import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration64 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("radio_transmissions", SchemaColumn("message", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false));
		database.deleteColumn("radio_transmissions", "text");
		database.alterColumn("radio_channels", "transmitSound", (c) {c.isNullable = true;});
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    