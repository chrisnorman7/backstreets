import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration15 extends Migration { 
  @override
  Future upgrade() async {
   		database.deleteColumn("game_maps", "convolverUrl");
		database.deleteColumn("game_maps", "convolverVolume");
		database.addColumn("map_sections", SchemaColumn("convolverUrl", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.addColumn("map_sections", SchemaColumn("convolverVolume", ManagedPropertyType.doublePrecision, isPrimaryKey: false, autoincrement: false, defaultValue: "1.0", isIndexed: false, isNullable: false, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    