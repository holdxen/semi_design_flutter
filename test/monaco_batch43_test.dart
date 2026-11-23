import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/lsp/types.dart' as T;

/// batch43: 1:1 port of the generated LSP 3.17 protocol declaration file
/// (monaco-lsp-client/src/types.ts -> lib/src/monaco/lsp/types.dart).
/// Full symbol/value truth is verified by tool/ts2dart/verify_lsp_types.py
/// (TS runtime truth byte-compared against the Dart source). These tests
/// compile-time import and assert representative runtime constants.
void main() {
  group('batch43 / LSP types 1:1', () {
    test('string enums keep exact values', () {
      expect(T.SemanticTokenTypes.namespace, 'namespace');
      expect(T.SemanticTokenTypes.typeParameter, 'typeParameter');
      expect(T.SemanticTokenTypes.function_, 'function'); // Dart reserved word -> `_`
      expect(T.SemanticTokenTypes.operator_, 'operator');
      expect(T.SemanticTokenModifiers.defaultLibrary, 'defaultLibrary');
      expect(T.MarkupKind.PlainText, 'plaintext');
      expect(T.MarkupKind.Markdown, 'markdown');
      expect(T.PositionEncodingKind.UTF16, 'utf-16');
      expect(T.CodeActionKind.QuickFix, 'quickfix');
      expect(T.CodeActionKind.Empty, '');
      expect(T.TokenFormat.Relative, 'relative');
    });

    test('numeric enums keep exact values (negative + boundary)', () {
      expect(T.ErrorCodes.ParseError, -32700);
      expect(T.ErrorCodes.InvalidRequest, -32600);
      expect(T.ErrorCodes.ServerNotInitialized, -32002);
      expect(T.LSPErrorCodes.RequestFailed, -32803);
      expect(T.SymbolKind.File, 1);
      expect(T.SymbolKind.TypeParameter, 26);
      expect(T.CompletionItemKind.Text, 1);
      expect(T.CompletionItemKind.TypeParameter, 25);
      expect(T.DiagnosticSeverity.Error, 1);
      expect(T.TextDocumentSyncKind.None, 0);
      expect(T.FoldingRangeKind.Comment, 'comment');
    });

    test('capabilities map: key -> method string', () {
      expect(T.capabilities.length, 48);
      expect(T.capabilities['textDocumentImplementation']!.method, 'textDocument/implementation');
      expect(T.capabilities['textDocumentCompletion']!.method, 'textDocument/completion');
      expect(T.capabilities['workspaceExecuteCommand']!.method, 'workspace/executeCommand');
      expect(T.capabilities['textDocumentRangesFormatting']!.method, 'textDocument/rangesFormatting');
      expect(T.capabilities['workspaceDidChangeWatchedFiles']!.method, 'workspace/didChangeWatchedFiles');
    });

    test('api contract: name, server/client split, kind + optional flags', () {
      expect(T.api.name, 'LSP');
      expect(T.api.server.length, 74);
      expect(T.api.client.length, 21);

      final impl = T.api.server['textDocumentImplementation']!;
      expect(impl.method, 'textDocument/implementation');
      expect(impl.isNotification, false);
      expect(impl.optional, false);

      final showReq = T.api.client['windowShowMessageRequest']!;
      expect(showReq.method, 'window/showMessageRequest');
      expect(showReq.optional, true);

      final showMsg = T.api.client['windowShowMessage']!;
      expect(showMsg.method, 'window/showMessage');
      expect(showMsg.isNotification, true);
      expect(showMsg.optional, false);

      final setTrace = T.api.server['setTrace']!;
      expect(setTrace.method, r'$/setTrace');
      expect(setTrace.isNotification, true);

      final progress = T.api.client['progress']!;
      expect(progress.method, r'$/progress');
      expect(progress.isNotification, true);
    });

    test('Capability<T> generic carrier + typedef aliases compile', () {
      const cap = T.Capability<int>('x/y');
      expect(cap.method, 'x/y');
      // typedefs are type-only; referencing them in a typed local proves presence.
      T.ProgressToken p = 5;
      T.ChangeAnnotationIdentifier id_ = 'anno';
      T.DocumentSelector sel = <T.DocumentFilter>[];
      expect(p, 5);
      expect(id_, 'anno');
      expect(sel, isEmpty);
    });

    test('abstract class interface carriers are referencable as types', () {
      T.Location? loc;
      T.ServerCapabilities? caps;
      T.ClientCapabilities? cc;
      T.TextDocumentItem? item;
      expect(loc, isNull);
      expect(caps, isNull);
      expect(cc, isNull);
      expect(item, isNull);
    });
  });
}
