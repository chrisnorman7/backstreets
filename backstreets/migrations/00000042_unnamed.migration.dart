import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration42 extends Migration { 
  @override
  Future upgrade() async {
   		database.deleteTable("map_tiles");
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    