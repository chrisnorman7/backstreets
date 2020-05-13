/// Provides utility functions.
/// * [newId].
library util;

import 'package:uuid/uuid.dart';

final Uuid uuid = Uuid();

String getId() {
  return uuid.v4();
}
