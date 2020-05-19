import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration8 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("map_sections", SchemaColumn("tileName", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    