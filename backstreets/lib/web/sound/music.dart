import 'dart:html';
import 'dart:web_audio';

import 'sound.dart';

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

  AudioNode gain;
  AudioBufferSourceNode source;

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
