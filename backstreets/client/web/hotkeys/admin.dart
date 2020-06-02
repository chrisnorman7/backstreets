/// Provides admin related hotkeys.
library admin;

import 'package:game_utils/game_utils.dart';

import '../game/game_object.dart';
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
          showMessage('Loading players...');
          clearBook();
          commandContext.send('adminPlayerList', null);
          commandContext.onListOfObjects = () {
            final List<Line> lines = <Line>[];
              for (final GameObject o in commandContext.objects) {
                lines.add(
                  Line(commandContext.book, () => commandContext.book.push(editObjectPage(commandContext.book, o)), titleString: o.name)
                );
              }
            commandContext.book = Book(bookOptions)
              ..push(Page(lines: lines, titleFunc: () => 'Players (${commandContext.objects.length})', onCancel: clearBook));
          };
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
