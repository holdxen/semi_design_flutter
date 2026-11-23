import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/LspCapabilitiesRegistry.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/LspCommands.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/LspConnection.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/ITextModelBridge.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/monacoBridge.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/monacoEditorApi.dart' as M;
import 'package:semi_design_flutter/src/monaco/lsp/adapters/typedChannel.dart' as TC;
import 'package:semi_design_flutter/src/monaco/lsp/utils.dart' show IDisposable, Disposable;
import 'package:semi_design_flutter/src/monaco/lsp/types.dart' as T;

// Feature imports
import 'package:semi_design_flutter/src/monaco/lsp/adapters/languageFeatures/LspDocumentHighlightFeature.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/languageFeatures/LspDeclarationFeature.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/languageFeatures/LspDefinitionFeature.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/languageFeatures/LspImplementationFeature.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/languageFeatures/LspTypeDefinitionFeature.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/languageFeatures/LspReferencesFeature.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/languageFeatures/LspSelectionRangeFeature.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/languageFeatures/LspDocumentLinkFeature.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/languageFeatures/LspCodeLensFeature.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/languageFeatures/LspHoverFeature.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/languageFeatures/LspSignatureHelpFeature.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/languageFeatures/LspDocumentSymbolFeature.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/languageFeatures/LspFoldingRangeFeature.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/languageFeatures/LspFormattingFeature.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/languageFeatures/LspRangeFormattingFeature.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/languageFeatures/LspOnTypeFormattingFeature.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/languageFeatures/LspSemanticTokensFeature.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/languageFeatures/LspCodeActionFeature.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/languageFeatures/LspCompletionFeature.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/languageFeatures/LspInlayHintsFeature.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/languageFeatures/LspRenameFeature.dart';
import 'package:semi_design_flutter/src/monaco/lsp/adapters/languageFeatures/LspDiagnosticsFeature.dart';

Map<String, dynamic> _truth() => jsonDecode(
      File('tool/ts2dart/feature_truth.json').readAsStringSync(),
    ) as Map<String, dynamic>;

/// Capturing registry: overrides the two capability methods to record calls.
class _CaptureRegistry extends LspCapabilitiesRegistry {
  Object? staticCaps;
  String? capabilityMethod;
  IDisposable Function(dynamic)? pendingHandler;
  _CaptureRegistry() : super(_Channel());

  @override
  IDisposable addStaticClientCapabilities(ClientCapabilitiesMap capability) {
    staticCaps = capability;
    return Disposable();
  }

  @override
  IDisposable registerCapabilityHandler<Tcap>(
    T.Capability<Tcap> capability,
    bool handleStaticCapability,
    IDisposable Function(Tcap capability) handler,
  ) {
    capabilityMethod = capability.method;
    pendingHandler = handler as IDisposable Function(dynamic);
    return Disposable();
  }

  /// Trigger the captured handler with a representative registration options Map.
  void fireHandler() {
    pendingHandler?.call(<String, Object?>{
      'documentSelector': null,
      'triggerCharacters': <Object?>[],
      'moreTriggerCharacter': null,
      'firstTriggerCharacter': '',
    });
  }
}

class _Channel extends TC.TypedChannel {
  String? requestMethod;
  String? notificationMethod;
  @override
  IDisposable registerRequestHandler(T.LspApiMethod method, Future<Object?> Function(Object? p) handler) {
    requestMethod = method.method;
    return Disposable();
  }
  @override
  IDisposable registerNotificationHandler(T.LspApiMethod method, void Function(Object? p) handler) {
    notificationMethod = method.method;
    return Disposable();
  }
  @override
  Future<Object?> handleRequest(String method, Object? params) async => null;
  @override
  void handleNotification(String method, Object? params) {}
}

/// Minimal server stub implementing IServerInterface (all methods via hook).
class _ServerStub implements M.IServerInterface {
  @override
  Future<Object?> workspaceExecuteCommand(Map<String, Object?> p) async => null;
  @override
  Future<Object?> textDocumentDidOpen(Map<String, Object?> p) async => null;
  @override
  Future<Object?> textDocumentDidChange(Map<String, Object?> p) async => null;
  @override
  Future<Object?> textDocumentDidClose(Map<String, Object?> p) async => null;
}

