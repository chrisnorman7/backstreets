/// Provides utility methods.
library util;

import 'dart:async';
import 'dart:math';
import 'dart:web_audio';

import 'package:game_utils/game_utils.dart' show randomElement;

import 'directions.dart';

import 'game/map_section.dart';
import 'game/wall.dart';

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
  commandContext.theta = normaliseTheta(commandContext.theta + amount);
  commandContext.sendTheta();
}

/// Ensure that [t] is in the range 0-359.
///
/// For example:
///
/// * You are facing 0 degrees.
/// * You turn 1 degree to the left, so your theta is now -1.
/// * This function would return 359 instead.
double normaliseTheta(double t) {
  if (t< 0) {
    return t + 360;
  } else if (t >= 360) {
    return t - 360;
  }
  return t;
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

Point<double> coordinatesInDirection(Point<double> start, double direction, {double distance = 1.0}) {
  final double x = start.x + (distance * cos((direction * pi) / 180));
  final double y = start.y + (distance * sin((direction * pi) / 180));
  return Point<double>(x, y);
}

void move(double multiplier) {
  final MapSection s = commandContext.getCurrentSection();
  if (s == null) {
    return showMessage('There is nothing here for you to walk on.');
  }
  final Point<double> coordinates = coordinatesInDirection(commandContext.coordinates, commandContext.theta, distance: s.tileSize * multiplier);
  moveCharacter(coordinates);
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
/// The function operates differently, depending on the value of the [mode] argument.
void moveCharacter(Point<double> coordinates, {MoveModes mode = MoveModes.normal}) {
  final Point<int> tileCoordinates = Point<int>(coordinates.x.floor(), coordinates.y.floor());
  final MapSection oldSection = commandContext.getCurrentSection();
  final MapSection newSection = commandContext.getCurrentSection(tileCoordinates);
  final Wall wall = commandContext.map.walls[tileCoordinates];
  if (newSection == null || wall != null) {
    const String wallSoundsDirectory = 'sounds/wall';
    String url = '$wallSoundsDirectory/cantgo.wav';
    if (wall != null) {
      if (wall.sound != null) {
        url = wall.sound;
      } else {
        final String s = wall.type.toString();
        url = '$wallSoundsDirectory/${s.substring(s.indexOf('.') + 1)}.wav';
      }
    }
    playSoundAtCoordinates(url);
    if (mode == MoveModes.normal) {
      return commandContext.message('You cannot go that way.');
    }
  }
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
    ..positionX.value = coordinates.x
    ..positionY.value = coordinates.y;
  if (mode != MoveModes.silent) {
    String tileName = commandContext.map.tiles[tileCoordinates];
    tileName ??= newSection?.tileName;
    if (tileName != null) {
      final String url = getFootstepSound(tileName);
      playSoundAtCoordinates(url);
    }
  }
  if (mode != MoveModes.silent) {
    commandContext.send('characterCoordinates', <double>[coordinates.x, coordinates.y]);
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
  moveCharacter(coordinates, mode: MoveModes.staff);
}

/// Play a sound at a specific set of coordinates.
void playSoundAtCoordinates(String url, {Point<double> coordinates, double volume = 1.0, bool dry = false}) {
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
  if (!dry) {
    ConvolverNode convolver;
    final MapSection s = commandContext.getCurrentSection(Point<int>(coordinates.x.floor(), coordinates.y.floor()));
    if (s?.convolver?.convolver == null) {
      if (commandContext.map.convolver.convolver != null) {
        convolver = commandContext.map.convolver.convolver;
      }
    } else {
      convolver = s.convolver.convolver;
    }
    if (convolver != null) {
      gain.connectNode(convolver);
    }
  }
  commandContext.sounds.playSound(url, output: gain);
}

/// Ping the objects nearby.
void echoLocate([String url]) {
  url ??= commandContext.echoSounds[commandContext.options.echoSound];
  final Point<int> startCoordinates = Point<int>(commandContext.coordinates.x.floor(), commandContext.coordinates.y.floor());
  commandContext.map.walls.forEach((Point<int> coordinates, Wall w) {
    final double distance = startCoordinates.distanceTo(coordinates);
    if (distance <= commandContext.options.echoLocationDistance) {
      Timer(Duration(milliseconds: (distance * commandContext.options.echoLocationDistanceMultiplier).round()), () => playSoundAtCoordinates(url, coordinates: Point<double>(coordinates.x.toDouble(), coordinates.y.toDouble()), dry: true));
    }
  });
}
