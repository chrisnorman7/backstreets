/// Provides the [Music] class.
library music;

import 'dart:html';
import 'dart:web_audio';

import 'sound_pool.dart';

/// Plays music on a loop.
class Music {
  Music(
    SoundPool pool, String url,
    {  AudioNode output,
    num volume = 0.5
  }
) {
    output ??= pool.audioContext.destination;
    gain = pool.audioContext.createGain();
    (gain as GainNode).gain.value = volume;
    gain.connectNode(output);
    source = pool.getSound(url, loop: true, output: gain).source;
  }

  /// Used to set the volume of music.
  AudioNode gain;
  
  /// The source to play.
  AudioBufferSourceNode source;

  /// Stop the music.
  ///
  /// If [when] is provided, pass it onto [source].stop.
  void stop(num when) {
    try {
      source.stop(when);
    }
    on DomException {
      // Music can't be stopped if it's not already been started.
    }
    finally {
      source.disconnect();
      source = null;
    }
  }
}
