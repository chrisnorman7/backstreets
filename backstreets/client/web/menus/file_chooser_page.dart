/// Provides the [FileChooserPage] class.
library file_chooser_page;

import 'package:game_utils/game_utils.dart';
import 'package:path/path.dart' as path;

import '../directory.dart';

Page fileChooserPage(
  Book b, String Function() titleFunc, Directory directory,
  String Function() getFile, void Function(String) setFile, {
    bool fileOnly = true, String Function() onCancel, bool allowNull = true
  }
) {
  final String currentFile = getFile();
  final List<Line> lines = <Line>[];
  if (!fileOnly) {
    lines.add(Line(b, () => setFile(directory.name), titleString : '<Random file from directory>'));
  }
  if (allowNull) {
    lines.add(Line(b, () => setFile(null), titleString: '<Unset>'));
  }
  for (final Directory subdirectory in directory.directories) {
    lines.add(
      Line(b, () => b.push(
        fileChooserPage(b, () => subdirectory.name, subdirectory, getFile, setFile, fileOnly: fileOnly, onCancel: onCancel, allowNull: false)
      ), titleFunc : () => '${currentFile != null && path.dirname(currentFile).contains(subdirectory.name) ? "* " : ""}${path.basename(subdirectory.name)} (Directory)')
    );
  }
  for (final String filename in directory.files) {
    lines.add(Line(b, () => setFile(filename), titleFunc: () => '${currentFile != null && currentFile.endsWith(filename) ? "* " : ""}${path.basename(filename)} (File)'));
  }
  return Page(lines: lines, titleFunc: titleFunc, onCancel: onCancel);
}
