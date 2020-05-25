/// Provides the [main] function.
library main;

import 'dart:convert';
import 'dart:html';
import 'dart:web_audio';

import 'package:game_utils/game_utils.dart';

import 'authentication.dart';

import 'commands/command_context.dart';
import 'commands/commands.dart';
import 'commands/login.dart';

import 'hotkeys/building.dart';
import 'hotkeys/general.dart';
import 'hotkeys/menu.dart';
import 'hotkeys/movement.dart';
import 'hotkeys/socials.dart';
import 'hotkeys/sound.dart';

import 'menus/main_menu.dart';

import 'run_conditions.dart';

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

/// Set the document title. [state] will be shown in square brackets.
void setTitle({String state}) {
  document.title = 'Backstreets';
  if (state != null) {
    document.title += ' [$state]';
  }
}

/// The message aread.
final Element messageArea = querySelector('#message');

/// Show a message.
void showMessage(String text) {
  messageArea.innerText = text;
}

/// The keyboard area. This is a paragraph element that can be focussed.
final Element keyboardArea = querySelector('#keyboardArea');

/// The interface to [Hotkey] processing.
final Keyboard keyboard = Keyboard((dynamic e, StackTrace s) {
  showMessage(e.toString());
  throw e;
}, unhandledKey: (KeyState ks) {
  if (commandContext.book != null && !ks.shift && !ks.control && !ks.alt) {
    commandContext.book.handleSearch(ks.key);
  }
});

/// What each of the mouse keys do.
final Map<int, Hotkey> mouseButtons = <int, Hotkey>{
  2: walkForwardsHotkey,
};

