/// Provides general hotkeys.
library general;

import 'package:game_utils/game_utils.dart';

import '../directions.dart';
import '../game/exit.dart';
import '../game/map_section.dart';
import '../main.dart';
import '../menus/map_section_page.dart';
import '../menus/select_exit_page.dart';
import '../run_conditions.dart';
import '../util.dart';

void previousMessage() {
  String message;
  commandContext.messageIndex ??= commandContext.messages.length - 1;
  commandContext.messageIndex--;
  if (commandContext.messageIndex < 0) {
    commandContext.messageIndex = 0;
  }
  if (commandContext.messageIndex == null) {
    message = commandContext.messages.last;
  } else {
    message = commandContext.messages[commandContext.messageIndex];
  }
  showMessage(message);
}

void firstMessage() {
  commandContext.messageIndex = 1;
  return previousMessage();
}

void nextMessage() {
  String message;
  if (commandContext.messageIndex != null) {
    commandContext.messageIndex++;
    if (commandContext.messageIndex == commandContext.messages.length) {
      commandContext.messageIndex = null;
    }
  }
  if (commandContext.messageIndex == null) {
    message = commandContext.messages.last;
  } else {
    message = commandContext.messages[commandContext.messageIndex];
  }
  showMessage(message);
}

void lastMessage() {
  commandContext.messageIndex = null;
  return nextMessage();
}

void messages() {
  final List<Line> lines = <Line>[];
  for (final String message in commandContext.messages.reversed) {
    lines.add(
      Line(
        commandContext.book, clearBook, titleString: message
      )
    );
  }
  commandContext.book = Book(bookOptions)
    ..push(Page(titleString: 'Messages', lines: lines, onCancel: clearBook));
}

void hotkeys() {
  commandContext.book = Book(bookOptions);
  final Page hotkeysPage = Page.hotkeysPage(keyboard.hotkeys, commandContext.book, beforeRun: clearBook, onCancel: () {
    clearBook();
    resetFocus();
  });
  hotkeysPage.lines.insert(0, Line.checkboxLine(commandContext.book, () => '${commandContext.helpMode ? "Disable" : "Enable"} help mode', () => commandContext.helpMode, (bool value) {
    commandContext.helpMode = value;
    commandContext.message('Help mode ${value ? "enabled" : "disabled"}.');
  }));
  commandContext.book.push(hotkeysPage);
}

/// What to do with the arrow keys.
void doArrowKey(Directions d) {
  if (validBook()) {
    switch(d) {
      case Directions.west:
        commandContext.book.cancel();
        break;
      case Directions.east:
        commandContext.book.activate();
        break;
      case Directions.north:
        commandContext.book.moveUp();
        break;
      case Directions.south:
        commandContext.book.moveDown();
        break;
      default:
        throw 'Unhandled direction: $d.';
    }
  } else if (builderOnly()) {
    if (commandContext.mapSectionResizer != null) {
      resizeMapSection(d);
    } else if (commandContext.mapSectionMover != null) {
      moveMapSection(d);
    } else {
      instantMove(d);
    }
  }
}

void leftArrow() => doArrowKey(Directions.west);

void rightArrow() => doArrowKey(Directions.east);

void upArrow() => doArrowKey(Directions.north);

void downArrow() => doArrowKey(Directions.south);

void escapeKey() {
  if (validBook()) {
    commandContext.book.cancel();
  } else if (builderOnly()) {
    if (commandContext.mapSectionResizer != null) {
      if (commandContext.mapSectionResizer.coordinates == commandContext.mapSectionResizer.defaultCoordinates) {
        showMessage('Stop dragging ${commandContext.mapSectionResizer.section.name}.');
        commandContext.mapSectionResizer = null;
      } else {
        commandContext.mapSectionResizer.updateCoordinates(commandContext.mapSectionResizer.defaultCoordinates);
        showMessage('Coordinates reset.');
      }
    } else if (commandContext.mapSectionMover!= null) {
      if (commandContext.mapSectionMover.hasMoved) {
        commandContext.mapSectionMover.restoreDefaults();
        commandContext.message('Original location restored.');
      } else {
        commandContext.message('${commandContext.mapSectionMover.startX} -> ${commandContext.mapSectionMover.section.startX}.');
        commandContext.message('Stop moving ${commandContext.mapSectionMover.section.name}.');
        commandContext.mapSectionMover = null;
      }
    }
  }
}

void enterKey() {
  final List<Exit> exits = <Exit>[];
  if (commandContext.map != null) {
    commandContext.map.exits.forEach((int id, Exit e) {
      if (e.x == commandContext.coordinates.x.floor() && e.y == commandContext.coordinates.y.floor()) {
        exits.add(e);
      }
    });
  }
  if (validBook()) {
    commandContext.book.activate();
  } else if (commandContext.map != null && commandContext.getCurrentSection()?.actions?.isNotEmpty == true) {
    final MapSection s = commandContext.getCurrentSection();
    if (s.actions.length == 1) {
      commandContext.send('action', <dynamic>[s.id, s.actions[0]]);
    } else {
      commandContext.book = Book(bookOptions);
      final List<Line> lines = <Line>[];
      for (final String name in s.actions) {
        lines.add(
          Line(
            commandContext.book, () {
              commandContext.send('action', <dynamic>[s.id, name]);
              clearBook();
            }, titleString: commandContext.actions[name]
          )
        );
      }
      commandContext.book.push(Page(lines: lines, titleString: 'Actions', onCancel: clearBook));
    }
  } else if (exits.isNotEmpty) {
    if (exits.length == 1) {
      exits[0].use(commandContext);
    } else {
      commandContext.book = Book(bookOptions)
        ..push(selectExitPage(commandContext.book, exits, (Exit e) {
          clearBook();
          e.use(commandContext);
        }, onCancel: clearBook));
    }
  } else if (builderOnly()) {
    if (commandContext.mapSectionResizer != null || commandContext.mapSectionMover != null) {
      commandContext.book = Book(bookOptions)
        ..push(mapSectionPage(commandContext.book, commandContext.mapSectionResizer == null? commandContext.mapSectionMover.section : commandContext.mapSectionResizer.section, commandContext, onUpload: () {
          commandContext.section = null;
          clearBook();
        }, onCancel: () {
          showMessage('Cancelled.');
          clearBook();
        }));
      commandContext.mapSectionResizer = null;
      commandContext.mapSectionMover = null;
    } else if (commandContext.exit != null) {
      commandContext.exit
        ..destinationId = commandContext.map.id
        ..destinationX = commandContext.coordinates.x.floor()..destinationY = commandContext.coordinates.y.floor()
        ..destinationY = commandContext.coordinates.y.floor()..destinationY = commandContext.coordinates.y.floor();
      if (commandContext.exit.id == null) {
        commandContext.send('addExit', <Map<String, dynamic>>[commandContext.exit.toJson()]);
      } else {
        commandContext.exit.update();
      }
      commandContext.exit = null;
    }
  }
}

void showActions() {
  final MapSection s = commandContext.getCurrentSection();
  if (s == null) {
    showMessage('No current section.');
  } else if (s.actions.isEmpty) {
    showMessage('There is nothing special here.');
  } else {
    final List<String> actions = <String>[];
    for (final String action in s.actions) {
      actions.add(commandContext.actions[action]);
    }
    showMessage('Actions: ${englishList(actions)}.');
  }
}
