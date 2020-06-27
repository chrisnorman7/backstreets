/// Provides the [Ambience] clasc.
library ambience;

import 'dart:math';
import 'dart:web_audio';

import 'package:game_utils/game_utils.dart';

import '../util.dart';
import 'panned_sound.dart';

class Ambience {
  Ambience(this.sounds, this.url, {this.output, this.coordinates, this.distance}) {
    output ??= sounds.ambienceOutput;
    reset();
  }

  /// The sound pool to use for getting sounds.
  SoundPool sounds;

  /// The coordinates the ambience should play at.
  Point<double> coordinates;

  /// The URL to load.
  String url;

  /// The output that [sound] will be piped through.
  AudioNode output;

  /// The distance modifier for this sound.
  ///
  /// Used as the panner's refDistance property.
  int distance;

  /// The actual sound that has been loaded from [url].
  PannedSound sound;

  /// Stop [sound].
  void stop() {
    sound?.stop();
    sound = null;
  }

  void reset() {
    if (url == null) {
      stop();
    } else if (coordinates == null) {
      stop();
      sound = PannedSound(sounds.playSound(url, output: output, loop: true), null, null, null, null);
    } else {
      if (url != sound?.sound?.url) {
        stop();
        sound = playSoundAtCoordinates(url, coordinates: coordinates, output: output, loop: true, size: distance);
      } else {
        if (sound.panner != null) {
          sound.panner
            ..positionX.value = coordinates.x
            ..positionY.value = coordinates.y;
        }
      }
    }
  }
}
