/// General commands.
library general;

import 'command_context.dart';

Future<void> message(CommandContext ctx) async {
  ctx.message(ctx.args[0] as String);
}

Future<void> error(CommandContext ctx) async {
  ctx.message('Error: ${ctx.args[0]}');
}
