/// Provides social hotkeys.
library socials;

import '../commands/command_context.dart';

import '../form_builder.dart';

void say(CommandContext ctx) {
  FormBuilder('Say', (Map<String, String> data) => ctx.send('say', <String>[data['say']]))
    ..addElement('say', label: 'Say something')
    ..render();
}
