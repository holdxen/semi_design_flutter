// 1:1 port of vscode/src/vs/editor/common/model/mirrorTextModel.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c

import '../../../base/common/strings.dart' show splitLines;
import '../../../base/common/uri.dart' show URI;
import '../core/position.dart' show Position;
import '../core/range.dart' show IRange;
import 'prefixSumComputer.dart' show PrefixSumComputer;

/// 1:1: `export interface IModelContentChange`
abstract class IModelContentChange {
  /// The old range that got replaced.
  IRange get range;

  /// The offset of the range that got replaced.
  int get rangeOffset;

  /// The length of the range that got replaced.
  int get rangeLength;

  /// The new text for the range.
  String get text;
}

/// 1:1: `export interface IModelChangedEvent`
abstract class IModelChangedEvent {
  /// The actual changes.
  List<IModelContentChange> get changes;

  /// The (new) end-of-line character.
  String get eol;

  /// The new version id the model has transitioned to.
  int get versionId;

  /// Flag that indicates that this event was generated while undoing.
  bool get isUndoing;

  /// Flag that indicates that this event was generated while redoing.
  bool get isRedoing;
}

/// 1:1: `export interface IMirrorTextModel`
abstract class IMirrorTextModel {
  int get version;
}

/// 1:1: `export class MirrorTextModel implements IMirrorTextModel`
class MirrorTextModel implements IMirrorTextModel {
  // ignore: unused_field
  late URI _uri;
  late List<String> _lines;
  late String _eol;
  late int _versionId;
  PrefixSumComputer? _lineStarts;
  String? _cachedTextValue;

  MirrorTextModel(URI uri, List<String> lines, String eol, int versionId) {
    _uri = uri;
    _lines = lines;
    _eol = eol;
    _versionId = versionId;
    _lineStarts = null;
    _cachedTextValue = null;
  }

  /// 1:1: `dispose`
  void dispose() {
    _lines.length = 0;
  }

  @override
  int get version => _versionId;

  /// 1:1: `getText`
  String getText() {
    if (_cachedTextValue == null) {
      _cachedTextValue = _lines.join(_eol);
    }
    return _cachedTextValue!;
  }

  /// 1:1: `onEvents`
  void onEvents(IModelChangedEvent e) {
    if (e.eol.isNotEmpty && e.eol != _eol) {
      _eol = e.eol;
      _lineStarts = null;
    }

    // Update my lines
    final List<IModelContentChange> changes = e.changes;
    for (final IModelContentChange change in changes) {
      _acceptDeleteRange(change.range);
      _acceptInsertText(
          Position(change.range.startLineNumber, change.range.startColumn),
          change.text);
    }

    _versionId = e.versionId;
    _cachedTextValue = null;
  }

  /// 1:1: `_ensureLineStarts`
  // ignore: unused_element
  void _ensureLineStarts() {
    if (_lineStarts == null) {
      final int eolLength = _eol.length;
      final int linesLength = _lines.length;
      final List<int> lineStartValues = List<int>.filled(linesLength, 0);
      for (int i = 0; i < linesLength; i++) {
        lineStartValues[i] = _lines[i].length + eolLength;
      }
      _lineStarts = PrefixSumComputer(lineStartValues);
    }
  }

  /// All changes to a line's text go through this method
  ///
  /// 1:1: `_setLineText`
  void _setLineText(int lineIndex, String newValue) {
    _lines[lineIndex] = newValue;
    if (_lineStarts != null) {
      // update prefix sum
      _lineStarts!.setValue(lineIndex, _lines[lineIndex].length + _eol.length);
    }
  }

  /// 1:1: `_acceptDeleteRange`
  void _acceptDeleteRange(IRange range) {
    if (range.startLineNumber == range.endLineNumber) {
      if (range.startColumn == range.endColumn) {
        // Nothing to delete
        return;
      }
      // Delete text on the affected line
      _setLineText(
          range.startLineNumber - 1,
          _lines[range.startLineNumber - 1].substring(0, range.startColumn - 1) +
              _lines[range.startLineNumber - 1].substring(range.endColumn - 1));
      return;
    }

    // Take remaining text on last line and append it to remaining text on first line
    _setLineText(
        range.startLineNumber - 1,
        _lines[range.startLineNumber - 1].substring(0, range.startColumn - 1) +
            _lines[range.endLineNumber - 1].substring(range.endColumn - 1));

    // Delete middle lines
    _lines.removeRange(range.startLineNumber,
        range.endLineNumber); // splice(startLineNumber, endLineNumber - startLineNumber)
    if (_lineStarts != null) {
      // update prefix sum
      _lineStarts!.removeValues(
          range.startLineNumber, range.endLineNumber - range.startLineNumber);
    }
  }

  /// 1:1: `_acceptInsertText`
  void _acceptInsertText(Position position, String insertText) {
    if (insertText.isEmpty) {
      // Nothing to insert
      return;
    }
    final List<String> insertLines = splitLines(insertText);
    if (insertLines.length == 1) {
      // Inserting text on one line
      _setLineText(
          position.lineNumber - 1,
          _lines[position.lineNumber - 1].substring(0, position.column - 1) +
              insertLines[0] +
              _lines[position.lineNumber - 1].substring(position.column - 1));
      return;
    }

    // Append overflowing text from first line to the end of text to insert
    insertLines[insertLines.length - 1] +=
        _lines[position.lineNumber - 1].substring(position.column - 1);

    // Delete overflowing text from first line and insert text on first line
    _setLineText(
        position.lineNumber - 1,
        _lines[position.lineNumber - 1].substring(0, position.column - 1) +
            insertLines[0]);

    // Insert new lines & store lengths
    final List<int> newLengths = List<int>.filled(insertLines.length - 1, 0);
    for (int i = 1; i < insertLines.length; i++) {
      _lines.insert(position.lineNumber + i - 1, insertLines[i]);
      newLengths[i - 1] = insertLines[i].length + _eol.length;
    }

    if (_lineStarts != null) {
      // update prefix sum
      _lineStarts!.insertValues(position.lineNumber, newLengths);
    }
  }
}
