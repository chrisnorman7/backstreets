/// Provides the [WallTypes] enumeration, and the [Wall] class.
library map_wall;

import 'package:aqueduct/aqueduct.dart';

import 'game_map.dart';
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
class _MapWall with PrimaryKeyMixin, IntCoordinatesMixin {
  WallTypes wallType;

  /// The map this wall is part of.
  @Relate(#walls, isRequired: true, onDelete: DeleteRule.cascade)
  GameMap location;
}

/// A wall on a map.
class MapWall extends ManagedObject<_MapWall> implements _MapWall {}
