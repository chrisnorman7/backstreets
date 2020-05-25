/// Provides general hotkeys.
library general;

import 'package:game_utils/game_utils.dart';

import '../main.dart';

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
  commandContext.book.push(Page.hotkeysPage(keyboard.hotkeys, commandContext.book));
}
