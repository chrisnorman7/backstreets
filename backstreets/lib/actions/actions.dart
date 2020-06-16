/// Provides actions functions, and the [actions] dictionary.
///
/// To add a new action, simply add it to the dictionary.
///
/// ```
/// actions['name'] = Action('Do something cool', (MapSection s, CommandContext ctx) => ctx.message('You just activated an action.'));
/// ```
library actions;

import 'package:aqueduct/aqueduct.dart';

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
  }
};
