// 1:1 replay of
//   `editor/browser/controller/editContext/native/nativeEditContextRegistry.ts` (27 lines),
//   `editor/browser/controller/editContext/textArea/textAreaEditContextRegistry.ts` (27 lines).
// Truth: `tool/ts2dart/_batch333_truth.cjs` -> `batch333_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/lifecycle.dart' show IDisposable;
import '../lib/src/monaco/editor/browser/controller/editContext/native/nativeEditContextRegistry.dart';
import '../lib/src/monaco/editor/browser/controller/editContext/textArea/textAreaEditContextRegistry.dart';

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(
  jsonDecode(File('tool/ts2dart/batch333_truth.json').readAsStringSync()),
);

class _Entry {
  _Entry(this.name);
  final String name;
}

String? _nameOf(Object? value) => value == null ? null : (value as _Entry).name;

Map<String, Object?> _sequence({
  required IDisposable Function(String, Object) register,
  required Object? Function(String) get,
}) {
  final a = _Entry('a');
  final b = _Entry('b');
  final c = _Entry('c');
  final out = <String, Object?>{};
  out['missingBefore'] = _nameOf(get('owner1'));
  final IDisposable d1 = register('owner1', a);
  out['afterRegister'] = _nameOf(get('owner1'));
  register('owner1', b);
  out['afterOverwrite'] = _nameOf(get('owner1'));
  final IDisposable d2 = register('owner2', c);
  out['owner2'] = _nameOf(get('owner2'));
  d1.dispose();
  out['owner1AfterStaleDispose'] = _nameOf(get('owner1'));
  out['owner2AfterOwner1Dispose'] = _nameOf(get('owner2'));
  d2.dispose();
  out['owner2AfterDispose'] = _nameOf(get('owner2'));
  try {
    d2.dispose();
    out['disposeTwice'] = 'ok';
  } catch (_) {
    out['disposeTwice'] = 'threw';
  }
  d1.dispose();
  out['afterSecondStaleDispose'] = _nameOf(get('owner1'));
  out['caseSensitive'] = _nameOf(get('Owner1'));
  return out;
}

void main() {
  final truth = _truth();

  test('NativeEditContextRegistry mirrors register/get/dispose semantics', () {
    final actual = _sequence(
      register: NativeEditContextRegistry.register,
      get: NativeEditContextRegistry.get,
    );
    expect(actual, _map(truth['native']));
  });

  test(
    'TextAreaEditContextRegistry mirrors register/get/dispose semantics',
    () {
      final actual = _sequence(
        register: TextAreaEditContextRegistry.register,
        get: TextAreaEditContextRegistry.get,
      );
      expect(actual, _map(truth['textArea']));
    },
  );
}
