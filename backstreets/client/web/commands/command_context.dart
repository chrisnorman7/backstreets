/// provides the [CommandContext] class.
library command_context;

import 'dart:convert';
import 'dart:html';
import 'dart:math';

import 'package:game_utils/game_utils.dart';

import '../directory.dart';

import '../game/game_map.dart';
import '../game/game_object.dart';
import '../game/map_section.dart';
import '../game/options.dart';

/// A command context. Will be passed to all commands, instead of using individual arguments, which will quickly become unmanageable.
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
  Point<double> coordinates = const Point<double>(0, 0);

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
  double _theta;

  /// Get [_theta].
  double get theta => _theta;

  /// Set [_theta].
  ///
  /// Also set the listener orientation.
  set theta(double value) {
    _theta = value;
    // Code modified from
    // https://developer.mozilla.org/en-US/docs/Web/API/PannerNode/orientationX
    //
    // convert degrees to radians and offset the angle so 0 points towards the listener
    final double radians = (value - 90) * (pi / 180);
    // using cosine and sine here ensures the output values are always normalised
    // i.e. they range between -1 and 1
    final double x = cos(radians);
    final double z = sin(radians);
    // we hard-code the Y component to 0, as Y is the axis of rotation
    sounds.listener
      ..forwardX.value = x
      ..forwardY.value = 0
      ..forwardZ.value = z;
  }

  /// The map the connected character is on.
  GameMap map;

  /// All possible ambiences.
  Map<String, String> ambiences = <String, String>{};

  /// All the tile names. Used so that [tile] doesn't send as much initial data.
  ///
  /// Added to by [movement.tileNames].
  List<String> tileNames = <String>[];

  /// All the footstep sounds.
  ///
  /// Added to by [footstepSound].
  Map<String, List<String>> footstepSounds = <String, List<String>>{};

  /// The permissions of the connected character.
  Permissions permissions = Permissions();

  /// The section which is in the process of being created.
  MapSection section;

  /// The id of a [MapSection] that the player wants resetting.
  int sectionResetId;

  /// The list of objects sent from the server.
  List<GameObject> objects;

  /// The function to be called when [objects] are sent.
  void Function() onListOfObjects;

  /// Used when resizing a [MapSection].
  MapSectionResizer mapSectionResizer;

  /// If `true`, any key that is not handled as a hotkey will be printed.
  bool helpMode = false;

  /// The impulses sent by the server.
  Directory impulses;

  /// Any player options not handled elsewhere.
  Options options = Options();

  /// The list of possible echo sounds.
  Map<String, String> echoSounds = <String, String>{};

  /// Get the section spanned by the provided coordinates.
  ///
  /// If no coordinates are provided, use [coordinates].
  MapSection getCurrentSection([Point<int> c]) {
    c ??= Point<int>(coordinates.x.floor(), coordinates.y.floor());
    final List<MapSection> matchingSections = <MapSection>[];
    map.sections.forEach((int id, MapSection s) {
      if (s.rect.containsPoint(c)) {
        matchingSections.add(s);
      }
    });
    if (matchingSections.isEmpty) {
      return null;
    }
    matchingSections.sort((MapSection a, MapSection b) {
      if (a.rect.containsRectangle(b.rect)) {
        return 1;
      } else if (a.rect.intersects(b.rect)) {
        return a.area.compareTo(b.area);
      } else {
        return -1;
      }
    });
    return matchingSections.first;
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
