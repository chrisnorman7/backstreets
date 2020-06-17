/// General commands.
library general;

import 'dart:math';

import 'package:game_utils/game_utils.dart';

import '../authentication.dart';
import '../constants.dart';
import '../game/game_object.dart';
import '../menus/main_menu.dart';
import 'command_context.dart';
import 'login.dart';

/// Show a quick message.
void message(CommandContext ctx) {
  ctx.message(ctx.args[0] as String);
}

/// Alert the player to an error.
///
/// Handles some special cases, like errors during the login process, where a certain menu needs to be re-shown.
void error(CommandContext ctx) {
  final String msg = ctx.args[0] as String;
  if (authenticationStage == AuthenticationStages.anonymous) {
    // Probably a login failure.
    commandContext.book = Book(bookOptions)
      ..push(mainMenu());
  } else if (authenticationStage == AuthenticationStages.account) {
    // A problem creating or connecting to a player.
    ctx.args = <dynamic>[ctx.username, characterList];
    ctx.username = null;
    account(ctx);
  } else if (authenticationStage == AuthenticationStages.connected) {
    // Do nothing but show the message.
  } else {
    ctx.message('Unknown authentication stage: $authenticationStage.');
  }
  ctx.message('Error: $msg');
}

/// Parses player options.
void playerOptions(CommandContext ctx) {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  ctx.sounds.setVolume(OutputTypes.sound, (data['soundVolume'] as num).toDouble());
  ctx.sounds.setVolume(OutputTypes.ambience, (data['ambienceVolume'] as num).toDouble());
  ctx.sounds.setVolume(OutputTypes.music, (data['musicVolume'] as num).toDouble());
  ctx.options
    ..echoLocationDistance = data['echoLocationDistance'] as int
    ..echoLocationDistanceMultiplier = data['echoLocationDistanceMultiplier'] as int
    ..echoSound = data['echoSound'] as String
    ..airbornElevate = data['airbornElevate'] as int
    ..wallFilterAmount = data['wallFilterAmount'] as int
    ..mouseSensitivity = data['mouseSensitivity'] as int;
}

/// A list of objects has been sent.
///
/// The onListOfObjects callback on the command context should know what to do with them.
void listOfObjects(CommandContext ctx) {
  ctx.objects = <GameObject>[];
  final Map<int, Account> accounts = <int, Account>{};
  for (final dynamic data in ctx.args[0] as List<dynamic>) {
    final bool builder = data['builder'] as bool;
    final bool admin = data['admin'] as bool;
    final int accountId = data['accountId'] as int;
    Permissions permissions;
    Account account;
    if (accountId != null) {
      permissions = Permissions(builder: builder, admin: admin);
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
        ..speed = data['speed'] as int
        ..maxMoveTime = data['maxMoveTime'] as int
        ..phrase = data['phrase'] as String
        ..minPhraseTime = data['minPhraseTime'] as int
        ..maxPhraseTime = data['maxPhraseTime'] as int
        ..flying = data['flying'] as bool
        ..useExitChance = data['useExitChance'] as int
        ..canLeaveMap = data['canLeaveMap'] as bool
    );
  }
  if (ctx.onListOfObjects == null) {
    ctx.message('Unsolicited list of objects received.');
  } else {
    ctx.onListOfObjects();
  }
}

void actionFunctions(CommandContext ctx) {
  ctx.actionFunctions.clear();
  for (final dynamic name in ctx.args[0] as List<dynamic>) {
    ctx.actionFunctions.add(name as String);
  }
}

void confirmAction(CommandContext ctx) {
  final int sectionId = ctx.args[0] as int;
  final int actionId = ctx.args[1] as int;
  ctx.map.sections[sectionId].actions[actionId].confirm();
}
