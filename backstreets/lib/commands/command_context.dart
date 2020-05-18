/// Provides the [CommandContext] class.
library command_arguments;

import 'dart:convert';
import 'dart:io';

import 'package:aqueduct/aqueduct.dart';

import '../model/account.dart';
import '../model/game_map.dart';
import '../model/game_object.dart';
import '../sound.dart';

import 'commands.dart';

/// Used when calling commands.
class CommandContext{
  /// Pass this object to a command in the [commands] dictionary.
  CommandContext(this.socket, this.logger, this.db);

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
    accountId = a.id;
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
    characterId = c.id;
  }

  /// Get the map this context's character is on.
  Future<GameMap> getMap() async {
    return await db.transaction((ManagedContext t) async {
      final Query<GameObject> characterQuery = Query<GameObject>(t)
        ..where((GameObject o) => o.id).equalTo(characterId)
        ..join(object: (GameObject o) => o.location);
      final GameObject c = await characterQuery.fetchOne();
      final Query<GameMap> mapQuery = Query<GameMap>(t)
        ..where((GameMap m) => m.id).equalTo(c.location.id)
        ..join(set: (GameMap m) => m.tiles);
      return await mapQuery.fetchOne();
    });
  }

  /// Send an arbitrary command to [socket].
  void send(String name, dynamic arguments) {
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
    final Query<Account> accountQuery = Query<Account>(db)
      ..join(set: (Account a) => a.objects)
      ..where((Account a) => a.id).equalTo(accountId);
    final Account account = await accountQuery.fetchOne();
    for (final GameObject obj in account.objects) {
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

  Future<void> sendCharacter() async {
    final GameObject c = await getCharacter();
    send('characterName', <String>[c.name]);
    send('characterCoordinates', <double>[c.x, c.y]);
    logger.info('Sent character name and coordinates.');
    await sendMap();
  }

  Future<void> sendMap() async {
    logger.info('Sending map data.');
    final GameMap m = await getMap();
    for (final MapTile t in m.tiles) {
      send('tile', <String>[t.tileName]);
    }
    logger.info('Sent map tiles.');
    send('mapName', <String>[m.name]);
    logger.info('Sent map name.');
  }
}
