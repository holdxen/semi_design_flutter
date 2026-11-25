// 1:1 port of vscode/src/vs/editor/common/viewModel.ts (448 lines).
//
// The source is mostly erased interfaces (IViewModel, IViewLayout,
// IEditorWhitespace, IWhitespaceChangeAccessor, ILineHeightChangeAccessor,
// IPartialViewLinesViewportData, IViewWhitespaceViewportData) plus 6 runtime
// classes ported here:
//   - `Viewport` (ctor truncates each field with `| 0`),
//   - `MinimapLinesRenderingData` (carrier),
//   - `ViewLineData` (carrier),
//   - `ViewLineRenderingData` (ctor derives isBasicASCII / containsRTL via
//     strings.isBasicASCII / strings.containsRTL; 2 static helpers),
//   - `ViewModelDecoration` (carrier),
//   - `OverviewRulerDecorationsGroup` (compareByRenderingProps / equals /
//     equalsArr via arrays.equals).
//
// Adaptations (documented inline):
//  * opaque brand fields (`_viewportBrand`, `_viewLineDataBrand`,
//    `_viewModelDecorationBrand`) are `void = undefined` in TS and carry no
//    data - omitted in Dart;
//  * erased interfaces used as field types (`IViewLineTokens`,
//    `IModelDecorationOptions`, `InlineDecoration`) are carried structurally
//    as `Object?` / `List<Object?>`;
//  * `TextDirection` is a TS enum - carried as `int` (repo convention);
//  * JS `| 0` truncates toward zero (and wraps to int32) - `_jsTrunc0`
//    mirrors it for the values the editor uses.
import '../../base/common/arrays.dart' as arrays show equals;
import '../../base/common/strings.dart' show containsRTL, isBasicASCII;
import './core/range.dart' show Range;

/// JS `value | 0`: ToInt32 - truncate toward zero then wrap into 32-bit int.
/// The editor's viewport inputs are small non-negative pixel values, so a
/// toward-zero truncation matches; the int32 wrap is kept for fidelity.
int _jsTrunc0(num value) {
  final int t = value.toInt(); // toward zero, matches JS for finite numbers
  // ToInt32 wrap: JS `| 0` reduces modulo 2^32 into signed int32 range.
  const int mask = 0xFFFFFFFF;
  final int unsigned = t & mask;
  return unsigned >= 0x80000000 ? unsigned - 0x100000000 : unsigned;
}

/// 1:1: `export class Viewport`.
class Viewport {
  Viewport(num top, num left, num width, num height)
      : top = _jsTrunc0(top),
        left = _jsTrunc0(left),
        width = _jsTrunc0(width),
        height = _jsTrunc0(height);

  final int top;
  final int left;
  final int width;
  final int height;
}

/// 1:1: `export class MinimapLinesRenderingData`.
class MinimapLinesRenderingData {
  MinimapLinesRenderingData(this.tabSize, this.data);

  final int tabSize;
  final List<Object?> data;
}

/// 1:1: `export class ViewLineData`.
class ViewLineData {
  ViewLineData(
    this.content,
    this.continuesWithWrappedLine,
    this.minColumn,
    this.maxColumn,
    this.startVisibleColumn,
    this.tokens,
    this.inlineDecorations,
  );

  final String content;
  final bool continuesWithWrappedLine;
  final int minColumn;
  final int maxColumn;
  final int startVisibleColumn;

  /// Erased `IViewLineTokens` - carried structurally.
  final Object? tokens;

  /// Erased `readonly InlineDecoration[] | null`.
  final List<Object?>? inlineDecorations;
}

/// 1:1: `export class ViewLineRenderingData`.
class ViewLineRenderingData {
  ViewLineRenderingData(
    this.minColumn,
    this.maxColumn,
    this.content,
    this.continuesWithWrappedLine,
    bool mightContainRTL,
    bool mightContainNonBasicASCII,
    this.tokens,
    this.inlineDecorations,
    this.tabSize,
    this.startVisibleColumn,
    this.textDirection,
    this.hasVariableFonts,
  )   : isBasicASCII = ViewLineRenderingData.staticIsBasicASCII(
            content, mightContainNonBasicASCII),
        containsRTL = ViewLineRenderingData.staticContainsRTL(
            content,
            ViewLineRenderingData.staticIsBasicASCII(
                content, mightContainNonBasicASCII),
            mightContainRTL);

  final int minColumn;
  final int maxColumn;
  final String content;
  final bool continuesWithWrappedLine;
  final bool containsRTL;
  final bool isBasicASCII;

  /// Erased `IViewLineTokens`.
  final Object? tokens;

  /// Erased `InlineDecoration[]`.
  final List<Object?> inlineDecorations;
  final int tabSize;
  final int startVisibleColumn;

  /// 1:1: `textDirection: TextDirection` (int enum carrier).
  final int textDirection;
  final bool hasVariableFonts;

  // Dart forbids a static member and an instance field with the same name,
  // so the TS statics `isBasicASCII` / `containsRTL` are exposed here with a
  // `static` prefix; the instance fields keep the TS field names above.

  /// 1:1: `public static isBasicASCII(lineContent, mightContainNonBasicASCII)`.
  static bool staticIsBasicASCII(
      String lineContent, bool mightContainNonBasicASCII) {
    if (mightContainNonBasicASCII) {
      return _basicAscii(lineContent);
    }
    return true;
  }

  /// 1:1: `public static containsRTL(lineContent, isBasicASCII, mightContainRTL)`.
  static bool staticContainsRTL(
    String lineContent,
    bool isBasicASCII,
    bool mightContainRTL,
  ) {
    if (!isBasicASCII && mightContainRTL) {
      return _rtl(lineContent);
    }
    return false;
  }
}

// Indirection so the static helpers can be swapped if a test needs the raw
// strings helpers; by default they are the 1:1 imports.
bool _basicAscii(String s) => isBasicASCII(s);
bool _rtl(String s) => containsRTL(s);

/// 1:1: `export class ViewModelDecoration`.
class ViewModelDecoration {
  ViewModelDecoration(this.range, this.options);

  final Range range;

  /// Erased `IModelDecorationOptions` - carried structurally.
  final Object? options;
}

/// 1:1: `export class OverviewRulerDecorationsGroup`.
class OverviewRulerDecorationsGroup {
  OverviewRulerDecorationsGroup(this.color, this.zIndex, this.data);

  final String color;
  final int zIndex;
  final List<int> data;

  /// 1:1: `public static compareByRenderingProps(a, b)`.
  static int compareByRenderingProps(
    OverviewRulerDecorationsGroup a,
    OverviewRulerDecorationsGroup b,
  ) {
    if (a.zIndex == b.zIndex) {
      if (a.color.compareTo(b.color) < 0) return -1;
      if (a.color.compareTo(b.color) > 0) return 1;
      return 0;
    }
    return a.zIndex - b.zIndex;
  }

  /// 1:1: `public static equals(a, b)`.
  static bool equals(
    OverviewRulerDecorationsGroup a,
    OverviewRulerDecorationsGroup b,
  ) =>
      a.color == b.color &&
      a.zIndex == b.zIndex &&
      arrays.equals<int>(a.data, b.data);

  /// 1:1: `public static equalsArr(a, b)`.
  static bool equalsArr(
    List<OverviewRulerDecorationsGroup> a,
    List<OverviewRulerDecorationsGroup> b,
  ) =>
      arrays.equals<OverviewRulerDecorationsGroup>(a, b, equals);
}
