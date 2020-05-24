/// provides the [CommandContext] class.
library command_context;

import 'dart:convert';
import 'dart:html';
import 'dart:math';

import 'package:game_utils/game_utils.dart';

import '../map_section.dart';

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

  /// A book for menus.
  Book book;

  /// The current position in the messages list.
  int messageIndex;

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

  /// The speed of this character.
  ///
  /// Set by the [commandSpeed] command.
  ///
  /// Used by the w key.
  int speed;

  /// The time (ini milliseconds) the character last moved.
  ///
  /// Set by the w hotkey.
  int lastMoved;

  /// The heading of the connected character.
  ///
  /// Set by [characterTheta].
  double theta;

  /// The name of the map the connected character is on.
  ///
  /// Sent by [mapName].
  String mapName;

  /// The ambience of the current map.
  String ambienceUrl;

  /// The ambience to play.
  Sound ambience;

  /// All possible ambiences.
  Map<String, String> ambiences = <String, String>{};

  /// Every section on the current map.
  Map<int, MapSection> sections = <int, MapSection>{};

  /// Every tile on the current map.
  ///
  /// Tiles updated by [tile].
  Map<Point<int>, String> tiles = <Point<int>, String>{};

  /// All the tile names. Used so that [tile] doesn't send as much initial data.
  ///
  /// Added to by [movement.tileNames].
  List<String> tileNames = <String>[];

  /// All the footstep sounds.
  ///
  /// Added to by [footstepSound].
  Map<String, List<String>> footstepSounds = <String, List<String>>{};

  /// The admin flag of the connected character.
  bool admin;

  /// The section which is in the process of being created.
  MapSection section;

  /// Get the section spanned by the provided coordinates.
  ///
  /// If no coordinates are provided, use [coordinates].
  MapSection getCurrentSection([Point<int> c]) {
    c ??= Point<int>(coordinates.x.toInt(), coordinates.y.toInt());
    final List<MapSection> matchingSections = <MapSection>[];
    sections.forEach((int id, MapSection s) {
      if (s.rect.containsPoint(c)) {
        matchingSections.add(s);
      }
    });
    if (matchingSections.isEmpty) {
      return null;
    }
    matchingSections.sort((MapSection a, MapSection b) {
      if (a.rect.containsRectangle(b.rect)) {
        return -1;
      } else if (a.rect.intersects(b.rect)) {
        return 0;
      } else {
        return -1;
      }
    });
    return matchingSections.last;
  }

  /// Send arbitrary commands to the server.
  void send(String name, List<dynamic> arguments) {
    final List<dynamic> data = <dynamic>[name, arguments];
    socket.send(jsonEncode(data));
  }

  /// Send the character's heading back to the server.
  void sendTheta() {
    send('characterTheta', <double>[theta]);
  }
}
