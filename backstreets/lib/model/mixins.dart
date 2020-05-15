/// Provides various mixins for use with database objects.
///
/// * [PrimaryKeyMixin]
/// * [CoordinatesMixin]
/// * [NameMixin]
library mixins;

import 'dart:math';

import 'package:aqueduct/aqueduct.dart';

/// Adds a primary key to any object.
mixin PrimaryKeyMixin {
  /// The primary key.
  @primaryKey
  int id;
}

/// Ad coordinates to any object.
mixin CoordinatesMixin {
  /// The x coordinate.
  double x;

  /// The y coordinates.

  double y;
  Point<double> get coordinates {
    return Point<double>(x, y);
  }
}

/// Add a name to any object.
mixin NameMixin {
  /// The name of this object.
  String name;
}
