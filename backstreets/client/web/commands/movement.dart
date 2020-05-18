/// Contains movement commands.
library movement;

import 'dart:math';

import 'command_context.dart';

Future<void> characterCoordinates(CommandContext ctx) async {
  ctx.coordinates = Point<double>(ctx.args[0] as double, ctx.args[1] as double);
}

Future<void> mapName(CommandContext ctx) async {
  ctx.mapName = ctx.args[0] as String;
  ctx.message('You are on ${ctx.mapName}.');
}

Future<void> tile(CommandContext ctx) async {
}
