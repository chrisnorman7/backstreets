/// Provides the [Wall] class, and the [WallTypes] enumeration.
library wall;

/// Specifies the possible wall types.
enum WallTypes {
  /// A wall that cannot be passed through, or fired over.
  wall,
  /// A wall that cannot be passed through, but can be fired over.
  barricade
}

// A wall in the game.
///
/// Depending on the type, it may be possible to shoot over this wall.
class Wall {
  Wall(this.id, this.type, this.sound);

  /// The id of this wall.
  int id;

  /// The type of this wall.
  WallTypes type;

  /// The sound made when walking into this wall.
  String sound;
}
