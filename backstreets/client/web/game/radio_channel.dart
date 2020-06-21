/// Provides the [RadioChannel] class.
library radio_channel;

/// Store a radio channel from the server.
class RadioChannel {
  RadioChannel(this.id, this.name, this.transmitSound, this.admin);

  /// The id of the radio channel.
  int id;

  /// The name of the radio channel.
  String name;

  /// The sound that plays when transmissions are made.
  String transmitSound;

  /// Whether or not this channel is admin only.
  bool admin;
}
