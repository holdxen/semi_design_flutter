// Truth replay for batch232 (editorOptions.ts lines 6500-6801):
//   `EditorOptions` slice 2 — the object literal from `foldingStrategy`
//   through `roundedSelection` (64 entries).
//
// Expectations come from `tool/ts2dart/batch232_truth.json`, produced by
// `tool/ts2dart/_batch232_truth.cjs`, which transpiles and executes the REAL
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
import '../lib/src/monaco/editor/common/config/fontInfo.dart' show FontInfo;

Map<String, dynamic> _map(Object? value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() =>
    _map(jsonDecode(File('tool/ts2dart/batch232_truth.json').readAsStringSync()));

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
  if (value is FontInfo) {
    return <String, Object?>{
      'pixelRatio': value.pixelRatio,
      'fontFamily': value.fontFamily,
      'fontWeight': value.fontWeight,
      'fontSize': value.fontSize,
      'fontFeatureSettings': value.fontFeatureSettings,
      'fontVariationSettings': value.fontVariationSettings,
      'lineHeight': value.lineHeight,
      'letterSpacing': value.letterSpacing,
      'version': value.version,
      'isTrusted': value.isTrusted,
      'isMonospace': value.isMonospace,
      'typicalHalfwidthCharacterWidth': value.typicalHalfwidthCharacterWidth,
      'typicalFullwidthCharacterWidth': value.typicalFullwidthCharacterWidth,
      'canUseHalfwidthRightwardsArrow': value.canUseHalfwidthRightwardsArrow,
      'spaceWidth': value.spaceWidth,
      'middotWidth': value.middotWidth,
      'wsmiddotWidth': value.wsmiddotWidth,
      'maxDigitWidth': value.maxDigitWidth,
    };
  }
  if (value is opts.GoToLocationOptions) {
    return <String, Object?>{
      'multiple': value.multiple,
      'multipleDefinitions': value.multipleDefinitions,
      'multipleTypeDefinitions': value.multipleTypeDefinitions,
      'multipleDeclarations': value.multipleDeclarations,
      'multipleImplementations': value.multipleImplementations,
      'multipleReferences': value.multipleReferences,
      'multipleTests': value.multipleTests,
      'alternativeDefinitionCommand': value.alternativeDefinitionCommand,
      'alternativeTypeDefinitionCommand': value.alternativeTypeDefinitionCommand,
      'alternativeDeclarationCommand': value.alternativeDeclarationCommand,
      'alternativeImplementationCommand': value.alternativeImplementationCommand,
      'alternativeReferenceCommand': value.alternativeReferenceCommand,
      'alternativeTestsCommand': value.alternativeTestsCommand,
    };
  }
  if (value is opts.EditorHoverOptions) {
    return <String, Object?>{
      'enabled': value.enabled,
      'delay': value.delay,
      'sticky': value.sticky,
      'hidingDelay': value.hidingDelay,
      'above': value.above,
      'showLongLineWarning': value.showLongLineWarning,
    };
  }
  if (value is opts.EditorLightbulbOptions) {
    return <String, Object?>{'enabled': value.enabled};
  }
  if (value is opts.InternalEditorRenderLineNumbersOptions) {
    return <String, Object?>{
      'renderType': value.renderType,
      'renderFn': _ser(value.renderFn),
    };
  }
  if (value is opts.EditorMarkdownImagesOptions) {
    return <String, Object?>{'allowedOrigins': _ser(value.allowedOrigins)};
  }
  if (value is opts.EditorMinimapOptions) {
    return <String, Object?>{
      'enabled': value.enabled,
      'size': value.size,
      'side': value.side,
      'showSlider': value.showSlider,
      'autohide': value.autohide,
      'renderCharacters': value.renderCharacters,
      'maxColumn': value.maxColumn,
      'scale': value.scale,
      'showRegionSectionHeaders': value.showRegionSectionHeaders,
      'showMarkSectionHeaders': value.showMarkSectionHeaders,
      'markSectionHeaderRegex': value.markSectionHeaderRegex,
      'sectionHeaderFontSize': value.sectionHeaderFontSize,
      'sectionHeaderLetterSpacing': value.sectionHeaderLetterSpacing,
    };
  }
  if (value is opts.EditorPaddingOptions) {
    return <String, Object?>{'top': value.top, 'bottom': value.bottom};
  }
  if (value is opts.EditorPasteAsOptions) {
    return <String, Object?>{
      'enabled': value.enabled,
      'showPasteSelector': value.showPasteSelector,
    };
  }
  if (value is opts.EditorParameterHintsOptions) {
    return <String, Object?>{'enabled': value.enabled, 'cycle': value.cycle};
  }
  if (value is opts.InternalQuickSuggestionsOptions) {
    return <String, Object?>{
      'other': value.other,
      'comments': value.comments,
      'strings': value.strings,
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
    'foldingStrategy': opts.EditorOptions.foldingStrategy,
    'foldingHighlight': opts.EditorOptions.foldingHighlight,
    'foldingImportsByDefault': opts.EditorOptions.foldingImportsByDefault,
    'foldingMaximumRegions': opts.EditorOptions.foldingMaximumRegions,
    'unfoldOnClickAfterEndOfLine':
        opts.EditorOptions.unfoldOnClickAfterEndOfLine,
    'fontFamily': opts.EditorOptions.fontFamily,
    'fontInfo': opts.EditorOptions.fontInfo,
    'fontLigatures2': opts.EditorOptions.fontLigatures2,
    'fontSize': opts.EditorOptions.fontSize,
    'fontWeight': opts.EditorOptions.fontWeight,
    'fontVariations': opts.EditorOptions.fontVariations,
    'formatOnPaste': opts.EditorOptions.formatOnPaste,
    'formatOnType': opts.EditorOptions.formatOnType,
    'fullwidthCharacterWidth': opts.EditorOptions.fullwidthCharacterWidth,
    'glyphMargin': opts.EditorOptions.glyphMargin,
    'gotoLocation': opts.EditorOptions.gotoLocation,
    'hideCursorInOverviewRuler': opts.EditorOptions.hideCursorInOverviewRuler,
    'hover': opts.EditorOptions.hover,
    'inDiffEditor': opts.EditorOptions.inDiffEditor,
    'inertialScroll': opts.EditorOptions.inertialScroll,
    'letterSpacing': opts.EditorOptions.letterSpacing,
    'lightbulb': opts.EditorOptions.lightbulb,
    'lineDecorationsWidth': opts.EditorOptions.lineDecorationsWidth,
    'lineHeight': opts.EditorOptions.lineHeight,
    'lineNumbers': opts.EditorOptions.lineNumbers,
    'lineNumbersMinChars': opts.EditorOptions.lineNumbersMinChars,
    'linkedEditing': opts.EditorOptions.linkedEditing,
    'links': opts.EditorOptions.links,
    'markdownImages': opts.EditorOptions.markdownImages,
    'matchBrackets': opts.EditorOptions.matchBrackets,
    'minimap': opts.EditorOptions.minimap,
    'mouseStyle': opts.EditorOptions.mouseStyle,
    'mouseWheelScrollSensitivity':
        opts.EditorOptions.mouseWheelScrollSensitivity,
    'mouseWheelZoom': opts.EditorOptions.mouseWheelZoom,
    'multiCursorMergeOverlapping':
        opts.EditorOptions.multiCursorMergeOverlapping,
    'multiCursorModifier': opts.EditorOptions.multiCursorModifier,
    'mouseMiddleClickAction': opts.EditorOptions.mouseMiddleClickAction,
    'multiCursorPaste': opts.EditorOptions.multiCursorPaste,
    'multiCursorLimit': opts.EditorOptions.multiCursorLimit,
    'occurrencesHighlight': opts.EditorOptions.occurrencesHighlight,
    'occurrencesHighlightDelay': opts.EditorOptions.occurrencesHighlightDelay,
    'occurrencesHighlightFromAllProviders':
        opts.EditorOptions.occurrencesHighlightFromAllProviders,
    'overtypeOnPaste': opts.EditorOptions.overtypeOnPaste,
    'overviewRulerBorder': opts.EditorOptions.overviewRulerBorder,
    'overviewRulerLanes': opts.EditorOptions.overviewRulerLanes,
    'padding': opts.EditorOptions.padding,
    'pasteAs': opts.EditorOptions.pasteAs,
    'parameterHints': opts.EditorOptions.parameterHints,
    'peekWidgetDefaultFocus': opts.EditorOptions.peekWidgetDefaultFocus,
    'placeholder': opts.EditorOptions.placeholder,
    'definitionLinkOpensInPeek': opts.EditorOptions.definitionLinkOpensInPeek,
    'quickSuggestions': opts.EditorOptions.quickSuggestions,
    'quickSuggestionsDelay': opts.EditorOptions.quickSuggestionsDelay,
    'readOnly': opts.EditorOptions.readOnly,
    'readOnlyMessage': opts.EditorOptions.readOnlyMessage,
    'renameOnType': opts.EditorOptions.renameOnType,
    'renderControlCharacters': opts.EditorOptions.renderControlCharacters,
    'renderFinalNewline': opts.EditorOptions.renderFinalNewline,
    'renderLineHighlight': opts.EditorOptions.renderLineHighlight,
    'renderLineHighlightOnlyWhenFocus':
        opts.EditorOptions.renderLineHighlightOnlyWhenFocus,
    'renderValidationDecorations':
        opts.EditorOptions.renderValidationDecorations,
    'renderWhitespace': opts.EditorOptions.renderWhitespace,
    'revealHorizontalRightPadding':
        opts.EditorOptions.revealHorizontalRightPadding,
    'roundedSelection': opts.EditorOptions.roundedSelection,
  };

  test('EditorOptions slice 2 covers exactly the captured 64 entries', () {
    expect(order.length, 64);
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
        // `EditorRenderLineNumbersOption` is the one option whose source
        // `validate` distinguishes JS `undefined` from `null`; the Dart port
        // replays `undefined` with its no-argument sentinel form (documented
        // inline in editorOptions.dart), so the harness's `undefined` case
        // must call `validate()` with no arguments here.
        final Object? result = (name == 'lineNumbers' && c['input'] == null)
            ? (option as opts.EditorRenderLineNumbersOption).validate()
            : option.validate(c['input']);
        expect(_ser(result), c['result'],
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
    // batch232 only owns slice 2, so its registry is deliberately shorter.
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