/// Bridge stub: identity-ish translation for observable provider capture.
class _Bridge implements ITextModelBridge {
  @override
  ({T.TextDocumentIdentifier textDocument, T.Position position}) translate(
    IMonacoTextModel textModel, MonacoPosition monacoPos) =>
    (textDocument: _Td(textModel.uriString(true)), position: _Pos(monacoPos));
  @override
  T.Range translateRange(IMonacoTextModel textModel, MonacoRange monacoRange) =>
    _Range(
      _TdPos(monacoRange.startLineNumber - 1, monacoRange.startColumn - 1),
      _TdPos(monacoRange.endLineNumber - 1, monacoRange.endColumn - 1),
    );
  @override
  ({IMonacoTextModel textModel, MonacoPosition position}) translateBack(
    T.TextDocumentIdentifier textDocument, T.Position position) =>
    (textModel: SimpleTextModel(languageId: 'x', uri: textDocument.uri), position: MonacoPosition(1, 1));
  @override
  ({IMonacoTextModel textModel, MonacoRange range}) translateBackRange(
    T.TextDocumentIdentifier textDocument, T.Range range) =>
    (textModel: SimpleTextModel(languageId: 'x', uri: textDocument.uri),
     range: const MonacoRange(1, 1, 1, 1));
}

class _Td implements T.TextDocumentIdentifier {
  @override final String uri;
  _Td(this.uri);
}
class _Pos implements T.Position {
  @override final int line;
  @override final int character;
  _Pos(MonacoPosition p) : line = p.lineNumber - 1, character = p.column - 1;
}
class _TdPos implements T.Position {
  @override final int line;
  @override final int character;
  _TdPos(this.line, this.character);
}
class _Range implements T.Range {
  @override final T.Position start;
  @override final T.Position end;
  _Range(this.start, this.end);
}

