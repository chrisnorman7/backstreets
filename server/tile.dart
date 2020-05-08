import 'dart:io';

final Directory tileSoundsDirectory = Directory('web/sounds/tiles');

class Tile {
  Tile(this.name) {
    soundsDirectory = Directory('${tileSoundsDirectory.path}/$name');
    final Directory footstepSoundsDirectory = Directory('${soundsDirectory.path}/footsteps');
    footstepSoundsDirectory.list(recursive: true).listen((FileSystemEntity entity) {
      if (entity is File) {
        final FileStat stat = entity.statSync();
        footstepSounds.add('${entity.path}?${stat.modified.millisecondsSinceEpoch}');
        print('Added footstep sound ${footstepSounds.last} to $name tile.');
      }
    });
  }

  String name;
  Directory soundsDirectory;
  List<String> footstepSounds = <String>[];
}

List<Tile> tiles = <Tile>[];
