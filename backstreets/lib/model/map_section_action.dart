/// Provides the [MapSectionAction] class.
library map_section_action;

import 'package:aqueduct/aqueduct.dart';

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

  /// The social to use when this action is triggered.
  @Column(nullable: true)
  String social;

  /// The sound that should play when this social is used.
  @Column(nullable: true)
  String sound;

  /// The function to be called when this action is used.
  @Column(nullable: true)
  String functionName;
}

/// An action on a section of a map, which can be triggered with the enter key.
class MapSectionAction extends ManagedObject<_MapSectionAction> implements _MapSectionAction {
  /// Get the action associated with this object from the [actions] dictionary.
  Function get func {
    return actions[functionName];
  }

  /// Return this object as a map.
  ///
  /// This is how actions should be sent to clients.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'sectionId': section.id,
      'name': name,
      'functionName': functionName,
      'social': social,
      'sound': sound
    };
  }
}
