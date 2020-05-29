/// Provides general hotkeys.
library general;

import 'package:game_utils/game_utils.dart';

import '../directions.dart';
import '../main.dart';

import '../menus/map_section_page.dart';

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
      case Directions.left:
        commandContext.book.cancel();
        break;
      case Directions.right:
        commandContext.book.activate();
        break;
      case Directions.up:
        commandContext.book.moveUp();
        break;
      case Directions.down:
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

void leftArrow() => doArrowKey(Directions.left);

void rightArrow() => doArrowKey(Directions.right);

void upArrow() => doArrowKey(Directions.up);

void downArrow() => doArrowKey(Directions.down);

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
  if (validBook()) {
    commandContext.book.activate();
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
    }
  }
}
