import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration8 extends Migration { 
  @override
  Future upgrade() async {
   		database.deleteColumn("game_maps", "tileSize");
		database.addColumn("map_sections", SchemaColumn("tileSize", ManagedPropertyType.doublePrecision, isPrimaryKey: false, autoincrement: false, defaultValue: "0.5", isIndexed: false, isNullable: false, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    