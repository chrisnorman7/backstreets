/// Provides the [editObjectPage] function.
library edit_object_page;

import 'package:game_utils/game_utils.dart';

import '../game/game_object.dart';

import '../main.dart';
import '../util.dart';

Page editObjectPage(Book b, GameObject o) {
  final List<Line> lines = <Line>[
    Line(b, () {
      FormBuilder('Rename Object', (Map<String, String> data) {
        resetFocus();
        o.name = data['name'];
        commandContext.send('renameObject', <dynamic>[o.id, o.name]);
      }, showMessage)
        ..addElement(
          'name', label: 'Object Name', value: o.name,
          validator: notSameAsValidator(() => o.name, message: 'You cannot enter the same name.', onSuccess: notEmptyValidator)
        )
        ..render(formBuilderDiv, beforeRender: keyboard.releaseAll);
    }, titleString: 'Rename'),
  ];
  if (o.permissions != null) {
    lines.addAll(<Line>[
      Line.checkboxLine(b, () => '${o.permissions.builder ? "Unset" : "Set"} Builder', () => o.permissions.builder, (bool value) {
        resetFocus();
        o.permissions.builder = value;
        commandContext.send('setObjectPermission', <dynamic>[o.id, 'builder', value]);
      }),
      Line.checkboxLine(b, () => '${o.permissions.admin ? "Unset" : "Set"} Admin', () => o.permissions.admin, (bool value) {
        resetFocus();
        o.permissions.admin = value;
        commandContext.send('setObjectPermission', <dynamic>[o.id, 'admin', value]);
      })
    ]);
  }
  return Page(lines: lines, titleFunc: () => 'Edit ${o.name} (#${o.id})');
}
