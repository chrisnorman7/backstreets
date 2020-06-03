/// Provides actions functions, and the [actions] dictionary.
///
/// To add a new action, simply add it to the dictionary.
///
/// ```
/// actions['name'] = Action('Do something cool', (MapSection s, CommandContext ctx) => ctx.message('You just activated an action.'));
/// ```
library actions;

import '../commands/command_context.dart';
import '../model/game_object.dart';
import '../model/map_section.dart';
import 'action.dart';

/// The actions dictionary.
Map<String, Action> actions = <String, Action>{
  'splash': Action('Splash in the water', (MapSection s , CommandContext ctx) async {
    final GameObject c = await ctx.getCharacter();
    c.doSocial(ctx.db, '%1N splash%1es in the ${s.name.toLowerCase()}.');
  }),
  'look': Action('Look around', (MapSection s, CommandContext ctx) async => ctx.message('You look around.')),
};
