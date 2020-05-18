/// Provides login commands.
library login;

import '../authentication.dart';
import '../form_builder.dart';
import '../main.dart';
import '../menus/book.dart';
import '../menus/line.dart';
import '../menus/page.dart';

import 'command_context.dart';

Future<void> account(CommandContext ctx) async {
  authenticationStage = AuthenticationStages.account;
  book = Book(ctx.sounds, ctx.message);
  final List<Line> lines = <Line>[];
  characterList = ctx.args[1] as List<dynamic>;
  for (final dynamic characterData in characterList) {
    final Map<String, dynamic> data = characterData as Map<String, dynamic>;
    final int id = data['id'] as int;
    final String name = data['name'] as String;
    lines.add(
      Line(
        book, (Book b) {
          book = null;
          ctx.message('Please wait.');
          ctx.sendCommand('connectCharacter', <int>[id]);
        }, titleString: name
      )
    );
  }
  lines.add(
    Line(
      book, (Book b) {
        book = null;
        final FormBuilder createForm = FormBuilder(
          'New Character', (Map<String, String> data) {
            ctx.message('Creating character...');
            ctx.sendCommand('createCharacter', <String>[data['name']]);
          },
          subTitle: 'Enter the name for your new character',
          submitLabel: 'Create Character',
          cancellable: true
        );
        createForm.addElement('name', label: 'Character Name');
        createForm.render();
      }, titleString: 'New Character'
    )
  );
  ctx.username = ctx.args[0] as String;
  book.push(
    Page(
      titleString: 'Character Selection',
      lines: lines,
      dismissible: false
    )
  );
}

Future<void> characterName(CommandContext ctx) async {
  // Don't keep the character list lying around.
  characterList = null;
  authenticationStage = AuthenticationStages.connected;
  ctx.characterName = ctx.args[0] as String;
  setTitle(state: ctx.characterName);
}
