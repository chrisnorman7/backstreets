/// Provides the [Exit] class.
library exit;

import 'dart:math';

import 'package:aqueduct/aqueduct.dart';

import '../sound.dart';
import 'game_map.dart';
import 'game_object.dart';
import 'mixins.dart';

/// The exits table. To deal with exits directly, use the [Exit] class instead.
@Table(name: 'exits')
class _Exit with PrimaryKeyMixin, NameMixin, IntCoordinatesMixin {
  @Relate(#exits)
  GameMap location;

  @Relate(#entrances)
  GameMap destination;

  /// The target x coordinate.
  int destinationX;

  /// The target y coordinate.
  int destinationY;

  /// The sound that plays when this exit is used.
  @Column(nullable: true)
  String useSound;

  /// The social that is seen when this exit is used.
  @Column(defaultValue: "'%1N walk%1s through %2n.'")
  String useSocial;
}

/// An exit between two maps.
///
/// Exits link maps, so that players can travel between them.
class Exit extends ManagedObject<_Exit> implements _Exit {
  /// Convert this object to a map.
  ///
  /// Used for sending with the `exit` command.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'x': x,
      'y': y,
      'useSocial': useSocial,
      'useSound': useSound,
      'destinationId': destination.id,
      'destinationX': destinationX,
      'destinationY': destinationY,
    };
  }

  /// Allow an object through this exit.
  Future<void> use(ManagedContext db, GameObject o) async {
    if (useSound != null) {
      location.broadcastSound(db, exitSounds[useSound], o.coordinates, 1.0);
      destination.broadcastSound(db, exitSounds[useSound], Point<double>(destinationX.toDouble(), destinationY.toDouble()), 1.0);
    }
    if (useSocial != null) {
      // Create a pretend object that we can use to perform socials using this exit's name.
      final GameObject pretend = GameObject()
        ..name = name
        ..x = x.toDouble()
        ..y = y.toDouble();
      o.doSocial(db, useSocial, perspectives: <GameObject>[o, pretend]);
    }
    await o.move(db, destination, destinationX.toDouble(), destinationY.toDouble());
  }
}
