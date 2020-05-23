/// Provides login commands.
library login;

import 'package:aqueduct/aqueduct.dart';

import '../model/account.dart';
import '../model/game_map.dart';
import '../model/game_object.dart';
import '../sound.dart';

import 'command_context.dart';

/// The sound to play when the player logs in.
const String loginSound = 'general/welcome.wav';

/// The sound to play when there is a login failure.
const String loginError = 'general/loginerror.wav';

Future<void> createAccount(CommandContext ctx) async {
  final String username = ctx.args[0] as String;
  final String password = ctx.args[1] as String;
  Account a = Account()
    ..username = username
    ..setPassword(password);
  try {
    a = await ctx.db.insertObject(a);
    ctx.logger.info('Created account $username.');
    ctx.account = a;
    await ctx.sendAccount();
    ctx.sendInterfaceSound(Sound(loginSound));
  }
  catch(e) {
    ctx.sendError('There is already an account with that username.');
    rethrow;
  }
}

Future<void> login(CommandContext ctx) async {
  final String username = ctx.args[0] as String;
  final String password = ctx.args[1] as String;
  final Query<Account> q = Query<Account>(ctx.db)
    ..where((Account a) => a.username).equalTo(username);
  final Account a = await q.fetchOne();
  if (a != null && a.verify(password)) {
    ctx.logger.info('Authenticated as $username.');
    ctx.account = a;
    await ctx.sendAccount();
    return ctx.sendInterfaceSound(Sound(loginSound));
  }
  ctx.logger.info('Failed to authenticate as $username.');
  ctx.sendError('Invalid username or password.', sound: Sound(loginError));
}

Future<void> createCharacter(CommandContext ctx) async {
  final String name = ctx.args[0] as String;
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..where((GameObject o) => o.name).equalTo(name)
    ..where((GameObject o) => o.account.id).isNotNull();
  if (await q.reduce.count() > 0) {
    return ctx.sendError('There is already a character named $name.');
  }
  final Query<GameMap> mapQuery = Query<GameMap>(ctx.db);
  final GameMap m = await mapQuery.fetchOne();
  final Query<GameObject> adminQuery = Query<GameObject>(ctx.db)
    ..where((GameObject o) => o.admin).equalTo(true);
  GameObject character = GameObject()
    ..admin = await adminQuery.reduce.count() == 0
    ..name = name
    .. account = await ctx.getAccount()
    ..location = m
    ..x = m.popX.toDouble()
    ..y = m.popY.toDouble();
  character = await ctx.db.insertObject(character);
  ctx.character = character;
  ctx.map = m;
  await ctx.sendCharacter();
  ctx.logger.info('Created character $character.');
}

Future<void> connectCharacter(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..join(object: (GameObject c) => c.location)
    ..where((GameObject c) => c.id).equalTo(id)
    ..where((GameObject c) => c.account.id).equalTo(ctx.accountId);
  final GameObject c = await q.fetchOne();
  if (c == null) {
    return ctx.sendError('That character is not registered to your account.');
  }
  ctx.character = c;
  ctx.map = c.location;
  await ctx.sendCharacter();
  ctx.logger.info('Connected to object $c.');
}
