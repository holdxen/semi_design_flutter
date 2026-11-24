// Truth replay for batch215:
//   `editor/browser/controller/editContext/native/screenReaderUtils.ts`.
//
// The source declares only `IScreenReaderContent`, so the truth
// (`tool/ts2dart/batch215_truth.json`, produced by
// `tool/ts2dart/_batch215_truth.cjs`) records the empty runtime export list,
// the member surface and the member signatures.
//
// NOTE: the file has no official test of its own.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/browser/controller/editContext/native/screenReaderUtils.dart'
    as native;
import '../lib/src/monaco/editor/common/config/editorOptions.dart'
    show IComputedEditorOptions;
import '../lib/src/monaco/editor/common/core/selection.dart' show Selection;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch215_truth.json').readAsStringSync()));

/// Implements every member of [native.IScreenReaderContent]: a missing or
/// mistyped member fails at compile time (the contract check for an
/// interface-only file).
class _FakeScreenReaderContent implements native.IScreenReaderContent {
  final List<String> calls = <String>[];

  @override
  void dispose() => calls.add('dispose');
  @override
  void onWillCut() => calls.add('onWillCut');
  @override
  void onWillPaste() => calls.add('onWillPaste');
  @override
  void onFocusChange(bool newFocusValue) => calls.add('onFocusChange:$newFocusValue');
  @override
  void onConfigurationChanged(IComputedEditorOptions options) =>
      calls.add('onConfigurationChanged');
  @override
  void updateScreenReaderContent(Selection primarySelection) =>
      calls.add('updateScreenReaderContent');
  @override
  void updateScrollTop(Selection primarySelection) => calls.add('updateScrollTop');
}

Selection _selection() => Selection(1, 1, 1, 2);

void main() {
  final Map<String, dynamic> truth = _truth();

  test('batch215 the source has no runtime exports', () {
    expect(truth['exports'], isEmpty);
    expect(truth['interfaceName'], 'IScreenReaderContent');
    expect(native.IScreenReaderContent, isNotNull);
  });

  test('batch215 the interface declares every source member', () {
    final List<String> expected =
        (truth['membersSorted'] as List<dynamic>).cast<String>();
    final List<String> portMembers = <String>[
      'dispose',
      'onWillCut',
      'onWillPaste',
      'onFocusChange',
      'onConfigurationChanged',
      'updateScreenReaderContent',
      'updateScrollTop',
    ]..sort();
    expect(portMembers, expected);
  });

  test('batch215 a full implementation is callable through the interface', () {
    final _FakeScreenReaderContent fake = _FakeScreenReaderContent();
    final native.IScreenReaderContent content = fake;

    content.onWillCut();
    content.onWillPaste();
    content.onFocusChange(true);
    content.updateScreenReaderContent(_selection());
    content.updateScrollTop(_selection());
    content.dispose();

    expect(fake.calls, <String>[
      'onWillCut',
      'onWillPaste',
      'onFocusChange:true',
      'updateScreenReaderContent',
      'updateScrollTop',
      'dispose',
    ]);
    // Signature check derived from the truth table.
    final Map<String, dynamic> signatures = _map(truth['signatures']);
    expect(_map(signatures['onFocusChange'])['params'], 'newFocusValue: boolean');
    expect(_map(signatures['updateScrollTop'])['params'],
        'primarySelection: Selection');
  });
}
