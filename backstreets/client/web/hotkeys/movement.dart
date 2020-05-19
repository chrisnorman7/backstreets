/// Provides movement hotkeys.
library hotkeys;

import 'dart:math';

import '../keyboard/hotkey.dart';

import '../main.dart';
import '../map_section.dart';
import '../util.dart';

/// Only fire hotkeys when the map has been loaded.
bool validMap() => commandContext != null && commandContext.mapName != null;

final Hotkey coordinates = Hotkey(
  'c', () => commandContext.message('${commandContext.coordinates.x.toStringAsFixed(0)}, ${commandContext.coordinates.y.toStringAsFixed(0)}.'),
  runWhen: validMap, titleString: 'Show coordinates'
);

final Hotkey mapName = Hotkey('v', () => commandContext.message(commandContext.mapName), runWhen: validMap, titleString: 'View your current location');

final Hotkey facing = Hotkey('f', () => commandContext.message(headingToString(commandContext.theta)), runWhen: validMap, titleString: 'Show which way you are facing');

final Hotkey forward = Hotkey('w', () {
  double x = commandContext.coordinates.x;
  double y = commandContext.coordinates.y;
  x += 0.1 * cos((commandContext.theta * pi) / 180);
  y += 0.1 * sin((commandContext.theta * pi) / 180);
  final Point<int> tileCoordinates = Point<int>(x.toInt(), y.toInt());
  String tileName = commandContext.tiles[tileCoordinates];
  if (tileName == null) {
    for (final MapSection s in commandContext.sections) {
      if (s.rect.containsPoint(tileCoordinates)) {
        tileName = s.tileName;
        break;
      }
    }
  }
  if (tileName == null) {
    commandContext.message('You cannot go that way.');
    return null;
  }
  final String url = randomElement(commandContext.footstepSounds[tileName]);
  commandContext.sounds.playSound(url);
  commandContext.coordinates = Point<double>(x, y);
}, interval: 50, runWhen: validMap, titleString: 'Move forward');

final Hotkey left = Hotkey('a', () => turn(-1), interval: 500, runWhen: validMap, titleString: 'Turn left a bit');

final Hotkey leftSnap = Hotkey('a', () => snap(SnapDirections.left), shift: true, runWhen: validMap, titleString: 'Snap left to the nearest cardinal direction');

final Hotkey right = Hotkey('d', () => turn(1), interval: 500, runWhen: validMap, titleString: 'Turn right a bit');

final Hotkey rightSnap = Hotkey('d', () => snap(SnapDirections.right), shift: true, runWhen: validMap, titleString: 'Snap right to the nearest cardinal direction');
