// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/2d/rect.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. TS overloads (`withMargin`) collapsed to a
// named-optional Dart signature; `Number.MAX_SAFE_INTEGER` -> large int const.
// ---------------------------------------------------------------------------

import '../../../../base/common/errors.dart';
import '../ranges/offsetRange.dart';
import './point.dart';
import './size.dart';

class Rect {
  static Rect fromPoint(Point point) => Rect(point.x, point.y, point.x, point.y);

  static Rect fromPoints(Point topLeft, Point bottomRight) =>
      Rect(topLeft.x, topLeft.y, bottomRight.x, bottomRight.y);

  static Rect fromPointSize(Point point, Point size) =>
      Rect(point.x, point.y, point.x + size.x, point.y + size.y);

  static Rect fromLeftTopRightBottom(num left, num top, num right, num bottom) =>
      Rect(left, top, right, bottom);

  static Rect fromLeftTopWidthHeight(num left, num top, num width, num height) =>
      Rect(left, top, left + width, top + height);

  static Rect fromRanges(OffsetRange leftRight, OffsetRange topBottom) =>
      Rect(leftRight.start, topBottom.start, leftRight.endExclusive, topBottom.endExclusive);

  static Rect hull(List<Rect> rects) {
    num left = _maxSafeInt;
    num top = _maxSafeInt;
    num right = -_maxSafeInt;
    num bottom = -_maxSafeInt;

    for (final Rect rect in rects) {
      left = left < rect.left ? left : rect.left;
      top = top < rect.top ? top : rect.top;
      right = right > rect.right ? right : rect.right;
      bottom = bottom > rect.bottom ? bottom : rect.bottom;
    }

    return Rect(left, top, right, bottom);
  }

  static const int _maxSafeInt = 9007199254740991; // Number.MAX_SAFE_INTEGER

  num get width => this.right - this.left;
  num get height => this.bottom - this.top;

  late final num left;
  late final num top;
  late final num right;
  late final num bottom;

  Rect(num left, num top, num right, num bottom)
      : left = left,
        top = top,
        right = right,
        bottom = bottom {
    if (left > right) {
      throw BugIndicatingError('Invalid arguments: Horizontally offset by ' + (left - right).toString());
    }
    if (top > bottom) {
      throw BugIndicatingError('Invalid arguments: Vertically offset by ' + (top - bottom).toString());
    }
  }

  /// TS overloads: withMargin(margin) / withMargin(v,h) / withMargin(t,r,b,l).
  /// Positional optional params preserve the source call forms.
  Rect withMargin(num marginOrVerticalOrTop, [num? rightOrHorizontal, num? bottom, num? left]) {
    late final num marginLeft;
    late final num marginRight;
    late final num marginTop;
    late final num marginBottom;

    // Single margin value
    if (rightOrHorizontal == null && bottom == null && left == null) {
      marginLeft = marginOrVerticalOrTop;
      marginRight = marginOrVerticalOrTop;
      marginTop = marginOrVerticalOrTop;
      marginBottom = marginOrVerticalOrTop;
    }
    // Vertical and horizontal margins
    else if (bottom == null && left == null) {
      marginRight = rightOrHorizontal!;
      marginLeft = marginRight;
      marginTop = marginOrVerticalOrTop;
      marginBottom = marginTop;
    }
    // Individual margins for all sides
    else {
      marginLeft = left!;
      marginRight = rightOrHorizontal!;
      marginTop = marginOrVerticalOrTop;
      marginBottom = bottom!;
    }

    return Rect(
      this.left - marginLeft,
      this.top - marginTop,
      this.right + marginRight,
      this.bottom + marginBottom,
    );
  }

  Rect intersectVertical(OffsetRange range) {
    final num newTop = this.top > range.start ? this.top : range.start;
    final num newBottom = this.bottom < range.endExclusive ? this.bottom : range.endExclusive;
    return Rect(
      this.left,
      newTop,
      this.right,
      newTop > newBottom ? newTop : newBottom,
    );
  }

