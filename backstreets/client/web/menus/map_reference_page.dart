/// Provides the [mapReferenceMenu] function.
library map_reference_menu;

import 'package:game_utils/game_utils.dart';

import '../constants.dart';
import '../game/map_reference.dart';

Page mapReferencePage(String title, void Function(MapReference) onOk, {bool Function(MapReference) shouldInclude, void Function() onCancel}) {
  final List<Line> lines = <Line>[];
  commandContext.maps.forEach((int id, MapReference mr) {
    if (shouldInclude != null && shouldInclude(mr) == false) {
      return null;
    }
    lines.add(
      Line(commandContext.book, () => onOk(mr), titleString: mr.name)
    );
  });
  return Page(lines: lines, titleString: title, onCancel: onCancel);
}
