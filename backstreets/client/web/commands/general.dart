/// General commands.
library general;

import 'package:game_utils/game_utils.dart';

import '../authentication.dart';
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
