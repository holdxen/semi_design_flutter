// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/textChange.ts
// Translated 1:1 from TypeScript. Uses buffer.dart read/write helpers and
// decodeUTF16LE from stringBuilder.dart.
// ---------------------------------------------------------------------------

import 'dart:typed_data';

import '../../../base/common/buffer.dart';
import 'stringBuilder.dart';

String _escapeNewLine(String str) =>
    str.replaceAll('\n', r'\n').replaceAll('\r', r'\r');

/// 1:1: `export class TextChange`
class TextChange {
  final int oldPosition;
  final String oldText;
  final int newPosition;
  final String newText;

  int get oldLength => oldText.length;
  int get oldEnd => oldPosition + oldText.length;
  int get newLength => newText.length;
  int get newEnd => newPosition + newText.length;

  TextChange(this.oldPosition, this.oldText, this.newPosition, this.newText);

  @override
  String toString() {
    if (oldText.isEmpty) {
      return '(insert@$oldPosition "${_escapeNewLine(newText)}")';
    }
    if (newText.isEmpty) {
      return '(delete@$oldPosition "${_escapeNewLine(oldText)}")';
    }
    return '(replace@$oldPosition "${_escapeNewLine(oldText)}" with "${_escapeNewLine(newText)}")';
  }

  static int _writeStringSize(String str) => 4 + 2 * str.length;

  static int _writeString(Uint8List b, String str, int offset) {
    final int len = str.length;
    writeUInt32BE_(b, len, offset);
    offset += 4;
    for (int i = 0; i < len; i++) {
      writeUInt16LE(b, str.codeUnitAt(i), offset);
      offset += 2;
    }
    return offset;
  }

  static String _readString(Uint8List b, int offset) {
    final int len = readUInt32BE_(b, offset);
    offset += 4;
    return decodeUTF16LE(b, offset, len);
  }

  /// 1:1: `writeSize()`
  int writeSize() => 4 + 4 + _writeStringSize(oldText) + _writeStringSize(newText);

  /// 1:1: `write(b, offset)`
  int write(Uint8List b, int offset) {
    writeUInt32BE_(b, oldPosition, offset);
    offset += 4;
    writeUInt32BE_(b, newPosition, offset);
    offset += 4;
    offset = _writeString(b, oldText, offset);
    offset = _writeString(b, newText, offset);
    return offset;
  }

  /// 1:1: `static read(b, offset, dest)`
  static int read(Uint8List b, int offset, List<TextChange> dest) {
    final int oldPosition = readUInt32BE_(b, offset);
    offset += 4;
    final int newPosition = readUInt32BE_(b, offset);
    offset += 4;
    final String oldText = _readString(b, offset);
    offset += _writeStringSize(oldText);
    final String newText = _readString(b, offset);
    offset += _writeStringSize(newText);
    dest.add(TextChange(oldPosition, oldText, newPosition, newText));
    return offset;
  }
}

/// 1:1: `compressConsecutiveTextChanges`
List<TextChange> compressConsecutiveTextChanges(
    List<TextChange>? prevEdits, List<TextChange> currEdits) {
  if (prevEdits == null || prevEdits.isEmpty) {
    return currEdits;
  }
  return TextChangeCompressor(prevEdits, currEdits).compress();
}

/// 1:1: `class TextChangeCompressor`
class TextChangeCompressor {
  final List<TextChange> _prevEdits;
  final List<TextChange> _currEdits;

  /// Source uses a JS sparse array with `_result[_resultLen++] = x`; Dart uses
  /// a growable list with add (writes are strictly sequential).
  final List<TextChange> _result = <TextChange>[];

  late final int _prevLen;
  int _prevDeltaOffset = 0;

  late final int _currLen;
  int _currDeltaOffset = 0;

  TextChangeCompressor(this._prevEdits, this._currEdits)
      : _prevLen = _prevEdits.length,
        _currLen = _currEdits.length;

