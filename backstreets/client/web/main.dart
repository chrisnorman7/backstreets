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

import 'keyboard/hotkey.dart';
import 'keyboard/key_state.dart';
import 'keyboard/keyboard.dart';

import 'menus/book.dart';
import 'menus/main_menu.dart';

import 'sound/sound.dart';

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

/// Main entry point.
void main() {
  setTitle();
  keyboard.addHotkeys(
    <Hotkey>[
      // Building hotkeys.
      builderMenu,

      // General hotkeys.
      previousMessage,
      nextMessage,
      messages,

      // Menu hotkeys.
      moveUp,
      moveDown,
      activateSpace,
      activateEnter,
      activateRightArrow ,
      cancelEscape,
      cancelLeftArrow,

      /// Movement hotkeys.
      coordinates,
      mapName,
      facing,
      walkForwards,
      walkBackwards,
      left,
      leftSnap,
      right,
      rightSnap,
      aboutFace,
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
}
