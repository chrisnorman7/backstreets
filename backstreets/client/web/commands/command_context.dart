/// provides the [CommandContext] class.
library command_context;

import 'dart:convert';
import 'dart:html';
import 'dart:math';

import '../sound/sound.dart';

/// A command context. Will be passed to all commands, instead of using individiaul arguments, which will quickly become unmanageable.
class CommandContext {
  /// Create a context.
  CommandContext(this.socket, this.message, this.sounds);

  /// The socket that will provide all the communication.
  final WebSocket socket;

  /// The command that will allow commands to print messages.
  final void Function(String) message;

  /// A way to play sounds using web_audio.
  final SoundPool sounds;

  /// The command arguments. Retrieved from JSON.
  List<dynamic> args;

  /// Every message that is sent from the server.
  List<String> messages = <String>[];

  /// The username of the account we are connected to.
  ///
  /// Sent by [account].
  String username;

  /// The name of the connected character.
  ///
  /// Send by [characterName].
  String characterName;

  /// The coordinates of the connected character.
  ///
  /// Send by [characterCoordinates].
  Point<double> coordinates;

  /// The name of the map the connected character is on.
  ///
  /// Sent by [mapName].
  String mapName;

  /// Every tile on the current map.
  ///
  /// Tiles updated by [tile].
  Map<Point<double>, String> tiles;

  /// Send arbitrary commands to the server.
  void sendCommand(String name, List<dynamic> arguments) {
    final List<dynamic> data = <dynamic>[name, arguments];
    socket.send(jsonEncode(data));
  }
}
