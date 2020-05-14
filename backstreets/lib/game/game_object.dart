/// Provides the [GameObject] class.
library game_object;

import 'dart:io';
import 'dart:math';

import '../util.dart';

import 'dump_util.dart';
import 'game_map.dart';

/// Map ids to [GameObject] instances.
Map<String, GameObject> objects = <String, GameObject>{};

/// An object in a game. Contained by a [GameMap] instance.
class GameObject with DumpHelper {
  /// Create this object with a name.
  ///
  /// ```dart
  /// final GameObject g = GameObject('Soldier');
  /// ```
  GameObject(this.name) {
    id = getId();
  }

  /// The name of this object.
  @loadable
  @dumpable
  String name;

  /// The ID of this object.
  @loadable
  @dumpable
  String id;

  /// The location of this object.
  GameMap location;

  /// The coordinates of this object.
  Point<int> coordinates;

  /// The socket this object is connected to.
  WebSocket socket;
}
