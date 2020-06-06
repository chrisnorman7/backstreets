/// Provides the [GameMap] class.
library game_map;

import 'dart:math';

import '../main.dart';
import 'ambience.dart';
import 'convolver.dart';
import 'exit.dart';
import 'map_section.dart';
import 'wall.dart';

/// A map in the game.
class GameMap {
  GameMap(this.id, this.name) {
    convolver = Convolver(commandContext.sounds, null, 1.0);
  }

  /// The id of this map.
  int id;

  /// The name of this map.
  String name;

  /// The ambience of this map.
  Ambience ambience;

  /// The default convolver for this map.
  ///
  /// Will be used when the current [MapSection] has no convolver set.
  Convolver convolver;

  /// Every section on this map.
  Map<int, MapSection> sections = <int, MapSection>{};

  /// Every wall on this map.
  Map<Point<int>, Wall> walls = <Point<int>, Wall>{};

  /// Every exit on this map.
  Map<int, Exit> exits = <int, Exit>{};

  /// Stop all sounds on this map.
  ///
  /// This function will run through [sections], and stop all ambiences, and disconnect all nodes.
  ///
  /// It will also stop [ambience].
  void stop() {
    ambience.sound?.stop();
    sections.forEach((int id, MapSection s) => s.ambience?.sound?.stop());
  }
}
