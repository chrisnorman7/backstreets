/// Provides building related commands.
library building;

import '../form_builder.dart';

import '../keyboard/hotkey.dart';

import '../main.dart';

import '../menus/book.dart';
import '../menus/line.dart';
import '../menus/page.dart';

final Hotkey builderMenu = Hotkey('b', () {
  commandContext.book = Book(commandContext.sounds, showMessage);
  final Page page = Page(
    lines: <Line>[
      Line(commandContext.book, (Book b) {
        commandContext.book = null;
        final FormBuilder fb = FormBuilder(
          'Rename Map', (Map<String, String> data) => commandContext.send('renameMap', <String>[data['name']]),
          subTitle: 'Enter the new name for this map.'
        );
        fb.addElement('name', label: 'Map Name', validator: (String name, Map<String, String> values, String value) {
          if (value == commandContext.mapName) {
            return 'The new map name cannot be the same as the old one.';
          } else {
            return notEmptyValidator(name, values, value);
          }
        }, value: commandContext.mapName);
        fb.render();
      }, titleString: 'Rename Map'),
    ], titleString: 'Building'
  );
  commandContext.book.push(page);
}, runWhen: () => commandContext.admin == true);