  Rect intersectHorizontal(OffsetRange range) {
    final num newLeft = this.left > range.start ? this.left : range.start;
    final num newRight = this.right < range.endExclusive ? this.right : range.endExclusive;
    return Rect(
      newLeft,
      this.top,
      newLeft > newRight ? newLeft : newRight,
      this.bottom,
    );
  }

  @override
  String toString() => 'Rect{(' + this.left.toString() + ',' + this.top.toString() + '), (' +
      this.right.toString() + ',' + this.bottom.toString() + ')}';

  Rect? intersect(Rect parent) {
    final num left = this.left > parent.left ? this.left : parent.left;
    final num right = this.right < parent.right ? this.right : parent.right;
    final num top = this.top > parent.top ? this.top : parent.top;
    final num bottom = this.bottom < parent.bottom ? this.bottom : parent.bottom;

    if (left > right || top > bottom) {
      return null;
    }

    return Rect(left, top, right, bottom);
  }

  Rect union(Rect other) => Rect(
        this.left < other.left ? this.left : other.left,
        this.top < other.top ? this.top : other.top,
        this.right > other.right ? this.right : other.right,
        this.bottom > other.bottom ? this.bottom : other.bottom,
      );

  bool containsRect(Rect other) =>
      this.left <= other.left &&
      this.top <= other.top &&
      this.right >= other.right &&
      this.bottom >= other.bottom;

  bool containsPoint(Point point) =>
      this.left <= point.x && this.top <= point.y && this.right >= point.x && this.bottom >= point.y;

  Rect moveToBeContainedIn(Rect parent) {
    final num width = this.width;
    final num height = this.height;

    num left = this.left;
    num top = this.top;

    if (left < parent.left) {
      left = parent.left;
    } else if (left + width > parent.right) {
      left = parent.right - width;
    }

    if (top < parent.top) {
      top = parent.top;
    } else if (top + height > parent.bottom) {
      top = parent.bottom - height;
    }

    return Rect(left, top, left + width, top + height);
  }

  Rect withWidth(num width) => Rect(this.left, this.top, this.left + width, this.bottom);

  Rect withHeight(num height) => Rect(this.left, this.top, this.right, this.top + height);

  Rect withTop(num top) => Rect(this.left, top, this.right, this.bottom);

  Rect withLeft(num left) => Rect(left, this.top, this.right, this.bottom);

  Rect translateX(num delta) => Rect(this.left + delta, this.top, this.right + delta, this.bottom);

  Rect translateY(num delta) => Rect(this.left, this.top + delta, this.right, this.bottom + delta);

  Rect translate(Point point) => Rect(
        this.left + point.x,
        this.top + point.y,
        this.right + point.x,
        this.bottom + point.y,
      );

  Rect deltaRight(num delta) => Rect(this.left, this.top, this.right + delta, this.bottom);

  Rect deltaTop(num delta) => Rect(this.left, this.top + delta, this.right, this.bottom);

  Rect deltaLeft(num delta) => Rect(this.left + delta, this.top, this.right, this.bottom);

  Rect deltaBottom(num delta) => Rect(this.left, this.top, this.right, this.bottom + delta);

  Point getLeftBottom() => Point(this.left, this.bottom);

  Point getRightBottom() => Point(this.right, this.bottom);

  Point getLeftTop() => Point(this.left, this.top);

  Point getRightTop() => Point(this.right, this.top);

  /// Source returns a CSS style object; Dart carries it as a Map.
  Map<String, String> toStyles() => <String, String>{
        'position': 'absolute',
        'left': this.left.toString() + 'px',
        'top': this.top.toString() + 'px',
        'width': this.width.toString() + 'px',
        'height': this.height.toString() + 'px',
      };

  OffsetRange getHorizontalRange() => OffsetRange(this.left.toInt(), this.right.toInt());

  OffsetRange getVerticalRange() => OffsetRange(this.top.toInt(), this.bottom.toInt());

  Rect withHorizontalRange(OffsetRange range) =>
      Rect(range.start, this.top, range.endExclusive, this.bottom);

  Rect withVerticalRange(OffsetRange range) =>
      Rect(this.left, range.start, this.right, range.endExclusive);

  Size2D getSize() => Size2D(this.width, this.height);
}
