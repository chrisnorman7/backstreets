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
  ///   't', (KeyState ks) => print('Test.'),
  ///   titleString: 'Test hotkeys'
  /// );
  /// ```
  ///
  /// If [interval] is not null, then start a timer which will run every [interval] milliseconds to call [func].
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
      int interval,
      this.runWhen
    }
  ) {
    state = KeyState(key, shift: shift, alt: alt, control: control);
    setInterval(interval);
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
  int _interval;

  /// A function which determines whether [func] should be called.
  bool Function() runWhen;

  /// The timer that will call [func].
  Timer timer;

  /// Set [_interval].
  ///
  /// If [value] is null, call [stopTimer].
  ///
  /// If [value] is not null, call [startTimer].
  void setInterval(int value) {
    _interval = value;
    if (value == null) {
      if (timer != null) {
        stopTimer();
      }
    } else {
      startTimer();
    }
  }

  void startTimer() {
    if (timer != null) {
      stopTimer();
    }
    timer = Timer.periodic(Duration(milliseconds: _interval), (Timer t) => run());
  }

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

  /// Returns [true] if [_interval] is true.
  bool get isOneTime => _interval == null;

  /// Returns a [String] representing the title of this hotkey. If [titleString] was not provided, then [titleFunc]() will be returned instead.
  String getTitle() {
    if (titleString == null) {
      return titleFunc();
    }
    return titleString;
  }
}
