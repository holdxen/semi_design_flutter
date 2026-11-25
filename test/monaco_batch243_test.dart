// 1:1 replay of the OFFICIAL test
// `editor/test/browser/config/fontMeasurements.test.ts` (263 lines).
//
// The official test stubs `CharWidthRequest.prototype.fulfill` with sinon and
// uses fake timers / iframe windows. This port reproduces the same effects with
// the port's seams (`charWidthReader.offsetWidthOverride`, the global
// `fontMeasurements` timer pair, `dom.registerWindow`). Expectations are
// recorded in `tool/ts2dart/batch243_truth.json` by
// `tool/ts2dart/_batch243_truth.cjs`, which runs the same scenarios against the
// real TypeScript sources.
//
// The official `allows closed-window font measurements to be garbage
// collected` test needs `--js-flags=--expose-gc` and a `WeakRef` sweep; it is
// skipped there too when `globalThis.gc` is absent, so it is not replayed.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/browser/dom.dart' as dom;
import '../lib/src/monaco/base/browser/window.dart'
    show CodeWindow, mainWindow;
import '../lib/src/monaco/base/common/lifecycle.dart' as lifecycle;
import '../lib/src/monaco/editor/browser/config/charWidthReader.dart' as reader;
import '../lib/src/monaco/editor/browser/config/fontMeasurements.dart'
    as fontMeasurements;
import '../lib/src/monaco/editor/common/config/editorOptions.dart'
    show EditorFontLigatures;
import '../lib/src/monaco/editor/common/config/fontInfo.dart' as fontInfo;
import '../lib/src/monaco/editor/test/browser/config/fontMeasurements.test.dart'
    as official;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch243_truth.json').readAsStringSync()));

fontInfo.BareFontInfo _bare(String featureSettings, {num fontSize = 14}) =>
    fontInfo.BareFontInfo.create(
        'monospace', 'normal', fontSize.toDouble(), featureSettings,
        'normal', 19, 0, 1, false);

fontInfo.FontInfo _restoredInfo() => fontInfo.FontInfo(
      fontInfo.FontInfoOptions(
        pixelRatio: 1,
        fontFamily: 'monospace',
        fontWeight: 'normal',
        fontSize: 14,
        fontFeatureSettings: '"liga" off, "calt" off',
        fontVariationSettings: 'normal',
        lineHeight: 19,
        letterSpacing: 0,
        isMonospace: true,
        typicalHalfwidthCharacterWidth: 8,
        typicalFullwidthCharacterWidth: 14,
        canUseHalfwidthRightwardsArrow: true,
        spaceWidth: 8,
        middotWidth: 8,
        wsmiddotWidth: 14,
        maxDigitWidth: 8,
      ),
      false,
    );

