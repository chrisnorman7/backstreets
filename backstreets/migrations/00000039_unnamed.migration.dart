import 'dart:async';
import 'package:aqueduct/aqueduct.dart';

class Migration39 extends Migration {
  @override
  Future upgrade() async {
   		database.alterColumn("exits", "useSocial", (c) {c.defaultValue = "'%1N walk%1s through %2n.'";c.isNullable = false;}, unencodedInitialValue: "'%1N walk%1s through %2n.'");
  }

  @override
  Future downgrade() async {}

  @override
  Future seed() async {}
}
