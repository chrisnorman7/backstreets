/// Provides the [Line] class, which acts as a menu item for [Page] instances.
library line;

import 'book.dart';
import 'page.dart';

/// A menu item.
///
/// ```
/// final Line line = Line(book, (Book b) => b.message('Testing.'), stringTitle: 'Test');
/// ```
class Line {
  /// Create a line.
  Line(
    this.book,
    this.func,
    {
      this.titleString,
      this.titleFunc,
      this.soundUrl,
    }
  );

  /// The book which this line is bound to, via a [Page] instance.
  Book book;

  /// The function which will be called when this line is in focus, and [Book.activate] is called.
  BookFunctionType func;

  /// The title of this menu item as a string.
  String titleString;

  /// A function which when called should return the title of this line. Useful in circumstances where the title might change. On a configuration page for example.
  TitleFunctionType titleFunc, soundUrl;

  /// Returns the title of this item as a string.
  ///
  /// If [titleFunc] is null, then [titleString] is returns. Otherwise, [titleFunc] is called.
  String getTitle() {
    if (titleString == null) {
      return titleFunc();
    }
    return titleString;
  }
}

/// A line that acts as a checkbox.
class CheckboxLine extends Line {
  /// Create.
  ///
  /// When activated, this line will call [setValue](![getValue]()).
  CheckboxLine(
    Book book,
    bool Function() getValue,
    void Function(Book, bool) setValue,
    {
      String titleString,
      TitleFunctionType titleFunc,
      String enableUrl = 'res/menus/enable.wav',
      String disableUrl = 'res/menus/disable.wav',
    }
  ): super(
    book,
    (Book b) {
      final bool oldValue = getValue();
      final bool newValue = !oldValue;
      final String soundUrl = newValue ? enableUrl : disableUrl;
      b.soundPool.getSound(soundUrl, output: b.soundPool.soundOutput).play();
      setValue(b, newValue);
    },
    titleString: titleString,
    titleFunc: titleFunc,
  );
}
