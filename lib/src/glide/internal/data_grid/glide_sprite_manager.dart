// Port of `packages/core/src/internal/data-grid/data-grid-sprites.ts`.
//
// Upstream rasterizes each sprite into an offscreen canvas keyed by
// `${bgColor}_${fgColor}_${rSize}_${sprite}` and blits that bitmap. A Flutter
// `ui.Picture` is resolution independent, so the device-pixel-ratio factor
// `rSize` drops out of the key: one entry serves every draw size and the scale
// is applied when the picture is drawn. Everything else follows upstream — the
// color triple, the "empty canvas while the decode is in flight" state, and
// the `inFlight`/`onSettled` handshake that repaints once every pending sprite
// has landed.
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common/glide_theme.dart';
import 'glide_sprites.dart';

/// `SpriteVariant` (`data-grid-sprites.ts:38-42`).
enum GlideSpriteVariant { normal, selected, special }

/// `getColors` (`data-grid-sprites.ts:30-40`).
///
/// Upstream's theme stores CSS color strings and hands them to the sprite
/// functions verbatim; this port's theme stores [Color], so the pair is
/// formatted to CSS on the way out. That formatting is the only thing standing
/// between a theme override and the SVG text.
({String bg, String fg}) glideSpriteColors(
  GlideSpriteVariant variant,
  GlideTheme theme,
) {
  switch (variant) {
    case GlideSpriteVariant.normal:
      return (
        bg: _cssColor(theme.bgIconHeader),
        fg: _cssColor(theme.fgIconHeader),
      );
    case GlideSpriteVariant.selected:
      // Upstream writes the literal `"white"` here rather than a theme value.
      return (bg: '#ffffff', fg: _cssColor(theme.accentColor));
    case GlideSpriteVariant.special:
      return (bg: _cssColor(theme.accentColor), fg: _cssColor(theme.bgHeader));
  }
}

String _cssColor(Color c) {
  if (c.a >= 1.0) {
    return '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }
  return 'rgba(${(c.r * 255).round()}, ${(c.g * 255).round()}, '
      '${(c.b * 255).round()}, ${c.a.toStringAsFixed(3)})';
}

/// `SpriteManager` (`data-grid-sprites.ts:44-107`).
///
/// Painting is synchronous but sprite decoding is not: the first call reserves
/// the cache slot and starts the load, drawing nothing until it lands — which
/// is exactly what upstream does with an empty canvas. [onSettled] fires when
/// the last in-flight sprite finishes so the caller can repaint.
class GlideSpriteManager {
  GlideSpriteManager({
    required Map<String, GlideSpriteFn> icons,
    required VoidCallback settled,
  }) : _headerIcons = icons,
       _onSettled = settled;

  final Map<String, GlideSpriteFn> _headerIcons;
  final VoidCallback _onSettled;

  /// `spriteMap`. A `null` value is upstream's canvas that exists but has not
  /// been painted into yet.
  final Map<String, ({ui.Picture picture, ui.Size size})?> _cache = {};
  int _inFlight = 0;
  bool _disposed = false;

  /// `drawSprite` (`data-grid-sprites.ts:57-107`).
  void drawSprite(
    String sprite,
    GlideSpriteVariant variant,
    Canvas ctx,
    double x,
    double y,
    double size,
    GlideTheme theme, [
    double alpha = 1,
  ]) {
    final colors = glideSpriteColors(variant, theme);
    final key = '${colors.bg}_${colors.fg}_$sprite';

    if (!_cache.containsKey(key)) {
      final fn = _headerIcons[sprite];
      // Unknown sprites draw nothing (`data-grid-sprites.ts:64-66`).
      if (fn == null) return;
      // Reserve the slot before awaiting so a second call in the same frame
      // does not start a duplicate load.
      _cache[key] = null;
      _inFlight++;
      _load(key, fn((fgColor: colors.fg, bgColor: colors.bg)));
      return;
    }

    final loaded = _cache[key];
    // Still decoding — upstream's canvas is empty at this point too.
    if (loaded == null) return;
    if (size <= 0 || loaded.size.width <= 0 || loaded.size.height <= 0) return;

    if (alpha < 1) {
      // `ctx.globalAlpha = alpha` (`data-grid-sprites.ts:99-104`).
      ctx.saveLayer(
        Rect.fromLTWH(x, y, size, size),
        Paint()..color = Color.fromRGBO(0, 0, 0, alpha),
      );
    }
    ctx.save();
    ctx.translate(x, y);
    ctx.scale(size / loaded.size.width, size / loaded.size.height);
    ctx.drawPicture(loaded.picture);
    ctx.restore();
    if (alpha < 1) ctx.restore();
  }

  Future<void> _load(String key, String svg) async {
    ui.Picture? picture;
    var size = ui.Size.zero;
    try {
      final info = await vg.loadPicture(SvgStringLoader(svg), null);
      picture = info.picture;
      size = info.size;
    } catch (_) {
      // A sprite that fails to parse never draws. Upstream keeps the empty
      // canvas in the map, so the reservation below is kept as well.
    }
    if (_disposed) {
      picture?.dispose();
    } else if (picture != null) {
      _cache[key] = (picture: picture, size: size);
    }
    _inFlight--;
    if (_inFlight == 0 && !_disposed) _onSettled();
  }

  /// Releases every decoded picture. The grid owns the manager, so this runs
  /// with the widget; in-flight loads notice the flag and drop their result
  /// instead of caching it.
  void dispose() {
    _disposed = true;
    for (final entry in _cache.values) {
      entry?.picture.dispose();
    }
    _cache.clear();
  }
}
