/// Provides the [BackstreetsChannel] class.
library channel;

import 'dart:convert';
import 'dart:io';

import 'package:aqueduct/aqueduct.dart';
import 'package:emote_utils/emote_utils.dart';
import 'package:git/git.dart';
import 'package:path/path.dart' as path;

import 'actions/actions.dart';
import 'commands/command.dart';
import 'commands/command_context.dart';
import 'commands/commands.dart';

import 'config.dart';

import 'game/npc.dart';
import 'game/tile.dart';

import 'model/account.dart';
import 'model/connection_record.dart';
import 'model/game_map.dart';
import 'model/game_object.dart';

import 'socials_factory.dart';
import 'sound.dart';

/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://aqueduct.io/docs/http/channel/.
class BackstreetsChannel extends ApplicationChannel {
  /// Enables communication to and from the database.
  ManagedContext databaseContext;

  /// Allows us to get a number of commits, to use as a get argument.
  GitDir git;

  /// All the loaded impulses.
  Map<String, dynamic> impulses;

  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  @override
  Future<void> prepare() async {
    final int started = DateTime.now().millisecondsSinceEpoch;
    git = await GitDir.fromExisting(path.current, allowSubdirectory: true);
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
    for (final FileSystemEntity entity in tileSoundsDirectory.listSync()) {
      if (entity is Directory) {
        final String name = path.basename(entity.path);
        final Tile tile = Tile(name);
        tiles[name] = tile;
      }
    }
    socials.addSuffix(<String>['name', 'n'], (GameObject o) => SuffixResult('you', o.name));
    socials.addSuffix(<String>['ss'], (GameObject o) => SuffixResult('your', "${o.name}'s"));
    for (final FileSystemEntity entity in socialSoundsDirectory.listSync()) {
      if (entity is File) {
        final String socialName = path.basenameWithoutExtension(entity.path);
        socialSounds[socialName] = Sound(entity.path);
      }
    }
    for (final FileSystemEntity entity in ambienceDirectory.listSync()) {
      if (entity is File) {
        final String ambienceName = path.basenameWithoutExtension(entity.path);
        ambiences[ambienceName] = Sound(entity.path);
      }
    }
    impulses = loadImpulses();
    for (final FileSystemEntity entity in echoSoundsDirectory.listSync()) {
      final String echoSound = path.basenameWithoutExtension(entity.path);
      echoSounds[echoSound] = Sound(entity.path).url;
    }
    for (final FileSystemEntity entity in exitSoundsDirectory.listSync()) {
      if (entity is File) {
        final String name = path.basenameWithoutExtension(entity.path);
        exitSounds[name] = Sound(entity.path);
      }
    }
    for (final FileSystemEntity entity in phrasesDirectory.listSync(recursive: true)) {
      final String name = path.basenameWithoutExtension(entity.path);
      if (entity is Directory) {
        phrases[name] = <Sound>[];
      } else {
        phrases[path.basename(path.dirname(entity.path))].add(Sound(entity.path));
      }
    }
    for (final FileSystemEntity entity in actionsDirectory.listSync(recursive: true)) {
      final String name = path.basenameWithoutExtension(entity.path);
      if (entity is Directory) {
        actionSounds[name] = <Sound>[];
      } else {
        actionSounds[path.basename(path.dirname(entity.path))].add(Sound(entity.path));
      }
    }
    final Query<GameMap> q = Query<GameMap>(databaseContext);
    if (await q.reduce.count() == 0) {
      q.values.name = 'Map 1';
      await q.insert();
      logger.info('Created initial map.');
    } else {
      await npcStartTasks(databaseContext);
    }
    final double duration = (DateTime.now().millisecondsSinceEpoch - started) / 1000;
    logger.info('Preparation completed in ${duration.toStringAsFixed(2)} seconds.');
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

    // Serve up "index.html".
    router.route('/').linkFunction((Request req) async {
      final File f = File('client/build/index.html');
      String contents = f.readAsStringSync();
      contents = contents.replaceAll('%version%', (await git.commitCount()).toString());
      return Response.ok(contents, headers: <String, dynamic>{'Content-Type': 'text/html; charset=UTF-8'});
    });

    // Serve out of build.
    router.route('/*').link(() => FileController('client/build/'));

    // Serve API docs.
    router.route('/doc/api/*').link(() => FileController('doc/api/'));

    // Setup the websocket.
    router.route('/ws').linkFunction((Request request) async {
      final WebSocket socket = await WebSocketTransformer.upgrade(request.raw);
      final Logger socketLogger = Logger('${request.connectionInfo.remoteAddress.address}:${request.connectionInfo.remotePort}');
      socketLogger.info('Connection established.');
      final File motdFile = File('motd.txt');
      final CommandContext ctx = CommandContext(socket, socketLogger, databaseContext, request.connectionInfo.remoteAddress.address);
      await GameObject.notifyAdmins(ctx.db, 'Incoming conection from ${socketLogger.name}.', sound: Sound(path.join(soundsDirectory, 'notifications/connected.wav')));
      CommandContext.instances.add(ctx);
      final String motd = motdFile.readAsStringSync();
      ctx.message(motd);
      ctx.send('tileNames', tiles.keys.toList());
      tiles.forEach((String name, Tile t) {
        for (final Sound sound in t.footstepSounds) {
          ctx.send('footstepSound', <String>[t.name, sound.url]);
        }
      });
      ctx.sendAmbiences();
      ctx.send('impulses', <Map<String, dynamic>>[impulses]);
      ctx.send('echoSounds', <Map<String, String>>[echoSounds]);
      exitSounds.forEach((String name, Sound value) => ctx.send('exitSound', <String>[name, value.url]));
      final Query<GameMap> q = Query<GameMap>(ctx.db);
      for (final GameMap m in await q.fetch()) {
        ctx.send('addGameMap', <Map<String, dynamic>>[m.minimalData]);
      }
      ctx.send('actionFunctions', <List<String>>[actions.keys.toList()]);
      actionSounds.forEach((String name, List<Sound> sounds) {
        ctx.send('actionSounds', <dynamic>[name, <String>[for (final Sound s in sounds) s.url]]);
      });
      ctx.send('phrases', <List<String>>[phrases.keys.toList()]);
      socket.listen((dynamic payload) async {
        if (payload is! String) {
          await socket.close(WebSocketStatus.unsupportedData, 'Binary communication is not supported.');
          return null;
        }
        List<dynamic> data;
        try {
          data = jsonDecode(payload as String) as List<dynamic>;
        }
        on FormatException {
          socketLogger.severe('Invalid JSON received: $payload');
          await socket.close(WebSocketStatus.protocolError, 'Invalid JSON: $payload.');
          return null;
        }
        try {
          if (data.length != 2) {
            throw 'Invalid command sent.';
          }
          final String name = data[0] as String;
          final List<dynamic> arguments = data[1] as List<dynamic>;
          GameObject character;
          if (commands.containsKey(name)) {
            final Command command = commands[name];
            final Account account = await ctx.getAccount();
            character = await ctx.getCharacter();
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
            // When checking AuthenticationTypes.admin, check to see if they have no player, or their player's admin field isn't true.
            } else if (command.authenticationType == AuthenticationTypes.admin && character?.admin != true) {
              throw 'Attempting to call an admin command without being an administrator.';
            // When checking AuthenticationTypes.staff, check to see if they have no player, or their player's admin and builder fields isn't true.
            } else if (command.authenticationType == AuthenticationTypes.staff && !(await character.getStaff(ctx.db))) {
              throw 'Attempting to call a staff command without being a member of staff.';
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
          socketLogger.severe('Error parsing command.', e, s);
          ctx.sendError(e.toString());
        }
      }, onError: (dynamic error) => logger.warning(error),
      onDone: () async {
        await GameObject.notifyAdmins(ctx.db, '${socketLogger.name} has disconnected.', sound: Sound(path.join(soundsDirectory, 'notifications/disconnected.wav')));
        if (ctx.characterId != null) {
          final GameObject c = await ctx.setConnected(false);
          await c.doSocial(ctx.db, c.disconnectSocial);
          GameObject.commandContexts.remove(ctx.characterId);
          final Query<ConnectionRecord> q = Query<ConnectionRecord>(ctx.db)
            ..values.disconnected = DateTime.now()
            ..where((ConnectionRecord c) => c.object).identifiedBy(ctx.characterId)
            ..where((ConnectionRecord c) => c.disconnected).isNull();
          await q.update();
        }
        CommandContext.instances.remove(ctx);
        socketLogger.info('Websocket closed.');
      });
      return null;
    });
    return router;
  }

  @override
  Future<void> close() async {
    final Query<ConnectionRecord> q = Query<ConnectionRecord>(databaseContext)
      ..values.disconnected = DateTime.now()
      ..where((ConnectionRecord c) => c.disconnected).isNull();
    final List<ConnectionRecord> records = await q.update();
    logger.info('Connection records amended: ${records.length}.');
    super.close();
  }
}
