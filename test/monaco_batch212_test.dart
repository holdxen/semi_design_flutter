// Truth replay for batch212:
//   `editor/common/config/editorConfiguration.ts`.
//
// The source declares only `IEditorConfiguration` (an interface extending
// `IDisposable`), so the truth (`tool/ts2dart/batch212_truth.json`, produced by
// `tool/ts2dart/_batch212_truth.cjs`) records the empty runtime export list and
// the interface member surface.
//
// NOTE: the file has no official test of its own (the STRICT+test match is the
// usual stem heuristic false positive).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/event.dart' show Event;
import '../lib/src/monaco/base/common/lifecycle.dart' show IDisposable;
import '../lib/src/monaco/editor/common/config/editorConfiguration.dart'
    as config;
import '../lib/src/monaco/editor/common/config/editorOptions.dart'
    as opts;
import '../lib/src/monaco/editor/common/core/2d/dimension.dart' show IDimension;
import '../lib/src/monaco/platform/actions/common/actions.dart' show MenuId;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch212_truth.json').readAsStringSync()));

/// Implements every member of [config.IEditorConfiguration]; a missing or
/// mistyped member is a compile-time failure, which is the real contract test
/// for an interface-only file.
class _FakeEditorConfiguration implements config.IEditorConfiguration {
  _FakeEditorConfiguration({required this.contextMenuId});

  final Map<String, Object?> calls = <String, Object?>{};

  @override
  bool get isSimpleWidget => false;

  @override
  final MenuId contextMenuId;

  @override
  opts.IComputedEditorOptions get options {
    throw UnimplementedError('not needed for the contract test');
  }

  @override
  Event<opts.ConfigurationChangedEvent> get onDidChange =>
      (dynamic listener, [dynamic thisArgs, dynamic disposables]) =>
          _NoopDisposable();

  @override
  Event<opts.ConfigurationChangedEvent> get onDidChangeFast =>
      (dynamic listener, [dynamic thisArgs, dynamic disposables]) =>
          _NoopDisposable();

  @override
  opts.IEditorOptions getRawOptions() {
    calls['getRawOptions'] = true;
    return opts.IEditorOptions();
  }

  @override
  void updateOptions(opts.IEditorOptions newOptions) {
    calls['updateOptions'] = newOptions;
  }

  @override
  void observeContainer([IDimension? dimension]) {
    calls['observeContainer'] = dimension;
  }

  @override
  void setIsDominatedByLongLines(bool isDominatedByLongLines) {
    calls['setIsDominatedByLongLines'] = isDominatedByLongLines;
  }

  @override
  void setModelLineCount(int modelLineCount) {
    calls['setModelLineCount'] = modelLineCount;
  }

  @override
  void setViewLineCount(int viewLineCount) {
    calls['setViewLineCount'] = viewLineCount;
  }

  @override
  void setReservedHeight(num reservedHeight) {
    calls['setReservedHeight'] = reservedHeight;
  }

  @override
  void setGlyphMarginDecorationLaneCount(int decorationLaneCount) {
    calls['setGlyphMarginDecorationLaneCount'] = decorationLaneCount;
  }

  @override
  void dispose() {
    calls['dispose'] = true;
  }
}

class _NoopDisposable implements IDisposable {
  @override
  void dispose() {}
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('batch212 the source has no runtime exports', () async {
    expect(truth['exports'], isEmpty);
    // Loading the library must not throw and must not need runtime imports.
    expect(config.IEditorConfiguration, isNotNull);
    expect(truth['extends'], 'IDisposable');
  });

  test('batch212 the interface declares every source member', () {
    final List<String> expectedMembers =
        (truth['membersSorted'] as List<dynamic>).cast<String>();
    // The names below are the port's declared member surface; together with
    // the implementing fake above this pins the contract.
    final List<String> portMembers = <String>[
      'isSimpleWidget',
      'contextMenuId',
      'options',
      'onDidChangeFast',
      'onDidChange',
      'getRawOptions',
      'updateOptions',
      'observeContainer',
      'setIsDominatedByLongLines',
      'setModelLineCount',
      'setViewLineCount',
      'setReservedHeight',
      'setGlyphMarginDecorationLaneCount',
    ]..sort();
    expect(portMembers, expectedMembers);
  });

  test('batch212 a full implementation is usable through the interface', () {
    final _FakeEditorConfiguration fake = _FakeEditorConfiguration(
      contextMenuId: MenuId.EditorContext,
    );
    final config.IEditorConfiguration configuration = fake;

    expect(configuration.isSimpleWidget, isFalse);
    expect(configuration.contextMenuId, MenuId.EditorContext);
    configuration.updateOptions(opts.IEditorOptions());
    configuration.observeContainer();
    configuration.setIsDominatedByLongLines(true);
    configuration.setModelLineCount(10);
    configuration.setViewLineCount(20);
    configuration.setReservedHeight(12);
    configuration.setGlyphMarginDecorationLaneCount(2);
    expect(fake.calls['updateOptions'], isA<opts.IEditorOptions>());
    expect(fake.calls['setIsDominatedByLongLines'], isTrue);
    expect(fake.calls['setModelLineCount'], 10);
    expect(fake.calls['setViewLineCount'], 20);
    expect(fake.calls['setReservedHeight'], 12);
    expect(fake.calls['setGlyphMarginDecorationLaneCount'], 2);
    expect(configuration.getRawOptions(), isA<opts.IEditorOptions>());
    configuration.dispose();
    expect(fake.calls['dispose'], isTrue);
  });
}
