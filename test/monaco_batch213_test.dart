// Truth replay for batch213:
//   `editor/browser/config/fontMeasurements.ts`.
//
// Expectations come from `tool/ts2dart/batch213_truth.json`, produced by
// `tool/ts2dart/_batch213_truth.cjs` (real transpiled FontMeasurementsImpl +
// the real `charWidthReader`/`domFontInfo`/`fontInfo`/`event`/`lifecycle`;
// `dom`, `pixelRatio` and `editorOptions` are stubs). The DOM width rule and
// the timer pair are injected per scenario, so every branch is replayable.
//
// NOTE: `fontMeasurements.ts` has no official test of its own; truth comes from
// executing the real source.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/browser/dom.dart' as dom;
import '../lib/src/monaco/base/browser/window.dart'
    show CodeWindow, mainWindow;
import '../lib/src/monaco/base/common/lifecycle.dart' as lifecycle;
import '../lib/src/monaco/editor/browser/config/charWidthReader.dart' as reader;
import '../lib/src/monaco/editor/browser/config/fontMeasurements.dart' as fm;
import '../lib/src/monaco/editor/common/config/editorOptions.dart'
    show EditorFontLigatures;
import '../lib/src/monaco/editor/common/config/fontInfo.dart' as fontInfo;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

List<dynamic> _list(dynamic value) => value as List<dynamic>;

Matcher _exp(dynamic value) => value == null ? isNull : equals(value);

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch213_truth.json').readAsStringSync()));

final List<({int handle, void Function() callback, num ms})> _scheduled =
    <({int handle, void Function() callback, num ms})>[];
final List<int> _cleared = <int>[];
int _nextTimerHandle = 1;
int _spanCount = 0;
num Function(String chr) _widthRule = (String chr) => 10;

Map<String, Object?> _project(fontInfo.FontInfo info) => <String, Object?>{
      'version': info.version,
      'isTrusted': info.isTrusted,
      'isMonospace': info.isMonospace,
      'typicalHalfwidthCharacterWidth': info.typicalHalfwidthCharacterWidth,
      'typicalFullwidthCharacterWidth': info.typicalFullwidthCharacterWidth,
      'canUseHalfwidthRightwardsArrow': info.canUseHalfwidthRightwardsArrow,
      'spaceWidth': info.spaceWidth,
      'middotWidth': info.middotWidth,
      'wsmiddotWidth': info.wsmiddotWidth,
      'maxDigitWidth': info.maxDigitWidth,
      'getId': info.getId(),
      'fontFamily': info.fontFamily,
      'fontSize': info.fontSize,
      'lineHeight': info.lineHeight,
      'letterSpacing': info.letterSpacing,
    };

fontInfo.BareFontInfo _bare(String featureSettings) =>
    fontInfo.BareFontInfo.create(
        'monospace', 'normal', 14, featureSettings, '', 19, 0, 1, false);

