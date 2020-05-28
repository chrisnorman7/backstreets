import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration21 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("player_options", SchemaColumn("echoSound", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, defaultValue: "'clack.wav'", isIndexed: false, isNullable: false, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    