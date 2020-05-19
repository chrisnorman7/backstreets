import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration6 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("game_objects", SchemaColumn("theta", ManagedPropertyType.doublePrecision, isPrimaryKey: false, autoincrement: false, defaultValue: "0.0", isIndexed: false, isNullable: false, isUnique: false));
		database.addColumn("game_objects", SchemaColumn("speed", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, defaultValue: "400", isIndexed: false, isNullable: false, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    