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

  // Music volume.
  @Column(defaultValue: '0.50')
  double musicVolume;

  /// The distance that echo location should work at.
  @Column(defaultValue: '50')
  int echoLocationDistance;

  /// The distance multiplier for echo location.
  ///
  /// This number will be multiplied by the distance between a character and an object, to get the time delay before the echo sound is played.
  @Column(defaultValue: '20')
  int echoLocationDistanceMultiplier;

  /// The default echo sound.
  @Column(defaultValue: "'clack'")
  String echoSound;

  /// The elevation of "airborn" sounds.
  @Column(defaultValue: '5')
  int airbornElevate;

  /// How much sounds on the other side of walls should be filtered.
  @Column(defaultValue: '9000')
  int wallFilterAmount;

  /// The mouse sensitivity.
  @Column(defaultValue: '5')
  int mouseSensitivity;

  /// Whether or not this object wants to hear about new connections.
  @Column(defaultValue: 'true')
  bool connectNotifications;

  /// Whether or not this object wants to hear about connections dropping.
  @Column(defaultValue: 'true')
  bool disconnectNotifications;
}

/// A class to hold player options.
class PlayerOptions extends ManagedObject<_PlayerOptions> implements _PlayerOptions {}
