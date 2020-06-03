/// Provides the [MapSectionAction] class.
library map_section_action;

import 'package:aqueduct/aqueduct.dart';

import '../actions/action.dart';
import '../actions/actions.dart';
import 'map_section.dart';
import 'mixins.dart';

/// The map section actions table.
///
/// To work with map section actions directly, use the [MapSectionAction] class.
@Table(name: 'map_section_actions')
class _MapSectionAction with PrimaryKeyMixin, NameMixin {
  /// The section this action is attached to.
  @Relate(#actions, isRequired: true, onDelete: DeleteRule.cascade)
  MapSection section;
}

/// An action on a section of a map, which can be triggered with the enter key.
class MapSectionAction extends ManagedObject<_MapSectionAction> implements _MapSectionAction {
  /// Get the action associated with this object from the [actions] dictionary.
  Action get action {
    return actions[name];
  }
}
