/// Provides various utility functions to be passed as the runWhen argument when creating [Hotkey] instances.
library run_condigiont;

import 'constants.dart';

/// Returns true if the player is connected to a builder character.
bool _builderOnly() => commandContext != null && commandContext.book == null && commandContext.permissions.builder == true;

/// Returns true if the player is connected to an admin character.
bool adminOnly() => commandContext != null && commandContext.book == null && commandContext.permissions.admin == true;

/// Returns true if the player is connected to an admin or builder character.
bool staffOnly() => _builderOnly() || adminOnly();

/// Returns true if the map has been loaded, and there is no book in the way.
bool validMap() => commandContext != null && commandContext.map != null && commandContext.book == null;

/// Returns true if the sound system is present.
bool validSounds() => commandContext != null && commandContext.sounds != null && commandContext.book == null;

/// Only run if we have a valid book.
bool validBook() => commandContext != null && commandContext.book != null;

/// Only run if the player's options have been sent.
bool validOptions() => commandContext?.options != null;

/// Only run if there is a valid CommandContext.
bool validCommandContext() => commandContext != null;
