/// Provides the [Exit] class.
library exit;

import 'package:aqueduct/aqueduct.dart';

import 'game_map.dart';
import 'mixins.dart';

/// The exits table. To deal with exits directly, use the [Exit] class instead.
@Table(name: 'exits')
class _Exit with PrimaryKeyMixin, NameMixin, IntCoordinatesMixin {
  @Relate(#exits)
  GameMap location;

  @Relate(#entrances)
  GameMap destination;

  /// The target x coordinate.
  double targetX;

  /// The target y coordinate.
  double targetY;
}

/// An exit between two maps.
///
/// Exits link maps, so that players can travel between them.
class Exit extends ManagedObject<_Exit> implements _Exit {}
