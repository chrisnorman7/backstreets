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
    soundOutput = audioContext.createGain()
      ..connectNode(output);
    musicOutput = audioContext.createGain()
      ..connectNode(output);
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

  /// Load a buffer into the [buffers] map.
  void loadBuffer(String url, void Function(AudioBuffer) done) {
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

  /// Get a sound instance.
  ///
  /// If you are only planning to play the resulting sound, use [playSound] instead.
  Sound getSound(String url, {AudioNode output, OnEndedType onEnded, bool loop = false}) {
      output ??= soundOutput;
    return Sound(this, url, output, onEnded, loop);
  }

  /// Get a sound with [getSound], and play it.
  Sound playSound(String url, {AudioNode output, OnEndedType onEnded, bool loop = false}) {
    final Sound sound = getSound(url, output: output, onEnded: onEnded, loop:loop);
    sound.play();
    return sound;
  }

  /// Change the volume a bit.
  ///
  /// Used by [volumeUp], and [volumeDown].
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
      final GainNode output = audioContext.createGain()
        ..connectNode(audioContext.destination)
        ..gain.value = start;
      playSound(volumeSoundUrl, output: output);
    }
    setVolume(outputType, start);
  }

  /// Set the volume to an absolute value.
  ///
  /// Used by [adjustVolume].
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

  /// Turn the volume up by [volumeChangeAmount].
  void volumeUp(OutputTypes outputType) {
    adjustVolume(outputType, volumeChangeAmount);
  }

  /// Turn the volume down by [volumeChangeAmount].
  void volumeDown(OutputTypes outputType) {
    adjustVolume(outputType, -volumeChangeAmount);
  }
}

/// A sound object.
///
/// For ease of use, use [SoundPool.getSound], or [SoundPool.playSound] to create sounds.
class Sound {
  Sound (this.pool, this.url, this.output, this.onEnded, this.loop) {
    source = pool.audioContext.createBufferSource()
      ..loop = loop
      ..connectNode(output);
    if (onEnded != null) {
      source.onEnded.listen(onEnded);
    }
  }

  /// The interface for getting buffers and creating nodes.
  ///
  /// See [SoundPool] for more details.
  final SoundPool pool;

  /// The URL of the sound.
  String url;

  /// Whether or not [source] should loop.
  bool loop;

  /// The output to connect [source] to.
  AudioNode output;

  /// [source].buffer.
  AudioBuffer buffer;

  /// The node that actually plays audio.
  AudioBufferSourceNode source;

  /// The function to be called when [source] has finished playing.
  OnEndedType onEnded;

  /// Play an audio buffer.///
  /// Used by [play], by way of [SoundPool.getBuffer].
  void playBuffer(AudioBuffer buf) {
    buffer = buf;
    if (source != null) {
      source.buffer = buffer;
      source.start(0);
    } else {
      // Consider this sound stopped.
    }
  }

  /// Stop [source].
  void stop() {
    if (source != null) {
      source.disconnect();
    }
    source = null;
    buffer = null;
  }

  /// Play [source].
  ///
  /// Uses [SoundPool.getBuffer] to initialise [buffer] if needed.
  ///
  /// Uses [playBuffer] to actually play the buffer.
  void play() {
    if (buffer == null) {
      pool.loadBuffer(url, (AudioBuffer buffer) => playBuffer(buffer));
    } else {
      playBuffer(buffer);
    }
  }
}
