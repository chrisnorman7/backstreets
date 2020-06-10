import 'dart:async';
import 'package:aqueduct/aqueduct.dart';

class Migration48 extends Migration {
  @override
  Future upgrade() async {
   		database.addColumn("player_options", SchemaColumn("wallFilterAmount", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false), unencodedInitialValue: '4000');
  }

  @override
  Future downgrade() async {}

  @override
  Future seed() async {}
}
