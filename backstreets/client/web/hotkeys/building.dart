/// Provides building related commands.
library building;

import '../form_builder.dart';

import '../keyboard/hotkey.dart';

import '../main.dart';
import '../map_section.dart';

import '../menus/book.dart';
import '../menus/line.dart';
import '../menus/page.dart';

final Hotkey builderMenu = Hotkey('b', () {
  commandContext.book = Book(commandContext.sounds, showMessage);
  final Page page = Page(
    lines: <Line>[
      Line(commandContext.book, (Book b) {
        b.push(Page(
          titleString: 'Edit Section', lines: <Line>[
            Line(b, (Book b) {
              final List<Line> lines = <Line>[];
              for (final String name in commandContext.tileNames) {
                lines.add(
                  Line(b, (Book b) {
                    b.pop();
                    final MapSection s = commandContext.getCurrentSection();
                    if (s == null) {
                      return commandContext.message('There is no section at your current coordinates.');
                    }
                    commandContext.send('sectionTileName', <dynamic>[s.id, name]);
                  }, titleString: name)
                );
              }
              b.push(Page(titleString: 'Tile Name', lines: lines));
            }, titleString: 'Set Default Tile'),
            Line(b, (Book b) {
              final FormBuilder fb = FormBuilder('Rename Section', (Map<String, String> data) {
                b.pop();
                final MapSection s = commandContext.getCurrentSection();
                if (s == null) {
                  return commandContext.message('There is no section at your current coordinates.');
                  }
                  commandContext.send('renameSection', <dynamic>[s.id, data['name']]);
              });
              fb.addElement(
                'name', label: 'Section Name',
                validator: notSameAsValidator(() => commandContext.getCurrentSection().name, onSuccess: notEmptyValidator),
                value: commandContext.getCurrentSection().name
              );
              fb.render();
            }, titleString: 'Rename'),
          ],
        ));
      }, titleString: 'Current Section'),
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
