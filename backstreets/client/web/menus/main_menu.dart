/// Provides the [mainMenu] [Page].
library main_menu;

import 'dart:html';

import '../form_builder.dart';
import '../main.dart';

import 'line.dart';
import 'page.dart';

Page mainMenu() {
  return Page(
    titleString: 'Main Menu',
    lines: <Line>[
      Line(
        commandContext.book, () {
          final FormBuilder loginForm = FormBuilder('Login', (Map<String, String> data) {
            commandContext.book = null;
            commandContext.message('Logging in...');
            commandContext.send('login', <String>[data['username'], data['password']]);
          },
          subTitle: 'Log into your account', submitLabel: 'Login');
          loginForm.addElement('username', validator: notEmptyValidator);
          loginForm.addElement('password', element: PasswordInputElement(), validator: notEmptyValidator);
          loginForm.render();
        },
        titleString: 'Login'
      ),
      Line(
        commandContext.book, () {
          final FormBuilder createForm = FormBuilder(
            'Create Account', (Map<String, String> data) {
              commandContext.book = null;
              commandContext.message('Creating account...');
              commandContext.send('createAccount', <dynamic>[data['username'], data['password']]);
            }, submitLabel: 'Create Account'
          );
          createForm.addElement('username', validator: notEmptyValidator);
          createForm.addElement('password', element: PasswordInputElement(), validator: notEmptyValidator);
          createForm.addElement(
            'confirm', element: PasswordInputElement(), label: 'Confirm Password',
            validator: (String name, Map<String, String> values, String value) => value == values['password'] ? null : 'Passwords do not match.'
          );
          createForm.render();
        }, titleString: 'Create Account',
      ),
      Line(
        commandContext.book, () => commandContext.send('serverTime', <dynamic>[]),
        titleString: 'Show Server Time'
      )
    ], dismissible: false
  );
}
