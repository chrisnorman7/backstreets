import 'dart:async';
import 'package:aqueduct/aqueduct.dart';

class Migration56 extends Migration {
  @override
  Future upgrade() async {
   		database.createTable(SchemaTable("builder_permissions", [SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false)]));
		database.addColumn("builder_permissions", SchemaColumn.relationship("object", ManagedPropertyType.bigInteger, relatedTableName: "game_objects", relatedColumnName: "id", rule: DeleteRule.nullify, isNullable: true, isUnique: false));
		database.addColumn("builder_permissions", SchemaColumn.relationship("location", ManagedPropertyType.bigInteger, relatedTableName: "game_maps", relatedColumnName: "id", rule: DeleteRule.nullify, isNullable: true, isUnique: false));
		database.deleteTable("build_permissions");
  }

  @override
  Future downgrade() async {}

  @override
  Future seed() async {}
}
