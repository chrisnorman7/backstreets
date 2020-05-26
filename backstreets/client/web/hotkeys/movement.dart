/// Provides movement hotkeys.
library hotkeys;

import 'dart:math';

import '../main.dart';
import '../map_section.dart';
import '../util.dart';

void coordinates() => showMessage('${commandContext.coordinates.x.floor()}, ${commandContext.coordinates.y.floor()}.');

void mapName() {
  String result = commandContext.mapName;
  final MapSection s = commandContext.getCurrentSection();
  if (s != null) {
    result += ': ${s.name}';
  }
  commandContext.message('$result.');
}

void facing() => showMessage(headingToString(commandContext.theta));

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
  showMessage('${s.textSize}.');
}

void mapSize() {
  int startX, startY, endX, endY;
  commandContext.sections.forEach((int id, MapSection s) {
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
  showMessage('${rect.width + 1} x ${rect.height + 1}: $startX, $endX to $endX, $endY.');
}
