import 'dart:async';
import 'package:aqueduct/aqueduct.dart';

class Migration49 extends Migration {
  @override
  Future upgrade() async {
   		database.addColumn("game_objects", SchemaColumn("useExitChance", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, defaultValue: "2", isIndexed: false, isNullable: false, isUnique: false), unencodedInitialValue: '2');
  }

  @override
  Future downgrade() async {}

  @override
  Future seed() async {}
}
