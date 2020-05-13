/// Provides the [main] function.
library main;

import 'dart:html';

/// Set the document title. [state] will be shown in square brackets.
void setTitle({String state}) {
  document.title = 'Backstreets';
  if (state != null) {
    document.title += ' [$state]';
  }
}

/// The keyboard area. This is a paragraph element that can be focussed.
final Element keyboardArea = querySelector('#keyboard');

/// Main entry point.
void main() {
  setTitle();
  final Element startDiv = querySelector('#startDiv');
  final Element startButton = querySelector('#startButton');
  final Element mainDiv = querySelector('#main');
  startDiv.hidden = false;
  startButton.onClick.listen((Event event) {
    startDiv.hidden = true;
    mainDiv.hidden = false;
    final WebSocket socket = WebSocket('ws://${window.location.hostname}:8888/ws');
    setTitle(state: 'Connecting');
    socket.onOpen.listen((Event e) => setTitle(state: 'Connected'));
    socket.onClose.listen((Event e) {
      setTitle(state: 'Disconnected');
      mainDiv.hidden = true;
      startDiv.hidden = false;
    });
    socket.onMessage.listen((MessageEvent e) {
      mainDiv.innerText = e.data as String;
    });
  });
}
