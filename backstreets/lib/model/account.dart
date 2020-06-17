/// Provides the [Account] class.
library account;

import 'package:aqueduct/aqueduct.dart';
import 'package:password/password.dart';

import 'game_object.dart';
import 'mixins.dart';

/// Hash a password.
///
/// For use with [Account.setPassword].
String hashPassword(String password) {
  final PBKDF2 algorithm = PBKDF2();
  return Password.hash(password, algorithm);
}

/// The accounts table.
///
/// To work with accounts, instead use the [Account] class.
@Table(name: 'accounts')
class _Account with PrimaryKeyMixin {
  /// The account's username.
  @Column(unique: true, indexed: true)
  String username;

  /// The password hash.
  @Column(nullable: true)
  String password;

  /// The list of [GameObject] instances.
  ManagedSet<GameObject> objects;

  /// The reason for this account being locked.
  ///
  /// If this value is null, the account is considered unlocked.
  @Column(nullable: true)
  String lockedMessage;
}

/// An account, which is linked to 0 or more [GameObject] instances.
///
/// ```
/// final Account a = Account();
/// a.username = 'username';
/// a.setPassword('password');
/// a.verify('password'); // true
/// a.verify('not right'); // false
/// ```
class Account extends ManagedObject<_Account> implements _Account {
  /// Set the password for this account, using [Password.hash].
  ///
  /// ```
  /// final Account a = Account();
  /// a.username = 'username';
  /// a.setPassword('hello123');
  /// ```
  void setPassword(String p) {
    password = hashPassword(p);
  }

  /// Clear the password, thus locking this account against access.
  ///
  /// ```
  /// accountToLock.clearPassword();
  /// ```
  void clearPassword() {
    password = null;
  }

  /// Verify the password for this account.
  ///
  /// ```
  /// if (account.verify(password)) {
  ///   // Send account.objects to the player, and let them choose an object.
  /// } else {
  ///   // Tell the player they entered the wrong password.
  /// }
  /// ```
  bool verify(String guess) {
    return Password.verify(guess, password);
  }

  /// Returns true if this account is locked, flase otherwise.
  bool get locked => lockedMessage != null;
}
