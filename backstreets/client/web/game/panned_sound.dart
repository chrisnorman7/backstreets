/// Provides the [PannedSound] class.
library filtered_sound;

import 'dart:math';
import 'dart:web_audio';

import 'package:game_utils/game_utils.dart';

class PannedSound {
  PannedSound(this.sound, this.filter, this.coordinates, this.panner, this.id);

  /// The sound that this object represents.
  Sound sound;

  /// The filter that is currently applied to [sound].
  BiquadFilterNode filter;

  /// The coordinates this sound is playing at.
  ///
  /// We could infer these from [panner], but that will be relatively slow.
  Point<double> coordinates;

  /// The panner for [sound].
  PannerNode panner;

  /// The id of the object that generated this sound (if any).
  int id;

  /// Stop [sound].
  void stop() {
    return sound.stop();
  }
}
