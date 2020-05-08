import 'package:meta/meta.dart';

@immutable
class KeyState {
  const KeyState(
    this.key,
    {
      this.shift = false,
      this.control = false,
      this.alt = false
    }
  );

  final String key;
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
