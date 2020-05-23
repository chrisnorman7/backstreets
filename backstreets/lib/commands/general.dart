/// Contains general commands.
library general;

import 'package:aqueduct/aqueduct.dart';

import '../model/player_options.dart';

import 'command.dart';
import 'command_context.dart';

final Command serverTime = Command('serverTime', (CommandContext ctx) async {
  ctx.sendMessage('Server time is ${DateTime.now()}.');
}, authenticationType: AuthenticationTypes.any);

final Command playerOption = Command('playerOption', (CommandContext ctx) async {
  final String name = ctx.args[0] as String;
  final dynamic value = ctx.args[1];
  final PlayerOptions o = await ctx.getPlayerOptions();
  final Query<PlayerOptions> q = Query<PlayerOptions>(ctx.db)
    ..where((PlayerOptions i) => i.id).equalTo(o.id);
  if (name == 'soundVolume') {
    q.values.soundVolume = (value as num).toDouble();
  } else if (name == 'ambienceVolume') {
    q.values.ambienceVolume = (value as num).toDouble();
  } else if (name == 'musicVolume') {
    q.values.musicVolume = (value as num).toDouble();
  } else {
    return ctx.sendError('Invalid option name "$name".');
  }
  await q.updateOne();
});
