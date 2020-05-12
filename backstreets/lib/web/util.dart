import 'dart:math';

final Random random = Random();

String headingToString(num angle) {
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

int randint(
  int end,
  {
    int start = 0,
  }
) {
  return random.nextInt(end) + start;
}

int timestamp() {
  return DateTime.now().millisecondsSinceEpoch;
}
