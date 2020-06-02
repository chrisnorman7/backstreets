/// Provides staff only commands.
library staff;

import 'package:aqueduct/aqueduct.dart';

import '../model/game_map.dart';
import '../model/game_object.dart';

import 'command_context.dart';

Future<void> teleport(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  double x = ctx.args[1] as double;
  double y = ctx.args[2] as double;
  final Query<GameMap> mapQuery = Query<GameMap>(ctx.db)
    ..where((GameMap m) => m.id).equalTo(id);
  final GameMap m = await mapQuery.fetchOne();
  x ??= m.popX.toDouble();
  y ??= m.popY.toDouble();
  ctx.message(m.name);
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..values.location = m
    ..values.x = x
    ..values.y = y
    ..where((GameObject o) => o.id).equalTo(ctx.characterId);
  await q.updateOne();
  ctx.map = m;
  await ctx.sendMap();
  ctx.send('characterCoordinates', <double>[x, y]);
}
