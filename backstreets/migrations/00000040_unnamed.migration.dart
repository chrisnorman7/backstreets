import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration40 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("exits", SchemaColumn("admin", ManagedPropertyType.boolean, isPrimaryKey: false, autoincrement: false, defaultValue: "false", isIndexed: false, isNullable: false, isUnique: false));
		database.addColumn("exits", SchemaColumn("builder", ManagedPropertyType.boolean, isPrimaryKey: false, autoincrement: false, defaultValue: "false", isIndexed: false, isNullable: false, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    