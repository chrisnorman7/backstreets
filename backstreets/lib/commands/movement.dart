/// Provides movement-related commands.
library movement;

import 'package:aqueduct/aqueduct.dart';

import '../model/game_map.dart';
import '../model/game_object.dart';

import 'command_context.dart';

Future<void> characterCoordinates(CommandContext ctx) async {
  double x, y;
  if (ctx.args[0] is int) {
    x = (ctx.args[0] as int).toDouble();
  } else {
    x = ctx.args[0] as double;
  }
  if (ctx.args[1] is int) {
    y = (ctx.args[1] as int).toDouble();
  } else {
    y = ctx.args[1] as double;
  }
  final GameMap m = await ctx.getMap();
  final GameObject c = await ctx.getCharacter();
  if (await m.validCoordinates(ctx.db, x.floor(), y.floor())) {
    final Query<GameObject> q = Query<GameObject>(ctx.db)
      ..values.x = x
      ..values.y = x
      ..where((GameObject o) => o.id).equalTo(c.id);
    await q.updateOne();
  } else {
    ctx.send('characterCoordinates', <double>[c.x, c.y]);
  }
}

Future<void> characterTheta(CommandContext ctx) async {
  double theta;
  if (ctx.args[0] is int) {
    theta = (ctx.args[0] as int).toDouble();
  } else {
    theta = ctx.args[0] as double;
  }
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..values.theta = theta
    ..where((GameObject o) => o.id).equalTo(ctx.characterId);
  await q.updateOne();
}
