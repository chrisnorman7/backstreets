import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration41 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("game_objects", SchemaColumn("maxMoveTime", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    