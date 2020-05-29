/// Provides the [Options] class.
library options;

/// An object for keeping track of player options.
class Options {
  /// How far the echo location system should search for things to bounce off.
  int echoLocationDistance;

  /// The echo location distance multiplier.
  ///
  /// Used for calculating the time before echo sounds play.
  int echoLocationDistanceMultiplier;

  /// The sound to play when pinging.
  String echoSound;
}