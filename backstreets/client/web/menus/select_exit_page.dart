/// Provides the [selectExitPage] function.
library select_exit_page;

import 'package:game_utils/game_utils.dart';

import '../game/exit.dart';

/// Used to select from a list of exits.
Page selectExitPage(Book b, List<Exit> exits, void Function(Exit) onDone, {void Function() onCancel}) {
  final List<Line> lines = <Line>[];
  for (final Exit e in exits) {
    lines.add(Line(b, () => onDone(e), titleString: e.name));
  }
  return Page(lines: lines, titleString: 'Exits', onCancel: onCancel);
}
