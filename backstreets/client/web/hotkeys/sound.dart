/// Provides Sound related hotkeys.
library sound;

import 'package:game_utils/game_utils.dart';

import '../main.dart';

void soundVolumeDown() => commandContext.sounds.volumeDown(OutputTypes.sound);

void soundVolumeUp() => commandContext.sounds.volumeUp(OutputTypes.sound);

void ambienceVolumeDown() => commandContext.sounds.volumeDown(OutputTypes.ambience);

void ambienceVolumeUp() => commandContext.sounds.volumeUp(OutputTypes.ambience);

void musicVolumeDown() => commandContext.sounds.volumeDown(OutputTypes.music);

void musicVolumeUp() => commandContext.sounds.volumeUp(OutputTypes.music);
