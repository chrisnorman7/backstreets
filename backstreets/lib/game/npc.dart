/// Provides functions for working with NPC's.
library npc;

import 'dart:async';
import 'dart:math';

import 'package:aqueduct/aqueduct.dart';

import '../game/tile.dart';
import '../model/game_object.dart';
import '../model/map_section.dart';
import '../sound.dart';
import 'util.dart';

/// Keep a record of all the timers that have been started.
Map<int, Timer> timers = <int, Timer>{};

/// Move an NPC around.
Future<void> npcMove(ManagedContext db, int id) async {
  Logger logger = Logger('Object #$id');
  int nextRun = 20000; // 20 seconds.
  try {
    Query<GameObject> q = Query<GameObject>(db)
      ..join(object: (GameObject o) => o.location)
      ..where((GameObject o) => o.id).equalTo(id);
    GameObject o = await q.fetchOne();
    if (o == null) {
      throw 'Object does not exist.';
    }
    logger = Logger(o.toString());
    if (o.location == null) {
      throw 'This object has no location.';
    }
    final MapSection s = await o.location.getCurrentSection(db, Point<int>(o.x.round(), o.y.round()));
    final Point<double> c = o.coordinatesInDirection(s.tileSize);
    if (await o.location.validCoordinates(db, Point<int>(c.x.round(), c.y.round()))) {
      q = Query<GameObject>(db)
        ..values.x = c.x
        ..values.y = c.y
        ..where((GameObject obj) => obj.id).equalTo(id);
      o = await q.updateOne();
      final Tile t = tiles[s.tileName];
      o.location.broadcastSound(db, randomElement<Sound>(t.footstepSounds), o.coordinates, 1.0);
    } else {
      // Turn a random amount.
      q = Query<GameObject>(db)
        ..values.theta = randInt(360).toDouble()
        ..where((GameObject obj) => obj.id).equalTo(id);
      o = await q.updateOne();
    }
    nextRun = randInt(o.maxMoveTime, start: o.speed);
  }
  catch (e, s) {
    logger.severe(e.toString());
    logger.severe(s.toString());
  }
  finally {
    timers[id] = Timer(Duration(milliseconds: nextRun), () => npcMove(db, id));
  }
}

/// Find all the NPC's and move them.Object
/// An NPC is defined as a [GameObject] instance with a maxMoveTime that is not null.
Future<void> npcMoveAll(ManagedContext db) async {
  final Logger logger = Logger('NPC')
    ..info('Moving NPCs...');
  final Query<GameObject> q = Query<GameObject>(db)
    ..where((GameObject o) => o.account).isNull()
    ..where((GameObject o) => o.maxMoveTime).isNotNull();
  for (final GameObject o in await q.fetch()) {
    logger.info('Moving $o.');
    await npcMove(db, o.id);
  }
  logger.info('Objects moved: ${timers.length}.');
}

/// Start an NPC moving if it's not already moving.Number
Future<void> npcMaybeMove(ManagedContext db, int id) async {
  if (!timers.containsKey(id)) {
    await npcMove(db, id);
  }
}