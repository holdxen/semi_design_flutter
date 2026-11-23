// 1:1 translation of vscode/src/vs/base/common/jsonEdit.ts
// Adaptations (documented inline):
//   - Reuses Edit/FormattingOptions/format/isEOL from jsonFormatter.dart and
//     Node/JSONPath/Segment/parseTree/findNodeAtLocation/SyntaxKind from json.dart.
//   - `JSON.stringify(value)` → a small helper mirroring JS stringify semantics
//     (int doubles without ".0", key order preserved by dart:convert).
//   - Dart switch-on-value avoided (uses String comparison for node.type).
//   - `value: unknown` → Object?; `getInsertionIndex?: (properties: string[]) => number`
//     → `int Function(List<String>)?`.

import 'dart:convert';

import 'json.dart'
    show
        JSONPath,
        Node,
        NodeType,
        ParseError,
        Segment,
        SyntaxKind,
        createScanner,
        findNodeAtLocation,
        parseTree;
import 'jsonFormatter.dart'
    show Edit, FormatRange, FormattingOptions, format, isEOL;

/// JS `JSON.stringify` for the values this module emits (objects/arrays/scalars).
/// dart:convert preserves insertion order for maps; the only divergence is JS
/// number formatting (integer-valued doubles drop ".0"), handled by [jsNumber].
String _stringify(Object? value) {
  if (value is double && value == value.roundToDouble() && value.abs() < 1e21) {
    // Encode integer-valued doubles as integers so JSON output has no ".0".
    return jsonEncode(value.toInt());
  }
  return jsonEncode(value);
}

String jsNumber(Object? value) => _stringify(value);

/// 1:1: `removeProperty(text, path, formattingOptions)`
List<Edit> removeProperty(String text, JSONPath path, FormattingOptions formattingOptions) =>
    setProperty(text, path, null, formattingOptions);

/// 1:1: `setProperty(text, originalPath, value, formattingOptions, getInsertionIndex?)`
List<Edit> setProperty(
  String text,
  JSONPath originalPath,
  Object? value,
  FormattingOptions formattingOptions, [
  int Function(List<String>)? getInsertionIndex,
]) {
  final JSONPath path = List<Object>.from(originalPath);
  final List<ParseError> errors = <ParseError>[];
  final Node? root = parseTree(text, errors);
  Node? parent;

  Segment? lastSegment;
  while (path.isNotEmpty) {
    lastSegment = path.removeLast();
    parent = findNodeAtLocation(root, path);
    if (parent == null && value != null) {
      if (lastSegment is String) {
        value = <String, Object?>{lastSegment: value};
      } else {
        value = <Object?>[value];
      }
    } else {
      break;
    }
  }

  if (parent == null) {
    // empty document
    if (value == null) {
      // delete — property does not exist, nothing to do
      return <Edit>[];
    }
    return withFormatting(
        text,
        Edit(root != null ? root.offset : 0, root != null ? root.length : 0,
            _stringify(value)),
        formattingOptions);
  } else if (parent.type == NodeType.object &&
      lastSegment is String &&
      parent.children != null) {
    final Node? existing = findNodeAtLocation(parent, <Object>[lastSegment]);
    if (existing != null) {
      if (value == null) {
        // delete
        final Node? existingParent = existing.parent;
        if (existingParent == null) {
          throw StateError('Malformed AST');
        }
        final int propertyIndex = parent.children!.indexOf(existingParent);
        late final int removeBegin;
        int removeEnd = existingParent.offset + existingParent.length;
        if (propertyIndex > 0) {
          // remove the comma of the previous node
          final Node previous = parent.children![propertyIndex - 1];
          removeBegin = previous.offset + previous.length;
        } else {
          removeBegin = parent.offset + 1;
          if (parent.children!.length > 1) {
            // remove the comma of the next node
            final Node next = parent.children![1];
            removeEnd = next.offset;
          } else {
            // remove the trailing comma of the only node
            final scanner = createScanner(text, true);
            scanner.setPosition(removeEnd);
            if (scanner.scan() == SyntaxKind.commaToken) {
              removeEnd = scanner.getPosition();
            }
          }
        }
        return withFormatting(
            text, Edit(removeBegin, removeEnd - removeBegin, ''), formattingOptions);
      } else {
        // set value of existing property
        return withFormatting(
            text,
            Edit(existing.offset, existing.length, _stringify(value)),
            formattingOptions);
      }
    } else {
      if (value == null) {
        // delete — property does not exist, nothing to do
        return <Edit>[];
      }
      final String newProperty =
          '${_stringify(lastSegment)}: ${_stringify(value)}';
      final int index = getInsertionIndex != null
          ? getInsertionIndex(parent.children!
              .map((Node p) => p.children![0].value as String)
              .toList())
          : parent.children!.length;
      late final Edit edit;
      if (index > 0) {
        final Node previous = parent.children![index - 1];
        edit = Edit(previous.offset + previous.length, 0, ',$newProperty');
      } else if (parent.children!.isEmpty) {
        edit = Edit(parent.offset + 1, 0, newProperty);
      } else {
        edit = Edit(parent.offset + 1, 0, '$newProperty,');
      }
      return withFormatting(text, edit, formattingOptions);
    }
  } else if (parent.type == NodeType.array &&
      lastSegment is int &&
      parent.children != null) {
    if (value != null) {
      // Insert
      final String newProperty = _stringify(value);
      late final Edit edit;
      if (parent.children!.isEmpty || lastSegment == 0) {
        edit = Edit(parent.offset + 1, 0,
            parent.children!.isEmpty ? newProperty : '$newProperty,');
      } else {
        final int index = lastSegment == -1 || lastSegment > parent.children!.length
            ? parent.children!.length
            : lastSegment;
        final Node previous = parent.children![index - 1];
        edit = Edit(previous.offset + previous.length, 0, ',$newProperty');
      }
      return withFormatting(text, edit, formattingOptions);
    } else {
      // Removal
      final int removalIndex = lastSegment;
      final Node toRemove = parent.children![removalIndex];
      late final Edit edit;
      if (parent.children!.length == 1) {
        // only item
        edit = Edit(parent.offset + 1, parent.length - 2, '');
      } else if (parent.children!.length - 1 == removalIndex) {
        // last item
        final Node previous = parent.children![removalIndex - 1];
        final int offset = previous.offset + previous.length;
        final int parentEndOffset = parent.offset + parent.length;
        edit = Edit(offset, parentEndOffset - 1 - offset, '');
      } else {
        edit = Edit(
            toRemove.offset,
            parent.children![removalIndex + 1].offset - toRemove.offset,
            '');
      }
      return withFormatting(text, edit, formattingOptions);
    }
  } else {
    throw StateError(
        'Can not add ${lastSegment is int ? 'index' : 'property'} to parent of type ${parent.type}');
  }
}

