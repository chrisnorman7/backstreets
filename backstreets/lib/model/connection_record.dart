/// Provides the [ConnectionRecord] class.
library connection_record;

import 'package:aqueduct/aqueduct.dart';
import 'game_object.dart';
import 'mixins.dart';

/// The connection_records table.
///
/// To deal with connection records directly, use the [ConnectionRecord] class.
@Table(name: 'connection_records')
class _ConnectionRecord with PrimaryKeyMixin {
  /// The IP address of the connection.
  String host;

  /// The time the connection was established.
  DateTime connected;

  /// The time the connection was terminated.
  @Column(nullable: true)
  DateTime disconnected;

  /// The object that the player connected to.
  @Relate(#connectionRecords, isRequired: true, onDelete: DeleteRule.cascade)
  GameObject object;
}

/// A class for logging connections.
///
/// Every time a player connects to a [GameObject] instance, a connection is logged, by creating a new instance of this class.
class ConnectionRecord extends ManagedObject<_ConnectionRecord> implements _ConnectionRecord {
  Duration get duration {
    final DateTime end = disconnected ?? DateTime.now();
    return end.difference(connected);
  }
}
