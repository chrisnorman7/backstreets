import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration52 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("player_options", SchemaColumn("mouseSensitivity", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, defaultValue: "5", isIndexed: false, isNullable: false, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    