/// Provides the [commands] dictionary, as well as containing other command imports.
library commands;

import 'command.dart';
import 'command_context.dart';
import 'login.dart';

typedef CommandType = void Function(CommandContext);

Map<String, CommandType> commands = <String, CommandType>{};

List<CommandCollection> commandCollections = <CommandCollection>[ 
LoginCommands(),
];
