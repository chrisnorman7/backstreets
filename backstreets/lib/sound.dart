/// Provides the [Sound] class.
library sound;

import 'dart:io';

import 'package:path/path.dart' as _path;

/// Sound file extensions supported by the server.
///
/// This list is used to ensure we're not sending `.ds_store` and `desktop.ini` files among others.
const List<String> allowedExtensions = <String>[
  '.wav',
  '.mp3',
  '.ogg',
  '.m4a',
];

/// The directory where all sounds are stored.
final String soundsDirectory = _path.join('client', 'web', 'sounds');

/// The directory where all ambience sounds are stored.
final Directory ambienceDirectory = Directory(_path.join(soundsDirectory, 'ambience'));

/// All the possible ambiences.
final Map<String, Sound> ambiences = <String, Sound>{};

/// The directory where ambiences are stored.
final Directory impulseDirectory = Directory(_path.join(soundsDirectory, 'impulses'));

Map<String, dynamic> loadImpulses([Directory start]) {
  start ??= impulseDirectory;
  const String directoriesKey = 'directories';
  const String filesKey = 'files';
  final Map<String, dynamic> impulses = <String, dynamic>{
    'name': start.path,
    directoriesKey: <Map<String, dynamic>>[],
    filesKey: <String>[],
  };
  for (final FileSystemEntity entity in start.listSync()) {
    if (entity is Directory) {
      impulses[directoriesKey].add(loadImpulses(entity));
    } else {
      if (allowedExtensions.contains(_path.extension(entity.path))) {
        impulses[filesKey].add(_path.relative(entity.path, from: Directory(soundsDirectory).parent.path));
      }
    }
  }
  return impulses;
}

/// The directory where all echo sounds are held.
final Directory echoSoundsDirectory = Directory(_path.join(soundsDirectory, 'echoes'));

/// All the loaded echo sounds.
Map<String, String> echoSounds = <String, String>{};

/// A sound object.
///
/// Passed a path, it will give you a URL, with appropriate get params.
///
/// ```
/// final Sound s = Sound('beep.wav');
/// print(s.url);
/// beep.wav?123456
/// ```
class Sound {
  /// Create with a path.
  /// ```
  /// final Sound sound = Sound('beep.wav');
  Sound(String p) {
    if (p.startsWith(soundsDirectory)) {
      path = p.substring(soundsDirectory.length + 1);
    } else {
      path = p;
    }
  }

  /// The path there this sound is located.
  String path;

  /// Get the url for this sound. The last modified timestamp of the file will be used as the get param.
  String get url {
    final String filename = _path.join(soundsDirectory, path);
    final File file = File(filename);
    if (!file.existsSync()) {
      throw 'No such file: $filename';
    }
    final FileStat stat = file.statSync();
    return 'sounds/$path?${stat.modified.millisecondsSinceEpoch}';
  }
}
