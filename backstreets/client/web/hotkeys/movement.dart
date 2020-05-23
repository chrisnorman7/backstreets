/// Provides movement hotkeys.
library hotkeys;

import '../keyboard/hotkey.dart';

import '../main.dart';
import '../map_section.dart';
import '../util.dart';

import 'run_conditions.dart';

final Hotkey coordinates = Hotkey(
  'c', () => showMessage('${commandContext.coordinates.x.floor()}, ${commandContext.coordinates.y.floor()}.'),
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

final Hotkey facing = Hotkey('f', () => showMessage(headingToString(commandContext.theta)), runWhen: validMap, titleString: 'Show which way you are facing');

final Hotkey walkForwards = Hotkey('w', () => move(1), interval: 50, runWhen: validMap, titleString: 'Move forward');

final Hotkey walkBackwards = Hotkey('s', () => move(-0.5), shift: true, interval: 50, runWhen: validMap);

final Hotkey left = Hotkey('a', () => turn(-1), interval: 500, runWhen: validMap, titleString: 'Turn left a bit');

final Hotkey leftSnap = Hotkey('a', () => snap(SnapDirections.left), shift: true, runWhen: validMap, titleString: 'Snap left to the nearest cardinal direction');

final Hotkey right = Hotkey('d', () => turn(1), interval: 500, runWhen: validMap, titleString: 'Turn right a bit');

final Hotkey rightSnap = Hotkey('d', () => snap(SnapDirections.right), shift: true, runWhen: validMap, titleString: 'Snap right to the nearest cardinal direction');

final Hotkey aboutFace = Hotkey('s', () {
  /// Turn a full 180, then 45 more, s that snap can announce the new heading.
  commandContext.theta += 180 + 45;
  if (commandContext.theta > 360) {
    commandContext.theta -= 360;
  }
  snap(SnapDirections.left);
}, runWhen: validMap);
