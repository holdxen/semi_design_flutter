// Truth replay for batch231 (editorOptions.ts lines 6144-6499):
//   `EditorOptions` slice 1 — the object literal from
//   `acceptSuggestionOnCommitCharacter` through `folding` (59 entries).
//
// Expectations come from `tool/ts2dart/batch231_truth.json`, produced by
// `tool/ts2dart/_batch231_truth.cjs`, which transpiles and executes the REAL
// `editorOptions.ts` (`nls` + `platform` stubbed) and reads each option from
// the real `EditorOptions` object / `editorOptionsRegistry`. The harness also
// asserts the source's sparse indexed write
// (`editorOptionsRegistry[option.id] === option`) for every covered entry.
// This test additionally checks the Dart registry's length and slot layout
// (registered ids filled at their index, all other ids left as null holes).
//
// JS `undefined` is replayed as Dart `null` (documented port convention); the
// harness deliberately omits a raw JS `null` input because `boolean(null)`
// differs between JS and Dart. Each validate case carries its own input.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/config/editorOptions.dart' as opts;

Map<String, dynamic> _map(Object? value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() =>
    _map(jsonDecode(File('tool/ts2dart/batch231_truth.json').readAsStringSync()));

/// Serializes the value carriers used by the nested option classes in this
/// slice to the same JSON shape the truth harness captured.
Object? _ser(Object? value) {
  if (value == null || value is bool || value is num || value is String) {
    return value;
  }
  if (value is Map) {
    return value.map<Object?, Object?>((Object? k, Object? v) =>
        MapEntry<Object?, Object?>(k as String, _ser(v)));
  }
  if (value is List) {
    return value.map<Object?>(_ser).toList();
  }
  if (value is opts.EditorCommentsOptions) {
    return <String, Object?>{
      'insertSpace': value.insertSpace,
      'ignoreEmptyLines': value.ignoreEmptyLines,
    };
  }
  if (value is opts.InternalBracketPairColorizationOptions) {
    return <String, Object?>{
      'enabled': value.enabled,
      'independentColorPoolPerBracketType':
          value.independentColorPoolPerBracketType,
    };
  }
  if (value is opts.InternalGuidesOptions) {
    return <String, Object?>{
      'bracketPairs': value.bracketPairs,
      'bracketPairsHorizontal': value.bracketPairsHorizontal,
      'highlightActiveBracketPair': value.highlightActiveBracketPair,
      'indentation': value.indentation,
      'highlightActiveIndentation': value.highlightActiveIndentation,
    };
  }
  if (value is opts.EditorStickyScrollOptions) {
    return <String, Object?>{
      'enabled': value.enabled,
      'maxLineCount': value.maxLineCount,
      'defaultModel': value.defaultModel,
      'scrollWithEditor': value.scrollWithEditor,
    };
  }
  if (value is opts.EditorDropIntoEditorOptions) {
    return <String, Object?>{
      'enabled': value.enabled,
      'showDropSelector': value.showDropSelector,
    };
  }
  if (value is opts.EditorFindOptions) {
    return <String, Object?>{
      'cursorMoveOnType': value.cursorMoveOnType,
      'findOnType': value.findOnType,
      'seedSearchStringFromSelection': value.seedSearchStringFromSelection,
      'autoFindInSelection': value.autoFindInSelection,
      'globalFindClipboard': value.globalFindClipboard,
      'addExtraSpaceOnTop': value.addExtraSpaceOnTop,
      'loop': value.loop,
      'closeOnResult': value.closeOnResult,
      'history': value.history,
      'replaceHistory': value.replaceHistory,
    };
  }
  // No other carrier type occurs in this slice; fail loudly on source drift.
  throw StateError('unexpected value carrier: ${value.runtimeType}');
}

// Mirrors the harness's platform-token schema scan.
final RegExp _platformToken = RegExp(
    r'\b(linux|macintosh|macos|windows|web|native|browser|electron)\b',
    caseSensitive: false);

void _collectPlatformStrings(Object? value, String path, List<Object?> out) {
  if (value is String) {
    if (_platformToken.hasMatch(value)) {
      out.add(<String, Object?>{'path': path, 'value': value});
    }
  } else if (value is List) {
    for (int i = 0; i < value.length; i++) {
      _collectPlatformStrings(value[i], '$path[$i]', out);
    }
  } else if (value is Map) {
    value.forEach((Object? key, Object? v) {
      _collectPlatformStrings(v, path.isEmpty ? '$key' : '$path.$key', out);
    });
  }
}

void main() {
  final Map<String, dynamic> truth = _truth();
  final List<String> order = (truth['order'] as List).cast<String>();

  // Touching every field forces Dart's lazily-initialized static fields, so
  // `register` has run for the whole slice before the registry assertions.
  final Map<String, opts.IEditorOption<Object?>> covered =
      <String, opts.IEditorOption<Object?>>{
    'acceptSuggestionOnCommitCharacter':
        opts.EditorOptions.acceptSuggestionOnCommitCharacter,
    'acceptSuggestionOnEnter': opts.EditorOptions.acceptSuggestionOnEnter,
    'accessibilitySupport': opts.EditorOptions.accessibilitySupport,
    'accessibilityPageSize': opts.EditorOptions.accessibilityPageSize,
    'allowOverflow': opts.EditorOptions.allowOverflow,
    'allowVariableLineHeights': opts.EditorOptions.allowVariableLineHeights,
    'allowVariableFonts': opts.EditorOptions.allowVariableFonts,
    'allowVariableFontsInAccessibilityMode':
        opts.EditorOptions.allowVariableFontsInAccessibilityMode,
    'ariaLabel': opts.EditorOptions.ariaLabel,
    'ariaRequired': opts.EditorOptions.ariaRequired,
    'screenReaderAnnounceInlineSuggestion':
        opts.EditorOptions.screenReaderAnnounceInlineSuggestion,
    'autoClosingBrackets': opts.EditorOptions.autoClosingBrackets,
    'autoClosingComments': opts.EditorOptions.autoClosingComments,
    'autoClosingDelete': opts.EditorOptions.autoClosingDelete,
    'autoClosingOvertype': opts.EditorOptions.autoClosingOvertype,
    'autoClosingQuotes': opts.EditorOptions.autoClosingQuotes,
    'autoIndent': opts.EditorOptions.autoIndent,
    'autoIndentOnPaste': opts.EditorOptions.autoIndentOnPaste,
    'autoIndentOnPasteWithinString':
        opts.EditorOptions.autoIndentOnPasteWithinString,
    'automaticLayout': opts.EditorOptions.automaticLayout,
    'autoSurround': opts.EditorOptions.autoSurround,
    'bracketPairColorization': opts.EditorOptions.bracketPairColorization,
    'bracketPairGuides': opts.EditorOptions.bracketPairGuides,
    'stickyTabStops': opts.EditorOptions.stickyTabStops,
    'codeLens': opts.EditorOptions.codeLens,
    'codeLensFontFamily': opts.EditorOptions.codeLensFontFamily,
    'codeLensFontSize': opts.EditorOptions.codeLensFontSize,
    'colorDecorators': opts.EditorOptions.colorDecorators,
    'colorDecoratorActivatedOn': opts.EditorOptions.colorDecoratorActivatedOn,
    'colorDecoratorsLimit': opts.EditorOptions.colorDecoratorsLimit,
    'columnSelection': opts.EditorOptions.columnSelection,
    'comments': opts.EditorOptions.comments,
    'contextmenu': opts.EditorOptions.contextmenu,
    'copyWithSyntaxHighlighting': opts.EditorOptions.copyWithSyntaxHighlighting,
    'cursorBlinking': opts.EditorOptions.cursorBlinking,
    'cursorSmoothCaretAnimation': opts.EditorOptions.cursorSmoothCaretAnimation,
    'cursorStyle': opts.EditorOptions.cursorStyle,
    'overtypeCursorStyle': opts.EditorOptions.overtypeCursorStyle,
    'cursorSurroundingLines': opts.EditorOptions.cursorSurroundingLines,
    'cursorSurroundingLinesStyle':
        opts.EditorOptions.cursorSurroundingLinesStyle,
    'cursorWidth': opts.EditorOptions.cursorWidth,
    'cursorHeight': opts.EditorOptions.cursorHeight,
    'disableLayerHinting': opts.EditorOptions.disableLayerHinting,
    'disableMonospaceOptimizations':
        opts.EditorOptions.disableMonospaceOptimizations,
    'domReadOnly': opts.EditorOptions.domReadOnly,
    'doubleClickSelectsBlock': opts.EditorOptions.doubleClickSelectsBlock,
    'dragAndDrop': opts.EditorOptions.dragAndDrop,
    'emptySelectionClipboard': opts.EditorOptions.emptySelectionClipboard,
    'dropIntoEditor': opts.EditorOptions.dropIntoEditor,
    'editContext': opts.EditorOptions.editContext,
    'renderRichScreenReaderContent':
        opts.EditorOptions.renderRichScreenReaderContent,
    'stickyScroll': opts.EditorOptions.stickyScroll,
    'experimentalGpuAcceleration': opts.EditorOptions.experimentalGpuAcceleration,
    'experimentalWhitespaceRendering':
        opts.EditorOptions.experimentalWhitespaceRendering,
    'extraEditorClassName': opts.EditorOptions.extraEditorClassName,
    'fastScrollSensitivity': opts.EditorOptions.fastScrollSensitivity,
    'find': opts.EditorOptions.find,
    'fixedOverflowWidgets': opts.EditorOptions.fixedOverflowWidgets,
    'folding': opts.EditorOptions.folding,
  };

  test('EditorOptions slice 1 covers exactly the captured 59 entries', () {
    expect(order.length, 59);
    expect(covered.keys.toSet(), order.toSet());
  });

  test('every entry id, name, defaultValue and schema match the real source',
      () {
    for (final String name in order) {
      final Map<String, dynamic> expected = _map(truth['entries'][name]);
      final opts.IEditorOption<Object?> option = covered[name]!;
      expect(option.id, expected['id'], reason: '$name.id');
      expect(option.name, expected['name'], reason: '$name.name');
      expect(_ser(option.defaultValue), expected['defaultValue'],
          reason: '$name.defaultValue');
      expect(option.schema, expected['schema'], reason: '$name.schema');
    }
  });

  test('validate matches every captured input/result pair', () {
    for (final String name in order) {
      final Map<String, dynamic> expected = _map(truth['entries'][name]);
      final opts.IEditorOption<Object?> option = covered[name]!;
      final List<Object?> cases = (expected['validate'] as List).cast<Object?>();
      for (final Object? entry in cases) {
        final Map<String, dynamic> c = _map(entry);
        expect(_ser(option.validate(c['input'])), c['result'],
            reason: '$name.validate/${c['label']}');
      }
    }
  });

  test('registry length and slots reflect indexed registration with holes', () {
    final Set<int> ids = order
        .map((String name) => _map(truth['entries'][name])['id'] as int)
        .toSet();
    int maxId = 0;
    for (final int id in ids) {
      if (id > maxId) maxId = id;
    }
    final int expectedLength = maxId + 1;

    expect(opts.editorOptionsRegistry.length, expectedLength);
    for (final String name in order) {
      final Map<String, dynamic> expected = _map(truth['entries'][name]);
      final int id = expected['id'] as int;
      final opts.IEditorOption<Object?>? slot = opts.editorOptionsRegistry[id];
      expect(slot, isNotNull, reason: '$name must occupy slot $id');
      expect(slot, same(covered[name]), reason: '$name identity at slot $id');
      expect(slot!.name, expected['name'], reason: '$name.name at slot $id');
      expect(expected['registrySlotIsSelf'], true, reason: name);
    }
    for (int id = 0; id < expectedLength; id++) {
      if (!ids.contains(id)) {
        expect(opts.editorOptionsRegistry[id], isNull,
            reason: 'uncovered id $id must stay a null hole');
      }
    }
    // The real source registers the WHOLE EditorOptions object (180 ids);
    // batch231 only owns slice 1, so its registry is deliberately shorter.
    expect(truth['editorOptionsRegistryLength'], 180);
    expect(expectedLength, lessThan(180));
  });

  test('platform-token schema strings match the real source', () {
    final List<Object?> captured = <Object?>[];
    for (final String name in order) {
      _collectPlatformStrings(covered[name]!.schema, name, captured);
    }
    expect(captured, truth['platformSchemaStrings']);
  });
}
