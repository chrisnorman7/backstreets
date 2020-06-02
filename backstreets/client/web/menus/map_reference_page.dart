/// Provides the [mapReferenceMenu] function.
library map_reference_menu;

import 'package:game_utils/game_utils.dart';

import '../game/map_reference.dart';

import '../main.dart';
import '../util.dart';

Page mapReferencePage(String title, void Function(MapReference) onOk) {
  final List<Line> lines = <Line>[];
  commandContext.maps.forEach((int id, MapReference mr) {
    lines.add(
      Line(commandContext.book, () => onOk(mr), titleString: mr.name)
    );
  });
  return Page(lines: lines, titleString: title, onCancel: clearBook);
}