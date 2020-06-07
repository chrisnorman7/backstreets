/// Provides the [mainMenu] [Page].
library main_menu;

import 'dart:html';

import 'package:game_utils/game_utils.dart';

import '../constants.dart';
import '../main.dart';
import '../util.dart';

Page mainMenu() {
  return Page(
    titleString: 'Main Menu',
    lines: <Line>[
      Line(
        commandContext.book, () {
          FormBuilder(
            'Login', (Map<String, String> data) {
              clearBook();
              commandContext.message('Logging in...');
              commandContext.send('login', <String>[data['username'], data['password']]);
            }, showMessage, onCancel: resetFocus,
            subTitle: 'Log into your account', submitLabel: 'Login'
          )
            ..addElement('username', validator: notEmptyValidator)
            ..addElement('password', element: PasswordInputElement(), validator: notEmptyValidator)
            ..render(formBuilderDiv, beforeRender: keyboard.releaseAll);
        },
        titleString: 'Login'
      ),
      Line(
        commandContext.book, () {
          FormBuilder(
            'Create Account', (Map<String, String> data) {
              clearBook();
              commandContext.message('Creating account...');
              commandContext.send('createAccount', <dynamic>[data['username'], data['password']]);
            }, showMessage, submitLabel: 'Create Account', onCancel: resetFocus
          )
            ..addElement('username', validator: notEmptyValidator)
            ..addElement('password', element: PasswordInputElement(), validator: notEmptyValidator)
            ..addElement(
              'confirm', element: PasswordInputElement(), label: 'Confirm Password',
              validator: (String name, Map<String, String> values, String value) => value == values['password'] ? null : 'Passwords do not match.'
            )
            ..render(formBuilderDiv, beforeRender: keyboard.releaseAll);
        }, titleString: 'Create Account',
      ),
      Line(
        commandContext.book, () => commandContext.send('serverTime', null),
        titleString: 'Show Server Time'
      )
    ], dismissible: false
  );
}