void main() {
  final Map<String, dynamic> truth = _truth();

  final List<({int handle, void Function() callback, num ms})> scheduled =
      <({int handle, void Function() callback, num ms})>[];
  int nextTimer = 1;
  num widthFactor = 8;

  setUp(() {
    scheduled.clear();
    nextTimer = 1;
    widthFactor = 8;
    fontMeasurements.setTimeoutOverride = (void Function() callback, num ms) {
      final int handle = nextTimer++;
      scheduled.add((handle: handle, callback: callback, ms: ms));
      return handle;
    };
    fontMeasurements.clearTimeoutOverride = (int handle) {};
    reader.offsetWidthOverride = (dom.DomElement element) =>
        element.textContent.length * widthFactor;
  });

  tearDown(() {
    fontMeasurements.setTimeoutOverride = null;
    fontMeasurements.clearTimeoutOverride = null;
    reader.offsetWidthOverride = null;
  });

  test('batch243 the ported official suite runs to completion', () {
    expect(official.runAll, returnsNormally);
  });

  test('batch243 classifies ligatures exactly like the official suite', () {
    final List<dynamic> cases = truth['ligature'] as List<dynamic>;
    expect(cases.length, 20);

    for (final dynamic raw in cases) {
      final Map<String, dynamic> entry = _map(raw);
      final String probe = entry['probe'] as String;
      final num delta = entry['delta'] as num;
      final List<String> measuredLigatures = <String>[];

      // Official helper: width = 8 * chr.length + (chr === probe ? delta : 0).
      reader.offsetWidthOverride = (dom.DomElement element) {
        final String text = element.textContent;
        final String chr = text.isEmpty
            ? ''
            : text.substring(0, text.length ~/ 256);
        if (chr.length > 1) measuredLigatures.add(chr);
        final num width = 8 * chr.length + (chr == probe ? delta : 0);
        return width * 256;
      };

      final fontMeasurements.FontMeasurementsImpl impl =
          fontMeasurements.FontMeasurementsImpl();
      final fontInfo.FontInfo info = impl.readFontInfo(dom.windowCarrier(mainWindow),
          _bare(EditorFontLigatures.ON));
      expect(info.isMonospace, entry['isMonospace'],
          reason: 'probe=$probe delta=$delta');
      expect(measuredLigatures, _list(entry['measuredLigatures']),
          reason: 'probe=$probe delta=$delta');
      impl.dispose();
    }
  });

  test('batch243 releases readings for unregistered windows only', () {
    final Map<String, dynamic> expected = _map(_map(truth['scenarios'])['releasedReadings']);
    final fontMeasurements.FontMeasurementsImpl impl =
        fontMeasurements.FontMeasurementsImpl();

    final CodeWindow auxiliaryWindow = CodeWindow(Object(), 999);
    final lifecycle.IDisposable registration =
        dom.registerWindow(auxiliaryWindow);
    final dom.DomWindowCarrier main = dom.windowCarrier(mainWindow);
    final dom.DomWindowCarrier auxiliary = dom.windowCarrier(auxiliaryWindow);

    final fontInfo.FontInfo mainFont = impl.readFontInfo(main, _restoredInfo());
    final fontInfo.FontInfo auxiliaryFont =
        impl.readFontInfo(auxiliary, _restoredInfo());
    expect(auxiliaryFont.isTrusted, expected['auxiliaryTrusted']);

    registration.dispose(); // fires `onDidUnregisterWindow`

    expect(
        impl
            .serializeFontInfo(main)!
            .map((fontInfo.FontInfo i) => i.getId())
            .toList(),
        _exp(expected['live']));
    expect(identical(impl.readFontInfo(main, _restoredInfo()), mainFont),
        expected['liveCachePreserved']);
    impl.dispose();
  });

  test('batch243 does not emit a delayed change for an unregistered window', () {
    final Map<String, dynamic> expected =
        _map(_map(truth['scenarios'])['noDelayedChange']);
    final fontMeasurements.FontMeasurementsImpl impl =
        fontMeasurements.FontMeasurementsImpl();

    final CodeWindow auxiliaryWindow = CodeWindow(Object(), 999);
    final lifecycle.IDisposable registration =
        dom.registerWindow(auxiliaryWindow);
    int changes = 0;
    impl.onDidChange((dynamic _) => changes++);
    impl.restoreFontInfo(dom.windowCarrier(auxiliaryWindow), <fontInfo.FontInfo>[_restoredInfo()]);
    registration.dispose();
    for (final timer in scheduled.toList()) {
      timer.callback();
    }

    expect(changes, expected['changes']);
    impl.dispose();
  });

  test('batch243 keeps restored untrusted information through eviction', () {
    final Map<String, dynamic> expected =
        _map(_map(truth['scenarios'])['restoredUntrusted']);
    final fontMeasurements.FontMeasurementsImpl impl =
        fontMeasurements.FontMeasurementsImpl();
    final dom.DomWindowCarrier main = dom.windowCarrier(mainWindow);

    final int initiallySerialized = impl.serializeFontInfo(main)!.length;
    int changeCount = 0;
    impl.onDidChange((dynamic _) => changeCount++);

    impl.restoreFontInfo(main, <fontInfo.FontInfo>[_restoredInfo()]);
    final bool isTrusted = impl.readFontInfo(main, _restoredInfo()).isTrusted;
    final List<fontInfo.FontInfo>? beforeEviction = impl.serializeFontInfo(main);

    for (final timer in scheduled.toList()) {
      timer.callback();
    }

    final List<fontInfo.FontInfo>? afterEviction = impl.serializeFontInfo(main);
    final int changeCountAfterEviction = changeCount;

    impl.clearAllFontInfos();

    expect(
        <String, Object?>{
          'initiallySerialized': initiallySerialized,
          'isTrusted': isTrusted,
          'serializedBeforeEviction':
              beforeEviction == null ? null : _ids(beforeEviction),
          'serializedAfterEviction':
              afterEviction == null ? null : _ids(afterEviction),
          'changeCountAfterEviction': changeCountAfterEviction,
          'serializedAfterClear': impl.serializeFontInfo(main)!.length,
        },
        _exp(<String, Object?>{
          'initiallySerialized': expected['initiallySerialized'],
          'isTrusted': expected['isTrusted'],
          'serializedBeforeEviction': expected['serializedBeforeEviction'],
          'serializedAfterEviction': expected['serializedAfterEviction'],
          'changeCountAfterEviction': expected['changeCountAfterEviction'],
          'serializedAfterClear': expected['serializedAfterClear'],
        }));
    impl.dispose();
  });

  test('batch243 serializes empty current-session failed measurements', () {
    final Map<String, dynamic> expected =
        _map(_map(truth['scenarios'])['emptyFailed']);
    final fontMeasurements.FontMeasurementsImpl impl =
        fontMeasurements.FontMeasurementsImpl();
    final dom.DomWindowCarrier main = dom.windowCarrier(mainWindow);

    // Unreadable layout: every measurement is 0.5 (Bug 14341 fallback).
    widthFactor = 0.5;
    final fontInfo.FontInfo info =
        impl.readFontInfo(main, _bare(EditorFontLigatures.OFF, fontSize: 0));

    expect(info.isTrusted, expected['isTrusted']);
    expect(impl.serializeFontInfo(main)!.length, expected['serializedLength']);
    impl.dispose();
  });
}

List<dynamic> _list(dynamic value) => value as List<dynamic>;

Matcher _exp(dynamic value) => value == null ? isNull : equals(value);

List<String> _ids(List<fontInfo.FontInfo> infos) =>
    infos.map((fontInfo.FontInfo i) => i.getId()).toList();