/// Main entry point.
void main() {
  const String activateString = 'Activate a menu item';
  const String cancelString = 'Close the current menu, or go back to the previous one';
  setTitle();
  keyboard.addHotkeys(
    <Hotkey>[
      // Building hotkeys:
      Hotkey(keyboard, 'b', builderMenu, runWhen: builderOnly, titleString: 'Builder menu'),

      // General hotkeys:
      Hotkey(keyboard, '.', previousMessage, titleString: 'Show previous message'),
      Hotkey(keyboard, ',', nextMessage, titleString: 'Show next message'),
      Hotkey(keyboard, '/', messages, titleString: 'Show all messages in a list'),
      Hotkey(keyboard, '?', hotkeys, shift: true, runWhen: validMap, titleString: 'Show a menu containing all hotkeys'),

      // Menu hotkeys:
      Hotkey(keyboard, 'arrowup', moveUp, runWhen: validBook, titleString: 'Move up in a menu'),
      Hotkey(keyboard, 'arrowdown', moveDown, runWhen: validBook, titleString: 'Move down in a menu'),
      Hotkey(keyboard, ' ', activateSpace, runWhen: validBook, titleString: activateString),
      Hotkey(keyboard, 'enter', activateEnter, runWhen: validBook, titleString: activateString),
      Hotkey(keyboard, 'arrowright', activateRightArrow , runWhen: validBook, titleString: activateString),
      Hotkey(keyboard, 'escape', cancelEscape, runWhen: validBook, titleString: cancelString),
      Hotkey(keyboard, 'arrowleft', cancelLeftArrow, runWhen: validBook, titleString: cancelString),

      /// Movement hotkeys:
      Hotkey(keyboard, 'c', coordinates,runWhen: validMap, titleString: 'Show your coordinates'),
      Hotkey(keyboard, 'v', mapName, runWhen: validMap, titleString: 'View your current location'),
      Hotkey(keyboard, 'f', facing, runWhen: validMap, titleString: 'Show which way you are facing'),
      walkForwardsHotkey,
      walkBackwardsHotkey,
      Hotkey(keyboard, 'a', left, runWhen: validMap, titleString: 'Turn left a bit'),
      Hotkey(keyboard, 'a', leftSnap, shift: true, runWhen: validMap, titleString: 'Snap left to the nearest cardinal direction'),
      Hotkey(keyboard, 'd', right, runWhen: validMap, titleString: 'Turn right a bit'),
      Hotkey(keyboard, 'd', rightSnap, shift: true, runWhen: validMap, titleString: 'Snap right to the nearest cardinal direction'),
      Hotkey(keyboard, 's', aboutFace, runWhen: validMap, titleString: 'Turn around'),

      // Social hotkeys:
      Hotkey(keyboard, "'", say, runWhen: validMap, titleString: 'Say something to other players nearby'),

      // Sound hotkeys:
      Hotkey(keyboard, 'j', soundVolumeDown, shift: true, runWhen: validSounds, titleString: 'Reduce the volume of game sounds'),
      Hotkey(keyboard, 'j', soundVolumeUp, runWhen: validSounds, titleString: 'Increase the volume of game sounds'),
      Hotkey(keyboard, 'k', ambienceVolumeDown, shift: true, runWhen: validSounds, titleString: 'Reduce the volume of the map ambience'),
      Hotkey(keyboard, 'k', ambienceVolumeUp, runWhen: validSounds, titleString: 'Increase the volume of the map ambience'),
      Hotkey(keyboard, 'l', musicVolumeDown, shift: true, runWhen: validSounds, titleString: 'Reduce the volume of game music'),
      Hotkey(keyboard, 'l', musicVolumeUp, runWhen: validSounds, titleString: 'Increase the volume of game music'),
    ]
  );
  keyboardArea.onKeyDown.listen((KeyboardEvent e) {
    final KeyState ks = keyboard.press(e.key.toLowerCase(), shift: e.shiftKey, control: e.ctrlKey, alt: e.altKey);
    if (keyboard.hotkeys.where((Hotkey hk) => hk.state == ks).isNotEmpty) {
      e.preventDefault();
    }
  });
  keyboardArea.onKeyUp.listen((KeyboardEvent e) => keyboard.release(e.key.toLowerCase()));
  final Element startDiv = querySelector('#startDiv');
  final Element startButton = querySelector('#startButton');
  final Element mainDiv = querySelector('#main');
  startDiv.hidden = false;
  startButton.onClick.listen((Event event) {
    final AudioContext audio = AudioContext();
    final SoundPool sounds = SoundPool(audio, showMessage: showMessage);
    sounds.playSound('sounds/general/start.wav');
    startDiv.hidden = true;
    mainDiv.hidden = false;
    final WebSocket socket = WebSocket('ws://${window.location.hostname}:8888/ws');
    setTitle(state: 'Connecting');
    socket.onOpen.listen((Event e) {
      authenticationStage = AuthenticationStages.anonymous;
      keyboardArea.focus();
      commandContext = CommandContext(socket, (String message) {
        commandContext.messages.add(message);
        showMessage(message);
      }, sounds);
      bookOptions = BookOptions(sounds, showMessage);
      commandContext.book = Book(bookOptions)
        ..push(mainMenu());
      setTitle(state: 'Connected');
    });
    socket.onClose.listen((CloseEvent e) {
      startButton.innerText = 'Reconnect';
      showMessage('Connection lost: ${e.reason.isNotEmpty ? e.reason : "No reason given."} (${e.code})');
      authenticationStage = null;
      setTitle(state: 'Disconnected');
      if (commandContext != null && commandContext.ambience != null) {
        commandContext.ambience.stop();
      }
      commandContext = null;
      mainDiv.hidden = true;
      startDiv.hidden = false;
      startButton.focus();
    });
    socket.onMessage.listen((MessageEvent e) async {
      final List<dynamic> data = jsonDecode(e.data as String) as List<dynamic>;
      final String commandName = data[0] as String;
      final List<dynamic> commandArgs = data[1] as List<dynamic>;
      if (commands.containsKey(commandName)) {
        commandContext.args = commandArgs;
        final CommandType command = commands[commandName];
        try {
          await command(commandContext);
        }
        catch (e, s) {
          commandContext.message('${e.toString()}\n${s.toString()}');
        }
      } else {
        commandContext.message('Unrecognised command: $commandName.');
      }
    });
  });
  document.onMouseDown.listen((MouseEvent e) {
    e.stopPropagation();
    e.preventDefault();
    if (mouseButtons.containsKey(e.button)) {
      final Hotkey hk = mouseButtons[e.button];
      if (!keyboard.heldKeys.contains(hk.state)) {
        keyboard.heldKeys.add(hk.state);
      }
      hk.startTimer();
    } else {
      showMessage('Mouse ${e.button}.');
    }
  });
  document.onMouseUp.listen((MouseEvent e) {
    e.stopPropagation();
    e.preventDefault();
    if (mouseButtons.containsKey(e.button)) {
      final Hotkey hk = mouseButtons[e.button];
      if (keyboard.heldKeys.contains(hk.state)) {
        keyboard.heldKeys.remove(hk.state);
      }
      if (hk.timer != null) {
        hk.stopTimer();
      }
    }
  });
  document.onContextMenu.listen((MouseEvent e) => e.preventDefault());
}
