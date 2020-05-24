/// Provides building related hotkeys.
library building;

import 'package:game_utils/game_utils.dart';

import '../main.dart';
import '../map_section.dart';

import '../menus/map_section_menu.dart';

import '../util.dart';


void builderMenu() {
  commandContext.book = Book(bookOptions);
  final Page page = Page(
    lines: <Line>[
      Line(commandContext.book, () {
        commandContext.section ??= MapSection(
          null, commandContext.coordinates.x.floor(),
          commandContext.coordinates.y.floor(),
          commandContext.coordinates.x.floor(),
          commandContext.coordinates.y.floor(),
          'Untitled Section', commandContext.tileNames[0], 0.5
        );
        commandContext.book.push(
          mapSectionMenu(commandContext.book, commandContext.section, commandContext, onUpload: () {
            commandContext.section = null;
            commandContext.book = null;
          })
        );
      }, titleString: 'New Section Menu'),
      Line(commandContext.book, () =>commandContext.book.push(
        mapSectionMenu(commandContext.book, commandContext.getCurrentSection(), commandContext)
      ), titleString: 'Current Section Menu'),
      Line(commandContext.book, () {
        final List<Line> lines = <Line>[];
        commandContext.sections.forEach((int id, MapSection s) => lines.add(
          Line(
            commandContext.book, () => commandContext.book.push(mapSectionMenu(commandContext.book, s, commandContext)
          ), titleFunc: () => '${s.name} (${s.startX}, ${s.startY} -> ${s.endX}, ${s.endY})', soundUrl: () => getFootstepSound(s.tileName))
        ));
        commandContext.book.push(Page(titleString: 'Map Sections', lines: lines));
      }, titleString: 'Other Sections Menu'),
      Line (commandContext.book, () {
        commandContext.book.push(
          Page(
            titleString: 'Map', lines: <Line>[
              Line(commandContext.book, () => commandContext.book.push(
                Page.soundsPage(
                  commandContext.book, commandContext.ambiences.keys.toList(), (String ambience) {
                    commandContext.send('mapAmbience', <String>[ambience]);
                    commandContext.book.pop();
                  }, (String name) => commandContext.ambiences[name], currentSound: commandContext.ambienceUrl
                )
              ), titleFunc: () => 'Ambience (${commandContext.ambienceUrl})'),
              Line(commandContext.book, () {
                  commandContext.book = null;
                FormBuilder('Rename Map', (Map<String, String> data) {
                  resetFocus();
                  commandContext.send('renameMap', <String>[data['name']]);
                },
                showMessage, subTitle: 'Enter the new name for this map.')
                  ..addElement(
                    'name', label: 'Map Name',
                    validator: notSameAsValidator(() => commandContext.mapName, message: 'The new map name cannot be the same as the old one.', onSuccess: notEmptyValidator),
                    value: commandContext.mapName
                  )
                  ..render(formBuilderDiv, beforeRender: keyboard.releaseAll);
              }, titleString: 'Rename Map'),
            ]
          )
        );
      }, titleString: 'Map Menu'),
    ], titleString: 'Building', onCancel: () {
      showMessage('Done.');
      clearBook();
    }
  );
  commandContext.book.push(page);
}
