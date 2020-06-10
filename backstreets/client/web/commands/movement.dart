/// Contains movement commands.
library movement;

import 'dart:math';

import 'package:game_utils/game_utils.dart';

import '../constants.dart';
import '../game/ambience.dart';
import '../game/exit.dart';
import '../game/game_map.dart';
import '../game/map_reference.dart';
import '../game/map_section.dart';
import '../game/panned_sound.dart';
import '../game/wall.dart';
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
void mapName(CommandContext ctx) {
  final int id = ctx.args[0] as int;
  final String name = ctx.args[1] as String;
  ctx.maps[id].name = name;
  if (ctx.map == null) {
  ctx.map = GameMap(id, name);
  } else {
    ctx.map.name = name;
  }
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
  final int id = data['id'] as int;
  final String name = data['name'] as String;
  if (ctx.map?.id != id) {
    if (ctx.map != null) {
      ctx.map.stop();
    }
    ctx.map = GameMap(id, name);
  } else {
    ctx.args = <dynamic>[id, name];
    mapName(ctx);
  }
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
  for (final dynamic wallData in data['walls'] as List<dynamic>) {
    ctx.args[0] = wallData as Map<String, dynamic>;
    mapWall(ctx);
  }
  for (final dynamic exitData in data['exits'] as List<dynamic>) {
    ctx.args[0] = exitData;
    addExit(ctx);
  }
}

