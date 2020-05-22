/// Provides all sound-related commands.
library sound;

import 'command_context.dart';

Future<void> interfaceSound(CommandContext ctx) async {
  final String url = ctx.args[0] as String;
  ctx.sounds.playSound(url);
}

Future<void> sound(CommandContext ctx) async {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  ctx.message(data.toString());
}
