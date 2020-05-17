/// Provides the [buildCommands] function, for populating the [commands.commands] dictionary.
library builder;

import 'command.dart';
import 'commands.dart';

void buildCommands() {
  for (final Command command in commandsList) {
    if (commands.containsKey(command.name)) {
      throw 'Duplicate "${command.name}" commands found.';
    }
    commands[command.name] = command;
  }
}
