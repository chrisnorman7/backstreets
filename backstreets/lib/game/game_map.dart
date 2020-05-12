import 'dart:math';

import 'sound.dart';
import 'tile.dart';

class GameMap {
  GameMap.fromSize({int x, int y, Tile tile}) {
    for (int i = 0; i < x; i++) {
      for (int j = 0; j < y; j++) {
        addTile(Point<int>(i, j), tile);
      }
    }
  }

  Map<Point<int>, Tile> tiles = <Point<int>, Tile>{};
  Sound convolver = Sound();

  void addTile(Point<int> coordinates, Tile tile) {
    tiles[coordinates] = tile;
  }

  void removeTile(Point<num> coordinates) {
    tiles.remove(coordinates);
  }
}
