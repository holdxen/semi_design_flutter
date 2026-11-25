// 1:1 replay of
// `editor/contrib/dropOrPasteInto/browser/pasteEditSession.ts` (22 lines).
//
// Truth: `tool/ts2dart/_batch328_truth.cjs` -> `batch328_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/lifecycle.dart' show IDisposable;
import '../lib/src/monaco/editor/contrib/dropOrPasteInto/browser/pasteEditSession.dart'
    as session;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch328_truth.json').readAsStringSync()));

class _CountingDisposable implements IDisposable {
  static int disposals = 0;

  @override
  void dispose() => disposals += 1;
}

void main() {
  final truth = _truth();
  final edits = <Map<String, Object?>>[
    <String, Object?>{'title': 'edit', 'insertText': 'x'},
  ];

  setUp(() => _CountingDisposable.disposals = 0);

  test('edits are kept by reference and dispose releases the payload', () {
    expect(truth['editsAreKeptByReference'], isTrue);
    final probe = session.PasteEditSession<Map<String, Object?>>(
        edits, _CountingDisposable());
    expect(identical(probe.edits, edits), isTrue);

    _CountingDisposable.disposals = 0;
    session.PasteEditSession<Map<String, Object?>>(edits, _CountingDisposable())
        .dispose();
    expect(_CountingDisposable.disposals,
        _map(truth['disposeReleases'])['disposals']);

    _CountingDisposable.disposals = 0;
    session.PasteEditSession<Map<String, Object?>>(edits, null).dispose();
    expect(_CountingDisposable.disposals,
        _map(truth['disposeWithoutDisposables'])['disposals']);
  });

  test('take() transfers ownership away from the original session', () {
    final expected = _map(truth['takeTransfersOwnership']);
    final result = _map(expected['result']);

    final a = session.PasteEditSession<Map<String, Object?>>(
        edits, _CountingDisposable());
    final b = a.take();
    expect(identical(b.edits, edits), result['editsShared']);

    a.dispose();
    expect(_CountingDisposable.disposals, result['afterOriginal']);

    b.dispose();
    expect(_CountingDisposable.disposals, expected['disposals']);
  });

  test('take() can be chained; only the last owner releases', () {
    final expected = _map(truth['takeTwice']);
    final result = _map(expected['result']);
    _CountingDisposable.disposals = 0;

    final a = session.PasteEditSession<Map<String, Object?>>(
        edits, _CountingDisposable());
    final b = a.take();
    final c = b.take();
    expect(identical(c.edits, edits), result['editsShared']);

    a.dispose();
    b.dispose();
    expect(_CountingDisposable.disposals, result['beforeFinal']);

    c.dispose();
    expect(_CountingDisposable.disposals, expected['disposals']);
  });

  test('the session exposes dispose() and take()', () {
    final probe =
        session.PasteEditSession<Object?>([], null);
    expect(truth['isDisposable'], isTrue);
    expect(probe, isA<IDisposable>());
    expect(probe.take, isNotNull);
  });
}
