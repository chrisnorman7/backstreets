/// Provides building related hotkeys.
library building;

import '../commands/command_context.dart';

import '../form_builder.dart';

import '../main.dart';
import '../map_section.dart';

import '../menus/book.dart';
import '../menus/line.dart';
import '../menus/map_section_menu.dart';
import '../menus/page.dart';

import '../util.dart';


void builderMenu(CommandContext ctx) {
  ctx.book = Book(ctx.sounds, showMessage);
  final Page page = Page(
    lines: <Line>[
      Line(ctx.book, () {
        ctx.section ??= MapSection(
          null, ctx.coordinates.x.floor(),
          ctx.coordinates.y.floor(),
          ctx.coordinates.x.floor(),
          ctx.coordinates.y.floor(),
          'Untitled Section', ctx.tileNames[0], 0.5
        );
        ctx.book.push(
          mapSectionMenu(ctx.book, ctx.section, commandContext, onUpload: () {
            ctx.section = null;
            ctx.book = null;
          })
        );
      }, titleString: 'New Section Menu'),
      Line(ctx.book, () =>ctx.book.push(
        mapSectionMenu(ctx.book, ctx.getCurrentSection(), commandContext)
      ), titleString: 'Current Section Menu'),
      Line(ctx.book, () {
        final List<Line> lines = <Line>[];
        ctx.sections.forEach((int id, MapSection s) => lines.add(
          Line(
            ctx.book, () => ctx.book.push(mapSectionMenu(ctx.book, s, commandContext)
          ), titleFunc: () => '${s.name} (${s.startX}, ${s.startY} -> ${s.endX}, ${s.endY})', soundUrl: () => getFootstepSound(s.tileName))
        ));
        ctx.book.push(Page(titleString: 'Map Sections', lines: lines));
      }, titleString: 'Other Sections Menu'),
      Line (ctx.book, () {
        ctx.book.push(
          Page(
            titleString: 'Map', lines: <Line>[
              Line(ctx.book, () => ctx.book.push(
                Page.ambiencesPage(
                  ctx.book, (String ambience) {
                    ctx.send('mapAmbience', <String>[ambience]);
                    ctx.book.pop();
                  }, titleString: 'Ambiences'
                )
              ), titleFunc: () => 'Ambience (${ctx.ambienceUrl})'),
              Line(ctx.book, () {
                  ctx.book = null;
                FormBuilder(
                  'Rename Map', (Map<String, String> data) => ctx.send('renameMap', <String>[data['name']]),
                  subTitle: 'Enter the new name for this map.'
                )
                  ..addElement(
                    'name', label: 'Map Name',
                    validator: notSameAsValidator(() => ctx.mapName, message: 'The new map name cannot be the same as the old one.', onSuccess: notEmptyValidator),
                    value: ctx.mapName)
                  ..render();
              }, titleString: 'Rename Map'),
            ]
          )
        );
      }, titleString: 'Map Menu'),
    ], titleString: 'Building', onCancel: () {
      showMessage('Done.');
      clearBook();
    }
  );
  ctx.book.push(page);
}
