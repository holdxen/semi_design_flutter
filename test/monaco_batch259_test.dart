/// Replay test for batch259 — monospaceLineBreaksComputer.ts.
///
/// All inputs and expected values come from `batch259_truth.json`, produced by
/// the real TypeScript module via recursive transpile (zero stubs).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/config/fontInfo.dart';
import '../lib/src/monaco/editor/common/modelLineProjectionData.dart';
import '../lib/src/monaco/editor/common/textModelEvents.dart';
import '../lib/src/monaco/editor/common/viewModel/monospaceLineBreaksComputer.dart';

Map<String, dynamic> _loadTruth() {
  final f = File('tool/ts2dart/batch259_truth.json');
  return jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
}

/// Build the same FontInfo the upstream test uses.
FontInfo _fontInfo(num columnsForFullWidthChar) => FontInfo(
      FontInfoOptions(
        pixelRatio: 1,
        fontFamily: 'testFontFamily',
        fontWeight: 'normal',
        fontSize: 14,
        fontFeatureSettings: '',
        fontVariationSettings: '',
        lineHeight: 19,
        letterSpacing: 0,
        isMonospace: true,
        typicalHalfwidthCharacterWidth: 7,
        typicalFullwidthCharacterWidth: (7 * columnsForFullWidthChar).toDouble(),
        canUseHalfwidthRightwardsArrow: true,
        spaceWidth: 7,
        middotWidth: 7,
        wsmiddotWidth: 7,
        maxDigitWidth: 7,
      ),
      false,
    );

List<LineInjectedText>? _buildInjected(dynamic raw) {
  if (raw == null) return null;
  return (raw as List).map((e) {
    final m = e as Map<String, dynamic>;
    return LineInjectedText(
      (m['ownerId'] as num).toInt(),
      (m['lineNumber'] as num).toInt(),
      (m['column'] as num).toInt(),
      Map<String, dynamic>.from(m['options'] as Map),
      (m['order'] as num).toInt(),
    );
  }).toList();
}

/// Build a ModelLineProjectionData from a projected truth `data` map, used for
/// `prevRef` chaining (source tests clone with null injectionOptions).
ModelLineProjectionData? _fromProjected(dynamic raw) {
  if (raw == null) return null;
  final m = raw as Map<String, dynamic>;
  final inj = m['injectionOffsets'] as List?;
  return ModelLineProjectionData(
    inj == null
        ? null
        : inj.map((e) => (e as num).toInt()).toList(),
    null,
    (m['breakOffsets'] as List).map((e) => (e as num).toInt()).toList(),
    (m['breakOffsetsVisibleColumn'] as List).map((e) => e as num).toList(),
    m['wrappedTextIndentLength'] as num,
  );
}

List<num> _numList(dynamic raw) =>
    (raw as List).map((e) => e as num).toList();

void _expectData(
  ModelLineProjectionData? actual,
  Map<String, dynamic>? expected,
  String reason,
) {
  if (expected == null) {
    expect(actual, isNull, reason: '$reason data should be null');
    return;
  }
  expect(actual, isNotNull, reason: '$reason data should not be null');
  expect(actual!.breakOffsets,
      (expected['breakOffsets'] as List).map((e) => (e as num).toInt()).toList(),
      reason: '$reason breakOffsets');
  final expVc = _numList(expected['breakOffsetsVisibleColumn']);
  final actVc = actual.breakOffsetsVisibleColumn;
  expect(actVc.length, expVc.length, reason: '$reason visibleColumn length');
  for (var i = 0; i < expVc.length; i++) {
    expect((actVc[i] - expVc[i]).abs() < 0.001, isTrue,
        reason: '$reason visibleColumn[$i]: ${actVc[i]} vs ${expVc[i]}');
  }
  expect((actual.wrappedTextIndentLength -
              (expected['wrappedTextIndentLength'] as num))
          .abs() <
      0.001, isTrue,
      reason:
          '$reason indent: ${actual.wrappedTextIndentLength} vs ${expected['wrappedTextIndentLength']}');
}

String _annotated(String text, ModelLineProjectionData? data) {
  if (data == null) return text;
  var actual = '';
  var prev = 0;
  for (var i = 0; i < text.length; i++) {
    final r = data.translateToOutputPosition(i);
    if (prev != r.outputLineIndex) {
      prev = r.outputLineIndex;
      actual += '|';
    }
    actual += text[i];
  }
  return actual;
}

