import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration58 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("map_section_actions", SchemaColumn("social", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.deleteColumn("map_section_actions", "useSocial");
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    