/// Provides the [ActionPage] method.
library action_page;

import 'package:game_utils/game_utils.dart';

import '../constants.dart';
import '../game/action.dart';
import '../util.dart';

/// Used to edit [Action] classes.
Page actionPage(Book b, Action a) {
  final List<Line> lines = <Line>[
    Line(b, () {
      getString('Rename', () => a.name, (String value) => a.name = value, emptyString: EmptyStringHandler.disallow);
    }, titleFunc: () => 'Rename (${a.name}'),
    Line(b, () {
      getString('Social String', () => a.social, (String value) => a.social = value);
    }, titleFunc: () => 'Social String (${a.social}'),
    Line(b, () {
      final List<Line> lines = <Line>[
        Line(b, () {
          a.sound = null;
          b.pop();
        }, titleString: 'Clear')
      ];
      commandContext.actionSounds.forEach((String name, List<String> sounds) {
        lines.add(Line(b, () {
          b.pop();
          a.sound = name;
        }, titleString: name, soundUrl: () => randomElement<String>(sounds)));
      });
      b.push(Page(lines: lines, titleFunc: () => 'Action Sounds (${commandContext.actionSounds.length})'));
    }, titleFunc: () => 'Sound (${a.sound})', soundUrl: () => a.sound == null ? null : randomElement<String>(commandContext.actionSounds[a.sound])),
    Line(b, () {
      final List<Line> lines = <Line>[
        Line(b, () {
          a.functionName = null;
          b.pop();
        }, titleString: 'Clear')
      ];
      for (final String name in commandContext.actionFunctions) {
        lines.add(Line(b, () {
          a.functionName = name;
          b.pop();
        }, titleFunc: () => '$name (${name == a.functionName ? "*" : " "})'));
      }
      b.push(Page(lines: lines, titleFunc: () => 'Functions (${commandContext.actionFunctions.length})'));
    }, titleFunc: () => 'Function (${a.functionName})'),
    Line(b, () {
      getString('Confirm Message', () => a.confirmMessage, (String value) => a.confirmMessage = value);
    }, titleFunc: () => 'Confirm Message (${a.confirmMessage}'),
    Line(b, () {
      getString('Confirm Social', () => a.confirmSocial, (String value) => a.confirmSocial = value);
    }, titleFunc: () => 'Confirm Social (${a.confirmSocial}'),
    Line(b, () {
      getString('OK Label', () => a.okLabel, (String value) => a.okLabel = value);
    }, titleFunc: () => 'OK Label (${a.okLabel}'),
    Line(b, () {
      getString('Cancel Label', () => a.cancelLabel, (String value) => a.cancelLabel = value);
    }, titleFunc: () => 'Cancel Label (${a.cancelLabel}'),
    Line(b, () {
      getString('Cancel Social', () => a.cancelSocial, (String value) => a.cancelSocial = value);
    }, titleFunc: () => 'Cancel Social (${a.cancelSocial}'),
    Line(b, () {
      a.upload(commandContext);
      clearBook();
    }, titleString: 'Upload'),
    Line(b, () {
      b.push(Page.confirmPage(b, () {
        clearBook();
        commandContext.send('removeMapSectionAction', <int>[a.sectionId, a.id]);
      }));
    }, titleString: 'Delete'),
  ];
  return Page(lines: lines, titleString: 'Edit Action', onCancel: resetFocus);
}