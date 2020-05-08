import 'dart:math';

class GameObject {
  num x = 0.0;
  num y = 0.0;
  num heading = 0.0;

  Point<num> get coordinates {
    return Point<num>(x, y);
  }

  set coordinates(Point<num> value) {
    x = value.x;
    y = value.y;
  }

  void forward() {
    const num forwardAmount = 0.5;
    x += forwardAmount * cos((heading * pi) / 180);
    y += forwardAmount * sin((heading * pi) / 180);
  }
}
