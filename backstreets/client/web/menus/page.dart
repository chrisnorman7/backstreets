/// Provides the [Page] class, which holds a list of [Line] instances.
library page;

import '../keyboard/hotkey.dart';
import '../keyboard/keyboard.dart';

import '../main.dart';

import '../util.dart';

import 'book.dart';
import 'line.dart';

/// A page of [Line] instances.
class Page {
  /// Create a page.
  ///
  /// if [dismissible] is true, then [Book.cancel] will dismiss it without any fuss.
  Page(
    {
      this.titleString,
      this.titleFunc,
      this.lines = const <Line>[],
      this.dismissible = true,
      this.playDefaultSounds = true,
    }
  );

  /// Create a page that can be used for confirmations.
  static Page confirmPage(
    Book book, BookFunctionType okFunc, {
      String title = 'Are you sure?',
      String okTitle = 'OK',
      String cancelTitle = 'Cancel',
      BookFunctionType cancelFunc,
    }
  ) {
    final List<Line> lines = <Line>[
      Line(
        book,
        okFunc,
        titleString: okTitle,
      ),
      Line(
        book,
        cancelFunc ?? (Book b) => b.pop(),
        titleString: cancelTitle,
      )
    ];
    return Page(
      titleString: title,
      lines: lines
    );
  }

  /// Creates a page which lists all [Hotkey] instances, bound to a [Keyboard] instance.
  static Page hotkeysPage(Keyboard keyboard, Book book) {
    final List<Line> lines = <Line>[];
    for (final Hotkey hk in keyboard.hotkeys) {
      lines.add(
        Line(
          book,
          (Book b) {
            b.pop();
            hk.func();
          },
          titleFunc: () => '${hk.state}: ${hk.getTitle()}',
        )
      );
    }
    return Page(
      titleString: 'Hotkeys',
      lines: lines,
    );
  }

  /// Create a page for selecting a tile name.
  static Page selectTilePage(
    Book book, String Function() getTileName, void Function(String) setTileName, {String title = 'Tiles'}
  ) {
    final List<Line> lines = <Line>[];
    for (final String name in commandContext.tileNames) {
      lines.add(
        Line(
          book, (Book b) => setTileName(name),
          titleString: '${name == getTileName() ? "* " : ""}$name',
          soundUrl: () => getFootstepSound(name)
        )
      );
    }
    return Page(playDefaultSounds: false, titleString: title, lines: lines);
  }

  /// If true, then any [Line] instances contained by this page will not be silent, even if their [Line.soundUrl] attributes are null.
  bool playDefaultSounds;

  /// If true, then [Book.cancel] will dismiss this page.
  final bool dismissible;

  /// The current position in this page's list of [Line] instances.
  int focus = -1;

  /// The lines contained by this page.
  final List<Line> lines;

  /// The title of this page as a string.
  String titleString;

  /// A function which when called, will return the title of this page.
  TitleFunctionType titleFunc;

  /// Get the title of this page as a string. If [titleString] is null, then [titleFunc] will be called. Otherwise, [titleString] will be returned.
  String getTitle() {
    if (titleString == null) {
      return titleFunc();
    }
    return titleString;
  }

  /// Get the currently focussed line.
  Line getLine() {
    if (focus == -1) {
      return null;
    }
    return lines[focus];
  }
}
