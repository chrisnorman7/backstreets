import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration22 extends Migration { 
  @override
  Future upgrade() async {
   		database.alterColumn("player_options", "echoSound", (c) {c.defaultValue = "'echoes/clack.wav'";});
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    