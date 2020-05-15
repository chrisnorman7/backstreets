/// Provides the BackstreetsChannel class.
library channel;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import 'backstreets.dart';
import 'commands/builder.dart';
import 'commands/command.dart';
import 'commands/command_context.dart';
import 'commands/commands.dart';
import 'game/account.dart';
import 'game/game_map.dart';
import 'game/game_object.dart';
import 'game/tile.dart';

/// The file that will store [Account] instances.
const String accountsFile = 'game/accounts.json';

/// The file that will store [GameObject] instances.
const String objectsFile = 'game/objects.json';

/// The file that will store [GameMap] instances.
const String mapsFile = 'game/maps.json';

/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://aqueduct.io/docs/http/channel/.
class BackstreetsChannel extends ApplicationChannel {
  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  @override
  Future<void> prepare() async {
    logger.onRecord.listen((LogRecord rec) => print('$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}'));
    buildCommands();
    logger.info('Commands: ${commands.length}.');
    dynamic data;
    File f = File(objectsFile);
    if (f.existsSync()) {
      logger.info('Loading objects from $objectsFile.');
      data = jsonDecode(f.readAsStringSync());
      for (final dynamic objectData in data as List<dynamic>) {
        final GameObject obj = GameObject('not loaded yet');
        obj.updateFromJson(objectData as Map<String, dynamic>);
        objects[obj.id] = obj;
      }
      logger.info('Objects loaded: ${objects.length}.');
    } else {
      logger.info('No objects file to load from.');
    }
    f = File(mapsFile);
    if (f.existsSync()) {
      logger.info('Loading maps from $mapsFile.');
      data = jsonDecode(f.readAsStringSync());
      for (final dynamic mapData in data as List<dynamic>) {
        final GameMap m = GameMap();
        m.updateFromJson(mapData as Map<String, dynamic>);
        maps[m.id] = m;
      }
      logger.info('Maps loaded: ${maps.length}.');
    } else {
      logger.info('No maps file to load from.');
    }
    f = File(accountsFile);
    if (f.existsSync()) {
      logger.info('Loading accounts from $accountsFile.');
      data = jsonDecode(f.readAsStringSync());
      for (final dynamic accountData in data as List<dynamic>) {
        final Account a = Account('not loaded yet');
        a.updateFromJson(accountData as Map<String, dynamic>);
        accounts[a.username] = a;
      }
      logger.info('Accounts loaded: ${accounts.length}.');
    } else {
      logger.info('No accounts file to load from.');
    }
    logger.info('Gathering tile sounds.');
    tileSoundsDirectory.list().listen((FileSystemEntity entity) {
      if (entity is Directory) {
        final String name = path.basename(entity.path);
        tiles.add(Tile(name));
        logger.info('Added tile $name.');
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
      final CommandContext ctx = CommandContext(socket, socketLogger);
      final String motd = motdFile.readAsStringSync();
      ctx.sendMessage(motd);
      socketLogger.info('Connection established.');
      socket.listen(
        (dynamic payload) {
          if (payload is String) {
            try {
              final List<dynamic> data = jsonDecode(payload) as List<dynamic>;
              final String name = data[0] as String;
              final List<dynamic> arguments = data[1] as List<dynamic>;
              if (commands.containsKey(name)) {
                final Command command = commands[name];
                ///Let's check that the player is as authenticated as the command wants them to be.
                //
                // When checking AuthenticationTypes.anonymous, we only need to check ctx.account, since if they have a player, and no account, then there's a larger bug going on.
                if (command.authenticationType == AuthenticationTypes.anonymous && ctx.account != null) {
                  throw 'Attempting to call an anonymous command while connected to an account.';
                // When checking AuthenticationTypes.account, check to see if they have an invalid account or a valid player.
                } else if (command.authenticationType == AuthenticationTypes.account && (ctx.account == null || ctx.player != null)) {
                  throw 'Attempting to call an account command with an invalid account or a valid player.';
                // When checking AuthenticationTypes.authenticated, check to see if they have no player.
                } else if (command.authenticationType == AuthenticationTypes.authenticated && ctx.player == null) {
                  throw 'Attempting to call an authenticated command without being connected to a player.';
                }
                ctx.args = arguments;
                command.func(ctx);
              } else {
                logger.warning('Invalid command: $name.');
                ctx.sendError('Invalid JSON: $name.');
              }
            }
            on FormatException {
              socketLogger.severe('Invalid JSON received: $payload');
              ctx.sendError('Invalid JSON: $payload.');
            }
            catch(e) {
              socketLogger.severe(e);
              ctx.sendError(e.toString());
            }
          }
        },
        onDone: () {
          if (ctx.player != null) {
            ctx.player.socket = null;
          }
          socketLogger.info('Websocket closed.');
        }
      );
      return null;
    });
    return router;
  }

  @override
  Future<void> close() async {
    logger.info('Dumping the database.');
    dump();
    logger.info('Database dumped.');
    return super.close();
  }

  Future<void> backup(File f) async {
    final DateTime now = DateTime.now();
    await f.rename('${path.dirname(f.path)}/${now.year}-${now.month}-${now.day} ${now.hour}.${now.minute}.${now.second} ${path.basename(f.path)}');
  }

  void dump() {
    const JsonEncoder json = JsonEncoder.withIndent('  ');
    File f = File(accountsFile);
    backup(f);
    final List<Map<String, dynamic>> accountsData = <Map<String, dynamic>>[];
    accounts.forEach((String id, Account a) => accountsData.add(a.toJson()));
    f.writeAsString(json.convert(accountsData));
    logger.info('Accounts dumped: ${accountsData.length}.');
    f = File(objectsFile);
    backup(f);
    final List<Map<String, dynamic>> objectsData = <Map<String, dynamic>>[];
    objects.forEach((String id, GameObject obj) => objectsData.add(obj.toJson()));
    f.writeAsString(json.convert(objectsData));
    logger.info('Objects dumped: ${objectsData.length}.');
    f = File(mapsFile);
    backup(f);
    final List<Map<String, dynamic>> mapsData = <Map<String, dynamic>>[];
    maps.forEach((String id, GameMap m) => accountsData.add(m.toJson()));
    f.writeAsString(json.convert(mapsData));
    logger.info('Maps dumped: ${mapsData.length}.');
  }
}
