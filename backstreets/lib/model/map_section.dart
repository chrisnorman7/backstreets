/// Provides the [MapTerrain] class.
library map_section;

import 'package:aqueduct/aqueduct.dart';

import 'game_map.dart';
import 'mixins.dart';

/// The terrains table.
///
/// To work with terrains directly, use the [MapTerrain] class.
@Table(name: 'map_sections')
class _MapSection with PrimaryKeyMixin, NameMixin {
  /// The start x coordinate.
  int startX;

  /// The start y coordinate.
  int startY;

  /// The end x coordinate.
  int endX;

  /// The end y coordinate.
  int endY;

  /// The tile type this section is filled with.
  String tileName;
  
  /// The size of each tile.
  @Column(defaultValue: '0.5')
  double tileSize;

  /// The map this section is part of.
  @Relate(#sections, isRequired: true, onDelete: DeleteRule.cascade)
  GameMap location;
}

/// A section of a map.
class MapSection extends ManagedObject<_MapSection> implements _MapSection {}
