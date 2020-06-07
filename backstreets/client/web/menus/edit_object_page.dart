/// Provides the [editObjectPage] function.
library edit_object_page;

import 'dart:html';

import 'package:game_utils/game_utils.dart';

import '../game/game_object.dart';

import '../main.dart';
import '../util.dart';

/// Returns a page for editing a single object.
///
/// To work with multiple objects, use the [editObjects] function.
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
  lines.add(Line(b, () {
    final NumberInputElement e = NumberInputElement()
      ..min = '1'
      ..step = '1';
    FormBuilder('Object Speed', (Map<String, String> data) {
      resetFocus();
      o.speed = int.tryParse(data['speed']);
      commandContext.send('objectSpeed', <int>[o.id, o.speed]);
    }, showMessage, onCancel: resetFocus)
      ..addElement('speed', element: e, value: o.speed.toString())
      ..render(formBuilderDiv, beforeRender: keyboard.releaseAll);
  }, titleFunc: () => 'Speed (${o.speed})'));
  lines.add(Line(b, () {
    final NumberInputElement e = NumberInputElement()
      ..min = '0'
      ..step = '1';
    FormBuilder('Max Move Interval', (Map<String, String> data) {
      resetFocus();
      o.maxMoveTime = int.tryParse(data['speed']);
      if (o.maxMoveTime == 0) {
        o.maxMoveTime = null;
      }
      commandContext.send('objectMaxMoveTime', <int>[o.id, o.maxMoveTime]);
    }, showMessage, onCancel: resetFocus)
      ..addElement('speed', element: e, value: o.maxMoveTime == null ? '0' : o.maxMoveTime.toString(), label: 'Max move time')
      ..render(formBuilderDiv, beforeRender: keyboard.releaseAll);
  }, titleFunc: () => 'Max Move Time (${o.maxMoveTime})'));
  return Page(lines: lines, titleFunc: () => 'Edit ${o.name} (#${o.id})');
}

/// Creates a menu that lets you edit from a list of objects.
void editObjects({bool allowAddObject = false}) {
  final List<Line> lines = <Line>[];
  if (allowAddObject){
    lines.add(Line(commandContext.book, () {
      clearBook();
      commandContext.send('addObject', null);
    }, titleString: 'Add Object'));
  }
  for (final GameObject o in commandContext.objects) {
    lines.add(
      Line(commandContext.book, () => commandContext.book.push(editObjectPage(commandContext.book, o)), titleString: o.toString())
    );
  }
  commandContext.book = Book(bookOptions)
    ..push(Page(lines: lines, titleFunc: () => 'Players (${commandContext.objects.length})', onCancel: doCancel));
}
