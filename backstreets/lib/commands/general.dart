/// Contains general commands.
library general;

import 'dart:math';

import 'package:aqueduct/aqueduct.dart';
import 'package:backstreets/model/map_section_action.dart';

import '../game/menu.dart';
import '../game/util.dart';
import '../model/account.dart';
import '../model/game_map.dart';
import '../model/game_object.dart';
import '../model/map_section.dart';
import '../model/player_options.dart';
import '../model/radio.dart';
import '../sound.dart';
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
    case 'connectNotifications':
    q.values.connectNotifications = value as bool;
    break;
  case 'disconnectNotifications':
    q.values.disconnectNotifications = value as bool;
    break;
    default:
      return ctx.sendError('Invalid option name "$name".');
      break;
    }
  await q.updateOne();
}

Future<void> action(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final GameObject c = await ctx.getCharacter();
  final int x = c.x.floor();
  final int y = c.y.floor();
  final GameMap m = await ctx.getMap();
  final MapSection s = await m.getCurrentSection(ctx.db, Point<int>(x, y));
  if (s == null) {
    return ctx.sendError('You are not on a section.');
  }
  final Query<MapSectionAction> q = Query<MapSectionAction>(ctx.db)
    ..where((MapSectionAction a) => a.section).identifiedBy(s.id)
    ..where((MapSectionAction a) => a.id).equalTo(id);
  final MapSectionAction a = await q.fetchOne();
  if (a == null) {
    return ctx.sendError('Invalid action name.');
  }
  if (a.social != null) {
    final GameObject pretend = GameObject()
      ..name = s.name;
    await m.handleSocial(ctx.db, a.social, <GameObject>[c, pretend]);
  }
  if (a.sound != null) {
    await m.broadcastSound(ctx.db, randomElement<Sound>(actionSounds[a.sound]), c.coordinates, objectId: c.id);
  }
  if (a.functionName != null) {
    await a.func(s, ctx);
  }
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

Future<void> confirmAction(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final GameObject c = await ctx.getCharacter();
  final int x = c.x.floor();
  final int y = c.y.floor();
  final GameMap m = await ctx.getMap();
  final MapSection s = await m.getCurrentSection(ctx.db, Point<int>(x, y));
  if (s == null) {
    return ctx.sendError('You are not on a section.');
  }
  final Query<MapSectionAction> q = Query<MapSectionAction>(ctx.db)
    ..where((MapSectionAction a) => a.section).identifiedBy(s.id)
    ..where((MapSectionAction a) => a.id).equalTo(id);
  final MapSectionAction a = await q.fetchOne();
  if (a == null) {
    return ctx.sendError('Invalid action name.');
  }
  if (a.confirmSocial != null) {
    final GameObject pretend = GameObject()
      ..name = s.name;
    await m.handleSocial(ctx.db, a.confirmSocial, <GameObject>[c, pretend]);
    ctx.send('confirmAction', <int>[s.id, a.id]);
  }
}

Future<void> cancelAction(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final GameObject c = await ctx.getCharacter();
  final int x = c.x.floor();
  final int y = c.y.floor();
  final GameMap m = await ctx.getMap();
  final MapSection s = await m.getCurrentSection(ctx.db, Point<int>(x, y));
  if (s == null) {
    return ctx.sendError('You are not on a section.');
  }
  final Query<MapSectionAction> q = Query<MapSectionAction>(ctx.db)
    ..where((MapSectionAction a) => a.section).identifiedBy(s.id)
    ..where((MapSectionAction a) => a.id).equalTo(id);
  final MapSectionAction a = await q.fetchOne();
  if (a == null) {
    return ctx.sendError('Invalid action name.');
  }
  if (a.cancelSocial != null) {
    final GameObject pretend = GameObject()
      ..name = s.name;
    await m.handleSocial(ctx.db, a.cancelSocial, <GameObject>[c, pretend]);
  }
}

Future<void> stepCount(CommandContext ctx) async {
  final GameObject c = await ctx.getCharacter();
  ctx.message('You have walked ${c.steps} ${pluralise(c.steps, "step")}.');
}

Future<void> transmit(CommandContext ctx) async {
  final String message = ctx.args[0] as String;
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..join(object: (GameObject o) => o.radioChannel)
    ..where((GameObject o) => o.id).equalTo(ctx.characterId);
  final GameObject c = await q.fetchOne();
  if (message == null) {
    if (c.radioChannel == null) {
      ctx.message('Your radio is muted.');
    } else if (c.canTransmit) {
      ctx.message('You are allowed to transmit on the ${c.radioChannel.name} radio channel.');
    } else {
      ctx.message('You are banned from transmitting.');
    }
  } else if (c.radioChannel == null) {
    ctx.sendError('You have not selected a radio channel to transmit on. Please do that the with the r key.');
  } else if (c.canTransmit) {
    await c.radioChannel.transmit(ctx.db, c, message);
  } else {
    ctx.message('You are banned from transmitting.');
  }
}

Future<void> listRadioChannels(CommandContext ctx) async {
  final GameObject c = await ctx.getCharacter();
  final Menu m = Menu('Radio Channels');
  m.items.add(MenuItem('Mute', 'selectRadioChannel', <String>[null]));
  final Query<RadioChannel> q = Query<RadioChannel>(ctx.db)
    ..sortBy((RadioChannel c) => c.name, QuerySortOrder.ascending);
  for (final RadioChannel channel in await q.fetch()) {
    m.items.add(MenuItem('${channel == c.radioChannel ? "* " : ""}${channel.name}', 'selectRadioChannel', <int>[channel.id]));
  }
  if (await c.getStaff(ctx.db)) {
    m.items.add(MenuItem('Edit Channels', 'editRadioChannels', null));
  }
  ctx.sendMenu(m);
}

Future<void> selectRadioChannel(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  RadioChannel channel;
  if (id == null) {
    ctx.message('You mute your radio.');
  } else {
    final Query<RadioChannel> q = Query<RadioChannel>(ctx.db)
      ..where((RadioChannel c) => c.id).equalTo(id);
    channel = await q.fetchOne();
    if (channel == null) {
      return ctx.sendError('Invalid channel ID.');
    }
  }
  GameObject c = await ctx.getCharacter();
  if (c.radioChannel != channel) {
    final RadioChannel oldChannel = c.radioChannel;
    final Query<GameObject> q = Query<GameObject>(ctx.db)
      ..values.radioChannel = channel
      ..where((GameObject o) => o.id).equalTo(ctx.characterId);
    c = await q.updateOne();
    if (oldChannel != null) {
      await oldChannel.transmitRaw(ctx.db, '${c.name} leaves the channel.');
    }
    if (channel != null) {
      await channel.transmitRaw(ctx.db, '${c.name} joins the channel.');
    }
  } else {
    ctx.message('Channel unchanged.');
  }
}
