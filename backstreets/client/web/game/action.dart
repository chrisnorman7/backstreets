/// Provides the [Action] class.
library action;

import 'package:game_utils/game_utils.dart';

import '../commands/command_context.dart';
import '../constants.dart';
import '../util.dart';

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

  /// The message we will show if this action needs confirming.
  ///
  /// If it is null, then no confirmation is required.
  String confirmMessage;

  /// The confirm social.
  ///
  /// We don't need this client side, except for building.
  String confirmSocial;

  /// The label for the OK button.
  String okLabel;

  /// The label for the cancel button.
  String cancelLabel;

  /// The social which will be used if the player cancels.
  ///
  /// We do not need this client side except for building.
  String cancelSocial;

  /// Upload this action to the server.
  void upload(CommandContext ctx) {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'sectionId': sectionId,
      'name': name,
      'functionName': functionName,
      'social': social,
      'sound': sound,
      'confirmMessage': confirmMessage,
      'confirmSocial': confirmSocial,
      'okLabel': okLabel,
      'cancelLabel': cancelLabel,
      'cancelSocial': cancelSocial,
    };
    ctx.send('editMapSectionAction', <Map<String, dynamic>>[data]);
  }

  /// Perform this action.
  void use() {
    if (confirmMessage == null) {
      commandContext.sendAction(this);
    } else {
      clearBook();
      commandContext.send('confirmAction', <int>[id]);
    }
  }

  /// Confirm this action.
  void confirm() {
    final Book b = Book(bookOptions);
    b.push(Page.confirmPage(b, () {
      clearBook();
      commandContext.sendAction(this);
    }, okTitle: okLabel, cancelTitle: cancelLabel, cancelFunc: cancel, title: confirmMessage));
    commandContext.book = b;
  }

  /// Cancel the action.
  void cancel() {
    clearBook();
    commandContext.send('cancelAction', <int>[id]);
  }
}
