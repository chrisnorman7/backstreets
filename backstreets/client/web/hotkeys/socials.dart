/// Provides social hotkeys.
library socials;

import '../form_builder.dart';

import '../keyboard/hotkey.dart';

import '../main.dart';

import 'run_conditions.dart';

final Hotkey say = Hotkey("'", () {
  FormBuilder('Say', (Map<String, String> data) => commandContext.send('say', <String>[data['say']]))
    ..addElement('say', label: 'Say something')
    ..render();
}, runWhen: validMap);
