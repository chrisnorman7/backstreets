/// Provides the [AuthenticationStages] enumeration.
library authentication;

import 'commands/general.dart';

/// Used to keep track of where we are in the authentication process.
///
/// The [error] command uses this to figure out which menu to show when something goes wrong.
enum AuthenticationStages {
  /// Not logged in.
  anonymous,

  /// Logged in, but not connected to a character.
  account,

  /// Connected to a character.
  connected
}
