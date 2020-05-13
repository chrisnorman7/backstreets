/// Provides the [Sound] class.
library sound;

import 'dart:io';

import 'package:path/path.dart' as _path;

/// The directory where all sounds are stored.
final String soundsDirectory = _path.join('client', 'web', 'sounds');

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
  Sound(this.path);
  final String path;

  /// Get the url for this sound. The last modified timestamp of the file will be used as the get param.
  String get url {
    final File file = File(_path.join(soundsDirectory, path));
    if (!file.existsSync()) {
      throw 'No such file: ${file.path}';
    }
    final FileStat stat = file.statSync();
    return 'sounds/$path?${stat.modified.millisecondsSinceEpoch}';
  }
}
