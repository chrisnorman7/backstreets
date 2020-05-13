/// Finish the job of creating commands via reflection.
library builder;

import 'dart:mirrors';

import 'package:aqueduct/aqueduct.dart';

import 'command.dart';
import 'commands.dart';

void buildCommands() {
  for (final CommandCollection collection in commandCollections) {
    final Logger collectionLogger = Logger(collection.name);
    final InstanceMirror instanceMirror = reflect(collection);
    final ClassMirror classMirror = instanceMirror.type;
    classMirror.instanceMembers.forEach((Symbol name, MethodMirror methodMirror) {
      for (final InstanceMirror metadata in methodMirror.metadata) {
        if (metadata.reflectee == command) {
          final String methodName = MirrorSystem.getName(name);
          collectionLogger.info('Adding command $methodName.');
          commands[methodName] = instanceMirror.getField(name).reflectee as CommandType;
        }
      }
    });
  }
}
