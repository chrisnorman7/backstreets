/// Provides the [PlayerOptions] class.
library player_options;

import 'package:aqueduct/aqueduct.dart';

import 'game_object.dart';
import 'mixins.dart';

/// The player_options table.
///
/// To work with player options directly, see the [PlayerOptions] class.
@Table(name: 'player_options')
class _PlayerOptions with PrimaryKeyMixin {
  /// The object this object is bound to.
  @Relate(#options, onDelete: DeleteRule.cascade)
  GameObject object;

  /// Sound volume.
  @Column(defaultValue: '0.75')
  double soundVolume;

  // Ambience volume.
  @Column(defaultValue: '0.75')
  double ambienceVolume;
}

/// A class to hold player options.
class PlayerOptions extends ManagedObject<_PlayerOptions> implements _PlayerOptions {}
