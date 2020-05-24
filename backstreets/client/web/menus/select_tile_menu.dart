/// Provides the [selectTilePage] function.
library tile_menu;

import 'package:game_utils/game_utils.dart';

import '../main.dart';

import '../util.dart';

/// Create a page for selecting a tile name.
Page selectTilePage(
  Book book, String Function() getTileName, void Function(String) setTileName, {String title = 'Tiles'}
) {
  final List<Line> lines = <Line>[];
  for (final String name in commandContext.tileNames) {
    lines.add(
      Line(
        book, () => setTileName(name),
        titleString: '${name == getTileName() ? "* " : ""}$name',
        soundUrl: () => getFootstepSound(name)
      )
    );
  }
  return Page(playDefaultSounds: false, titleString: title, lines: lines);
}