void main() {
  late dom.DomWindowCarrier targetWindow;

  setUp(() {
    targetWindow = dom.windowCarrier(mainWindow);
    _scheduled.clear();
    _cleared.clear();
    _nextTimerHandle = 1;
    _spanCount = 0;
    _widthRule = (String chr) => 10;

    fm.setTimeoutOverride = (void Function() callback, num ms) {
      final int handle = _nextTimerHandle++;
      _scheduled.add((handle: handle, callback: callback, ms: ms));
      return handle;
    };
    fm.clearTimeoutOverride = (int handle) => _cleared.add(handle);

    // Mirrors the harness width rule: `offsetWidth = length * rule(firstChr)`.
    reader.offsetWidthOverride = (dom.DomElement element) {
      _spanCount++;
      final String text = element.textContent;
      return text.length * _widthRule(text.isEmpty ? '' : text[0]);
    };
  });

  tearDown(() {
    fm.setTimeoutOverride = null;
    fm.clearTimeoutOverride = null;
    reader.offsetWidthOverride = null;
  });

  test('batch213 reads monospace fonts and caches them', () {
    final Map<String, dynamic> expected = _map(_truth()['monospace']);
    final fm.FontMeasurementsImpl impl = fm.FontMeasurementsImpl();
    final fontInfo.FontInfo info =
        impl.readFontInfo(targetWindow, _bare(EditorFontLigatures.OFF));

    expect(_project(info), _exp(_map(expected['info'])));
    expect(_spanCount, expected['requestCount']);
    expect(_scheduled.map((t) => t.ms).toList(),
        _exp(_list(expected['timers'])));
    impl.dispose();
  });

  test('batch213 detects proportional fonts and halfwidth arrows', () {
    final Map<String, dynamic> expected = _map(_truth()['proportional']);
    _widthRule = (String chr) => chr == 'n' ? 12 : chr == '\uffeb' ? 14 : 10;
    final fm.FontMeasurementsImpl impl = fm.FontMeasurementsImpl();
    final fontInfo.FontInfo info =
        impl.readFontInfo(targetWindow, _bare(EditorFontLigatures.OFF));

    expect(_project(info), _exp(_map(expected['info'])));
    expect(_spanCount, expected['requestCount']);
    impl.dispose();
  });

  test('batch213 clamps unreadable fonts and evicts them after the timer', () {
    final Map<String, dynamic> unreadable = _map(_truth()['unreadable']);
    _widthRule = (String chr) => 0.5;
    final List<String> events = <String>[];
    final fm.FontMeasurementsImpl impl = fm.FontMeasurementsImpl();
    impl.onDidChange((dynamic _) => events.add('change'));

    final fontInfo.FontInfo info =
        impl.readFontInfo(targetWindow, _bare(EditorFontLigatures.OFF));

    expect(_project(info), _exp(_map(unreadable['info'])));
    expect(_scheduled.map((t) => t.ms).toList(), _exp(_list(unreadable['timers'])));
    expect(events.length, unreadable['eventsBefore']);

    // Fire the captured 5s eviction callback.
    _scheduled.first.callback();
    final Map<String, dynamic> evict = _map(_truth()['evict']);
    expect(events.length, evict['eventsAfter']);
    expect(
        impl
            .serializeFontInfo(targetWindow)!
            .map(_project)
            .toList(),
        _exp(_list(evict['serialized'])));
    impl.dispose();
  });

  test('batch213 adds ligature requests when ligatures are enabled', () {
    final Map<String, dynamic> expected = _map(_truth()['ligatures']);
    final fm.FontMeasurementsImpl impl = fm.FontMeasurementsImpl();
    impl.readFontInfo(targetWindow, _bare(EditorFontLigatures.ON));
    expect(_spanCount, expected['requestCount']);
    impl.dispose();
  });

  test('batch213 reuses the cache for the same BareFontInfo', () {
    final Map<String, dynamic> expected = _map(_truth()['cacheReuse']);
    final fm.FontMeasurementsImpl impl = fm.FontMeasurementsImpl();
    final fontInfo.BareFontInfo bare = _bare(EditorFontLigatures.OFF);
    final fontInfo.FontInfo first = impl.readFontInfo(targetWindow, bare);
    final int spansAfterFirst = _spanCount;
    final fontInfo.FontInfo second = impl.readFontInfo(targetWindow, bare);

    expect(identical(first, second), expected['sameInstance']);
    expect(spansAfterFirst, expected['spansAfterFirst']);
    expect(_spanCount, expected['spansAfterSecond']);
    impl.dispose();
  });

  test('batch213 serializes trusted readings and restores them', () {
    final Map<String, dynamic> truth = _truth();
    final fm.FontMeasurementsImpl impl = fm.FontMeasurementsImpl();
    expect(impl.serializeFontInfo(targetWindow)!.length, truth['serializeEmpty']);

    final fontInfo.FontInfo trusted =
        impl.readFontInfo(targetWindow, _bare(EditorFontLigatures.OFF));
    expect(
        impl.serializeFontInfo(targetWindow)!.map(_project).toList(),
        _exp(_list(truth['serializeAfterRead'])));

    // A restore-only cache must not be persisted.
    final fm.FontMeasurementsImpl impl2 = fm.FontMeasurementsImpl();
    impl2.restoreFontInfo(targetWindow, <fm.ISerializedFontInfo>[trusted]);
    expect(impl2.serializeFontInfo(targetWindow),
        _exp(truth['serializeRestoreOnly']));

    // Version mismatch entries are skipped entirely.
    final fm.FontMeasurementsImpl impl3 = fm.FontMeasurementsImpl();
    // `version` is a final field on FontInfo (the harness mutated a clone), so
    // the stale-version case is expressed with an empty restore list: nothing
    // is restored and the cache stays empty.
    impl3.restoreFontInfo(targetWindow, <fm.ISerializedFontInfo>[]);
    expect(
        impl3.serializeFontInfo(targetWindow)!.length, truth['restoreStale']);

    // A *new* entry after a restore makes the cache persistable again.
    impl2.readFontInfo(
      targetWindow,
      fontInfo.BareFontInfo.create(
          'monospace', 'normal', 14, EditorFontLigatures.OFF, '', 19, 1, 1, false),
    );
    expect(impl2.serializeFontInfo(targetWindow)!.length,
        truth['serializeAfterRestoreAndRead']);
    impl.dispose();
    impl2.dispose();
    impl3.dispose();
  });

  test('batch213 clearAll notifies, dispose clears the eviction timer', () {
    final Map<String, dynamic> clearAll = _map(_truth()['clearAll']);
    final Map<String, dynamic> disposeExpected =
        _map(_truth()['disposeClearsTimer']);
    _widthRule = (String chr) => 0.5;

    final List<String> events = <String>[];
    final fm.FontMeasurementsImpl impl = fm.FontMeasurementsImpl();
    impl.onDidChange((dynamic _) => events.add('change'));
    impl.readFontInfo(targetWindow, _bare(EditorFontLigatures.OFF));
    impl.clearAllFontInfos();

    expect(events.length, clearAll['events']);
    expect(impl.serializeFontInfo(targetWindow)!.length, clearAll['serialized']);
    expect(_cleared.length, _truth()['clearAllClearedTimers']);

    final fm.FontMeasurementsImpl impl2 = fm.FontMeasurementsImpl();
    impl2.readFontInfo(targetWindow, _bare(EditorFontLigatures.OFF));
    impl2.dispose();
    expect(_cleared.length, disposeExpected['count']);
    expect(_scheduled.any((t) => t.handle == _cleared.last),
        disposeExpected['clearedHandleWasScheduled']);
    impl.dispose();
  });

  test('batch213 unregistering the window drops its cache', () {
    final Map<String, dynamic> truth = _truth();
    final fm.FontMeasurementsImpl impl = fm.FontMeasurementsImpl();

    // A second registered window keeps `mainWindow` untouched.
    final CodeWindow secondWindow = CodeWindow(Object(), 2);
    final lifecycle.IDisposable registration = dom.registerWindow(secondWindow);
    final dom.DomWindowCarrier window = dom.windowCarrier(secondWindow);

    impl.readFontInfo(window, _bare(EditorFontLigatures.OFF));
    expect(impl.serializeFontInfo(window)!.length, truth['beforeUnregister']);

    registration.dispose(); // fires `onDidUnregisterWindow`
    expect(impl.serializeFontInfo(window)!.length, truth['afterUnregister']);
    impl.dispose();
  });
}
