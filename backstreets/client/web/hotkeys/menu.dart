/// Provides menu-related hotkeys.
library menu;

import '../keyboard/hotkey.dart';

import '../main.dart';

/// Only run a [Hotkey] if we have a valid book.
bool validBook() => book != null;

final Hotkey moveUp = Hotkey('arrowup', () {
  book.moveUp();
}, runWhen: validBook, titleString: 'Move up in a menu');

final Hotkey moveDown = Hotkey('arrowdown', () {
  if (book != null) {
    book.moveDown();
  }
}, runWhen: validBook, titleString: 'Move down in a menu');

final Hotkey activateSpace = Hotkey(' ', () => book.activate(), runWhen: validBook, titleString: 'Activate a menu item');

final Hotkey activateEnter = Hotkey('enter', () => book.activate(), runWhen: validBook, titleString: 'Activate a menu item');

final Hotkey activateRightArrow = Hotkey('arrowright', () => book.activate(), runWhen: validBook, titleString: 'Activate a menu item');

final Hotkey cancelEscape = Hotkey('escape', () => book.cancel(), runWhen: validBook, titleString: 'Go back to the previous menu');

final Hotkey cancelLeftArrow = Hotkey('arrowleft', () => book.cancel(), runWhen: validBook, titleString: 'Go back to the previous menu');
