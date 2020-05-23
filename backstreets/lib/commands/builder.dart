/// Provides the [buildCommands] function, for populating the [commands.commands] dictionary.
library builder;

import 'command.dart';
import 'commands.dart';

/// Build the [commands] dictionary.
///
/// This function iterates over the [commandsList] list, and adds every [Command] instance to the [commands] dictionary.
///
/// If two commands have the same name, an error is thrown.
void buildCommands() {
  for (final Command command in commandsList) {
    if (commands.containsKey(command.name)) {
      throw 'Duplicate "${command.name}" commands found.';
    }
    commands[command.name] = command;
  }
}
