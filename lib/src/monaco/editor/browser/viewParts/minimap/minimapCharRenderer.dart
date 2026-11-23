// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/viewParts/minimap/minimapCharRenderer.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
// ---------------------------------------------------------------------------

import 'dart:typed_data' show Uint8List;

import '../../../../base/common/uint.dart' show toUint8;
import '../../../common/core/misc/rgba.dart' show RGBA8;
import 'minimapCharSheet.dart' show Constants, getCharIndex;

/// Injectable `console.warn`.
void Function(String message) minimapCharRendererWarn = (String message) {};

/// Opaque carrier for the DOM `ImageData` used by `renderChar`/`blockRenderChar`.
class MinimapImageData {
  MinimapImageData(this.width, this.height, this.data);

  final int width;
  final int height;
  final Uint8List data;
}

/// 1:1: ECMAScript `ToUint8Clamp` used by `Uint8ClampedArray` assignment:
/// clamp into [0, 255] and round to nearest with ties to **even**.
/// `num.round()` is ties-away-from-zero and differs at an exact `x.5`.
void _setClamped(Uint8List dest, int index, num value) {
  if (value.isNaN) {
    dest[index] = 0;
    return;
  }
  if (value <= 0) {
    dest[index] = 0;
    return;
  }
  if (value >= 255) {
    dest[index] = 255;
    return;
  }
  final int f = value.floor();
  final num frac = value - f;
  if (frac > 0.5) {
    dest[index] = f + 1;
  } else if (frac < 0.5) {
    dest[index] = f;
  } else {
    dest[index] = f.isEven ? f : f + 1;
  }
}

/// 1:1: `export class MinimapCharRenderer`
class MinimapCharRenderer {
  final Uint8List charDataNormal;
  final Uint8List charDataLight;

  /// 1:1: `constructor(charData: Uint8ClampedArray, public readonly scale: number)`
  MinimapCharRenderer(Uint8List charData, this.scale)
      : charDataNormal = _soften(charData, 12 / 15),
        charDataLight = _soften(charData, 50 / 60);

  final num scale;

  /// 1:1: `private static soften(input, ratio): Uint8ClampedArray`
  static Uint8List _soften(Uint8List input, num ratio) {
    final Uint8List result = Uint8List(input.length);
    for (int i = 0, len = input.length; i < len; i++) {
      result[i] = toUint8(input[i] * ratio);
    }
    return result;
  }

  /// 1:1: `public renderChar(...)`
  void renderChar(
    MinimapImageData target,
    int dx,
    int dy,
    int chCode,
    RGBA8 color,
    num foregroundAlpha,
    RGBA8 backgroundColor,
    num backgroundAlpha,
    int fontScale,
    bool useLighterFont,
    bool force1pxHeight,
  ) {
    final int charWidth = (Constants.BASE_CHAR_WIDTH * scale).toInt();
    final int charHeight = (Constants.BASE_CHAR_HEIGHT * scale).toInt();
    final int renderHeight = force1pxHeight ? 1 : charHeight;
    if (dx + charWidth > target.width || dy + renderHeight > target.height) {
      minimapCharRendererWarn('bad render request outside image data');
      return;
    }

    final Uint8List charData = useLighterFont ? charDataLight : charDataNormal;
    final int charIndex = getCharIndex(chCode, fontScale);

    final int destWidth = target.width * Constants.RGBA_CHANNELS_CNT;

    final num backgroundR = backgroundColor.r;
    final num backgroundG = backgroundColor.g;
    final num backgroundB = backgroundColor.b;

    final num deltaR = color.r - backgroundR;
    final num deltaG = color.g - backgroundG;
    final num deltaB = color.b - backgroundB;

    final num destAlpha = _max(foregroundAlpha, backgroundAlpha);

    final Uint8List dest = target.data;
    int sourceOffset = charIndex * charWidth * charHeight;

    int row = dy * destWidth + dx * Constants.RGBA_CHANNELS_CNT;
    for (int y = 0; y < renderHeight; y++) {
      int column = row;
      for (int x = 0; x < charWidth; x++) {
        final num c = (charData[sourceOffset++] / 255) * (foregroundAlpha / 255);
        _setClamped(dest, column++, backgroundR + deltaR * c);
        _setClamped(dest, column++, backgroundG + deltaG * c);
        _setClamped(dest, column++, backgroundB + deltaB * c);
        _setClamped(dest, column++, destAlpha);
      }

      row += destWidth;
    }
  }

  /// 1:1: `public blockRenderChar(...)`
  void blockRenderChar(
    MinimapImageData target,
    int dx,
    int dy,
    RGBA8 color,
    num foregroundAlpha,
    RGBA8 backgroundColor,
    num backgroundAlpha,
    bool force1pxHeight,
  ) {
    final int charWidth = (Constants.BASE_CHAR_WIDTH * scale).toInt();
    final int charHeight = (Constants.BASE_CHAR_HEIGHT * scale).toInt();
    final int renderHeight = force1pxHeight ? 1 : charHeight;
    if (dx + charWidth > target.width || dy + renderHeight > target.height) {
      minimapCharRendererWarn('bad render request outside image data');
      return;
    }

    final int destWidth = target.width * Constants.RGBA_CHANNELS_CNT;

    final num c = 0.5 * (foregroundAlpha / 255);

    final num backgroundR = backgroundColor.r;
    final num backgroundG = backgroundColor.g;
    final num backgroundB = backgroundColor.b;

    final num deltaR = color.r - backgroundR;
    final num deltaG = color.g - backgroundG;
    final num deltaB = color.b - backgroundB;

    final num colorR = backgroundR + deltaR * c;
    final num colorG = backgroundG + deltaG * c;
    final num colorB = backgroundB + deltaB * c;

    final num destAlpha = _max(foregroundAlpha, backgroundAlpha);

    final Uint8List dest = target.data;

    int row = dy * destWidth + dx * Constants.RGBA_CHANNELS_CNT;
    for (int y = 0; y < renderHeight; y++) {
      int column = row;
      for (int x = 0; x < charWidth; x++) {
        _setClamped(dest, column++, colorR);
        _setClamped(dest, column++, colorG);
        _setClamped(dest, column++, colorB);
        _setClamped(dest, column++, destAlpha);
      }

      row += destWidth;
    }
  }

  /// 1:1: `Math.max`.
  num _max(num a, num b) => a > b ? a : b;
}
