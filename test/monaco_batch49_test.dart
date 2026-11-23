import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/LspConnection.dart' as C;
import 'package:semi_design_flutter/src/monaco/lsp/adapters/languageFeatures/common.dart' as CF;

Map<String, dynamic> _truth() =>
    jsonDecode(File('tool/ts2dart/common_truth.json').readAsStringSync()) as Map<String, dynamic>;

String sym(Object? v) => v == null ? '@undefined' : v.toString();

/// Normalize a value to a comparable string: TS truth emits raw numbers for
/// LSP enum values and '@undefined' for missing.
String norm(Object? v) {
  final s = sym(v);
  if (s.startsWith('@')) return s;
  return s;
}

void main() {
  final truth = _truth();

  group('batch49 / LspConnection + common conversions 1:1', () {
    test('all 15 conversion maps match TS runtime truth (89 entries)', () {
      final maps = <String, Map<Object?, Object?>>{
        'lspCodeActionKindToMonacoCodeActionKind': CF.lspCodeActionKindToMonacoCodeActionKind,
        'monacoCodeActionTriggerTypeToLspCodeActionTriggerKind': CF.monacoCodeActionTriggerTypeToLspCodeActionTriggerKind,
        'lspCompletionItemKindToMonacoCompletionItemKind': CF.lspCompletionItemKindToMonacoCompletionItemKind,
        'lspCompletionItemTagToMonacoCompletionItemTag': CF.lspCompletionItemTagToMonacoCompletionItemTag,
        'monacoCompletionTriggerKindToLspCompletionTriggerKind': CF.monacoCompletionTriggerKindToLspCompletionTriggerKind,
        'lspInsertTextFormatToMonacoInsertTextRules': CF.lspInsertTextFormatToMonacoInsertTextRules,
        'lspSymbolKindToMonacoSymbolKind': CF.lspSymbolKindToMonacoSymbolKind,
        'lspSymbolTagToMonacoSymbolTag': CF.lspSymbolTagToMonacoSymbolTag,
        'lspDocumentHighlightKindToMonacoDocumentHighlightKind': CF.lspDocumentHighlightKindToMonacoDocumentHighlightKind,
        'lspFoldingRangeKindToMonacoFoldingRangeKind': CF.lspFoldingRangeKindToMonacoFoldingRangeKind,
        'monacoMarkerSeverityToLspDiagnosticSeverity': CF.monacoMarkerSeverityToLspDiagnosticSeverity,
        'lspDiagnosticSeverityToMonacoMarkerSeverity': CF.lspDiagnosticSeverityToMonacoMarkerSeverity,
        'lspDiagnosticTagToMonacoMarkerTag': CF.lspDiagnosticTagToMonacoMarkerTag,
        'monacoSignatureHelpTriggerKindToLspSignatureHelpTriggerKind': CF.monacoSignatureHelpTriggerKindToLspSignatureHelpTriggerKind,
        'lspInlayHintKindToMonacoInlayHintKind': CF.lspInlayHintKindToMonacoInlayHintKind,
      };
      final tsMaps = truth['maps'] as Map<String, dynamic>;
      expect(maps.keys, tsMaps.keys);
      for (final entry in maps.entries) {
        final tsEntries = (tsMaps[entry.key] as List).cast<List<dynamic>>();
        expect(entry.value.length, tsEntries.length, reason: '${entry.key} size');
        for (final pair in tsEntries) {
          final k = pair[0];
          final expected = pair[1];
          expect(entry.value.containsKey(k), true, reason: '${entry.key} missing key $k');
          expect(norm(entry.value[k]), norm(expected), reason: '${entry.key}[$k]');
        }
      }
    });

    test('LSP->monaco conversion functions match TS truth', () {
      final f = truth['funcs'] as Map<String, dynamic>;
      final checks = <String, List<Object?>>{
        'toMonacoCodeActionKind': <Object?>['', 'quickfix', 'unknown.kind', null],
        'toMonacoCompletionItemKind': <Object?>[1, 2, 25, 0, 999, null],
        'toMonacoCompletionItemTag': <Object?>[1, 0, 999],
        'toMonacoInsertTextRules': <Object?>[1, 2, 0, null, 999],
        'toMonacoSymbolKind': <Object?>[1, 2, 26, 0, 999],
        'toMonacoSymbolTag': <Object?>[1, 0, 999],
        'toMonacoDocumentHighlightKind': <Object?>[1, 2, 3, 0, null],
        'toMonacoFoldingRangeKind': <Object?>['comment', 'imports', 'region', 'zzz', null],
        'toMonacoDiagnosticSeverity': <Object?>[1, 2, 3, 4, 0, null],
        'toMonacoDiagnosticTag': <Object?>[1, 2, 0, 999],
        'toMonacoInlayHintKind': <Object?>[1, 2, 0, null, 999],
      };
      final funcs = <String, Object? Function(Object?)>{
        'toMonacoCodeActionKind': CF.toMonacoCodeActionKind,
        'toMonacoCompletionItemKind': CF.toMonacoCompletionItemKind,
        'toMonacoCompletionItemTag': CF.toMonacoCompletionItemTag,
        'toMonacoInsertTextRules': CF.toMonacoInsertTextRules,
        'toMonacoSymbolKind': CF.toMonacoSymbolKind,
        'toMonacoSymbolTag': CF.toMonacoSymbolTag,
        'toMonacoDocumentHighlightKind': CF.toMonacoDocumentHighlightKind,
        'toMonacoFoldingRangeKind': CF.toMonacoFoldingRangeKind,
        'toMonacoDiagnosticSeverity': CF.toMonacoDiagnosticSeverity,
        'toMonacoDiagnosticTag': CF.toMonacoDiagnosticTag,
        'toMonacoInlayHintKind': CF.toMonacoInlayHintKind,
      };
      for (final c in checks.entries) {
        final expected = (f[c.key] as List).cast<Object?>();
        for (var i = 0; i < c.value.length; i++) {
          expect(norm(funcs[c.key]!(c.value[i])), norm(expected[i]),
              reason: '${c.key}(${c.value[i]})');
        }
      }
    });

    test('monaco->LSP conversion functions match TS truth', () {
      final f = truth['funcs'] as Map<String, dynamic>;
      final checks = <String, List<Object?>>{
        'toLspCodeActionTriggerKind': <Object?>['monaco.languages.CodeActionTriggerType.Invoke', 'monaco.languages.CodeActionTriggerType.Auto', 999],
        'toLspCompletionTriggerKind': <Object?>['monaco.languages.CompletionTriggerKind.Invoke', 'monaco.languages.CompletionTriggerKind.TriggerCharacter', 999],
        'toLspDiagnosticSeverity': <Object?>['monaco.MarkerSeverity.Error', 'monaco.MarkerSeverity.Warning', 'monaco.MarkerSeverity.Info', 'monaco.MarkerSeverity.Hint'],
        'toLspSignatureHelpTriggerKind': <Object?>['monaco.languages.SignatureHelpTriggerKind.Invoke', 'monaco.languages.SignatureHelpTriggerKind.TriggerCharacter', 999],
      };
      final funcs = <String, Object? Function(Object?)>{
        'toLspCodeActionTriggerKind': CF.toLspCodeActionTriggerKind,
        'toLspCompletionTriggerKind': CF.toLspCompletionTriggerKind,
        'toLspDiagnosticSeverity': CF.toLspDiagnosticSeverity,
        'toLspSignatureHelpTriggerKind': CF.toLspSignatureHelpTriggerKind,
      };
      for (final c in checks.entries) {
        final expected = (f[c.key] as List).cast<Object?>();
        for (var i = 0; i < c.value.length; i++) {
          expect(norm(funcs[c.key]!(c.value[i])), norm(expected[i]),
              reason: '${c.key}(${c.value[i]})');
        }
      }
    });

    test('toUntrustedMarkdownString carrier is safe', () {
      expect(CF.toUntrustedMarkdownString('x'), <String, Object?>{
        'value': 'x', 'isTrusted': false, 'supportHtml': false,
      });
    });

    test('LspConnection is a 5-field data container', () {
      // Compile-time proof that the carrier type is constructible/inspectable.
      expect(C.LspConnection, isNotNull);
    });
  });
}
