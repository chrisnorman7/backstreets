/// The main commands library. Contains the [commands] [Map].
library commands;

import 'command_context.dart';
import 'sound.dart';

/// The type for all command functions.
typedef CommandType = void Function(CommandContext);

/// A map containing all the commands which can be called by the server.
Map<String, CommandType> commands = <String, CommandType>{
  'message': (CommandContext ctx) => ctx.message(ctx.args[0] as String),
  'interfaceSound': interfaceSound,
};
