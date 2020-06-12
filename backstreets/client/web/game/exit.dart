/// Provides the [Exit] class.
library exit;

import 'dart:math';

import '../commands/command_context.dart';
import '../constants.dart';
import 'game_object.dart';

class Exit {
  Exit(this.name, this.locationId, this.x, this.y);

  /// The id of this exit.
  int id;

  /// The name of this exit.
  String name;

  /// The id of the location where this exit will be located.
  int locationId;

  /// The x coordinate of this exit.
  int x;

  /// The y coordinate of this exit.
  int y;

  /// The id of the destination location.
  int destinationId;

  /// The destination x coordinate.
  int destinationX;

  /// The destination y coordinate.
  int destinationY;

  /// The social that is seen when using this exit.
  String useSocial;

  /// The sound that is played when using this exit.
  String useSound;

  /// Add permissions.
  Permissions permissions = Permissions();

  /// Get the coordinates of this object.
  Point<int> get coordinates => Point<int>(x, y);

  /// Return this object as a map.
  ///
  /// Used with the `addExit` command.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'locationId': locationId,
      'x': x,
      'y': y,
      'destinationId': destinationId,
      'destinationX': destinationX,
      'destinationY': destinationY,
      'useSocial': useSocial,
      'useSound': useSound,
      'admin': permissions.admin,
      'builder': permissions.builder,
    };
  }

  /// Use this exit.
  void use(CommandContext ctx) {
    if (ctx.canMove){
      ctx.updateLastMoved();
      ctx.send('exit', <int>[id]);
    }
  }

  /// Update this exit on the server.
  void update() => commandContext.send('editExit', <dynamic>[id, toJson()]);
}
