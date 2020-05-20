/// Provides menu-related hotkeys.
library menu;

import '../keyboard/hotkey.dart';

import '../main.dart';

/// Only run a [Hotkey] if we have a valid book.
bool validBook() => commandContext.book != null;

final Hotkey moveUp = Hotkey('arrowup', () => commandContext.book.moveUp(), runWhen: validBook, titleString: 'Move up in a menu');

final Hotkey moveDown = Hotkey('arrowdown', () => commandContext.book.moveDown(), runWhen: validBook, titleString: 'Move down in a menu');

final Hotkey activateSpace = Hotkey(' ', () => commandContext.book.activate(), runWhen: validBook, titleString: 'Activate a menu item');

final Hotkey activateEnter = Hotkey('enter', () => commandContext.book.activate(), runWhen: validBook, titleString: 'Activate a menu item');

final Hotkey activateRightArrow = Hotkey('arrowright', () => commandContext.book.activate(), runWhen: validBook, titleString: 'Activate a menu item');

final Hotkey cancelEscape = Hotkey('escape', () => commandContext.book.cancel(), runWhen: validBook, titleString: 'Go back to the previous menu');

final Hotkey cancelLeftArrow = Hotkey('arrowleft', () => commandContext.book.cancel(), runWhen: validBook, titleString: 'Go back to the previous menu');
