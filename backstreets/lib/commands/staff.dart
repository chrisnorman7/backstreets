/// Provides staff only commands.
library staff;

import '../model/game_map.dart';
import '../model/game_object.dart';
import 'command_context.dart';

Future<void> teleport(CommandContext ctx) async {
  final int id = ctx.args[0] as int;
  final double x = (ctx.args[1] as num).toDouble();
  final double y = (ctx.args[2] as num).toDouble();
  final GameMap m = await ctx.db.fetchObjectWithID(id);
  if (m == null) {
    return ctx.sendError('Invalid map ID.');
  }
  final GameObject c = await ctx.getCharacter();
  await c.move(ctx.db, m, x, y);
}
