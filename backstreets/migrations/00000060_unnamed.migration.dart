import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration60 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("game_objects", SchemaColumn.relationship("owner", ManagedPropertyType.bigInteger, relatedTableName: "game_objects", relatedColumnName: "id", rule: DeleteRule.nullify, isNullable: true, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    