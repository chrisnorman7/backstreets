import 'key_state.dart';

class Hotkey {
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

  KeyState state;
  String titleString;
  String Function() titleFunc;
  final void Function(KeyState) func;
  final bool oneTime;

  String getTitle() {
    if (titleString == null) {
      return titleFunc();
    }
    return titleString;
  }
}
