/// Provides the [Convolver] class.
library convolver;

import 'dart:web_audio';

import 'package:game_utils/game_utils.dart';

import '../constants.dart';

/// Provides convolvers for maps and map sections.
class Convolver {
  Convolver(this.sounds, this.url, double _volume) {
    volume = sounds.audioContext.createGain()
      ..gain.value = _volume
      ..connectNode(sounds.output);
    resetConvolver();
  }

  /// The soundpool that instances of this class will use to create their outputs.
  SoundPool sounds;

  /// The convolver URL.
  String url;

  /// The actual convolver node.
  ///
  /// Created by [resetConvolver].
  ConvolverNode convolver;

  /// The volume for [convolver].
  GainNode volume;

  /// Get [convolverUrl] without the sounds directory, or get params.
  String get compactUrl {
    if (url != null) {
      int start = 0, end;
      if (url.startsWith(soundsDirectory)) {
        start = soundsDirectory.length;
      }
      if (url.contains('?')) {
        end = url.indexOf('?');
      }
      return url.substring(start, end);
    }
    return null;
  }

  /// Initialise [convolver].
  void resetConvolver() {
    if (convolver != null) {
      convolver.disconnect();
      convolver = null;
    }
    if (url != null) {
      sounds.loadBuffer(url.startsWith(soundsDirectory) ? url : '$soundsDirectory$url', (AudioBuffer buffer) {
        // only do something if convolver is still null.
        //
        // Otherwise, the convolver might have changed since this function was called, and we don't want to change it again.
        convolver ??= sounds.audioContext.createConvolver()
          ..buffer = buffer
          ..connectNode(volume);
      });
    }
  }
}
