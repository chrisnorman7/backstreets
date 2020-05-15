/// Contains the [BackstreetsConfiguration] class for app configuration.
library config;

import 'dart:io';

import 'package:aqueduct/aqueduct.dart';

class BackstreetsConfiguration extends Configuration {
  BackstreetsConfiguration(String configPath) : super.fromFile(File(configPath));

  DatabaseConfiguration database;
}
