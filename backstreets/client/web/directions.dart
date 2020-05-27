/// Provides the [Directions] enumeration, and the DirectionAdjustements class.
library directions;

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
