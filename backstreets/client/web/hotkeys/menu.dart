/// Provides menu-related hotkeys.
library menu;

import '../keyboard/hotkey.dart';

import '../main.dart';

/// Only run a [Hotkey] if we have a valid book.
bool validBook() => book != null;

final Hotkey moveUp = Hotkey('ArrowUp', () {
  book.moveUp();
}, runWhen: validBook, titleString: 'Move up in a menu');

final Hotkey moveDown = Hotkey('ArrowDown', () {
  if (book != null) {
    book.moveDown();
  }
}, runWhen: validBook, titleString: 'Move down in a menu');

final Hotkey activateSpace = Hotkey(' ', () => book.activate(), runWhen: validBook, titleString: 'Activate a menu item');

final Hotkey activateEnter = Hotkey('Enter', () => book.activate(), runWhen: validBook, titleString: 'Activate a menu item');

final Hotkey activateRightArrow = Hotkey('ArrowRight', () => book.activate(), runWhen: validBook, titleString: 'Activate a menu item');

final Hotkey cancelEscape = Hotkey('Escape', () => book.cancel(), runWhen: validBook, titleString: 'Go back to the previous menu');

final Hotkey cancelLeftArrow = Hotkey('ArrowLeft', () => book.cancel(), runWhen: validBook, titleString: 'Go back to the previous menu');
