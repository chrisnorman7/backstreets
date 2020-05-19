/// Provides the [GameMap] class.
library game_map;

import 'package:aqueduct/aqueduct.dart';

import 'exit.dart';
import 'game_object.dart';
import 'map_section.dart';
import 'map_tile.dart';
import 'map_wall.dart';
import 'mixins.dart';

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

  /// All the exits from this map.
  ManagedSet<Exit> exits;

  // All the entrances to this map.
  ManagedSet<Exit> entrances;

  /// All the [MapSection] instances on this map.
  ManagedSet<MapSection> sections;

  /// The convolver URL for this map.
  @Column(nullable: true)
  String convolverUrl;

  /// The volume of the convolver.
  @Column(defaultValue: '1.0')
  double convolverVolume;

  /// The x coordinate where players should pop.
  @Column(defaultValue: '0.0')
  double popX = 0;

  /// The y coordinate where players should pop.
  @Column(defaultValue: '0.0')
  double popY = 0;
}

/// A map.
///
/// Maps contain sections, tiles, walls, and objects.
class GameMap extends ManagedObject<_GameMap> implements _GameMap {
  @override
  String toString() {
    return '<Map $name (#$id)>';
  }
}
