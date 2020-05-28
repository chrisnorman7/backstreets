/// Provides the [mapSectionPage] function.
library map_section_page;

import 'dart:html';

import 'package:game_utils/game_utils.dart';

import '../commands/command_context.dart';

import '../game/map_section.dart';

import '../main.dart';
import '../util.dart';

import 'edit_convolver_page.dart';
import 'select_tile_page.dart';

/// Edit a map section.
Page mapSectionPage(Book b, MapSection s, CommandContext ctx, {void Function() onUpload, void Function() onCancel}) {
  final List<Line> lines = <Line>[
    Line(b, () {
      FormBuilder('Rename', (Map<String, String> data) {
        resetFocus();
        s.name = data['name'];
      }, showMessage, onCancel: resetFocus)
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
      commandContext.mapSectionResizer = MapSectionResizer(s, DragCoordinates.start);
      clearBook();
      ctx.message('Dragging the start coordinates for ${s.name}. Use your arrow keys to drag, and your enter key when done.');
    }, titleString: 'Drag Start Coordinates'),
    Line(b, () {
      commandContext.mapSectionResizer = MapSectionResizer(s, DragCoordinates.end);
      clearBook();
      ctx.message('Dragging the end coordinates for ${s.name}. Use your arrow keys to drag, and your enter key when done.');
    }, titleString: 'Drag end Coordinates'),
    Line(b, () {
      final NumberInputElement e = NumberInputElement()
        ..min = '0.01'
        ..max = '1.0'
        ..step = '0.01';
      FormBuilder('Tile Size', (Map<String, String> data) {
        resetFocus();
        s.tileSize = double.tryParse(data['tileSize']);
      }, showMessage, onCancel: resetFocus)
        ..addElement('tileSize', element: e, label: 'Tile size', value: s.tileSize.toString())
        ..render(formBuilderDiv, beforeRender: keyboard.releaseAll);
    }, titleFunc: () => 'Tile Size (${s.tileSize})'),
    Line(b, () => b.push(editConvolverPage(b, s.convolver)), titleString: 'Convolver'),
    Line(b, () {
      clearBook();
      moveCharacter(Point<double>(s.startCoordinates.x.toDouble(), s.startCoordinates.y.toDouble()), mode: MoveModes.staff);
    }, titleString: 'Move To Start Coordinates'),
    Line(b, () {
      clearBook();
      moveCharacter(Point<double>(s.endCoordinates.x.toDouble(), s.endCoordinates.y.toDouble()), mode: MoveModes.staff);
    }, titleString: 'Move To End Coordinates'),
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
  return Page(titleFunc: () => s.id == null? 'Add Section' : 'Edit Section', lines: lines, onCancel: onCancel);
}
