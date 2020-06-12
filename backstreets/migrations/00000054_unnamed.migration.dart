import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration54 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("game_objects", SchemaColumn("disconnectSocial", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, defaultValue: "'%1N %1has disconnected.'", isIndexed: false, isNullable: false, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    