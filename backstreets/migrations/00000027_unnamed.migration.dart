import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration27 extends Migration { 
  @override
  Future upgrade() async {
   		database.alterColumn("player_options", "echoLocationDistance", (c) {c.defaultValue = "50";});
		database.alterColumn("player_options", "echoLocationDistanceMultiplier", (c) {c.defaultValue = "150";});
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    