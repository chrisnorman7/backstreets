/// Provides the [GameMap] class.
library game_map;

import 'package:aqueduct/aqueduct.dart';

import 'exit.dart';
import 'game_object.dart';
import 'map_section.dart';
import 'map_tile.dart';
import 'map_wall.dart';
import 'mixins.dart';

/// The game_maps table.
///
/// If you want to work with maps directly, use the [GameMap] class.
@Table(name: 'game_maps')
class _GameMap with PrimaryKeyMixin, NameMixin, AmbienceMixin {
  /// All the [GameObject] instances on this map.
  ManagedSet<GameObject> objects;

  /// All the [MapWall] instances on this map.
  ManagedSet<MapWall> walls;

  /// All the [MapTile] instances contained by this map.
  ManagedSet<MapTile> tiles;

  /// All the exits from this map.
  ManagedSet<Exit> exits;

  // All the entrances to this map.
  ManagedSet<Exit> entrances;

  /// All the [MapSection] instances on this map.
  ManagedSet<MapSection> sections;

  /// The convolver URL for this map.
  @Column(nullable: true)
  String convolverUrl;

  /// The volume of the convolver.
  @Column(defaultValue: '1.0')
  double convolverVolume;

  /// The x coordinate where players should pop.
  @Column(defaultValue: '0')
  int popX = 0;

  /// The y coordinate where players should pop.
  @Column(defaultValue: '0')
  int popY = 0;
  
  /// The size of each tile.
  @Column(defaultValue: '0.5')
  double tileSize;
}

/// A map.
///
/// Maps contain sections, tiles, walls, and objects.
class GameMap extends ManagedObject<_GameMap> implements _GameMap {
  /// Returns [true] if the passed coordinates are valid for this Map.
  ///
  /// Valid coordinates means either there is a [MapSection] encompassing the coordinates, or there is a [MapTile] there.
  Future<bool> validCoordinates(ManagedContext db, int x, int y) async {
    final bool result = await db.transaction((ManagedContext t) async {
      final Query<MapSection> sectionQuery = Query<MapSection>(t)
        ..where((MapSection s) => s.startX).lessThanEqualTo(x)
        ..where((MapSection s) => s.startY).lessThanEqualTo(y)
        ..where((MapSection s) => s.endX).greaterThanEqualTo(x)
        ..where((MapSection s) => s.endY).greaterThanEqualTo(y);
      if (await sectionQuery.reduce.count() > 0) {
        return true;
      }
      final Query<MapTile> tileQuery = Query<MapTile>(t)
        ..where((MapTile t) => t.x).equalTo(x)
        ..where((MapTile t) => t.y).equalTo(y);
      if (await tileQuery.reduce.count() > 0) {
        return true;
      }
      return false;
    });
    return result;
  }

  @override
  String toString() {
    return '<Map $name (#$id)>';
  }

  /// Broadcast a command to any objects who are connected to players.
  Future<void> broadcastCommand(ManagedContext db, String name, List<dynamic> args) async {
    final Query<GameObject> q = Query<GameObject>(db)
      ..where((GameObject o) => o.location).identifiedBy(id);
    for (final GameObject obj in await q.fetch()) {
      obj.commandContext?.send(name, args);
    }
  }
}
