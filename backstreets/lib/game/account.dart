/// Provides the [Account] class.

library account;

import 'package:password/password.dart';

import 'game_object.dart';

/// The [Algorithm] to use for [Password.hash].
final PBKDF2 algorithm = PBKDF2();

/// Map usernames to [Account] instances.
Map<String, Account> accounts = <String, Account>{};

/// An account, which is linked to 0 or more [GameObject] instances.
///
/// ```dart
///final Account a = Account('username');
/// a.setPassword('password');
/// a.verify('password'); // true
/// a.verify('not right'); // false
/// ```
class Account {
  /// Create an account with a username, before using [Account.setPassword] to set the password.
  Account(this.username);

  /// The account's username.
  String username;

  /// The password hash.
  String _password;

  /// The list of objects assigned to this account.
  List<GameObject> objects = <GameObject>[];

  /// Set the password for this account, using [Password.hash].
  ///
  /// ```dart
  /// final Account a = Account('username');
  /// a.setPassword('hello123');
  /// ```
  void setPassword(String password) {
    _password = Password.hash(password, algorithm);
  }

  /// Clear the password, thus locking this account against access.
  ///
  /// ```dart
  /// accountToLock.clearPassword();
  /// ```
  void clearPassword() {
    _password = null;
  }

  /// Verify the password for this account.
  ///
  /// ```dart
  /// if (account.verify(password)) {
  ///   // Send account.objects to the player, and let them choose an object.
  /// } else {
  ///   // Tell the player they entered the wrong password.
  /// }
  /// ```
  bool verify(String password) {
    return Password.verify(password, _password);
  }
}
