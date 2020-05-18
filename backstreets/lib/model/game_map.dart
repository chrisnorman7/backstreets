/// Provides map-related classes.
///
/// * [GameMap]
/// * [MapWall]
/// * [MapTile]
library game_map;

import 'package:aqueduct/aqueduct.dart';

import '../game/tile.dart';

import 'exit.dart';
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
  GameMap location;
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
  GameMap location;
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

/// The game_maps table.
///
/// If you want to work with maps directly, use the [GameMap] class.
@Table(name: 'game_maps')
class _GameMap with PrimaryKeyMixin, NameMixin {
  /// All the [GameObject] instances on this map.
  ManagedSet<GameObject> objects;

  /// All the [MapWall] instances on this map.
  ManagedSet<MapWall> walls;

  /// All the [MapTile] instances contained by this map.
  ManagedSet<MapTile> tiles;

  /// The convolver URL for this map.
  @Column(nullable: true)
  String convolverUrl;

  /// The volume of the convolver.
  @Column(defaultValue: '1.0')
  double convolverVolume;

  /// All the exits from this map.
  ManagedSet<Exit> exits;

  // All the entrances to this map.
  ManagedSet<Exit> entrances;

  /// The x coordinate where players should pop.
  @Column(defaultValue: '0.0')
  double popX = 0;

  /// The y coordinate where players should pop.
  @Column(defaultValue: '0.0')
  double popY = 0;
}

/// A map.
///
/// Maps contain tiles, walls, and objects.
class GameMap extends ManagedObject<_GameMap> implements _GameMap {
  /// Fille the map with tiles.
  ///
  /// ```
  /// final GameMap m = GameMap();
  /// m.fillSize(datebaseContext, x: 200, y: 200, tile: tiles[0]);
  /// ```
  Future<void> fillSize(ManagedContext ctx, int x, int y, Tile tile) async {
    await ctx.transaction((ManagedContext transaction) async {
      for (double i = 0; i < x; i++) {
        for (double j = 0; j < y; j++) {
          await addTile(transaction, i, j, tile);
        }
      }
    });
  }

  /// Add a tile to this map at the given coordinates.
  ///
  /// ```dart
  /// // Add 2 tiles to this map.
  /// await map.addTile(databaseContext, 5, 5, tiles[1]);
  /// await map.addTile(databaseContext, 6, 5, tiles[1]);
  /// ```
  Future<MapTile> addTile(ManagedContext ctx, double x, double y, Tile tile) async {
    final Query<MapTile> q = Query<MapTile>(ctx)
    ..values.tileName = tile.name
    ..values.location = this
    ..values.x = x
    ..values.y = y;
    return await q.insert();
  }

  @override
  String toString() {
    return '<Map $name (#$id)>';
  }
}
