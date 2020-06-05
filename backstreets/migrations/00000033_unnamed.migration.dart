import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration33 extends Migration { 
  @override
  Future upgrade() async {
   		database.deleteTable("exits");
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    