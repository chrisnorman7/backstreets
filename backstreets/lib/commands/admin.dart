/// Provides admin related commands.
library admin;

import 'dart:io';

import 'package:aqueduct/aqueduct.dart';
import 'package:backstreets/model/builder_permission.dart';

import '../model/game_map.dart';
import '../model/game_object.dart';

import 'command_context.dart';

Future<void> adminPlayerList(CommandContext ctx) async {
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..join(object: (GameObject o) => o.account)
    ..join(object: (GameObject o) => o.location)
    ..where((GameObject o) => o.account).isNotNull()
    ..sortBy((GameObject o) => o.name, QuerySortOrder.ascending);
  await ctx.sendObjects(await q.fetch());
}

Future<void> setObjectPermission(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final String permission = ctx.args[1] as String;
  final bool value = ctx.args[2] as bool;
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..where((GameObject o) => o.account).isNotNull()
    ..where((GameObject o) => o.id).equalTo(id);
  if (permission == 'admin') {
    q.values.admin = value;
  } else {
    return ctx.sendError('Invalid permission name "$permission".');
  }
  final GameObject o = await q.updateOne();
  if (o == null) {
    return ctx.sendError('Invalid object.');
  }
  ctx.message('Permissions updated.');
  final CommandContext c = o.commandContext;
  if (c != null) {
    c.send(permission, <bool>[value]);
    c.message('Permission $permission ${value ? "set" : "unset"}.');
  }
}

Future<void> addMap(CommandContext ctx) async {
  GameMap m = GameMap()
    ..name = 'Untitled Map';
  m = await ctx.db.insertObject(m);
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..values.location = m
    ..values.x = m.popX.toDouble()
    ..values.y = m.popY.toDouble()
    ..where((GameObject o) => o.id).equalTo(ctx.characterId);
  await q.updateOne();
  ctx.map = m;
  CommandContext.broadcast('addGameMap', <Map<String, dynamic>>[m.minimalData]);
  ctx.send('characterCoordinates', <int>[m.popX, m.popY]);
  await ctx.sendMap();
  ctx.message('${m.name} created.');
}

Future<void> deleteGameMap(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final Query<GameMap> q = Query<GameMap>(ctx.db)
    ..join(set: (GameMap m) => m.objects)
    ..where((GameMap m) => m.id).equalTo(id);
  final GameMap m = await q.fetchOne();
  if (m.objects.isNotEmpty) {
    return ctx.sendError('First remove all remaining objects. Objects: ${m.objects.length}.');
  }
  final int deleted = await q.delete();
  if (deleted == 0) {
    return ctx.sendError('Failed to delete the map.');
  }
  CommandContext.broadcast('deleteGameMap', <int>[id]);
  ctx.message('Map deleted.');
}

Future<void> revokeBuilderPermissions(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final Query<BuilderPermission> q = Query<BuilderPermission>(ctx.db)
    ..where((BuilderPermission p) => p.object).identifiedBy(id);
  final int deleted = await q.delete();
  ctx.message('Builder permissions deleted: $deleted.');
  if (GameObject.commandContexts.containsKey(id)) {
    GameObject.commandContexts[id].send('builder', <bool>[false]);
  }
}

Future<void> getPossibleOwners(CommandContext ctx) async {
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..join(object: (GameObject o) => o.location)
    ..join(object: (GameObject o) => o.owner)
    ..where((GameObject o) => o.account).isNotNull();
  await ctx.sendObjects(await q.fetch());
}

Future<void> bootPlayer(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final CommandContext c = CommandContext.instances.firstWhere((CommandContext e) => e.characterId == id, orElse: () => null);
  if (c == null) {
    return ctx.sendError('Not connected.');
  }
  await c.socket.close(WebSocketStatus.normalClosure, ctx.args[1] as String);
  ctx.message('Done.');
}
