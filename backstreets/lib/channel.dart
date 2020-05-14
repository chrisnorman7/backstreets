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
import 'game/tile.dart';

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
}
