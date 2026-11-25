// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/viewModel/minimapTokensColorTracker.ts
// Translated 1:1. Structure, members and semantics preserved.
// Verified against the TypeScript transpile truth (batch422).
// ---------------------------------------------------------------------------

import '../../../base/common/errors.dart'
    show BugIndicatingError, onUnexpectedError;
import '../../../base/common/event.dart' show Emitter, Event;
import '../../../base/common/lifecycle.dart' show Disposable, markAsSingleton;
import '../core/misc/rgba.dart' show RGBA8;
import '../encodedTokenAttributes.dart' show ColorId;
import '../languages.dart' show TokenizationRegistry;
import '../tokenizationRegistry.dart' show TokenizationSupportChangedEvent;

/// 1:1: `MinimapTokensColorTracker`.
class MinimapTokensColorTracker extends Disposable {
  static MinimapTokensColorTracker? _instance;

  static MinimapTokensColorTracker getInstance() {
    final MinimapTokensColorTracker? existing = _instance;
    if (existing == null) {
      final MinimapTokensColorTracker created =
          markAsSingleton(MinimapTokensColorTracker._());
      _instance = created;
      return created;
    }
    return existing;
  }

  late List<RGBA8> _colors;
  late bool _backgroundIsLight;

  final Emitter<void> _onDidChange = Emitter<void>();

  /// 1:1: `public readonly onDidChange: Event<void>`.
  late final Event<void> onDidChange = _onDidChange.event;

  MinimapTokensColorTracker._() {
    _updateColorMap();
    register(TokenizationRegistry.onDidChange(
      (TokenizationSupportChangedEvent e) {
        if (e.changedColorMap) {
          _updateColorMap();
        }
      },
    ));
  }

  /// Reset the singleton for replay isolation. Not part of the TS surface;
  /// only used by truth-replay tests to construct a fresh tracker.
  static void resetForReplay() {
    final MinimapTokensColorTracker? old = _instance;
    if (old != null) {
      old.dispose();
    }
    _instance = null;
  }

  void _updateColorMap() {
    final List<ColorDynamic>? colorMap = _registryColorMap();
    if (colorMap == null) {
      _colors = <RGBA8>[];
      for (int i = 0; i <= ColorId.defaultBackground; i++) {
        _colors.add(RGBA8.Empty);
      }
      _backgroundIsLight = true;
      return;
    }
    _colors = <RGBA8>[RGBA8.Empty];
    for (int colorId = 1; colorId < colorMap.length; colorId++) {
      final ColorDynamic source = colorMap[colorId];
      // Use a VM friendly data-type.
      _colors.add(RGBA8(
        source.r,
        source.g,
        source.b,
        _round(source.a * 255),
      ));
    }
    final double backgroundLuminosity =
        colorMap[ColorId.defaultBackground].relativeLuminance;
    _backgroundIsLight = backgroundLuminosity >= 0.5;
    _onDidChange.fire(null);
  }

  /// 1:1: `public getColor(colorId: ColorId): RGBA8`.
  RGBA8 getColor(int colorId) {
    if (colorId < 1 || colorId >= _colors.length) {
      // background color (basically invisible)
      colorId = ColorId.defaultBackground;
    }
    RGBA8? color = colorId < _colors.length ? _colors[colorId] : null;
    if (color == null) {
      onUnexpectedError(
        BugIndicatingError('Missing color for colorId $colorId'),
      );
      color = RGBA8.Empty;
    }
    return color;
  }

  /// 1:1: `public backgroundIsLight(): boolean`.
  bool backgroundIsLight() => _backgroundIsLight;

  // ---- Registry access (narrow carriers; production + replay) -------------

  /// Reads the registry color map. Production uses the real singleton; a
  /// replay can install a hook via [colorMapProviderForReplay].
  static List<ColorDynamic>? Function()? colorMapProviderForReplay;

  List<ColorDynamic>? _registryColorMap() {
    final List<ColorDynamic>? Function()? hook = colorMapProviderForReplay;
    if (hook != null) return hook();
    // The real registry stores `Color` objects (with .rgba and
    // .getRelativeLuminance()); adapt them to the narrow carrier lazily.
    final Object? map = TokenizationRegistry.getColorMap();
    if (map == null) return null;
    return (map as List<Object?>).map(_fromRealColor).toList();
  }

  static ColorDynamic _fromRealColor(Object? c) {
    if (c == null) {
      return ColorDynamic(0, 0, 0, 0, 0.0);
    }
    final dynamic color = c;
    return ColorDynamic(
      color.rgba.r as num,
      color.rgba.g as num,
      color.rgba.b as num,
      color.rgba.a is double ? color.rgba.a : (color.rgba.a as int),
      (color.getRelativeLuminance() as num).toDouble(),
    );
  }

  /// JS `Math.round(x)`: ties round toward +infinity.
  static int _round(num x) => x.round();
}

/// Narrow color carrier: rgba components plus relative luminance.
class ColorDynamic {
  final num r;
  final num g;
  final num b;
  final num a;
  final double relativeLuminance;

  ColorDynamic(this.r, this.g, this.b, this.a, this.relativeLuminance);
}
