/// Provides the [main] function.
library main;

import 'dart:convert';
import 'dart:html';
import 'dart:web_audio';

import 'package:game_utils/game_utils.dart';

import 'authentication.dart';
import 'commands/command_context.dart';
import 'commands/commands.dart';
import 'constants.dart';
import 'hotkeys/building.dart';
import 'hotkeys/general.dart';
import 'hotkeys/menu.dart';
import 'hotkeys/movement.dart';
import 'hotkeys/sound.dart';
import 'hotkeys/staff.dart';
import 'menus/main_menu.dart';
import 'run_conditions.dart';
import 'util.dart';

/// The div containing [startButton].
final Element startDiv = querySelector('#startDiv');

/// The button which should start everything off.
final Element startButton = querySelector('#startButton');  final Element mainDiv = querySelector('#main');

/// Set the document title. [state] will be shown in square brackets.
void setTitle({String state}) {
  document.title = 'Backstreets';
  if (state != null) {
    document.title += ' [$state]';
  }
}

/// Remember whether or not the last message was important.
bool rememberLastMessage;

/// Show a message.
void showMessage(String text, {bool important = true}) {
  if (rememberLastMessage == true && messageArea.innerText != text) {
    final ParagraphElement p = ParagraphElement()
      ..innerText = messageArea.innerText;
    messagesDiv.append(p);
    messagesDiv.scroll();
  }
  rememberLastMessage = important;
  messageArea.innerText = text;
}

/// The URL to use for websockets.
///
///Doesn't include the "ws" part, as that is changeable.
final String socketUrl = '${window.location.hostname}:8888/ws';

/// The websocket to use.
WebSocket socket;

/// A function to build a socket.
void createSocket(String url, [bool reconnect = true]) {
  socket = WebSocket(url)
    ..onOpen.listen(onOpen)
    ..onMessage.listen(onMessage)
    ..onClose.listen((CloseEvent e) {
      if (connectedAt == null && reconnect) {
        createSocket('ws://$socketUrl', false);
      } else {
        onClose(e);
      }
    });
}

/// The time [socket] connected at.
DateTime connectedAt;

/// The soundpool to use.
SoundPool sounds;

/// The callback to run when the websocket gets opened.
void onOpen(Event e) {
  connectedAt = DateTime.now();
  authenticationStage = AuthenticationStages.anonymous;
  keyboardArea.focus();
  keyboard.releaseAll();
  commandContext = CommandContext(socket, showMessage, sounds);
  commandContext.book = Book(bookOptions)
    ..push(mainMenu());
  setTitle(state: 'Connected');
}

/// The callback to call when [socket] closes.
void onClose(CloseEvent e) {
  startButton.innerText = 'Reconnect';
  document.exitPointerLock();
  if (connectedAt == null) {
    showMessage('Connection failed. The server seems to be down.');
  } else {
    showMessage('Connection lost: ${e.reason.isNotEmpty ? e.reason : "No reason given."} (${e.code})');
    connectedAt = null;
  }
  authenticationStage = null;
  setTitle(state: 'Disconnected');
  if (commandContext?.map != null) {
    commandContext.map.stop();
  }
  commandContext = null;
  mainDiv.hidden = true;
  startDiv.hidden = false;
  startButton.focus();
}

/// The callback for when [socket] receives a message.
void onMessage(MessageEvent e) {
  final List<dynamic> data = jsonDecode(e.data as String) as List<dynamic>;
  final String commandName = data[0] as String;
  final List<dynamic> commandArgs = data[1] as List<dynamic>;
  if (commands.containsKey(commandName)) {
    commandContext.args = commandArgs;
    final CommandType command = commands[commandName];
    try {
      command(commandContext);
    }
    catch (e, s) {
      commandContext.message('${e.toString()}\n${s.toString()}');
    }
  } else {
    commandContext.message('Unrecognised command: $commandName.');
  }
}

