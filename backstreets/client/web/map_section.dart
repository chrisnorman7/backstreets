/// Provides the [MapSection] class.
library map_section;

import 'dart:math';

/// A section of a map.
///
/// Basically rectangles, with a name, and a tile type.
class MapSection {
  MapSection(this.id, int startX, int startY, int endX, int endY, this.name, this.tileName) {
    rect = Rectangle<int>.fromPoints(Point<int>(startX, startY), Point<int>(endX, endY));
  }

  /// The id of this section.
  int id;

  /// The bounding coordinates.
  Rectangle<int> rect;

  /// The human readable name.
  String name;

  /// The tile type.
  String tileName;
}