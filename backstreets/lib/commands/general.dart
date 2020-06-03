/// Contains general commands.
library general;

import 'package:aqueduct/aqueduct.dart';

import '../actions/action.dart';
import '../actions/actions.dart';
import '../model/game_object.dart';
import '../model/map_section.dart';
import '../model/player_options.dart';
import 'command_context.dart';

/// Shows the server time.
/// Implemented more as a proof of concept before I'd written anything else than because it's actually useful.
Future<void> serverTime(CommandContext ctx) async => ctx.message('Server time is ${DateTime.now()}.');

/// Set a single player option.
///
/// The first argument should be the option name, and the second the value (which can be of any type).
Future<void> playerOption(CommandContext ctx) async {
  final String name = ctx.args[0] as String;
  final dynamic value = ctx.args[1];
  final Query<PlayerOptions> q = Query<PlayerOptions>(ctx.db)
    ..where((PlayerOptions o) => o.object).identifiedBy(ctx.characterId);
  switch(name) {
    case 'soundVolume':
      q.values.soundVolume = (value as num).toDouble();
      break;
    case 'ambienceVolume':
      q.values.ambienceVolume = (value as num).toDouble();
      break;
    case 'musicVolume':
      q.values.musicVolume = (value as num).toDouble();
      break;
    case 'echoLocationDistance':
      q.values.echoLocationDistance = value as int;
      break;
    case 'echoLocationDistanceMultiplier':
      q.values.echoLocationDistanceMultiplier = value as int;
      break;
    case 'echoSound':
      q.values.echoSound = value as String;
      break;
    default:
      return ctx.sendError('Invalid option name "$name".');
      break;
    }
  await q.updateOne();
}

Future<void> action(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final String name = ctx.args[1] as String;
  final GameObject c = await ctx.getCharacter();
  final int x = c.x.floor();
  final int y = c.y.floor();
  final Query<MapSection> mapSectionQuery = Query<MapSection>(ctx.db)
    ..where((MapSection s) => s.id).equalTo(id)
    ..where((MapSection s) => s.startX).greaterThanEqualTo(x)
    ..where((MapSection s) => s.startY).greaterThanEqualTo(y)
    ..where((MapSection s) => s.endX).lessThanEqualTo(x)
    ..where((MapSection s) => s.endY).lessThanEqualTo(y);
  final MapSection s = await mapSectionQuery.fetchOne();
  if (s == null) {
    return ctx.sendError('Invalid section ID.');
  }
  final Action a = actions[name];
  if (a == null) {
      return ctx.sendError('Invalid action name.');
  }
  await a.func(s, ctx);
}
