/// General commands.
library general;

import 'dart:math';

import 'package:game_utils/game_utils.dart';

import '../authentication.dart';
import '../game_object.dart';
import '../main.dart';

import '../menus/main_menu.dart';

import 'command_context.dart';
import 'login.dart';

/// Show a quick message.
Future<void> message(CommandContext ctx) async {
  ctx.message(ctx.args[0] as String);
}

/// Alert the player to an error.
///
/// Handles some special cases, like errors during the login process, where a certain menu needs to be re-shown.
Future<void> error(CommandContext ctx) async {
  final String msg = ctx.args[0] as String;
  if (authenticationStage == AuthenticationStages.anonymous) {
    // Probably a login failure.
    commandContext.book = Book(bookOptions)
      ..push(mainMenu());
  } else if (authenticationStage == AuthenticationStages.account) {
    // A problem creating or connecting to a player.
    ctx.args = <dynamic>[ctx.username, characterList];
    ctx.username = null;
    await account(ctx);
  } else if (authenticationStage == AuthenticationStages.connected) {
    // Do nothing but show the message.
  } else {
    ctx.message('Unknown authentication stage: $authenticationStage.');
  }
  ctx.message('Error: $msg');
}

/// Parses player options.
Future<void> playerOptions(CommandContext ctx) async {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  ctx.sounds.setVolume(OutputTypes.sound, (data['soundVolume'] as num).toDouble());
  ctx.sounds.setVolume(OutputTypes.ambience, (data['ambienceVolume'] as num).toDouble());
  ctx.sounds.setVolume(OutputTypes.music, (data['musicVolume'] as num).toDouble());
}

/// A list of objects has been sent.
///
/// The onListOfObjects callback on the command context should know what to do with them.
Future<void> listOfObjects(CommandContext ctx) async {
  ctx.objects = <GameObject>[];
  final Map<int, Account> accounts = <int, Account>{};
  for (final dynamic data in ctx.args[0] as List<dynamic>) {
    final Permissions permissions = Permissions(builder: data['builder'] as bool, admin: data['admin'] as bool);
    final int accountId = data['accountId'] as int;
    Account account;
    if (accountId != null) {
      if (!accounts.containsKey(accountId)) {
        accounts[accountId] = Account(accountId, data['username'] as String);
      }
      account = accounts[accountId];
    }
    final Point<double> coordinates = Point<double>((data['x'] as num).toDouble(), (data['y'] as num).toDouble());
    ctx.objects.add(
      GameObject(
        data['id'] as int, data['name'] as String, coordinates,
        data['locationId'] as int, data['locationName'] as String, permissions, account
      )
    );
    if (ctx.onListOfObjects == null) {
      ctx.message('Unsolicited list of objects received.');
    } else {
      ctx.onListOfObjects();
    }
  }
}
