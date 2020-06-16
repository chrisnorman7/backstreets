/// Provides various constants.
library constants;

import 'dart:html';

import 'package:game_utils/game_utils.dart';

import 'authentication.dart';
import 'commands/command_context.dart';
import 'hotkeys/admin.dart';
import 'hotkeys/building.dart';
import 'hotkeys/general.dart';
import 'hotkeys/movement.dart';
import 'hotkeys/socials.dart';
import 'hotkeys/staff.dart';
import 'run_conditions.dart';

/// The first part of any sound URL.
const String soundsDirectory = 'sounds/';

/// The sound to play for exits.
const String exitSoundUrl = soundsDirectory + 'general/exit.wav';

/// Character data, as sent to the [account] command.
List<dynamic> characterList;

/// Where to put new [FormBuilder]s, when calling [FormBuilder.render].
final Element formBuilderDiv = querySelector('#formBuilderDiv');

/// The context to call commands with.
CommandContext commandContext;

/// The current stage in the authentication process.
AuthenticationStages authenticationStage;

/// The hotkey for forward movement.
final Hotkey walkForwardsHotkey = Hotkey(keyboard, 'w', walkForwards, interval: 50, runWhen: validMap, titleString: 'Move forward');

/// The hotkey for moving backwards;
final Hotkey walkBackwardsHotkey = Hotkey(keyboard, 's', walkBackwards, shift: true, interval: 50, runWhen: validMap, titleString: 'Move backwards');

/// The options for any books that get created.
BookOptions bookOptions;

/// The message aread.
final Element messageArea = querySelector('#message');

/// The div that holds all past messages.
final Element messagesDiv = querySelector('#messages');

/// The keyboard area. This is a paragraph element that can be focussed.
final Element keyboardArea = querySelector('#keyboardArea');

/// The interface to [Hotkey] processing.
Keyboard keyboard;

/// What each of the mouse keys do.
final Map<int, Hotkey> mouseButtons = <int, Hotkey>{
  2: walkForwardsHotkey,
};

/// The buttons used for interracting with books.
final Element bookControls = querySelector('#book');

/// The standard controls.
final Element standardControls = querySelector('#standard');

/// Builder controls.
final Element builderControls = querySelector('#builder');

/// Staff controls.
final Element staffControls = querySelector('#staff');

///Admin controls.
final Element adminControls = querySelector('#admin');

/// Various hotkeys:
final Hotkey escapeHotkey = Hotkey(keyboard, 'escape', escapeKey, titleString: 'Various escape / reset actions');
final Hotkey upArrowHotkey = Hotkey(keyboard, 'arrowup', upArrow, titleString: 'Up arrow');
final Hotkey downArrowHotkey = Hotkey(keyboard, 'arrowdown', downArrow, titleString: 'down arrow');
final Hotkey enterHotkey = Hotkey(keyboard, 'enter', enterKey, titleString: 'Performs a multitude of actions');
final Hotkey coordinatesHotkey = Hotkey(keyboard, 'c', coordinates,runWhen: validMap, titleString: 'Show your coordinates');
final Hotkey leftSnapHotkey = Hotkey(keyboard, 'a', leftSnap, runWhen: validMap, titleString: 'Snap left to the nearest cardinal direction');
final Hotkey rightSnapHotkey = Hotkey(keyboard, 'd', rightSnap, runWhen: validMap, titleString: 'Snap right to the nearest cardinal direction');
final Hotkey sayHotkey = Hotkey(keyboard, "'", say, runWhen: validMap, titleString: 'Say something to other players nearby');
final Hotkey builderMenuHotkey = Hotkey(keyboard, 'b', builderMenu, runWhen: staffOnly, titleString: 'Builder menu');
final Hotkey wallMenuHotkey = Hotkey(keyboard, 'w', wallMenu, shift: true, runWhen: staffOnly, titleString: 'Wall menu');
final Hotkey adminMenuHotkey = Hotkey(keyboard, 'backspace', adminMenu, runWhen: adminOnly, titleString: 'Admin Menu');
final Hotkey teleportHotkey = Hotkey(keyboard, 't', teleport, runWhen: staffOnly, titleString: 'Teleport to another map');

/// All the hotkeys which can be triggered by buttons in the DOM.
final Map<String, Hotkey> buttonHotkeys = <String, Hotkey>{
  'escape': escapeHotkey,
  'cancel': escapeHotkey,
  'up': upArrowHotkey,
  'down': downArrowHotkey,
  'enter': enterHotkey,
  'activate': enterHotkey,
  'coordinates': coordinatesHotkey,
  'w': walkForwardsHotkey,
  'a': leftSnapHotkey,
  's': walkBackwardsHotkey,
  'd': rightSnapHotkey,
  'say': sayHotkey,
  'builderMenu': builderMenuHotkey,
  'wallMenu': wallMenuHotkey,
  'adminMenu': adminMenuHotkey,
  'teleport': teleportHotkey,
};
