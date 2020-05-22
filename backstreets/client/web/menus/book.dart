/// Provides the [Book] class, which can be used for making menus.
library book;

import 'package:path/path.dart' as path;

import '../main.dart';

import '../sound/sound_pool.dart';
import '../util.dart';
import 'line.dart';
import 'page.dart';

/// The directory where menu sounds are stored.
const String menuSoundsDirectory = 'sounds/menus';

/// The type for all titleFunc arguments.
typedef TitleFunctionType = String Function();

/// The type for all functions which are called with [Book] as their first argument.
typedef BookFunctionType = void Function(Book);

/// A book, which acts like a menu.
///
/// Books contain [Page]s, which can be [Book.push]ed.
///
///You can traverse through the menu with [Book.moveUp], [Book.moveDown].
///
/// You can return to the previous [Page] with [Book.cancel], which uses [Book.pop] to "pop" the most recently added [Page].
/// You can activate items with [Book.activate].
class Book{
  /// Give it the ability to make sounds, and the ability to send messages.
  Book(this.soundPool, this.message, {this.onCancel}) {
    searchFailSound = soundPool.getSound(searchFailSoundUrl);
    searchSuccessSound = soundPool.getSound(searchSuccessSoundUrl);
    moveSound = soundPool.getSound(moveSoundUrl);
    noCancelSound = soundPool.getSound(noCancelSoundUrl);
    activateSound = soundPool.getSound(activateSoundUrl);
  }

  /// An interface for playing sounds.
  SoundPool soundPool;

  /// The function to use for showing text.
  final void Function(String) message;

  /// The function to call when [cancel] is called.
  void Function() onCancel;

  /// The most recent search string.
  String searchString;

  /// The URL sound to play when a search matches a result.
  String searchSuccessSoundUrl = path.join(menuSoundsDirectory, 'searchsuccess.wav');

  /// The sound associated with [searchSuccessUrl];
  Sound searchSuccessSound;

  /// The sound to play when a search matches nothing.
  String searchFailSoundUrl = path.join(menuSoundsDirectory, 'searchfail.wav');

  /// The sound associated with [searchFailUrl].
  Sound searchFailSound;

  /// The url of the sound to play when moving through the menu.
  String moveSoundUrl = path.join(menuSoundsDirectory, 'move.wav');

  /// The sound associated with [moveSoundUrl].
  Sound moveSound;

  /// The url of the sound to play when using [cancel].
  String noCancelSoundUrl = path.join(menuSoundsDirectory, 'nocancel.wav');

  /// The sound associated with [noCancelSoundUrl];
  Sound noCancelSound;

  /// The url of the sound to play when using [activate] on a menu item.
  String activateSoundUrl = path.join(menuSoundsDirectory, 'activate.wav');

  // The sound associated with [activateSoundUrl].
  Sound activateSound;

  /// The last time a search was performed.
  int lastSearchTime;

  /// The timeout (in milliseconds) for searches.
  int searchTimeout = 500;

  /// The pages contained by this book.
  ///
  /// Using [push] to add another page will increase the stack depth, while using [pop] will decrease it.
  List<Page> pages = <Page>[];

  /// Push a [Page] instance.
  ///
  /// This creates a new menu, as menu items are really [Line] instances contained by a [Page] instance.
  void push(Page page) {
    lastSearchTime = 0;
    pages.add(page);
    showFocus();
  }

  /// Pop a [Page] instance from the end of the stack.
  ///
  /// This returns focus to the previous menu.
  Page pop() {
    final Page oldPage = pages.removeLast(); // Remove the last page from the list.
    if (pages.isNotEmpty) {
      final Page page = pages.removeLast(); // Pop the next one too, so we can push it again.
      push(page);
    }
    return oldPage;
  }

  /// Get the current page. If there are no pages, then [null] is returned.
  Page getPage() {
    if (pages.isNotEmpty) {
      return pages[pages.length - 1];
    }
    return null;
  }

  /// Get the current focus as an integer. If no page is focussed ([getPage] returns null), then null is returned.
  ///
  /// ```
  /// book.pages[book.getFocus()] == book.getPage();
  /// ```
  int getFocus() {
    final Page page = getPage();
    if (page == null) {
      return null;
    }
    return page.focus;
  }

  /// Using [message], print the title of the currently active [Page].
  ///
  /// If no page is is currently focussed ([getPage] returns null), then an error is thrown.
  void showFocus() {
    final Page page = getPage();
    if (page == null) {
      throw 'First push a page.';
    } else if (page.focus == -1) {
      message(page.getTitle());
    } else {
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

  /// Move upwards through the current [Page]'s list of [Line] instances.
  ///
  /// Should probably be triggered by arrow keys or some such.
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

  /// Move downwards through the current [Page]'s list of [Line] instances.
  ///
  /// Should probably be triggered by arrow keys or some such.
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

  /// Call [Line.func] on the currently focussed [Line] instance of the currently active [Page] instance.
  ///
  /// Should probably be triggered by the enter key or space.
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

  /// Cancel and remove the currently active [Page] instance, and pop it from the stack.
  ///
  /// Should probably be triggered by left arrow, or some sort of back button.
  void cancel() {
    final Page page = getPage();
    if (page == null) {
      return;
    } else if (!page.dismissible) {
      noCancelSound.stop();
      noCancelSound = soundPool.playSound(noCancelSoundUrl);
    } else {
      pop();
      if (onCancel != null) {
        onCancel();
      }
    }
  }

  /// Handle a search string.
  ///
  /// This method adds [term] to [searchString], and performs the search.
  ///
  /// If the last search was performed too long ago (according to [lastSearchTime], then [searchString] will be reset to an empty string first.
  ///
  /// Should probably be triggered by letter keys with no modifiers, or some kind of alternate keyboard.
  void handleSearch(String term) {
    final Page page = getPage();
    if (page == null) {
      return; // Don't search when there is no page.
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
      searchFailSound = soundPool.playSound(searchFailSoundUrl);
    } else {
      searchFailSound.stop();
      searchSuccessSound = soundPool.getSound(searchSuccessSoundUrl);
      page.focus = index;
      showFocus();
    }
  }
}

void clearBook() => commandContext.book = null;
