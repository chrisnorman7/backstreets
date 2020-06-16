/// Provides the [Action] class.
library action;

import '../commands/command_context.dart';

/// Destcribes an action sent by the server.
///
/// Used for building.
class Action {
  /// The id of this action.
  int id;

  /// The id of the section this action is assigned to.
  int sectionId;

  /// The name of this action.
  String name;

  /// The name of the function that should be called by this function.
  String functionName;

  /// The social that is emited by this action.
  String social;

  /// The sound that is emited by this action.
  String sound;

  /// Upload this action to the server.
  void upload(CommandContext ctx) {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'sectionId': sectionId,
      'name': name,
      'functionName': functionName,
      'social': social,
      'sound': sound
    };
    ctx.send('editMapSectionAction', <Map<String, dynamic>>[data]);
  }
}
