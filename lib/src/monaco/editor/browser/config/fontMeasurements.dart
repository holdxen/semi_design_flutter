// 1:1 port of vscode/src/vs/editor/browser/config/fontMeasurements.ts
//
// Carriers: `charWidthReader` (batch211), `BareFontInfo`/`FontInfo`,
// `PixelRatio`, `getWindowId`/`onDidUnregisterWindow`, `Emitter`/`Disposable`
// are used as-is.
//
// Adaptations (documented inline):
//  * `targetWindow: Window` -> `DomWindowCarrier`.
//  * TS `targetWindow.setTimeout` / global `clearTimeout` are routed through
//    module-level seams so the 5s "evict untrusted readings" timer is testable.
//  * `{ [key: string]: T }` caches -> insertion-ordered Dart `Map`s (JS object
//    key order is insertion order for string keys).
import 'dart:async' show Timer;

import '../../../base/browser/dom.dart' as dom;
import '../../../base/browser/pixelRatio.dart' as pixelRatio;
import '../../../base/browser/window.dart' show CodeWindow;
import '../../../base/common/event.dart' show Emitter, Event;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../common/config/editorOptions.dart' show EditorFontLigatures;
import '../../common/config/fontInfo.dart'
    show BareFontInfo, FontInfo, FontInfoOptions, SERIALIZED_FONT_INFO_VERSION;
import './charWidthReader.dart'
    show CharWidthRequest, CharWidthRequestType, readCharWidths;

/// 1:1: `export interface ISerializedFontInfo`. In this port `FontInfo` itself
/// carries every serialized field, so it is used directly.
typedef ISerializedFontInfo = FontInfo;

final Map<int, Timer> _timers = <int, Timer>{};
int _nextTimerHandle = 1;

int _defaultSetTimeout(void Function() callback, num milliseconds) {
  final int handle = _nextTimerHandle++;
  _timers[handle] = Timer(
    Duration(milliseconds: milliseconds.toInt()),
    () {
      _timers.remove(handle);
      callback();
    },
  );
  return handle;
}

void _defaultClearTimeout(int handle) {
  _timers.remove(handle)?.cancel();
}

/// TS `targetWindow.setTimeout` / global `clearTimeout` are injectable seams
/// (`null` restores the real `Timer`-backed implementation) so the 5000ms
/// eviction path is replayable without waiting five seconds.
int Function(void Function() callback, num milliseconds)? _setTimeoutOverride;
void Function(int handle)? _clearTimeoutOverride;

set setTimeoutOverride(int Function(void Function() callback, num milliseconds)? value) {
  _setTimeoutOverride = value;
}

set clearTimeoutOverride(void Function(int handle)? value) {
  _clearTimeoutOverride = value;
}

int _setTimeout(void Function() callback, num milliseconds) =>
    (_setTimeoutOverride ?? _defaultSetTimeout)(callback, milliseconds);

void _clearTimeout(int handle) => (_clearTimeoutOverride ?? _defaultClearTimeout)(handle);

/// 1:1: `export class FontMeasurementsImpl extends Disposable`.
class FontMeasurementsImpl extends lifecycle.Disposable {
  FontMeasurementsImpl() : super() {
    register(dom.onDidUnregisterWindow((dynamic e) {
      _cache.remove((e as CodeWindow).vscodeWindowId);
    }));
  }

  final Map<int, FontMeasurementsCache> _cache =
      <int, FontMeasurementsCache>{};

  int _evictUntrustedReadingsTimeout = -1;

  final Emitter<void> _onDidChange = Emitter<void>();
  late final Event<void> onDidChange = _onDidChange.event;

  @override
  void dispose() {
    if (_evictUntrustedReadingsTimeout != -1) {
      _clearTimeout(_evictUntrustedReadingsTimeout);
      _evictUntrustedReadingsTimeout = -1;
    }
    super.dispose();
  }

  /// Clear all cached font information and trigger a change event.
  void clearAllFontInfos() {
    _cache.clear();
    _onDidChange.fire(null);
  }

  FontMeasurementsCache _ensureCache(dom.DomWindowCarrier targetWindow) {
    final int windowId = dom.getWindowId(targetWindow.codeWindow);
    FontMeasurementsCache? cache = _cache[windowId];
    if (cache == null) {
      cache = FontMeasurementsCache();
      _cache[windowId] = cache;
    }
    return cache;
  }

