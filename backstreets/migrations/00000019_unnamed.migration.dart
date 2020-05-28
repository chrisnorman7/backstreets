import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration19 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("player_options", SchemaColumn("echoLocationDistance", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, defaultValue: "10", isIndexed: false, isNullable: false, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    