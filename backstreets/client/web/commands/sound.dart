/// Provides all sound-related commands.
library sound;

import 'dart:math';

import '../directory.dart';
import '../util.dart';

import 'command_context.dart';

/// Play a sound which should alert the character of something.
///
/// This sound should play without any fx or panning.
Future<void> interfaceSound(CommandContext ctx) async {
  final String url = ctx.args[0] as String;
  ctx.sounds.playSound(url);
}

/// Play a sound relating to the game.
///
/// The sound should play at specific coordinates (which could be the same as those of the character), and with fx applied.
Future<void> sound(CommandContext ctx) async {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  final String url = data['url'] as String;
  final double volume = (data['volume'] as num).toDouble();
  final double x = (data['x'] as num).toDouble();
  final double y = (data['y'] as num).toDouble();
  playSoundAtCoordinates(url, coordinates: Point<double>(x, y), volume: volume);
}


Future<void> ambiences(CommandContext ctx) async {
  final Map<dynamic, dynamic> data = ctx.args[0] as Map<dynamic, dynamic>;
  data.forEach((dynamic name, dynamic url) => ctx.ambiences[name as String] = url as String);
}

Future<void> impulses(CommandContext ctx) async {
  final Map<String, dynamic> data = ctx.args[0] as Map<String, dynamic>;
  ctx.impulses = Directory.fromData(data);
}
