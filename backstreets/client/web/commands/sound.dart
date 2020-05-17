/// Provides all sound-related commands.
library sound;

import 'command_context.dart';

Future<void> interfaceSound(CommandContext ctx) async {
  final String url = ctx.args[0] as String;
  ctx.sounds.playSound(url);
}
