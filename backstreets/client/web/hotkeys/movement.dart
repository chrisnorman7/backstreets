/// Provides movement hotkeys.
library hotkeys;

import '../commands/command_context.dart';

import '../main.dart';
import '../map_section.dart';
import '../util.dart';

void coordinates(CommandContext ctx) => showMessage('${ctx.coordinates.x.floor()}, ${ctx.coordinates.y.floor()}.');

void mapName(CommandContext ctx) {
  String result = ctx.mapName;
  final MapSection s = ctx.getCurrentSection();
  if (s != null) {
    result += ': ${s.name}';
  }
  ctx.message('$result.');
}

void facing(CommandContext ctx) => showMessage(headingToString(ctx.theta));

void walkForwards(CommandContext ctx) => move(1);

void walkBackwards(CommandContext ctx) => move(-0.5);

void left(CommandContext ctx) => turn(-1);

void leftSnap(CommandContext ctx) => snap(SnapDirections.left);

void right(CommandContext ctx) => turn(1);

void rightSnap(CommandContext ctx) => snap(SnapDirections.right);

void aboutFace(CommandContext ctx) {
  /// Turn a full 180, then 45 more, s that snap can announce the new heading.
  ctx.theta += 180 + 45;
  if (ctx.theta > 360) {
    ctx.theta -= 360;
  }
  snap(SnapDirections.left);
}
