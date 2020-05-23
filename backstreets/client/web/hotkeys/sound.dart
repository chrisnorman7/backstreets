/// Provides Sound related hotkeys.
library sound;

import '../commands/command_context.dart';

import '../sound/sound_pool.dart';

void soundVolumeDown(CommandContext ctx) => ctx.sounds.volumeDown(OutputTypes.sound);

void soundVolumeUp(CommandContext ctx) => ctx.sounds.volumeUp(OutputTypes.sound);

void ambienceVolumeDown(CommandContext ctx) => ctx.sounds.volumeDown(OutputTypes.ambience);

void ambienceVolumeUp(CommandContext ctx) => ctx.sounds.volumeUp(OutputTypes.ambience);

void musicVolumeDown(CommandContext ctx) => ctx.sounds.volumeDown(OutputTypes.music);

void musicVolumeUp(CommandContext ctx) => ctx.sounds.volumeUp(OutputTypes.music);
