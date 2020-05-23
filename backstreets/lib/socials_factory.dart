/// Provides the [socials] object.
library socials_factory;

import 'dart:io';

import 'package:path/path.dart' as path;

import 'package:emote_utils/emote_utils.dart';

import 'model/game_object.dart';

import 'sound.dart';

/// The interface for dealing with socials.
SocialsFactory<GameObject> socials = SocialsFactory<GameObject>.sensible();

/// The directory where all social sounds are stored.
final Directory socialSoundsDirectory = Directory(path.join(soundsDirectory, 'socials'));

/// The dictionary of all discovered social sounds.
///
/// Discovered from [socialSoundsDirectory].
Map<String, Sound> socialSounds = <String, Sound>{};
