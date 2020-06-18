// Various utility functions.
library util;

import 'dart:math';

/// The random number generator.
final Random random = Random();

/// Returned by [divmod].
class DivmodResult {
  DivmodResult(this.quotient, this.remainder);

  /// The quotient.
  num quotient;

  /// The remainder.
  num remainder;
}

/// Return a random element from a list.
///
///
/// This function doesn't check for an empty list.
T randomElement<T>(List<T> items) {
  return items[random.nextInt(items.length)];
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

/// Convert a list of items to a properly formatted english list.
String englishList(List<String> items, {String andString = ', and ', String sepString = ', ', String emptyString = 'nothing'}) {
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

/// Return [single] if [number] is 1, otherwise [plural].
String pluralise(int number, String single, [String plural]) {
  plural ??= single + 's';
  return number == 1 ? single : plural;
}

/// Like Python's divmod function.
DivmodResult divmod(num x, num y) {
  final num remainder = x % y;
  return DivmodResult(x / y, remainder);
}

/// Format [duration] with [englishList].
String formatDuration(Duration duration, {String suffix = '', String noTime = 'No time at all'}) {
  final List<String> details = <String>[];
  int remaining = duration.inSeconds;
  DivmodResult dr = divmod(remaining, 24 * 3600);
  final int days = dr.quotient.floor();
  remaining = dr.remainder.floor();
  if (days > 0) {
    details.add('$days ${pluralise(days, "day")}');
  }
  dr = divmod(remaining, 3600);
  final int hours = dr.quotient.floor();
  remaining = dr.remainder.floor();
  if (hours > 0) {
    details.add('$hours ${pluralise(hours, "hour")}');
  }
  dr = divmod(remaining, 60);
  final int minutes = dr.quotient.floor();
  remaining = dr.remainder.floor();
  if (minutes > 0) {
    details.add('$minutes ${pluralise(minutes, "minute")}');
  }
  if (remaining > 0) {
    details.add('$remaining ${pluralise(remaining, "second")}');
  }
  if (details.isEmpty) {
    return noTime;
  } else {
    return englishList(details) + suffix;
  }
}
