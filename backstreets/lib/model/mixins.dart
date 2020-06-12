/// Provides various mixins for use with database objects.
///
/// * [PrimaryKeyMixin]
/// * [NameMixin]
/// * [IntCoordinatesMixin]
/// * [DoubleCoordinatesMixin]
/// * [AmbienceMixin]
library mixins;

import 'package:aqueduct/aqueduct.dart';

/// Adds a primary key to any object.
mixin PrimaryKeyMixin {
  /// The primary key.
  @primaryKey
  int id;
}

/// Add a name to any object.
mixin NameMixin {
  /// The name of this object.
  String name;
}

mixin IntCoordinatesMixin {
  /// The x coordinate.
  int x;

  /// The y coordinate.
  int y;
}

mixin DoubleCoordinatesMixin {
  /// The x coordinate.
  double x;

  /// The y coordinate.
  double y;
}

/// Ad ambience to an object.
mixin AmbienceMixin {
  /// The ambience to play on this object.
  @Column(nullable: true)
  String ambience;
}

/// Give the ambience of this object a distance it can travel.
///
/// On the web end, sets panner.refDistance.
mixin AmbienceDistanceMixin {
  /// How far this object's ambience travels.
  @Column(nullable: true)
  int ambienceDistance;
}

/// Add an admin flag to any object.
mixin AdminMixin {
  /// Whether or not this object is an admin.
  @Column(defaultValue: 'false')
  bool admin;
}
