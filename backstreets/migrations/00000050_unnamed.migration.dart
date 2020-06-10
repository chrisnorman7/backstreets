import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration50 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("game_objects", SchemaColumn("canLeaveMap", ManagedPropertyType.boolean, isPrimaryKey: false, autoincrement: false, defaultValue: "false", isIndexed: false, isNullable: false, isUnique: false));
		database.alterColumn("game_objects", "useExitChance", (c) {c.defaultValue = null;c.isNullable = true;});
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    