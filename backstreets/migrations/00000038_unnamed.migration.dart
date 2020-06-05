import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration38 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("exits", SchemaColumn("useSound", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.addColumn("exits", SchemaColumn("useSocial", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
		database.deleteColumn("exits", "sound");
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    