  /// 1:1: `compress()`
  List<TextChange> compress() {
    int prevIndex = 0;
    int currIndex = 0;

    TextChange? prevEdit = _getPrev(prevIndex);
    TextChange? currEdit = _getCurr(currIndex);

    while (prevIndex < _prevLen || currIndex < _currLen) {
      if (prevEdit == null) {
        _acceptCurr(currEdit!);
        currEdit = _getCurr(++currIndex);
        continue;
      }
      if (currEdit == null) {
        _acceptPrev(prevEdit);
        prevEdit = _getPrev(++prevIndex);
        continue;
      }
      if (currEdit.oldEnd <= prevEdit.newPosition) {
        _acceptCurr(currEdit);
        currEdit = _getCurr(++currIndex);
        continue;
      }
      if (prevEdit.newEnd <= currEdit.oldPosition) {
        _acceptPrev(prevEdit);
        prevEdit = _getPrev(++prevIndex);
        continue;
      }
      if (currEdit.oldPosition < prevEdit.newPosition) {
        final List<TextChange> parts = _splitCurr(
            currEdit, prevEdit.newPosition - currEdit.oldPosition);
        _acceptCurr(parts[0]);
        currEdit = parts[1];
        continue;
      }
      if (prevEdit.newPosition < currEdit.oldPosition) {
        final List<TextChange> parts = _splitPrev(
            prevEdit, currEdit.oldPosition - prevEdit.newPosition);
        _acceptPrev(parts[0]);
        prevEdit = parts[1];
        continue;
      }

      // At this point, currEdit.oldPosition === prevEdit.newPosition
      late TextChange mergePrev;
      late TextChange mergeCurr;

      if (currEdit.oldEnd == prevEdit.newEnd) {
        mergePrev = prevEdit;
        mergeCurr = currEdit;
        prevEdit = _getPrev(++prevIndex);
        currEdit = _getCurr(++currIndex);
      } else if (currEdit.oldEnd < prevEdit.newEnd) {
        final List<TextChange> parts = _splitPrev(prevEdit, currEdit.oldLength);
        mergePrev = parts[0];
        mergeCurr = currEdit;
        prevEdit = parts[1];
        currEdit = _getCurr(++currIndex);
      } else {
        final List<TextChange> parts = _splitCurr(currEdit, prevEdit.newLength);
        mergePrev = prevEdit;
        mergeCurr = parts[0];
        prevEdit = _getPrev(++prevIndex);
        currEdit = parts[1];
      }

      _result.add(TextChange(
        mergePrev.oldPosition,
        mergePrev.oldText,
        mergeCurr.newPosition,
        mergeCurr.newText,
      ));
      _prevDeltaOffset += mergePrev.newLength - mergePrev.oldLength;
      _currDeltaOffset += mergeCurr.newLength - mergeCurr.oldLength;
    }

    final List<TextChange> merged = _merge(_result);
    return _removeNoOps(merged);
  }

  void _acceptCurr(TextChange currEdit) {
    _result.add(_rebaseCurr(_prevDeltaOffset, currEdit));
    _currDeltaOffset += currEdit.newLength - currEdit.oldLength;
  }

  TextChange? _getCurr(int currIndex) =>
      currIndex < _currLen ? _currEdits[currIndex] : null;

  void _acceptPrev(TextChange prevEdit) {
    _result.add(_rebasePrev(_currDeltaOffset, prevEdit));
    _prevDeltaOffset += prevEdit.newLength - prevEdit.oldLength;
  }

  TextChange? _getPrev(int prevIndex) =>
      prevIndex < _prevLen ? _prevEdits[prevIndex] : null;

  static TextChange _rebaseCurr(int prevDeltaOffset, TextChange currEdit) =>
      TextChange(currEdit.oldPosition - prevDeltaOffset, currEdit.oldText,
          currEdit.newPosition, currEdit.newText);

  static TextChange _rebasePrev(int currDeltaOffset, TextChange prevEdit) =>
      TextChange(prevEdit.oldPosition, prevEdit.oldText,
          prevEdit.newPosition + currDeltaOffset, prevEdit.newText);

  static List<TextChange> _splitPrev(TextChange edit, int offset) {
    final String preText = edit.newText.substring(0, offset);
    final String postText = edit.newText.substring(offset);
    return <TextChange>[
      TextChange(edit.oldPosition, edit.oldText, edit.newPosition, preText),
      TextChange(edit.oldEnd, '', edit.newPosition + offset, postText),
    ];
  }

  static List<TextChange> _splitCurr(TextChange edit, int offset) {
    final String preText = edit.oldText.substring(0, offset);
    final String postText = edit.oldText.substring(offset);
    return <TextChange>[
      TextChange(edit.oldPosition, preText, edit.newPosition, edit.newText),
      TextChange(edit.oldPosition + offset, postText, edit.oldEnd, ''),
    ];
  }

  static List<TextChange> _merge(List<TextChange> edits) {
    if (edits.isEmpty) {
      return edits;
    }
    final List<TextChange> result = <TextChange>[];
    TextChange prev = edits[0];
    for (int i = 1; i < edits.length; i++) {
      final TextChange curr = edits[i];
      if (prev.oldEnd == curr.oldPosition) {
        prev = TextChange(prev.oldPosition, prev.oldText + curr.oldText,
            prev.newPosition, prev.newText + curr.newText);
      } else {
        result.add(prev);
        prev = curr;
      }
    }
    result.add(prev);
    return result;
  }

  static List<TextChange> _removeNoOps(List<TextChange> edits) {
    if (edits.isEmpty) {
      return edits;
    }
    final List<TextChange> result = <TextChange>[];
    for (int i = 0; i < edits.length; i++) {
      final TextChange edit = edits[i];
      if (edit.oldText == edit.newText) {
        continue;
      }
      result.add(edit);
    }
    return result;
  }
}
