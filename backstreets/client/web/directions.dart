/// Provides the [Directions] enumeration, and the DirectionAdjustements class.
library directions;

import 'package:game_utils/game_utils.dart';

/// A set of directions.
///
/// Used when resizing or moving a [MapSection] instance.
enum Directions {
  west,
  east,
  north,
  south,
}

/// Used for adjusting coordinates.
class DirectionAdjustments {
  /// Create an instance.
  DirectionAdjustments(Directions direction) {
    switch(direction) {
      case Directions.west:
        x = -1;
        break;
      case Directions.east:
        x = 1;
        break;
      case Directions.north:
        y = -1;
        break;
      case Directions.south:
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
  RelativeDirections(this.east, this.north);

  /// The distance to the east.
  int east;

  /// The distance to the north.
  int north;

  @override
  String toString() {
    final List<String> directions = <String>[];
    if (east != 0) {
      directions.add('${east.abs()} ${east > 0 ? "east" : "west"}');
    }
    if (north != 0) {
      directions.add('${north.abs()} ${north > 0 ? "south" : "north"}');
    }
    return englishList(directions, emptyString: 'Here');
  }
}
