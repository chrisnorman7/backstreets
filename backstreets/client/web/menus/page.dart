import '../keyboard/hotkey.dart';
import '../keyboard/keyboard.dart';
import 'book.dart';
import 'line.dart';

class Page {
  Page(
    {
      this.titleString,
      this.titleFunc,
      this.lines = const <Line>[],
      this.dismissible = true,
      this.playDefaultSounds = true,
    }
  );

  Page confirmPage(
    Book book,
    BookFunctionType okFunc,
    {
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

  Page hotkeysPage(Keyboard keyboard, Book book) {
    final List<Line> lines = <Line>[];
    for (final Hotkey hk in keyboard.hotkeys) {
      lines.add(
        Line(
          book,
          (Book b) {
            b.pop();
            hk.func(hk.state);
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

  bool isLevel = false, playDefaultSounds;
  final bool dismissible;
  int focus = -1;
  final List<Line> lines;
  String titleString;
  TitleFunctionType titleFunc;
  
  String getTitle() {
    if (titleString == null) {
      return titleFunc();
    }
    return titleString;
  }

  Line getLine() {
    if (focus == -1) {
      return null;
    }
    return lines[focus];
  }
}
