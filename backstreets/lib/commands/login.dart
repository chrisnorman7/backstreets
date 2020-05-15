/// Provides login commands.
library login;

import 'package:aqueduct/aqueduct.dart';

import '../model/account.dart';
import '../sound.dart';

import 'command.dart';
import 'command_context.dart';

/// The sound to play when the player logs in.
const String loginSound = 'general/welcome.wav';

/// The sound to play when there is a login failure.
const String loginError = 'general/loginerror.wav';

final Command createAccount = Command(
  'createAccount', (CommandContext ctx) async {
    final String username = ctx.args[0] as String;
    final String password = ctx.args[1] as String;
    Account a = Account()
      ..username = username
      ..setPassword(password);
    a = await ctx.db.insertObject(a);
    ctx.logger.info('Created account $username.');
    ctx.account = a;
    ctx.sendAccount(a);
    ctx.sendInterfaceSound(Sound(loginSound));
  }, authenticationType: AuthenticationTypes.anonymous
);

final Command login = Command(
  'login', (CommandContext ctx) async {
    final String username = ctx.args[0] as String;
    final String password = ctx.args[1] as String;
    final Query<Account> q = Query<Account>(ctx.db)
      ..where((Account a) => a.username).equalTo(username);
    final Account a = await q.fetchOne();
    if (a != null && a.verify(password)) {
      ctx.logger.info('Authenticated as $username.');
      ctx.account = a;
      ctx.sendAccount(a);
      ctx.sendInterfaceSound(Sound(loginSound));
    } else {
      ctx.logger.info('Failed to authenticate as $username.');
      ctx.sendError('Invalid username or password.', sound: Sound(loginError));
    }
  }, authenticationType: AuthenticationTypes.anonymous
);
