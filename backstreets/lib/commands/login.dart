/// Provides login commands.
library login;

import '../game/account.dart';
import '../sound.dart';

import 'command.dart';
import 'command_context.dart';

/// The sound to play when the player logs in.
const String loginSound = 'general/welcome.wav';

/// The sound to play when there is a login failure.
const String loginError = 'general/loginerror.wav';

final Command createAccount = Command(
  'createAccount', (CommandContext ctx) {
    final String username = ctx.args[0] as String;
    final String password = ctx.args[1] as String;
    if (accounts.containsKey(username)) {
      return ctx.sendError('That username is already taken.', sound: Sound(loginError));
    }
    ctx.account = Account(username);
    accounts[ctx.account.username] = ctx.account;
    ctx.account.setPassword(password);
    ctx.sendAccount(ctx.account);
    ctx.sendInterfaceSound(Sound(loginSound));
  }, authenticationType: AuthenticationTypes.anonymous
);

final Command login = Command(
  'login', (CommandContext ctx) {
    final String username = ctx.args[0] as String;
    final String password = ctx.args[1] as String;
    if (accounts.containsKey(username) && accounts[username].verify(password)) {
      final Account account = accounts[username];
      ctx.account = account;
      ctx.sendAccount(account);
      ctx.sendInterfaceSound(Sound(loginSound));
    } else {
      ctx.sendError('Invalid username or password.', sound: Sound(loginError));
    }
  }, authenticationType: AuthenticationTypes.anonymous
);
