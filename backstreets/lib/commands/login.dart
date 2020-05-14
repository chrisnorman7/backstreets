/// Provides login commands.
library login;

import '../game/account.dart';

import 'command.dart';
import 'command_context.dart';

final Command createAccount = Command(
  'createAccount', (CommandContext ctx) {
    final String username = ctx.args[0] as String;
    final String password = ctx.args[1] as String;
    if (accounts.containsKey(username)) {
      return ctx.sendError('That username is already taken.');
    }
    ctx.account = Account(username);
    ctx.account.setPassword(password);
    ctx.sendAccount(ctx.account);
  }, authenticationType: AuthenticationTypes.anonymous
);

final Command login = Command(
  'login', (CommandContext ctx) {
    final String username = ctx.args[0] as String;
    final String password = ctx.args[1] as String;
    if (accounts.containsKey(username) && accounts[username].verify(password)) {
      final Account account = accounts[username];
      ctx.account = account;
      return ctx.sendAccount(account);
    }
    ctx.sendError('Invalid username or password.');
  }, authenticationType: AuthenticationTypes.anonymous
);
