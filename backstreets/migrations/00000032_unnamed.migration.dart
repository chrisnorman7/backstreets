import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration32 extends Migration { 
  @override
  Future upgrade() async {
   		database.createTable(SchemaTable("map_section_actions", [SchemaColumn("name", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false)]));
		database.addColumn("map_section_actions", SchemaColumn.relationship("section", ManagedPropertyType.bigInteger, relatedTableName: "map_sections", relatedColumnName: "id", rule: DeleteRule.cascade, isNullable: false, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    