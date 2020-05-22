/// Provides movement hotkeys.
library hotkeys;

import '../keyboard/hotkey.dart';

import '../main.dart';
import '../map_section.dart';
import '../util.dart';

/// Only fire hotkeys when the map has been loaded.
bool validMap() => commandContext != null && commandContext.mapName != null && commandContext.book == null;

final Hotkey coordinates = Hotkey(
  'c', () => commandContext.message('${commandContext.coordinates.x.toStringAsFixed(0)}, ${commandContext.coordinates.y.toStringAsFixed(0)}.'),
  runWhen: validMap, titleString: 'Show coordinates'
);

final Hotkey mapName = Hotkey('v', () {
  String result = commandContext.mapName;
  final MapSection s = commandContext.getCurrentSection();
  if (s != null) {
    result += ': ${s.name}';
  }
  commandContext.message('$result.');
}, runWhen: validMap, titleString: 'View your current location');

final Hotkey facing = Hotkey('f', () => commandContext.message(headingToString(commandContext.theta)), runWhen: validMap, titleString: 'Show which way you are facing');

final Hotkey walkForwards = Hotkey('w', () => move(1), interval: 50, runWhen: validMap, titleString: 'Move forward');

final Hotkey walkBackwards = Hotkey('s', () => move(-1), shift: true, interval: 50, runWhen: validMap);

final Hotkey left = Hotkey('a', () => turn(-1), interval: 500, runWhen: validMap, titleString: 'Turn left a bit');

final Hotkey leftSnap = Hotkey('a', () => snap(SnapDirections.left), shift: true, runWhen: validMap, titleString: 'Snap left to the nearest cardinal direction');

final Hotkey right = Hotkey('d', () => turn(1), interval: 500, runWhen: validMap, titleString: 'Turn right a bit');

final Hotkey rightSnap = Hotkey('d', () => snap(SnapDirections.right), shift: true, runWhen: validMap, titleString: 'Snap right to the nearest cardinal direction');

final Hotkey aboutFace = Hotkey('s', () {
  commandContext.theta += 180 + 45;
  if (commandContext.theta > 360) {
    commandContext.theta -= 360;
  }
  snap(SnapDirections.left);
}, runWhen: validMap);
