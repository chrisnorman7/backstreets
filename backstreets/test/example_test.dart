import 'package:aqueduct_test/aqueduct_test.dart';
import 'package:test/test.dart';

import 'harness/app.dart';

Future<void> main() async {
  final Harness harness = Harness()..install();

  test('GET /ws upgrades the connection to a websocket and returns null', () async {
    expectResponse(await harness.agent.get('/ws'), 400, body: null);
  });
}
