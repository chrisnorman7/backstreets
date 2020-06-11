/// Provides functions for working with NPC's.
library npc;

import 'dart:async';
import 'dart:math';

import 'package:aqueduct/aqueduct.dart';

import '../game/tile.dart';
import '../model/exit.dart';
import '../model/game_object.dart';
import '../model/map_section.dart';
import '../sound.dart';
import 'util.dart';

/// Keep a record of all the move timers that have been started.
Map<int, Timer> moveTimers = <int, Timer>{};

/// Keep a record of all the phrase timers that have been started.
Map<int, Timer> phraseTimers = <int, Timer>{};

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
    final MapSection s = await o.location.getCurrentSection(db, Point<int>(o.x.floor(), o.y.floor()));
    final Point<double> c = o.coordinatesInDirection(s.tileSize);
    final Point<int> tileCoordinates = Point<int>(c.x.floor(), c.y.floor());
    final Query<Exit> exitQuery = Query<Exit>(db)
      ..join(object: (Exit e) => e.destination)
      ..where((Exit e) => e.x).equalTo(tileCoordinates.x)
      ..where((Exit e) => e.y).equalTo(tileCoordinates.y)
      ..where((Exit e) => e.location).identifiedBy(o.location.id);
    if (!o.canLeaveMap) {
      exitQuery.where((Exit e) => e.destination).identifiedBy(o.location.id);
    }
    final List<Exit> exits = await exitQuery.fetch();
    if (exits.isNotEmpty && o.useExitChance != null && random.nextInt(o.useExitChance) == 0) {
      final Exit e = randomElement<Exit>(exits);
      logger.info('Heading through ${e.name}.');
      await e.use(db, o);
    } else if (await o.location.validCoordinates(db, tileCoordinates)) {
      o = await o.move(db, c.x, c.y);
      if (!o.flying) {
        final Tile t = tiles[s.tileName];
        await o.location.broadcastSound(db, randomElement<Sound>(t.footstepSounds), o.coordinates, objectId: o.id);
      }
    } else {
      // Turn a random amount.
      q = Query<GameObject>(db)
        ..values.theta = random.nextInt(360).toDouble()
        ..where((GameObject obj) => obj.id).equalTo(id);
      o = await q.updateOne();
    }
    nextRun = random.nextInt(o.maxMoveTime) + o.speed;
  }
  catch (e, s) {
    logger.severe(e.toString());
    logger.severe(s.toString());
  }
  finally {
    moveTimers[id] = Timer(Duration(milliseconds: nextRun), () => npcMove(db, id));
  }
}

/// Find all the NPC's and move them.Object
/// An NPC is defined as a [GameObject] instance with a maxMoveTime that is not null.
Future<void> npcStartTasks(ManagedContext db) async {
  final Logger logger = Logger('NPC')
    ..info('Moving NPCs...');
  Query<GameObject> q = Query<GameObject>(db)
    ..where((GameObject o) => o.account).isNull()
    ..where((GameObject o) => o.maxMoveTime).isNotNull();
  for (final GameObject o in await q.fetch()) {
    logger.info('Moving $o.');
    await npcMove(db, o.id);
  }
  logger
    ..info('Objects moved: ${moveTimers.length}.')
    ..info('Running NPC phrases...');
  q = Query<GameObject>(db)
    ..where((GameObject o) => o.phrase).isNotNull();
  for (final GameObject o in await q.fetch()) {
    await npcPhrase(db, o.id);
  }
  logger.info('Phrased objects: ${phraseTimers.length}.');
}

/// Start an NPC moving if it's not already moving.Number
Future<void> npcMaybeMove(ManagedContext db, int id) async {
  if (!moveTimers.containsKey(id)) {
    await npcMove(db, id);
  }
}

/// Make an object emit a phrase from its collection.
Future<void> npcPhrase(ManagedContext db, int id) async {
  Logger logger = Logger('Object #$id');
  int nextRun = 20000;
  try {
    final Query<GameObject> q = Query<GameObject>(db)
      ..join(object: (GameObject o) => o.location)
      ..where((GameObject o) => o.phrase).isNotNull()
      ..where((GameObject o) => o.id).equalTo(id);
    final GameObject o = await q.fetchOne();
    if (o == null) {
      throw 'There is no phrased object with this ID.';
    }
    logger = Logger(o.toString());
    if (o.location == null) {
      throw 'This object has no location.';
    }
    nextRun = random.nextInt(o.maxPhraseTime) + o.minPhraseTime;
    final List<Sound> phrase = phrases[o.phrase];
    final Sound s = randomElement(phrase);
    o.location.broadcastSound(db, s, o.coordinates, airborn: o.flying, objectId: o.id);
  }
  catch (e, s) {
    logger.severe(e.toString());
    logger.severe(s.toString());
  }
  finally {
    phraseTimers[id] = Timer(Duration(milliseconds: nextRun), () => npcPhrase(db, id));
  }
}
