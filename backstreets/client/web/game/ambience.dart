/// Provides the [Ambience] clasc.
library ambience;

import 'dart:math';
import 'dart:web_audio';

import 'package:game_utils/game_utils.dart';

import '../util.dart';

class Ambience {
  Ambience(this.sounds, this.url, {this.output, this.x, this.y}) {
    output ??= sounds.ambienceOutput;
    reset();
  }

  /// The sound pool to use for getting sounds.
  SoundPool sounds;

  /// The x coordinate of this ambience.
  double x;

  /// The y coordinate of this ambience.
  double y;

  /// The URL to load.
  String url;

  /// The output that [sound] will be piped through.
  AudioNode output;

  /// The actual sound that has been loaded from [url].
  Sound sound;

  /// Returns the coordinates of this ambience.
  /// 
  /// If [x] or [y] are null, null is returned.
  Point<double> get coordinates {
    if (x == null || y == null) {
      return null;
    } else {
      return Point<double>(x, y);
    }
  }

  void reset() {
    if (sound != null) {
      sound.stop();
    }
    if (url == null) {
      sound = null;
    } else if (coordinates != null) {
      sound = playSoundAtCoordinates(url, coordinates: coordinates, output: output, loop: true);
    } else {
      sound = sounds.playSound(url, output: output, loop: true);
    }
  }
}
