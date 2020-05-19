/// Provides the KeyState class.
library key_state;

import 'package:meta/meta.dart';

/// A key with modifiers.
@immutable
class KeyState {
  /// Create a instance.
  ///
  /// ```
  /// final KeyState printKey = KeyState('p', control: true);
  /// final KeyState escapeKey = KeyState('escape');
  /// ```
  const KeyState(
    this.key,
    {
      this.shift = false,
      this.control = false,
      this.alt = false
    }
  );

  /// A non-modifier key.
  final String key;

  /// Modifier keys.
  final bool shift, control, alt;

  @override
  int get hashCode {
    return toString().hashCode;
  }

  @override
  bool operator == (dynamic other) {
    if (other is KeyState) {
      return other.hashCode == hashCode;
    }
    return false;
  }

  /// Returns a human-readable string, like "ctrl+p", or "f12".
  @override
  String toString() {
    final List<String> keys = <String>[];
    if (control) {
      keys.add('ctrl');
    }
    if (alt) {
      keys.add('alt');
    }
    if (shift) {
      keys.add('shift');
    }
    const Map<String, String> hotkeyConvertions = <String, String>{
      ' ': 'Space',
    };
    String keyString = key;
    if (hotkeyConvertions.containsKey(keyString)) {
      keyString = hotkeyConvertions[keyString];
    }
    keys.add(keyString);
    return keys.join('+');
  }
}
