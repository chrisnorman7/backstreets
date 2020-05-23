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
import '../model/player_options.dart';

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

  /// The logger that describes [socket].
  final Logger logger;

  /// The interface to the database.
  ManagedContext db;

  /// The id of the [Account] that [socket] is logged in on.
  ///
  /// If the player has not logged in yet, this value will be null.
  int accountId;

  /// The id of the [GameObject] that [socket] is logged in on.
  ///
  /// If the player has not connected to a character (after logging in), this value will be null.
  int characterId;

  /// The id of the map that this context's player is on.
  ///
  /// If the player has not yet logged in and connected to a character, this value will be null.
  int mapId;

  /// The arguments provided to a command.
  ///
  /// This list can be of any length (including 0), and its contents depends on the command being sent.
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

  /// Get the options for the connected player.
  Future<PlayerOptions> getPlayerOptions() async {
    final Query<PlayerOptions> q = Query<PlayerOptions>(db)
      ..where((PlayerOptions o) => o.object).identifiedBy(characterId);
    return q.fetchOne();
  }

  /// Set [mapId] to the id of the provided [GameMap].
  set map(GameMap m) {
    mapId = m?.id;
  }

  /// Send an arbitrary command to [socket].
  ///
  /// It is OK to use arguments of any length.
  ///
  /// ``` send('ping', <String>[]);
  /// send('wizardName', <String>['Gandalf']);
  /// send('bottles', <String>['There are 99 green bottles standing on a wall...', 'There are 98 green bottles standing on a wall...' ...]);
  /// ```
  void send(String name, List<dynamic> arguments) {
    final String data = jsonEncode(<dynamic>[name, arguments]);
    socket.add(data);
  }

  /// Send a message to the player.
  ///
  /// If you are alerting the player to an error condition, use [sendError] instead.
  void sendMessage(String text) {
    send('message', <String>[text]);
  }

  /// Alert the player to an error.
  ///
  /// If you simply want to send a message, use [sendMessage] instead.
  ///
  /// The optional [sound] will be sent with a call to [sendInterfaceSound].
  void sendError(String text, {Sound sound}) {
    send('error', <String>[text]);
    if (sound != null) {
      sendInterfaceSound(sound);
    }
  }

  /// Make the player's browser play an interface sound.
  ///
  /// This sound will have no panning applied, and no fx.
  ///
  /// This sort of sound should not be used for playing game-related sounds (firing weapons, rocks falling or whatever), but for sending alerts, incoming log messages and the like.
  void sendInterfaceSound(Sound sound) {
    send('interfaceSound', <String>[sound.url]);
  }

  /// Tell the player about their account.
  ///
  /// Sends the following details:
  /// * The username.
  /// A list of Maps, representing the characters that are attached to the player's account.
  /// A list of Maps representing [GameMap] instances. Eventually the maps list will be used so players can create their characters on whatever map they like (presumably within reason).
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

  /// Tell the player about their connected character.
  ///
  /// This function actually runs a whole bunch of smaller sends, relying on the other end knowing how to handle aspects of the player, such as their current heading (theta) and coordinates.
  ///
  /// I feel like this function should send one big data package, like [sendMap] does, but as player stuff is most likely only going to get sent once - when the player connects, it's probably not all that important.
  Future<void> sendCharacter() async {
    final GameObject c = await getCharacter();
    final Query<PlayerOptions> q = Query<PlayerOptions>(db)
      ..where((PlayerOptions o) => o.object).identifiedBy(characterId);
    if (await q.reduce.count() == 0) {
      final PlayerOptions p = PlayerOptions()
        ..object = c;
      await db.insertObject(p);
    }
    send('characterName', <String>[c.name]);
    send('characterSpeed', <int>[c.speed]);
    send('characterTheta', <double>[c.theta]);
    send('characterCoordinates', <double>[c.x, c.y]);
    send('admin', <bool>[c.admin]);
    await sendPlayerOptions();
    logger.info('Sent character details.');
    await sendMap();
    await c.doSocial(db, c.connectSocial);
  }

  /// Tell the connected player about the map they are on.
  ///
  /// This function sends all the map data in a chunk, and lets the client split it up at the other end.
  ///
  /// This function used to send all its data as separate calls to [send], like [sendCharacter] does, but it was really slow.
  ///
  /// It probably won't be as slow now we're using [MapSection]s, not [MapTile]s, but it works fine as it is.
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
      'ambience': m.ambience == null ? null : ambiences[m.ambience].url,
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

  /// Send a section of a map.
  ///
  /// This method is used after a section has been updated for example.
  void sendMapSection(MapSection s) {
    send('mapSection', <Map<String, dynamic>>[s.asMap()]);
  }

  /// Send all the registered [ambiences].
  ///
  /// These are used by the client to build maps and so on.
  void sendAmbiences() {
    final Map<String, String> a = <String, String>{};
    ambiences.forEach((String name, Sound sound) => a[name] = sound.url);
    send('ambiences', <Map<String, String>>[a]);
  }

  /// Send the options this player has configured.
  //
  /// These include (but are probably not limited to):
  /// * Sound volume.
  /// * Ambience volume.
  /// * Music volume
  Future<void> sendPlayerOptions() async {
    final PlayerOptions o = await getPlayerOptions();
    send('playerOptions', <Map<String, dynamic>>[o.asMap()]);
  }
}
