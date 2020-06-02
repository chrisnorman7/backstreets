/// Used for storing commands.
///
/// To create more commands, add them to [commandsList].
///
/// ```
/// commandsList.add(Command((CommandContext ctx) => ctx.sendMessage('The current time is ${DateTime.now()}.')));
/// // OR:
/// commandsList.add(Command(someFunction));
/// ```
///
/// The [buildCommands] function will handle setting command names (unless you do it yourself), and moving them into the [commands.commands] dictionary.
library commands;

import 'admin.dart';
import 'builder.dart';
import 'building.dart';
import 'command.dart';
import 'general.dart';
import 'login.dart';
import 'movement.dart';
import 'socials.dart';
import 'staff.dart';

/// The list of pre-processed commands.
///
/// The [buildCommands] function migrates them to the [commands.commands] dictionary.
List<Command> commandsList = <Command>[
  // Admin commands:
  Command(adminPlayerList, authenticationType: AuthenticationTypes.admin),
  Command(renameObject, authenticationType: AuthenticationTypes.admin),
  Command(setObjectPermission, authenticationType: AuthenticationTypes.admin),
  Command(addMap, authenticationType: AuthenticationTypes.admin),
  Command(deleteGameMap, authenticationType: AuthenticationTypes.admin),

  // Building commands:
  Command(renameMap, authenticationType: AuthenticationTypes.builder),
  Command(addMapSection, authenticationType: AuthenticationTypes.builder),
  Command(mapAmbience, authenticationType: AuthenticationTypes.builder),
  Command(editMapSection, authenticationType: AuthenticationTypes.builder),
  Command(deleteMapSection, authenticationType: AuthenticationTypes.builder),
  Command(mapConvolver, authenticationType: AuthenticationTypes.builder),
  Command(addWall, authenticationType: AuthenticationTypes.builder),
  Command(addBarricade, authenticationType: AuthenticationTypes.builder),
  Command(deleteWall, authenticationType: AuthenticationTypes.builder),
  Command(mapSectionAmbience, authenticationType: AuthenticationTypes.builder),
  Command(setPlayersCanCreate, authenticationType: AuthenticationTypes.builder),
  Command(setPopCoordinates, authenticationType: AuthenticationTypes.builder),

  // General commands:
  Command(serverTime, authenticationType: AuthenticationTypes.any),
  Command(playerOption),

  // Login commands:
  Command(createAccount, authenticationType: AuthenticationTypes.anonymous),
  Command(login, authenticationType: AuthenticationTypes.anonymous),
  Command(createCharacter, authenticationType: AuthenticationTypes.account),
  Command(connectCharacter, authenticationType: AuthenticationTypes.account),

  // Movement commands:
  Command(characterCoordinates),
  Command(characterTheta),
  Command(resetMapSection),

  // Social commands:
  Command(say),

  // Staff only commands:
  Command(teleport, authenticationType: AuthenticationTypes.staff),
];

/// The final dictionary of commands.
///
/// It is this dictionary (not [commandsList]) that websockets use to find the command they want.
Map<String, Command> commands = <String, Command>{};
