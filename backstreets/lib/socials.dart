/// Provides the [socials] object.
library socials;

import 'dart:io';

import 'package:path/path.dart' as path;

import 'package:emote_utils/emote_utils.dart';

import 'model/game_object.dart';

import 'sound.dart';

SocialsFactory<GameObject> socials = SocialsFactory<GameObject>.sensible();

final Directory socialSoundsDirectory = Directory(path.join(soundsDirectory, 'socials'));

Map<String, Sound> socialSounds = <String, Sound>{};
