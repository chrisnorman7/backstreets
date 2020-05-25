/// Used for storing commands.
///
/// To create more commands, add them to [commandsList].
///
/// ```
/// commandsList.add(Command('time', (CommandContext ctx) => ctx.sendMessage('The current time is ${DateTime.now()}.')));
/// // OR:
/// commandsList.add(Command('function', someFunction));
/// ```
///
/// The [buildCommands] function will handle moving them into the [commands.commands] dictionary.
library commands;

import 'builder.dart';
import 'building.dart';
import 'command.dart';
import 'general.dart';
import 'login.dart';
import 'movement.dart';
import 'socials.dart';

/// The list of pre-processed commands.
///
/// The [buildCommands] function migrates them to the [commands.commands] dictionary.
List<Command> commandsList = <Command>[
  // Building commands.
  Command('renameMap', renameMap, authenticationType: AuthenticationTypes.admin),
  Command('addMapSection', addMapSection, authenticationType: AuthenticationTypes.admin),
  Command('mapAmbience', mapAmbience, authenticationType: AuthenticationTypes.admin),
  Command('editMapSection', editMapSection, authenticationType: AuthenticationTypes.admin),
  Command('deleteMapSection', deleteMapSection, authenticationType: AuthenticationTypes.admin),

  // General commands.
  Command('serverTime', serverTime, authenticationType: AuthenticationTypes.any),
  Command('playerOption', playerOption),

  // Login commands.
  Command('createAccount', createAccount, authenticationType: AuthenticationTypes.anonymous),
  Command('login', login, authenticationType: AuthenticationTypes.anonymous),
  Command('createCharacter', createCharacter, authenticationType: AuthenticationTypes.account),
  Command('connectCharacter', connectCharacter, authenticationType: AuthenticationTypes.account),

  // Movement commands.
  Command('characterCoordinates', characterCoordinates),
  Command('characterTheta', characterTheta),
  Command('resetMapSection', resetMapSection),

  // Social commands:
  Command('say', say),
];

/// The final dictionary of commands.
///
/// It is this dictionary (not [commandsList]) that websockets use to find the command they want.
Map<String, Command> commands = <String, Command>{};
