/// Provides the [MapSection] class.
library map_section;

import 'dart:math';
import 'dart:web_audio';

import 'package:game_utils/game_utils.dart';

import 'constants.dart';

/// A section of a map.
///
/// Basically rectangles, with a name, and a tile type.
class MapSection {
  MapSection(this.sounds, this.id, this.startX, this.startY, this.endX, this.endY, this.name, this.tileName, this.tileSize, this.convolverUrl, double _convolverVolume) {
    convolverVolume = sounds.audioContext.createGain()
      ..gain.value = _convolverVolume
      ..connectNode(sounds.output);
    output = sounds.audioContext.createGain()
      ..connectNode(sounds.soundOutput);
    resetConvolver();
  }

  /// The soundpool this section will use to create its outputs.
  SoundPool sounds;

  /// The id of this section.
  int id;

  /// The starting x coordinate.
  int startX;

  /// The starting y coordinate.
  int startY;

  /// The ending x coordinate.
  int endX;

  /// The ending y coordinate.
  int endY;

  /// The human readable name.
  String name;

  /// The tile type.
  String tileName;

  /// The tilesize. Set by the [tileSize] command.
  double tileSize;

  /// The convolver URL.
  String convolverUrl;

  /// The output for this map section.
  ///
  /// When the convolver (if any) has been loaded, this node will be connected to it.
  GainNode output;

  /// The convolver for this section.
  ConvolverNode convolver;

  /// The volume for [convolver].
  GainNode convolverVolume;

  /// The bounding coordinates.
  Rectangle<int> get rect => Rectangle<int>.fromPoints(startCoordinates, endCoordinates);

  /// The start coordinates of this section.
  Point<int> get startCoordinates => Point<int>(startX, startY);

  /// The end coordinates of this section.
  Point<int> get endCoordinates => Point<int>(endX, endY);

  /// Get [convolverUrl] without the sounds directory, or get params.
  String get compactConvolverUrl {
    if (convolverUrl != null) {
      int start = 0, end;
      if (convolverUrl.startsWith(soundsDirectory)) {
        start = soundsDirectory.length;
      }
      if (convolverUrl.contains('?')) {
        end = convolverUrl.indexOf('?');
      }
      return convolverUrl.substring(start, end);
    }
    return null;
  }

  /// Convert this section to a map.
  ///
  /// Used when uploading new sections.
  Map<String, dynamic> asMap() {
    return <String, dynamic>{
      'id': id,
      'startX': startX,
      'startY': startY,
      'endX': endX,
      'endY': endY,
      'name': name,
      'tileName': tileName,
      'tileSize': tileSize,
      'convolverUrl': compactConvolverUrl,
      'convolverVolume': convolverVolume.gain.value,
    };
  }

  /// Get the area of [rect].
  int get area => rect.width * rect.height;

  /// Get the size of this section as text.
  String get textSize => '${rect.width + 1} x ${rect.height + 1}';

  /// Set the convolver for this section.
  void resetConvolver() {
    if (convolver != null) {
      convolver.disconnect();
      convolver = null;
    }
    if (convolverUrl != null) {
      sounds.loadBuffer(convolverUrl.startsWith(soundsDirectory) ? convolverUrl : '$soundsDirectory$convolverUrl', (AudioBuffer buffer) {
        // only do something if convolver is still null.
        //
        // Otherwise, the convolver might have changed since this function was called, and we don't want to change it again.
        if (convolver == null) {
          convolver = sounds.audioContext.createConvolver()
            ..buffer = buffer
            ..connectNode(convolverVolume);
          output.connectNode(convolver);
        }
      });
    }
  }
}
