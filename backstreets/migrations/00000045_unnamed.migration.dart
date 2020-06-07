import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration45 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("game_objects", SchemaColumn("minPhraseTime", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, defaultValue: "15000", isIndexed: false, isNullable: false, isUnique: false));
		database.addColumn("game_objects", SchemaColumn("maxPhraseTime", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, defaultValue: "60000", isIndexed: false, isNullable: false, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    