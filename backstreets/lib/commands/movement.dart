/// Provides movement-related commands.
library movement;

import 'package:aqueduct/aqueduct.dart';

import '../model/exit.dart';
import '../model/game_map.dart';
import '../model/game_object.dart';
import '../model/map_section.dart';

import 'command_context.dart';

/// The player has moved their character, now they're letting us know the new coordinates.
///
/// This function ensures the coordinates they are trying to move to are valid.
///
/// If they are not, a counter coordinates call is sent, hopefully re-aligning the character's client.
Future<void> characterCoordinates(CommandContext ctx) async {
  final double x = (ctx.args[0] as num).toDouble();
  final double y = (ctx.args[1] as num).toDouble();
  final GameObject c = await ctx.getCharacter();
  if (!c.staff) {
    final GameMap m = await ctx.getMap();
    if (!(await m.validCoordinates(ctx.db, x.floor(), y.floor()))) {
      ctx.logger.warning('Tried to move to $x, $y.');
      return ctx.send('characterCoordinates', <double>[c.x, c.y]);
    }
  }
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..values.x = x
    ..values.y = y
    ..values.steps = c.steps + 1
    ..where((GameObject o) => o.id).equalTo(c.id);
  await q.updateOne();
}

/// The character has turned their player, now they're letting us know.
///
/// No checks are performed here. If the value is < 0 or > 360, it's because the player is doing something dodgy, but there's no risk as far as I can tell.
Future<void> characterTheta(CommandContext ctx) async {
  double theta;
  if (ctx.args[0] is int) {
    theta = (ctx.args[0] as int).toDouble();
  } else {
    theta = ctx.args[0] as double;
  }
  final Query<GameObject> q = Query<GameObject>(ctx.db)
    ..values.theta = theta
    ..where((GameObject o) => o.id).equalTo(ctx.characterId);
  await q.updateOne();
}

Future<void> resetMapSection(CommandContext ctx) async {
  final Query<MapSection> q = Query<MapSection>(ctx.db)
    ..where((MapSection s) => s.id).equalTo(ctx.args[0] as int)
    ..where((MapSection s) => s.location).identifiedBy(ctx.mapId);
  final MapSection s = await q.fetchOne();
  return ctx.send('mapSection', <Map<String, dynamic>>[s.asMap()]);
}

Future<void> exit(CommandContext ctx) async{
  final int id = ctx.args[0] as int;
  final GameObject c = await ctx.getCharacter();
  final Query<Exit> q = Query<Exit>(ctx.db)
  ..join(object: (Exit e) => e.location)
    ..join(object: (Exit e) => e.destination)
    ..where((Exit e) => e.location).identifiedBy(ctx.mapId)
    ..where((Exit e) => e.x).equalTo(c.x.floor())
    ..where((Exit e) => e.y).equalTo(c.y.floor())
    ..where((Exit e) => e.id).equalTo(id);
  final Exit e = await q.fetchOne();
  if (e == null) {
    return ctx.sendError('Invalid exit ID.');
  }
  await e.use(ctx.db, await ctx.getCharacter());
}
