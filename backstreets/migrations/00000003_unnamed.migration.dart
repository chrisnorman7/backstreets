import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration3 extends Migration { 
  @override
  Future upgrade() async {
   		database.alterColumn("game_maps", "popX", (c) {c.defaultValue = "0.0";});
		database.alterColumn("game_maps", "popY", (c) {c.defaultValue = "0.0";});
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    