  void _writeToCache(
    dom.DomWindowCarrier targetWindow,
    BareFontInfo item,
    FontInfo value,
    bool isRestored,
  ) {
    final FontMeasurementsCache cache = _ensureCache(targetWindow);
    cache.put(item, value, isRestored);

    if (!value.isTrusted && _evictUntrustedReadingsTimeout == -1) {
      // Try reading again after some time
      _evictUntrustedReadingsTimeout = _setTimeout(() {
        _evictUntrustedReadingsTimeout = -1;
        _evictUntrustedReadings(targetWindow);
      }, 5000);
    }
  }

  void _evictUntrustedReadings(dom.DomWindowCarrier targetWindow) {
    final FontMeasurementsCache? cache =
        _cache[dom.getWindowId(targetWindow.codeWindow)];
    if (cache == null) {
      return; // The window closed or the font cache was cleared while waiting.
    }
    final List<FontInfo> values = cache.getValues();
    bool somethingRemoved = false;
    for (final FontInfo item in values) {
      if (!item.isTrusted) {
        somethingRemoved = true;
        cache.remove(item);
      }
    }
    if (somethingRemoved) {
      _onDidChange.fire(null);
    }
  }

  /// Returns trusted cached font information, or null when the cache contains
  /// only restored readings.
  List<ISerializedFontInfo>? serializeFontInfo(
      dom.DomWindowCarrier targetWindow) {
    final FontMeasurementsCache cache = _ensureCache(targetWindow);
    if (cache.shouldPreservePersistedValues()) {
      return null;
    }
    return cache
        .getValues()
        .where((FontInfo item) => item.isTrusted)
        .toList();
  }

  /// Restore previously serialized font informations.
  void restoreFontInfo(
    dom.DomWindowCarrier targetWindow,
    List<ISerializedFontInfo> savedFontInfos,
  ) {
    // Take all the saved font info and insert them in the cache without the
    // trusted flag: a font might have been installed on the OS in the meantime.
    for (final ISerializedFontInfo savedFontInfo in savedFontInfos) {
      if (savedFontInfo.version != SERIALIZED_FONT_INFO_VERSION) {
        // cannot use older version
        continue;
      }
      // TS rebuilds the info as untrusted (`new FontInfo(saved, false)`): the
      // font may have been installed on the OS in the meantime.
      final FontInfo fontInfo = FontInfo(
        FontInfoOptions(
          pixelRatio: savedFontInfo.pixelRatio,
          fontFamily: savedFontInfo.fontFamily,
          fontWeight: savedFontInfo.fontWeight,
          fontSize: savedFontInfo.fontSize,
          fontFeatureSettings: savedFontInfo.fontFeatureSettings,
          fontVariationSettings: savedFontInfo.fontVariationSettings,
          lineHeight: savedFontInfo.lineHeight,
          letterSpacing: savedFontInfo.letterSpacing,
          isMonospace: savedFontInfo.isMonospace,
          typicalHalfwidthCharacterWidth:
              savedFontInfo.typicalHalfwidthCharacterWidth,
          typicalFullwidthCharacterWidth:
              savedFontInfo.typicalFullwidthCharacterWidth,
          canUseHalfwidthRightwardsArrow:
              savedFontInfo.canUseHalfwidthRightwardsArrow,
          spaceWidth: savedFontInfo.spaceWidth,
          middotWidth: savedFontInfo.middotWidth,
          wsmiddotWidth: savedFontInfo.wsmiddotWidth,
          maxDigitWidth: savedFontInfo.maxDigitWidth,
        ),
        false,
      );
      _writeToCache(targetWindow, fontInfo, fontInfo, true);
    }
  }

