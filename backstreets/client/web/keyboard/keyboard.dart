/// Provides the Keyboard class.
library keyboard;

import 'dart:html';

import 'hotkey.dart';
import 'key_state.dart';

/// A class for triggering [Hotkey] instances.
class Keyboard {
  /// Create the keyboard, adding a callback for when hotkeys throw an error.
  ///
  ///
  /// final Keyboard kb = Keyboard((dynamic e) => print(e));
  /// ```
  ///
  /// If you want to handle unhandled keys yourself, provide a [unhandledKey] argument.
  Keyboard(this.onError, {this.unhandledKey});

  /// The function which is called when [Hotkey] instances throw an error.
  void Function(dynamic, StackTrace) onError;

  /// The function to call when a key is pressed that is not handled by any of the hotkeys added with [addHotkey].
  void Function(KeyState) unhandledKey;

  /// The keys which are currently held down.
  List<KeyState> heldKeys = <KeyState>[];

  /// The hotkeys registered to this instance.
  List<Hotkey> hotkeys = <Hotkey>[];

  /// The one-time [Hotkey] instances which have already been handled. This list will be cleared as the keys for those hotkeys are released.
  List<Hotkey> handledHotkeys = <Hotkey>[];

  /// Returns [true] if [key] is held down.
  ///
  /// ```
  /// if (keyboard.keyHeld(' ')) {
  ///   // Fire weapon.
  /// }
  /// ```
  bool keyHeld(String key) {
    return heldKeys.where((KeyState state) => state.key == key).isNotEmpty;
  }

  /// Register a key as pressed.
  ///
  /// Returns the key that was pressed, converted to a [KeyState] instance.
  ///
  /// ```
  /// element.onKeyDown.listen((KeyboardEvent e) => keyboard.press(
  ///   e.key, control: e.ctrlKey, shift: e.shiftKey, alt: e.altKey
  /// ));
  /// ```
  KeyState press(
    String key, {
      bool shift = false,
      bool control = false,
      bool alt = false
    }
  ) {
    final KeyState state = KeyState(key, shift: shift, control: control, alt: alt);
    if (!keyHeld(state.key)) {
      heldKeys.add(state);
      bool handled = false;
      for (final Hotkey hk in hotkeys) {
        if (hk.state == state && (hk.runWhen == null || hk.runWhen())) {
          handled = true;
          if (hk.interval == null) {
            hk.run();
          } else {
            hk.startTimer();
          }
        }
      }
      if (!handled && unhandledKey != null) {
        unhandledKey(state);
      }
    }
    return state;
  }

  /// Release a key.
  ///
  /// ```
  /// element.onKeyUp.listen((KeyboardEvent e) => keyboard.release(e.key);
  /// ```
  void release(String key) {
    heldKeys.removeWhere((KeyState state) => state.key == key);
    for (final Hotkey hk in hotkeys) {
      if (hk.state.key == key && hk.timer != null) {
        hk.stopTimer();
      }
    }
  }

  /// Release all held keys.
  void releaseAll() {
    for (final KeyState state in heldKeys) {
      release(state.key);
    }
  }

  /// Add a [Hotkey] instance to this keyboard.
  ///
  /// ```
  /// final Hotkey hk = Hotkey(
  ///   't', () => print('Test.'),
  ///   titleString: 'Test hotkeys'
  /// );
  /// keyboard.addHotkey(hk);
  /// ```
  void addHotkey(Hotkey hk) {
    hotkeys.add(hk);
    querySelector('#hotkeys').append(ParagraphElement()
        ..innerText = '${hk.state}: ${hk.getTitle()}');
  }

  /// Remove a hotkey.
  ///
  /// ```
  /// keyboard.remove(noLongerNeededHotkey);
  /// ```
  void removeHotkey(Hotkey hk) {
    hotkeys.remove(hk);
  }

  /// Add multiple hotkeys.
  /// ```
  /// final List<Hotkey> hotkeys = <Hotkey>[...];
  /// keyboard.addHotkeys(hotkeys);
  /// ```
  void addHotkeys(List<Hotkey> hotkeys) {
    hotkeys.forEach(addHotkey);
  }
}
