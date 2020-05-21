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

/// A section which the player is currently creating.
///
/// Once both corners have been specified, it will be uploaded.
class CreatedMapSection {
  /// Create with a name.
  ///
  /// All other info should be filled in from the menu.
  CreatedMapSection(this.name);

  /// The name of the default tile.
  String tileName;

  /// The name of this section.
  String name;

  /// The start coordinates of this section.
  Point<int> startCoordinates;

  /// The end coordinates of this section.
  Point<int> endCoordinates;

  /// Convert this section to a map, for sending to the server.
  Map<String, dynamic> asMap() {
    return <String, dynamic>{
      'tileName': tileName,
      'name': name,
      'startX': startCoordinates.x,
      'startY': startCoordinates.x,
      'endX': endCoordinates.x,
      'endY': endCoordinates.y
    };
  }
}
