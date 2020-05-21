import 'package:aqueduct/aqueduct.dart';
import 'package:aqueduct_test/aqueduct_test.dart';
import 'package:backstreets/backstreets.dart';

/// A testing harness for backstreets.
///
/// A harness for testing an aqueduct application. Example test file:
///
///         void main() {
///           Harness harness = Harness()..install();
///
///           test("GET /path returns 200", () async {
///             final response = await harness.agent.get("/path");
///             expectResponse(response, 200);
///           });
///         }
///
class Harness extends TestHarness<BackstreetsChannel> with TestHarnessORMMixin {
  @override
  ManagedContext get context => channel.databaseContext;

  @override
  Future<void> onSetUp() async {
    await resetData();
  }

  @override
  Future<void> seed() async {
    /* insert some rows here */
  }

  @override
  Future<void> onTearDown() async {}
}
