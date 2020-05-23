/// Contains movement commands.
library movement;

import 'dart:math';

import '../hotkeys/movement.dart';

import '../keyboard/hotkey.dart';

import '../map_section.dart';

import 'command_context.dart';

Future<void> characterCoordinates(CommandContext ctx) async {
  ctx.coordinates = Point<double>(ctx.args[0] as double, ctx.args[1] as double);
  ctx.sounds.audioContext.listener.positionX.value = ctx.coordinates.x;
  ctx.sounds.audioContext.listener.positionY.value = ctx.coordinates.y;
}

Future<void> mapName(CommandContext ctx) async => ctx.mapName = ctx.args[0] as String;

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
  ctx.args[0] = data['ambience'] as String;
  await mapAmbience(ctx);
  for (final dynamic sectionData in data['sections'] as List<dynamic>) {
    ctx.args[0] = sectionData as Map<String, dynamic>;
    await mapSection(ctx);
  }
  for (final dynamic tileData in data['tiles'] as List<dynamic>) {
    ctx.args[0] = tileData;
    await tile(ctx);
  }
  ctx.args[0] = data['name'];
  await mapName(ctx);
}

Future<void> characterSpeed(CommandContext ctx) async {
  for (final Hotkey hk in <Hotkey>[walkForwards, walkBackwards]) {
    hk.interval = ctx.args[0] as int;
  }
}

Future<void> characterTheta(CommandContext ctx) async {
  ctx.theta = ctx.args[0] as double;
}

Future<void> renameSection(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final String name = ctx.args[1] as String;
  ctx.sections[id].name = name;
}

Future<void> sectionTileName(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final String tileName = ctx.args[1] as String;
  ctx.sections[id].tileName = tileName;
}

Future<void> mapSection(CommandContext ctx) async {
  final Map<String, dynamic> sectionData = ctx.args[0] as Map<String, dynamic>;
  final int id = sectionData['id'] as int;
  ctx.sections[id] = MapSection(
    id,
    sectionData['startX'] as int,
    sectionData['startY'] as int,
    sectionData['endX'] as int,
    sectionData['endY'] as int,
    sectionData['name'] as String,
    sectionData['tileName'] as String,
    sectionData['tileSize'] as double,
  );
}

Future<void> mapAmbience(CommandContext ctx) async {
  ctx.ambienceUrl = ctx.args[0] as String;
  if (ctx.ambience != null) {
    ctx.ambience.stop();
  }
  if (ctx.ambienceUrl == null) {
    ctx.ambience = null;
  } else {
    ctx.ambience = ctx.sounds.playSound(ctx.ambienceUrl, loop: true);
  }
}
