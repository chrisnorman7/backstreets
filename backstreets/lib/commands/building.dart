/// Provides building commands.
library building;

import 'dart:math';

import 'package:aqueduct/aqueduct.dart';

import '../model/game_map.dart';
import '../model/game_object.dart';
import '../model/map_section.dart';
import '../model/map_wall.dart';

import '../sound.dart';

import 'command_context.dart';

/// Renames the map the connected object is on.
Future<void> renameMap(CommandContext ctx) async {
  final Query<GameMap> q = Query<GameMap>(ctx.db)
    ..values.name = ctx.args[0] as String
    ..where((GameMap m) => m.id).equalTo(ctx.mapId);
  final GameMap m = await q.updateOne();
  await m.broadcastCommand(ctx.db, 'mapName', <String>[m.name]);
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
  await m.broadcastCommand(ctx.db, 'mapSectionAmbience', <Map<String, dynamic>>[<String, dynamic>{'id': s.id, 'url': s.ambience}]);
  ctx.message('Ambience updated.');
}
