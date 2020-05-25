/// Provides the [mapSectionMenu] function.
library map_section_menu;

import 'dart:html';

import 'package:game_utils/game_utils.dart';

import '../commands/command_context.dart';

import '../main.dart';
import '../map_section.dart';
import '../util.dart';

import 'select_tile_menu.dart';

/// Edit a map section.
Page mapSectionMenu(Book b, MapSection s, CommandContext ctx, {void Function() onUpload}) {
  final List<Line> lines = <Line>[
    Line(b, () {
      FormBuilder('Rename', (Map<String, String> data) {
        resetFocus();
        s.name = data['name'];
      }, showMessage)
        ..addElement('name', validator: notEmptyValidator, value: s.name)
        ..render(formBuilderDiv, beforeRender: keyboard.releaseAll);
    }, titleFunc: () => 'Rename (${s.name})'),
    Line(b, () {
      b.push(
        selectTilePage(
          b, () => s.tileName,
          (String name) {
            b.pop();
            s.tileName = name;
            ctx.message('Default tile set to $name.');
          },
        )
      );
    }, titleFunc: () => 'DefaultTile (${s.tileName})'),
    Line(b, () {
      s
        ..startX = ctx.coordinates.x.floor()
        ..startY = ctx.coordinates.y.floor();
      ctx.message('Start coordinates set.');
    }, titleFunc: () => 'Start Coordinates (${s.startCoordinates.x}, ${s.startCoordinates.y})'),
    Line(b, () {
      s
        ..endX = ctx.coordinates.x.floor()
        ..endY = ctx.coordinates.y.floor();
      ctx.message('End coordinates set.');
    }, titleFunc: () => 'End Coordinates (${s.endCoordinates.x}, ${s.endCoordinates.y})'),
    Line(b, () {
      final NumberInputElement e = NumberInputElement()
        ..min = '0.01'
        ..max = '1.0'
        ..step = '0.01';
      FormBuilder('Tile Size', (Map<String, String> data) {
        resetFocus();
        s.tileSize = double.tryParse(data['tileSize']);
      }, showMessage)
        ..addElement('tileSize', element: e, label: 'Tile size', value: s.tileSize.toString())
        ..render(formBuilderDiv, beforeRender: keyboard.releaseAll);
    }, titleFunc: () => 'Tile Size (${s.tileSize})'),
    Line(b, () {
      if (s.name == null || s.name.isEmpty) {
        ctx.message('You must first set a name.');
      } else if (s.tileName == null) {
        ctx.message('You must set the default tile.');
      } else if (s.startCoordinates == null) {
        ctx.message('You must first set start coordinates.');
      } else if (s.endCoordinates == null) {
        ctx.message('You must first set end coordinates.');
      } else {
        String commandName;
        if (s.id == null) {
          commandName = 'addMapSection';
        } else {
          commandName = 'editMapSection';
        }
        ctx.send(commandName, <Map<String, dynamic>>[s.asMap()]);
        ctx.message('Uploading.');
        if (onUpload != null) {
          onUpload();
        }
      }
    }, titleString: 'Upload')
  ];
  if (s.id != null) {
    lines.addAll(<Line>[
      Line(b, () {
        commandContext.send('resetMapSection', <int>[s.id]);
        b.pop();
        showMessage('Resetting Section...');
        commandContext.sectionResetId = s.id;
      }, titleString: 'Reset'),
      Line(b, () {
        b.push(
          Page.confirmPage(b, () {
            ctx.book = null;
            ctx.send('deleteMapSection', <int>[s.id]);
          })
        );
      }, titleString: 'Delete')
    ]);
  }
  return Page(titleFunc: () => s.id == null? 'Add Section' : 'Edit Section', lines: lines);
}
