import 'dart:math';

import 'tile.dart';

class GameMap {
  Map<Point<num>, Tile> tiles = <Point<num>, Tile>{};

  void addTile(Point<num> coordinates, Tile tile) {
    tiles[coordinates] = tile;
  }

  void removeTile(Point<num> coordinates) {
    tiles.remove(coordinates);
  }
}
