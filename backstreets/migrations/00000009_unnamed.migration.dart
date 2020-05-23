import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration9 extends Migration { 
  @override
  Future upgrade() async {
   		database.createTable(SchemaTable("player_options", [SchemaColumn("soundVolume", ManagedPropertyType.doublePrecision, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),SchemaColumn("ambienceVolume", ManagedPropertyType.doublePrecision, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false)]));
		database.addColumn("game_objects", SchemaColumn.relationship("options", ManagedPropertyType.bigInteger, relatedTableName: "player_options", relatedColumnName: "id", rule: DeleteRule.cascade, isNullable: true, isUnique: true));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    