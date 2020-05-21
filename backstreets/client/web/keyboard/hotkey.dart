/// Provides the [Hotkey] class.
library hotkey;

import 'dart:async';

import '../main.dart';

import 'key_state.dart';
import 'keyboard.dart';

/// A hotkey.
///
/// Used by [Keyboard.addHotkey].
class Hotkey {
  /// Create a hotkey.
  ///
  /// ```
  /// final Hotkey hk = Hotkey(
  ///   KeyCode.T', () => print('Test.'),
  ///   titleString: 'Test hotkeys'
  /// );
  /// ```
  ///
  /// The function [func] will fire when the hotkey is pressed. It will be called via [run], so that errors are handled appropriately.
  ///
  /// If [interval] is not null, then [func] will be called every [interval] milliseconds.
  ///
  /// If [runWhen] is not null, only run [func] when [runWhen] returns true.
  Hotkey(
    String key,
    this.func,
    {
      this.titleString,
      this.titleFunc,
      bool shift = false,
      bool control = false,
      bool alt = false,
      this.interval,
      this.runWhen
    }
  ) {
    state = KeyState(key, shift: shift, alt: alt, control: control);
  }

  /// The key which must be pressed in order that this hotkey is fired.
  KeyState state;

  /// The title of this hotkey.
  String titleString;

  /// A function which when called should return the title of this hotkey.
  String Function() titleFunc;

  /// The hotkey callback, to be called with [state] as its only argument.
  final void Function() func;

  /// The interval between firing [func].
  ///
  /// If this value is null, then this key will only fire once when the key is pressed.
  int interval;

  /// A function which determines whether [func] should be called.
  bool Function() runWhen;

  /// The timer that will call [func] via [run].
  Timer timer;
  
  /// The time this hotkey was last run.
  int lastRun;

  /// Start the timer to call [run] every [interval] milliseconds.
  void startTimer() {
    if (timer != null) {
      stopTimer();
    }
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (lastRun == null || (now - lastRun) > interval) {
      lastRun = now;
      run();
    }
    timer = Timer.periodic(Duration(milliseconds: interval), (Timer t) => run());
  }

  /// Stop [timer].
  void stopTimer() {
    timer.cancel();
    timer = null;
  }

  /// Call [func], and handle errors.
  void run() {
    if (!keyboard.heldKeys.contains(state)) {
      return;
    }
    try {
      if (runWhen == null || runWhen()) {
        func();
      }
    }
    catch (e, s) {
      keyboard.onError(e, s);
    }
  }

  /// Returns a [String] representing the title of this hotkey. If [titleString] was not provided, then [titleFunc]() will be returned instead.
  String getTitle() {
    if (titleString == null) {
      if (titleFunc != null) {
        return titleFunc();
      }
    }
    return titleString;
  }
}
