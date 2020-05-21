/// Used for storing commands.
///
/// To create more commands, add them to [commandsList].
///
/// ```
/// commandsList.add(Command('time', (CommandContext ctx) => ctx.sendMessage('The current time is ${DateTime.now()}.')));
/// ```
///
/// The [buildCommands] function will handle moving them into the [commands] dictionary.
library commands;

import 'builder.dart';
import 'building.dart';
import 'command.dart';
import 'general.dart';
import 'login.dart';
import 'movement.dart';

List<Command> commandsList = <Command>[
  // Building commands.
  renameMap,
  renameSection,
  sectionTileName,
  addMapSection,

  // General commands.
  serverTime,

  // Login commands.
  login,
  createAccount,
  createCharacter,
  connectCharacter,

  // Movement commands.
  characterCoordinates,
  characterTheta,
];

Map<String, Command> commands = <String, Command>{};
