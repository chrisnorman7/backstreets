/// provides the [EditExitPage] function.
library edit_exit_page;

import 'package:game_utils/game_utils.dart';

import '../game/exit.dart';
import '../game/map_reference.dart';
import '../main.dart';
import '../util.dart';
import 'map_reference_page.dart';

Page editExitPage(Book b, Exit e) {
  final List<Line> lines = <Line>[
    Line(b, () {
      FormBuilder('Rename', (Map<String, String> data) {
        e.name = data['name'];
        e.update();
        resetFocus();
      }, showMessage, onCancel: resetFocus)
        ..addElement('name', value: e.name, validator: notEmptyValidator)
        ..render(formBuilderDiv, beforeRender: keyboard.releaseAll);
    }, titleString: 'Rename'),
    Line(b, () {
      FormBuilder('Use Social', (Map<String, String> data) {
        resetFocus();
        e.useSocial = data['social'];
        if (e.useSocial.isEmpty) {
          e.useSocial = null;
        }
        e.update();
      }, showMessage, onCancel: resetFocus)
        ..addElement('social', value: e.useSocial ?? '')
        ..render(formBuilderDiv, beforeRender: keyboard.releaseAll);
    }, titleFunc: () => 'Use Social (${e.useSocial})'),
    Line(b, () {
      final List<Line> lines = <Line>[
        Line(b, () {
          b.pop();
          e.useSound = null;
          e.update();
        }, titleString: 'Clear', soundUrl: () => null)
      ];
      commandContext.exitSounds.forEach((String name, String url) {
        lines.add(Line(b, () {
          b.pop();
          e.useSound = name;
          e.update();
        }, titleString: name, soundUrl: () => url));
      });
      b.push(Page(lines: lines, titleString: 'Use Sound'));
    }, titleFunc: () => 'Use Sound (${e.useSound})', soundUrl: () => e.useSound == null ? null : commandContext.exitSounds[e.useSound]),
    Line(b, () {
      commandContext.send('teleport', <int>[e.destinationId, e.destinationX, e.destinationY]);
      clearBook();
    }, titleString: 'Go To Destination'),
    Line(b, () {
      b.push(mapReferencePage('Destination', (MapReference r) {
        b.pop();
        e.destinationId = r.id;
        e.update();
      }));
    }, titleFunc: () => 'Set Destination (${commandContext.maps[e.destinationId].name})'),
    Line(b, () {
      commandContext.message('Move to where this exit should lead to and press enter.');
      commandContext.exit = e;
      clearBook();
    }, titleFunc: () => 'Move destination (${e.destinationX}, ${e.destinationY})'),
    Line.checkboxLine(b, () => '${e.permissions.builder ? "Unset" : "Set"} Builder', () => e.permissions.builder, (bool value) {
      e.permissions.builder = value;
      e.update();
    }),
    Line.checkboxLine(b, () => '${e.permissions.admin ? "Unset" : "Set"} Admin', () => e.permissions.admin, (bool value) {
      e.permissions.admin = value;
      e.update();
    }),
    Line(b, () {
      b.push(Page.confirmPage(b, () {
        clearBook();
        commandContext.send('deleteExit', <int>[e.id]);
      }));
    }, titleString: 'Delete Exit')
  ];
  return Page(lines: lines, titleString: 'Configure Exit');
}