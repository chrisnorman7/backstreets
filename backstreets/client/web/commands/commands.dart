/// The main commands library. Contains the [commands] [Map].
library commands;

import 'command_context.dart';
import 'general.dart';
import 'login.dart';
import 'movement.dart';
import 'sound.dart';

/// The type for all command functions.
typedef CommandType = Future<void> Function(CommandContext);

/// A map containing all the commands which can be called by the server.
Map<String, CommandType> commands = <String, CommandType>{
  // General commands:
  'message': message,
  'error': error,

  // Sound commands:
  'interfaceSound': interfaceSound,

  // Login commands:
  'account': account,
  'characterName': characterName,
  'characterCoordinates': characterCoordinates,
  'mapName': mapName,
  'tile': tile,
};
