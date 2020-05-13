import 'dart:math';

import 'sound.dart';
import 'tile.dart';

/// Specifies the possible wall types.
enum WallTypes {
  /// A wall that cannot be passed through, or fired over.
  wall,
  /// A wall that cannot be passed through, but can be fired over.
  barricade
}

/// A map.
///
/// Maps contain both tiles and walls. Use the [fromSize] constructor to make a map with all tiles pre-populated.
/// Use [addTile] to add a tile, and [addWall] to add a wall.
/// All coordinates are specified as [Point]s from the dart:math library.
class GameMap {
  /// Used to create a map which is pre-populated with tiles.
  GameMap.fromSize({int x, int y, Tile tile}) {
    for (int i = 0; i < x; i++) {
      for (int j = 0; j < y; j++) {
        addTile(Point<int>(i, j), tile);
      }
    }
  }

  /// The [Map] of all tiles on this [GameMap].
  Map<Point<int>, Tile> tiles = <Point<int>, Tile>{};

  /// The [Map] of all walls on this [GameMap], given as [WallTypes].
  Map<Point<int>, WallTypes> walls = <Point<int>, WallTypes>{};

  /// The convolver for this [GameMap].
  Sound convolver = Sound();

  /// Add a tile to this map at the given coordinates.
  void addTile(Point<int> coordinates, Tile tile) {
    tiles[coordinates] = tile;
  }
}
