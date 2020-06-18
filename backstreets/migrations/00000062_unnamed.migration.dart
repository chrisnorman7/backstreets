import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration62 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("player_options", SchemaColumn("connectNotifications", ManagedPropertyType.boolean, isPrimaryKey: false, autoincrement: false, defaultValue: "true", isIndexed: false, isNullable: false, isUnique: false));
		database.addColumn("player_options", SchemaColumn("disconnectNotifications", ManagedPropertyType.boolean, isPrimaryKey: false, autoincrement: false, defaultValue: "true", isIndexed: false, isNullable: false, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    