import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration20 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("player_options", SchemaColumn("echoLocationDistanceMultiplier", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, defaultValue: "5", isIndexed: false, isNullable: false, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    