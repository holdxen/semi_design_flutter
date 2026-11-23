// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/gpu/css/decorationStyleCache.ts
// Translated 1:1 from TypeScript. The two `interface`s -> carrier classes;
// the `NKeyMap<Entry, [number, number, string, number, string, number]>`
// tuple key -> `List<Object>` (the ported NKeyMap already uses List<Object>).
// `number.toFixed(2)` -> `num.toStringAsFixed(2)`.
// ---------------------------------------------------------------------------

import '../../../../base/common/map.dart';

/// 1:1: `export interface IDecorationStyleSet`
class IDecorationStyleSet {
  /// A 24-bit number representing `color`.
  final int? color;
  /// Whether the text should be rendered in bold.
  final bool? bold;
  /// A number between 0 and 1 representing the opacity of the text.
  final num? opacity;
  /// Whether the text should be rendered with a strikethrough.
  final bool? strikethrough;
  /// The thickness of the strikethrough line in pixels (CSS pixels, not device pixels).
  final num? strikethroughThickness;
  /// A 32-bit number representing the strikethrough color.
  final int? strikethroughColor;

  IDecorationStyleSet({
    this.color,
    this.bold,
    this.opacity,
    this.strikethrough,
    this.strikethroughThickness,
    this.strikethroughColor,
  });
}

/// 1:1: `export interface IDecorationStyleCacheEntry extends IDecorationStyleSet`
class IDecorationStyleCacheEntry extends IDecorationStyleSet {
  /// A unique identifier for this set of styles.
  final int id;

  IDecorationStyleCacheEntry({
    required this.id,
    int? color,
    bool? bold,
    num? opacity,
    bool? strikethrough,
    num? strikethroughThickness,
    int? strikethroughColor,
  }) : super(
          color: color,
          bold: bold,
          opacity: opacity,
          strikethrough: strikethrough,
          strikethroughThickness: strikethroughThickness,
          strikethroughColor: strikethroughColor,
        );
}

/// 1:1: `export class DecorationStyleCache`
class DecorationStyleCache {
  int _nextId = 1;

  final Map<int, IDecorationStyleCacheEntry> _cacheById =
      <int, IDecorationStyleCacheEntry>{};
  final NKeyMap<IDecorationStyleCacheEntry, List<Object>> _cacheByStyle =
      NKeyMap<IDecorationStyleCacheEntry, List<Object>>();

  /// Builds the 6-part style key used by both `get` and `set`.
  /// 1:1: the argument list passed to `_cacheByStyle.get(...)` / `.set(...)`.
  static List<Object> _styleKey(
    int? color,
    bool? bold,
    num? opacity,
    bool? strikethrough,
    num? strikethroughThickness,
    int? strikethroughColor,
  ) =>
      <Object>[
        color ?? 0,
        bold != null && bold ? 1 : 0,
        opacity == null ? '' : opacity.toStringAsFixed(2),
        strikethrough != null && strikethrough ? 1 : 0,
        strikethroughThickness == null
            ? ''
            : strikethroughThickness.toStringAsFixed(2),
        strikethroughColor ?? 0,
      ];

  /// 1:1: `getOrCreateEntry(...)`
  int getOrCreateEntry(
    int? color,
    bool? bold,
    num? opacity,
    bool? strikethrough,
    num? strikethroughThickness,
    int? strikethroughColor,
  ) {
    if (color == null &&
        bold == null &&
        opacity == null &&
        strikethrough == null &&
        strikethroughThickness == null &&
        strikethroughColor == null) {
      return 0;
    }
    final List<Object> key = _styleKey(color, bold, opacity, strikethrough,
        strikethroughThickness, strikethroughColor);
    final IDecorationStyleCacheEntry? result = _cacheByStyle.get(key);
    if (result != null) {
      return result.id;
    }
    final int id = _nextId++;
    final IDecorationStyleCacheEntry entry = IDecorationStyleCacheEntry(
      id: id,
      color: color,
      bold: bold,
      opacity: opacity,
      strikethrough: strikethrough,
      strikethroughThickness: strikethroughThickness,
      strikethroughColor: strikethroughColor,
    );
    _cacheById[id] = entry;
    _cacheByStyle.set(entry, key);
    return id;
  }

  /// 1:1: `getStyleSet(id: number): IDecorationStyleSet | undefined`
  IDecorationStyleSet? getStyleSet(int id) {
    if (id == 0) {
      return null;
    }
    return _cacheById[id];
  }
}
