/// Provides building related hotkeys.
library building;

import 'dart:math';

import 'package:game_utils/game_utils.dart';

import '../game/map_reference.dart';
import '../game/map_section.dart';
import '../game/wall.dart';

import '../main.dart';

import '../menus/edit_convolver_page.dart';

import '../menus/map_section_page.dart';

import '../util.dart';

void builderMenu() {
  final MapReference m = commandContext.maps[commandContext.map.id];
  commandContext.book = Book(bookOptions);
  final Page page = Page(
    lines: <Line>[
      Line(commandContext.book, () {
        commandContext.section ??= MapSection(
          commandContext.sounds, null, commandContext.coordinates.x.floor(),
          commandContext.coordinates.y.floor(),
          commandContext.coordinates.x.floor(),
          commandContext.coordinates.y.floor(),
          'Untitled Section', commandContext.tileNames[0], 0.5,
          null, 1.0, null
        );
        commandContext.book.push(
          mapSectionPage(commandContext.book, commandContext.section, commandContext, onUpload: () {
            commandContext.section = null;
            clearBook();
          })
        );
      }, titleString: 'New Section Menu'),
      Line(commandContext.book, () {
        final MapSection s = commandContext.getCurrentSection();
        if (s == null) {
          return showMessage('There is currently no section. Either return to an existing section, or create a new section.');
        }
        commandContext.book.push(mapSectionPage(commandContext.book, s, commandContext));
      }, titleString: 'Current Section Menu'),
      Line(commandContext.book, () {
        final List<Line> lines = <Line>[];
        commandContext.map.sections.forEach((int id, MapSection s) => lines.add(
          Line(
            commandContext.book, () => commandContext.book.push(mapSectionPage(commandContext.book, s, commandContext)
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
                  }, (String name) => commandContext.ambiences[name], currentSound: commandContext.map.ambience.url
                )
              ), titleFunc: () => 'Ambience (${commandContext.map.ambience.url})'),
              Line(
                commandContext.book, () => commandContext.book.push(
                  editConvolverPage(
                    commandContext.book, commandContext.map.convolver,
                    onChange: () {
                      commandContext.send('mapConvolver', <Map<String, dynamic>>[
                        <String, dynamic>{
                          'url': commandContext.map.convolver.url,
                          'volume': commandContext.map.convolver.volume.gain.value,
                        }
                      ]);
                    }
                  )
                ), titleString: 'Convolver'
              ),
              Line(commandContext.book, () {
                  commandContext.book = null;
                FormBuilder('Rename Map', (Map<String, String> data) {
                  commandContext.send('renameMap', <String>[data['name']]);
                }, showMessage, subTitle: 'Enter the new name for this map.', onCancel: resetFocus)
                  ..addElement(
                    'name', label: 'Map Name',
                    validator: notSameAsValidator(() => commandContext.map.name, message: 'The new map name cannot be the same as the old one.', onSuccess: notEmptyValidator),
                    value: commandContext.map.name
                  )
                  ..render(formBuilderDiv, beforeRender: keyboard.releaseAll);
              }, titleString: 'Rename Map'),
              Line(commandContext.book, () {
                clearBook();
                moveCharacter(Point<double>(m.popX.toDouble(), m.popY.toDouble()), mode: MoveModes.staff);
              }, titleString: 'Go To Pop Coordinates'),
              Line(commandContext.book, () => commandContext.send('setPopCoordinates', <int>[commandContext.coordinates.x.round(), commandContext.coordinates.y.round()]), titleString: 'Set Pop Coordinates (${m.popX}, ${m.popY}'),
              Line.checkboxLine(commandContext.book, () => '${m.playersCanCreate ? "Disable" : "Enable"} Player Creation', () => m.playersCanCreate, (bool value) {
                clearBook();
                commandContext.send('setPlayersCanCreate', <bool>[value]);
              })
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

void buildWall() => commandContext.send('addWall', <String>[]);

void buildBarricade () => commandContext.send('addBarricade', <String>[]);

void wallMenu() {
  final Point<int> coordinates = Point<int>(commandContext.coordinates.x.floor(), commandContext.coordinates.y.floor());
  final Wall currentWall = commandContext.map.walls[coordinates];
  final List<Line> lines = <Line>[];
  if (currentWall == null) {
    lines.addAll(<Line>[
      Line(commandContext.book, () {
        clearBook();
        buildWall();
      }, titleString: 'Build a wall'),
      Line(commandContext.book, () {
        clearBook();
        buildBarricade();
      }, titleString: 'Build a barricade'),
    ]);
  } else {
    lines.addAll(<Line>[
      Line(commandContext.book, () {
        commandContext.message('You cannot currently change wall sounds.');
      }, titleFunc: () => 'Sound (${currentWall.sound})'),
      Line(commandContext.book, () {
        commandContext.send('deleteWall', <int>[currentWall.id]);
        clearBook();
      }, titleString: 'Delete')
    ]);
  }
  commandContext.book = Book(bookOptions)
    ..push(Page(lines: lines, titleString: 'Wall Menu', onCancel: clearBook));
}
