/// Provides staff only commands.
library staff;

import 'package:aqueduct/aqueduct.dart';

import '../model/game_map.dart';
import '../model/game_object.dart';
import 'command_context.dart';

Future<void> teleport(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final double x = (ctx.args[1] as num).toDouble();
  final double y = (ctx.args[2] as num).toDouble();
  final GameMap m = await ctx.db.fetchObjectWithID(id);
  if (m == null) {
    return ctx.sendError('Invalid map ID.');
  }
  final GameObject c = await ctx.getCharacter();
  await c.move(ctx.db, x, y, destination: m);
}

Future<void> renameObject(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final String name = ctx.args[1] as String;
  final GameObject c = await ctx.getCharacter();
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..values.name = name
    ..where((GameObject o) => o.id).equalTo(id);
  if (c.builder) {
    q.where((GameObject o) => o.account).isNull();
  }
  final GameObject o = await q.updateOne();
  o.commandContext?.send('characterName', <String>[o.name]);
  ctx.message('Object rename.');
}

Future<void> summonObject(CommandContext ctx) async {
  GameObject c = await ctx.getCharacter();
  Query<GameObject> q = Query<GameObject>(ctx.db)
    ..where((GameObject o) => o.id).equalTo(ctx.args[0] as int);
  if (!c.builder) {
    q.where((GameObject o) => o.account).isNull();
  }
  GameObject o = await q.fetchOne();
  if (o == null) {
    return ctx.sendError('Invalid object ID.');
  }
  o = await o.move(ctx.db, c.x, c.y, destination: await ctx.getMap());
  q = Query<GameObject>(ctx.db)
    ..where((GameObject obj) => obj.location).identifiedBy(ctx.mapId);
  final List<GameObject> observers = await q.fetch();
  c = observers.firstWhere((GameObject obj) => obj.id == c.id);
  o = observers.firstWhere((GameObject obj) => obj.id == o.id);
  await c.doSocial(ctx.db, '%1N summon%1s %2n.', perspectives: <GameObject>[c, o], observers: observers);
}
