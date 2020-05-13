/// Provides all sound-related commands.
library sound;

import 'command_context.dart';

void interfaceSound(CommandContext ctx) {
  final String url = ctx.args[0] as String;
  ctx.sounds.playSound(url);
}
