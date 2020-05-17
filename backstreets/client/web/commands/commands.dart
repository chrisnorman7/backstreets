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
typedef CommandType = Future<void> Function(CommandContext);

/// A map containing all the commands which can be called by the server.
Map<String, CommandType> commands = <String, CommandType>{
  'message': (CommandContext ctx) async {
    ctx.message(ctx.args[0] as String);
  },
  'interfaceSound': interfaceSound,
  'account': (CommandContext ctx) async {
    book = Book(ctx.sounds, ctx.message);
    final List<Line> lines = <Line>[];
    final List<dynamic> characterList = ctx.args[1] as List<dynamic>;
    for (final dynamic characterData in characterList) {
      final Map<String, dynamic> data = characterData as Map<String, dynamic>;
      final int id = data['id'] as int;
      final String name = data['name'] as String;
      lines.add(
        Line(
          book, (Book b) {
            book = null;
            ctx.sendCommand('connectCharacter', <int>[id]);
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
};
