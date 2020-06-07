/// Used for storing commands.
///
/// To create more commands, add them to [commands] dictionary.
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

  // Building commands:
  'renameMap': Command(renameMap, authenticationType: AuthenticationTypes.builder),
  'addMapSection': Command(addMapSection, authenticationType: AuthenticationTypes.builder),
  'mapAmbience': Command(mapAmbience, authenticationType: AuthenticationTypes.builder),
  'editMapSection': Command(editMapSection, authenticationType: AuthenticationTypes.builder),
  'deleteMapSection': Command(deleteMapSection, authenticationType: AuthenticationTypes.builder),
  'mapConvolver': Command(mapConvolver, authenticationType: AuthenticationTypes.builder),
  'addWall': Command(addWall, authenticationType: AuthenticationTypes.builder),
  'addBarricade': Command(addBarricade, authenticationType: AuthenticationTypes.builder),
  'deleteWall': Command(deleteWall, authenticationType: AuthenticationTypes.builder),
  'mapSectionAmbience': Command(mapSectionAmbience, authenticationType: AuthenticationTypes.builder),
  'setPlayersCanCreate': Command(setPlayersCanCreate, authenticationType: AuthenticationTypes.builder),
  'setPopCoordinates': Command(setPopCoordinates, authenticationType: AuthenticationTypes.builder),
  'addMapSectionAction': Command(addMapSectionAction, authenticationType: AuthenticationTypes.builder),
  'removeMapSectionAction': Command(removeMapSectionAction, authenticationType: AuthenticationTypes.builder),
  'addExit': Command(addExit, authenticationType: AuthenticationTypes.builder),
  'editExit': Command(editExit, authenticationType: AuthenticationTypes.builder),
  'deleteExit': Command(deleteExit, authenticationType: AuthenticationTypes.builder),
  'getObjects': Command(getObjects, authenticationType: AuthenticationTypes.builder),
  'addObject': Command(addObject, authenticationType: AuthenticationTypes.builder),
  'objectSpeed': Command(objectSpeed, authenticationType: AuthenticationTypes.builder),
  'objectMaxMoveTime': Command(objectMaxMoveTime, authenticationType: AuthenticationTypes.builder),
  'objectPhrase': Command(objectPhrase, authenticationType: AuthenticationTypes.builder),
  'objectMinPhraseTime': Command(objectMinPhraseTime, authenticationType: AuthenticationTypes.builder),
  'objectMaxPhraseTime': Command(objectMaxPhraseTime, authenticationType: AuthenticationTypes.builder),
  'objectFlying': Command(objectFlying, authenticationType: AuthenticationTypes.builder),

  // General commands:
  'serverTime': Command(serverTime, authenticationType: AuthenticationTypes.any),
  'playerOption': Command(playerOption),
  'action': Command(action),

  // Login commands:
  'createAccount': Command(createAccount, authenticationType: AuthenticationTypes.anonymous),
  'login': Command(login, authenticationType: AuthenticationTypes.anonymous),
  'createCharacter': Command(createCharacter, authenticationType: AuthenticationTypes.account),
  'connectCharacter': Command(connectCharacter, authenticationType: AuthenticationTypes.account),

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
};
