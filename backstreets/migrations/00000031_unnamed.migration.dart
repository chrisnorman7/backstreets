import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration31 extends Migration { 
  @override
  Future upgrade() async {
   		database.alterColumn("game_maps", "playersCanCreate", (c) {c.defaultValue = "false";});
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    