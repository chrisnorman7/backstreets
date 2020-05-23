/// Provides menu-related hotkeys.
library menu;

import '../main.dart';

void moveUp() => commandContext.book.moveUp();

void moveDown() => commandContext.book.moveDown();

void activateSpace() => commandContext.book.activate();

void activateEnter() => commandContext.book.activate();

void activateRightArrow() => commandContext.book.activate();

void cancelEscape() => commandContext.book.cancel();

void cancelLeftArrow() => commandContext.book.cancel();
