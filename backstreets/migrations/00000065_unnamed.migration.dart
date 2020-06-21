import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration65 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("game_objects", SchemaColumn("connectionName", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.deleteColumn("game_objects", "connected");
		database.alterColumn("radio_transmissions", "channel", (c) {c.isNullable = false;c.deleteRule = DeleteRule.cascade;});
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    