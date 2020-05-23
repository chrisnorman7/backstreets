/// Contains movement commands.
library movement;

import 'dart:math';

import '../keyboard/hotkey.dart';

import '../main.dart';
import '../map_section.dart';

import 'command_context.dart';

/// Save the character's coordinates.
///
/// These get stored in [ctx].coordinates.
Future<void> characterCoordinates(CommandContext ctx) async {
  ctx.coordinates = Point<double>(ctx.args[0] as double, ctx.args[1] as double);
  ctx.sounds.audioContext.listener.positionX.value = ctx.coordinates.x;
  ctx.sounds.audioContext.listener.positionY.value = ctx.coordinates.y;
}

/// Store the name of the current map.
///
/// Used when the v key is pressed.
Future<void> mapName(CommandContext ctx) async => ctx.mapName = ctx.args[0] as String;

/// Used when a single tile is added to the map.
Future<void> tile(CommandContext ctx) async {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  final int index = data['index'] as int;
  final double x = data['x'] as double;
  final double y = data['y'] as double;
  ctx.tiles[Point<int>(x.toInt(), y.toInt())] = ctx.tileNames[index];
}

/// Save a list of all the possible tile names.
///
/// This list is used extensively by the builder menu (Hotkey b).
Future<void> tileNames(CommandContext ctx) async {
  for (final dynamic tileName in ctx.args) {
    ctx.tileNames.add(tileName as String);
  }
}

/// Add a new footstep sound for a particular tile type.
///
/// These URLs are used by menus that show lists of tiles, and when walking.
Future<void> footstepSound(CommandContext ctx) async {
  final String tileName = ctx.args[0] as String;
  final String url = ctx.args[1] as String;
  if (!ctx.footstepSounds.containsKey(tileName)) {
    ctx.footstepSounds[tileName] = <String>[];
  }
  ctx.footstepSounds[tileName].add(url);
}

/// An entire map has been sent.
///
/// Split up the data and palm it off on other commands, like [mapName], [mapSection], and [mapAmbience].
///
/// Originally I used individual commands for sending map data, and it took an age.
///
/// Since then, I've stopped using tiles, but sending one large chunk when the player enters a map still seems prudent.
///
/// The presence of multiple commands means we can send chunks as the map gets edited by a builder.
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

/// The speed the character can move at.
///
/// This command sets the interval property on both [walkForwardsHotkey] and [walkBackwardsHotkey].
Future<void> characterSpeed(CommandContext ctx) async {
  for (final Hotkey hk in <Hotkey>[walkForwardsHotkey, walkBackwardsHotkey]) {
    hk.interval = ctx.args[0] as int;
  }
}

/// Set the direction the character is facing in.
Future<void> characterTheta(CommandContext ctx) async {
  ctx.theta = ctx.args[0] as double;
}

/// A section of the map has been renamed.
Future<void> renameSection(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final String name = ctx.args[1] as String;
  ctx.sections[id].name = name;
}

/// The tileName of a map section has changed.
Future<void> sectionTileName(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final String tileName = ctx.args[1] as String;
  ctx.sections[id].tileName = tileName;
}

/// Map section data has been received.
///
/// This command creates a new [MapSection] instance.
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

/// The ambience of this map has changed.
Future<void> mapAmbience(CommandContext ctx) async {
  ctx.ambienceUrl = ctx.args[0] as String;
  if (ctx.ambience != null) {
    commandContext.message(ctx.ambienceUrl);
    ctx.ambience.stop();
  }
  if (ctx.ambienceUrl == null) {
    ctx.ambience = null;
  } else {
    ctx.ambience = ctx.sounds.playSound(ctx.ambienceUrl, output: ctx.sounds.ambienceOutput, loop: true);
  }
}

/// A map section has been deleted.
Future<void> deleteMapSection(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  ctx.sections.remove(id);
}
