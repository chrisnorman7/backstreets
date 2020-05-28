import 'dart:async';
import 'package:aqueduct/aqueduct.dart';   

class Migration26 extends Migration { 
  @override
  Future upgrade() async {
   		database.alterColumn("player_options", "echoSound", (c) {c.defaultValue = "'clack'";});
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    