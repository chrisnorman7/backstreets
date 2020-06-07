/// Provides all sound-related commands.
library sound;

import 'dart:math';

import '../directory.dart';
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
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  final String url = data['url'] as String;
  final double volume = (data['volume'] as num).toDouble();
  final double x = (data['x'] as num).toDouble();
  final double y = (data['y'] as num).toDouble();
  playSoundAtCoordinates(url, coordinates: Point<double>(x, y), volume: volume);
}


void ambiences(CommandContext ctx) {
  final Map<dynamic, dynamic> data = ctx.args[0] as Map<dynamic, dynamic>;
  data.forEach((dynamic name, dynamic url) => ctx.ambiences[name as String] = url as String);
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