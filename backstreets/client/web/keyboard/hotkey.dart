/// Provides the [Hotkey] class.
library hotkey;

import 'key_state.dart';
import 'keyboard.dart';

/// A hotkey.
///
/// Used by [Keyboard.addHotkey].
class Hotkey {
  /// Create a hotkey.
  ///
  /// ```dart
  /// final Hotkey hk = Hotkey(
  ///   't', (KeyState ks) => print('Test.'),
  ///   titleString: 'Test hotkeys'
  /// );
  /// ```
  Hotkey(
    String key,
    this.func,
    {
      this.titleString,
      this.titleFunc,
      bool shift = false,
      bool control = false,
      bool alt = false,
      this.oneTime = true
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
  final void Function(KeyState) func;

  ///
  /// If [true], then this key will only fire once, no matter how long the key is held down. It will fire again once the key is released, and pressed again.
  final bool oneTime;

  /// Returns a [String] representing the title of this hotkey. If [titleString] was not provided, then [titleFunc]() will be returned instead.
  String getTitle() {
    if (titleString == null) {
      return titleFunc();
    }
    return titleString;
  }
}
