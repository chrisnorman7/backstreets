/// Provides the [SoundPool] class, which is responsible for playing all sounds.
library sound;

import 'dart:html';
import 'dart:typed_data';
import 'dart:web_audio';

import 'music.dart';

typedef OnEndedType = void Function(Event);

enum OutputTypes {
  sound,
  music
}

class SoundPool {
  SoundPool(this.audioContext) {
    output = audioContext.destination;
    soundOutput = audioContext.createGain();
    musicOutput = audioContext.createGain();
  }

  /// The underlying web audio context.
  final AudioContext audioContext;


  /// The master channel.
  AudioNode output;

  /// The output for game sounds.
  ///
  /// If a convolver is required, this is the channel it should be applied to.
  AudioNode soundOutput;

  /// The output for music.
  ///
  /// This should be separated from [output], so it can have it's own independant volume control.
  AudioNode musicOutput;

  /// All the buffers that have been downloaded.
  Map<String, AudioBuffer> buffers = <String, AudioBuffer>{};

  /// The amount volume should change by when volume change hotkeys are used.
  num volumeChangeAmount = 0.1;

  /// The volume of [soundOutput].
  num soundVolume = 0.75;

  /// The volume of [musicOutput].
  ///
  /// It is important to use this value when changing the volume of the music, since nodes may fade out, and [musicOutput]'s gain may not be reliable.
  num musicVolume = 0.5;

  /// The URL to the sound which should play when the volume is changed.
  String volumeSoundUrl;

  /// The loaded music track.
  ///
  /// Currently, music tracks cannot be layered.
  Music music;

  void loadBuffer(
    String url,
    void Function(AudioBuffer) done
  ) {
    if (buffers.containsKey(url)){
      return done(buffers[url]);
    }
    final HttpRequest xhr = HttpRequest();
    xhr.responseType = 'arraybuffer';
    xhr.open('GET', url);
    xhr .onLoad.listen(
      (ProgressEvent e) async {
        try {
          final AudioBuffer buffer = await audioContext.decodeAudioData(xhr.response as ByteBuffer);
          buffers[url] = buffer;
          done(buffer);
        }
        catch(e) {
          throw 'Failed to get "$url": $e';
        }
      }
    );
    xhr.send();
  }

  Sound getSound(
    String url,
    {
      AudioNode output,
      OnEndedType onEnded,
      bool loop = false
    }
  ) {
    output ??= output;
    return Sound(this, url, output: output, onEnded: onEnded, loop: loop);
  }

  Sound playSound(
    String url,
    {
      AudioNode output,
      OnEndedType onEnded,
      bool loop = false
    }
  ) {
    output ??= audioContext.destination;
    final Sound sound = getSound(url, output: output, onEnded: onEnded, loop:loop);
    sound.play();
    return sound;
  }

  void adjustVolume(OutputTypes outputType, num adjust) {
    num start;
    if (outputType == OutputTypes.sound) {
      start = soundVolume;
    } else {
      start = musicVolume;
    }
    start += adjust;
    if (start < 0.0) {
      start = 0;
    } else if (start > 1.0) {
      start = 1.0;
    }
    if (volumeSoundUrl != null) {
      final GainNode output = audioContext.createGain();
      output.connectNode(audioContext.destination);
      output.gain.value = start;
      if (volumeSoundUrl != null) {
        playSound(volumeSoundUrl, output: output);
      }
    }
    setVolume(outputType, start);
  }

  void setVolume(OutputTypes outputType, num value) {
    AudioNode output;
    if (outputType == OutputTypes.sound) {
      soundVolume = value;
      output = soundOutput;
    } else {
      musicVolume = value;
      if (music != null) {
        output = music.gain;
      }
    }
    if (output != null) {
      (output as GainNode).gain.value = value;
    }
  }

  void volumeUp(OutputTypes outputType) {
    adjustVolume(outputType, volumeChangeAmount);
  }

  void volumeDown(OutputTypes outputType) {
    adjustVolume(outputType, -volumeChangeAmount);
  }
}

class Sound {
  Sound (
    this.pool,
    this.url,
    {
      this.output,
      this.onEnded,
      this.loop = false,
    }
  ) {
    output ??= pool.audioContext.destination;
    source = pool.audioContext.createBufferSource();
    if (onEnded != null) {
      source.onEnded.listen(onEnded);
    }
    source.loop = loop;
    source.connectNode(output);
  }

  final SoundPool pool;
  String url;
  bool loop;
  AudioNode output;
  AudioBuffer buffer;
  AudioBufferSourceNode source;
  OnEndedType onEnded;

  void playBuffer(AudioBuffer buf) {
    buffer = buf;
    if (source != null) {
      source.buffer = buffer;
      source.start(0);
    }
  }

  void stop() {
    if (source != null) {
      source.disconnect();
    }
    source = null;
    buffer = null;
  }

  void play() {
    if (buffer == null) {
      pool.loadBuffer(
        url, (AudioBuffer buffer) => playBuffer(buffer)
      );
    } else {
      playBuffer(buffer);
    }
  }
}
