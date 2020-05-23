/// Provides the [MapSection] class.
library map_section;

import 'dart:math';

/// A section of a map.
///
/// Basically rectangles, with a name, and a tile type.
class MapSection {
  MapSection(this.id, this.startX, this.startY, this.endX, this.endY, this.name, this.tileName, this.tileSize);

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
      'startX': startCoordinates.x,
      'startY': startCoordinates.x,
      'endX': endCoordinates.x,
      'endY': endCoordinates.y,
      'name': name,
      'tileName': tileName,
      'tileSize': tileSize
    };
  }
}
