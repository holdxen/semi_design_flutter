// batch58: editorContextKeys.ts + platform/contextkey/common/contextkeys.ts
// All assertions are data-driven from ctxkeyfamily_truth.json (Node TS real eval).
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/nls.dart' show localize;
import 'package:semi_design_flutter/src/monaco/base/common/platform.dart' as mplat;
import 'package:semi_design_flutter/src/monaco/platform/contextkey/common/contextkey.dart';
import 'package:semi_design_flutter/src/monaco/platform/contextkey/common/contextkeys.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/editorContextKeys.dart';

/// Minimal IContextKey that captures nothing; createKey records defaultValue.
class _CaptureKey<T> implements IContextKey<T> {
  @override
  void set(T value) {}
  @override
  void reset() {}
  @override
  T? get_() => null;
}

class _CaptureService implements IContextKeyServiceType {
  Object? lastDefaultValue;
  // Private name is library-scoped; it does not override the interface one.
  // ignore: unused_element, override_on_non_overriding_member
  Object? get _serviceBrand => null;
  @override
  Object get onDidChangeContext => throw UnimplementedError();
  @override
  void bufferChangeEvents(void Function() callback) => callback();
  @override
  IContextKey<T> createKey<T>(String key, T? defaultValue) {
    lastDefaultValue = defaultValue;
    return _CaptureKey<T>();
  }
  @override
  bool contextMatchesRules(ContextKeyExpression? rules) => false;
  @override
  T? getContextKeyValue<T>(String key) => null;
  @override
  IScopedContextKeyService createScoped(IContextKeyServiceTarget target) =>
      throw UnimplementedError();
  @override
  IContextKeyServiceType createOverlay(Iterable<List<Object?>> overlay) =>
      throw UnimplementedError();
  @override
  IContext getContext(IContextKeyServiceTarget? target) => throw UnimplementedError();
  @override
  void updateParent(IContextKeyServiceType parentContextKeyService) {}
}

Map<String, dynamic> _truth() => jsonDecode(
      File('tool/ts2dart/ctxkeyfamily_truth.json').readAsStringSync(),
    ) as Map<String, dynamic>;

Object? _decodeDefault(Object? v) => v == '__undefined__' ? null : v;

/// Verify a RawContextKey declaration against its truth record.
void _verify(Map<String, dynamic> rec, RawContextKey<Object?> key,
    {bool platformDependent = false}) {
  expect(key.key, rec['key'], reason: 'key name');
  expect(key.serialize(), rec['key'], reason: 'serialize == key');
  // defaultValue via bindTo mock
  if (!platformDependent) {
    final svc = _CaptureService();
    key.bindTo(svc);
    expect(svc.lastDefaultValue, _decodeDefault(rec['defaultValue']),
        reason: 'defaultValue of ${rec['key']}');
  }
  // description/type via RawContextKey.all()
  final info = RawContextKey.all().where((i) => i.key == rec['key']).toList();
  final expectedDesc = rec['description'] as String?;
  if (expectedDesc == null) {
    expect(info.isEmpty, isTrue, reason: '${rec['key']} hidden (no info)');
  } else {
    expect(info.length, 1, reason: 'info registered once for ${rec['key']}');
    expect(info.single.description, expectedDesc, reason: 'description');
  }
  // negated expression (constant folding from platform values)
  if (!platformDependent) {
    expect(key.toNegated().serialize(), rec['negated'],
        reason: 'negated serialize');
  }
}

