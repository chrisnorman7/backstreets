import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration61 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("accounts", SchemaColumn("lockedMessage", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    