import 'dart:html';

import 'quill.dart' as quill;

// ignoring leap years
const int _secondsInAYear = 31536000;
const String _prompt = 'Something happened. Make it sound puzzling and heroic.';
final List<String> _templates = [
  'We encountered what appeared to be a <insert space anomaly>. It has '
      'proven to be sentient and has taken control of our ship. Thus far, all '
      'efforts at communication have failed...',
  'A warship from the <insert hostile alien organization> has entered our '
      'territory. It is currently speeding towards Earth. Thus far, all '
      'efforts at peace have failed...',
  'The ship has been pulled into a <insert type of time distortion>. We are '
      'observing the universe in the distant <past or future>. Thus far, all '
      'efforts to return to our timeline have failed...'
];

quill.QuillStatic quillEditor;
Map<double, HtmlElement> logEntries;

main() {
  // initialization
  quillEditor = new quill.QuillStatic('#editor',
      new quill.QuillOptionsStatic(theme: 'snow', placeholder: _prompt));

  logEntries = new Map<double, HtmlElement>();
  loadPreviousEntries();

  // listeners
  document.getElementById('save').onClick.listen(saveLog);
  document.getElementById('templateSelect') as SelectElement
    ..onChange.listen(useTemplate);
}

/// Capture entry in editor, save to local storage and display in log.
void appendToLog(double stardate, HtmlElement logEntryElement) {
  logEntries[stardate] = logEntryElement;
  window.localStorage[stardate.toString()] = logEntryElement.innerHtml;
  displayLogEntry(stardate, logEntryElement);
}

/// Calculate the current stardate: <Year>.<Percentage of year completion>
double calculateStardate() {
  var now = new DateTime.now();
  var beginningOfYear = new DateTime(now.year);
  int secondsThisYear = now.difference(beginningOfYear).inSeconds;
  return now.year + secondsThisYear / _secondsInAYear;
}

/// Copy html elements from the editor view and return them inside a new
/// DivElement.
HtmlElement captureEditorView() {
  Element contentElement = document.getElementById('editor').firstChild;

  var logEntryElement = new DivElement()
    ..innerHtml = contentElement.innerHtml;

  return logEntryElement;
}

void displayLogEntry(double stardate, HtmlElement logEntryElement) {
  Element logElement = document.getElementById('log');

  if (logElement.children.isNotEmpty) {
    logElement.insertAdjacentElement('afterBegin', new HRElement());
  }

  logElement.insertAdjacentElement('afterBegin', logEntryElement);
  var stardateElement = new HeadingElement.h2()
    ..text = 'Stardate: $stardate'
    ..classes.add('stardate');
  logElement.insertAdjacentElement('afterBegin', stardateElement);
}

/// Load all log entries from browser local storage.
void loadPreviousEntries() {
  Element logElement = document.getElementById('log');
  logElement.innerHtml = window.localStorage['log'] ?? '';

  List<String> keys = window.localStorage.keys.toList();
  keys.sort();
  for (String key in keys) {
    var entryElement = new DivElement()
      ..innerHtml = window.localStorage[key];
    logEntries[double.parse(key)] = entryElement;
    displayLogEntry(double.parse(key), entryElement);
  }
}

/// Save the log entry that is currently in the editor.
void saveLog(Event _) {
  DivElement logEntryElement = captureEditorView();
  appendToLog(calculateStardate(), logEntryElement);

  // Clear the editor.
  quillEditor.deleteText(0, quillEditor.getLength());
}

/// Updates the content of the editor using the selected template.
void useTemplate(Event _) {
  SelectElement templateSelectElement =
      document.getElementById('templateSelect');
  int selectedIndex = templateSelectElement.selectedIndex;

  if (selectedIndex == 0) return;

  quillEditor.deleteText(0, quillEditor.getLength());
  String templateText = _templates[templateSelectElement.selectedIndex - 1];
  quillEditor.insertText(0, templateText, 'api');
}
