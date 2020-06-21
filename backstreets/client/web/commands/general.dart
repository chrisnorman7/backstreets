/// General commands.
library general;

import 'dart:math';

import 'package:game_utils/game_utils.dart';

import '../authentication.dart';
import '../constants.dart';
import '../game/game_object.dart';
import '../game/radio_channel.dart';
import '../menus/edit_radio_channel_page.dart';
import '../menus/main_menu.dart';
import '../util.dart';
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
    ..mouseSensitivity = data['mouseSensitivity'] as int
    ..connectNotifications = data['connectNotifications'] as bool
    ..disconnectNotifications = data['disconnectNotifications'] as bool;
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
        data['locationId'] as int, data['locationName'] as String, permissions, account,
        data['ownerId'] as int, data['ownerName'] as String,
        data['connectionName'] as String, data['secondsInactive'] as int, data['lastActive'] as String,
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

void accounts(CommandContext ctx) {
  final List<dynamic> accounts = ctx.args[0] as List<dynamic>;
  final Book b = Book(bookOptions);
  final List<Line> lines = <Line>[];
  for (final dynamic data in accounts) {
    final int id = data['id'] as int;
    final String username = data['username'] as String;
    final String lockedMessage = data['lockedMessage'] as String;
    lines.add(Line(b, () {
      final List<Line> lines = <Line>[
        Line(b, resetFocus, titleString: 'Username: $username'),
        Line(b, resetFocus, titleString: 'ID: $id'),
      ];
      if (lockedMessage == null) {
        lines.add(Line(b, () => lockAccount(id), titleString: 'Lock Account'));
      } else {
        lines.addAll(<Line>[
          Line(b, resetFocus, titleString: 'Lock Reason: $lockedMessage'),
          Line(b, () => lockAccount(id, true), titleString: 'Unlock Account')
        ]);
      }
      b.push(Page(lines: lines, titleString: username));
    }, titleString: '$username${lockedMessage == null ? "" : " (Locked)"}'));
  }
  commandContext.book = b
    ..push(Page(lines: lines, titleString: 'Accounts (${accounts.length})', onCancel: doCancel));
}

void menu(CommandContext ctx) {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  final String title = data['title'] as String;
  final List<Line> lines = <Line>[];
  final Book b = Book(bookOptions);
  for (final dynamic itemData in data['items'] as List<dynamic>) {
    lines.add(Line(b, () {
      clearBook();
      commandContext.send(itemData['command'] as String, itemData['args'] as List<dynamic>);
    }, titleString: itemData['title'] as String));
  }
  commandContext.book = b
    ..push(Page(lines: lines, titleString: title, onCancel: doCancel));
}

void editRadioChannel(CommandContext ctx) {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  final int id = data['id'] as int;
  final String name = data['name'] as String;
  final String transmitSound = data['transmitSound'] as String;
  final bool admin = data['admin'] as bool;
  final RadioChannel channel = RadioChannel(id, name, transmitSound, admin);
  ctx.book = Book(bookOptions);
  ctx.book.push(editRadioChannelPage(ctx.book, channel));
}
