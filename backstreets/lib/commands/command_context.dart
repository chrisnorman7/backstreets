/// Provides the CommandArguments class.
library command_arguments;

import 'dart:convert';
import 'dart:io';

import 'package:aqueduct/aqueduct.dart';

import '../game/account.dart';
import '../game/game_object.dart';
import '../sound.dart';
import 'commands.dart';

/// Used when calling commands.
class CommandContext{
  /// Pass this object to a command in the [commands] dictionary.
  ///
  /// ```
  /// CommandArguments(socket, player, <String>['a', 'b', 'c']);
  /// ```
  CommandContext(this.socket, this.logger);

  /// The [WebSocket] that called this command.
  final WebSocket socket;

  /// The logger for this socket.
  final Logger logger;

  /// The player that is logged in on [socket], or null.
  Account account;

  /// The character that is logged in on [socket], or null.
  GameObject player;

  /// The arguments provided to the command.
  List<dynamic> args;

  /// Send an arbitrary command to [socket].
  void send(String name, List<dynamic> arguments) {
    final String data = jsonEncode(<dynamic>[name, arguments]);
    socket.add(data);
  }

  /// Send a message to the player.
  void sendMessage(String text) {
    send('message', <String>[text]);
  }

  /// Alert the player to an error.
  void sendError(String text, {Sound sound}) {
    sendMessage(text);
    if (sound != null) {
      sendInterfaceSound(sound);
    }
  }

  /// Make the player's browser play an interface sound.
  ///
  /// This sound will have no panning applied, and no convolver.
  ///
  /// This sort of sound should not be used for playing game-related sounds (firing weapons, rocks falling or whatever), but for sending alerts, incoming log messages and the like.
  void sendInterfaceSound(Sound sound) {
    send('interfaceSound', <String>[sound.url]);
  }

  /// Tell the player about their account.
  void sendAccount(Account account) {
    final Map<String, String> objects = <String, String>{};
    for (final GameObject object in account.objects) {
      objects[object.id] = object.name;
    }
    send('account', <dynamic>[account.username, objects]);
  }
}
