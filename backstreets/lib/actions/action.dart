/// Provides the [Action] class.
library action;

import '../commands/command_context.dart';
import '../model/map_section.dart';

/// The type for all [Action] functions.
typedef ActionFunctionType = Future<void> Function(MapSection, CommandContext);

/// An action which can be triggered by the enter key.
///
/// These functions should have a reasonable [description], which should explain what the action does in the actions menu.
class Action {
  Action(this.description, this.func);

  /// The description of this action.
  String description;

  /// The function that this action should call.
  ActionFunctionType func;
}
