/// Provides Sound related hotkeys.
library sound;

import 'package:game_utils/game_utils.dart';

import '../main.dart';

void soundVolumeDown() {
  commandContext.sounds.volumeDown(OutputTypes.sound);
  commandContext.send('playerOption', <dynamic>['soundVolume', commandContext.sounds.soundVolume]);
}

void soundVolumeUp() {
  commandContext.sounds.volumeUp(OutputTypes.sound);
  commandContext.send('playerOption', <dynamic>['soundVolume', commandContext.sounds.soundVolume]);
}

void ambienceVolumeDown() {
  commandContext.sounds.volumeDown(OutputTypes.ambience);
  commandContext.send('playerOption', <dynamic>['ambienceVolume', commandContext.sounds.ambienceVolume]);
}

void ambienceVolumeUp() {
  commandContext.sounds.volumeUp(OutputTypes.ambience);
  commandContext.send('playerOption', <dynamic>['ambienceVolume', commandContext.sounds.ambienceVolume]);
}

void musicVolumeDown() {
  commandContext.sounds.volumeDown(OutputTypes.music);
  commandContext.send('playerOption', <dynamic>['musicVolume', commandContext.sounds.musicVolume]);
}

void musicVolumeUp() {
  commandContext.sounds.volumeUp(OutputTypes.music);
  commandContext.send('playerOption', <dynamic>['musicVolume', commandContext.sounds.musicVolume]);
}
