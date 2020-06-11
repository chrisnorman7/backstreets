/// Provides social commands.
library socials;


import '../socials_factory.dart';

import 'command_context.dart';

/// The character wants to say something.
Future<void> say(CommandContext ctx) async {
  final String text = ctx.args[0] as String;
  if (text.isEmpty) {
    return ctx.message('You say nothing. Good job!');
  }
  await ctx.doSocial('%1N say%1s: "$text"', sound: socialSounds['say']);
}