  /// Read font information.
  FontInfo readFontInfo(
    dom.DomWindowCarrier targetWindow,
    BareFontInfo bareFontInfo,
  ) {
    final FontMeasurementsCache cache = _ensureCache(targetWindow);
    if (!cache.has(bareFontInfo)) {
      FontInfo readConfig = _actualReadFontInfo(targetWindow, bareFontInfo);

      if (readConfig.typicalHalfwidthCharacterWidth <= 2 ||
          readConfig.typicalFullwidthCharacterWidth <= 2 ||
          readConfig.spaceWidth <= 2 ||
          readConfig.maxDigitWidth <= 2) {
        // Hey, it's Bug 14341 ... we couldn't read
        readConfig = FontInfo(
          FontInfoOptions(
            pixelRatio: pixelRatio.PixelRatio
                .getInstance(targetWindow.codeWindow)
                .value
                .toDouble(),
            fontFamily: readConfig.fontFamily,
            fontWeight: readConfig.fontWeight,
            fontSize: readConfig.fontSize,
            fontFeatureSettings: readConfig.fontFeatureSettings,
            fontVariationSettings: readConfig.fontVariationSettings,
            lineHeight: readConfig.lineHeight,
            letterSpacing: readConfig.letterSpacing,
            isMonospace: readConfig.isMonospace,
            typicalHalfwidthCharacterWidth:
                _maxDouble(readConfig.typicalHalfwidthCharacterWidth, 5),
            typicalFullwidthCharacterWidth:
                _maxDouble(readConfig.typicalFullwidthCharacterWidth, 5),
            canUseHalfwidthRightwardsArrow:
                readConfig.canUseHalfwidthRightwardsArrow,
            spaceWidth: _maxDouble(readConfig.spaceWidth, 5),
            middotWidth: _maxDouble(readConfig.middotWidth, 5),
            wsmiddotWidth: _maxDouble(readConfig.wsmiddotWidth, 5),
            maxDigitWidth: _maxDouble(readConfig.maxDigitWidth, 5),
          ),
          false,
        );
      }

      _writeToCache(targetWindow, bareFontInfo, readConfig, false);
    }
    return cache.get(bareFontInfo);
  }

  CharWidthRequest _createRequest(
    String chr,
    int type,
    List<CharWidthRequest> all,
    List<CharWidthRequest>? monospace,
  ) {
    final CharWidthRequest result = CharWidthRequest(chr, type);
    all.add(result);
    monospace?.add(result);
    return result;
  }

  FontInfo _actualReadFontInfo(
    dom.DomWindowCarrier targetWindow,
    BareFontInfo bareFontInfo,
  ) {
    final List<CharWidthRequest> all = <CharWidthRequest>[];
    final List<CharWidthRequest> monospace = <CharWidthRequest>[];

    final CharWidthRequest typicalHalfwidthCharacter = _createRequest(
        'n', CharWidthRequestType.Regular, all, monospace);
    final CharWidthRequest typicalFullwidthCharacter = _createRequest(
        '\uff4d', CharWidthRequestType.Regular, all, null);
    final CharWidthRequest space =
        _createRequest(' ', CharWidthRequestType.Regular, all, monospace);
    final CharWidthRequest digit0 =
        _createRequest('0', CharWidthRequestType.Regular, all, monospace);
    final CharWidthRequest digit1 =
        _createRequest('1', CharWidthRequestType.Regular, all, monospace);
    final CharWidthRequest digit2 =
        _createRequest('2', CharWidthRequestType.Regular, all, monospace);
    final CharWidthRequest digit3 =
        _createRequest('3', CharWidthRequestType.Regular, all, monospace);
    final CharWidthRequest digit4 =
        _createRequest('4', CharWidthRequestType.Regular, all, monospace);
    final CharWidthRequest digit5 =
        _createRequest('5', CharWidthRequestType.Regular, all, monospace);
    final CharWidthRequest digit6 =
        _createRequest('6', CharWidthRequestType.Regular, all, monospace);
    final CharWidthRequest digit7 =
        _createRequest('7', CharWidthRequestType.Regular, all, monospace);
    final CharWidthRequest digit8 =
        _createRequest('8', CharWidthRequestType.Regular, all, monospace);
    final CharWidthRequest digit9 =
        _createRequest('9', CharWidthRequestType.Regular, all, monospace);

    // monospace test: used for whitespace rendering
    final CharWidthRequest rightwardsArrow = _createRequest(
        '\u2192', CharWidthRequestType.Regular, all, monospace);
    final CharWidthRequest halfwidthRightwardsArrow = _createRequest(
        '\uffeb', CharWidthRequestType.Regular, all, null);

    // U+00B7 - MIDDLE DOT
    final CharWidthRequest middot =
        _createRequest('\u00b7', CharWidthRequestType.Regular, all, monospace);

    // U+2E31 - WORD SEPARATOR MIDDLE DOT
    final CharWidthRequest wsmiddotWidth = _createRequest(
        String.fromCharCode(0x2E31), CharWidthRequestType.Regular, all, null);

    // monospace test: some characters
    const String monospaceTestChars = '|/-_ilm%';
    for (int i = 0, len = monospaceTestChars.length; i < len; i++) {
      _createRequest(
          monospaceTestChars[i], CharWidthRequestType.Regular, all, monospace);
      _createRequest(
          monospaceTestChars[i], CharWidthRequestType.Italic, all, monospace);
      _createRequest(
          monospaceTestChars[i], CharWidthRequestType.Bold, all, monospace);
    }

    if (bareFontInfo.fontFeatureSettings != EditorFontLigatures.OFF) {
      const List<String> monospaceLigatureTestStrings = <String>[
        'fi',
        '<=',
        '=>',
        '==='
      ];
      for (final String testString in monospaceLigatureTestStrings) {
        _createRequest(
            testString, CharWidthRequestType.Regular, all, monospace);
      }
    }

    readCharWidths(targetWindow, bareFontInfo, all);

    final num maxDigitWidth = <num>[
      digit0.width,
      digit1.width,
      digit2.width,
      digit3.width,
      digit4.width,
      digit5.width,
      digit6.width,
      digit7.width,
      digit8.width,
      digit9.width,
    ].reduce(_maxNum);

    bool isMonospace = true;
    final num referenceWidth = monospace[0].width;
    for (int i = 1, len = monospace.length; isMonospace && i < len; i++) {
      final CharWidthRequest request = monospace[i];
      final num diff = referenceWidth * request.chr.length - request.width;
      if (diff < -0.005 || diff > 0.005) {
        isMonospace = false;
        break;
      }
    }

    bool canUseHalfwidthRightwardsArrow = true;
    if (isMonospace && halfwidthRightwardsArrow.width != referenceWidth) {
      // using a halfwidth rightwards arrow would break monospace...
      canUseHalfwidthRightwardsArrow = false;
    }
    if (halfwidthRightwardsArrow.width > rightwardsArrow.width) {
      // using a halfwidth rightwards arrow would paint a larger arrow than a
      // regular rightwards arrow
      canUseHalfwidthRightwardsArrow = false;
    }

    return FontInfo(
      FontInfoOptions(
        pixelRatio: pixelRatio.PixelRatio
            .getInstance(targetWindow.codeWindow)
            .value
            .toDouble(),
        fontFamily: bareFontInfo.fontFamily,
        fontWeight: bareFontInfo.fontWeight,
        fontSize: bareFontInfo.fontSize,
        fontFeatureSettings: bareFontInfo.fontFeatureSettings,
        fontVariationSettings: bareFontInfo.fontVariationSettings,
        lineHeight: bareFontInfo.lineHeight,
        letterSpacing: bareFontInfo.letterSpacing,
        isMonospace: isMonospace,
        typicalHalfwidthCharacterWidth:
            typicalHalfwidthCharacter.width.toDouble(),
        typicalFullwidthCharacterWidth:
            typicalFullwidthCharacter.width.toDouble(),
        canUseHalfwidthRightwardsArrow: canUseHalfwidthRightwardsArrow,
        spaceWidth: space.width.toDouble(),
        middotWidth: middot.width.toDouble(),
        wsmiddotWidth: wsmiddotWidth.width.toDouble(),
        maxDigitWidth: maxDigitWidth.toDouble(),
      ),
      true,
    );
  }
}

