import 'dart:io';

import 'package:aqueduct/aqueduct.dart';
import 'package:backstreets/backstreets.dart';

Future<void> main() async {
  final Application<BackstreetsChannel> app = Application<BackstreetsChannel>()
      ..options.configurationFilePath = 'config.yaml'
      ..options.port = 8888;

  final int count = Platform.numberOfProcessors ~/ 2;
  await app.start(numberOfInstances: count > 0 ? count : 1);

  print('Application started on port: ${app.options.port}.');
  print('Use Ctrl-C (SIGINT) to stop running the application.');
}
