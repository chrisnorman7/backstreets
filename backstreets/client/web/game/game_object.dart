/// Provides the classes that make up game objects, as sent by the server.
library game_object;

import 'dart:math';

import '../constants.dart';

/// Store account information for a [GameObject] instance.
class Account {
  /// Create an account.
  Account(this.id, this.username);

  /// The id of this account.
  int id;

  /// This account's username.
  String username;
}

/// The permissions for a [GameObject].
class Permissions {
  Permissions({this.builder = false, this.admin = false});

  /// Whether or not this player is a builder.
  bool builder;

  /// Whether or not this player is an admin.
  bool admin;

  /// Whether or not this player is a staff member.
  bool get staff {
    return admin == true || builder == true;
  }
}

/// A player object.
///
/// As created by the [playerList] command.
class GameObject {
  /// Create a player or other object.
  GameObject(this.id, this.name, this.coordinates, this.locationId, this.locationName, this.permissions, this.account, this.ownerId, this.ownerName, this.connectionName, this.secondsInactive, this.lastActive);

  /// The id of the Character.
  int id;

  /// The name of this player (called a character on the server side).
  String name;

  /// The coordinates where this object is located.
  Point<double> coordinates;

  /// The permissions for this account.
  Permissions permissions;

  /// The account this object is connected to.
  Account account;

  /// The minimum time between object moves.
  int speed;

  /// The maximum time between object moves.
  int maxMoveTime;

  /// The phrase directory used by this object.
  String phrase;

  /// The minimum phrase time.
  int minPhraseTime;

  /// The maximum phrase time.
  int maxPhraseTime;

  /// Whether or not this object is airborn.
  bool flying;

  /// The chance this object has of using an exit.
  int useExitChance;

  /// Whether or not this object can leave the current map.
  bool canLeaveMap;

  //// Whether or not this object is connected.
  String connectionName;

  /// How many seconds this player has been inactive.
  int secondsInactive;

  /// How long it has been since this object was active on the server.
  String lastActive;

  /// A list of [Player] objects who are also connected to this account.
  List<GameObject> get relatedObjects => commandContext.objects.where((GameObject o) => o.account?.id == account?.id && o.id != id).toList();

  /// The id of the map this object is on.
  int locationId;

  /// The name of this map this object is on.
  String locationName;

  /// The owner of this object.
  int ownerId;

  /// The name of the object that owns this object.
  String ownerName;

  /// Return a name and an object number.
  @override
  String toString() => '$name (#$id) [$locationName ${coordinates.x.toStringAsFixed(2)}, ${coordinates.y.toStringAsFixed(2)}]';

  /// Return this object as a map, so it can be sent to the server.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'x': coordinates.x,
      'y': coordinates.y,
      'admin': permissions?.admin,
      'speed': speed,
      'maxMoveTime': maxMoveTime,
      'phrase': phrase,
      'minPhraseTime': minPhraseTime,
      'maxPhraseTime': maxPhraseTime,
      'flying': flying,
      'useExitChance': useExitChance,
      'canLeaveMap': canLeaveMap,
      'locationId': locationId,
      'ownerId': ownerId,
      'ownerName': ownerName,
    };
  }
  }
