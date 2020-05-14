/// The main commands library. Contains the [commands] [Map].
library commands;

import '../form_builder.dart';
import '../main.dart';
import '../menus/book.dart';
import '../menus/line.dart';
import '../menus/page.dart';

import 'command_context.dart';
import 'sound.dart';

/// The type for all command functions.
typedef CommandType = void Function(CommandContext);

/// A map containing all the commands which can be called by the server.
Map<String, CommandType> commands = <String, CommandType>{
  'message': (CommandContext ctx) => ctx.message(ctx.args[0] as String),
  'interfaceSound': interfaceSound,
  'account': (CommandContext ctx) {
    book = Book(ctx.sounds, ctx.message);
    final List<Line> lines = <Line>[];
    final List<dynamic> characterList = ctx.args[1] as List<dynamic>;
    for (final dynamic characterData in characterList) {
      final Map<String, String> data = characterData as Map<String, String>;
      final String id = data['id'];
      final String name = data['name'];
      lines.add(
        Line(
          book, (Book b) {
            book = null;
            ctx.sendCommand('connectCharacter', <String>[id]);
          }, titleString: name
        )
      );
    }
    lines.add(
      Line(
        book, (Book b) {
          final FormBuilder createForm = FormBuilder(
            'New Character',
            (Map<String, String> data) => ctx.sendCommand('createCharacter', <String>[data['name']]),
            subTitle: 'Enter the name for your new character',
            submitLabel: 'Create Character'
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
};
