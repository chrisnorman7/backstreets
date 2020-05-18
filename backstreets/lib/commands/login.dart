/// Provides login commands.
library login;

import 'package:aqueduct/aqueduct.dart';

import '../model/account.dart';
import '../model/game_map.dart';
import '../model/game_object.dart';
import '../sound.dart';

import 'command.dart';
import 'command_context.dart';

/// The sound to play when the player logs in.
const String loginSound = 'general/welcome.wav';

/// The sound to play when there is a login failure.
const String loginError = 'general/loginerror.wav';

final Command createAccount = Command('createAccount', (CommandContext ctx) async {
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
}, authenticationType: AuthenticationTypes.anonymous);

final Command login = Command('login', (CommandContext ctx) async {
  final String username = ctx.args[0] as String;
  final String password = ctx.args[1] as String;
  final Query<Account> q = Query<Account>(ctx.db)
    ..join(set: (Account a) => a.objects)
    ..where((Account a) => a.username).equalTo(username);
  final Account a = await q.fetchOne();
  if (a != null && a.verify(password)) {
    await ctx.sendAccount();
    ctx.logger.info('Authenticated as $username.');
    ctx.account = a;
    return ctx.sendInterfaceSound(Sound(loginSound));
  }
  ctx.logger.info('Failed to authenticate as $username.');
  ctx.sendError('Invalid username or password.', sound: Sound(loginError));
}, authenticationType: AuthenticationTypes.anonymous);

final Command createCharacter = Command('createCharacter', (CommandContext ctx) async {
  final String name = ctx.args[0] as String;
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..where((GameObject o) => o.name).equalTo(name)
    ..where((GameObject o) => o.account.id).isNotNull();
  if (await q.reduce.count() > 0) {
    return ctx.sendError('There is already a character named $name.');
  }
  final Query<GameMap> mapQuery = Query<GameMap>(ctx.db);
  final GameMap m = await mapQuery.fetchOne();
  GameObject character = GameObject()
    ..name = name
    .. account = await ctx.getAccount()
    ..location = m
    ..x = m.popX
    ..y = m.popY;
  character = await ctx.db.insertObject(character);
  ctx.character = character;
  ctx.sendCharacter(character);
}, authenticationType: AuthenticationTypes.account);

final Command connectCharacter = Command('connectCharacter', (CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..where((GameObject c) => c.id).equalTo(id)
    ..where((GameObject c) => c.account.id).equalTo(ctx.accountId);
  final GameObject c = await q.fetchOne();
  if (c == null) {
    return ctx.sendError('That character is not registered to your account.');
  }
  ctx.character = c;
  ctx.sendCharacter(c);
  ctx.logger.info('Connected to object ${c.name} (#${c.id}).');
}, authenticationType: AuthenticationTypes.account);
