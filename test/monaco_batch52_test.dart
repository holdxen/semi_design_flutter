// batch52 truth test: monaco/src/index.ts + monaco-lsp-client/src/index.ts
// facade port. Verifies the public surface (re-exports + external carriers) is
// present and that injected transport carriers round-trip 1:1.
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/index.dart' as monaco;
import 'package:semi_design_flutter/src/monaco/lsp/index.dart' as lsp;
import 'package:semi_design_flutter/src/monaco/lsp/adapters/LspClient.dart';

void main() {
  setUp(() {
    lsp.WebSocketTransport = null;
    lsp.createTransportToWorker = null;
    lsp.createTransportToIFrame = null;
  });

  test('T1: lsp/index re-exports MonacoLspClient + options', () {
    expect(lsp.MonacoLspClient, MonacoLspClient);
    const opts = MonacoLspClientOptions(allowedLocalCommands: ['x']);
    expect(opts.allowedLocalCommands, ['x']);
  });

  test('T2: lsp/index external transport carriers are injectable', () {
    final sock = Object();
    final worker = Object();
    final iframe = Object();
    lsp.WebSocketTransport = (s) => s;
    lsp.createTransportToWorker = (w) => w;
    lsp.createTransportToIFrame = (i) => i;

    expect(lsp.WebSocketTransport!(sock), same(sock));
    expect(lsp.createTransportToWorker!(worker), same(worker));
    expect(lsp.createTransportToIFrame!(iframe), same(iframe));
  });

  test('T3: monaco/index re-exports editor + lsp facade and holds carriers', () {
    // editor.dart is a real re-export target of monaco/index.dart.
    expect(monaco.lsp, isA<Map<String, Object?>>());
    expect(monaco.lsp['MonacoLspClient'], MonacoLspClient);
    // language contribution carriers start null and are overridable.
    expect(monaco.css, isNull);
    monaco.css = Object();
    expect(monaco.css, isNotNull);
  });
}
