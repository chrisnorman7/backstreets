import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration28 extends Migration { 
  @override
  Future upgrade() async {
   		database.alterColumn("player_options", "echoLocationDistanceMultiplier", (c) {c.defaultValue = "20";});
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    