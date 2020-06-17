/// Provides actions functions, and the [actions] dictionary.
///
/// To add a new action, simply add it to the dictionary.
///
/// ```
/// actions['name'] = Action('Do something cool', (MapSection s, CommandContext ctx) => ctx.message('You just activated an action.'));
/// ```
library actions;

import 'package:aqueduct/aqueduct.dart';
import 'package:backstreets/model/builder_permission.dart';

import '../commands/command_context.dart';
import '../game/util.dart';
import '../model/game_map.dart';
import '../model/game_object.dart';
import '../model/map_section.dart';

/// The actions dictionary.
Map<String, void Function(MapSection, CommandContext)> actions = <String, void Function(MapSection, CommandContext)>{
  'Random Teleport': (MapSection s, CommandContext ctx) async {
    final GameObject c = await ctx.getCharacter();
    final Query<GameMap> q = Query<GameMap>(ctx.db);
    final GameMap m = randomElement<GameMap>(await q.fetch());
    await c.move(ctx.db, m.popX.toDouble(), m.popY.toDouble(), destination: m);
  },
  'Make Builder': (MapSection s, CommandContext ctx) async {
    final GameObject c = await ctx.getCharacter();
    final Duration d = await c.connectedDuration(ctx.db);
    if (d.inDays < 7) {
      return ctx.sendError('You must have been connected for at least a week before you can become a builder.');
    }
    if (c.steps < 10000) {
      return ctx.sendError('You are not well traveled enough.');
    }
    if (c.admin == true) {
      return ctx.sendError('You are already an admin. What more do you want?');
    }
    GameMap m = GameMap()
      ..name = "${c.name}'s Map";
    m = await ctx.db.insertObject(m);
    final BuilderPermission p = BuilderPermission()
      ..location = m
      ..object = c;
    await ctx.db.insertObject(p);
    await c.move(ctx.db, m.popX.toDouble(), m.popY.toDouble(), destination: m);
    ctx.message('You are a builder now. Please behave accordingly.');
  },
};
