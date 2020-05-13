/// Provides the Keyboard class.
library keyboard;

import 'dart:async';

import 'hotkey.dart';
import 'key_state.dart';

/// A class for triggering [Hotkey] instances.
class Keyboard {
  /// Create the keyboard, setting the interval between keypressed.
  ///
  /// ```dart
  /// final Keyboard kb = Keyboard();
  /// ```
  Keyboard({this.keyPressInterval = 50});

  /// The length of time between [Hotkey]s firing.
  int keyPressInterval;

  /// The keys which are currently held down.
  List<KeyState> heldKeys = <KeyState>[];

  /// The hotkeys registered to this instance.
  List<Hotkey> hotkeys = <Hotkey>[];

  /// The one-time [Hotkey] instances which have already been handled. This list will be cleared as the keys for those hotkeys are released.
  List<Hotkey> handledHotkeys = <Hotkey>[];

  /// The timer which will fire every [keyPressInterval] milliseconds.
  Timer keyTimer;

  /// Returns [true] if [key] is held down.
  ///
  /// ```dart
  /// if (keyboard.keyHeld(' ')) {
  ///   // Fire weapon.
  /// }
  /// ```
  bool keyHeld(String key) {
    return heldKeys.where((KeyState state) => state.key == key).isNotEmpty;
  }

  /// Start [keyTimer].
  void startKeyTimer() {
    keyTimer = Timer.periodic(
      Duration(milliseconds: keyPressInterval),
      handleKeys
    );
  }

  /// Stop [keyTimer].
  void stopKeyTimer() {
    keyTimer.cancel();
    keyTimer = null;
  }

  /// Run through [heldKeys], and figure out if there are associated [Hotkey] instances in the [hotkeys] list.
  void handleKeys(Timer t) {
    for (final KeyState key in heldKeys) {
      for (final Hotkey hotkey in hotkeys) {
        if (hotkey.state == key) {
          if (hotkey.oneTime) {
            if (handledHotkeys.contains(hotkey)) {
              continue;
            } else {
              handledHotkeys.add(hotkey);
            }
          }
          hotkey.func(key);
        }
      }
    }
  }

  /// Register a key as pressed.
  ///
  /// ```dart
  /// element.onKeyDown.listen((KeyboardEvent e) => keyboard.press(
  ///   e.key, control: e.ctrlKey, shift: e.shiftKey, alt: e.altKey
  /// ));
  /// ```
  void press(
    String key, {
      bool shift = false,
      bool control = false,
      bool alt = false
    }) {
    final KeyState state = KeyState(key, shift: shift, control: control, alt: alt);
    if (!keyHeld(state.key)) {
      heldKeys.add(state);
    }
    if (keyTimer == null) {
      startKeyTimer();
    }
  }

  /// Release a key.
  ///
  /// ```dart
  /// element.onKeyUp.listen((KeyboardEvent e) => keyboard.release(e.key);
  /// ```
  void release(String key) {
    heldKeys.removeWhere((KeyState state) => state.key == key);
    handledHotkeys.removeWhere((Hotkey hotkey) => hotkey.state.key == key);
    if (heldKeys.isEmpty && keyTimer != null) {
      stopKeyTimer();
      }
  }

  /// Add a [Hotkey] instance to this keyboard.
  ///
  /// ```dart
  /// final Hotkey hk = Hotkey(
  ///   't', () => print('Test.'),
  ///   titleString: 'Test hotkeys'
  /// );
  /// keyboard.addHotkey(hk);
  /// ```
  void addHotkey(Hotkey hk) {
    hotkeys.add(hk);
  }

  /// Remove a hotkey.
  ///
  /// ```dart
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
