import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration57 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("map_section_actions", SchemaColumn("useSocial", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.addColumn("map_section_actions", SchemaColumn("sound", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.addColumn("map_section_actions", SchemaColumn("functionName", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.alterColumn("builder_permissions", "object", (c) {c.isNullable = false;c.deleteRule = DeleteRule.cascade;});
		database.alterColumn("builder_permissions", "location", (c) {c.isNullable = false;c.deleteRule = DeleteRule.cascade;});
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    