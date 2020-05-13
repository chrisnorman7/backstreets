/// Provides login commands.
library login;

import '../game/account.dart';

import 'command.dart';
import 'command_context.dart';

class LoginCommands extends CommandCollection {
  @override
  LoginCommands(): super('Login Commands');

  @command
  void createAccount(CommandContext ctx) {
    final String username = ctx.args[0] as String;
    final String password = ctx.args[1] as String;
    if (accounts.containsKey(username)) {
      ctx.sendError('That username is already taken.');
    } else if (password.isEmpty) {
      ctx.sendError('Passwords must not be blank.');
    } else {
      ctx.account = Account(username);
      ctx.account.setPassword(password);
      ctx.sendAccount(ctx.account);
    }
  }

  @command
  void login(CommandContext ctx) {
    final String username = ctx.args[0] as String;
    final String password = ctx.args[1] as String;
    if (accounts.containsKey(username) && accounts[username].verify(password)) {
      final Account account = accounts[username];
      ctx.account = account;
      return ctx.sendAccount(account);
    }
    ctx.sendError('Invalid username or password.');
  }
}
