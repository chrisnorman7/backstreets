/// Provides Sound related hotkeys.
library sound;

import '../keyboard/hotkey.dart';

import '../main.dart';

import '../sound/sound_pool.dart';

import 'run_conditions.dart';

final Hotkey soundVolumeDown = Hotkey('j', () {
  commandContext.sounds.volumeDown(OutputTypes.sound);
}, shift: true, runWhen: validSounds);

final Hotkey soundVolumeUp = Hotkey('j', () {
  commandContext.sounds.volumeUp(OutputTypes.sound);
}, runWhen: validSounds);

final Hotkey ambienceVolumeDown = Hotkey('k', () {
  commandContext.sounds.volumeDown(OutputTypes.ambience);
}, shift: true, runWhen: validSounds);

final Hotkey ambienceVolumeUp = Hotkey('k', () {
  commandContext.sounds.volumeUp(OutputTypes.ambience);
}, runWhen: validSounds);

final Hotkey musicVolumeDown = Hotkey('l', () {
  commandContext.sounds.volumeDown(OutputTypes.music);
}, shift: true, runWhen: validSounds);

final Hotkey musicVolumeUp = Hotkey('l', () {
  commandContext.sounds.volumeUp(OutputTypes.music);
}, runWhen: validSounds);
