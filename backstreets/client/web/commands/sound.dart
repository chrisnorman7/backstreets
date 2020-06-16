/// Provides all sound-related commands.
library sound;

import 'dart:math';

import '../directory.dart';
import '../run_conditions.dart';
import '../util.dart';

import 'command_context.dart';

/// Play a sound which should alert the character of something.
///
/// This sound should play without any fx or panning.
void interfaceSound(CommandContext ctx) {
  final String url = ctx.args[0] as String;
  ctx.sounds.playSound(url);
}

/// Play a sound relating to the game.
///
/// The sound should play at specific coordinates (which could be the same as those of the character), and with fx applied.
void sound(CommandContext ctx) {
  if (!validMap()) {
    return; // There is no map or anything.
  }
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  final String url = data['url'] as String;
  final double volume = (data['volume'] as num).toDouble();
  final double x = (data['x'] as num).toDouble();
  final double y = (data['y'] as num).toDouble();
  final bool airborn = data['airborn'] as bool;
  final int id = data['id'] as int;
  playSoundAtCoordinates(url, coordinates: Point<double>(x, y), volume: volume, airborn: airborn, id: id);
}


void ambiences(CommandContext ctx) {
  final Map<dynamic, dynamic> data = ctx.args[0] as Map<dynamic, dynamic>;
  final List<String> names = <String>[];
  for (final dynamic name in data.keys) {
    names.add(name as String);
  }
  names.sort((String a, String b) => a.toUpperCase().compareTo(b.toUpperCase()));
  for (final String name in names) {
    ctx.ambiences[name] = data[name] as String;
  }
}

void impulses(CommandContext ctx) {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  ctx.impulses = Directory.fromData(data);
}

void echoSounds(CommandContext ctx) {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  data.forEach((String name, dynamic value) => ctx.echoSounds[name] = value as String);
}

void exitSound(CommandContext ctx) {
  final String name = ctx.args[0] as String;
  final String url = ctx.args[1] as String;
  ctx.exitSounds[name] = url;
}

void phrases(CommandContext ctx) {
  final List<dynamic> phrases = ctx.args[0] as List<dynamic>;
  for (final dynamic phrase in phrases) {
    ctx.phrases.add(phrase as String);
  }
}