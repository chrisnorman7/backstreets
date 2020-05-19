/// Provides movement hotkeys.
library hotkeys;

import 'dart:math';

import '../keyboard/hotkey.dart';
import '../keyboard/key_state.dart';

import '../main.dart';
import '../util.dart';

final Hotkey coordinates = Hotkey('c', (KeyState ks) {
  if (commandContext.mapName != null) {
    commandContext.message('${commandContext.coordinates.x.toStringAsFixed(0)}, ${commandContext.coordinates.y.toStringAsFixed(0)}.');
  }
});

final Hotkey mapName = Hotkey('v', (KeyState ks) {
  if (commandContext.mapName != null) {
    commandContext.message(commandContext.mapName);
  }
});

final Hotkey facing = Hotkey('f', (KeyState ks) {
  if (commandContext.mapName == null) {
    // Not connected yet.
    return;
  }
  commandContext.message(headingToString(commandContext.theta));
});

final Hotkey forward = Hotkey('w', (KeyState ks) {
  if (commandContext.mapName == null) {
    // Not loaded yet.
    return;
  }
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
}, oneTime: false);

final Hotkey left = Hotkey('a', (KeyState ks) {
  if (commandContext.mapName == null) {
    // Not connected yet.
    return;
  }
  turn(-1);
}, oneTime: false);

final Hotkey leftSnap = Hotkey('a', (KeyState ks) {
  if (commandContext.mapName == null) {
    // Not connected yet.
    return;
  }
  snap(SnapDirections.left);
}, shift: true);

final Hotkey right = Hotkey('d', (KeyState ks) {
  if (commandContext.mapName == null) {
    // Not connected yet.
    return;
  }
  turn(1);
}, oneTime: false);

final Hotkey rightSnap = Hotkey('d', (KeyState ks) {
  if (commandContext.mapName == null) {
    // Not connected yet.
    return;
  }
  snap(SnapDirections.right);
}, shift: true);
