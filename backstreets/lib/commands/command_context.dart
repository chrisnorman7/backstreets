/// Provides the [CommandContext] class.
library command_arguments;

import 'dart:convert';
import 'dart:io';

import 'package:aqueduct/aqueduct.dart';

import '../game/tile.dart';

import '../model/account.dart';
import '../model/game_map.dart';
import '../model/game_object.dart';
import '../model/map_section.dart';
import '../model/map_tile.dart';

import '../sound.dart';

import 'commands.dart';

/// Used when calling commands.
class CommandContext{
  /// Pass this object to a command in the [commands] dictionary.
  CommandContext(this.socket, this.logger, this.db);

  /// All instances.
  static List<CommandContext> instances = <CommandContext>[];

  /// The [WebSocket] that called this command.
  final WebSocket socket;

  /// The logger for this socket.
  final Logger logger;

  /// The interface to the database.
  ManagedContext db;

  /// The id of the [Account] that is logged in on [socket], or null.
  int accountId;

  /// The id of the [GameObject] that is logged in on [socket], or null.
  int characterId;

  /// The id of the map that this context's player is on.
  int mapId;

  /// The arguments provided to the command.
  List<dynamic> args;

  /// Get an [Account] instance, with an id of [accountId].
  Future<Account> getAccount() async {
    if (accountId == null) {
      return null;
    }
    final Query<Account> q = Query<Account>(db)
      ..where((Account a) => a.id).equalTo(accountId);
    return await q.fetchOne();
  }

  /// Set [accountId] to the id of the provided [Account] instance.
  set account(Account a) {
    accountId = a?.id;
  }

  /// Get a [GameObject] instance, with an id of [characterId].
  Future<GameObject> getCharacter() async {
    if (characterId == null) {
      return null;
    }
    final Query<GameObject> q = Query<GameObject>(db)
      ..where((GameObject c) => c.id).equalTo(characterId);
    return await q.fetchOne();
  }

  /// Set [characterId] to the id of the provided [GameObject] instance.
  set character(GameObject c) {
    characterId = c?.id;
  }

  /// Get the map this context's character is on.
  Future<GameMap> getMap() async {
    if (mapId == null) {
      return null;
    }
    final Query<GameMap> mapQuery = Query<GameMap>(db)
      ..where((GameMap m) => m.id).equalTo(mapId);
    return await mapQuery.fetchOne();
  }

  /// Set [mapId] to the id of the provided [GameMap].
  set map(GameMap m) {
    mapId = m?.id;
  }

  /// Send an arbitrary command to [socket].
  void send(String name, List<dynamic> arguments) {
    final String data = jsonEncode(<dynamic>[name, arguments]);
    socket.add(data);
  }

  /// Send a message to the player.
  void sendMessage(String text) {
    send('message', <String>[text]);
  }

  /// Alert the player to an error.
  void sendError(String text, {Sound sound}) {
    send('error', <String>[text]);
    if (sound != null) {
      sendInterfaceSound(sound);
    }
  }

  /// Make the player's browser play an interface sound.
  ///
  /// This sound will have no panning applied, and no convolver.
  ///
  /// This sort of sound should not be used for playing game-related sounds (firing weapons, rocks falling or whatever), but for sending alerts, incoming log messages and the like.
  void sendInterfaceSound(Sound sound) {
    send('interfaceSound', <String>[sound.url]);
  }

  /// Tell the player about their account.
  Future<void> sendAccount() async {
    final List<Map<String, dynamic>> objects = <Map<String, dynamic>>[];
    final Account account = await getAccount();
    final Query<GameObject> charactersQuery = Query<GameObject>(db)
      ..where((GameObject o) => o.account).identifiedBy(accountId)
      ..sortBy((GameObject o) => o.createdAt, QuerySortOrder.ascending);
    for (final GameObject obj in await charactersQuery.fetch()) {
      objects.add(<String, dynamic>{
        'id': obj.id,
        'name': obj.name,
      });
    }
    final List<Map<String, dynamic>> maps = <Map<String, dynamic>>[];
    final Query<GameMap> q = Query<GameMap>(db);
    for (final GameMap m in await q.fetch()) {
      maps.add(<String, dynamic>{
        'id': m.id,
        'name': m.name
      });
    }
    send('account', <dynamic>[account.username, objects, maps]);
  }

  /// Tell the connected player about the connected character.
  Future<void> sendCharacter() async {
    final GameObject c = await getCharacter();
    send('characterName', <String>[c.name]);
    send('characterSpeed', <int>[c.speed]);
    send('characterTheta', <double>[c.theta]);
    send('characterCoordinates', <double>[c.x, c.y]);
    logger.info('Sent character details.');
    send('admin', <bool>[c.admin]);
    await sendMap();
    await c.doSocial(db, c.connectSocial);
  }

  /// Tell the connected player about the map they are on.
  Future<void> sendMap() async {
    final int started = DateTime.now().millisecondsSinceEpoch;
    logger.info('Sending map data.');
    final Query<GameMap> mapQuery = Query<GameMap>(db)
      ..where((GameMap m) => m.id).equalTo(mapId);
    final GameMap m = await mapQuery.fetchOne();
    final Map<String, dynamic> mapData = <String, dynamic>{
      'name': m.name,
      'convolverUrl': m.convolverUrl,
      'convolverVolume': m.convolverVolume,
      'sections': <Map<String, dynamic>>[],
      'tiles': <Map<String, dynamic>>[]
    };
    final Query<MapSection> sectionsQuery = Query<MapSection>(db)
      ..where((MapSection s) => s.location).identifiedBy(mapId);
    for (final MapSection s in await sectionsQuery.fetch()) {
      mapData['sections'].add(s.asMap());
    }
    final Query<MapTile> tilesQuery = Query<MapTile>(db)
      ..where((MapTile t) => t.location.id).equalTo(mapId);
    final List<String> tileNames = tiles.keys.toList();
    for (final MapTile t in await tilesQuery.fetch()) {
      mapData['tiles'].add(<String, dynamic>{
        'index': tileNames.indexOf(t.tileName),
        'x': t.x,
        'y': t.y
      });
    }
    send('mapData', <Map<String, dynamic>>[mapData]);
    final int total = DateTime.now().millisecondsSinceEpoch - started;
    logger.info('Sent map data in ${(total / 1000).toStringAsFixed(2)} seconds.');
  }
  
  void sendMapSection(MapSection s) {
    send('mapSection', <Map<String, dynamic>>[s.asMap()]);
  }
}
