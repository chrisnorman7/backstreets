/// provides the [Command] class.
library command;

import '../model/game_object.dart';

import 'command_context.dart';

/// The type for all command functions.
typedef CommandType = Future<void> Function(CommandContext);

/// The various authentication types for commands.
enum AuthenticationTypes {
  /// Must not be logged in.
  anonymous,

  /// Must be successfully authenticated, but not yet be connected to a [GameObject].
  account,

  /// Must be logged in, and be connected to a [GameObject].
  authenticated,

  /// Must be logged in, and connected to a [GameObject], whose admin field is true.
  admin,

  /// Must be logged in, and connected to a [GameObject] instance, which must either be an admin, or be able to build on the current map.
  staff,

  // Can be in any state.
  any,
}

/// Use this class to make a command.
/// ```
/// final Command time = Command('time', (CommandContext ctx) => ctx.socket.sendMessage('The time is ${DateTime.now()}.'));
/// ```
class Command {
  /// Create with a callback.
  ///
  /// The [func] argument is the function which will be called when this command has been requested.
  ///
  /// If you want to change when this command will be available, pass the [authenticationType} argument.
  Command(this.func, {this.authenticationType = AuthenticationTypes.authenticated});

  /// The function which will be called to handle this command.
  final CommandType func;

  /// The authentication type.
  ///
  /// See the [AuthenticationTypes] enumeration for details on the possible values.
  final AuthenticationTypes authenticationType;
}