/// 1:1: `withFormatting(text, edit, formattingOptions)`
List<Edit> withFormatting(String text, Edit edit, FormattingOptions formattingOptions) {
  // apply the edit
  String newText = applyEdit(text, edit);

  // format the new text
  int begin = edit.offset;
  int end = edit.offset + edit.content.length;
  if (edit.length == 0 || edit.content.isEmpty) {
    // insert or remove
    while (begin > 0 && !isEOL(newText, begin - 1)) {
      begin--;
    }
    while (end < newText.length && !isEOL(newText, end)) {
      end++;
    }
  }

  final List<Edit> edits = format(
      newText, FormatRange(begin, end - begin), formattingOptions);

  // apply the formatting edits and track the begin and end offsets of the changes
  for (int i = edits.length - 1; i >= 0; i--) {
    final Edit curr = edits[i];
    newText = applyEdit(newText, curr);
    begin = begin < curr.offset ? begin : curr.offset;
    end = end > curr.offset + curr.length ? end : curr.offset + curr.length;
    end += curr.content.length - curr.length;
  }
  // create a single edit with all changes
  final int editLength = text.length - (newText.length - end) - begin;
  final int clampedEnd = end > newText.length ? newText.length : end;
  return [
    Edit(begin, editLength, newText.substring(begin, clampedEnd))
  ];
}

/// 1:1: `applyEdit(text, edit)`
String applyEdit(String text, Edit edit) =>
    text.substring(0, edit.offset) + edit.content + text.substring(edit.offset + edit.length);

/// 1:1: `applyEdits(text, edits)`
String applyEdits(String text, List<Edit> edits) {
  final List<Edit> sortedEdits = List<Edit>.from(edits)
    ..sort((Edit a, Edit b) {
      final int diff = a.offset - b.offset;
      if (diff == 0) {
        return a.length - b.length;
      }
      return diff;
    });
  int lastModifiedOffset = text.length;
  for (int i = sortedEdits.length - 1; i >= 0; i--) {
    final Edit e = sortedEdits[i];
    if (e.offset + e.length <= lastModifiedOffset) {
      text = applyEdit(text, e);
    } else {
      throw StateError('Overlapping edit');
    }
    lastModifiedOffset = e.offset;
  }
  return text;
}
