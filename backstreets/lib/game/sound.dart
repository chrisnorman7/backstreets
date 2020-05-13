import 'game_map.dart';

/// A reference to a sound. Used with [GameMap].
class Sound {
  /// Construct a sound with a URL and a volume.
  ///
  /// Volume should be between 0.0 and 1.0, although this is not enforced.
  Sound({this.url, this.volume = 1.0});

  /// The URL of the sound.
  String url;

  /// The volume the sound should play at in the client.
  num volume;
}