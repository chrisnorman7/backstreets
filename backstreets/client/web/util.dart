/// Provides utility methods.
library util;

import 'dart:math';
import 'dart:web_audio';

import 'package:game_utils/game_utils.dart' show randomElement;

import 'directions.dart';

import 'game/map_section.dart';

import 'main.dart';

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
  final MapSection s = commandContext.getCurrentSection();
  if (s == null) {
    return showMessage('There is nothing here for you to walk on.');
  }
  final double amount = s.tileSize * multiplier;
  double x = commandContext.coordinates.x;
  double y = commandContext.coordinates.y;
  x += amount * cos((commandContext.theta * pi) / 180);
  y += amount * sin((commandContext.theta * pi) / 180);
  moveCharacter(x, y);
}

/// An enumeration, for use with the [moveCharacter] function.
enum MoveModes {
  /// Move normally, respecting walls, and informing the server when done.
  normal,
  
  /// Move like a staff member, ignoring walls, and not informing the server when done.
  staff,
  
  /// Move silently, with no footstep sounds, and do not inform the server when done.
  silent,
}

/// Move the character to the provided coordinates.
///
/// The command operates differently, depending on the value of the [mode] argument.
void moveCharacter(double x, double y, {MoveModes mode = MoveModes.normal}) {
  final Point<int> tileCoordinates = Point<int>(x.floor(), y.floor());
  final MapSection oldSection = commandContext.getCurrentSection();
  final MapSection newSection = commandContext.getCurrentSection(tileCoordinates);
  if (mode != MoveModes.staff && newSection == null) {
    playSoundAtCoordinates('sounds/wall/wall.wav');
    return commandContext.message('You cannot go that way.');
  }
  final Point<double> coordinates = Point<double>(x, y);
  if (mode != MoveModes.silent && newSection?.name != oldSection?.name) {
    String action, name;
    if (oldSection == null || (newSection != null && newSection.area < oldSection.area)) {
      action = 'Entering';
      name = newSection?.name ?? 'Nowhere';
    } else {
      action = 'Leaving';
      name = oldSection?.name ?? 'Nowhere';
    }
    commandContext.message('$action $name.');
  }
  commandContext.coordinates = coordinates;
  commandContext.sounds.audioContext.listener
    ..positionX.value = x
    ..positionY.value = y;
  if (mode != MoveModes.silent) {
    String tileName = commandContext.map.tiles[tileCoordinates];
    tileName ??= newSection?.tileName;
    if (tileName != null) {
      final String url = getFootstepSound(tileName);
      playSoundAtCoordinates(url);
    }
  }
  if (mode != MoveModes.silent) {
    commandContext.send('characterCoordinates', <double>[x, y]);
  }
}

void clearBook() {
  commandContext.book = null;
  keyboardArea.focus();
}

void resetFocus() {
  keyboardArea.focus();
  if (commandContext != null && commandContext.book != null) {
    commandContext.book.showFocus();
  }
}

/// Used to drag [MapSection] coordinates.
void resizeMapSection(Directions d) {
  final DirectionAdjustments da = DirectionAdjustments(d);
  Point<int> coordinates = commandContext.mapSectionResizer.coordinates;
  coordinates = Point<int>(coordinates.x + da.x, coordinates.y + da.y);
  commandContext.mapSectionResizer.updateCoordinates(coordinates);
  showMessage('${commandContext.mapSectionResizer.section.textSize}: ${commandContext.mapSectionResizer.coordinates.x}, ${commandContext.mapSectionResizer.coordinates.y}.');
}

/// Instantly move the character.
void instantMove(Directions d) {
  final DirectionAdjustments da = DirectionAdjustments(d);
  Point<double> coordinates = commandContext.coordinates;
  coordinates = Point<double>(coordinates.x + da.x, coordinates.y + da.y);
  moveCharacter(coordinates.x, coordinates.y, mode: MoveModes.staff);
}

/// Play a sound at a specific set of coordinates.
void playSoundAtCoordinates(String url, {Point<double> coordinates, double volume = 1.0}) {
  coordinates ??= commandContext.coordinates;
  AudioNode output = commandContext.sounds.soundOutput;
  if (coordinates != commandContext.coordinates) {
    final PannerNode panner = commandContext.sounds.audioContext.createPanner()
      ..positionX.value = coordinates.x
      ..positionY.value = coordinates.y
      ..panningModel = 'HRTF'
      ..connectNode(output);
    output = panner;
  }
  final GainNode gain = commandContext.sounds.audioContext.createGain()
    ..gain.value = volume
    ..connectNode(output);
  ConvolverNode convolver;
  final MapSection s = commandContext.getCurrentSection(Point<int>(coordinates.x.floor(), coordinates.y.floor()));
  if (s.convolver.convolver == null) {
    if (commandContext.map.convolver.convolver != null) {
      convolver = commandContext.map.convolver.convolver;
    }
  } else {
    convolver = s.convolver.convolver;
  }
  if (convolver != null) {
    gain.connectNode(convolver);
  }
  commandContext.sounds.playSound(url, output: gain);
}
