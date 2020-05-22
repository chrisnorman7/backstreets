/// Provides general hotkeys.
library general;

import '../keyboard/hotkey.dart';

import '../main.dart';

import '../menus/book.dart';
import '../menus/line.dart';
import '../menus/page.dart';

final Hotkey previousMessage = Hotkey('.', () {
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
});

final Hotkey nextMessage = Hotkey(',', () {
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
});

final Hotkey messages = Hotkey('/', () {
  bool removeBook;
  if (commandContext.book == null) {
    removeBook = true;
    commandContext.book = Book(commandContext.sounds, showMessage, onCancel: clearBook);
  } else {
    removeBook = false;
  }
  final List<Line> lines = <Line>[];
  for (final String message in commandContext.messages.reversed) {
    lines.add(
      Line(
        commandContext.book, (Book b) {
          if (removeBook) {
            commandContext.book = null;
          } else {
            b.pop();
          }
        }, titleString: message
      )
    );
  }
  commandContext.book.push(Page(titleString: 'Messages', lines: lines));
});
