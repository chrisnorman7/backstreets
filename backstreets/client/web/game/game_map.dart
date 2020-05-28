/// Provides the [GameMap] class.
library game_map;

import 'dart:math';

import 'package:game_utils/game_utils.dart';

import '../main.dart';

import 'convolver.dart';
import 'map_section.dart';

/// A map in the game.
class GameMap {
  GameMap(this.name) {
    convolver = Convolver(commandContext.sounds, null, 1.0);
  }

  /// The name of this map.
  String name;

  /// The ambience of this map.
  String ambienceUrl;

  /// The ambience to play.
  Sound ambience;

  /// The default convolver for this map.
  ///
  /// Will be used when the current [MapSection] has no convolver set.
  Convolver convolver;

  /// Every section on this map.
  Map<int, MapSection> sections = <int, MapSection>{};

  /// Every tile on this map.
  Map<Point<int>, String> tiles = <Point<int>, String>{};
}
