/// Provides admin related hotkeys.
library admin;

import 'package:game_utils/game_utils.dart';

import '../game/map_reference.dart';

import '../main.dart';

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
        }, titleString: 'Add Map'),
        Line(commandContext.book, () {
          clearBook();
          commandContext.getObjectList(editObjects, 'adminPlayerList');
        }, titleString: 'Edit Player'),
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
      ], onCancel: clearBook)
    );
}
