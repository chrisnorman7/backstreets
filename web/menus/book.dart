import '../sound/sound.dart';
import '../util.dart';
import 'line.dart';
import 'page.dart';
import 'scene.dart';

typedef TitleFunctionType = String Function();
typedef BookFunctionType = void Function(Book);

class Book{
  Book(this.soundPool);

  SoundPool soundPool;
  String searchString, searchSuccessUrl, searchFailUrl;
  int lastSearchTime, searchTimeout;
  Scene scene;
  List<Page> pages = <Page>[];
  void Function(String) message;
  String moveSoundUrl, activateSoundUrl;
  Sound moveSound, activateSound, searchSuccessSound, searchFailSound;

  void push(Page page) {
    lastSearchTime = 0;
    pages.add(page);
    showFocus();
  }

  Page pop() {
    final Page oldPage = pages.removeLast(); // Remove the last page from the list.
    if (pages.isNotEmpty) {
      final Page page = pages.removeLast(); // Pop the next one too, so we can push it again.
      push(page);
    }
    return oldPage;
  }

  Page getPage() {
    if (pages.isNotEmpty) {
      return pages[pages.length - 1];
    }
    return null;
  }

  int getFocus() {
    final Page page = getPage();
    if (page == null) {
      return null;
    }
    return page.focus;
  }

  void showFocus() {
    final Page page = getPage();
    if (page == null) {
      throw 'First push a page.';
    } else if (page.focus == -1) {
      message(page.getTitle());
    } else if (!page.isLevel) {
      final Line line = page.getLine();
      String url;
      if (line.soundUrl != null) {
        url = line.soundUrl();
      } else if (page.playDefaultSounds) {
        url = moveSoundUrl;
      }
      moveSound.stop();
      if (url != null) {
        moveSound = soundPool.playSound(url, output: soundPool.output);
      }
      message(line.getTitle());
    }
  }

  void moveUp() {
    final Page page = getPage();
    if (page == null) {
      return; // There"s probably no pages.
    }
    final int focus = getFocus();
    if (focus == -1) {
      return; // Do nothing.
    }
    page.focus --;
    showFocus();
  }

  void moveDown() {
    final Page page = getPage();
    if (page == null) {
      return; // There"s no pages.
    }
    final int focus = getFocus();
    if (focus == (page.lines.length - 1)) {
      return; // Can't move down any further.
    }
    page.focus++;
    showFocus();
  }

  void activate() {
    final Page page = getPage();
    if (page == null) {
      return; // Can"t do anything with no page.
    }
    final Line line = page.getLine();
    if (line == null) {
      return; // They are probably looking at the title.
    }
    activateSound = soundPool.playSound(activateSoundUrl);
    line.func(this);
  }

  void cancel() {
    final Page page = getPage();
    if (page == null || !page.dismissible) {
      return; // No page, or the page can"t be dismissed that easily.
    }
    pop();
  }

  void handleSearch(String term) {
    final Page page = getPage();
    if (page == null || page.isLevel) {
      return; // Don't search in levels or when there is no page.
    }
    final int now = timestamp();
    if ((now - lastSearchTime) >= searchTimeout) {
      searchString = '';
    }
    lastSearchTime = now;
    searchString += term.toLowerCase();
    final int index = page.lines.indexWhere(
      (Line entry) => entry.getTitle().toLowerCase().startsWith(searchString)
    );
    if (index == -1) {
      searchSuccessSound.stop();
      searchFailSound = soundPool.playSound(searchFailUrl);
    } else {
      searchFailSound.stop();
      searchSuccessSound = soundPool.getSound(searchSuccessUrl);
      page.focus = index;
      showFocus();
    }
  }

  Scene playScene(
    String url,
    BookFunctionType onFinish,
  ) {
    scene = Scene(this, url, onFinish);
    scene.sound.play();
    return scene;
  }
}
