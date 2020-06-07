/// Provides the [GameMap] class.
library game_map;

import 'dart:math';

import 'package:aqueduct/aqueduct.dart';

import '../sound.dart';
import 'exit.dart';
import 'game_object.dart';
import 'map_section.dart';
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

  /// All the exits from this map.
  ManagedSet<Exit> exits;

  // All the entrances to this map.
  ManagedSet<Exit> entrances;

  /// All the [MapSection] instances on this map.
  ManagedSet<MapSection> sections;

  /// The x coordinate where players should pop.
  @Column(defaultValue: '0')
  int popX = 0;

  /// The y coordinate where players should pop.
  @Column(defaultValue: '0')
  int popY = 0;

  /// The convolver URL for this map.
  @Column(nullable: true)
  String convolverUrl;

  /// The convolver volume for this map.
  @Column(defaultValue: '1.0')
  double convolverVolume;

  /// Whether ot not players can create here.
  @Column(defaultValue: 'false')
  bool playersCanCreate;
}

/// A map.
///
/// Maps contain sections, tiles, walls, and objects.
class GameMap extends ManagedObject<_GameMap> implements _GameMap {
  /// Returns true if the passed coordinates are valid for this Map.
  ///
  /// Valid coordinates means either there is a [MapSection] encompassing the coordinates, or there is a [MapTile] there.
  Future<bool> validCoordinates(ManagedContext db, Point<int> coordinates) async {
    final Query<MapSection> mapSectionQuery = Query<MapSection>(db)
      ..where((MapSection s) => s.startX).lessThanEqualTo(coordinates.x)
      ..where((MapSection s) => s.startY).lessThanEqualTo(coordinates.y)
      ..where((MapSection s) => s.endX).greaterThanEqualTo(coordinates.x)
      ..where((MapSection s) => s.endY).greaterThanEqualTo(coordinates.y)
      ..where((MapSection s) => s.location).identifiedBy(id);
    if (await mapSectionQuery.reduce.count() > 0) {
      final Query<MapWall> wallsQuery = Query<MapWall>(db)
        ..where((MapWall w) => w.x).equalTo(coordinates.x)
        ..where((MapWall w) => w.y).equalTo(coordinates.y);
      if (await wallsQuery.reduce.count() == 0) {
        return true;
      }
    }
    return false;
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

  Future<void> broadcastWall(ManagedContext db, MapWall w) async {
    return broadcastCommand(db, 'mapWall', <Map<String, dynamic>>[<String, dynamic>{
      'id': w.id,
      'x': w.x,
      'y': w.y,
      'sound': w.sound,
      'type': w.type.index,
    }]);
  }

  /// Tell all objects on this map to play a sound.
  Future<void> broadcastSound(ManagedContext db, Sound s, Point<double> coordinates, double volume) async {
    final Query<GameObject> q = Query<GameObject>(db)
      ..where((GameObject o) => o.location).identifiedBy(id);
    for (final GameObject o in await q.fetch()) {
      o?.commandContext?.sendSound(s, coordinates, volume);
    }
  }

  /// Used to send as part of the 'addGameMap' command.
  Map<String, dynamic> get minimalData {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'playersCanCreate': playersCanCreate,
      'popX': popX,
      'popY': popY,
    };
  }

  /// Get the section spanned by the provided coordinates.
  Future<MapSection> getCurrentSection(ManagedContext db, Point<int> coordinates) async {
    final Query<MapSection> q = Query<MapSection>(db)
      ..where((MapSection s) => s.startX).lessThanEqualTo(coordinates.x)
      ..where((MapSection s) => s.startY).lessThanEqualTo(coordinates.y)
      ..where((MapSection s) => s.endX).greaterThanEqualTo(coordinates.x)
      ..where((MapSection s) => s.endY).greaterThanEqualTo(coordinates.y)
      ..where((MapSection s) => s.location).identifiedBy(id);
    final List<MapSection> sections = await q.fetch();
    if (sections.isEmpty) {
      return null;
    }
    sections.sort((MapSection a, MapSection b) {
      if (a.rect.containsRectangle(b.rect)) {
        return 1;
      } else if (a.rect.intersects(b.rect)) {
        return a.area.compareTo(b.area);
      } else {
        return -1;
      }
    });
    return sections.first;
  }
}
