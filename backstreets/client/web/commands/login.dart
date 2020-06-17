/// Provides login commands.
library login;

import 'package:game_utils/game_utils.dart';

import '../authentication.dart';
import '../constants.dart';
import '../game/map_reference.dart';
import '../main.dart';
import '../menus/map_reference_page.dart';
import '../util.dart';
import 'command_context.dart';

/// Login was successful.
///
/// Show the menu with all the players for the given account, and let the player create a new character.
void account(CommandContext ctx) {
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
          clearBook();
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
            resetFocus();
            ctx.book = Book(bookOptions)
              ..push(
                mapReferencePage('Create Character', (MapReference m) {
                  clearBook();
                  ctx.message('Creating character...');
                  ctx.send('createCharacter', <dynamic>[m.id, data['name']]);
                }, shouldInclude: (MapReference r) => r.playersCanCreate,
                onCancel: () {
                  ctx.args = <dynamic>[ctx.username, characterList];
                  account(ctx);
                })
              );
          }, showMessage,
          subTitle: 'Enter the name for your new character',
          submitLabel: 'Create Character',
          cancellable: true, onCancel: doCancel
        )
          ..addElement('name', label: 'Character Name', validator: notEmptyValidator)
          ..render(formBuilderDiv, beforeRender: keyboard.releaseAll);
      }, titleString: 'New Character'
    )
  );
  final Page page = Page(titleString: 'Character Selection', lines: lines, dismissible: false);
  ctx.book.push(page);
}

/// Save the character name.
///
/// Also sets the title of the page.
void characterName(CommandContext ctx) {
  // Don't keep the character list lying around.
  characterList = null;
  authenticationStage = AuthenticationStages.connected;
  ctx.characterName = ctx.args[0] as String;
  setTitle(state: ctx.characterName);
}

/// Says whether or not this character is a builder.
void builder(CommandContext ctx) {
  ctx.permissions.builder= ctx.args[0] as bool;
  builderControls.hidden = !ctx.permissions.builder;
  staffControls.hidden = !ctx.permissions.staff;
}

/// Says whether or not this character is an admin.
void admin(CommandContext ctx) {
  ctx.permissions.admin = ctx.args[0] as bool;
  adminControls.hidden = !ctx.permissions.admin;
  staffControls.hidden = !ctx.permissions.staff;
}
