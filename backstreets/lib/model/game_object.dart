/// Provides the [GameObject] class.
library game_object;

import 'dart:math';

import 'package:aqueduct/aqueduct.dart';

import '../commands/command_context.dart';
import '../game/tile.dart';
import '../game/util.dart';
import '../sound.dart';
import 'account.dart';
import 'builder_permission.dart';
import 'connection_record.dart';
import 'game_map.dart';
import 'map_section.dart';
import 'mixins.dart';
import 'player_options.dart';
import 'radio.dart';

/// The game_objects table.
///
/// To deal with game objects directly, use the [GameObject] class instead.
@Table(name: 'game_objects')
class _GameObject with PrimaryKeyMixin, DoubleCoordinatesMixin, NameMixin, AmbienceMixin, AdminMixin {
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

  /// Used to find out what [GameMap]s this object can build on.
  ManagedSet<BuilderPermission> builderPermissions;

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

  /// The maximum time between NPC moves.
  @Column(nullable: true)
  int maxMoveTime;

  /// When this object was first created.
  @Column(defaultValue: "'2020-01-01'")
  DateTime createdAt;

  /// The social which is used when this object connects to the game.
  @Column(defaultValue: "'%1N %1has connected.'")
  String connectSocial;

  /// The social which is used when this object disconnects from the game.
  @Column(defaultValue: "'%1N %1has disconnected.'")
  String disconnectSocial;

  /// The phrase directory used by this object.
  ///
  /// Set to null for no phrase.
  @Column(nullable: true)
  String phrase;

  /// The minimum time (in milliseconds) between phrases.
  @Column(defaultValue: '15000')
  int minPhraseTime;

  /// The maximum amount of time (in milliseconds) between phrases.
  @Column(defaultValue: '60000')
  int maxPhraseTime;

  /// Whether or not this object is airborn.
  @Column(defaultValue: 'false')
  bool flying;

  /// The chance this object has of using exits.
  ///
  /// Change to 0 to prevent them from using exits.
  @Column(nullable: true)
  int useExitChance;

  /// Whether or not this object can leave the current map.
  @Column(defaultValue: 'false')
  bool canLeaveMap;

  /// Whether or not this object is connected.
  @Column(nullable: true)
  String connectionName;

