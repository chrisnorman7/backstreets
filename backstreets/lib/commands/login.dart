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

/// Create an account with the given username and password.
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

/// Login with the given username and password.
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

/// Create a character with the given name.
///
/// This command checks for the existance of character objects ([GameObject] instances with a not-null account property) with the same name.
///
/// If any are found, then `ctx.sendError` is used to complain.
///
/// This triggers the client to show the character menu again.
///
/// At some point we should probably disconnect them after 3 failed login attempts or something, but (like death), not today.
///
/// Should probably also ensure that only a finite number of characters per account can be created.
Future<void> createCharacter(CommandContext ctx) async {
  final int mapId = ctx.args[0] as int;
  final String name = ctx.args[1] as String;
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..where((GameObject o) => o.name).equalTo(name)
    ..where((GameObject o) => o.account.id).isNotNull();
  if (await q.reduce.count() > 0) {
    return ctx.sendError('There is already a character named $name.');
  }
  final Query<GameMap> mapQuery = Query<GameMap>(ctx.db)
    ..where((GameMap m) => m.id).equalTo(mapId)
    ..where((GameMap m) => m.playersCanCreate).equalTo(true);
  final GameMap m = await mapQuery.fetchOne();
  if (m == null) {
    return ctx.sendError('Invalid map ID.');
  }
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

/// Connect the player to a character on their account.
/// The query that is used will only retrieve a character with given id, if their account id is the same as the one the socket is logged in with.
Future<void> connectCharacter(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..join(object: (GameObject c) => c.location)
    ..join(object: (GameObject o) => o.account)
    ..where((GameObject c) => c.id).equalTo(id)
    ..where((GameObject c) => c.account).identifiedBy(ctx.accountId);
  final GameObject c = await q.fetchOne();
  if (c == null) {
    return ctx.sendError('That character is not registered to your account.');
  }
  ctx.character = c;
  ctx.map = c.location;
  await ctx.sendCharacter();
  ctx.logger.info('Connected to object $c.');
}

Future<void> logout(CommandContext ctx) async {
  ctx.message('Logging you out.');
  ctx.character = null;
  await ctx.sendAccount();
}