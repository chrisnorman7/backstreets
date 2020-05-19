/// Contains movement commands.
library movement;

import 'dart:math';

import '../map_section.dart';

import 'command_context.dart';

Future<void> characterCoordinates(CommandContext ctx) async {
  ctx.coordinates = Point<double>(ctx.args[0] as double, ctx.args[1] as double);
}

Future<void> mapName(CommandContext ctx) async {
  ctx.mapName = ctx.args[0] as String;
  ctx.message('Loaded ${ctx.mapName} in ${((DateTime.now().millisecondsSinceEpoch - ctx.loadingStarted) / 1000).toStringAsFixed(2)} seconds.');
}

Future<void> tile(CommandContext ctx) async {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  final int index = data['index'] as int;
  final double x = data['x'] as double;
  final double y = data['y'] as double;
  ctx.tiles[Point<int>(x.toInt(), y.toInt())] = ctx.tileNames[index];
}

Future<void> tileNames(CommandContext ctx) async {
  for (final dynamic tileName in ctx.args) {
    ctx.tileNames.add(tileName as String);
  }
}

Future<void> footstepSound(CommandContext ctx) async {
  final String tileName = ctx.args[0] as String;
  final String url = ctx.args[1] as String;
  if (!ctx.footstepSounds.containsKey(tileName)) {
    ctx.footstepSounds[tileName] = <String>[];
  }
  ctx.footstepSounds[tileName].add(url);
}

Future<void> mapData(CommandContext ctx) async {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  for (final dynamic sectionData in data['sections'] as List<dynamic>) {
    ctx.sections.add(MapSection(
      sectionData['startX'] as int,
      sectionData['startY'] as int,
      sectionData['endX'] as int,
      sectionData['endY'] as int,
      sectionData['name'] as String,
      sectionData['tileName'] as String,
    ));
  }
  for (final dynamic tileData in data['tiles'] as List<dynamic>) {
    ctx.args[0] = tileData;
    await tile(ctx);
  }
  ctx.args[0] = data['name'];
  await mapName(ctx);
}

Future<void> characterSpeed(CommandContext ctx) async {
  ctx.speed = ctx.args[0] as int;
}

Future<void> characterTheta(CommandContext ctx) async {
  ctx.theta = ctx.args[0] as double;
}
