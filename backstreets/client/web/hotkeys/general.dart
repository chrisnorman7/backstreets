/// Provides general hotkeys.
library general;

import '../main.dart';

import '../menus/book.dart';
import '../menus/line.dart';
import '../menus/page.dart';

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

void messages() {
  bool removeBook;
  void Function() onCancel;
  if (commandContext.book == null) {
    removeBook = true;
    onCancel = clearBook;
    commandContext.book = Book(commandContext.sounds, showMessage);
  } else {
    removeBook = false;
    onCancel = () => commandContext.book.showFocus();
  }
  final List<Line> lines = <Line>[];
  for (final String message in commandContext.messages.reversed) {
    lines.add(
      Line(
        commandContext.book, () {
          if (removeBook) {
            commandContext.book = null;
          } else {
            commandContext.book.pop();
          }
        }, titleString: message
      )
    );
  }
  commandContext.book.push(Page(titleString: 'Messages', lines: lines, onCancel: onCancel));
}

void hotkeys() {
  commandContext.book = Book(commandContext.sounds, showMessage);
  commandContext.book.push(Page.hotkeysPage(keyboard, commandContext.book));
}
