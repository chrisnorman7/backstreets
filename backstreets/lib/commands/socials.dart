/// Provides social commands.
library socials;

import '../model/game_object.dart';

import '../socials.dart';

import 'command_context.dart';

/// The character wants to say something.
Future<void> say(CommandContext ctx) async {
  final String text = ctx.args[0] as String;
  final GameObject c = await ctx.getCharacter();
  c.doSocial(ctx.db, '%1N say%1s: "$text"', sound: socialSounds['say']);
}
