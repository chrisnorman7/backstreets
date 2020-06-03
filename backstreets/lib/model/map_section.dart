/// Provides the [MapSection] class.
library map_section;

import 'package:aqueduct/aqueduct.dart';

import '../sound.dart';
import 'game_map.dart';
import 'map_section_action.dart';
import 'mixins.dart';

/// The sections table.
///
/// To work with map sections directly, use the [MapSection] class.
@Table(name: 'map_sections')
class _MapSection with PrimaryKeyMixin, NameMixin, AmbienceMixin {
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

  /// The convolver URL for this map.
  @Column(nullable: true)
  String convolverUrl;

  /// The volume of the convolver.
  @Column(defaultValue: '1.0')
  double convolverVolume;

  /// The map this section is part of.
  @Relate(#sections, isRequired: true, onDelete: DeleteRule.cascade)
  GameMap location;

  /// The actions associated with this section.
  ManagedSet<MapSectionAction> actions;
}

/// A section of a map.
class MapSection extends ManagedObject<_MapSection> implements _MapSection {
  /// Convert this object to a map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'startX': startX,
      'startY': startY,
      'endX': endX,
      'endY': endY,
      'tileName': tileName,
      'tileSize': tileSize,
      'convolverUrl': convolverUrl == null ? null : Sound(convolverUrl).url,
      'convolverVolume': convolverVolume,
      'ambienceUrl': ambience,
    };
  }
}
