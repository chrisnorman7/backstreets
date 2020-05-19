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
  double startX;

  /// The start y coordinate.
  double startY;

  /// The end x coordinate.
  double endX;

  /// The end y coordinate.
  double endY;

  /// The tile type this section is filled with.
  String tileName;

  /// The map this section is part of.
  @Relate(#sections, isRequired: true, onDelete: DeleteRule.cascade)
  GameMap location;
}

/// A section of a map.
class MapSection extends ManagedObject<_MapSection> implements _MapSection {}
