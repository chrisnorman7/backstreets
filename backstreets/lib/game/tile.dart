import 'dart:io';

import 'package:aqueduct/aqueduct.dart';

final Directory tileSoundsDirectory = Directory('sounds/tiles');

class Tile {
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
