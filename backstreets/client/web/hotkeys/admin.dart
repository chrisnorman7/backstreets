/// Provides admin related hotkeys.
library admin;

import 'package:game_utils/game_utils.dart';

import '../game_object.dart';
import '../main.dart';

import '../menus/edit_object_page.dart';
import '../util.dart';

void adminMenu() {
  commandContext.book = Book(bookOptions)
    ..push(
      Page(titleString: 'Admin Menu', lines: <Line>[
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
        }, titleString: 'Edit Player')
      ], onCancel: clearBook)
    );
}