/// The speed the character can move at.
///
/// This command sets the interval property on both [walkForwardsHotkey] and [walkBackwardsHotkey].
void characterSpeed(CommandContext ctx) {
  ctx.speed = ctx.args[0] as int;
  for (final Hotkey hk in <Hotkey>[walkForwardsHotkey, walkBackwardsHotkey]) {
    hk.interval = ctx.speed;
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
/// If there is no section at the given coordinates, this function creates a new [MapSection] instance. Otherwise, the existing instance is modified.
void mapSection(CommandContext ctx) {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  final int id = data['id'] as int;
  final int startX = data['startX'] as int;
  final int startY = data['startY'] as int;
  final int endX = data['endX'] as int;
  final int endY = data['endY'] as int;
  final String name = data['name'] as String;
  final String tileName = data['tileName'] as String;
  final double tileSize = data['tileSize'] as double;
  final String convolverUrl = data['convolverUrl'] as String;
  final double convolverVolume = (data['convolverVolume'] as num).toDouble();
  String ambienceUrl = data['ambienceUrl'] as String;
  final int ambienceDistance = data['ambienceDistance'] as int;
  final List<dynamic> actions = data['actions'] as List<dynamic>;
  if (ctx.map.sections.containsKey(id)) {
    ctx.map.sections[id]
      ..startX = startX
      ..endX = endX
      ..startY = startY
      ..endY = endY
      ..name = name
      ..tileName = tileName
      ..tileSize = tileSize;
    ctx.map.sections[id].convolver
      ..url = convolverUrl
      ..volume.gain.value = convolverVolume
      ..resetConvolver();
    ctx.args[0] = <String, dynamic>{'id': id, 'url': ambienceUrl, 'distance': ambienceDistance};
    mapSectionAmbience(ctx);
  } else {
    if (ambienceUrl != null) {
      ambienceUrl = ctx.ambiences[ambienceUrl];
    }
    ctx.map.sections[id] = MapSection(
      ctx.sounds, id, startX, startY, endX, endY, name, tileName, tileSize,
      convolverUrl, convolverVolume, ambienceUrl, ambienceDistance
    );
  }
  if (actions != null) {
    for (final dynamic action in actions) {
      ctx.map.sections[id].actions.add(action as String);
    }
  }
  if (id == ctx.sectionResetId) {
    ctx.message('Section reset.');
    ctx.sectionResetId = null;
  }
}

/// The ambience of this map has changed.
void mapAmbience(CommandContext ctx) {
  final String url = ctx.args[0] as String;
  if (ctx.map.ambience == null) {
    ctx.map.ambience = Ambience(ctx.sounds, url);
  } else if (ctx.map.ambience.url != url) {
    ctx.map.ambience.url = url;
    ctx.map.ambience.reset();
  }
}

/// A map section has been deleted.
void deleteMapSection(CommandContext ctx) {
  final int id = ctx.args[0] as int;
  ctx.map.sections.remove(id);
}

/// A map has a new convolver.
void mapConvolver(CommandContext ctx) {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  ctx.map.convolver.url = data['url'] as String;
  ctx.map.convolver.volume.gain.value = (data['volume'] as num).toDouble();
  ctx.map.convolver.resetConvolver();
}

/// A new wall has been created.
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

/// A wall should be deleted from a map.
void deleteWall(CommandContext ctx) {
  final int id = ctx.args[0] as int;
  ctx.map.walls.removeWhere((Point<int> coordinates, Wall w) => w.id == id);
}

/// Assign a new ambience to a map section.
void mapSectionAmbience(CommandContext ctx) {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  final int id = data['id'] as int;
  String url = data['url'] as String;
  if (url != null) {
    url = ctx.ambiences[url];
  }
  final MapSection s = ctx.map.sections[id];
  s.ambience
    ..url = url
    ..coordinates = s.ambienceCoordinates
    ..reset();
}

/// A new game map has been added.
void addGameMap(CommandContext ctx) {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  final int id = data['id'] as int;
  final String name = data['name'] as String;
  final bool playersCanCreate = data['playersCanCreate'] as bool;
  final int popX = data['popX'] as int;
  final int popY = data['popY'] as int;
  ctx.maps[id] = MapReference(id, name, playersCanCreate, popX, popY);
}

void deleteGameMap(CommandContext ctx) {
  final int id = ctx.args[0] as int;
  ctx.maps.remove(id);
}

void setPlayersCanCreate(CommandContext ctx) {
  final int id = ctx.args[0] as int;
  final bool value = ctx.args[1] as bool;
  ctx.maps[id].playersCanCreate = value;
}

void addMapSectionAction(CommandContext ctx) {
  final int id = ctx.args[0] as int;
  final String name = ctx.args[1] as String;
  ctx.map.sections[id].actions.add(name);
}

void removeMapSectionAction(CommandContext ctx) {
  final int id = ctx.args[0] as int;
  final String name = ctx.args[1] as String;
  ctx.map.sections[id].actions.removeWhere((String e) => e == name);
}

void addExit(CommandContext ctx) {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  final int id = data['id'] as int;
  final String name = data['name'] as String;
  final int x = data['x'] as int;
  final int y = data['y'] as int;
  final int destinationX = data['destinationX'] as int;
  final int destinationY = data['destinationY'] as int;
  final int destinationId = data['destinationId'] as int;
  final String useSocial = data['useSocial'] as String;
  final String useSound = data['useSound'] as String;
  final Exit e = Exit(name, ctx.map.id, x, y)
    ..destinationId = destinationId
    ..destinationX = destinationX
    ..destinationY = destinationY
    ..id = id
    ..useSocial = useSocial
    ..useSound = useSound;
  e.permissions
    ..admin = data['admin'] as bool
    ..builder = data['builder'] as bool;
  ctx.map.exits[id] = e;
}

void deleteExit(CommandContext ctx) {
  final int id = ctx.args[0] as int;
  ctx.map.exits.remove(id);
}

/// An object on the current map has moved.
void objectMoved(CommandContext ctx) {
  final int id = ctx.args[0] as int;
  final double x = (ctx.args[1] as num).toDouble();
  final double y = (ctx.args[2] as num).toDouble();
  ctx.objectCoordinates[id] = Point<double>(x, y);
  for (final PannedSound s in ctx.pannedSounds) {
    if (s.id == id && s.panner != null) {
      s.panner
        ..positionX.value = x
        ..positionY.value = y;
    }
  }
}
