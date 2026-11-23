// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/viewParts/minimap/minimapCharRendererFactory.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//   - `ImageData`/`document.createElement('canvas')` -> injectable canvas
//     carrier (`MinimapCanvas2D`), default produces correctly-sized blank data.
//   - `Uint8ClampedArray` -> `Uint8List`; assignment via clamp+round helper,
//     matching the sibling `minimapCharRenderer.dart` port.
//   - JS `prebakedMiniMaps[scale]` truthiness -> null check on the function.
// ---------------------------------------------------------------------------

import 'dart:typed_data' show Uint8List;

import '../../../../base/common/uint.dart' show toUint8;
import 'minimapCharRenderer.dart' show MinimapCharRenderer, MinimapImageData;
import 'minimapCharSheet.dart' show Constants, allCharCodes;
import 'minimapPreBaked.dart' show prebakedMiniMaps;

/// 1:1: the 2D canvas context surface used by `createSampleData`.
abstract class MinimapCanvas2D {
  set fillStyle(String value);
  set font(String value);
  set textBaseline(String value);
  void fillText(String text, num x, num y);
  Uint8List getImageData(int x, int y, int w, int h);
}

/// 1:1: the canvas element surface used by `createSampleData`.
class MinimapCanvas {
  MinimapCanvas(this.context2d);

  final MinimapCanvas2D context2d;

  /// Mirrors `canvas.style.height` / `canvas.style.width`.
  final Map<String, String> style = <String, String>{};
  int height = 0;
  int width = 0;

  MinimapCanvas2D getContext(String type) => context2d;
}

/// Default 2D context: records no glyphs, returns zeroed image data of the
/// requested size. Tests can inject a provider that paints real samples.
class _BlankCanvas2D implements MinimapCanvas2D {
  @override
  String fillStyle = '#000000';
  @override
  String font = '';
  @override
  String textBaseline = '';
  @override
  void fillText(String text, num x, num y) {}
  @override
  Uint8List getImageData(int x, int y, int w, int h) => Uint8List(w * h * 4);
}

/// Injectable `document.createElement('canvas')`.
MinimapCanvas Function() createMinimapCanvas = () => MinimapCanvas(_BlankCanvas2D());

/// 1:1: ECMAScript `ToUint8Clamp` (spec 23.3.2.2) used by `Uint8ClampedArray`
/// element assignment: clamp into [0,255] and round to nearest with ties to
/// **even**. Dart's `num.round()` is ties-away-from-zero, which differs at an
/// exact `x.5` (e.g. 200.5 -> 200 in JS, 201 with `round()`).
int _setClamped(num value) {
  if (value.isNaN) return 0;
  if (value <= 0) return 0;
  if (value >= 255) return 255;
  final int f = value.floor();
  final num frac = value - f;
  if (frac > 0.5) return f + 1;
  if (frac < 0.5) return f;
  return f.isEven ? f : f + 1;
}

/// 1:1: `export class MinimapCharRendererFactory`
class MinimapCharRendererFactory {
  MinimapCharRendererFactory._();

  static MinimapCharRenderer? _lastCreated;
  static String? _lastFontFamily;

  /// 1:1: `public static create(scale, fontFamily)`
  static MinimapCharRenderer create(num scale, String fontFamily) {
    // Renderers are immutable; reuse when scale and font family are unchanged.
    final MinimapCharRenderer? last = _lastCreated;
    if (last != null && scale == last.scale && fontFamily == _lastFontFamily) {
      return last;
    }

    late final MinimapCharRenderer factory;
    final Uint8List Function()? prebaked = prebakedMiniMaps[scale];
    if (prebaked != null) {
      factory = MinimapCharRenderer(prebaked(), scale);
    } else {
      factory = createFromSampleData(
        createSampleData(fontFamily).data,
        scale,
      );
    }

    _lastFontFamily = fontFamily;
    _lastCreated = factory;
    return factory;
  }

  /// 1:1: `public static createSampleData(fontFamily): ImageData`
  static MinimapImageData createSampleData(String fontFamily) {
    final MinimapCanvas canvas = createMinimapCanvas();
    final MinimapCanvas2D ctx = canvas.getContext('2d');

    canvas.style['height'] = '${Constants.SAMPLED_CHAR_HEIGHT}px';
    canvas.height = Constants.SAMPLED_CHAR_HEIGHT;
    canvas.width = Constants.CHAR_COUNT * Constants.SAMPLED_CHAR_WIDTH;
    canvas.style['width'] = '${Constants.CHAR_COUNT * Constants.SAMPLED_CHAR_WIDTH}px';

    ctx.fillStyle = '#ffffff';
    ctx.font = 'bold ${Constants.SAMPLED_CHAR_HEIGHT}px $fontFamily';
    ctx.textBaseline = 'middle';

    int x = 0;
    for (final int code in allCharCodes) {
      ctx.fillText(String.fromCharCode(code), x, Constants.SAMPLED_CHAR_HEIGHT / 2);
      x += Constants.SAMPLED_CHAR_WIDTH;
    }

    final Uint8List data = ctx.getImageData(
      0,
      0,
      Constants.CHAR_COUNT * Constants.SAMPLED_CHAR_WIDTH,
      Constants.SAMPLED_CHAR_HEIGHT,
    );
    return MinimapImageData(
      Constants.CHAR_COUNT * Constants.SAMPLED_CHAR_WIDTH,
      Constants.SAMPLED_CHAR_HEIGHT,
      data,
    );
  }

