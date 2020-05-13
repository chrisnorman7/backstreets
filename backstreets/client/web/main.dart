import 'dart:html';

void main() {
  final Element startDiv = document.querySelector('#startDiv');
  final Element startButton = document.querySelector('#startButton');
  final Element mainDiv = document.querySelector('#main');
  startDiv.hidden = false;
  startButton.onclick.listen((Event) {
    startDiv.hidden = true;
    mainDiv.hidden = false;
  });
}
