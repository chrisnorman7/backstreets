// Various utility functions.
library util;

import 'dart:math';

/// The random number generator.
final Random random = Random();

/// Generate a random number between start and end inclusive.
int randInt(int end, {int start = 0}) {
  return random.nextInt(end) + start;
}

/// Return a random element from a list.
///
///
/// This function doesn't check for an empty list.
T randomElement<T>(List<T> items) {
  return items[randInt(items.length)];
}

/// Convert a theta to a human readable string.
String headingToString(double angle) {
  const List<String> directions = <String>[
    'north',
    'north-east',
    'east',
    'south-east',
    'south',
    'south-west',
    'west',
    'north-west',
  ];
  final int index =
      (((angle %= 360) < 0 ? angle + 360 : angle) ~/ 45 % 8).round();
  return directions[index];
}
