import 'dart:async';

import 'hotkey.dart';
import 'key_state.dart';

class Keyboard {
  Keyboard({this.keyPressInterval = 50});

  int keyPressInterval;
  List<KeyState> heldKeys = <KeyState>[];
  List<Hotkey> hotkeys = <Hotkey>[];
  List<Hotkey> handledHotkeys = <Hotkey>[];
  Timer keyTimer;

  bool keyHeld(String key) {
    return heldKeys.where((KeyState state) => state.key == key).isNotEmpty;
  }

  void startKeyTimer() {
    keyTimer = Timer.periodic(
      Duration(milliseconds: keyPressInterval),
      handleKeys
    );
  }

  void stopKeyTimer() {
    keyTimer.cancel();
    keyTimer = null;
  }

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

  void press(KeyState state) {
    if (!keyHeld(state.key)) {
      heldKeys.add(state);
    }
    if (keyTimer == null) {
      startKeyTimer();
    }
  }

  void release(String key) {
    heldKeys.removeWhere((KeyState state) => state.key == key);
    handledHotkeys.removeWhere((Hotkey hotkey) => hotkey.state.key == key);
    if (heldKeys.isEmpty && keyTimer != null) {
      stopKeyTimer();
      }
  }

  void addHotkey(Hotkey hk) {
    hotkeys.add(hk);
  }

  void removeHotkey(Hotkey hk) {
    hotkeys.remove(hk);
  }
}
