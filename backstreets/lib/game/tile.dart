/// Provides the [Tile] class, and the [tiles] list.
library tile;

import 'dart:io';

import 'package:aqueduct/aqueduct.dart';
import 'package:path/path.dart' as path;

import '../channel.dart';
import '../sound.dart' as sound;
import 'game_map.dart';

/// The directory where tile sounds are kept.
final Directory tileSoundsDirectory = Directory(path.join(sound.soundsDirectory, 'tiles'));

/// A tile on a [GameMap] instance.
///
/// Tiles dictate certain things about the terrain, such as the footstep sound, and (eventually), the sound made by objects as they die and fall to earth.
class Tile {
  /// Create a tile with a name. Actually called when [BackstreetsChannel] is prepared.
  ///
  /// The name must be a subdirectory of `sounds/tiles`, as that is where the code will automatically look for tile-related sounds.
  ///
  /// If you don't want that automatic behaviour (a silent tile perhaps), then set the appropriate attributes yourself.
  ///
  /// final Tile t = Tile('wood');
  Tile(this.name) {
    logger = Logger(name);
    soundsDirectory = path.join(tileSoundsDirectory.path, name);
    final Directory footstepSoundsDirectory = Directory(path.join(soundsDirectory, 'footsteps'));
    footstepSoundsDirectory.list(recursive: true).listen((FileSystemEntity entity) {
      if (entity is File) {
        footstepSounds.add(sound.Sound(entity.path.substring(sound.soundsDirectory.length + 1)));
        logger.info('Added footstep sound ${footstepSounds.last.url} to $name tile.');
      }
    });
  }

  /// The name of this tile.
  String name;

  /// The directory where sounds relating to this tile are stored.
  ///
  /// This directory should be a sub directory of [tileSoundsDirectory].
  String soundsDirectory;

  /// A list of all the footstep sounds.
  ///
  /// This will be set automatically by [BackstreetsChannel.prepare].
  List<sound.Sound> footstepSounds = <sound.Sound>[];

  /// The logger to use when adding sounds.
  Logger logger;
}

/// All instantiated tiles.
///
/// If creating tiles by hand, you should probably add them to this list, so they can be accessed by the online creation tools.
List<Tile> tiles = <Tile>[];
