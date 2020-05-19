/// Provides movement hotkeys.
library hotkeys;

import 'dart:math';

import '../keyboard/hotkey.dart';

import '../main.dart';
import '../util.dart';

/// Only fire hotkeys when the map has been loaded.
bool validMap() => commandContext != null && commandContext.mapName != null;

final Hotkey coordinates = Hotkey('c', () => commandContext.message('${commandContext.coordinates.x.toStringAsFixed(0)}, ${commandContext.coordinates.y.toStringAsFixed(0)}.'), runWhen: validMap);

final Hotkey mapName = Hotkey('v', () => commandContext.message(commandContext.mapName), runWhen: validMap);

final Hotkey facing = Hotkey('f', () => commandContext.message(headingToString(commandContext.theta)), runWhen: validMap);

final Hotkey forward = Hotkey('w', () {
  final int now = timestamp();
  if (commandContext.lastMoved == null || (now - commandContext.lastMoved) >= commandContext.speed) {
    commandContext.lastMoved = now;
    double x = commandContext.coordinates.x;
    double y = commandContext.coordinates.y;
    x += 0.1 * cos((commandContext.theta * pi) / 180);
    y += 0.1 * sin((commandContext.theta * pi) / 180);
    commandContext.coordinates = Point<double>(x, y);
    final String tileName = commandContext.tiles[Point<int>(x.toInt(), y.toInt())];
    final String url = randomElement(commandContext.footstepSounds[tileName]);
    commandContext.sounds.playSound(url);
  }
}, interval: 50, runWhen: validMap);

final Hotkey left = Hotkey('a', () => turn(-1), interval: 500, runWhen: validMap);

final Hotkey leftSnap = Hotkey('a', () => snap(SnapDirections.left), shift: true, runWhen: validMap);

final Hotkey right = Hotkey('d', () => turn(1), interval: 500, runWhen: validMap);

final Hotkey rightSnap = Hotkey('d', () => snap(SnapDirections.right), shift: true, runWhen: validMap);
