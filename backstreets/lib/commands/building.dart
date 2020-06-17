/// Provides building commands.
library building;

import 'dart:math';

import 'package:aqueduct/aqueduct.dart';

import '../actions/actions.dart';
import '../game/npc.dart';
import '../model/exit.dart';
import '../model/game_map.dart';
import '../model/game_object.dart';
import '../model/map_section.dart';
import '../model/map_section_action.dart';
import '../model/map_wall.dart';
import '../sound.dart';
import 'command_context.dart';

/// Renames the map the connected object is on.
Future<void> renameMap(CommandContext ctx) async {
  final Query<GameMap> q = Query<GameMap>(ctx.db)
    ..values.name = ctx.args[0] as String
    ..where((GameMap m) => m.id).equalTo(ctx.mapId);
  final GameMap m = await q.updateOne();
  CommandContext.broadcast('mapName', <dynamic>[m.id, m.name]);
  ctx.message('Map renamed.');
}

/// Adds a new [MapSection] instance from the given data.
Future<void> addMapSection(CommandContext ctx) async {
  final GameMap m = await ctx.getMap();
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  final int startX = data['startX'] as int;
  final int startY = data['startY'] as int;
  final int endX = data['endX'] as int;
  final int endY = data['endY'] as int;
  final Query<MapSection> q = Query<MapSection>(ctx.db)
    ..values.tileName = data['tileName'] as String
    ..values.name = data['name'] as String
    ..values.startX = min(startX, endX)
    ..values.startY = min(startY, endY)
    ..values.endX = max(endX, startX)
    ..values.endY = max(endY, startY)
    ..values.tileSize = data['tileSize'] as double
    ..values.location = m;
  final MapSection s = await q.insert();
  await m.broadcastCommand(ctx.db, 'mapSection', <Map<String, dynamic>>[s.asMap()]);
  ctx.message('Section added.');
}

/// Change the ambience for the map the connected object is on.
Future<void> mapAmbience(CommandContext ctx) async {
  String ambience = ctx.args[0] as String;
  if (ambience == null || ambiences.containsKey(ambience)) {
    final Query<GameMap> q = Query<GameMap>(ctx.db)
      ..values.ambience = ambience
      ..where((GameMap m) => m.id).equalTo(ctx.mapId);
    final GameMap m = await q.updateOne();
    if (ambience != null) {
      ambience = ambiences[ambience].url;
    }
    await m.broadcastCommand(ctx.db, 'mapAmbience', <String>[ambience]);
  } else {
    ctx.sendError('Invalid ambience "$ambience".');
  }
}

/// Given a Map of data, edit a section of the current map by its ID.
Future<void> editMapSection(CommandContext ctx) async {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  final int id = data['id'] as int;
  final int startX = data['startX'] as int;
  final int startY = data['startY'] as int;
  final int endX = data['endX'] as int;
  final int endY = data['endY'] as int;
  final Query<MapSection> q = Query<MapSection>(ctx.db)
    ..values.tileName = data['tileName'] as String
    ..values.name = data['name'] as String
    ..values.startX = min(startX, endX)
    ..values.startY = min(startY, endY)
    ..values.endX = max(endX, startX)
    ..values.endY = max(endY, startY)
    ..values.tileSize = (data['tileSize'] as num).toDouble()
    ..values.convolverUrl = data['convolverUrl'] as String
    ..values.convolverVolume = (data['convolverVolume'] as num).toDouble()
    ..values.ambienceDistance = data['ambienceDistance'] as int
    ..where((MapSection s) => s.location).identifiedBy(ctx.mapId)
    ..where((MapSection s) => s.id).equalTo(id);
  final MapSection s = await q.updateOne();
  if (s == null) {
    ctx.sendError('Invalid map section. Maybe someone else deleted it?');
  } else {
    final GameMap m = await ctx.getMap();
    await m.broadcastCommand(ctx.db, 'mapSection', <Map<String, dynamic>>[s.toJson()]);
    ctx.message('Section edited.');
  }
}

