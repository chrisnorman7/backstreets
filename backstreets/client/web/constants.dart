/// Provides various constants.
library constants;

import 'dart:html';

import 'package:game_utils/game_utils.dart';

import 'authentication.dart';
import 'commands/command_context.dart';
import 'hotkeys/movement.dart';
import 'run_conditions.dart';

/// The first part of any sound URL.
const String soundsDirectory = 'sounds/';

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

///Admin controls.
final Element adminControls = querySelector('#admin');
