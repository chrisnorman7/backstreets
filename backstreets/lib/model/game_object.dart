/// Provides the [GameObject] class.
library game_object;

import 'package:aqueduct/aqueduct.dart';

import 'account.dart';
import 'connection_record.dart';
import 'game_map.dart';
import 'mixins.dart';

/// The game_objects table.
///
/// To deal with game objects directly, use the [GameObject] class instead.
@Table(name: 'game_objects')
class _GameObject with PrimaryKeyMixin, CoordinatesMixin, NameMixin {
  /// The location of this object.
  @Relate(#objects)
  GameMap location;

  /// The account that is bound to this object.
  @Relate(#objects)
  Account account;

  /// The connections which have been made to this object.
  ManagedSet<ConnectionRecord> connectionRecords;

  /// The number of times this object has died.
  ///
  /// It is unlikely this property will be used for NPC's, but players love to know their stats.
  @Column(defaultValue: '0', nullable: false)
  int deaths;
}

/// An object in a game. Contained by a [GameMap] instance.
class GameObject extends ManagedObject<_GameObject> implements _GameObject {

  @override
  String toString() {
    return '<Object $name (#$id)>';
  }
}
