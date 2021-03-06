/// provides the [CommandContext] class.
library command_context;

import 'dart:convert';
import 'dart:html';
import 'dart:math';
import 'dart:web_audio';

import 'package:game_utils/game_utils.dart';

import '../constants.dart';
import '../directory.dart';
import '../game/action.dart';
import '../game/exit.dart';
import '../game/game_map.dart';
import '../game/game_object.dart';
import '../game/map_reference.dart';
import '../game/map_section.dart';
import '../game/options.dart';
import '../game/panned_sound.dart';
import '../game/wall.dart';
import '../util.dart';

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

  /// A book for menus.
  Book _book;

  /// Get [_book].
  Book get book {
    return _book;
  }

  /// Set [_book].
  set book(Book b) {
    _book = b;
    bookControls.hidden = b == null;
    standardControls.hidden = !bookControls.hidden;
    <Element, bool>{
      staffControls: permissions.staff,
      adminControls: permissions.admin,
      builderControls: permissions.builder,
    }.forEach((Element e, bool flag) {
      if (standardControls.hidden) {
        e.hidden = true;
      } else {
        if (flag == true) {
          e.hidden = false;
        } else {
          e.hidden = true;
        }
      }
    });
  }

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
  Point<double> _coordinates = const Point<double>(0, 0);

  /// Get [_coordinates].
  Point<double> get coordinates {
    return _coordinates;
  }

  /// Set [_coordinates].
  ///
  /// Also set the listener position.
  set coordinates(Point<double> value) {
    _coordinates = value;
    sounds.audioContext.listener
      ..positionX.value = value.x
      ..positionY.value = value.y;
    updateFilters();
  }

  /// Update all filters.
  void updateFilters() {
    for (final PannedSound s in map.pannedSounds) {
      if (s.sound.source == null) {
        continue;
      }
      final List<Wall> walls = wallsBetween(coordinates, s.coordinates);
      if (walls.isNotEmpty) {
        if (s.filter == null) {
          s.sound.output.disconnect();
          s.filter = getWallFilter(s.coordinates)
            ..connectNode(s.panner);
          s.sound.output.connectNode(s.filter);
        } else {
        }
      } else {
        if (s.filter != null) {
          s.filter.disconnect();
          s.filter = null;
          s.sound.output.connectNode(s.panner);
        }
      }
    }
  }

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
    final double rads = value / 180.0 * pi;
    sounds.listener
      ..forwardX.value = sin(rads)
      ..forwardY.value = cos(rads)
      ..forwardZ.value = 0;
  }

  /// The map the connected character is on.
  GameMap map;

  /// The maps that have been sent by the server.
  Map<int, MapReference> maps = <int, MapReference>{};

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

  /// The section which is in the process of being moved.
  MapSectionMover mapSectionMover;

  /// If `true`, any key that is not handled as a hotkey will be printed.
  bool helpMode = false;

  /// The impulses sent by the server.
  Directory impulses;

  /// Any player options not handled elsewhere.
  Options options = Options();

  /// The list of possible echo sounds.
  Map<String, String> echoSounds = <String, String>{};

  /// All the actions that have been sent by the server.
  List<String> actionFunctions = <String>[];

  /// The possible action sounds.
  Map<String, List<String>> actionSounds = <String, List<String>>{};

  /// An exit which is in the process of being made.
  Exit exit;

  /// The last exit to be stumbled across.
  Exit lastExit;

  /// All the possible exit sounds.
  Map<String, String> exitSounds = <String, String>{};

  /// The phrase directories on the server.
  List<String> phrases = <String>[];

  /// The coordinates of all the objects on the current map.
  Map<int, Point<double>> objectCoordinates = <int, Point<double>>{};

  /// The ID of an object which the player wants to summon.
  int summonObjectId;

  /// The possible radio sounds.
  Map<String, String> radioSounds = <String, String>{};

  /// Get the section spanned by the provided coordinates.
  ///
  /// If no coordinates are provided, use [coordinates].
  MapSection getCurrentSection([Point<int> c]) {
    c ??= getIntCoordinates();
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

  /// Get the current convolver.
  ///
  /// This is either the convolver for the current [MapSection], or the overall map convolver.
  ConvolverNode getCurrentConvolver(Point<int> coordinates) {
    final MapSection s = getCurrentSection(coordinates);
    if (s?.convolver?.convolver == null) {
      if (map.convolver.convolver != null) {
        return map.convolver.convolver;
      }
      return null;
    }
    return s.convolver.convolver;
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

  /// Returns true if we are good to move again.
  bool get canMove => (timestamp() - (lastMoved ?? 0)) >= speed;

  /// Set [lastMoved] to the current timestamp.
  void updateLastMoved() => lastMoved = timestamp();

  /// Used to call a map action to the server.
  void sendAction(Action a) {
    if (canMove) {
      send('action', <int>[a.id]);
      updateLastMoved();
    }
  }

  /// Request a list of objects, and set [onListOfObjects] to receive them.
  void getObjectList(void Function() cb, String commandName, {List<dynamic> args, String loadingMessage = 'Loading...'}) {
    onListOfObjects = cb;
    send(commandName, args);
    message(loadingMessage);
  }

  /// Send an object's phrase to the server.
  ///
  /// For brevity, this function also sets the phrase with the [phrase] argument.
  void sendPhrase(GameObject o, String phrase) {
    o.phrase = phrase;
    send('objectPhrase', <dynamic>[o.id, o.phrase]);
  }
}
