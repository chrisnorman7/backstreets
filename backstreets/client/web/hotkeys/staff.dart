/// Hotkeys that can only be used if a player is a builder or an admin.
library staff;

import 'dart:html';

import 'package:game_utils/game_utils.dart';

import '../main.dart';
import '../util.dart';

void goto() {
  FormBuilder('Goto', (Map<String, String> data) async {
    resetFocus();
    final double x = double.tryParse(data['x']);
    final double y = double.tryParse(data['y']);
    moveCharacter(x, y, mode: MoveModes.staff);
  }, showMessage, onCancel: resetFocus)
    ..addElement('x', element: NumberInputElement(), value:commandContext.coordinates.x.round().toString())
    ..addElement('y', element: NumberInputElement(), value: commandContext.coordinates.y.round().toString())
    ..render(formBuilderDiv, beforeRender: keyboard.releaseAll);
}
