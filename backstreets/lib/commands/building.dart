/// Provides building commands.
library building;

import 'package:aqueduct/aqueduct.dart';

import '../model/game_map.dart';

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
