/// Provides the [BuilderPermission] class.
library builder_permission;

import 'package:aqueduct/aqueduct.dart';

import 'game_map.dart';
import 'game_object.dart';
import 'mixins.dart';

/// The build_permissions table.
///
/// To work with build permissions directly, use the [BuilderPermission] class.
@Table(name: 'builder_permissions')
class _BuilderPermission with PrimaryKeyMixin {
  /// The object which this permission is assigned to.
  @Relate(#builderPermissions, isRequired: true, onDelete: DeleteRule.cascade)
  GameObject object;

  /// The map that [object] has builder permissions for.
  @Relate(#builderPermissions, isRequired: true, onDelete: DeleteRule.cascade)
  GameMap location;
}

/// Allows objects to build on multiple maps, without being admins.
class BuilderPermission extends ManagedObject<_BuilderPermission> implements _BuilderPermission {}
