/// Provides menu-related hotkeys.
library menu;

import '../keyboard/hotkey.dart';
import '../keyboard/key_state.dart';
import '../main.dart';

final Hotkey moveUp = Hotkey('ArrowUp', (KeyState ks) {
  if (book != null) {
    book.moveUp();
  }
});

final Hotkey moveDown = Hotkey('ArrowDown', (KeyState ks) {
  if (book != null) {
    book.moveDown();
  }
});

void activate(KeyState ks) {
  if (book != null) {
    book.activate();
  }
}

final Hotkey activateSpace = Hotkey(' ', activate);
final Hotkey activateEnter = Hotkey('Enter', activate);
final Hotkey activateRightArrow = Hotkey('ArrowRight', activate);

void cancel(KeyState ks) {
  if (book != null) {
    book.cancel();
  }
}

final Hotkey cancelEscape = Hotkey('Escape', cancel);
final Hotkey cancelLeftArrow = Hotkey('ArrowLeft', cancel);