void main() {
  final truth = _loadTruth();

  group('monaco batch259 — monospaceLineBreaksComputer replay', () {
    // Cases execute in truth order so `prevRef` can reference earlier results.
    for (final rawCase in (truth['cases'] as List)) {
      final c = rawCase as Map<String, dynamic>;
      final label = c['label'] as String;

      test(label, () {
        // A mutable registry of projected results for prevRef chaining.
        final registry = <String, dynamic>{};
        // Re-execute all cases up to and including this one, so that any
        // prevRef target is available. (We only assert on the target case.)
        for (final raw in (truth['cases'] as List)) {
          final cc = raw as Map<String, dynamic>;
          final l = cc['label'] as String;
          if (cc['kind'] == 'variants') {
            final firstResult = <String, dynamic>{};
            for (final vr in (cc['variants'] as List)) {
              final v = vr as Map<String, dynamic>;
              final text = v['text'] as String? ?? cc['text'] as String? ?? '';
              final data = _runOne(cc, v, text, registry);
              if (firstResult.isEmpty) {
                firstResult['data'] = _project(data);
              }
            }
            registry[l] = firstResult['data'];
            if (l == label) {
              // Assert variants for the target case.
              for (final vr in (cc['variants'] as List)) {
                final v = vr as Map<String, dynamic>;
                final text = v['text'] as String? ?? cc['text'] as String? ?? '';
                final data = _runOne(cc, v, text, registry);
                _expectData(data, v['data'] as Map<String, dynamic>?, '[$l]');
                if (v['expectedAnnot'] != null) {
                  expect(_annotated(text, data), v['expectedAnnot'],
                      reason: '[$l] annotated');
                }
                if (v['expectedCols'] != null) {
                  expect(
                      data!.breakOffsetsVisibleColumn
                          .map((e) => e.toInt())
                          .toList(),
                      (v['expectedCols'] as List)
                          .map((e) => (e as num).toInt())
                          .toList(),
                      reason: '[$l] visibleColumn');
                }
                if (v['expectedIndent'] != null) {
                  expect(data!.wrappedTextIndentLength.toInt(),
                      (v['expectedIndent'] as num).toInt(),
                      reason: '[$l] indent');
                }
              }
            }
            continue;
          }

          final text = cc['text'] as String;
          final data = _runOne(cc, null, text, registry);
          registry[l] = _project(data);
          if (l == label) {
            _expectData(data, cc['data'] as Map<String, dynamic>?, '[$l]');
            if (cc['annotated'] != null) {
              expect(_annotated(text, data), cc['annotated'],
                  reason: '[$l] annotated');
            }
          }
        }
      });
    }
  });
}

Map<String, dynamic> _project(ModelLineProjectionData? data) => {
      'breakOffsets': data?.breakOffsets ?? [],
      'breakOffsetsVisibleColumn': data?.breakOffsetsVisibleColumn ?? [],
      'wrappedTextIndentLength': data?.wrappedTextIndentLength ?? 0,
      'injectionOffsets': data?.injectionOffsets,
    };

ModelLineProjectionData? _runOne(
  Map<String, dynamic> cfg,
  Map<String, dynamic>? override,
  String text,
  Map<String, dynamic> registry,
) {
  final before = cfg['before'] as String;
  final after = cfg['after'] as String;
  final tabSize = (cfg['tabSize'] as num).toInt();
  final breakAfterRaw = override?['breakAfter'] ?? cfg['breakAfter'];
  final breakAfter = (breakAfterRaw as num?)?.toInt() ?? 0;
  final columns = ((override != null ? override['columns'] : null) ??
          cfg['columnsForFullWidthChar']) as num;
  final indent =
      ((override != null ? override['indent'] : null) ?? cfg['wrappingIndent'])
          as int;
  final wordBreak = cfg['wordBreak'] as String;
  final escaped = cfg['wrapOnEscapedLineFeeds'] as bool;
  final twoCell = ((override != null ? override['twoCell'] : null) ??
      cfg['useTwoCell']) as bool;
  final injected = _buildInjected(cfg['injectedText']);

  ModelLineProjectionData? previous;
  final prevRef = cfg['prevRef'] as String?;
  if (prevRef != null && prevRef.startsWith('result:')) {
    previous = _fromProjected(registry[prevRef.substring('result:'.length)]);
  }

  final context = _Context(text, injected);
  final factory = MonospaceLineBreaksComputerFactory(before, after);
  final computer = factory.createLineBreaksComputer(
    context,
    _fontInfo(columns),
    tabSize,
    breakAfter,
    indent,
    wordBreak,
    escaped,
    twoCell,
  );
  computer.addRequest(1, previous);
  return computer.finalize()[0];
}

class _Context implements ILineBreaksComputerContext {
  final String _text;
  final List<LineInjectedText>? _injected;
  _Context(this._text, this._injected);

  @override
  String getLineContent(int lineNumber) => _text;

  @override
  List<LineInjectedText>? getLineInjectedText(int lineNumber) => _injected;
}
