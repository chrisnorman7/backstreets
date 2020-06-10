import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration51 extends Migration { 
  @override
  Future upgrade() async {
   		database.alterColumn("player_options", "wallFilterAmount", (c) {c.defaultValue = "9000";});
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    