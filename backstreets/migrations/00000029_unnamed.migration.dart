import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration29 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("map_sections", SchemaColumn("ambience", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    