/// Contains movement commands.
library movement;

import 'dart:math';

import 'package:game_utils/game_utils.dart';

import '../game/game_map.dart';
import '../game/map_section.dart';
import '../game/wall.dart';

import '../main.dart';
import '../util.dart';

import 'command_context.dart';

/// Save the character's coordinates.
///
/// These get stored in [ctx].coordinates.
void characterCoordinates(CommandContext ctx) => moveCharacter(
  Point<double>(
    (ctx.args[0] as num).toDouble(),
    (ctx.args[1] as num).toDouble()
  ), mode: MoveModes.silent
);

/// Store the name of the current map.
///
/// Used when the v key is pressed.
void mapName(CommandContext ctx) => ctx.map = GameMap(ctx.args[0] as String);

/// Used when a single tile is added to the map.
void tile(CommandContext ctx) {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  final int index = data['index'] as int;
  final int x = data['x'] as int;
  final int y = data['y'] as int;
  ctx.map.tiles[Point<int>(x, y)] = ctx.tileNames[index];
}

/// Save a list of all the possible tile names.
///
/// This list is used extensively by the builder menu (Hotkey b).
void tileNames(CommandContext ctx) {
  for (final dynamic tileName in ctx.args) {
    ctx.tileNames.add(tileName as String);
  }
}

/// Add a new footstep sound for a particular tile type.
///
/// These URLs are used by menus that show lists of tiles, and when walking.
void footstepSound(CommandContext ctx) {
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
void mapData(CommandContext ctx) {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  ctx.args[0] = data['name'];
  mapName(ctx);
  ctx.args[0] = data['ambience'] as String;
  mapAmbience(ctx);
  ctx.args[0] = <String, dynamic>{
    'url': data['convolverUrl'] as String,
    'volume': (data['convolverVolume'] as num).toDouble()
  };
  mapConvolver(ctx);
  for (final dynamic sectionData in data['sections'] as List<dynamic>) {
    ctx.args[0] = sectionData as Map<String, dynamic>;
    mapSection(ctx);
  }
  for (final dynamic tileData in data['tiles'] as List<dynamic>) {
    ctx.args[0] = tileData;
    tile(ctx);
  }
  for (final dynamic wallData in data['walls'] as List<dynamic>) {
    ctx.args[0] = wallData as Map<String, dynamic>;
    mapWall(ctx);
  }
}

/// The speed the character can move at.
///
/// This command sets the interval property on both [walkForwardsHotkey] and [walkBackwardsHotkey].
void characterSpeed(CommandContext ctx) {
  for (final Hotkey hk in <Hotkey>[walkForwardsHotkey, walkBackwardsHotkey]) {
    hk.interval = ctx.args[0] as int;
  }
}

/// Set the direction the character is facing in.
void characterTheta(CommandContext ctx) => ctx.theta = ctx.args[0] as double;

/// A section of the map has been renamed.
void renameSection(CommandContext ctx) {
  final int id = ctx.args[0] as int;
  final String name = ctx.args[1] as String;
  ctx.map.sections[id].name = name;
}

/// The tileName of a map section has changed.
void sectionTileName(CommandContext ctx) {
  final int id = ctx.args[0] as int;
  final String tileName = ctx.args[1] as String;
  ctx.map.sections[id].tileName = tileName;
}

/// Map section data has been received.
///
/// This command creates a new [MapSection] instance.
void mapSection(CommandContext ctx) {
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
void mapAmbience(CommandContext ctx) {
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
void deleteMapSection(CommandContext ctx) {
  final int id = ctx.args[0] as int;
  ctx.map.sections.remove(id);
}

void mapConvolver(CommandContext ctx) {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  ctx.map.convolver.url = data['url'] as String;
  ctx.map.convolver.volume.gain.value = (data['volume'] as num).toDouble();
  ctx.map.convolver.resetConvolver();
}

void mapWall(CommandContext ctx) {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  final int id = data['id'] as int;
  final int x = data['x'] as int;
  final int y = data['y'] as int;
  final String sound = data['sound'] as String;
  final int typeIndex = data['type'] as int;
  final WallTypes type = WallTypes.values.toList()[typeIndex];
  final Point<int> coordinates = Point<int>(x, y);
  if (ctx.map.walls.containsKey(coordinates)) {
    ctx.map.walls[coordinates]
      ..id = id
      ..type = type
      ..sound = sound;
  } else {
    ctx.map.walls[coordinates] = Wall(id, type, sound);
  }
}

void deleteWall(CommandContext ctx) {
  final int id = ctx.args[0] as int;
  ctx.map.walls.removeWhere((Point<int> coordinates, Wall w) => w.id == id);
}
