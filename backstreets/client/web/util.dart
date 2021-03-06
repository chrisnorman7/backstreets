/// Provides utility methods.
library util;

import 'dart:async';
import 'dart:html';
import 'dart:math';
import 'dart:web_audio';

import 'package:game_utils/game_utils.dart';

import 'constants.dart';
import 'directions.dart';
import 'game/exit.dart';
import 'game/map_section.dart';
import 'game/panned_sound.dart';
import 'game/wall.dart';
import 'main.dart';

final Random random = Random();

/// Convert a theta to a human readable string.
String headingToString(double angle) {
  const List<String> directions = <String>[
    'north',
    'north-east',
    'east',
    'south-east',
    'south',
    'south-west',
    'west',
    'north-west',
  ];
  final int index =
      (((angle %= 360) < 0 ? angle + 360 : angle) ~/ 45 % 8).round();
  return directions[index];
}

/// Returns relative directions.
///
///
/// If the coordinates `(0, 0)`, and `(1, 2)` were given, `"1 north, and 2
RelativeDirections relativeDirections(Point<int> start, Point<int> end) {
  int east = (max(start.x, end.x) - min(start.x, end.x)).toInt();
  int north = (max(start.y, end.y) - min(start.y, end.y)).toInt();
  if (start.x > end.x) {
    east *= -1;
  }
  if (start.y > end.y) {
    north *= -1;
  }
  return RelativeDirections(east, north);
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

/// Return the coordinates in the given direction.
///
/// The distance can be set to allow the function to work in big or small steps.
Point<double> coordinatesInDirection(Point<double> start, double direction, {double distance = 1.0}) {
  final double rads = direction / 180.0 * pi;
  final double x = start.x + (distance * sin(rads));
  final double y = start.y + (distance * cos(rads));
  return Point<double>(x, y);
}

/// Returns a list of walls between [a] and [b].
List<Wall> wallsBetween(Point<double> a, Point<double> b) {
  final List<Wall> walls = <Wall>[];
  final double lowerX = min(a.x, b.x);
  final double lowerY = min(a.y, b.y);
  final double upperX = max(a.x, b.x);
  final double upperY = max(a.y, b.y);
  final Rectangle<double> r = Rectangle<double>.fromPoints(Point<double>(lowerX, lowerY), Point<double>(upperX, upperY));
  commandContext.map?.walls?.forEach((Point<int> coordinates, Wall w) {
    if (r.containsPoint(Point<double>(coordinates.x.toDouble(), coordinates.y.toDouble()))) {
      walls.add(w);
    }
  });
  return walls;
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
  final Point<int> tileCoordinates = getIntCoordinates(coordinates);
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
  if (newSection?.name != oldSection?.name) {
    if (mode != MoveModes.silent) {
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
    if (oldSection != null && !oldSection.rect.containsPoint(tileCoordinates) && oldSection.ambience.sound != null && oldSection.ambience.sound.panner == null) {
      // Let's add a panner, so the sound doesn't come from everywhere.
      oldSection.ambience.sound.panner = oldSection.ambience.sounds.audioContext.createPanner()
        ..positionX.value = oldSection.ambienceCoordinates.x
        ..positionY.value = oldSection.ambienceCoordinates.y
        ..connectNode(oldSection.ambience.sounds.ambienceOutput);
      if (oldSection.ambience.distance != null) {
        oldSection.ambience.sound.panner.refDistance = oldSection.ambience.distance;
      }
      commandContext.map.pannedSounds.add(oldSection.ambience.sound);
      oldSection.ambience.sound.sound.output
        ..disconnect()
        ..connectNode(oldSection.ambience.sound.panner);
    }
    if (newSection != null && newSection.rect.containsPoint(tileCoordinates) && newSection.ambience.sound != null && newSection.ambience.sound.panner != null) {
      // Clear the panner, so the sound appears to be everywhere.
      newSection.ambience.sound.panner.disconnect();
      newSection.ambience.sound.panner = null;
      newSection.ambience.sound.sound.output
        ..disconnect()
        ..connectNode(newSection.ambience.sounds.ambienceOutput);
      commandContext.map.pannedSounds.remove(newSection.ambience.sound);
    }
  }
  commandContext.coordinates = coordinates;
  if (mode != MoveModes.silent) {
    bool found = false;
    for (final Exit e in commandContext.map.exits.values) {
      if (e.x == tileCoordinates.x && e.y == tileCoordinates.y) {
        if (e != commandContext.lastExit) {
          sounds.playSound(exitSoundUrl);
          commandContext.lastExit = e;
        }
        found = true;
        break;
      }
    }
    if (!found) {
      commandContext.lastExit = null;
    }
    final String tileName = newSection?.tileName;
    if (tileName != null) {
      final String url = getFootstepSound(tileName);
      playSoundAtCoordinates(url);
    }
    commandContext.send('characterCoordinates', <double>[coordinates.x, coordinates.y]);
  }
}

void clearBook() {
  commandContext.book = null;
  keyboardArea.focus();
}

/// Clear the book, and show a cancel message.
void doCancel() {
  clearBook();
  showMessage('Cancelled.');
}

void resetFocus() {
  keyboardArea.focus();
  if (commandContext != null && commandContext.book != null) {
    commandContext.book.showFocus();
  }
  keyboard.releaseAll();
}

/// Used to drag [MapSection] coordinates.
void resizeMapSection(Directions d) {
  final DirectionAdjustments da = DirectionAdjustments(d);
  Point<int> coordinates = commandContext.mapSectionResizer.coordinates;
  coordinates = Point<int>(coordinates.x + da.x, coordinates.y + da.y);
  commandContext.mapSectionResizer.updateCoordinates(coordinates);
  showMessage('${relativeDirections(commandContext.mapSectionResizer.defaultCoordinates, commandContext.mapSectionResizer.coordinates)}: ${commandContext.mapSectionResizer.section.textSize}.');
}

/// Moves a map section.
void moveMapSection(Directions d) {
  final DirectionAdjustments da = DirectionAdjustments(d);
  commandContext.mapSectionMover
    ..section.startX += da.x
    ..section.startY += da.y
    ..section.endX += da.x
    ..section.endY += da.y;
  commandContext.message(relativeDirections(commandContext.mapSectionMover.startCoordinates, commandContext.mapSectionMover.section.startCoordinates).toString());
}

/// Instantly move the character.
void instantMove(Directions d) {
  final DirectionAdjustments da = DirectionAdjustments(d);
  Point<double> coordinates = commandContext.coordinates;
  coordinates = Point<double>(coordinates.x + da.x, coordinates.y + da.y);
  moveCharacter(coordinates, mode: MoveModes.staff);
}

/// Get a filter that simulates the affect a wall would have on a sound.
BiquadFilterNode getWallFilter(Point<double> coordinates){
  return commandContext.sounds.audioContext.createBiquadFilter()
    ..type = 'highshelf'
    ..frequency.value = commandContext.options.wallFilterAmount
    ..gain.value = -100;
}

/// Play a sound at a specific set of coordinates.
PannedSound playSoundAtCoordinates(String url, {Point<double> coordinates, double volume = 1.0, bool dry = false, AudioNode output, int size, bool loop = false, bool airborn = false, int id}) {
  output ??= commandContext.sounds.soundOutput;
  final GainNode gain = commandContext.sounds.audioContext.createGain()
    ..gain.value = volume;
  BiquadFilterNode filter;
  PannerNode panner;
  if (coordinates == null) {
    gain.connectNode(output);
  } else {
    panner = commandContext.sounds.audioContext.createPanner()
      ..positionX.value = coordinates.x
      ..positionY.value = coordinates.y
      ..panningModel = 'HRTF'
      ..connectNode(output);
    if (airborn) {
      panner.positionZ.value = commandContext.options.airbornElevate;
    }
    if (size != null) {
      panner.refDistance = size;
    }
    if (!dry && wallsBetween(commandContext.coordinates, coordinates).isNotEmpty) {
      filter = getWallFilter(coordinates)
        ..connectNode(panner);
      gain.connectNode(filter);
    } else {
      gain.connectNode(panner);
    }
  }
  if (!dry) {
    coordinates ??= commandContext.coordinates;
    final ConvolverNode convolver = commandContext.getCurrentConvolver(getIntCoordinates(coordinates));
    if (convolver != null) {
      (filter ?? gain).connectNode(convolver);
    }
  }
  final Sound s = commandContext.sounds.playSound(url, output: gain, loop: loop);
  final PannedSound ps = PannedSound(s, filter, coordinates, panner, id);
  if (panner != null) {
    s.onEnded = (Event e) {
      if (commandContext.map.pannedSounds.contains(ps)) {
        commandContext.map.pannedSounds.remove(ps);
      }
    };
    commandContext.map.pannedSounds.add(ps);
  }
  return ps;
}

/// Ping the objects nearby.
void echoLocate() {
  final String url = commandContext.echoSounds[commandContext.options.echoSound];
  final Point<int> startCoordinates = getIntCoordinates();
  commandContext.map.walls.forEach((Point<int> coordinates, Wall w) {
    final double distance = startCoordinates.distanceTo(coordinates);
    if (distance <= commandContext.options.echoLocationDistance) {
      Timer(Duration(milliseconds: (distance * commandContext.options.echoLocationDistanceMultiplier).round()), () => playSoundAtCoordinates(url, coordinates: Point<double>(coordinates.x.toDouble(), coordinates.y.toDouble()), dry: true));
    }
  });
  for (final Exit e in commandContext.map.exits.values) {
    final Point<int> coordinates = Point<int>(e.x, e.y);
    final double distance = startCoordinates.distanceTo(coordinates);
    if (distance <= commandContext.options.echoLocationDistance) {
      Timer(Duration(milliseconds: (distance * commandContext.options.echoLocationDistanceMultiplier).round()), () => playSoundAtCoordinates(exitSoundUrl, coordinates: Point<double>(coordinates.x.toDouble(), coordinates.y.toDouble()), dry: true));
    }
  }
}

/// Get an integer from the user, and send it with a command.
void getInt(
  String title, int Function() getValue, void Function(int) setValue, {
    int min = 0, int max, int step = 1, bool allowNull = true
  }
) {
  final NumberInputElement e = NumberInputElement();
  if (min != null) {
    e.min = min.toString();
  }
  if (max != null) {
    e.max = max.toString();
  }
  if (step != null) {
  e.step = step.toString();
  }
  FormBuilder(title, (Map<String, String> data) {
    int value = int.tryParse(data['value']);
    if (value == 0 && allowNull) {
      value = null;
    }
    setValue(value);
    resetFocus();
  }, showMessage, onCancel: resetFocus)
    ..addElement('value', element: e, value: getValue().toString(), label: title)
    ..render(formBuilderDiv, beforeRender: keyboard.releaseAll);
}

/// How to handle the empty string with [getString].
enum EmptyStringHandler {
  /// Allow empty strings.
  allow,

  /// Empty strings mean null.
  makeNull,

  /// Strings must not be empty.
  disallow,
}

/// Get a String.
void getString(String title, String Function() getValue, void Function(String) setValue, {EmptyStringHandler emptyString = EmptyStringHandler.makeNull, String label = 'Value'}) {
  FormBuilder(title, (Map<String, String> data) {
    String value = data['value'];
    if (value.isEmpty && emptyString == EmptyStringHandler.makeNull) {
      value = null;
    }
    setValue(value);
    resetFocus();
  }, showMessage, onCancel: resetFocus)
    ..addElement('value', value: getValue(), validator: emptyString == EmptyStringHandler.disallow ? notEmptyValidator : null, label: label)
    ..render(formBuilderDiv, beforeRender: keyboard.releaseAll);
}

/// Get int coordinates.
Point<int> getIntCoordinates([Point<double> c]) {
  c ??= commandContext.coordinates;
  return Point<int>(c.x.floor(), c.y.floor());
}

/// Used to lock and unlock accounts.
void lockAccount(int id, [bool unlock = false]) {
  if (unlock) {
    commandContext.send('lockAccount', <dynamic>[id, null]);
  } else {
    getString('Lock Message', () => 'Your account has been locked by ${commandContext.characterName}.', (String value) {
      commandContext.send('lockAccount', <dynamic>[id, value]);
    }, emptyString: EmptyStringHandler.disallow);
  }
  clearBook();
}
