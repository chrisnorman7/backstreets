/// Provides building related hotkeys.
library building;

import '../form_builder.dart';

import '../keyboard/hotkey.dart';

import '../main.dart';
import '../map_section.dart';

import '../menus/book.dart';
import '../menus/line.dart';
import '../menus/map_section_menu.dart';
import '../menus/page.dart';

import 'run_conditions.dart';

final Hotkey builderMenu = Hotkey('b', () {
  commandContext.book = Book(commandContext.sounds, showMessage, onCancel: clearBook);
  final Page page = Page(
    lines: <Line>[
      Line(commandContext.book, (Book b) {
        commandContext.section ??= MapSection(
          null, commandContext.coordinates.x.floor(),
          commandContext.coordinates.y.floor(),
          commandContext.coordinates.x.floor(),
          commandContext.coordinates.y.floor(),
          'Untitled Section', commandContext.tileNames[0], 0.5
        );
        b.push(
          mapSectionMenu(b, commandContext.section, commandContext, () {
            commandContext.section = null;
            commandContext.book = null;
          })
        );
      }, titleString: 'New Section Menu'),
      Line(commandContext.book, (Book b) {
        b.push(Page(
          titleString: 'Edit Section', lines: <Line>[
            Line(b, (Book b) {
              b.push(
                Page.selectTilePage(
                  b, () => commandContext.getCurrentSection().tileName,
                  (String name) {
                    b.pop();
                    final MapSection s = commandContext.getCurrentSection();
                    if (s == null) {
                      return commandContext.message('There is no section at your current coordinates.');
                    }
                    commandContext.send('sectionTileName', <dynamic>[s.id, name]);
                  }
                )
              );
            }, titleString: 'Set Default Tile'),
            Line(b, (Book b) {
              FormBuilder('Rename Section', (Map<String, String> data) {
                b.pop();
                final MapSection s = commandContext.getCurrentSection();
                if (s == null) {
                  return commandContext.message('There is no section at your current coordinates.');
                  }
                  commandContext.send('renameSection', <dynamic>[s.id, data['name']]);
              })
                ..addElement(
                  'name', label: 'Section Name',
                  validator: notSameAsValidator(
                    () => commandContext.getCurrentSection().name,
                    onSuccess: notEmptyValidator
                  ),
                  value: commandContext.getCurrentSection().name
                )
                ..render();
            }, titleString: 'Rename'),
          ],
        ));
      }, titleString: 'Current Section Menu'),
      Line (commandContext.book, (Book b) {
        b.push(
          Page(
            titleString: 'Map', lines: <Line>[
              Line(b, (Book b) {
                final List<Line> lines = <Line>[];
                commandContext.ambiences.forEach((String name, String url) {
                  lines.add(
                    Line(b, (Book b) {
                      commandContext.send('mapAmbience', <String>[name]);
                      b.pop();
                    }, titleString: name,
                    soundUrl: () => url)
                  );
                });
                b.push(Page(titleString: 'Ambiences', lines: lines));
              }, titleFunc: () => 'Ambience (${commandContext.ambienceUrl})'),
              Line(b, (Book b) {
                commandContext.book = null;
                FormBuilder(
                  'Rename Map', (Map<String, String> data) => commandContext.send('renameMap', <String>[data['name']]),
                  subTitle: 'Enter the new name for this map.'
                )
                  ..addElement(
                    'name', label: 'Map Name',
                    validator: notSameAsValidator(() => commandContext.mapName, message: 'The new map name cannot be the same as the old one.', onSuccess: notEmptyValidator),
                    value: commandContext.mapName)
                  ..render();
              }, titleString: 'Rename Map'),
            ]
          )
        );
      }, titleString: 'Map Menu'),
    ], titleString: 'Building'
  );
  commandContext.book.push(page);
}, runWhen: admin);
