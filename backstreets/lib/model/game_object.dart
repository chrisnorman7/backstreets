/// Provides the [GameObject] class.
library game_object;

import 'dart:math';

import 'package:aqueduct/aqueduct.dart';

import '../commands/command_context.dart';

import '../socials_factory.dart';

import '../sound.dart';

import 'account.dart';
import 'connection_record.dart';
import 'game_map.dart';
import 'mixins.dart';
import 'player_options.dart';

/// The game_objects table.
///
/// To deal with game objects directly, use the [GameObject] class instead.
@Table(name: 'game_objects')
class _GameObject with PrimaryKeyMixin, DoubleCoordinatesMixin, NameMixin, AmbienceMixin {
  /// The options for this object.
  PlayerOptions options;

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

  /// The direction this object is facing.
  @Column(defaultValue: '0.0')
  double theta;

  /// The minimum number of milliseconds between moves.
  @Column(defaultValue: '400')
  int speed;

  /// Whether or not this object is an admin.
  @Column(defaultValue: 'false')
  bool admin;

  /// Whether or not this object is a builder.
  @Column(defaultValue: 'false')
  bool builder;

  /// When this object was first created.
  @Column(defaultValue: "'2020-01-01'")
  DateTime createdAt;

  /// The social which is used when this object connects to the game.
  @Column(defaultValue: "'%1N %1has connected.'")
  String connectSocial;
}

/// An object in a game. Contained by a [GameMap] instance.
class GameObject extends ManagedObject<_GameObject> implements _GameObject {
  @override
  String toString() {
    return '<Object $name (#$id)>';
  }

  /// Get the command context which is connected to this object.
  ///
  /// If no player is connected to this object, null is returned.
  CommandContext get commandContext {
    final List<CommandContext> c = CommandContext.instances.where((CommandContext c) => c.characterId == id).toList();
    if (c.isNotEmpty) {
      return c.first;
    }
    return null;
  }

  /// Send a message to the socket which this object is connected to.
  void message(String text) {
    return commandContext?.sendMessage(text);
  }

  /// Tell the connected player to play a sound.
  ///
  /// If coordinates are given, the sound will be heard there. If not, then coordinates will be made from [x] and [y].
  void sound(Sound s, {Point<double> coordinates, double volume}) {
    coordinates ??= Point<double>(x, y);
    volume ??= 1.0;
    commandContext?.send('sound', <Map<String, dynamic>>[<String, dynamic>{
      'url': s.url,
      'x': coordinates.x,
      'y': coordinates.y,
      'volume': volume
    }]);
  }

  /// Have this object perform a social.
  Future<void> doSocial(
    ManagedContext db, String social, {
      List<GameObject> perspectives,
      List<GameObject> observers,
      Sound sound
    }
  ) async {
    if (observers == null) {
      final Query<GameObject> q = Query<GameObject>(db)
        ..where((GameObject o) => o.location).identifiedBy(location.id);
      observers = await q.fetch();
      perspectives ??= observers.where((GameObject o) => o.id == id).toList();
    }
    socials.getStrings(social, perspectives).dispatch(
      observers,
      (GameObject obj, String message) {
        if (sound != null) {
          obj.sound(sound, coordinates: Point<double>(x, y));
        }
        obj.message(message);
      }
    );
  }

  @override
  void willInsert() {
    createdAt = DateTime.now().toUtc();
  }
}
