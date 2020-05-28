import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration16 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("game_maps", SchemaColumn("convolverUrl", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.addColumn("game_maps", SchemaColumn("convolverVolume", ManagedPropertyType.doublePrecision, isPrimaryKey: false, autoincrement: false, defaultValue: "1.0", isIndexed: false, isNullable: false, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    