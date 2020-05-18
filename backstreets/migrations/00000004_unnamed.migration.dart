import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration4 extends Migration { 
  @override
  Future upgrade() async {
   		database.alterColumn("game_objects", "deaths", (c) {c.defaultValue = "0";});
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    