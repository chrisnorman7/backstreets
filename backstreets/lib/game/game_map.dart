/// Provides the [GameMap] class.
library game_map;

import 'dart:math';

import '../util.dart';

import 'dump_util.dart';
import 'game_object.dart';
import 'sound.dart';
import 'tile.dart';

/// Specifies the possible wall types.
enum WallTypes {
  /// A wall that cannot be passed through, or fired over.
  wall,
  /// A wall that cannot be passed through, but can be fired over.
  barricade
}

/// Map ids to [GameMap] instances.
Map<String, GameMap> maps = <String, GameMap>{};

/// A map.
///
/// Maps contain tiles, walls, and objects.
/// All coordinates are specified as [Point] instances.
class GameMap with DumpHelper {
  /// Create a standard map.
  GameMap() {
    name = 'Untitled Map';
    id = getId();
  }

  /// Used to create a map which is pre-populated with tiles.
  ///
  /// ```dart
  /// final GameMap m = GameMap.fromSize(x: 200, y: 200, tile: tiles[0]);
  /// ```
  GameMap.fromSize({int x, int y, Tile tile}) {
    name = '$x x $y Map';
    id = getId();
    for (int i = 0; i < x; i++) {
      for (int j = 0; j < y; j++) {
        addTile(Point<int>(i, j), tile);
      }
    }
  }

  /// The name of this map.
  @loadable
  @dumpable
  String name;

  /// The ID of this map.
  @loadable
  @dumpable
  String id;

  /// The [Map] of all [Tile] instances on this map.
  Map<Point<int>, Tile> tiles = <Point<int>, Tile>{};

  /// The [Map] of all [WallTypes] on this map.
  Map<Point<int>, WallTypes> walls = <Point<int>, WallTypes>{};

  /// The [Map] of all [GameObject] instances on this map.
  Map<Point<int>, GameObject> objects = <Point<int>, GameObject>{};

  /// The convolver for this map.
  Sound convolver = Sound();

  /// Add a tile to this map at the given coordinates.
  ///
  /// ```dart
  /// // Add 2 tiles to this map.
  /// map.addTile(Point<int>(5, 5), tiles[1]);
  /// map.addTile(Point<int>(6, 5), tiles[1]);
  /// ```
  void addTile(Point<int> coordinates, Tile tile) {
    tiles[coordinates] = tile;
  }
}
