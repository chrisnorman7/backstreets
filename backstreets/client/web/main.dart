/// Provides the [main] function.
library main;

import 'dart:convert';
import 'dart:html';
import 'dart:web_audio';

import 'commands/command_context.dart';
import 'commands/commands.dart';
import 'form_builder.dart';
import 'hotkeys/menu.dart';
import 'keyboard/hotkey.dart';
import 'keyboard/key_state.dart';
import 'keyboard/keyboard.dart';
import 'menus/book.dart';
import 'menus/main_menu.dart';
import 'sound/sound.dart';

/// The currently activated form builder.
FormBuilder currentFormBuilder;

/// Where to put new [FormBuilder]s, when calling [FormBuilder.render].
final Element formBuilderDiv = querySelector('#formBuilderDiv');

/// A book for menus.
Book book;

/// The context to call commands with.
CommandContext commandContext;

/// Set the document title. [state] will be shown in square brackets.
void setTitle({String state}) {
  document.title = 'Backstreets';
  if (state != null) {
    document.title += ' [$state]';
  }
}

/// The message aread.
final Element messageArea = querySelector('#message');

/// The keyboard area. This is a paragraph element that can be focussed.
final Element keyboardArea = querySelector('#keyboardArea');

/// Main entry point.
void main() {
  setTitle();
  final Keyboard keyboard = Keyboard();
  keyboard.addHotkeys(
    <Hotkey>[
      moveUp,
      moveDown,
      activateSpace,
      activateEnter,
      activateRightArrow ,
      cancelEscape,
      cancelLeftArrow,
    ]
  );
  keyboardArea.onKeyDown.listen((KeyboardEvent e) {
    if (currentFormBuilder != null) {
      return;
    }
    final KeyState ks = keyboard.press(e.key, shift: e.shiftKey, control: e.ctrlKey, alt: e.altKey);
    if (keyboard.hotkeys.where((Hotkey hk) => hk.state == ks).isNotEmpty) {
      e.preventDefault();
    }
  });
  keyboardArea.onKeyUp.listen((KeyboardEvent e) => keyboard.release(e.key));
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
      keyboardArea.focus();
      book = Book(sounds, (String message) => messageArea.innerText = message);
      book.push(mainMenu);
      commandContext = CommandContext(socket, (String message) {
        commandContext.messages.add(message);
        messageArea.innerText = message;
      }, sounds);
      setTitle(state: 'Connected');
    });
    socket.onClose.listen((Event e) {
      setTitle(state: 'Disconnected');
      mainDiv.hidden = true;
      startDiv.hidden = false;
    });
    socket.onMessage.listen((MessageEvent e) {
      final List<dynamic> data = jsonDecode(e.data as String) as List<dynamic>;
      final String commandName = data[0] as String;
      final List<dynamic> commandArgs = data[1] as List<dynamic>;
      if (commands.containsKey(commandName)) {
        commandContext.args = commandArgs;
        final CommandType command = commands[commandName];
        command(commandContext);
      } else {
        commandContext.message('Unrecognised command: $commandName.');
      }
    });
  });
}