  /// The object that owns this object.
  @Relate(#ownedObjects)
  GameObject owner;

  /// All the objects this object owns.
  ManagedSet<GameObject> ownedObjects;

  /// The radio channel this object is currently listening and transmitting on.
  @Relate(#listeners)
  RadioChannel radioChannel;

  /// Whether or not this object can transmit on radio channels.
  @Column(defaultValue: 'true')
  bool canTransmit;

  /// The messages this object has transmitted.
  ManagedSet<RadioTransmission> radioTransmissions;
}

/// An object in a game. Contained by a [GameMap] instance.
class GameObject extends ManagedObject<_GameObject> implements _GameObject {
  /// The command contexts that are logged in with characters.
  static Map<int, CommandContext> commandContexts = <int, CommandContext>{};

  /// Get the coordinates of this object.
  Point<double> get coordinates => Point<double>(x, y);

  /// See if there is a builder permission for this object.
  Future<BuilderPermission> getBuilderPermission(ManagedContext db, [GameMap m]) async {
    m ??= location;
    final Query<BuilderPermission> q = Query<BuilderPermission>(db)
      ..where((BuilderPermission p) => p.object).identifiedBy(id)
      ..where((BuilderPermission p) => p.location).identifiedBy(location.id);
    return q.fetchOne();
  }

  /// Returns true if this object can build on [where], flase otherwise.
  ///
  /// If [where] is null, [location] is used instead.
  Future<bool> canBuild(ManagedContext db, [GameMap where]) async {
    if ((await getBuilderPermission(db, where)) == null) {
      return false;
    }
    return true;
  }

  /// Get the staff status of this object.
  ///
  /// An object is considered a member of staff if it is either a builder or an admin.
  Future<bool> getStaff(ManagedContext db) async {
    if (admin) {
      return true;
    }
    if (await getBuilderPermission(db) != null) {
      return true;
    }
    return false;
  }

  /// Get the command context which is connected to this object.
  ///
  /// If no player is connected to this object, null is returned.
  CommandContext get commandContext {
    return commandContexts[id];
  }

  /// Send a message to the socket which this object is connected to.
  void message(String text) {
    return commandContext?.message(text);
  }

  /// Tell the connected player to play a sound.
  ///
  /// If coordinates are given, the sound will be heard there. If not, then coordinates will be made from [x] and [y].
  void sound(Sound s, {Point<double> coordinates, double volume, int id}) {
    coordinates ??= Point<double>(x, y);
    volume ??= 1.0;
    commandContext?.sendSound(s, coordinates, volume: volume, id: id);
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
      ..where((ConnectionRecord r) => r.object).identifiedBy(id);
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
  Future<GameObject> move(ManagedContext db, double destinationX, double destinationY, {GameMap destination, bool silent = false}) async {
    final Query<GameObject> q = Query<GameObject>(db)
      ..values.x = destinationX
      ..values.y = destinationY
      ..values.steps = steps + 1
      ..where((GameObject o) => o.id).equalTo(id);
    if (destination != null) {
      q.values.location = destination;
    }
    final GameObject o = await q.updateOne();
    final CommandContext ctx = o.commandContext;
    if (ctx != null) {
      if (destination != null) {
        ctx.map = destination;
        await ctx.sendMap();
      }
      if (!silent) {
        ctx.send('characterCoordinates', <double>[o.x, o.y]);
      }
    }
    final GameMap m = await db.fetchObjectWithID<GameMap>(o.location.id);
    final MapSection s = await m.getCurrentSection(db, Point<int>(o.x.floor(), o.y.floor()));
    if (s != null && !flying) {
      final Tile t = tiles[s.tileName];
      await o.location.broadcastSound(db, randomElement<Sound>(t.footstepSounds), o.coordinates, objectId: o.id, excludeIds: <int>[o.id]);
    }
    await m.broadcastMove(db, o.id, o.x, o.y);
    return o;
  }

  /// Return the coordinates in the direction this object is currently facing.
  ///
  /// The distance argument should probably be gotten from the tile size of the current section.
  Point<double> coordinatesInDirection(double distance) {
    final double rads = theta / 180.0 * pi;
    return Point<double>(x + (distance * sin(rads)), y + (distance * cos(rads)));
  }

  /// Perform a social.
  Future<void> doSocial(ManagedContext db, String social, {Sound sound, List<GameObject> others}) async {
    final List<GameObject> perspectives = <GameObject>[this];
    if (others != null) {
      others.forEach(perspectives.add);
    }
    await location.handleSocial(db, social, perspectives, sound: sound);
  }

  /// Convert this object to json.
  ///
  /// Used for sending to a connection.
  Future<Map<String, dynamic>> toJson(ManagedContext db) async {
    Duration lastActive;
    int secondsInactive;
    if (commandContext != null && commandContext.lastActive != null) {
      lastActive = DateTime.now().difference(commandContext.lastActive);
      secondsInactive = lastActive.inSeconds;
    }
    return <String, dynamic>{
      'id': id,
      'name': name,
      'x': x,
      'y': y,
      'locationId': location.id,
      'locationName': location.name,
      'speed': speed,
      'maxMoveTime': maxMoveTime,
      'phrase': phrase,
      'minPhraseTime': minPhraseTime,
      'maxPhraseTime': maxPhraseTime,
      'flying': flying,
      'admin': admin,
      'builder': await canBuild(db),
      'accountId': account?.id,
      'username': account?.username,
      'useExitChance': useExitChance,
      'canLeaveMap': canLeaveMap,
      'ownerId': owner?.id,
      'ownerName': owner?.name,
      'connectionName': connectionName,
      'secondsInactive': secondsInactive,
      'lastActive': lastActive == null ? null : formatDuration(lastActive, suffix: ' ago', noTime: 'Active now'),
    };
  }

  /// Notify all connected admins of something.
  static Future<void> notifyAdmins(ManagedContext db, String message, {Sound sound, Future<bool> Function(GameObject) filterFunc}) async {
    final Query<GameObject> q = Query<GameObject>(db)
      ..where((GameObject o) => o.connectionName).isNotNull()
      ..where((GameObject o) => o.admin).equalTo(true);
    for (final GameObject o in await q.fetch()) {
      if (filterFunc != null && !(await filterFunc(o))) {
        continue;
      }
      final CommandContext ctx = commandContexts[o.id];
      if (ctx != null) {
        ctx.message(message);
        if (sound != null) {
          ctx.sendInterfaceSound(sound);
        }
      }
    }
  }
}