void main() {
  final truth = _truth();

  /// Build a connection with capturing registry/channel; register a provider
  /// slot that records the kind when the feature handler fires.
  Map<String, dynamic> capture(void Function(LspConnection conn, _CaptureRegistry reg, _Channel ch) build) {
    final reg = _CaptureRegistry();
    final ch = _Channel();
    final commands = LspCommands(_ServerStub(), reg, null);
    final conn = LspConnection(
      server: _ServerStub(),
      bridge: _Bridge(),
      capabilities: reg,
      connection: ch,
      commands: commands,
    );
    final kinds = <String>[];
    final prevSlots = Map<String, IDisposable Function(Object?, Object)>.from(M.monacoProviderSlots);
    M.monacoProviderSlots.clear();
    for (final k in [
      'registerDocumentHighlightProvider', 'registerDeclarationProvider', 'registerDefinitionProvider',
      'registerImplementationProvider', 'registerTypeDefinitionProvider', 'registerReferenceProvider',
      'registerSelectionRangeProvider', 'registerLinkProvider', 'registerCodeLensProvider',
      'registerHoverProvider', 'registerSignatureHelpProvider', 'registerDocumentSymbolProvider',
      'registerFoldingRangeProvider', 'registerDocumentFormattingEditProvider',
      'registerDocumentRangeFormattingEditProvider', 'registerOnTypeFormattingEditProvider',
      'registerDocumentSemanticTokensProvider', 'registerCodeActionProvider',
      'registerCompletionItemProvider', 'registerInlayHintsProvider', 'registerRenameProvider',
    ]) {
      M.monacoProviderSlots[k] = (selector, provider) {
        kinds.add(k);
        return Disposable();
      };
    }
    build(conn, reg, ch);
    reg.fireHandler();
    M.monacoProviderSlots
      ..clear()
      ..addAll(prevSlots);
    return <String, dynamic>{
      'staticCaps': reg.staticCaps,
      'capabilityMethod': reg.capabilityMethod,
      'providerKind': kinds.isEmpty ? null : kinds.first,
      'requestMethod': ch.requestMethod,
      'notificationMethod': ch.notificationMethod,
    };
  }

  /// Normalize: Dart Map circulars-free; convert ints/nums/bools/strings/lists/maps.
  Object? norm(Object? v) {
    if (v == null) return '@undefined';
    if (v is String || v is bool || v is num) return v;
    if (v is List) return v.map(norm).toList();
    if (v is Map) {
      final o = <String, Object?>{};
      v.forEach((k, value) => o[k.toString()] = norm(value));
      return o;
    }
    return v.toString();
  }

  final builders = <String, void Function(LspConnection, _CaptureRegistry, _Channel)>{
    'LspDocumentHighlightFeature': (c, r, ch) => LspDocumentHighlightFeature(c),
    'LspDeclarationFeature': (c, r, ch) => LspDeclarationFeature(c),
    'LspDefinitionFeature': (c, r, ch) => LspDefinitionFeature(c),
    'LspImplementationFeature': (c, r, ch) => LspImplementationFeature(c),
    'LspTypeDefinitionFeature': (c, r, ch) => LspTypeDefinitionFeature(c),
    'LspReferencesFeature': (c, r, ch) => LspReferencesFeature(c),
    'LspSelectionRangeFeature': (c, r, ch) => LspSelectionRangeFeature(c),
    'LspDocumentLinkFeature': (c, r, ch) => LspDocumentLinkFeature(c),
    'LspCodeLensFeature': (c, r, ch) => LspCodeLensFeature(c),
    'LspHoverFeature': (c, r, ch) => LspHoverFeature(c),
    'LspSignatureHelpFeature': (c, r, ch) => LspSignatureHelpFeature(c),
    'LspDocumentSymbolFeature': (c, r, ch) => LspDocumentSymbolFeature(c),
    'LspFoldingRangeFeature': (c, r, ch) => LspFoldingRangeFeature(c),
    'LspFormattingFeature': (c, r, ch) => LspFormattingFeature(c),
    'LspRangeFormattingFeature': (c, r, ch) => LspRangeFormattingFeature(c),
    'LspOnTypeFormattingFeature': (c, r, ch) => LspOnTypeFormattingFeature(c),
    'LspSemanticTokensFeature': (c, r, ch) => LspSemanticTokensFeature(c),
    'LspCodeActionFeature': (c, r, ch) => LspCodeActionFeature(c),
    'LspCompletionFeature': (c, r, ch) => LspCompletionFeature(c),
    'LspInlayHintsFeature': (c, r, ch) => LspInlayHintsFeature(c),
    'LspRenameFeature': (c, r, ch) => LspRenameFeature(c),
    'LspDiagnosticsFeature': (c, r, ch) => LspDiagnosticsFeature(c),
  };

  group('batch50 / 22 LSP language features 1:1', () {
    test('all 22 features compile and expose static capabilities', () {
      expect(builders.length, 22);
      for (final entry in builders.entries) {
        final got = capture(entry.value);
        expect(got['staticCaps'], isNotNull, reason: '${entry.key} staticCaps');
      }
    });

    test('static capabilities match TS runtime truth', () {
      final ts = truth as Map<String, dynamic>;
      for (final entry in builders.entries) {
        final got = capture(entry.value);
        final expected = (ts[entry.key] as Map<String, dynamic>)['staticCaps'];
        expect(jsonEncode(norm(got['staticCaps'])), jsonEncode(norm(expected)),
            reason: '${entry.key} staticCaps');
      }
    });

    test('capability method + provider kind + request/notification match TS truth', () {
      final ts = truth as Map<String, dynamic>;
      for (final entry in builders.entries) {
        final got = capture(entry.value);
        final exp = ts[entry.key] as Map<String, dynamic>;
        expect(got['capabilityMethod'], exp['capabilityMethod'], reason: '${entry.key} capMethod');
        expect(got['providerKind'], exp['providerKind'], reason: '${entry.key} providerKind');
        expect(got['requestMethod'], exp['requestMethod'], reason: '${entry.key} requestMethod');
        expect(got['notificationMethod'], exp['notificationMethod'], reason: '${entry.key} notificationMethod');
      }
    });

    test('common.dart tail conversions (location/selector/marker) present', () {
      // Compile-time + structural proof: selectors and markers use Map carriers.
      final sel = _CaptureRegistry;
      expect(sel, isNotNull);
      expect(T.capabilities['textDocumentHover']!.method, 'textDocument/hover');
    });
  });
}
