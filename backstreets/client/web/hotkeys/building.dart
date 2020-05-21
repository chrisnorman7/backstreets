/// Provides building related commands.
library building;

import 'dart:math';

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
        final List<Line> lines = <Line>[];
        if (commandContext.section == null) {
          lines.add(Line(b, (Book b) {
            b.pop();
            commandContext.section = CreatedMapSection('Untitled Section');
            commandContext.message('Empty section created. Go back to the building menu to see further options.');
          }, titleString: 'Create'));
        } else {
          lines.addAll(<Line>[
            Line(b, (Book b) {
              final FormBuilder fb = FormBuilder('Rename', (Map<String, String> data) {
                if (commandContext.section == null) {
                  b.message('You must create a new section.');
                } else {
                  commandContext.section.name = data['name'];
                  commandContext.book = null;
                }
              });
              fb.addElement('name', validator: notEmptyValidator, value: commandContext.section.name);
              fb.render();
            }, titleFunc: () => 'Rename (${commandContext.section.name})'),
            Line(b, (Book b) {
              b.push(
                Page.selectTilePage(
                  b, () => commandContext.section.tileName,
                  (String name) {
                    b.pop();
                    commandContext.section.tileName = name;
                    commandContext.message('Default tile set to $name.');
                  },
                )
              );
            }, titleFunc: () => 'Set DefaultTile (${commandContext.section.tileName})'),
            Line(b, (Book b) {
              if (commandContext.section == null) {
                b.message('You must create a new section.');
              } else {
                commandContext.section.startCoordinates = Point<int>(commandContext.coordinates.x.toInt(), commandContext.coordinates.y.toInt());
                commandContext.message('Start coordinates set.');
              }
            }, titleFunc: () => 'Set Start Coordinates (${commandContext.section.startCoordinates})'),
            Line(b, (Book b) {
              if (commandContext.section == null) {
                b.message('You must create a new section.');
              } else {
                commandContext.section.endCoordinates = Point<int>(commandContext.coordinates.x.toInt(), commandContext.coordinates.y.toInt());
                commandContext.message('End coordinates set.');
              }
            }, titleFunc: () => 'Set End Coordinates ((${commandContext.section.endCoordinates})'),
            Line(b, (Book b) {
              if (commandContext.section == null) {
                commandContext.message('You must first create a section.');
              } else if (commandContext.section.name == null || commandContext.section.name.isEmpty) {
                commandContext.message('You must first set a name.');
              } else if (commandContext.section.tileName == null) {
                commandContext.message('You must set the default tile.');
              } else if (commandContext.section.startCoordinates == null) {
                commandContext.message('You must first set start coordinates.');
              } else if (commandContext.section.endCoordinates == null) {
                commandContext.message('You must first set end coordinates.');
              } else {
                commandContext.send('addMapSection', <Map<String, dynamic>>[commandContext.section.asMap()]);
                commandContext.message('Uploading.');
                commandContext.book = null;
                commandContext.section = null;
              }
            }, titleString: 'Upload'),
            Line(b, (Book b) {
              commandContext.section = null;
              commandContext.book = null;
              commandContext.message('Reset.');
            }, titleString: 'Reset')
          ]);
        }
        b.push(Page(titleString: 'New Section', lines: lines));
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
      }, titleString: 'Current Section Menu'),
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
