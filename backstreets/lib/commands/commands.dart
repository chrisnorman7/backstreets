/// Used for storing commands.
///
/// To create more commands, add them to the [commands] dictionary.
///
/// ```
/// commands['time'] = Command((CommandContext ctx) async => ctx.message('The current time is ${DateTime.now()}.'));
/// // Or:
/// commands['someFunction'] = Command(someFunction);
/// ```
///
/// The [buildCommands] function will handle setting command names (unless you do it yourself), and moving them into the [commands.commands] dictionary.
library commands;

import 'admin.dart';
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
Map<String, Command> commands = <String, Command>{
  // Admin commands:
  'adminPlayerList': Command(adminPlayerList, authenticationType: AuthenticationTypes.admin),
  'setObjectPermission': Command(setObjectPermission, authenticationType: AuthenticationTypes.admin),
  'addMap': Command(addMap, authenticationType: AuthenticationTypes.admin),
  'deleteGameMap': Command(deleteGameMap, authenticationType: AuthenticationTypes.admin),
  'revokeBuilderPermissions': Command(revokeBuilderPermissions, authenticationType: AuthenticationTypes.admin),
  'getPossibleOwners': Command(getPossibleOwners, authenticationType: AuthenticationTypes.admin),
  'bootPlayer': Command(bootPlayer, authenticationType: AuthenticationTypes.admin),
  'lockAccount': Command(lockAccount, authenticationType: AuthenticationTypes.admin),
  'accounts': Command(accounts, authenticationType: AuthenticationTypes.admin),
  'broadcast': Command(broadcast, authenticationType: AuthenticationTypes.admin),
  'radioChannelHistory': Command(radioChannelHistory, authenticationType: AuthenticationTypes.admin),
  'editRadioChannel': Command(editRadioChannel, authenticationType: AuthenticationTypes.admin),

  // Building commands (marked as "Staff-only"):
  'renameMap': Command(renameMap, authenticationType: AuthenticationTypes.staff),
  'addMapSection': Command(addMapSection, authenticationType: AuthenticationTypes.staff),
  'mapAmbience': Command(mapAmbience, authenticationType: AuthenticationTypes.staff),
  'editMapSection': Command(editMapSection, authenticationType: AuthenticationTypes.staff),
  'deleteMapSection': Command(deleteMapSection, authenticationType: AuthenticationTypes.staff),
  'mapConvolver': Command(mapConvolver, authenticationType: AuthenticationTypes.staff),
  'addWall': Command(addWall, authenticationType: AuthenticationTypes.staff),
  'addBarricade': Command(addBarricade, authenticationType: AuthenticationTypes.staff),
  'deleteWall': Command(deleteWall, authenticationType: AuthenticationTypes.staff),
  'mapSectionAmbience': Command(mapSectionAmbience, authenticationType: AuthenticationTypes.staff),
  'setPlayersCanCreate': Command(setPlayersCanCreate, authenticationType: AuthenticationTypes.staff),
  'setPopCoordinates': Command(setPopCoordinates, authenticationType: AuthenticationTypes.staff),
  'addMapSectionAction': Command(addMapSectionAction, authenticationType: AuthenticationTypes.staff),
  'removeMapSectionAction': Command(removeMapSectionAction, authenticationType: AuthenticationTypes.staff),
  'editMapSectionAction': Command(editMapSectionAction, authenticationType: AuthenticationTypes.staff),
  'addExit': Command(addExit, authenticationType: AuthenticationTypes.staff),
  'editExit': Command(editExit, authenticationType: AuthenticationTypes.staff),
  'deleteExit': Command(deleteExit, authenticationType: AuthenticationTypes.staff),
  'getObjects': Command(getObjects, authenticationType: AuthenticationTypes.staff),
  'addObject': Command(addObject, authenticationType: AuthenticationTypes.staff),
  'deleteObject': Command(deleteObject, authenticationType: AuthenticationTypes.staff),
  'editObject': Command(editObject, authenticationType: AuthenticationTypes.staff),

  // General commands:
  'serverTime': Command(serverTime, authenticationType: AuthenticationTypes.any),
  'playerOption': Command(playerOption),
  'action': Command(action),
  'resetPassword': Command(resetPassword),
  'connectedTime': Command(connectedTime),
  'who': Command(who),
  'confirmAction': Command(confirmAction),
  'cancelAction': Command(cancelAction),
  'stepCount': Command(stepCount),
  'transmit': Command(transmit),
  'listRadioChannels': Command(listRadioChannels),
  'selectRadioChannel': Command(selectRadioChannel),

  // Login commands:
  'createAccount': Command(createAccount, authenticationType: AuthenticationTypes.anonymous),
  'login': Command(login, authenticationType: AuthenticationTypes.anonymous),
  'createCharacter': Command(createCharacter, authenticationType: AuthenticationTypes.account),
  'connectCharacter': Command(connectCharacter, authenticationType: AuthenticationTypes.account),
  'logout': Command(logout),

  // Movement commands:
  'characterCoordinates': Command(characterCoordinates),
  'characterTheta': Command(characterTheta),
  'resetMapSection': Command(resetMapSection),
  'exit': Command(exit),

  // Social commands:
  'say': Command(say),

  // Staff only commands:
  'teleport': Command(teleport, authenticationType: AuthenticationTypes.staff),
  'renameObject': Command(renameObject, authenticationType: AuthenticationTypes.staff),
  'summonObject': Command(summonObject, authenticationType: AuthenticationTypes.staff),
  'addBuilderPermission': Command(addBuilderPermission, authenticationType: AuthenticationTypes.staff),
  'removeBuilderPermission': Command(removeBuilderPermission, authenticationType: AuthenticationTypes.staff),
  'getMapBuilders': Command(getMapBuilders, authenticationType: AuthenticationTypes.staff),
  'addMapBuilder': Command(addMapBuilder, authenticationType: AuthenticationTypes.staff),
  'addRadioChannel': Command(addRadioChannel, authenticationType: AuthenticationTypes.staff),
};
