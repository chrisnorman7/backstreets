import 'dart:html';

import '../sound/sound.dart';
import 'book.dart';

class Scene {
  Scene(this.book, this.url, this.onfinish) {
    completed = false;
    sound = book.soundPool.getSound(url);
    sound.onEnded = done;
  }
  
  bool completed = false;
  Sound sound;
  final Book book;
  final String url;
  BookFunctionType onfinish;

  void done(Event e) {
    if (completed) {
      return;
    }
    completed = true;
    book.scene = null;
    sound.stop();
    onfinish(book);
  }
}
