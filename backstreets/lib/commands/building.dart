/// Provides building commands.
library building;

import 'dart:math';

import 'package:aqueduct/aqueduct.dart';

import '../model/game_map.dart';
import '../model/map_section.dart';

import '../sound.dart';

import 'command_context.dart';

Future<void> renameMap(CommandContext ctx) async {
  final Query<GameMap> q = Query<GameMap>(ctx.db)
    ..values.name = ctx.args[0] as String
    ..where((GameMap m) => m.id).equalTo(ctx.mapId);
  final GameMap m = await q.updateOne();
  await m.broadcastCommand(ctx.db, 'mapName', <String>[m.name]);
  ctx.sendMessage('Map renamed.');
}

Future<void> addMapSection(CommandContext ctx) async {
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
    ..values.location.id = ctx.mapId;
  final MapSection s = await q.insert();
  final GameMap m = await ctx.getMap();
  await m.broadcastCommand(ctx.db, 'mapSection', <Map<String, dynamic>>[s.asMap()]);
  ctx.sendMessage('Section added.');
}

Future<void> mapAmbience(CommandContext ctx) async {
  final String ambience = ctx.args[0] as String;
  if (ambiences.containsKey(ambience)) {
    final Query<GameMap> q = Query<GameMap>(ctx.db)
      ..values.ambience = ambience
      ..where((GameMap m) => m.id).equalTo(ctx.mapId);
    final GameMap m = await q.updateOne();
    await m.broadcastCommand(ctx.db, 'mapAmbience', <String>[ambiences[ambience].url]);
  } else {
    ctx.sendError('Invalid ambience "$ambience".');
  }
}

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
    ..where((MapSection s) => s.location).identifiedBy(ctx.mapId)
    ..where((MapSection s) => s.id).equalTo(id);
  final MapSection s = await q.updateOne();
  if (s == null) {
    ctx.sendError('Invalid map section. Maybe someone else deleted it?');
  } else {
    final GameMap m = await ctx.getMap();
    await m.broadcastCommand(ctx.db, 'mapSection', <Map<String, dynamic>>[s.asMap()]);
    ctx.sendMessage('Section edited.');
  }
}

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
    ctx.sendMessage('Section Deleted.');
  }
}
