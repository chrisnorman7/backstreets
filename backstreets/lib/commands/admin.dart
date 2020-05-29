/// Provides admin related commands.
library admin;

import 'package:aqueduct/aqueduct.dart';

import '../model/game_object.dart';

import 'command_context.dart';

Future<void> adminPlayerList(CommandContext ctx) async {
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..join(object: (GameObject o) => o.account)
    ..join(object: (GameObject o) => o.location)
    ..where((GameObject o) => o.account).isNotNull();
  final List<Map<String, dynamic>> players = <Map<String, dynamic>>[];
  for (final GameObject o in await q.fetch()) {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': o.id, 'name': o.name, 'x': o.x, 'y': o.y,
      'locationId': o.location.id, 'locationName': o.location.name, 'builder': o.builder, 'admin': o.admin,
      'accountId': o.account.id, 'username': o.account.username
    };
    players.add(data);
  }
  ctx.send('listOfObjects', <dynamic>[players]);
}

Future<void> renameObject(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final String name = ctx.args[1] as String;
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..values.name = name
    ..where((GameObject o) => o.id).equalTo(id);
  final GameObject o = await q.updateOne();
  o.commandContext?.send('characterName', <String>[o.name]);
  ctx.message('Object rename.');
}

Future<void> setObjectPermission(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final String permission = ctx.args[1] as String;
  final bool value = ctx.args[2] as bool;
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..where((GameObject o) => o.account).isNotNull()
    ..where((GameObject o) => o.id).equalTo(id);
  if (permission == 'builder') {
    q.values.builder = value;
  } else if (permission == 'admin') {
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