num _maxNum(num a, num b) => a > b ? a : b;
double _maxDouble(double value, double minimum) =>
    value > minimum ? value : minimum;

/// 1:1: `class FontMeasurementsCache`.
class FontMeasurementsCache {
  final Map<String, BareFontInfo> _keys = <String, BareFontInfo>{};
  final Map<String, FontInfo> _values = <String, FontInfo>{};
  bool _wasPopulatedWithRestoredValues = false;
  bool _wasPopulatedWithCurrentSessionValues = false;

  bool has(BareFontInfo item) {
    final String itemId = item.getId();
    return _values[itemId] != null;
  }

  FontInfo get(BareFontInfo item) {
    final String itemId = item.getId();
    return _values[itemId]!;
  }

  void put(BareFontInfo item, FontInfo value, bool isRestored) {
    final String itemId = item.getId();
    _keys[itemId] = item;
    _values[itemId] = value;
    if (isRestored) {
      _wasPopulatedWithRestoredValues = true;
    } else {
      _wasPopulatedWithCurrentSessionValues = true;
    }
  }

  void remove(FontInfo item) {
    final String itemId = item.getId();
    _keys.remove(itemId);
    _values.remove(itemId);
  }

  List<FontInfo> getValues() => _keys.keys
      .map((String id) => _values[id]!)
      .toList();

  bool shouldPreservePersistedValues() =>
      _wasPopulatedWithRestoredValues && !_wasPopulatedWithCurrentSessionValues;
}

/// 1:1: `export const FontMeasurements = new FontMeasurementsImpl()`.
final FontMeasurementsImpl FontMeasurements = FontMeasurementsImpl();
