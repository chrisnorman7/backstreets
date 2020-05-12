import 'dart:io';

import 'package:path/path.dart' as path;

import 'backstreets.dart';
import 'game/tile.dart';

/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://aqueduct.io/docs/http/channel/.
class ServerChannel extends ApplicationChannel {
  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  @override
  Future<void> prepare() async {
    logger.onRecord.listen((LogRecord rec) => print('$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}'));
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

    // Prefer to use `link` instead of `linkFunction`.
    // See: https://aqueduct.io/docs/http/request_controller/
    router
      .route('/example')
      .linkFunction((Request request) async {
        return Response.ok(<String, String>{'key': 'value'});
      });

    return router;
  }
}
