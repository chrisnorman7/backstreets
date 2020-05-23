/// Provides movement hotkeys.
library hotkeys;

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
