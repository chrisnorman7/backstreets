import 'dart:io';

import 'package:aqueduct/aqueduct.dart';

import '../channel.dart';
import 'game_map.dart';

final Directory tileSoundsDirectory = Directory('client/web/sounds/tiles');

/// A tile on a [GameMap].
///
/// Tiles dictate certain things about the terrain, such as the footstep sound, and (eventually), the sound made by objects as they die, and fall to earth.
class Tile {
  /// Create a tile with a name. Actually called when [BackstreetsChannel] is prepared.
  Tile(this.name) {
    logger = Logger(name);
    soundsDirectory = Directory('${tileSoundsDirectory.path}/$name');
    final Directory footstepSoundsDirectory = Directory('${soundsDirectory.path}/footsteps');
    footstepSoundsDirectory.list(recursive: true).listen((FileSystemEntity entity) {
      if (entity is File) {
        final FileStat stat = entity.statSync();
        footstepSounds.add('${entity.path}?${stat.modified.millisecondsSinceEpoch}');
        logger.info('Added footstep sound ${footstepSounds.last} to $name tile.');
      }
    });
  }

  String name;
  Directory soundsDirectory;
  List<String> footstepSounds = <String>[];
  Logger logger;
}

List<Tile> tiles = <Tile>[];
