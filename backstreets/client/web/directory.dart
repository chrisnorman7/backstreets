/// Provides the [Directory] class.
library directory;

/// A directory.
///
/// Directories have a [name], as well as a list of [files].
class Directory {
  Directory(this.name, this.files);

  Directory.fromData(Map<String, dynamic> data) {
    name = data['name'] as String;
    files = <String>[];
    for (final dynamic filename in data['files'] as List<dynamic>) {
      files.add(filename as String);
    }
    for (final dynamic subdirectoryData in data['directories'] as List<dynamic>) {
      directories.add(Directory.fromData(subdirectoryData as Map<String, dynamic>));
    }
  }

  /// The name of this directory.
  String name;

  /// A list of subdirectories.
  List<Directory> directories = <Directory>[];

  /// A list of filenames contained by this directory.
  List<String> files;
}
