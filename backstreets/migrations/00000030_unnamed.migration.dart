import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration30 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("game_maps", SchemaColumn("playersCanCreate", ManagedPropertyType.boolean, isPrimaryKey: false, autoincrement: false, defaultValue: "true", isIndexed: false, isNullable: false, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    