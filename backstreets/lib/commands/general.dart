/// Contains general commands.
library general;

import 'command.dart';
import 'command_context.dart';

final Command serverTime = Command('serverTime', (CommandContext ctx) async {
  return ctx.sendMessage('Server time is ${DateTime.now()}.');
}, authenticationType: AuthenticationTypes.any
);
