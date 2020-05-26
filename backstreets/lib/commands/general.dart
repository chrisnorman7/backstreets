/// Contains general commands.
library general;

import 'package:aqueduct/aqueduct.dart';

import '../model/player_options.dart';

import 'command_context.dart';

/// Shows the server time.
/// Implemented more as a proof of concept before I'd written anything else than because it's actually useful.
Future<void> serverTime(CommandContext ctx) async => ctx.sendMessage('Server time is ${DateTime.now()}.');

/// Set a single player option.
///
/// The first argument should be the option name, and the second the value (which can be of any type).
Future<void> playerOption(CommandContext ctx) async {
  final String name = ctx.args[0] as String;
  final dynamic value = ctx.args[1];
  final Query<PlayerOptions> q = Query<PlayerOptions>(ctx.db)
    ..where((PlayerOptions o) => o.object).identifiedBy(ctx.characterId);
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
}
