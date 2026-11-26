import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/browser/view/renderingContext.dart'
    show FloatHorizontalRange;
import '../lib/src/monaco/editor/browser/viewParts/viewLines/rangeUtil.dart'
    show
        ClientRect,
        IDomRange,
        IElementNode,
        IRangeReadingContext,
        RangeUtil,
        RangeUtilEnvironment;

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root =
      jsonDecode(File('tool/ts2dart/batch439_truth.json').readAsStringSync())
          as Map<String, dynamic>;
  return <String, dynamic>{
    for (final dynamic r in root['results'] as List<dynamic>)
      (r as Map)['label'] as String: <String, dynamic>{
        for (final MapEntry<Object?, Object?> e
            in (r as Map).cast<Object?, Object?>().entries)
          if (e.key != 'label') e.key as String: e.value,
      },
  };
}

Object? _norm(Object? v) => v is num && v == v.round() ? v.toInt() : v;
Object? _rangesJson(List<FloatHorizontalRange>? ranges) => ranges
    ?.map((FloatHorizontalRange r) => <Object?>[_norm(r.left), _norm(r.width)])
    .toList();

class _Element implements IElementNode {
  final String? text;
  final List<ClientRect> rects;
  final List<IElementNode> children;
  _Element(this.text, this.rects, [this.children = const <IElementNode>[]]);

  @override
  Object? get firstChild => text == null ? null : _TextNode(text!);
  @override
  String? get textContent => text;
  @override
  List<ClientRect> getClientRects() => rects;
}

class _TextNode implements IElementNode {
  final String text;
  _TextNode(this.text);
  @override
  Object? get firstChild => null;
  @override
  String? get textContent => text;
  @override
  List<IElementNode> get children => const <IElementNode>[];
  @override
  List<ClientRect> getClientRects() => const <ClientRect>[];
}

class _Context implements IRangeReadingContext {
  @override
  Object get endNode => Object();
  @override
  num get clientRectDeltaLeft => 0;
  @override
  num get clientRectScale => 1;
  @override
  void markDidDomLayout() {}
}

class _DomRange implements IDomRange {
  int startOffset = 0;
  int endOffset = 0;
  @override
  void setStart(Object element, int offset) => startOffset = offset;
  @override
  void setEnd(Object element, int offset) => endOffset = offset;
  @override
  List<ClientRect>? getClientRects() => <ClientRect>[
        ClientRect(startOffset * 5, (endOffset - startOffset) * 5),
      ];
  @override
  void selectNodeContents(Object endNode) {}
}

void main() {
  final Map<String, dynamic> truth = _truth();

  setUp(() {
    RangeUtil.configure(RangeUtilEnvironment(() => _DomRange()));
  });

  test('range util truth replay', () {
    final Map<String, Object?> actual = <String, Object?>{};

    void merge(String label, List<List<num>> rects) {
      final List<FloatHorizontalRange> input = rects
          .map((List<num> r) => FloatHorizontalRange(r[0], r[1]))
          .toList();
      actual[label] = <String, Object?>{
        'value': _rangesJson(RangeUtil.mergeAdjacentRangesForReplay(input)),
      };
    }

    void fromRects(String label, List<List<num>> rects, num delta, num scale) {
      final List<ClientRect> input = rects
          .map((List<num> r) => ClientRect(r[0], r[1]))
          .toList();
      actual[label] = <String, Object?>{
        'value': _rangesJson(
            RangeUtil.horizontalRangesFromRectsForReplay(input, delta, scale)),
      };
    }

    merge('merge-single', <List<num>>[<num>[10, 5]]);
    merge('merge-adjacent', <List<num>>[
      <num>[0, 10], <num>[10.5, 5], <num>[20, 3], <num>[30, 4],
    ]);
    merge('merge-unsorted', <List<num>>[
      <num>[20, 3], <num>[0, 10], <num>[10.5, 5],
    ]);
    fromRects('rects-delta-scale', <List<num>>[
      <num>[110, 20], <num>[200, 10],
    ], 100, 2);
    actual['rects-empty'] = <String, Object?>{
      'value': _rangesJson(
          RangeUtil.horizontalRangesFromRectsForReplay(<ClientRect>[], 0, 1)),
      'nullValue': RangeUtil.horizontalRangesFromRectsForReplay(null, 0, 1),
    };

    final _Context context = _Context();

    // readHorizontalRanges: normal text span
    {
      final span = _Element('hello', <ClientRect>[ClientRect(10, 25)]);
      final node = _Element(null, const <ClientRect>[], <IElementNode>[span]);
      final List<FloatHorizontalRange>? ranges =
          RangeUtil.readHorizontalRanges(node, 0, 1, 0, 4, context);
      actual['read-range'] = <String, Object?>{'value': _rangesJson(ranges)};
    }
    // empty span at beginning
    {
      final span = _Element(null, <ClientRect>[ClientRect(10, 25)]);
      final node = _Element(null, const <ClientRect>[], <IElementNode>[span]);
      final List<FloatHorizontalRange>? ranges =
          RangeUtil.readHorizontalRanges(node, 0, 0, 0, 0, context);
      actual['read-empty-span'] = <String, Object?>{'value': _rangesJson(ranges)};
    }
    // no children
    {
      final node = _Element(null, const <ClientRect>[]);
      final List<FloatHorizontalRange>? ranges =
          RangeUtil.readHorizontalRanges(node, 0, 0, 0, 0, context);
      actual['read-no-children'] = <String, Object?>{'value': _rangesJson(ranges)};
    }
    // readHorizontalRangeForElement
    {
      final child = _Element('x', <ClientRect>[ClientRect(15, 8)]);
      final node = _Element(null, const <ClientRect>[], <IElementNode>[child]);
      final FloatHorizontalRange? range =
          RangeUtil.readHorizontalRangeForElement(node, 0, context);
      actual['read-element'] = <String, Object?>{
        'value': range == null ? null : <Object?>[_norm(range.left), _norm(range.width)],
      };
      final FloatHorizontalRange? missing =
          RangeUtil.readHorizontalRangeForElement(node, 5, context);
      actual['read-element-oob'] = <String, Object?>{
        'value': missing == null
            ? null
            : <Object?>[_norm(missing.left), _norm(missing.width)],
      };
    }

    expect(jsonEncode(actual), jsonEncode(truth));
  });
}
