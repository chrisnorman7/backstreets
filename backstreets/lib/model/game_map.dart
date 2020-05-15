/// Provides map-related classes.
///
/// * [GameMap]
/// * [MapWall]
/// * [MapTile]
library game_map;

import 'package:aqueduct/aqueduct.dart';

import '../game/tile.dart';

import 'game_object.dart';
import 'mixins.dart';

/// Specifies the possible wall types.
enum WallTypes {
  /// A wall that cannot be passed through, or fired over.
  wall,
  /// A wall that cannot be passed through, but can be fired over.
  barricade
}

/// The map_walls table.
///
/// To work with walls directly, use the [MapWall] class.
@Table(name: 'map_walls')
class _MapWall with PrimaryKeyMixin, CoordinatesMixin {
  WallTypes wallType;

  /// The map this wall is part of.
  @Relate(#walls, isRequired: true, onDelete: DeleteRule.cascade)
  GameMap map;
}

/// A wall on a map.
class MapWall extends ManagedObject<_MapWall> implements _MapWall {}

/// The map_tiles table.
///
/// If you want to work with tiles directly, use [MapTile] instead.
@Table(name: 'map_tiles')
class _MapTile with PrimaryKeyMixin, CoordinatesMixin {
  /// The name of the [Tile] instance.
  String tileName;

  /// The map this tile is part of.
  @Relate(#tiles, isRequired: true, onDelete: DeleteRule.cascade)
  GameMap map;
}

/// A tile on a map.
class MapTile extends ManagedObject<_MapTile> implements _MapTile {
  /// Convert [tileName] to an [Tile] instance.
  Tile get tile {
    return tiles[tileName];
  }

  /// Set [tileName] from a [Tile] instance.
  set tile(Tile t) {
    tileName = t.name;
  }
}

/// The maps table. If you want to work with maps directly, use the [GameMap] class.
@Table(name: 'maps')
class _GameMap with PrimaryKeyMixin, NameMixin {
  /// All the [GameObject] instances on this map.
  ManagedSet<GameObject> objects;

  /// All the [MapWall] instances on this map.
  ManagedSet<MapWall> walls;

  /// All the [MapTile] instances contained by this map.
  ManagedSet<MapTile> tiles;

  /// The convolver for this map.
  String convolverUrl;

  /// The volume of the convolver.
  double volume;
}

/// A map.
///
/// Maps contain tiles, walls, and objects.
class GameMap extends ManagedObject<_GameMap> implements _GameMap {
  /// Create an empty map.
  GameMap();

  /// Used to create a map which is pre-populated with tiles.
  ///
  /// ```dart
  /// final GameMap m = GameMap.fromSize(x: 200, y: 200, tile: tiles[0]);
  /// ```
  GameMap.fromSize({int x, int y, Tile tile}) {
    name = '$x x $y Map';
    for (double i = 0; i < x; i++) {
      for (double j = 0; j < y; j++) {
        addTile(i, j, tile);
      }
    }
  }

  /// Add a tile to this map at the given coordinates.
  ///
  /// ```dart
  /// // Add 2 tiles to this map.
  /// map.addTile(5, 5, tiles[1]);
  /// map.addTile(6, 5, tiles[1]);
  /// ```
  MapTile addTile(double x, double y, Tile tile) {
    final MapTile t = MapTile();
    t.tile = tile;
    t.map = this;
    t.x = x;
    t.y = y;
    return t;
  }
}
