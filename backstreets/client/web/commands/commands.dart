/// The main commands library. Contains the [commands] [Map].
library commands;

import 'command_context.dart';
import 'general.dart';
import 'login.dart';
import 'movement.dart';
import 'sound.dart';

/// The type for all command functions.
typedef CommandType = void Function(CommandContext);

/// A map containing all the commands which can be called by the server.
Map<String, CommandType> commands = <String, CommandType>{
  // General commands:
  'message': message,
  'error': error,
  'playerOptions': playerOptions,
  'listOfObjects': listOfObjects,
  'actionFunctions': actionFunctions,
  'confirmAction': confirmAction,
  'accounts': accounts,
  'menu': menu,
  'editRadioChannel': editRadioChannel,

  // Login commands:
  'account': account,
  'characterName': characterName,
  'builder': builder,
  'admin': admin,

  // Movement commands:
  'characterCoordinates': characterCoordinates,
  'mapName': mapName,
  'tileNames': tileNames,
  'footstepSound': footstepSound,
  'mapData': mapData,
  'characterSpeed': characterSpeed,
  'characterTheta': characterTheta,
  'renameSection': renameSection,
  'sectionTileName': sectionTileName,
  'mapSection': mapSection,
  'mapAmbience': mapAmbience,
  'deleteMapSection': deleteMapSection,
  'mapConvolver': mapConvolver,
  'mapWall': mapWall,
  'deleteWall': deleteWall,
  'mapSectionAmbience': mapSectionAmbience,
  'addGameMap': addGameMap,
  'deleteGameMap': deleteGameMap,
  'setPlayersCanCreate': setPlayersCanCreate,
  'addMapSectionAction': addMapSectionAction,
  'removeMapSectionAction': removeMapSectionAction,
  'addExit': addExit,
  'deleteExit': deleteExit,
  'objectMoved': objectMoved,

  // Sound commands:
  'interfaceSound': interfaceSound,
  'sound': sound,
  'ambiences': ambiences,
  'impulses': impulses,
  'echoSounds': echoSounds,
  'exitSound': exitSound,
  'phrases': phrases,
  'actionSounds': actionSounds,
  'radioSound': radioSound,
};
