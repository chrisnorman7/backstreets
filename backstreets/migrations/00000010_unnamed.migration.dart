import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration10 extends Migration { 
  @override
  Future upgrade() async {
   		database.deleteColumn("game_objects", "options");
		database.addColumn("player_options", SchemaColumn.relationship("object", ManagedPropertyType.bigInteger, relatedTableName: "game_objects", relatedColumnName: "id", rule: DeleteRule.cascade, isNullable: true, isUnique: true));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    