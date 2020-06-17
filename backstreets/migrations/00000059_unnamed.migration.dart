import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration59 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("map_section_actions", SchemaColumn("confirmMessage", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.addColumn("map_section_actions", SchemaColumn("confirmSocial", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.addColumn("map_section_actions", SchemaColumn("okLabel", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.addColumn("map_section_actions", SchemaColumn("cancelLabel", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.addColumn("map_section_actions", SchemaColumn("cancelSocial", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    