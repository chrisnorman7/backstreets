/// Provides the [MapReference] class.
library map_reference;

/// A reference to a map on the server.
class MapReference {
  MapReference(this.id, this.name, this.playersCanCreate, this.popX, this.popY);

  /// The id of this map.
  int id;

  /// The name of this map.
  String name;

  /// Whether or not players can be created here.
  bool playersCanCreate;

  /// The pop x coordinate.
  int popX;

  /// The pop y coordinate.
  int popY;
}
