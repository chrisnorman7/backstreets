/// Provides movement hotkeys.
library hotkeys;

import 'dart:math';

import 'package:game_utils/game_utils.dart';

import '../constants.dart';
import '../game/exit.dart';
import '../game/map_section.dart';

import '../main.dart';
import '../util.dart';

void coordinates() => showMessage('${commandContext.coordinates.x.floor()}, ${commandContext.coordinates.y.floor()}.', important: false);

void mapName() {
  String result = commandContext.map.name;
  final MapSection s = commandContext.getCurrentSection();
  if (s != null) {
    result += ': ${s.name}';
  }
  commandContext.message('$result.');
}

void facing() => showMessage(headingToString(commandContext.theta));

void showTheta() => showMessage(commandContext.theta.toString());

void walkForwards() => move(1);

void walkBackwards() => move(-0.5);

void left() => turn(-1);

void leftSnap() => snap(SnapDirections.left);

void right() => turn(1);

void rightSnap() => snap(SnapDirections.right);

void aboutFace() {
  /// Turn a full 180, then 45 more, s that snap can announce the new heading.
  commandContext.theta += 180 + 45;
  if (commandContext.theta > 360) {
    commandContext.theta -= 360;
  }
  snap(SnapDirections.left);
}

void sectionSize() {
  final MapSection s = commandContext.getCurrentSection();
  if (s == null) {
    return showMessage('You are not currently on a section.');
  }
  showMessage('${s.textSize}.', important: false);
}

void mapSize() {
  int startX, startY, endX, endY;
  commandContext.map.sections.forEach((int id, MapSection s) {
    if (startX == null) {
      startX = s.startX;
    } else {
      startX = min(s.startX, startX);
    }
    if (startY == null) {
      startY = s.startY;
    } else {
      startY = min(s.startY, startY);
    }
    if (endX == null) {
      endX = s.endX;
    } else {
      endX = max(s.endX, endX);
    }
    if (endY == null) {
      endY = s.endY;
    } else {
      endY = max(s.endY, endY);
    }
  });
  final Rectangle<int> rect = Rectangle<int>.fromPoints(Point<int>(startX, startY), Point<int>(endX, endY));
  showMessage('${rect.width + 1} x ${rect.height + 1}: $startX, $endX to $endX, $endY.', important: false);
}

void showExits() {
  final List<String> exits = <String>[];
  commandContext.map.exits.forEach((int id, Exit e) {
    if (e.x == commandContext.coordinates.x.floor() && e.y == commandContext.coordinates.y.floor()) {
      exits.add(e.name);
    }
  });
  if (exits.isEmpty) {
    showMessage('There are no exits here.', important: false);
  } else {
    showMessage('Exits: ${englishList(exits)}.', important: false);
  }
}

void nearestExit() {
  final Point<int> coordinates = getIntCoordinates();
  Exit x;
  for (final Exit e in commandContext.map.exits.values) {
    if (x == null || e.coordinates.distanceTo(coordinates) < x.coordinates.distanceTo(coordinates)) {
      x = e;
    }
    if (x == null) {
      commandContext.message('There are no visible exits.');
    } else {
      playSoundAtCoordinates(commandContext.echoSounds[commandContext.options.echoSound], coordinates: Point<double>(x.x.toDouble(), x.y.toDouble()), dry: true);
      commandContext.message('The nearest exit is ${x.name}: ${relativeDirections(coordinates, x.coordinates)}.');
    }
  }
}