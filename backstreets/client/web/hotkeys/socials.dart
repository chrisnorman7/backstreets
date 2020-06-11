/// Provides social hotkeys.
library socials;

import 'package:game_utils/game_utils.dart';

import '../constants.dart';
import '../main.dart';
import '../util.dart';

void say() {
  FormBuilder('Say', (Map<String, String> data) {
    resetFocus();
    commandContext.send('say', <String>[data['say']]);
  }, showMessage, onCancel: doCancel)
    ..addElement('say', label: 'Say something')
    ..render(formBuilderDiv, beforeRender: keyboard.releaseAll);
}
