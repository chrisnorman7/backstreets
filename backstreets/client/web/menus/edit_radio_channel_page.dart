/// Provides the [editRadioChannelPage] function.
library edit_radio_channel_page;

import 'package:game_utils/game_utils.dart';

import '../constants.dart';
import '../game/radio_channel.dart';
import '../util.dart';

/// A page to edit a radio channel.
Page editRadioChannelPage(Book b, RadioChannel c) {
  final List<Line> lines = <Line>[
    Line(b, () => getString('RRename', () => c.name, (String value) => c.name = value), titleFunc: () => 'Name (${c.name})'),
    Line(b, () {
      final List<Line> lines = <Line>[];
      for (final String name in commandContext.radioSounds.keys) {
        lines.add(Line(b, () {
          c.transmitSound = name;
          b.pop();
        }, titleString: '${c.transmitSound == name ? "* " : ""}$name', soundUrl: () => commandContext.radioSounds[name]));
      }
      b.push(Page(lines: lines, titleString: 'Radio Sounds'));
    }, titleFunc: () => 'Transmit Sound (${c.transmitSound})', soundUrl: () => commandContext.radioSounds[c.transmitSound]),
    Line.checkboxLine(b, () => '${c.admin ? "Unset" : "Set"} Admin', () => c.admin, (bool value) {
      c.admin = value;
      resetFocus();
    }),
    Line(b, () {
      clearBook();
      commandContext.send('editRadioChannel', <dynamic>[c.id, <String, dynamic>{
        'name': c.name,
        'transmitSound': c.transmitSound,
        'admin': c.admin,
      }]);
    }, titleString: 'Upload'),
  ];
  return Page(titleString: 'Edit Radio Channel', lines: lines, onCancel: doCancel);
}
