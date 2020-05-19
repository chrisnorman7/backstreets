/// Provides the [BackstreetsChannel] class.
library channel;

import 'dart:convert';
import 'dart:io';

import 'package:aqueduct/aqueduct.dart';
import 'package:path/path.dart' as path;

import 'commands/builder.dart';
import 'commands/command.dart';
import 'commands/command_context.dart';
import 'commands/commands.dart';

import 'config.dart';

import 'game/tile.dart';

import 'model/account.dart';
import 'model/game_map.dart';
import 'model/game_object.dart';
import 'model/map_section.dart';

import 'sound.dart';

/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://aqueduct.io/docs/http/channel/.
class BackstreetsChannel extends ApplicationChannel {
  /// Enables communication to and from the database.
  ManagedContext databaseContext;

  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  @override
  Future<void> prepare() async {
    bool mapBuilt = false;
    final BackstreetsConfiguration config = BackstreetsConfiguration(options.configurationFilePath);
    final ManagedDataModel dataModel = ManagedDataModel.fromCurrentMirrorSystem();
    final PostgreSQLPersistentStore psc = PostgreSQLPersistentStore.fromConnectionInfo(
      config.database.username,
      config.database.password,
      config.database.host,
      config.database.port,
      config.database.databaseName
    );
    databaseContext = ManagedContext(dataModel, psc);
    logger.onRecord.listen((LogRecord rec) => print('$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}'));
    buildCommands();
    logger.info('Commands: ${commands.length}.');
    logger.info('Gathering tile sounds.');
    tileSoundsDirectory.list().listen((FileSystemEntity entity) async {
      if (entity is Directory) {
        final String name = path.basename(entity.path);
        final Tile tile = Tile(name);
        tiles[name] = tile;
        logger.info('Added tile $name.');
        if (tiles.length == 1 && !mapBuilt) {
          mapBuilt = true;
          // Let's see if we need to build a map.
          final Query<GameMap> q = Query<GameMap>(databaseContext);
          final int mapCount = await q.reduce.count();
          if (mapCount < 1) {
            logger.info('Creating default map.');
            await databaseContext.transaction((ManagedContext db) async {
              GameMap m = GameMap()
                ..name = 'Map 1';
              m = await db.insertObject(m);
              final MapSection s = MapSection()
                ..name = 'Untitled Section'
                ..startX = 0.0
                ..startY = 0.0
                ..endX = 200.0
                ..endY = 200.0;
              await db.insertObject(s);
            });
            logger.info('Map created.');
          } else {
            logger.info('Maps: $mapCount.');
          }
        }
      }
    });
  }

  /// Construct the request channel.
  ///
  /// Return an instance of some [Controller] that will be the initial receiver
  /// of all [Request]s.
  ///
  /// This method is invoked after [prepare].
  @override
  Controller get entryPoint {
    final Router router = Router();

    // Setup the websocket first.
    router.route('/ws').linkFunction((Request request) async {
      final WebSocket socket = await WebSocketTransformer.upgrade(request.raw);
      final File motdFile = File('motd.txt');
      final Logger socketLogger = Logger('${request.connectionInfo.remoteAddress.address}:${request.connectionInfo.remotePort}');
      final CommandContext ctx = CommandContext(socket, socketLogger, databaseContext);
      final String motd = motdFile.readAsStringSync();
      ctx.sendMessage(motd);
      ctx.send('tileNames', tiles.keys.toList());
      tiles.forEach((String name, Tile t) {
        for (final Sound sound in t.footstepSounds) {
          ctx.send('footstepSound', <String>[t.name, sound.url]);
        }
      });
      socketLogger.info('Connection established.');
      socket.listen(
        (dynamic payload) async {
          if (payload is! String) {
            await socket.close(400, 'Binary communication is not supported.');
            return null;
          }
          List<dynamic> data;
          try {
            data = jsonDecode(payload as String) as List<dynamic>;
          }
          on FormatException {
            socketLogger.severe('Invalid JSON received: $payload');
            await socket.close(400, 'Invalid JSON: $payload.');
            return null;
          }
          try {
            if (data.length != 2) {
              throw 'Invalid command sent.';
            }
            final String name = data[0] as String;
            final List<dynamic> arguments = data[1] as List<dynamic>;
            if (commands.containsKey(name)) {
              final Command command = commands[name];
              final Account account = await ctx.getAccount();
              final GameObject character = await ctx.getCharacter();
              ///Let's check that the player has the right level of authentication.
              //
              // When checking AuthenticationTypes.anonymous, we only need to check ctx.account, since if they have a player, and no account, then there's a larger bug going on.
              if (command.authenticationType == AuthenticationTypes.anonymous && account != null) {
                throw 'Attempting to call an anonymous command while connected to an account.';
              // When checking AuthenticationTypes.account, check to see if they have an invalid account or a valid player.
              } else if (command.authenticationType == AuthenticationTypes.account && (account == null || character != null)) {
                throw 'Attempting to call an account command with an invalid account or a valid player.';
              // When checking AuthenticationTypes.authenticated, check to see if they have no player.
              } else if (command.authenticationType == AuthenticationTypes.authenticated && character == null) {
                throw 'Attempting to call an authenticated command without being connected to a player.';
              }
              ctx.args = arguments;
              await command.func(ctx);
            } else {
              final String msg = 'Invalid command: $name.';
              logger.warning(msg);
              ctx.sendError(msg);
            }
          }
          catch(e, s) {
            socketLogger.severe(e);
            logger.severe(s.toString());
            ctx.sendError(e.toString());
          }
        },
        onError: (dynamic error) => logger.warning(error),
        onDone: () {
          socketLogger.info('Websocket closed.');
        }
      );
      return null;
    });
    return router;
  }
}
