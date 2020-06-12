/// Provides staff only commands.
library staff;

import 'package:aqueduct/aqueduct.dart';
import 'package:backstreets/model/builder_permission.dart';

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
  if (!c.admin) {
    q.where((GameObject o) => o.account).isNull();
  }
  final GameObject o = await q.updateOne();
  if (c == null) {
    return ctx.sendError('Invalid object ID.');
  }
  o.commandContext?.send('characterName', <String>[o.name]);
  ctx.message('Object rename.');
}

Future<void> summonObject(CommandContext ctx) async {
  final GameObject c = await ctx.getCharacter();
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..where((GameObject o) => o.id).equalTo(ctx.args[0] as int);
  if (!c.admin) {
    q.where((GameObject o) => o.account).isNull();
  }
  GameObject o = await q.fetchOne();
  if (o == null) {
    return ctx.sendError('Invalid object ID.');
  }
  o = await o.move(ctx.db, c.x, c.y, destination: await ctx.getMap());
  await c.doSocial(ctx.db, '%1N summon%1s %2n.', others: <GameObject>[o]);
}

Future<void> addBuilderPermission(CommandContext ctx) async {
  final int objectId = ctx.args[0] as int;
  final int mapId = ctx.args[1] as int;
  final GameObject o = await ctx.db.fetchObjectWithID<GameObject>(objectId);
  if (o == null || o.account == null) {
    return ctx.sendError('Invalid object ID.');
  }
  final GameMap m = await ctx.db.fetchObjectWithID<GameMap>(mapId);
  if (m == null) {
    return ctx.sendError('Invalid map ID.');
  }
  final Query<BuilderPermission> q = Query<BuilderPermission>(ctx.db)
    ..where((BuilderPermission p) => p.object).identifiedBy(objectId)
    ..where((BuilderPermission p) => p.location).identifiedBy(mapId);
  if ((await q.reduce.count()) > 0) {
    return ctx.message('${o.name} can already build on ${m.name}.');
  }
  BuilderPermission p = BuilderPermission()
    ..object = o
    ..location = m;
  p = await ctx.db.insertObject(p);
  if (p == null) {
    return ctx.sendError('Something went wrong while creating the permission.');
  }
  o.message('You are now allowed to build on ${m.name}.');
  ctx.message('${o.name} can now build on ${m.name}.');
  if (o.location == m && GameObject.commandContexts.containsKey(o.id)) {
    GameObject.commandContexts[o.id].send('builder', <bool>[true]);
  }
}

Future<void> removeBuilderPermission(CommandContext ctx) async {
  final int objectId = ctx.args[0] as int;
  final int mapId = ctx.args[1] as int;
  final GameObject o = await ctx.db.fetchObjectWithID<GameObject>(objectId);
  if (o == null) {
    return ctx.sendError('Invalid object ID.');
  }
  final GameMap m = await ctx.db.fetchObjectWithID<GameMap>(mapId);
  if (m == null) {
    return ctx.sendError('Invalid map ID.');
  }
  final Query<BuilderPermission> q = Query<BuilderPermission>(ctx.db)
    ..where((BuilderPermission p) => p.object).identifiedBy(objectId)
    ..where((BuilderPermission p) => p.location).identifiedBy(mapId);
  final int deleted = await q.delete();
  if (deleted == 0) {
    return ctx.sendError('${o.name} could not build on ${m.name} in the first place.');
  }
  o.message('You are no longer allowed to build on ${m.name}.');
  ctx.message('${o.name} can no longer build on ${m.name}.');
  if (o.location == m && GameObject.commandContexts.containsKey(o.id)) {
    GameObject.commandContexts[o.id].send('builder', <bool>[false]);
  }
}

Future<void> getMapBuilders(CommandContext ctx) async {
  final Query<BuilderPermission> q = Query<BuilderPermission>(ctx.db)
    ..join(object: (BuilderPermission p) => p.object)
    ..where((BuilderPermission p) => p.location).identifiedBy(ctx.mapId);
  await ctx.sendObjects(<GameObject>[for (final BuilderPermission p in await q.fetch()) p.object]);
}

Future<void> addMapBuilder(CommandContext ctx) async {
  final GameMap m = await ctx.getMap();
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..where((GameObject o) => o.account).isNotNull();
  final List<GameObject> objects = <GameObject>[];
  for (final GameObject o in await q.fetch()) {
    if (!(await o.canBuild(ctx.db, m))) {
      objects.add(o);
    }
  }
  await ctx.sendObjects(objects);
}
