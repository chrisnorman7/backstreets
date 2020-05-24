/// Provides utility methods.
library util;

import 'dart:math';

import 'package:game_utils/game_utils.dart' show randomElement;

import 'main.dart';
import 'map_section.dart';

final Random random = Random();

/// Convert a theta to a human readable string.
String headingToString(double angle) {
  const List<String> directions = <String>[
    'east',
    'south-east',
    'south',
    'south-west',
    'west',
    'north-west',
    'north',
    'north-east',
  ];
  final int index =
      (((angle %= 360) < 0 ? angle + 360 : angle) ~/ 45 % 8).round();
  return directions[index];
}

/// Turn the player by [amount]..
void turn(double amount) {
  commandContext.theta += amount;
  if (commandContext.theta < 0) {
    commandContext.theta += 360;
  } else if (commandContext.theta > 360) {
    commandContext.theta -= 360;
  }
  commandContext.sendTheta();
}

/// Directions to snap in.
enum SnapDirections {
  /// Snap left.
  left,

  // Snap right.
  right,
}

/// Turn to face the nearest cardinal direction in the given direction.
void snap(SnapDirections direction) {
  double mod = commandContext.theta % 45;
  if (direction == SnapDirections.left) {
    if (mod == 0) {
      mod = 45;
    }
    commandContext.theta -= mod;
  } else {
    commandContext.theta += 45 - mod;
  }
  commandContext.sendTheta();
  showMessage(headingToString(commandContext.theta));
}

String getFootstepSound(String tileName) {
  return randomElement(commandContext.footstepSounds[tileName]);
}

void move(double multiplier) {
  final double amount = commandContext.getCurrentSection().tileSize * multiplier;
  double x = commandContext.coordinates.x;
  double y = commandContext.coordinates.y;
  x += amount * cos((commandContext.theta * pi) / 180);
  y += amount * sin((commandContext.theta * pi) / 180);
  final Point<int> tileCoordinates = Point<int>(x.floor(), y.floor());
  final MapSection oldSection = commandContext.getCurrentSection();
  final MapSection newSection = commandContext.getCurrentSection(tileCoordinates);
  if (newSection == null) {
    commandContext.sounds.playSound('sounds/wall/wall.wav');
    return commandContext.message('You cannot go that way.');
  }
  final Point<double> coordinates = Point<double>(x, y);
  if (newSection.name != oldSection.name) {
    String action, name;
    if (oldSection.rect.containsPoint(coordinates)) {
      action = 'Entering';
      name = newSection.name;
    } else {
      action = 'Leaving';
      name = oldSection.name;
    }
    commandContext.message('$action $name.');
  }
  String tileName = commandContext.tiles[tileCoordinates];
  tileName ??= newSection.tileName;
  commandContext.send('characterCoordinates', <double>[x, y]);
  final String url = getFootstepSound(tileName);
  commandContext.sounds.playSound(url);
  commandContext.coordinates = coordinates;
  commandContext.sounds.audioContext.listener.positionX.value = coordinates.x;
  commandContext.sounds.audioContext.listener.positionY.value = coordinates.y;
}

void clearBook() {
  commandContext.book = null;
  keyboardArea.focus();
}

void resetFocus() {
  keyboardArea.focus();
  if (commandContext.book != null) {
    commandContext.book.showFocus();
  }
}
