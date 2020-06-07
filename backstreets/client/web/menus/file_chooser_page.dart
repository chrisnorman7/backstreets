/// Provides the [FileChooserPage] class.
library file_chooser_page;

import 'package:game_utils/game_utils.dart';
import 'package:path/path.dart' as path;

import '../constants.dart';
import '../directory.dart';

Page fileChooserPage(
  Book b, String Function() titleFunc, Directory directory,
  String Function() getFile, void Function(String) setFile, {
    bool fileOnly = true, String Function() onCancel, bool allowNull = true,
    String Function(String) soundUrl
  }
) {
  final String currentFile = getFile();
  final String friendlyCurrentFile = currentFile == null? null : path.basename(currentFile);
  commandContext.message(currentFile);
  final List<Line> lines = <Line>[];
  if (!fileOnly) {
    lines.add(Line(b, () => setFile(directory.name), titleString : '<Random file from directory>'));
  }
  if (allowNull) {
    lines.add(Line(b, () => setFile(null), titleString: '<Unset>'));
  }
  for (final Directory subdirectory in directory.directories) {
    final String directoryName = path.basename(subdirectory.name);
    lines.add(
      Line(b, () => b.push(
        fileChooserPage(b, () => subdirectory.name, subdirectory, getFile, setFile, fileOnly: fileOnly, onCancel: onCancel, allowNull: false, soundUrl: soundUrl)
      ), titleFunc : () => '${currentFile != null && currentFile.contains(directoryName) ? "* " : ""}$directoryName (Directory)')
    );
  }
  for (final String filename in directory.files) {
    final String friendlyFilename = path.basename(filename);
    lines.add(
      Line(
        b, () => setFile(filename),
        titleFunc: () => '${currentFile != null && friendlyCurrentFile == friendlyFilename ? "* " : ""}$friendlyFilename} (File)',
        soundUrl: soundUrl == null ? null : () => soundUrl(filename)
      )
    );
  }
  return Page(lines: lines, titleFunc: titleFunc, onCancel: onCancel, playDefaultSounds: false);
}
