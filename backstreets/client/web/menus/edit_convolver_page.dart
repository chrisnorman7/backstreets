/// Provides the [ConvolverChooserPage] class.
library edit_convolver_page;

import 'dart:html';
import 'dart:web_audio';

import 'package:game_utils/game_utils.dart';

import '../game/convolver.dart';

import '../main.dart';
import '../util.dart';

import 'file_chooser_page.dart';

/// Create a menu for editing a convolver.
Page editConvolverPage(Book b, Convolver convolver, {void Function() onChange}) {
  final List<Line> lines = <Line>[
    Line(b, () => b.push(
      fileChooserPage(
        b, () => 'Convolver URL (${convolver.url == null ? "<Not set>" : convolver.compactUrl})', commandContext.impulses,
        () => convolver.compactUrl, (String url) {
          if (url == null) {
            convolver.url = null;
          } else {
            convolver.url = url;
          }
          convolver.resetConvolver();
          commandContext.message('URL set.');
          clearBook();
          if (onChange != null) {
            onChange();
          }
        }, soundUrl: (String filename) {
          commandContext.sounds.loadBuffer(filename, (AudioBuffer buffer) {
            final GainNode g = commandContext.sounds.audioContext.createGain()
              ..gain.value = convolver.volume.gain.value
              ..connectNode(commandContext.sounds.soundOutput);
            final ConvolverNode c = commandContext.sounds.audioContext.createConvolver()
              ..buffer = buffer
              ..connectNode(g);
            commandContext.sounds.playSound(commandContext.echoSounds[commandContext.options.echoSound]).source.connectNode(c);
          });
          return null;
        }
      )
    ), titleFunc: () => 'URL (${convolver.url == null ? "<Not set>" : convolver.compactUrl})'),
    Line(b, () {
      final NumberInputElement e = NumberInputElement()
        ..step = '0.05'
        ..min = '0.0'
        ..max = '1.0';
      FormBuilder('Convolver Volume', (Map<String, String> data) {
        convolver.volume.gain.value = double.parse(data['volume']);
        showMessage('Volume set.');
        if (onChange != null) {
          onChange();
        }
      }, showMessage, onCancel: resetFocus)
        ..addElement('volume', element: e, value: convolver.volume.gain.value.toStringAsFixed(2), label: 'Convolver Volume')
        ..render(formBuilderDiv, beforeRender: keyboard.releaseAll);
    }, titleFunc: () => 'Volume (${convolver.volume.gain.value.toStringAsFixed(2)})'),
  ];
  return Page(lines: lines, titleString: 'Edit Convolver');
}
