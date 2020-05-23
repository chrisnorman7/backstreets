import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration11 extends Migration { 
  @override
  Future upgrade() async {
   		database.alterColumn("player_options", "soundVolume", (c) {c.defaultValue = "0.75";});
		database.alterColumn("player_options", "ambienceVolume", (c) {c.defaultValue = "0.75";});
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    