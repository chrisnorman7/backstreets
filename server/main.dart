import 'dart:io';

import 'package:path/path.dart' as path;

import 'tile.dart';

Future<void> main() async {
  tileSoundsDirectory.list().listen((FileSystemEntity entity) {
    if (entity is Directory) {
      final String name = path.basename(entity.path);
      tiles.add(Tile(name));
      print('Added tile $name.');
    }
  });
  final HttpServer server = await HttpServer.bind('0.0.0.0', 8080);
  print('Server running on ${server.address.address}:${server.port}.');
  server.listen((HttpRequest req) async {
    print('[${req.connectionInfo.remoteAddress.address}] ${req.method} ${req.uri.path}');
    if (req.uri.path == '/ws') {
      try {
        print('Upgrading connection.');
        final WebSocket soc = await WebSocketTransformer.upgrade(req);
        soc.listen(
          (dynamic msg) {
            print(msg);
          },
          onDone: () => print('Websocket closed: ${soc.closeReason.isEmpty ? "Closed normally" : soc.closeReason}')
        );
      }
      on WebSocketException {
        print('Not a proper websocket connection.');
      }
    } else {
      req.response.write('${req.method} ${req.uri.path}');
      req.response.close();
    }
  });
}
