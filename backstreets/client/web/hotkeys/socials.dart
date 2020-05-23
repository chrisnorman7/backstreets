/// Provides social hotkeys.
library socials;

import '../form_builder.dart';

import '../main.dart';

void say() {
  FormBuilder('Say', (Map<String, String> data) => commandContext.send('say', <String>[data['say']]))
    ..addElement('say', label: 'Say something')
    ..render();
}
