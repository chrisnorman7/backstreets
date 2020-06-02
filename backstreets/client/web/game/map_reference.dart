/// Provides the [MapReference] class.
library map_reference;

class MapReference {
  MapReference(this.id, this.name, this.playersCanCreate);

  /// The id of this map.
  int id;

  /// The name of this map.
  String name;

  /// Whether or not players can be created here.
  bool playersCanCreate;
}
