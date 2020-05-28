/// Contains movement commands.
library movement;

import 'dart:math';

import 'package:game_utils/game_utils.dart';

import '../game/game_map.dart';
import '../game/map_section.dart';

import '../main.dart';
import '../util.dart';

import 'command_context.dart';

/// Save the character's coordinates.
///
/// These get stored in [ctx].coordinates.
Future<void> characterCoordinates(CommandContext ctx) async => moveCharacter(
  (ctx.args[0] as num).toDouble(),
  (ctx.args[1] as num).toDouble(),
  mode: MoveModes.silent
);

/// Store the name of the current map.
///
/// Used when the v key is pressed.
Future<void> mapName(CommandContext ctx) async => ctx.map = GameMap(ctx.args[0] as String);

/// Used when a single tile is added to the map.
Future<void> tile(CommandContext ctx) async {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  final int index = data['index'] as int;
  final double x = data['x'] as double;
  final double y = data['y'] as double;
  ctx.map.tiles[Point<int>(x.toInt(), y.toInt())] = ctx.tileNames[index];
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
  ctx.args[0] = data['name'];
  await mapName(ctx);
  ctx.args[0] = data['ambience'] as String;
  await mapAmbience(ctx);
  final Map<String, dynamic> convolverData = <String, dynamic>{
    'url': data['convolverUrl'] as String,
    'volume': (data['convolverVolume'] as num).toDouble()
  };
  ctx.args[0] = convolverData;
  await mapConvolver(ctx);
  for (final dynamic sectionData in data['sections'] as List<dynamic>) {
    ctx.args[0] = sectionData as Map<String, dynamic>;
    await mapSection(ctx);
  }
  for (final dynamic tileData in data['tiles'] as List<dynamic>) {
    ctx.args[0] = tileData;
    await tile(ctx);
  }
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
  ctx.map.sections[id].name = name;
}

/// The tileName of a map section has changed.
Future<void> sectionTileName(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final String tileName = ctx.args[1] as String;
  ctx.map.sections[id].tileName = tileName;
}

/// Map section data has been received.
///
/// This command creates a new [MapSection] instance.
Future<void> mapSection(CommandContext ctx) async {
  final Map<String, dynamic> sectionData = ctx.args[0] as Map<String, dynamic>;
  final int id = sectionData['id'] as int;
  ctx.map.sections[id] = MapSection(
    ctx.sounds, id,
    sectionData['startX'] as int,
    sectionData['startY'] as int,
    sectionData['endX'] as int,
    sectionData['endY'] as int,
    sectionData['name'] as String,
    sectionData['tileName'] as String,
    sectionData['tileSize'] as double,
    sectionData['convolverUrl'] as String,
    (sectionData['convolverVolume'] as num).toDouble(),
  );
  if (id == ctx.sectionResetId) {
    ctx.message('Section reset.');
  }
}

/// The ambience of this map has changed.
Future<void> mapAmbience(CommandContext ctx) async {
  ctx.map.ambienceUrl = ctx.args[0] as String;
  if (ctx.map.ambience != null) {
    ctx.map.ambience.stop();
  }
  if (ctx.map.ambienceUrl == null) {
    ctx.map.ambience = null;
  } else {
    ctx.map.ambience = ctx.sounds.playSound(ctx.map.ambienceUrl, output: ctx.sounds.ambienceOutput, loop: true);
  }
}

/// A map section has been deleted.
Future<void> deleteMapSection(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  ctx.map.sections.remove(id);
}

Future<void> mapConvolver(CommandContext ctx) async {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  ctx.map.convolver.url = data['url'] as String;
  ctx.map.convolver.volume.gain.value = (data['volume'] as num).toDouble();
  ctx.map.convolver.resetConvolver();
}
