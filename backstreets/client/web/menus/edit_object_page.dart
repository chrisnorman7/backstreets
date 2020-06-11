/// Provides the [editObjectPage] function.
library edit_object_page;

import 'package:game_utils/game_utils.dart';

import '../constants.dart';
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
      }, showMessage, onCancel: resetFocus)
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
  lines.addAll(
    <Line>[
      Line(b, () {
        getInt('Object Speed', () => o.speed, (int value) => o.speed = value, 'objectSpeed', id: o.id, min: 1, allowNull: false);
      }, titleFunc: () => 'Speed (${o.speed})'),
      Line(b, () {
        getInt('Maximum Move Time', () => o.maxMoveTime, (int value)=> o.maxMoveTime = value, 'objectMaxMoveTime', id: o.id);
      }, titleFunc: () => 'Max Move Time (${o.maxMoveTime})'),
      Line(b, () {
        final List<Line> lines = <Line>[
          Line(b, () {
            b.pop();
            commandContext.sendPhrase(o, null);
          }, titleFunc: () => '${o.phrase == null ? "* " : ""}Clear')
        ];
        for (final String phrase in commandContext.phrases) {
          lines.add(Line(b, () {
            b.pop();
            commandContext.sendPhrase(o, phrase);
          }, titleFunc: () => '${o.phrase == phrase ? "* " : ""}$phrase'));
        }
        b.push(Page(lines: lines, titleString: 'Phrases', onCancel: doCancel));
      }, titleFunc: () => 'Phrase (${o.phrase})'),
      Line(b, () {
        getInt('Minimum time between phrases', () => o.minPhraseTime, (int value) => o.minPhraseTime = value, 'objectMinPhraseTime', id: o.id, min: 1000, step: 100, allowNull: false);
      }, titleFunc: () => 'Minimum time between phrases (${o.minPhraseTime})'),
      Line(b, () {
        getInt('Maximum time between phrases', () => o.maxPhraseTime, (int value) => o.maxPhraseTime = value, 'objectMaxPhraseTime', id: o.id, min: 1000, step: 100, allowNull: false);
      }, titleFunc: () => 'Maximum time between phrases (${o.maxPhraseTime})'),
      Line.checkboxLine(b, () => '${o.flying ? "Unset" : "Set"} Object Flying', () => o.flying, (bool value) {
        o.flying = value;
        commandContext.send('objectFlying', <dynamic>[o.id, o.flying]);
      }),
      Line(b, () {
        getInt('Use Exit Chance', () => o.useExitChance, (int value) => o.useExitChance = value, 'objectUseExitChance', id: o.id);
      }, titleFunc: () => 'Exit Use Chance (${o.useExitChance == null ? "Will not use exits" : "1 in ${o.useExitChance}"})'),
      Line.checkboxLine(b, () => '${o.canLeaveMap ? "Don't allow" : "Allow"} Object Leave Map', () => o.canLeaveMap, (bool value) {
        o.canLeaveMap = value;
        commandContext.send('objectCanLeaveMap', <dynamic>[o.id, o.canLeaveMap]);
      }),
      Line(
        b, () {
          clearBook();
          commandContext.send('teleport', <dynamic>[o.locationId, o.coordinates.x, o.coordinates.y]);
        }, titleString: 'Join Object'
      ),
      Line(b, () {
        clearBook();
        showMessage('Head to where you want to move the object, and pess enter.');
        commandContext.summonObjectId = o.id;
      }, titleString: 'Summon Object'),
    ]
  );
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
    ..push(Page(lines: lines, titleFunc: () => 'Objects (${commandContext.objects.length})', onCancel: doCancel));
}
