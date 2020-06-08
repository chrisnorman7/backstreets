/// Hotkeys that can only be used if a player is a builder or an admin.
library staff;

import 'dart:html';

import 'package:game_utils/game_utils.dart';

import '../constants.dart';
import '../game/map_reference.dart';
import '../main.dart';
import '../menus/map_reference_page.dart';
import '../util.dart';

void goto() {
  FormBuilder('Goto', (Map<String, String> data) {
    resetFocus();
    final double x = double.tryParse(data['x']);
    final double y = double.tryParse(data['y']);
    moveCharacter(Point<double>(x, y), mode: MoveModes.staff);
  }, showMessage, onCancel: doCancel)
    ..addElement('x', element: NumberInputElement(), value:commandContext.coordinates.x.round().toString())
    ..addElement('y', element: NumberInputElement(), value: commandContext.coordinates.y.round().toString())
    ..render(formBuilderDiv, beforeRender: keyboard.releaseAll);
}

void teleport() {
  commandContext.book = Book(bookOptions)
    ..push(mapReferencePage('Teleport', (MapReference m) {
      clearBook();
      commandContext.send('teleport', <int>[m.id, m.popX, m.popY]);
    }, onCancel: doCancel));
}
