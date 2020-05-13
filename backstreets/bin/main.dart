import 'package:backstreets/backstreets.dart';

Future<void> main() async {
  final Application<BackstreetsChannel> app = Application<BackstreetsChannel>()
      ..options.configurationFilePath = 'config.yaml'
      ..options.port = 8888;

  await app.start(numberOfInstances: 1);

  print('Application started on port: ${app.options.port}.');
  print('Use Ctrl-C (SIGINT) to stop running the application.');
}
