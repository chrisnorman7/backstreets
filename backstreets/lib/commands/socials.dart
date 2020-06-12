/// Provides social commands.
library socials;

import '../model/game_object.dart';
import '../socials_factory.dart';

import 'command_context.dart';

/// The character wants to say something.
Future<void> say(CommandContext ctx) async {
  final String text = ctx.args[0] as String;
  if (text.isEmpty) {
    return ctx.message('You say nothing. Good job!');
  }
  final GameObject c = await ctx.getCharacter();
  await c.doSocial(ctx.db, '%1N say%1s: "$text"', sound: socialSounds['say']);
}
