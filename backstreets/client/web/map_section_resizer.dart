/// Provides the [MapSectionResizer] class.
library map_section_resizer;

import 'dart:math';
import 'map_section.dart';

/// The coordinates that are being dragged.
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
