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

  void reset() {
    if (url == null) {
      sound = null;
    } else if (coordinates == null) {
      if (sound != null) {
        sound.sound.stop();
      }
      sound = PannedSound(sounds.playSound(url, output: output, loop: true), null, null, null);
    } else {
      if (url != sound?.sound?.url) {
        if (sound != null) {
          sound.sound.stop();
        }
        sound = playSoundAtCoordinates(url, coordinates: coordinates, output: output, loop: true, size: distance);
      } else {
        sound.panner
          ..positionX.value = coordinates.x
          ..positionY.value = coordinates.y;
      }
    }
  }
}
