/// Provides the [MapSection], and [MapSectionResizer] classes.
library map_section;

import 'dart:math';

import 'package:game_utils/game_utils.dart';

import 'convolver.dart';

/// A section of a map.
///
/// Basically rectangles, with a name, and a tile type.
class MapSection {
  MapSection(SoundPool sounds, this.id, this.startX, this.startY, this.endX, this.endY, this.name, this.tileName, this.tileSize, String convolverUrl, double convolverVolume) {
    convolver = Convolver(sounds, convolverUrl, convolverVolume);
  }

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

  /// The convolver for this map section.
  Convolver convolver;

  /// The bounding coordinates.
  Rectangle<int> get rect => Rectangle<int>.fromPoints(startCoordinates, endCoordinates);

  /// The start coordinates of this section.
  Point<int> get startCoordinates => Point<int>(startX, startY);

  /// The end coordinates of this section.
  Point<int> get endCoordinates => Point<int>(endX, endY);

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
      'convolverUrl': convolver.compactUrl,
      'convolverVolume': convolver.volume.gain.value,
    };
  }

  /// Get the area of [rect].
  int get area => rect.width * rect.height;

  /// Get the size of this section as text.
  String get textSize => '${rect.width + 1} x ${rect.height + 1}';
}

/// When working with [MapSectionResizer] instances, dictates which coordinates should be dragged.
enum DragCoordinates {
  /// Maps to [MapSection.startCoordinates].
  start,

  /// Maps to [MapSection.endCoordinates].
  end,
}

/// Used to resize a [MapSection] instance.
///
/// ```
/// MapSectionResizer(s, DragCoordinates.start);
///```
class MapSectionResizer {
  ///Create an instance.
  /// The [section] argument is the `MapSection` instance to drag.
  ///
  /// The [coordinatesType] argument describes which coordinates you want to move.
  MapSectionResizer(this.section, this.coordinatesType) {
    defaultCoordinates = coordinates;
  }

  /// The section to work on.
  final MapSection section;

  /// Which coordinates to work on.
  final DragCoordinates coordinatesType;

  /// The default coordinates before any resizing has happened.
  Point<int> defaultCoordinates;

  /// Get the coordinates the resizer should be working on.
  Point<int> get coordinates {
    if (coordinatesType == DragCoordinates.start) {
      return section.startCoordinates;
    }
    return section.endCoordinates;
  }

  /// get the coordinates the resizer shouldn't be working on.
  Point<int> get otherCoordinates {
    if (coordinatesType == DragCoordinates.start) {
      return section.startCoordinates;
    }
    return section.endCoordinates;
  }

  /// Used to set the coorect coordinates.
  void updateCoordinates(Point<int> coordinates) {
    if (coordinatesType == DragCoordinates.start) {
      section.startX = coordinates.x;
      section.startY = coordinates.y;
    } else {
      section.endX = coordinates.x;
      section.endY = coordinates.y;
    }
  }
}