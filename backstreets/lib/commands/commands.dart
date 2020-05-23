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
import 'socials.dart';

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

  // Social commands:
  Command('say', say),
];

Map<String, Command> commands = <String, Command>{};