/// Delete a section of the map the connected object is on.
Future<void> deleteMapSection(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final Query<MapSection> q = Query<MapSection>(ctx.db)
    ..where((MapSection s) => s.location).identifiedBy(ctx.mapId)
    ..where((MapSection s) => s.id).equalTo(id);
  final int deleted = await q.delete();
  if (deleted < 1) {
    ctx.sendError('Invalid map section. Maybe someone else deleted it?');
  } else {
    final GameMap m = await ctx.getMap();
    await m.broadcastCommand(ctx.db, 'deleteMapSection', <int>[id]);
    ctx.message('Section Deleted.');
  }
}

Future<void> mapConvolver(CommandContext ctx) async {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  final String url = data['url'] as String;
  final double volume = (data['volume'] as num).toDouble();
  final Query<GameMap> q = Query<GameMap>(ctx.db)
    ..values.convolverUrl = url
    ..values.convolverVolume = volume
    ..where((GameMap m) => m.id).equalTo(ctx.mapId);
  final GameMap m = await q.updateOne();
  if (m == null) {
    ctx.sendError('Invalid map ID.');
  } else {
    await m.broadcastCommand(ctx.db, 'mapConvolver', <Map<String, dynamic>>[<String, dynamic>{'url': url, 'volume': volume}]);
    ctx.message('Convolver updated.');
  }
}

/// Actually perform the building of a wall.
Future<void> buildWall(CommandContext ctx, WallTypes t) async {
  final GameObject c = await ctx.getCharacter();
  final GameMap m = await ctx.getMap();
  MapWall w = MapWall()
    ..location = m
    ..x = c.x.floor()
    ..y = c.y.floor()
    ..type = t;
  final Query<MapWall> q = Query<MapWall>(ctx.db)
    ..where((MapWall w) => w.location).identifiedBy(m.id)
    ..where((MapWall w) => w.x).equalTo(w.x)
    ..where((MapWall w) => w.y).equalTo(w.y);
  if (await q.reduce.count() == 0) {
    w = await ctx.db.insertObject(w);
  } else {
    q.values = w;
    w = await q.updateOne();
  }
  await m.broadcastWall(ctx.db, w);
  String s = t.toString();
  s = s.substring(s.indexOf('.') + 1);
  s = s[0].toUpperCase() + s.substring(1);
  ctx.message('$s added at ${w.x}, ${w.y}.');
}

Future<void> addWall(CommandContext ctx) async => buildWall(ctx, WallTypes.wall);

Future<void> addBarricade(CommandContext ctx) async => buildWall(ctx, WallTypes.barricade);

Future<void> deleteWall(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final Query<MapWall> q = Query<MapWall>(ctx.db)
    ..where((MapWall w) => w.id).equalTo(id)
    ..where((MapWall w) => w.location).identifiedBy(ctx.mapId);
  final int count = await q.delete();
  if (count == 0) {
    ctx.sendError('No such wall. Maybe somebody else already deleted it.');
  } else {
    final GameMap m = await ctx.getMap();
    await m.broadcastCommand(ctx.db, 'deleteWall', <int>[id]);
    ctx.message('Deleted.');
  }
}

Future<void> mapSectionAmbience(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final String url = ctx.args[1] as String;
  final Query<MapSection> q = Query<MapSection>(ctx.db)
    ..values.ambience = url
    ..where((MapSection s) => s.id).equalTo(id)
    ..where((MapSection s) => s.location).identifiedBy(ctx.mapId);
  final MapSection s = await q.updateOne();
  if (s == null) {
    return ctx.sendError('Invalid section ID.');
  }
  final GameMap m = await ctx.getMap();
  await m.broadcastCommand(ctx.db, 'mapSectionAmbience', <Map<String, dynamic>>[<String, dynamic>{'id': s.id, 'url': s.ambience, 'distance': s.ambienceDistance}]);
  ctx.message('Ambience updated.');
}

Future<void> setPlayersCanCreate(CommandContext ctx) async {
  final bool value = ctx.args[0] as bool;
  final Query<GameMap> q = Query<GameMap>(ctx.db)
    ..values.playersCanCreate = value
    ..where((GameMap m) => m.id).equalTo(ctx.mapId);
  final GameMap m = await q.updateOne();
  if (m == null) {
    return ctx.message('Invalid map ID.');
  }
  CommandContext.broadcast('setPlayersCanCreate', <dynamic>[m.id, m.playersCanCreate]);
  ctx.message('Value updated.');
}

