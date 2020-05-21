/// Provides building commands.
library building;

import 'package:aqueduct/aqueduct.dart';

import '../model/game_map.dart';
import '../model/map_section.dart';

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
