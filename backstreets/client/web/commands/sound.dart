/// Provides all sound-related commands.
library sound;

import 'dart:web_audio';

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
  num volume, x, y;
  volume = data['volume'] as num;
  x = data['x'] as num;
  y = data['y'] as num;
  final PannerNode panner = ctx.sounds.audioContext.createPanner()
    ..positionX.value = x
    ..positionY.value = y
    ..panningModel = 'HRTF'
    ..connectNode(ctx.sounds.soundOutput);
  final GainNode gain = ctx.sounds.audioContext.createGain()
    ..gain.value = volume
    ..connectNode(panner);
  ctx.sounds.playSound(url, output: gain);
}


Future<void> ambiences(CommandContext ctx) async {
  final Map<dynamic, dynamic> data = ctx.args[0] as Map<dynamic, dynamic>;
  data.forEach((dynamic name, dynamic url) => ctx.ambiences[name as String] = url as String);
}
