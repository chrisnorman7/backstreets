/// Provides the [GameObject] class.
library game_object;

import 'package:aqueduct/aqueduct.dart';

import 'account.dart';
import 'game_map.dart';
import 'mixins.dart';

/// The objects table.
///
/// To deal with game objects directly, use the [GameObject] class instead.
class _GameObject with PrimaryKeyMixin, CoordinatesMixin, NameMixin {
  /// The location of this object.
  @Relate(#objects)
  GameMap location;
  
  /// The account that is bound to this object.
  @Relate(#objects)
  Account account;
}

/// An object in a game. Contained by a [GameMap] instance.
class GameObject extends ManagedObject<_GameObject> implements _GameObject {}
