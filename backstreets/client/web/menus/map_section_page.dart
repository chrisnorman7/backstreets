/// Provides the [mapSectionPage] function.
library map_section_page;

import 'dart:html';

import 'package:game_utils/game_utils.dart';

import '../commands/command_context.dart';

import '../constants.dart';
import '../game/action.dart';
import '../game/map_section.dart';

import '../main.dart';
import '../util.dart';

import 'action_page.dart';
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
    }, titleFunc: () => 'Name (${s.name})'),
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
    }, titleFunc: () => 'Footstep Sound (${s.tileName})',
    soundUrl: () => getFootstepSound(s.tileName)),
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
      if (commandContext.mapSectionMover == null) {
        commandContext.mapSectionResizer = MapSectionResizer(s, DragCoordinates.start);
        clearBook();
        ctx.message('Dragging the start coordinates for ${s.name}. Use your arrow keys to drag, and your enter key when done.');
      } else {
        commandContext.message('Finish moving ${commandContext.mapSectionMover.section.name} first.');
      }
    }, titleString: 'Drag Start Coordinates'),
    Line(b, () {
      if (commandContext.mapSectionMover == null) {
        commandContext.mapSectionResizer = MapSectionResizer(s, DragCoordinates.end);
        clearBook();
        ctx.message('Dragging the end coordinates for ${s.name}. Use your arrow keys to drag, and your enter key when done.');
      } else {
        commandContext.message('Finish moving ${commandContext.mapSectionMover.section.name} first.');
      }
    }, titleString: 'Drag end Coordinates'),
    Line(b, () {
      if (commandContext.mapSectionResizer == null) {
        commandContext.mapSectionMover = MapSectionMover(s);
        clearBook();
        commandContext.message('Use the arrow keys to move the section, and press enter when done.');
      } else {
        commandContext.message('Finish resizing ${commandContext.mapSectionResizer.section.name} first.');
      }
    }, titleString: 'Move Section'),
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
    Line(commandContext.book, () => commandContext.book.push(
      Page.soundsPage(
        commandContext.book, commandContext.ambiences.keys.toList(), (String ambience) {
          b.pop();
          if (s.id == null) {
            commandContext.message('You can only add an ambience once you have uploaded a section.');
          } else {
            commandContext.send('mapSectionAmbience', <dynamic>[s.id, ambience]);
          }
        }, (String name) => commandContext.ambiences[name], currentSound: commandContext.map.ambience.url
      )
    ), titleFunc: () => 'Ambience (${s.ambience.url})',
    soundUrl: () => s.ambience.url == null ? null : commandContext.ambiences[s.ambience.url]),
    Line(b, () {
      final NumberInputElement e = NumberInputElement()
        ..min = '0'
        ..step = '1';
      FormBuilder('Ambience Distance', (Map<String, String> data) {
        int value = int.tryParse(data['distance']);
        if (value == 0) {
          value = null;
        }
        s.ambience.distance = value;
        commandContext.message('Ambience distance updated.');
      }, showMessage, onCancel: resetFocus)
        ..addElement('distance', element: e, label: 'Ambience Distance (0 = null)', value: (s.ambience.distance == null ? '0' : s.ambience.distance.toString()))
        ..render(formBuilderDiv, beforeRender: keyboard.releaseAll);
    }, titleFunc: () => 'Ambience Distance (${s.ambience.distance})'),
    Line(b, () => b.push(editConvolverPage(b, s.convolver)), titleString: 'Convolver'),
    Line(b, () {
      final List<Line> lines = <Line>[
        Line(b, () {
          FormBuilder('Add Action', (Map<String, String> data) {
            b.pop();
            commandContext.send('addMapSectionAction', <dynamic>[s.id, data['name']]);
            resetFocus();
          }, showMessage, onCancel: resetFocus)
            ..addElement('name', validator: notEmptyValidator)
            ..render(formBuilderDiv, beforeRender: keyboard.releaseAll);
        }, titleString: 'Add Action')
      ];
      for (final Action a in s.actions.values) {
        lines.add(Line(b, () {
          b.push(actionPage(b, a));
        }, titleFunc: () => a.name));
      }
      b.push(Page(lines: lines, titleString: 'Actions', onCancel: b.pop));
    }, titleFunc: () => 'Actions (${s.actions.length})'),
    Line(b, () {
      clearBook();
      moveCharacter(Point<double>(s.startCoordinates.x.toDouble(), s.startCoordinates.y.toDouble()), mode: MoveModes.staff);
    }, titleString: 'Go to Start Coordinates'),
    Line(b, () {
      clearBook();
      moveCharacter(Point<double>(s.endCoordinates.x.toDouble(), s.endCoordinates.y.toDouble()), mode: MoveModes.staff);
    }, titleString: 'Go to End Coordinates'),
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
