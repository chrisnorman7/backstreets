/// Provides various functions which can be used as the `runWhen` argument when constructing [Hotkey] instances.
library run_conditions;

import '../main.dart';

/// Returns true if the player is connected to an admin character.
bool admin() => commandContext != null && commandContext.book == null && commandContext.admin == true;

/// Returns true if the map has been loaded, and there is no book in the way.
bool validMap() => commandContext != null && commandContext.mapName != null && commandContext.book == null;

bool validSounds() => commandContext != null && commandContext.sounds != null && commandContext.book == null;
