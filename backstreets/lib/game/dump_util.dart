/// Contains various annotations for use with the [DumpHelper] class.
///
/// * [loadable]
/// * [dumpable]
/// * [Loader]
/// * [Dumper]
library dump_util;

import 'dart:mirrors';

/// Specify that a member should be loaded by [DumpHelper.fromJson].
///
/// Don't use this annotation if you need a custom loader. If that is the case, the method should be annotated with @[Loader].
const String loadable = 'This member should be loadable.';

/// Specify that a member should be dumped with [DumpHelper.toJson].
const String dumpable = 'This member should be dumpable.';

/// Annotate methods that will dump a given member.
///
/// ```
/// class Thing with DumpHelper {
///   @dumpable
///   int maxHealth = 10;
///
///   @dumpable
///   int health;
///
///   @Dumper('health')
///   int dumpHealth() {
///     if (health == null) {
///       return maxHealth;
///     }
///     return health;
///   }
/// }
/// ```
class Dumper {
  /// Specify the name of the member this method knows how to dump.
  const Dumper(this.name);

  /// Member name.
  final String name;
}

/// Annotate methods that will load a particular value from a [Map] of dump data.
///
/// ```
/// class ImageList {
///   final List<Image> images = <Image>[];
///
///   @Loader('images')
///   void loadImages(List<String> imageUrls) {
///     for (final String url in imageUrls) {
///       images.add(Image(url));
///     }
///   }
/// }
/// ```
class Loader{
  /// Specify the key of the data [Map] which should be passed to the annotated method.
  const Loader(this.name);

  /// The key of the data [Map].
  final String name;
}

/// Returns all the methods annotated with [Dumper].
Map<String, Function> getDumpers(InstanceMirror mirror) {
  final Map<String, Function> dumpers = <String, Function>{};
  mirror.type.instanceMembers.forEach((Symbol name, MethodMirror memberMirror) {
    for (final InstanceMirror metadataMirror in memberMirror.metadata) {
      final dynamic metadata = metadataMirror.reflectee;
      if (metadata is Dumper) {
        dumpers[metadata.name] = mirror.getField(name).reflectee as Function;
      }
    }
  });
  return dumpers;
}

/// Returns all the methods annotated with [Loader].
Map<String, Function> getLoaders(InstanceMirror mirror) {
  final Map<String, Function> loaders = <String, Function>{};
  mirror.type.instanceMembers.forEach((Symbol name, MethodMirror memberMirror) {
    for (final InstanceMirror metadataMirror in memberMirror.metadata) {
      final dynamic metadata = metadataMirror.reflectee;
      if (metadata is Loader) {
        loaders[metadata.name] = mirror.getField(name).reflectee as Function;
      }
    }
  });
  return loaders;
}

/// A class which should be used as a mixin for classes wanting their members to be dumpable.
class DumpHelper {
  /// Fill members of an instance with data from a json [Map].
  void updateFromJson(Map<String, dynamic> data) {
    final InstanceMirror im = reflect(this);
    final Map<String, Function> loaders = getLoaders(im);
    im.type.declarations.forEach((Symbol name, DeclarationMirror declaration) {
      for (final InstanceMirror metadata in declaration.metadata) {
        if (metadata.reflectee == loadable) {
          final String nameString = MirrorSystem.getName(name);
          im.setField(name, data[nameString]);
          data.remove(name);
        }
      }
    });
    loaders.forEach((String name, Function func) {
      func(data[name]);
      data.remove(name);
    });
  }

  /// Allow this object to be dumped to JSON.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    final InstanceMirror im = reflect(this);
    final Map<String, Function> dumpers = getDumpers(im);
    im.type.declarations.forEach((Symbol name, DeclarationMirror declaration) {
      for (final InstanceMirror metadata in declaration.metadata) {
        if (metadata.reflectee == dumpable) {
          final String nameString = MirrorSystem.getName(name);
          dynamic value;
          if (dumpers.containsKey(nameString)) {
            value = dumpers[nameString]();
          } else {
            value = im.getField(name).reflectee;
          }
          data[nameString] = value;
        }
      }
    });
    return data;
  }
}
