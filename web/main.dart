import 'dart:html';

import 'keyboard/hotkey.dart';
import 'keyboard/key_state.dart';
import 'keyboard/keyboard.dart';
import 'objects/game_object.dart';
import 'util.dart';

final Keyboard keyboard = Keyboard();
final GameObject player = GameObject();

Element messageElement = querySelector('#message');

void message(String text) {
  messageElement.innerText = text;
}

void showHeading(KeyState ks) {
  message(headingToString(player.heading));
}

void main() {
  keyboard.addHotkey(
    Hotkey(
      'h',
      showHeading,
      titleString: 'Show heading'
    )
  );
  keyboard.addHotkey(
    Hotkey(
      'a',
      (KeyState ks) {
        player.heading -= 45;
        if (player.heading < 0) {
          player.heading += 360;
        }
        showHeading(ks);
      },
      titleString: 'Turn 45 degrees left'
    )
  );
  keyboard.addHotkey(
    Hotkey(
      'd',
      (KeyState ks) {
        player.heading += 45;
        if (player.heading > 360) {
          player.heading -= 360;
        }
        showHeading(ks);
      },
      titleString: 'Turn 45 degrees right'
    )
  );
  keyboard.addHotkey(
    Hotkey(
      'w',
      (KeyState ks) => player.forward(),
      titleString: 'Walk forward',
      oneTime: false
    )
  );
  keyboard.addHotkey(
    Hotkey(
      'c',
      (KeyState ks) => message('${player.x.toStringAsFixed(0)}, ${player.y.toStringAsFixed(0)}.'),
      titleString: 'Show coordinates'
    )
  );
  final Element keyboardArea = querySelector('#keyboardArea');
  messageElement = querySelector('#message');
  final Element startDiv = querySelector('#startDiv');
  final Element startButton = querySelector('#startButton');
  startButton.onClick.listen((Event e) async {
    querySelector('#main').hidden = false;
    startDiv.hidden = true;
    keyboardArea.focus();
  });
  keyboardArea.onKeyDown.listen(
    (KeyboardEvent e) => keyboard.press(
      KeyState(
        e.key,
        shift: e.shiftKey,
        control: e.ctrlKey,
        alt: e.altKey
      )
    )
  );
  keyboardArea.onKeyUp.listen((KeyboardEvent e) => keyboard.release(e.key));
  startDiv.hidden = false;
  message('Loaded.');
}
