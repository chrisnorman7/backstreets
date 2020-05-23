/// Provides building commands.
library building;

import 'package:aqueduct/aqueduct.dart';

import '../model/game_map.dart';
import '../model/map_section.dart';

import '../sound.dart';

import 'command.dart';
import 'command_context.dart';

final Command renameMap = Command('renameMap', (CommandContext ctx) async {
  final Query<GameMap> q = Query<GameMap>(ctx.db)
    ..values.name = ctx.args[0] as String
    ..where((GameMap m) => m.id).equalTo(ctx.mapId);
  final GameMap m = await q.updateOne();
  ctx.sendMessage('Map renamed.');
  ctx.send('mapName', <String>[m.name]);
}, authenticationType: AuthenticationTypes.admin);

final Command renameSection = Command('renameSection', (CommandContext ctx) async {
  final Query<MapSection> q = Query<MapSection>(ctx.db)
    ..values.name = ctx.args[1] as String
    ..where((MapSection s) => s.id).equalTo(ctx.args[0] as int);
  final MapSection s = await q.updateOne();
  ctx.send('renameSection', <dynamic>[s.id, s.name]);
  ctx.sendMessage('Section renamed.');
}, authenticationType: AuthenticationTypes.admin);

final Command sectionTileName = Command('sectionTileName', (CommandContext ctx) async {
  final Query<MapSection> q = Query<MapSection>(ctx.db)
    ..values.tileName = ctx.args[1] as String
    ..where((MapSection s) => s.id).equalTo(ctx.args[0] as int);
  final MapSection s = await q.updateOne();
  ctx.send('sectionTileName', <dynamic>[s.id, s.tileName]);
  ctx.sendMessage('Default tile updated.');
}, authenticationType: AuthenticationTypes.admin);

final Command addMapSection = Command('addMapSection', (CommandContext ctx) async {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  final Query<MapSection> q = Query<MapSection>(ctx.db)
    ..values.tileName = data['tileName'] as String
    ..values.name = data['name'] as String
    ..values.startX = data['startX'] as int
    ..values.startY = data['startY'] as int
    ..values.endX = data['endX'] as int
    ..values.endY = data['endY'] as int
    ..values.location.id = ctx.mapId;
  final MapSection s = await q.insert();
  ctx.sendMapSection(s);
}, authenticationType: AuthenticationTypes.admin);

final Command mapAmbience = Command('mapAmbience', (CommandContext ctx) async {
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
}, authenticationType: AuthenticationTypes.admin);