void main() {
  final truth = _truth();

  test('b58 localize carries nls message through (data is String)', () {
    expect(localize('editorTextFocus', 'msg'), 'msg');
  });

  test('b58 editorContextKeys: all 57 RawContextKey declarations match truth', () {
    final map = <String, RawContextKey<Object?>>{
      'editorSimpleInput': EditorContextKeys.editorSimpleInput,
      'editorTextFocus': EditorContextKeys.editorTextFocus,
      'focus': EditorContextKeys.focus,
      'textInputFocus': EditorContextKeys.textInputFocus,
      'readOnly': EditorContextKeys.readOnly,
      'inDiffEditor': EditorContextKeys.inDiffEditor,
      'isEmbeddedDiffEditor': EditorContextKeys.isEmbeddedDiffEditor,
      'inMultiDiffEditor': EditorContextKeys.inMultiDiffEditor,
      'multiDiffEditorAllCollapsed': EditorContextKeys.multiDiffEditorAllCollapsed,
      'multiDiffEditorItemAllUnchangedRegionsShown': EditorContextKeys.multiDiffEditorItemAllUnchangedRegionsShown,
      'multiDiffEditorRenderSideBySide': EditorContextKeys.multiDiffEditorRenderSideBySide,
      'hasChanges': EditorContextKeys.hasChanges,
      'comparingMovedCode': EditorContextKeys.comparingMovedCode,
      'accessibleDiffViewerVisible': EditorContextKeys.accessibleDiffViewerVisible,
      'diffEditorRenderSideBySideInlineBreakpointReached': EditorContextKeys.diffEditorRenderSideBySideInlineBreakpointReached,
      'diffEditorInlineMode': EditorContextKeys.diffEditorInlineMode,
      'diffEditorTemporaryInlineMode': EditorContextKeys.diffEditorTemporaryInlineMode,
      'diffEditorAutomaticRenderSideBySide': EditorContextKeys.diffEditorAutomaticRenderSideBySide,
      'diffEditorOriginalWritable': EditorContextKeys.diffEditorOriginalWritable,
      'diffEditorModifiedWritable': EditorContextKeys.diffEditorModifiedWritable,
      'diffEditorOriginalUri': EditorContextKeys.diffEditorOriginalUri,
      'diffEditorModifiedUri': EditorContextKeys.diffEditorModifiedUri,
      'columnSelection': EditorContextKeys.columnSelection,
      'hasNonEmptySelection': EditorContextKeys.hasNonEmptySelection,
      'hasMultipleSelections': EditorContextKeys.hasMultipleSelections,
      'tabMovesFocus': EditorContextKeys.tabMovesFocus,
      'isInEmbeddedEditor': EditorContextKeys.isInEmbeddedEditor,
      'canUndo': EditorContextKeys.canUndo,
      'canRedo': EditorContextKeys.canRedo,
      'hoverVisible': EditorContextKeys.hoverVisible,
      'hoverFocused': EditorContextKeys.hoverFocused,
      'stickyScrollFocused': EditorContextKeys.stickyScrollFocused,
      'stickyScrollVisible': EditorContextKeys.stickyScrollVisible,
      'standaloneColorPickerVisible': EditorContextKeys.standaloneColorPickerVisible,
      'standaloneColorPickerFocused': EditorContextKeys.standaloneColorPickerFocused,
      'isComposing': EditorContextKeys.isComposing,
      'inCompositeEditor': EditorContextKeys.inCompositeEditor,
      'languageId': EditorContextKeys.languageId,
      'hasCompletionItemProvider': EditorContextKeys.hasCompletionItemProvider,
      'hasCodeActionsProvider': EditorContextKeys.hasCodeActionsProvider,
      'hasCodeLensProvider': EditorContextKeys.hasCodeLensProvider,
      'hasDefinitionProvider': EditorContextKeys.hasDefinitionProvider,
      'hasDeclarationProvider': EditorContextKeys.hasDeclarationProvider,
      'hasImplementationProvider': EditorContextKeys.hasImplementationProvider,
      'hasTypeDefinitionProvider': EditorContextKeys.hasTypeDefinitionProvider,
      'hasHoverProvider': EditorContextKeys.hasHoverProvider,
      'hasDocumentHighlightProvider': EditorContextKeys.hasDocumentHighlightProvider,
      'hasDocumentSymbolProvider': EditorContextKeys.hasDocumentSymbolProvider,
      'hasReferenceProvider': EditorContextKeys.hasReferenceProvider,
      'hasRenameProvider': EditorContextKeys.hasRenameProvider,
      'hasSignatureHelpProvider': EditorContextKeys.hasSignatureHelpProvider,
      'hasInlayHintsProvider': EditorContextKeys.hasInlayHintsProvider,
      'hasDocumentFormattingProvider': EditorContextKeys.hasDocumentFormattingProvider,
      'hasDocumentSelectionFormattingProvider': EditorContextKeys.hasDocumentSelectionFormattingProvider,
      'hasMultipleDocumentFormattingProvider': EditorContextKeys.hasMultipleDocumentFormattingProvider,
      'hasMultipleDocumentSelectionFormattingProvider': EditorContextKeys.hasMultipleDocumentSelectionFormattingProvider,
      'selectionHasDiagnostics': EditorContextKeys.selectionHasDiagnostics,
    };
    final records = (truth['editor'] as Map<String, dynamic>)['EditorContextKeys']
        as Map<String, dynamic>;
    for (final entry in map.entries) {
      final rec = records[entry.key] as Map<String, dynamic>;
      expect(rec['derived'], isNot(true), reason: '${entry.key} is raw');
      _verify(rec, entry.value);
    }
    expect(map.length, 57);
  });

  test('b58 editorContextKeys: 5 derived negations match truth', () {
    final map = <String, ContextKeyExpression>{
      'writable': EditorContextKeys.writable,
      'hasOnlyEmptySelection': EditorContextKeys.hasOnlyEmptySelection,
      'hasSingleSelection': EditorContextKeys.hasSingleSelection,
      'tabDoesNotMoveFocus': EditorContextKeys.tabDoesNotMoveFocus,
      'notInCompositeEditor': EditorContextKeys.notInCompositeEditor,
    };
    final records = (truth['editor'] as Map<String, dynamic>)['EditorContextKeys']
        as Map<String, dynamic>;
    for (final entry in map.entries) {
      final rec = records[entry.key] as Map<String, dynamic>;
      expect(rec['derived'], true);
      expect(entry.value.serialize(), rec['serialize'],
          reason: 'derived ${entry.key}');
    }
    expect(map.length, 5);
  });

  test('b58 platform contextkeys: all 11 RawContextKey declarations match truth', () {
    final map = <String, RawContextKey<Object?>>{
      'IsMacContext': IsMacContext,
      'IsLinuxContext': IsLinuxContext,
      'IsWindowsContext': IsWindowsContext,
      'IsChromeOSContext': IsChromeOSContext,
      'IsWebContext': IsWebContext,
      'IsMacNativeContext': IsMacNativeContext,
      'IsIOSContext': IsIOSContext,
      'IsMobileContext': IsMobileContext,
      'IsDevelopmentContext': IsDevelopmentContext,
      'ProductQualityContext': ProductQualityContext,
      'InputFocusedContext': InputFocusedContext,
    };
    final records = truth['platform'] as Map<String, dynamic>;
    for (final entry in map.entries) {
      final rec = records[entry.key] as Map<String, dynamic>;
      _verify(rec, entry.value, platformDependent: true);
    }
    expect(map.length, 11);
  });

  test('b58 platform: default values bind to real platform constants', () {
    // The truth stub used isLinux=true; the Dart side uses the real platform
    // constants. Verify the 1:1 translation binds the correct expression.
    expect(IsMacContext.key, 'isMac');
    expect(IsLinuxContext.key, 'isLinux');
    expect(IsWindowsContext.key, 'isWindows');
    expect(IsChromeOSContext.key, 'isChromeOS');
    expect(IsWebContext.key, 'isWeb');
    expect(IsMacNativeContext.key, 'isMacNative');
    expect(IsIOSContext.key, 'isIOS');
    expect(IsMobileContext.key, 'isMobile');
    expect(IsDevelopmentContext.key, 'isDevelopment');
    expect(ProductQualityContext.key, 'productQualityType');
    expect(InputFocusedContext.key, 'inputFocus');
    expect(InputFocusedContextKey, 'inputFocus');
    final expectedDefaults = <RawContextKey<Object?>, Object?>{
      IsMacContext: mplat.isMacintosh,
      IsLinuxContext: mplat.isLinux,
      IsWindowsContext: mplat.isWindows,
      IsChromeOSContext: mplat.isChromeOS,
      IsWebContext: mplat.isWeb,
      IsMacNativeContext: mplat.isMacintosh && !mplat.isWeb,
      IsIOSContext: mplat.isIOS,
      IsMobileContext: mplat.isMobile,
      IsDevelopmentContext: false,
      ProductQualityContext: '',
      InputFocusedContext: false,
    };
    expectedDefaults.forEach((key, expected) {
      final svc = _CaptureService();
      key.bindTo(svc);
      expect(svc.lastDefaultValue, expected,
          reason: 'default of ${key.key} binds real platform constant');
    });
    // negated folds only when the key is a known CONSTANT_VALUES entry
    final negExpect = (String k) => CONSTANT_VALUES.containsKey(k)
        ? (CONSTANT_VALUES[k]! ? 'false' : 'true')
        : '!$k';
    final allPlatform = <RawContextKey<Object?>>[
      IsMacContext, IsLinuxContext, IsWindowsContext, IsChromeOSContext,
      IsWebContext, IsMacNativeContext, IsIOSContext, IsMobileContext,
      IsDevelopmentContext, ProductQualityContext, InputFocusedContext,
    ];
    for (final key in allPlatform) {
      expect(key.toNegated().serialize(), negExpect(key.key),
          reason: 'negated of ${key.key} follows real CONSTANT_VALUES');
    }
  });
}
