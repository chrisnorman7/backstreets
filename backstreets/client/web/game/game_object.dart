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

/// The permissions for a [Player] object.
class Permissions {
  Permissions({this.builder = false, this.admin = false});

  /// Whether or not this player is a builder.
  bool builder;

  /// Whether or not this player is an admin.
  bool admin;
}

/// A player object.
///
/// As created by the [playerList] command.
class GameObject {
  /// Create a player.
  GameObject(this.id, this.name, this.coordinates, this.locationId, this.locationName, this.permissions, this.account);

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

  /// A list of [Player] objects who are also connected to this account.
  List<GameObject> get relatedObjects => commandContext.objects.where((GameObject o) => o.account?.id == account?.id && o.id != id).toList();

  /// The id of the map this object is on.
  int locationId;

  /// The name of this map this object is on.
  String locationName;

  /// Return a name and an object number.
  @override
  String toString() => '$name (#$id)';
}
