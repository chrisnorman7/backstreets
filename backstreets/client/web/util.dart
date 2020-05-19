/// Provides utility methods.
library util;

import 'dart:math';

import 'main.dart';

final Random random = Random();

/// Convert a theta to a human readable string.
String headingToString(double angle) {
  const List<String> directions = <String>[
    'east',
    'south-east',
    'south',
    'south-west',
    'west',
    'north-west',
    'north',
    'north-east',
  ];
  final int index =
      (((angle %= 360) < 0 ? angle + 360 : angle) ~/ 45 % 8).round();
  return '${angle.toStringAsFixed(0)} degrees ${directions[index]}';
}

/// Convert a list of items to a properly formatted english list.
String englishList(
  {
    List<String> items,
    String andString = ', and ',
    String sepString = ', ',
    String emptyString = 'nothing'
  }
) {
  if (items.isEmpty) {
    return emptyString;
  }
  if (items.length == 1) {
    return items[0];
  }
  String string = '';
  final int lastIndex = items.length - 1;
  final int penultimateIndex = lastIndex - 1;
  for (int i = 0; i < items.length; i++) {
    final String item = items[i];
    string += item;
    if (i == penultimateIndex) {
      string += andString;
    } else if (i != lastIndex) {
      string += sepString;
    }
  }
  return string;
}

/// Generate a random number between start and end inclusive.
int randInt(int end, {int start = 0}) {
  return random.nextInt(end) + start;
}

T randomElement<T>(List<T> items) {
  return items[randInt(items.length)];
}

/// A shortcut for getting a milliseconds timestamp.
int timestamp() {
  return DateTime.now().millisecondsSinceEpoch;
}

/// Turn the player by [amount]..
void turn(double amount) {
  commandContext.theta += amount;
  if (commandContext.theta < 0) {
    commandContext.theta += 360;
  } else if (commandContext.theta > 360) {
    commandContext.theta -= 360;
  }
}

/// Directions to snap in.
enum SnapDirections {
  /// Snap left.
  left,

  // Snap right.
  right,
}

/// Turn to face the nearest cardinal direction in the given direction.
void snap(SnapDirections direction) {
  final double mod = commandContext.theta % 45;
  if (direction == SnapDirections.left) {
    commandContext.theta -= mod;
  } else {
    commandContext.theta += 45 - mod;
  }
  commandContext.message(headingToString(commandContext.theta));
}
