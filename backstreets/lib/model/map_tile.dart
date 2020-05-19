/// Provides the [MapTile] class.
library map_tile;

import 'package:aqueduct/aqueduct.dart';

import '../game/tile.dart';

import 'game_map.dart';
import 'mixins.dart';

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
