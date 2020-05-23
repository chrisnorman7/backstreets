/// Provides the [main] function.
library main;

import 'dart:convert';
import 'dart:html';
import 'dart:web_audio';

import 'authentication.dart';

import 'commands/command_context.dart';
import 'commands/commands.dart';
import 'commands/login.dart';

import 'form_builder.dart';

import 'hotkeys/building.dart';
import 'hotkeys/general.dart';
import 'hotkeys/menu.dart';
import 'hotkeys/movement.dart';
import 'hotkeys/socials.dart';
import 'hotkeys/sound.dart';

import 'keyboard/hotkey.dart';
import 'keyboard/key_state.dart';
import 'keyboard/keyboard.dart';

import 'menus/book.dart';
import 'menus/main_menu.dart';

import 'run_conditions.dart';

import 'sound/sound_pool.dart';

/// Character data, as sent to the [account] command.
List<dynamic> characterList;

/// The currently activated form builder.
FormBuilder currentFormBuilder;

/// Where to put new [FormBuilder]s, when calling [FormBuilder.render].
final Element formBuilderDiv = querySelector('#formBuilderDiv');

/// The context to call commands with.
CommandContext commandContext;

/// The current stage in the authentication process.
AuthenticationStages authenticationStage;

/// The hotkey for forward movement.
final Hotkey walkForwardsHotkey = Hotkey('w', walkForwards, interval: 50, runWhen: validMap, titleString: 'Move forward');

/// The hotkey for moving backwards;
final Hotkey walkBackwardsHotkey = Hotkey('s', walkBackwards, shift: true, interval: 50, runWhen: validMap);

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
  setTitle();
  keyboard.addHotkeys(
    <Hotkey>[
      // Building hotkeys:
      Hotkey('b', builderMenu, runWhen: adminOnly),

      // General hotkeys:
      Hotkey('.', previousMessage),
      Hotkey(',', nextMessage),
      Hotkey('/', messages),

      // Menu hotkeys:
      Hotkey('arrowup', moveUp, runWhen: validBook, titleString: 'Move up in a menu'),
      Hotkey('arrowdown', moveDown, runWhen: validBook, titleString: 'Move down in a menu'),
      Hotkey(' ', activateSpace, runWhen: validBook, titleString: 'Activate a menu item'),
      Hotkey('enter', activateEnter, runWhen: validBook, titleString: 'Activate a menu item'),
      Hotkey('arrowright', activateRightArrow , runWhen: validBook, titleString: 'Activate a menu item'),
      Hotkey('escape', cancelEscape, runWhen: validBook, titleString: 'Go back to the previous menu'),
      Hotkey('arrowleft', cancelLeftArrow, runWhen: validBook, titleString: 'Go back to the previous menu'),

      /// Movement hotkeys:
      Hotkey('c', coordinates,runWhen: validMap, titleString: 'Show coordinates'),
      Hotkey('v', mapName, runWhen: validMap, titleString: 'View your current location'),
      Hotkey('f', facing, runWhen: validMap, titleString: 'Show which way you are facing'),
      walkForwardsHotkey,
      walkBackwardsHotkey,
      Hotkey('a', left, runWhen: validMap, titleString: 'Turn left a bit'),
      Hotkey('a', leftSnap, shift: true, runWhen: validMap, titleString: 'Snap left to the nearest cardinal direction'),
      Hotkey('d', right, runWhen: validMap, titleString: 'Turn right a bit'),
      Hotkey('d', rightSnap, shift: true, runWhen: validMap, titleString: 'Snap right to the nearest cardinal direction'),
      Hotkey('s', aboutFace, runWhen: validMap),

      // Social hotkeys:
      Hotkey("'", say, runWhen: validMap),

      // Sound hotkeys:
      Hotkey('j', soundVolumeDown, shift: true, runWhen: validSounds),
      Hotkey('j', soundVolumeUp, runWhen: validSounds),
      Hotkey('k', ambienceVolumeDown, shift: true, runWhen: validSounds),
      Hotkey('k', ambienceVolumeUp, runWhen: validSounds),
      Hotkey('l', musicVolumeDown, shift: true, runWhen: validSounds),
      Hotkey('l', musicVolumeUp, runWhen: validSounds),
    ]
  );
  keyboardArea.onKeyDown.listen((KeyboardEvent e) {
    if (currentFormBuilder == null) {
      final KeyState ks = keyboard.press(e.key.toLowerCase(), shift: e.shiftKey, control: e.ctrlKey, alt: e.altKey);
      if (keyboard.hotkeys.where((Hotkey hk) => hk.state == ks).isNotEmpty) {
        e.preventDefault();
      }
    }
  });
  keyboardArea.onKeyUp.listen((KeyboardEvent e) => keyboard.release(e.key.toLowerCase()));
  final Element startDiv = querySelector('#startDiv');
  final Element startButton = querySelector('#startButton');
  final Element mainDiv = querySelector('#main');
  startDiv.hidden = false;
  startButton.onClick.listen((Event event) {
    final AudioContext audio = AudioContext();
    final SoundPool sounds = SoundPool(audio);
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
      commandContext.book = Book(sounds, showMessage)
        ..push(mainMenu());
      setTitle(state: 'Connected');
    });
    socket.onClose.listen((CloseEvent e) {
      startButton.innerText = 'Reconnect';
      showMessage('Connection lost: ${e.reason.isNotEmpty ? e.reason : "No reason given."} (${e.code})');
      authenticationStage = null;
      setTitle(state: 'Disconnected');
      if (commandContext.ambience != null) {
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
