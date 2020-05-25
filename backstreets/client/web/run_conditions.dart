/// Provides various utility functions to be passed as the runWhen argument when creating [Hotkey] instances.
library run_condigiont;

import 'main.dart';

/// Returns true if the player is connected to a builder character.
bool builderOnly() => commandContext != null && commandContext.book == null && commandContext.builder == true;

/// Returns true if the player is connected to an admin character.
bool adminOnly() => commandContext != null && commandContext.book == null && commandContext.admin == true;

/// Returns true if the map has been loaded, and there is no book in the way.
bool validMap() => commandContext != null && commandContext.mapName != null && commandContext.book == null;

/// Returns true if the sound system is present.
bool validSounds() => commandContext != null && commandContext.sounds != null && commandContext.book == null;

/// Only run if we have a valid book.
bool validBook() => commandContext.book != null;
