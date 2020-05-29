/// Provides the [Directions] enumeration, and the DirectionAdjustements class.
library directions;

import 'package:game_utils/game_utils.dart';

/// A set of directions.
///
/// At the minute, only used when resizing a [MapSection].
enum Directions {
  left,
  right,
  up,
  down,
}

/// Used for adjusting coordinates.
class DirectionAdjustments {
  /// Create an instance.
  DirectionAdjustments(Directions direction) {
    switch(direction) {
      case Directions.left:
        x = -1;
        break;
      case Directions.right:
        x = 1;
        break;
      case Directions.up:
        y = -1;
        break;
      case Directions.down:
        y = 1;
        break;
      default:
        throw 'Unimplemented direction $direction.';
        break;
    }
  }

  /// The x adjustment.
  int x = 0;

  /// The y adjustment.
  int y = 0;
}

/// Describes the directions between 2 points.
class RelativeDirections {
  RelativeDirections(this.north, this.east);

  /// The distance to the north.
  int north;

  /// The distance to the east.
  int east;

  @override
  String toString() {
    final List<String> directions = <String>[];
    if (north != 0) {
      directions.add('${north.abs()} ${north > 0 ? "north" : "south"}');
    }
    if (east != 0) {
      directions.add('${east.abs()} ${east > 0 ? "east" : "west"}');
    }
    return englishList(directions);
  }
}
