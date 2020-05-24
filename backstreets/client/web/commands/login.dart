/// Provides login commands.
library login;

import 'package:game_utils/game_utils.dart';

import '../authentication.dart';
import '../main.dart';

import '../util.dart';

import 'command_context.dart';

/// Login was successful.
///
/// Show the menu with all the players for the given account, and let the player create a new character.
Future<void> account(CommandContext ctx) async {
  authenticationStage = AuthenticationStages.account;
  ctx.book = Book(bookOptions);
  ctx.username = ctx.args[0] as String;
  final List<Line> lines = <Line>[];
  characterList = ctx.args[1] as List<dynamic>;
  for (final dynamic characterData in characterList) {
    final Map<String, dynamic> data = characterData as Map<String, dynamic>;
    final int id = data['id'] as int;
    final String name = data['name'] as String;
    lines.add(
      Line(
        commandContext.book, () {
          commandContext.book = null;
          ctx.message('Loading...');
          ctx.send('connectCharacter', <int>[id]);
        }, titleString: name
      )
    );
  }
  lines.add(
    Line(
      commandContext.book, () {
        FormBuilder(
          'New Character', (Map<String, String> data) {
            clearBook();
            ctx.message('Creating character...');
            ctx.send('createCharacter', <String>[data['name']]);
          }, showMessage,
          subTitle: 'Enter the name for your new character',
          submitLabel: 'Create Character',
          cancellable: true, onCancel: resetFocus
        )
          ..addElement('name', label: 'Character Name')
          ..render(formBuilderDiv, beforeRender: keyboard.releaseAll);
      }, titleString: 'New Character'
    )
  );
  ctx.book.push(
    Page(
      titleString: 'Character Selection',
      lines: lines,
      dismissible: false
    )
  );
}

/// Save the character name.
///
/// Also sets the title of the page.
Future<void> characterName(CommandContext ctx) async {
  // Don't keep the character list lying around.
  characterList = null;
  authenticationStage = AuthenticationStages.connected;
  ctx.characterName = ctx.args[0] as String;
  setTitle(state: ctx.characterName);
}

/// Says whether or not this character is an admin.
Future<void> admin(CommandContext ctx) async {
  ctx.admin = ctx.args[0] as bool;
}
