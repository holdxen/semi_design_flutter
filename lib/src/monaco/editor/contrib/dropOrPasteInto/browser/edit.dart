// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/dropOrPasteInto/browser/edit.ts
// Translated 1:1. Carrier interfaces stand in for ResourceTextEdit, document
// edits and workspace edits (some of their source files are not ported yet).
// ---------------------------------------------------------------------------
import '../../../../base/common/hierarchicalKind.dart' show HierarchicalKind;
import '../../../common/core/range.dart' show Range;
import '../../snippet/browser/snippetParser.dart' show SnippetParser;

/// 1:1: `ResourceTextEdit` carrier.
class ResourceTextEditForDropPaste {
  final String resource;
  final Range range;
  final String text;
  final bool insertAsSnippet;

  ResourceTextEditForDropPaste(this.resource, this.range, this.text)
      : insertAsSnippet = true;

  Map<String, Object?> toJson() => <String, Object?>{
        'resource': resource,
        'range': <Object?>[
          range.startLineNumber,
          range.startColumn,
          range.endLineNumber,
          range.endColumn,
        ],
        'text': text,
        'insertAsSnippet': insertAsSnippet,
      };
}

/// 1:1: snippet insert-text carrier.
class SnippetInsertText {
  final String snippet;

  SnippetInsertText(this.snippet);
}

/// 1:1: `WorkspaceEdit` carrier.
class WorkspaceEditForDropPaste {
  final List<Object?> edits;

  WorkspaceEditForDropPaste(this.edits);
}

/// 1:1: `DropYieldTo` union carrier.
class DropYieldToForEdit {
  final String? mimeType;
  final HierarchicalKind? kind;

  DropYieldToForEdit({this.mimeType, this.kind});
}

/// 1:1: edited item surface used by [sortEditsByYieldTo].
abstract class IYieldToEdit {
  HierarchicalKind? get kind;
  String? get handledMimeType;
  List<DropYieldToForEdit>? get yieldTo;
}

/// 1:1: `createCombinedWorkspaceEdit`.
WorkspaceEditForDropPaste createCombinedWorkspaceEdit(
  String uri,
  List<Range> ranges,
  Object insertText,
  List<Object?>? additionalEdits,
) {
  // If the edit insert text is empty, skip applying at each range
  final bool empty = insertText is String
      ? insertText.isEmpty
      : (insertText as SnippetInsertText).snippet.isEmpty;
  if (empty) {
    return WorkspaceEditForDropPaste(additionalEdits ?? <Object?>[]);
  }

  final String text = insertText is String
      ? SnippetParser.escape(insertText) + r'$0'
      : (insertText as SnippetInsertText).snippet;

  return WorkspaceEditForDropPaste(<Object?>[
    ...ranges.map((Range range) => ResourceTextEditForDropPaste(
        uri, range, text).toJson()),
    ...(additionalEdits ?? <Object?>[]),
  ]);
}

/// 1:1: `sortEditsByYieldTo`.
List<T> sortEditsByYieldTo<T extends IYieldToEdit>(List<T> edits) {
  bool yieldsTo(DropYieldToForEdit yTo, T other) {
    if (yTo.mimeType != null) {
      return yTo.mimeType == other.handledMimeType;
    }
    return other.kind != null && yTo.kind!.contains(other.kind!);
  }

  // Build list of nodes each node yields to
  final Map<T, List<T>> yieldsToMap = <T, List<T>>{};
  for (final T edit in edits) {
    for (final DropYieldToForEdit yTo in edit.yieldTo ?? <DropYieldToForEdit>[]) {
      for (final T other in edits) {
        if (identical(other, edit)) {
          continue;
        }
        if (yieldsTo(yTo, other)) {
          final List<T>? arr = yieldsToMap[edit];
          if (arr == null) {
            yieldsToMap[edit] = <T>[other];
          } else {
            arr.add(other);
          }
        }
      }
    }
  }

  if (yieldsToMap.isEmpty) {
    return List<T>.from(edits);
  }

  // Topological sort
  final Set<T> visited = <T>{};
  final List<T> tempStack = <T>[];

  List<T> visit(List<T> nodes) {
    if (nodes.isEmpty) {
      return <T>[];
    }
    final T node = nodes[0];
    if (tempStack.contains(node)) {
      // console.warn('Yield to cycle detected', node) in the source;
      // diagnostics are observed through this bridge in the Dart port.
      yieldToCycleWarn(node);
      return nodes;
    }
    if (visited.contains(node)) {
      return visit(nodes.sublist(1));
    }
    List<T> pre = <T>[];
    final List<T>? yTo = yieldsToMap[node];
    if (yTo != null) {
      tempStack.add(node);
      pre = visit(yTo);
      tempStack.removeLast();
    }
    visited.add(node);
    return <T>[...pre, node, ...visit(nodes.sublist(1))];
  }

  return visit(List<T>.from(edits));
}

/// 1:1: injectable `console.warn` for cycle diagnostics.
void Function(Object node) yieldToCycleWarn = (Object node) {};