Future<void> setPopCoordinates(CommandContext ctx) async {
  final int x = ctx.args[0] as int;
  final int y = ctx.args[1] as int;
  final Query<GameMap> q = Query<GameMap>(ctx.db)
    ..values.popX = x
    ..values.popY = y
    ..where((GameMap m) => m.id).equalTo(ctx.mapId);
  final GameMap m = await q.updateOne();
  if (m == null) {
      ctx.sendError('Invalid map ID.');
  } else {
    ctx.message('Pop coordinates updated.');
  }
}

Future<void> addMapSectionAction(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final String name = ctx.args[1] as String;
  final MapSection s = await ctx.db.fetchObjectWithID<MapSection>(id);
  if (s == null) {
    return ctx.sendError('Invalid map section ID.');
  }
  final Query<MapSectionAction> q = Query<MapSectionAction>(ctx.db)
    ..values.section = s
    ..values.name = name;
  final MapSectionAction a = await q.insert();
  final GameMap m = await ctx.getMap();
  await m.broadcastCommand(ctx.db, 'addMapSectionAction', <Map<String, dynamic>>[a.toJson()]);
  ctx.message('Action added.');
}

Future<void> removeMapSectionAction(CommandContext ctx) async {
  final int sectionId = ctx.args[0] as int;
  final int actionId = ctx.args[1] as int;
  final Query<MapSectionAction> q = Query<MapSectionAction>(ctx.db)
    ..where((MapSectionAction a) => a.section).identifiedBy(sectionId)
    ..where((MapSectionAction a) => a.id).equalTo(actionId);
  final int deleted = await q.delete();
  if (deleted == 0) {
    return ctx.sendError('No such action.');
  }
  final MapSection s = await ctx.db.fetchObjectWithID<MapSection>(sectionId);
  final GameMap m = await ctx.db.fetchObjectWithID<GameMap>(s.location.id);
  await m.broadcastCommand(ctx.db, 'removeMapSectionAction', <dynamic>[sectionId, actionId]);
  ctx.message('Actions removed: $deleted.');
}

Future<void> editMapSectionAction(CommandContext ctx) async {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  final int sectionId = data['sectionId'] as int;
  final Query<MapSection> mapSectionQuery = Query<MapSection>(ctx.db)
    ..where((MapSection s) => s.id).equalTo(sectionId)
    ..where((MapSection s) => s.location).identifiedBy(ctx.mapId);
  final MapSection s = await mapSectionQuery.fetchOne();
  if (s == null) {
    return ctx.sendError('Invalid section ID.');
  }
  final String functionName = data['functionName'] as String;
  if (functionName != null && !actions.containsKey(functionName)) {
    return ctx.sendError('Invalid function name.');
  }
  final String sound = data['sound'] as String;
  if (sound != null && !actionSounds.containsKey(sound)) {
    return ctx.sendError('Invalid sound.');
  }
  final int id = data['id'] as int;
  final Query<MapSectionAction> q = Query<MapSectionAction>(ctx.db)
    ..where((MapSectionAction a) => a.id).equalTo(id)
    ..values.section = s
    ..values.name = data['name'] as String
    ..values.functionName = functionName
    ..values.social = data['social'] as String
    ..values.sound = sound
    ..values.confirmMessage = data['confirmMessage'] as String
    ..values.confirmSocial = data['confirmSocial'] as String
    ..values.okLabel = data['okLabel'] as String
    ..values.cancelLabel = data['cancelLabel'] as String
    ..values.cancelSocial = data['cancelSocial'] as String;
  final MapSectionAction a = await q.updateOne();
  if (a == null) {
    return ctx.sendError('Invalid section ID.');
  }
  final GameMap m = await ctx.getMap();
await m.broadcastCommand(ctx.db, 'addMapSectionAction', <Map<String, dynamic>>[a.toJson()]);
ctx.message('Action updated.');
}

