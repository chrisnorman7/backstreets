/// Contains general commands.
library general;

import 'dart:math';

import 'package:aqueduct/aqueduct.dart';

import '../actions/action.dart';
import '../actions/actions.dart';
import '../game/util.dart';
import '../model/account.dart';
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
    case 'wallFilterAmount':
      q.values.wallFilterAmount = value as int;
      break;
    case 'mouseSensitivity':
      q.values.mouseSensitivity = value as int;
      break;
    default:
      return ctx.sendError('Invalid option name "$name".');
      break;
    }
  await q.updateOne();
}

Future<void> action(CommandContext ctx) async {
  final String name = ctx.args[0] as String;
  final GameObject c = await ctx.getCharacter();
  final int x = c.x.floor();
  final int y = c.y.floor();
  final MapSection s = await c.location.getCurrentSection(ctx.db, Point<int>(x, y));
  if (s == null) {
    return ctx.sendError('Invalid section ID.');
  }
  final Action a = actions[name];
  if (a == null) {
      return ctx.sendError('Invalid action name.');
  }
  await a.func(s, ctx);
}

Future<void> resetPassword(CommandContext ctx) async {
  final String  oldPassword = ctx.args[0] as String;
  final String newPassword = ctx.args[1] as String;
  Account a = await ctx.getAccount();
  if (a.verify(oldPassword)) {
    a.setPassword(newPassword);
    final Query<Account> q = Query<Account>(ctx.db)
      ..values.password = a.password
      ..where((Account a) => a.id).equalTo(ctx.accountId);
    a = await q.updateOne();
    ctx.message('Password changed.');
  } else {
    ctx.sendError('Wrong password.');
  }
}

Future<void> connectedTime(CommandContext ctx) async {
  final GameObject c = await ctx.getCharacter();
  final Duration ct = await c.connectedDuration(ctx.db);
  ctx.message('Time connected: ${formatDuration(ct)}.');
}

Future<void> who(CommandContext ctx) async {
  final List<String> here = <String>[];
  final List<String> elsewhere = <String>[];
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..where((GameObject o) => o.connected).equalTo(true)
    ..sortBy((GameObject o) => o.name, QuerySortOrder.ascending);
  for (final GameObject o in await q.fetch()) {
    if (o.location.id == ctx.mapId) {
      here.add(o.name);
    } else {
      elsewhere.add(o.name);
    }
  }
  ctx.message('There ${pluralise(here.length, "is", "are")} ${here.length} ${pluralise(here.length, "player")} on your map: ${englishList(here)}.\nThere ${pluralise(elsewhere.length, "is", "are")} ${elsewhere.length} ${pluralise(elsewhere.length, "player")} on other maps: ${englishList(elsewhere, emptyString: "Nobody")}.');
}
