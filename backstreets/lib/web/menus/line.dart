import 'book.dart';

class Line {
  Line(
    this.book,
    this.func,
    {
      this.titleString,
      this.titleFunc,
      this.soundUrl,
    }
  );
  
  Book book;
  BookFunctionType func;
  String titleString;
  TitleFunctionType titleFunc, soundUrl;

  String getTitle() {
    if (titleString == null) {
      return titleFunc();
    }
    return titleString;
  }
}

class CheckboxLine extends Line {
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
