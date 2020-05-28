import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration18 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("map_walls", SchemaColumn("type", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false));
		database.deleteColumn("map_walls", "wallType");
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    