Future<void> addExit(CommandContext ctx) async {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  final String name = data['name'] as String;
  final GameMap location = await ctx.db.fetchObjectWithID<GameMap>(data['locationId'] as int);
  final GameMap destination = await ctx.db.fetchObjectWithID<GameMap>(data['destinationId'] as int);
  final int x = data['x'] as int;
  final int y = data['y'] as int;
  final int destinationX = data['destinationX'] as int;
  final int destinationY = data['destinationY'] as int;
  if (location == null || destination == null) {
    return ctx.sendError('Invalid location or destination ID.');
  }
  final Query<Exit> q = Query<Exit>(ctx.db)
    ..values.name = name
    ..values.location = location
    ..values.destination = destination
    ..values.x = x
    ..values.y = y
    ..values.destinationX = destinationX
    ..values.destinationY = destinationY;
  final Exit first = await q.insert();
  q
    ..values.location = destination
    ..values.destination = location
    ..values.x = destinationX
    ..values.y = destinationY
    ..values.destinationX = x
    ..values.destinationY = y;
  final Exit second = await q.insert();
  await location.broadcastCommand(ctx.db, 'addExit', <Map<String, dynamic>>[first.toJson()]);
  await destination.broadcastCommand(ctx.db, 'addExit', <Map<String, dynamic>>[second.toJson()]);
  ctx.message('Exit added.');
}

Future<void> editExit(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final Map<String, dynamic> data = ctx.args[1] as Map<String, dynamic>;
  final GameMap destination = await ctx.db.fetchObjectWithID<GameMap>(data['destinationId'] as int);
  final Query<Exit> q = Query<Exit>(ctx.db)
    ..values.name = data['name'] as String
    ..values.destination = destination
    ..values.x = data['x'] as int
    ..values.y = data['y'] as int
    ..values.destinationX = data['destinationX'] as int
    ..values.destinationY = data['destinationY'] as int
    ..values.useSocial = data['useSocial'] as String
    ..values.useSound = data['useSound'] as String
    ..values.admin = data['admin'] as bool
    ..values.builder = data['builder'] as bool
    ..where((Exit e) => e.location).identifiedBy(ctx.mapId)
    ..where((Exit e) => e.id).equalTo(id);
  final Exit e = await q.updateOne();
  if (e == null) {
    return ctx.message('Invalid exit ID.');
  }
  final GameMap m = await ctx.getMap();
  await m.broadcastCommand(ctx.db, 'addExit', <Map<String, dynamic>>[e.toJson()]);
  ctx.message('Exit updated.');
}

Future<void> deleteExit(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final Query<Exit> q = Query<Exit>(ctx.db)
    ..where((Exit e) => e.id).equalTo(id)
    ..where((Exit e) => e.location).identifiedBy(ctx.mapId);
  final int deleted = await q.delete();
  if (deleted == 0) {
    return ctx.sendError('Invalid exit ID.');
  }
  final GameMap m = await ctx.getMap();
  await m.broadcastCommand(ctx.db, 'deleteExit', <int>[id]);
  ctx.message('Exit deleted.');
}

Future<void> getObjects(CommandContext ctx) async {
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..join(object: (GameObject o) => o.location)
    ..where((GameObject o) => o.account).isNull()
    ..sortBy((GameObject o) => o.name, QuerySortOrder.ascending);
  if (!(await ctx.getCharacter()).admin) {
    q.where((GameObject o) => o.location).identifiedBy(ctx.mapId);
  }
  ctx.sendObjects(await q.fetch());
}

Future<void> addObject(CommandContext ctx) async {
  final GameMap m = await ctx.getMap();
  GameObject o = GameObject()
    ..name = 'Unnamed Object'
    ..location = m
    ..x = m.popX.toDouble()
    ..y = m.popY.toDouble()
    ..maxMoveTime = 4000;
  o = await ctx.db.insertObject(o);
  ctx.message('Created object ${o.name}.');
  npcMove(ctx.db, o.id);
}

Future<void> objectSpeed(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final int speed = ctx.args[1] as int;
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..values.speed = speed
    ..where((GameObject o) => o.id).equalTo(id);
  final GameObject o = await q.updateOne();
  if (o == null) {
    return ctx.sendError('Invalid object ID.');
  }
  if (moveTimers.containsKey(o.id)) {
    moveTimers[o.id].cancel();
    moveTimers.remove(o.id);
  }
  await npcMaybeMove(ctx.db, o.id);
  ctx.message('Speed updated.');
  o.commandContext?.send('characterSpeed', <int>[o.speed]);
}

