/// Provides general hotkeys.
library general;

import '../commands/command_context.dart';

import '../main.dart';

import '../menus/book.dart';
import '../menus/line.dart';
import '../menus/page.dart';

void previousMessage(CommandContext ctx) {
  String message;
  ctx.messageIndex ??= ctx.messages.length - 1;
  ctx.messageIndex--;
  if (ctx.messageIndex < 0) {
    ctx.messageIndex = 0;
  }
  if (ctx.messageIndex == null) {
    message = ctx.messages.last;
  } else {
    message = ctx.messages[ctx.messageIndex];
  }
  showMessage(message);
}

void nextMessage(CommandContext ctx) {
  String message;
  if (ctx.messageIndex != null) {
    ctx.messageIndex++;
    if (ctx.messageIndex == ctx.messages.length) {
      ctx.messageIndex = null;
    }
  }
  if (ctx.messageIndex == null) {
    message = ctx.messages.last;
  } else {
    message = ctx.messages[ctx.messageIndex];
  }
  showMessage(message);
}

void messages(CommandContext ctx) {
  bool removeBook;
  void Function() onCancel;
  if (ctx.book == null) {
    removeBook = true;
    onCancel = clearBook;
    ctx.book = Book(ctx.sounds, showMessage);
  } else {
    removeBook = false;
    onCancel = () => ctx.book.showFocus();
  }
  final List<Line> lines = <Line>[];
  for (final String message in ctx.messages.reversed) {
    lines.add(
      Line(
        ctx.book, () {
          if (removeBook) {
            ctx.book = null;
          } else {
            ctx.book.pop();
          }
        }, titleString: message
      )
    );
  }
  ctx.book.push(Page(titleString: 'Messages', lines: lines, onCancel: onCancel));
}

void hotkeys(CommandContext ctx) {
  ctx.book = Book(ctx.sounds, showMessage);
  ctx.book.push(Page.hotkeysPage(keyboard, ctx.book));
}
