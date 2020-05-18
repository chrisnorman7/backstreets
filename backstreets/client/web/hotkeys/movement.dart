/// Provides movement hotkeys.
library hotkeys;

import '../keyboard/hotkey.dart';
import '../keyboard/key_state.dart';

import '../main.dart';

final Hotkey coordinates = Hotkey('c', (KeyState ks) {
  if (commandContext.mapName != null) {
    commandContext.message('${commandContext.coordinates.x}, ${commandContext.coordinates.y}.');
  }
});

final Hotkey mapName = Hotkey('m', (KeyState ks) {
  if (commandContext.mapName != null) {
    commandContext.message(commandContext.mapName);
  }
});
