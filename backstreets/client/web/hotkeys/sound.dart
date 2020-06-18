/// Provides Sound related hotkeys.
library sound;

import 'dart:math';

import 'package:game_utils/game_utils.dart';

import '../constants.dart';
import '../game/panned_sound.dart';
import '../main.dart';
import '../util.dart';

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

void echoLocationDistanceDown() {
  commandContext.options.echoLocationDistance = max(1, commandContext.options.echoLocationDistance - 1);
  commandContext.send('playerOption', <dynamic>['echoLocationDistance', commandContext.options.echoLocationDistance]);
  showMessage('Echo location distance ${commandContext.options.echoLocationDistance}.', important: false);
}

void echoLocationDistanceUp() {
  commandContext.options.echoLocationDistance++;
  commandContext.send('playerOption', <dynamic>['echoLocationDistance', commandContext.options.echoLocationDistance]);
  showMessage('Echo location distance ${commandContext.options.echoLocationDistance}.', important: false);
}

void echoLocationDistanceMultiplierDown() {
  commandContext.options.echoLocationDistanceMultiplier = max(5, commandContext.options.echoLocationDistanceMultiplier - 5);
  commandContext.send('playerOption', <dynamic>['echoLocationDistanceMultiplier', commandContext.options.echoLocationDistanceMultiplier]);
  showMessage('Echo location distance multiplier ${commandContext.options.echoLocationDistanceMultiplier}.', important: false);
}

void echoLocationDistanceMultiplierUp() {
  commandContext.options.echoLocationDistanceMultiplier += 5;
  commandContext.send('playerOption', <dynamic>['echoLocationDistanceMultiplier', commandContext.options.echoLocationDistanceMultiplier]);
  showMessage('Echo location distance multiplier ${commandContext.options.echoLocationDistanceMultiplier}.', important: false);
}

void ping() => echoLocate();

void echoSoundsMenu() {
  commandContext.book = Book(bookOptions);
  final List<Line> lines = <Line>[];
  commandContext.echoSounds.forEach((String name, String url) {
    lines.add(
      Line(commandContext.book, () {
        commandContext.options.echoSound = name;
        commandContext.send('playerOption', <dynamic>['echoSound', name]);
        clearBook();
      }, titleFunc: () => '${name == commandContext.options.echoSound ? "* " : ""}$name', soundUrl: () => url)
    );
  });
  lines.sort((Line a, Line b) => a.getTitle().toLowerCase().compareTo(b.getTitle().toLowerCase()));
  commandContext.book.push(Page(lines: lines, titleString: 'Echo Sounds', onCancel: clearBook));
}

void setWallFilterAmount(int amount) {
  commandContext.options.wallFilterAmount = amount;
  commandContext.send('playerOption', <dynamic>['wallFilterAmount', commandContext.options.wallFilterAmount]);
  showMessage('Filter: ${commandContext.options.wallFilterAmount}.', important: false);
  for (final PannedSound s in commandContext.map.pannedSounds) {
    if (s.filter != null) {
      s.filter.frequency.value= commandContext.options.wallFilterAmount;
    }
  }
}

void wallFilterDown() => setWallFilterAmount(max(0, commandContext.options.wallFilterAmount - 1000));
void wallFilterUp() => setWallFilterAmount(commandContext.options.wallFilterAmount + 1000);

/// Set mouse sensitivity.
void setMouseSensitivity(int value) {
  commandContext.options.mouseSensitivity = value;
  commandContext.send('playerOption', <dynamic>['mouseSensitivity', commandContext.options.mouseSensitivity]);
  showMessage('Mouse sensitivity set to $value.', important: false);
}

void mouseSensitivityDown() {
  setMouseSensitivity(max(1, commandContext.options.mouseSensitivity - 1));
}

void mouseSensitivityUp() {
  setMouseSensitivity(commandContext.options.mouseSensitivity + 1);
}
