import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration63 extends Migration { 
  @override
  Future upgrade() async {
   		database.createTable(SchemaTable("radio_transmissions", [SchemaColumn("text", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),SchemaColumn("sentAt", ManagedPropertyType.datetime, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false)]));
		database.createTable(SchemaTable("radio_channels", [SchemaColumn("transmitSound", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),SchemaColumn("name", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),SchemaColumn("admin", ManagedPropertyType.boolean, isPrimaryKey: false, autoincrement: false, defaultValue: "false", isIndexed: false, isNullable: false, isUnique: false),SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false)]));
		database.addColumn("radio_transmissions", SchemaColumn.relationship("object", ManagedPropertyType.bigInteger, relatedTableName: "game_objects", relatedColumnName: "id", rule: DeleteRule.nullify, isNullable: true, isUnique: false));
		database.addColumn("radio_transmissions", SchemaColumn.relationship("channel", ManagedPropertyType.bigInteger, relatedTableName: "radio_channels", relatedColumnName: "id", rule: DeleteRule.nullify, isNullable: true, isUnique: false));
		database.addColumn("game_objects", SchemaColumn("canTransmit", ManagedPropertyType.boolean, isPrimaryKey: false, autoincrement: false, defaultValue: "true", isIndexed: false, isNullable: false, isUnique: false));
		database.addColumn("game_objects", SchemaColumn.relationship("radioChannel", ManagedPropertyType.bigInteger, relatedTableName: "radio_channels", relatedColumnName: "id", rule: DeleteRule.nullify, isNullable: true, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    