  /// 1:1: `public static createFromSampleData(source, scale): MinimapCharRenderer`
  static MinimapCharRenderer createFromSampleData(Uint8List source, num scale) {
    final int expectedLength = Constants.SAMPLED_CHAR_HEIGHT *
        Constants.SAMPLED_CHAR_WIDTH *
        Constants.RGBA_CHANNELS_CNT *
        Constants.CHAR_COUNT;
    if (source.length != expectedLength) {
      throw StateError('Unexpected source in MinimapCharRenderer');
    }

    final Uint8List charData = _downsample(source, scale);
    return MinimapCharRenderer(charData, scale);
  }

  /// 1:1: `private static _downsampleChar(...)`
  static num _downsampleChar(
    Uint8List source,
    int sourceOffset,
    Uint8List dest,
    int destOffset,
    num scale,
  ) {
    final num width = Constants.BASE_CHAR_WIDTH * scale;
    final num height = Constants.BASE_CHAR_HEIGHT * scale;

    int targetIndex = destOffset;
    num brightest = 0;

    for (int y = 0; y < height; y++) {
      // 1. For this destination pixel, get the source pixels we're sampling
      // from (x1, y1) to the next pixel (x2, y2).
      final num sourceY1 = (y / height) * Constants.SAMPLED_CHAR_HEIGHT;
      final num sourceY2 = ((y + 1) / height) * Constants.SAMPLED_CHAR_HEIGHT;

      for (int x = 0; x < width; x++) {
        final num sourceX1 = (x / width) * Constants.SAMPLED_CHAR_WIDTH;
        final num sourceX2 = ((x + 1) / width) * Constants.SAMPLED_CHAR_WIDTH;

        // 2. Sample all of them, summing them up and weighting them.
        num value = 0;
        num samples = 0;
        for (num sy = sourceY1; sy < sourceY2; sy += 1) {
          final int sourceRow =
              sourceOffset + sy.floor() * Constants.RGBA_SAMPLED_ROW_WIDTH;
          final num yBalance = 1 - (sy - sy.floor());
          for (num sx = sourceX1; sx < sourceX2; sx += 1) {
            final num xBalance = 1 - (sx - sx.floor());
            final int sourceIndex =
                sourceRow + sx.floor() * Constants.RGBA_CHANNELS_CNT;

            final num weight = xBalance * yBalance;
            samples += weight;
            value += ((source[sourceIndex] * source[sourceIndex + 3]) / 255) * weight;
          }
        }

        final num finalValue = value / samples;
        if (finalValue > brightest) {
          brightest = finalValue;
        }
        // 1:1: `dest[targetIndex++] = toUint8(final)` (truncating toUint8, v|0).
        dest[targetIndex++] = toUint8(finalValue);
      }
    }

    return brightest;
  }

  /// 1:1: `private static _downsample(data, scale): Uint8ClampedArray`
  static Uint8List _downsample(Uint8List data, num scale) {
    final num pixelsPerCharacterNum = Constants.BASE_CHAR_HEIGHT *
        scale *
        Constants.BASE_CHAR_WIDTH *
        scale;
    final int pixelsPerCharacter = pixelsPerCharacterNum.toInt();
    final int resultLen = pixelsPerCharacter * Constants.CHAR_COUNT;
    final Uint8List result = Uint8List(resultLen);

    int resultOffset = 0;
    int sourceOffset = 0;
    num brightest = 0;
    for (int charIndex = 0; charIndex < Constants.CHAR_COUNT; charIndex++) {
      final num b = _downsampleChar(
        data,
        sourceOffset,
        result,
        resultOffset,
        scale,
      );
      if (b > brightest) {
        brightest = b;
      }
      resultOffset += pixelsPerCharacter;
      sourceOffset += Constants.SAMPLED_CHAR_WIDTH * Constants.RGBA_CHANNELS_CNT;
    }

    if (brightest > 0) {
      final num adjust = 255 / brightest;
      for (int i = 0; i < resultLen; i++) {
        result[i] = _setClamped(result[i] * adjust);
      }
    }

    return result;
  }
}
