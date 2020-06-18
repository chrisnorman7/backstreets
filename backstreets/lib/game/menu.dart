/// Provides the [Menu], and [MenuItem] classes.
library menu;

/// Holds a list of [MenuItem] instances to send to a client.
class Menu {
  Menu(this.title);

  /// The title of this menu.
  final String title;

  /// The items in this menu.
  final List<MenuItem> items = <MenuItem>[];

  /// Convert this object to a Map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'items': <Map<String, dynamic>>[for (final MenuItem item in items) item.toJson()],
    };
  }
}

/// An item in a [Menu].
class MenuItem {
  MenuItem(this.title, this.command, this.args);

  /// The title of this item.
  final String title;

  /// The command which will be called when the item is selected by the client.
  final String command;

  /// The arguments which will be sent with [command].
  final List<dynamic> args;

  /// Convert this menu item to a Map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'command': command,
      'args': args,
    };
  }
}
