import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration43 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("map_sections", SchemaColumn("ambienceDistance", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    