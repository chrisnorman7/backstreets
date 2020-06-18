/// Provides the [RadioChannel] and [RadioTransmission] classes.
library radio;

import 'package:aqueduct/aqueduct.dart';

import '../sound.dart';
import 'game_object.dart';
import 'mixins.dart';

/// The radio_channels table.
///
/// To deal with radio channels directly, use the [RadioChannel] class.
@Table(name: 'radio_channels')
class _RadioChannel with PrimaryKeyMixin, AdminMixin, NameMixin {
  /// The sound that plays when transmissions are sent out on this channel.
  @Column(nullable: true)
  String transmitSound;

  /// All the objects tuned into this channel.
  ManagedSet<GameObject> listeners;

  /// All the messages which have been transmitted on this channel.
  ManagedSet<RadioTransmission> messages;
}

/// A radio channel.
class RadioChannel extends ManagedObject<_RadioChannel> implements _RadioChannel {
  /// Transmit on this channel.
  Future<RadioTransmission> transmit(ManagedContext db, GameObject who, String text) async {
    RadioTransmission t = RadioTransmission()
      ..object = who
      ..message = text
      ..channel = this;
    t = await db.insertObject(t);
    transmitRaw(db, '${who.name} transmits: "${t.message}"');
    return t;
  }

  /// Send a raw transmission. This can be from anyone or anything.
  ///
  /// Used as the backend for [transmit].
  Future<void> transmitRaw(ManagedContext db, String text) async {
    final Query<GameObject> q = Query<GameObject>(db)
      ..where((GameObject o) => o.connected).equalTo(true)
      ..where((GameObject o) => o.radioChannel).identifiedBy(id);
    for (final GameObject o in await q.fetch()) {
      o.commandContext.message('[$name] $text');
      if (transmitSound != null){
          o.commandContext.sendInterfaceSound(radioSounds[transmitSound]);
      }
    }
  }
}

/// The radio_transmissions table.
///
/// To work with radio transmissions directly, use the [RadioTransmission] class.
@Table(name: 'radio_transmissions')
class _RadioTransmission with PrimaryKeyMixin {
  /// The object that sent this transmission.
  @Relate(#radioTransmissions)
  GameObject object;

  /// The channel this message was sent on.
  @Relate(#messages, isRequired: true, onDelete: DeleteRule.cascade)
  RadioChannel channel;

  /// The text of the message.
  String message;

  /// The time this message was sent.
  DateTime sentAt;
}

/// A radio transmission.
class RadioTransmission extends ManagedObject<_RadioTransmission> implements _RadioTransmission {
  @override
  void willInsert() {
    sentAt = DateTime.now().toUtc();
  }
}
