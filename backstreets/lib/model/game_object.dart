/// Provides the [GameObject] class.
library game_object;

import 'dart:math';

import 'package:aqueduct/aqueduct.dart';
import 'package:emote_utils/emote_utils.dart';

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

  /// The number of times this object has moved.
  @Column(defaultValue: '0', nullable: false)
  int steps;

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
  /// Get the coordinates of this object.
  Point<double> get coordinates => Point<double>(x, y);

  /// Get the staff status of this object.
  ///
  /// An object is considered a member of staff if it is either a builder or an admin.
  bool get staff => admin || builder;

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
    return commandContext?.message(text);
  }

  /// Tell the connected player to play a sound.
  ///
  /// If coordinates are given, the sound will be heard there. If not, then coordinates will be made from [x] and [y].
  void sound(Sound s, {Point<double> coordinates, double volume}) {
    coordinates ??= Point<double>(x, y);
    volume ??= 1.0;
    commandContext?.sendSound(s, coordinates, volume);
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
    final Map<int, String> strings = <int, String>{};
    final SocialContext<GameObject> sctx = socials.getStrings(social, perspectives);
    sctx.targetedStrings.forEach((GameObject o, String s) {
      strings[o.id] = s;
    });
    for (final GameObject obj in observers) {
      if (sound != null) {
        obj.sound(sound, coordinates: Point<double>(x, y));
      }
      String m = sctx.defaultString;
      if (strings.containsKey(obj.id)) {
        m = strings[obj.id];
      }
      obj.message(m);
  }
  }

  @override
  String toString() {
    return '<Object $name (#$id)>';
  }

  @override
  void willInsert() {
    createdAt = DateTime.now().toUtc();
  }

  /// Get the total duration this object has been connected for.
  Future<Duration> connectedDuration(ManagedContext db) async {
    final Query<ConnectionRecord> q = Query<ConnectionRecord>(db)
      ..where((ConnectionRecord r) => r.object).identifiedBy(this);
    final List<ConnectionRecord> records = await q.fetch();
    Duration d = const Duration();
    for (final ConnectionRecord r in records) {
      d += r.duration;
    }
    return d;
  }

  /// Teleport this object to another map.
  ///
  /// Used by both staff commands, and the more prosaic `exit` command.
  Future<void> move(ManagedContext db, GameMap destination, double destinationX, double destinationY) async {
    final Query<GameObject> q = Query<GameObject>(db)
      ..values.location = destination
      ..values.x = destinationX
      ..values.y = destinationY
      ..where((GameObject o) => o.id).equalTo(id);
    final GameObject o = await q.updateOne();
    final CommandContext ctx = o.commandContext;
    if (ctx != null) {
      ctx.map = destination;
      await ctx.sendMap();
      ctx.send('characterCoordinates', <double>[o.x, o.y]);
    }
  }
}