Future<void> objectMaxMoveTime(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final int maxMoveTime = ctx.args[1] as int;
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..values.maxMoveTime = maxMoveTime
    ..where((GameObject o) => o.id).equalTo(id);
  final GameObject o = await q.updateOne();
  if (o == null) {
    return ctx.sendError('Invalid object ID.');
  }
  if (o.maxMoveTime == null) {
    if (moveTimers.containsKey(o.id)) {
      moveTimers[o.id].cancel();
      moveTimers.remove(o.id);
    }
  } else {
    await npcMaybeMove(ctx.db, o.id);
  }
  ctx.message('Max move time updated.');
}

Future<void> objectPhrase(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final String phrase = ctx.args[1] as String;
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..values.phrase = phrase
    ..where((GameObject o) => o.id).equalTo(id);
  final GameObject o = await q.updateOne();
  if (o == null) {
    return ctx.sendError('Invalid object ID.');
  }
  ctx.message('Phrase set.');
  if (o.phrase == null) {
    if (phraseTimers.containsKey(o.id)) {
      phraseTimers[o.id].cancel();
    }
  }else {
    await npcMaybePhrase(ctx.db, o.id);
  }
}

Future<void> objectMinPhraseTime(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final int value = ctx.args[1] as int;
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..values.minPhraseTime = value
    ..where((GameObject o) => o.id).equalTo(id);
  final GameObject o = await q.updateOne();
  if (o == null) {
    return ctx.sendError('Invalid object ID.');
  }
  ctx.message('Min phrase time updated.');
  if (o.maxPhraseTime != null) {
    await npcMaybePhrase(ctx.db, o.id);
  }
}

Future<void> objectMaxPhraseTime(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final int value = ctx.args[1] as int;
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..values.maxPhraseTime = value
    ..where((GameObject o) => o.id).equalTo(id);
  final GameObject o = await q.updateOne();
  if (o == null) {
    return ctx.sendError('Invalid object ID.');
  }
  ctx.message('Max phrase time updated.');
  if (o.maxPhraseTime != null) {
    await npcMaybePhrase(ctx.db, o.id);
  }
}

Future<void> objectFlying(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final bool flying = ctx.args[1] as bool;
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..values.flying = flying
    ..where((GameObject o) => o.id).equalTo(id);
  final GameObject o = await q.updateOne();
  if (o == null) {
    return ctx.sendError('Invalid object ID.');
  }
  ctx.message('Object is ${o.flying ? "now" : "no longer"} flying.');
}

Future<void> objectUseExitChance(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final int value = ctx.args[1] as int;
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..values.useExitChance = value
    ..where((GameObject o) => o.id).equalTo(id);
  final GameObject o = await q.updateOne();
  if (o == null) {
    return ctx.sendError('Invalid object ID.');
  }
  ctx.message('${o.name} now has a 1 in ${o.useExitChance} chance of going through exits.');
}

Future<void> objectCanLeaveMap(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final bool value = ctx.args[1] as bool;
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..values.canLeaveMap = value
    ..where((GameObject o) => o.id).equalTo(id);
  final GameObject o = await q.updateOne();
  if (o == null) {
    return ctx.sendError('Invalid object ID.');
  }
  ctx.message('Object ${o.canLeaveMap ? "can" : "cannot"} leave this map.');
}

Future<void> deleteObject(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..where((GameObject o) => o.id).equalTo(id)
    ..where((GameObject o) => o.account).isNull();
  final int deleted = await q.delete();
  if (deleted == 0) {
    return ctx.sendError('Invalid object ID.');
  }
  ctx.message('Object deleted.');
  if (moveTimers.containsKey(id)) {
    moveTimers[id].cancel();
    moveTimers.remove(id);
  }
  if (phraseTimers.containsKey(id)) {
    phraseTimers[id].cancel();
    phraseTimers.remove(id);
  }
}
