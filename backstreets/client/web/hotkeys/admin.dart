/// Provides admin related hotkeys.
library admin;

import 'package:game_utils/game_utils.dart';

import '../constants.dart';
import '../game/map_reference.dart';
import '../menus/edit_object_page.dart';
import '../menus/map_reference_page.dart';
import '../util.dart';

void adminMenu() {
  commandContext.book = Book(bookOptions)
    ..push(
      Page(titleString: 'Admin Menu', lines: <Line>[
        Line(commandContext.book, () {
          commandContext.send('addMap', <String>[]);
          clearBook();
        }, titleString: 'New Map'),
        Line(commandContext.book, () => getString('Broadcast Announcement', () => '', (String value) {
          clearBook();
          commandContext.send('broadcast', <String>[value]);
        }, emptyString: EmptyStringHandler.disallow), titleString: 'Broadcast'),
        Line(commandContext.book, () => getString('Create Radio Channel', () => 'New Radio Channel', (String value) {
          final List<Line> lines = <Line>[];
          commandContext.radioSounds.forEach((String name, String url) {
            lines.add(Line(commandContext.book, () {
              clearBook();
              commandContext.send('addRadioChannel', <String>[value, name]);
            }, titleString: name, soundUrl: () => url));
          });
          commandContext.book.push(Page(lines: lines, onCancel: doCancel, titleString: 'Sounds'));
        }, emptyString: EmptyStringHandler.disallow, label: 'Channel Name'), titleString: 'New Radio Channel'),
        Line(commandContext.book, () {
          clearBook();
          commandContext.getObjectList(editObjects, 'adminPlayerList');
        }, titleString: 'Player List'),
        Line(commandContext.book, () {
          clearBook();
          commandContext.send('accounts', null);
        }, titleString: 'Accounts'),
        Line(commandContext.book, () {
          commandContext.book.push(
            mapReferencePage('Delete Map', (MapReference m) {
              commandContext.book.push(Page.confirmPage(commandContext.book, () {
                commandContext.send('deleteGameMap', <int>[m.id]);
                clearBook();
              }));
            })
          );
        }, titleString: 'Delete Map'),
      ], onCancel: doCancel)
    );
}