/// Main entry point.
void main() {
  keyboard = Keyboard((dynamic e, StackTrace s) {
    showMessage('$e\n$s');
    throw e;
  }, unhandledKey: (KeyState ks) {
    if (commandContext?.helpMode == true) {
      commandContext?.message(ks.toString());
    }
    if (commandContext.book != null && !ks.shift && !ks.control && !ks.alt) {
      commandContext.book.handleSearch(ks.key);
    }
  });
  setTitle();
  keyboard.addHotkeys(
    <Hotkey>[
      // Admin hotkeys:
      adminMenuHotkey,

      // Building hotkeys:
      builderMenuHotkey,
      Hotkey(keyboard, '[', buildWall, runWhen: staffOnly, titleString: 'Build a wall at your current coordinates'),
      Hotkey(keyboard, ']', buildBarricade, runWhen: staffOnly, titleString: 'Build a barricade at your current coordinates'),
      wallMenuHotkey,

      // General hotkeys:
      Hotkey(keyboard, '.', previousMessage, runWhen: validCommandContext, titleString: 'Show previous message'),
      Hotkey(keyboard, '>', firstMessage, shift: true, runWhen: validCommandContext, titleString: 'Show the first message'),
      Hotkey(keyboard, ',', nextMessage, runWhen: validCommandContext, titleString: 'Show next message'),
      Hotkey(keyboard, '<', lastMessage, shift: true, runWhen: validCommandContext, titleString: 'Show the last message'),
      Hotkey(keyboard, '/', messages, titleString: 'Show all messages in a list', runWhen: validCommandContext),
      Hotkey(keyboard, '?', hotkeys, shift: true, runWhen: validMap, titleString: 'Show a menu containing all hotkeys'),
      Hotkey(keyboard, 'arrowleft', leftArrow, titleString: 'Left arrow'),
      Hotkey(keyboard, 'arrowright', rightArrow, titleString: 'Right arrow'),
      upArrowHotkey,
      downArrowHotkey,
      escapeHotkey,
      enterHotkey,
      Hotkey(keyboard, 'z', showActions, titleString: 'Shows the possible actions for the current section of the map', runWhen: validMap),
      Hotkey(keyboard, 'e', showWho, runWhen: validMap, titleString: 'Show who is connected'),
      Hotkey(keyboard, 'r', selectRadioChannel, runWhen: validMap, titleString: 'Select a radio channel to send and receive'),
      Hotkey(keyboard, 't', transmit, runWhen: validMap, titleString: 'Transmit on your current radio channel'),

      // Menu hotkeys:
      Hotkey(keyboard, ' ', activateSpace, runWhen: validBook, titleString: 'Activate a menu item'),

      // Movement hotkeys:
      coordinatesHotkey,
      Hotkey(keyboard, 'v', mapName, runWhen: validMap, titleString: 'View your current location'),
      Hotkey(keyboard, 'f', facing, runWhen: validMap, titleString: 'Show which way you are facing'),
      Hotkey(keyboard, 'f', showTheta, shift: true, runWhen: validMap, titleString: 'Show your heading in degrees'),
      walkForwardsHotkey,
      walkBackwardsHotkey,
      Hotkey(keyboard, 'a', left, shift: true, runWhen: validMap, titleString: 'Turn left a bit'),
      leftSnapHotkey,
      Hotkey(keyboard, 'd', right, shift: true, runWhen: validMap, titleString: 'Turn right a bit'),
      rightSnapHotkey,
      Hotkey(keyboard, ' ', aboutFace, runWhen: validMap, titleString: 'Turn around'),
      Hotkey(keyboard, 'v', sectionSize, shift: true, runWhen: validMap, titleString: 'Show the size of the current section.'),
      Hotkey(keyboard, 'c', mapSize, shift: true, runWhen: validMap, titleString: 'Show the size of the current map.'),
      Hotkey(keyboard, 'x', showExits, runWhen: validMap, titleString: 'Show any exits that are at your current coordinates.'),
      Hotkey(keyboard, 'x', nearestExit, shift: true, runWhen: validMap, titleString: 'Show the nearest exit.'),

      // Social hotkeys:
      sayHotkey,

      // Sound hotkeys:
      Hotkey(keyboard, 'j', soundVolumeDown, shift: true, runWhen: validSounds, titleString: 'Reduce the volume of game sounds'),
      Hotkey(keyboard, 'j', soundVolumeUp, runWhen: validSounds, titleString: 'Increase the volume of game sounds'),
      Hotkey(keyboard, 'k', ambienceVolumeDown, shift: true, runWhen: validSounds, titleString: 'Reduce the volume of the map ambience'),
      Hotkey(keyboard, 'k', ambienceVolumeUp, runWhen: validSounds, titleString: 'Increase the volume of the map ambience'),
      Hotkey(keyboard, 'l', musicVolumeDown, shift: true, runWhen: validSounds, titleString: 'Reduce the volume of game music'),
      Hotkey(keyboard, 'l', musicVolumeUp, runWhen: validSounds, titleString: 'Increase the volume of game music'),
      Hotkey(keyboard, 'h', echoLocationDistanceDown, shift: true, runWhen: validSounds, titleString: 'Decrease the distance the echo location system will work at'),
      Hotkey(keyboard, 'h', echoLocationDistanceUp, runWhen: validSounds, titleString: 'Decrease the distance the echo location system will work at'),
      Hotkey(keyboard, ':', echoLocationDistanceMultiplierDown, shift: true, runWhen: validSounds, titleString: 'Decrease the time before echoes are heard'),
      Hotkey(keyboard, ';', echoLocationDistanceMultiplierUp, runWhen: validSounds, titleString: 'Increase the time before echoes are heard'),
      Hotkey(keyboard, 'p', ping, runWhen: validSounds, titleString: 'Ping your surroundings'),
      Hotkey(keyboard, 'p', echoSoundsMenu, shift: true, runWhen: validOptions, titleString: 'Change your echo sound'),
      Hotkey(keyboard, 'q', wallFilterDown, shift: true, runWhen: validSounds, titleString: 'Reduce the amount sounds that are blocked walls are filtered by'),
      Hotkey(keyboard, 'q', wallFilterUp, runWhen: validSounds, titleString: 'Increase the amount sounds that are blocked walls are filtered by'),
      Hotkey(keyboard, 'm', mouseSensitivityDown, shift: true, runWhen: validSounds, titleString: 'Reduce mouse sensitivity'),
      Hotkey(keyboard, 'm', mouseSensitivityUp, runWhen: validSounds, titleString: 'Increase mouse sensitivity'),

      // Staff only hotkeys:
      Hotkey(keyboard, 'g', goto, runWhen: staffOnly, titleString: 'Jump to specific coordinates on the map'),
      teleportHotkey,
    ]
  );
  keyboardArea.onKeyDown.listen((KeyboardEvent e) {
    final KeyState ks = keyboard.press(e.key.toLowerCase(), shift: e.shiftKey, control: e.ctrlKey, alt: e.altKey);
    if (keyboard.hotkeys.where((Hotkey hk) => hk.state == ks).isNotEmpty) {
      e.preventDefault();
    }
  });
  keyboardArea.onKeyUp.listen((KeyboardEvent e) => keyboard.release(e.key.toLowerCase()));
  startDiv.hidden = false;
  startButton.onClick.listen((Event event) {
    for (final Element e in <Element>[adminControls, bookControls, builderControls, staffControls, standardControls]) {
      e.hidden = true;
    }
    final AudioContext audio = AudioContext()
      ..listener.upZ.value = 1;
    sounds = SoundPool(audio, showMessage: (String text) => showMessage(text, important: false));
    sounds.playSound('sounds/general/start.wav');
    startDiv.hidden = true;
    mainDiv.hidden = false;
    bookOptions = BookOptions(sounds, (String text) => showMessage(text, important: false));
    setTitle(state: 'Connecting');
    createSocket('wss://$socketUrl');
    resetFocus();
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
  document.onContextMenu.listen((MouseEvent e) {
    if (formBuilderDiv.children.isEmpty) {
      e.preventDefault();
    }
  });
  for (final Element e in querySelectorAll('.controls')) {
    e.onClick.listen((MouseEvent e) {
      e.stopPropagation();
      e.preventDefault();
      final String currentId = document.activeElement.id.toString();
      final Hotkey hk = buttonHotkeys[currentId];
      if (hk == null) {
        return commandContext.message('Unhandled button: $currentId.');
      }
      keyboard.heldKeys.add(hk.state);
      if (hk.interval == null) {
        hk.run();
      } else {
        hk.startTimer();
      }
      keyboard.release(hk.state.key);
    });
  }
  document.onMouseMove.listen((MouseEvent e) {
    if (commandContext?.options != null) {
      e.stopPropagation();
      e.preventDefault();
      double t = commandContext.theta;
      if (e.movement.x < 0) {
        t -= commandContext.options.mouseSensitivity;
      } else {
        t += commandContext.options.mouseSensitivity;
      }
      commandContext.theta = normaliseTheta(t);
      commandContext.sendTheta();
    }
  });
}
