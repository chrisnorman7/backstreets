import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration35 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("exits", SchemaColumn("destinationX", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false));
		database.addColumn("exits", SchemaColumn("destinationY", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false));
		database.deleteColumn("exits", "targetX");
		database.deleteColumn("exits", "targetY");
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    