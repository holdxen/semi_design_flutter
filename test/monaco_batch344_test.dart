// 1:1 replay of
//   `editor/browser/viewParts/viewLines/viewLine.ts` (756 lines).
// Truth: `tool/ts2dart/_batch344_truth.cjs` -> `batch344_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/browser/viewParts/viewLines/domReadingContext.dart'
    show DomReadElement, DomReadingContext;
import 'package:semi_design_flutter/src/monaco/editor/browser/viewParts/viewLines/rangeUtil.dart'
    show ClientRect, IDomRange, IElementNode, RangeUtil, RangeUtilEnvironment;
import 'package:semi_design_flutter/src/monaco/editor/browser/viewParts/viewLines/viewLine.dart'
    show
        CharacterMapping,
        IViewLineElement,
        IViewLineSpan,
        IFastDomNode,
        IViewLineOptionsForLine,
        RenderLineInput,
        RenderLineOutput,
        ViewLine,
        configureViewLineFastDomNodeForReplay,
        configureViewLineRendererForReplay,
        setCanUseFastRenderedViewLineForReplay,
        setIsWebKitForViewLineReplay,
        setMonospaceAssumptionsForViewLineReplay;
import 'package:semi_design_flutter/src/monaco/editor/browser/view/renderingContext.dart'
    show FloatHorizontalRange, VisibleRanges;
import 'package:semi_design_flutter/src/monaco/editor/common/config/editorOptions.dart'
    show EditorFontLigatures;
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart' show Range;
import 'package:semi_design_flutter/src/monaco/editor/common/core/ranges/offsetRange.dart'
    show OffsetRange;
import 'package:semi_design_flutter/src/monaco/editor/common/core/selection.dart'
    show Selection;
import 'package:semi_design_flutter/src/monaco/editor/common/core/stringBuilder.dart'
    show StringBuilder;
import 'package:semi_design_flutter/src/monaco/editor/common/viewLayout/viewLinesViewportData.dart'
    show IPartialViewLinesViewportData, IViewModelForViewportData, ViewportData;
import 'package:semi_design_flutter/src/monaco/editor/common/viewModel/inlineDecorations.dart'
    show InlineDecoration;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/theme.dart'
    show ColorScheme;

const int _rangeExpand = 50;

Map<String, dynamic> _truth() => (jsonDecode(
      File('tool/ts2dart/batch344_truth.json').readAsStringSync(),
    ) as Map)
    .cast<String, dynamic>();

num? _jsonNum(num value) => value.isNaN ? null : value;

Map<String, Object?> _serializeVisible(VisibleRanges? value) {
  if (value == null) return <String, Object?>{};
  return <String, Object?>{
    'outsideRenderedLine': value.outsideRenderedLine,
    'ranges': value.ranges
        .map((FloatHorizontalRange r) => <Object?>[_jsonNum(r.left), _jsonNum(r.width)])
        .toList(),
  };
}

_IViewLineOptions _optionsFor({
  ColorScheme theme = ColorScheme.dark,
  String renderWhitespace = 'none',
  bool useMonospaceOptimizations = true,
  bool useGpu = false,
  bool useTwoCellFullwidthCharacters = false,
  num stopRenderingLineAfter = -1,
}) {
  return _IViewLineOptions(
    themeType: theme,
    renderWhitespace: renderWhitespace,
    experimentalWhitespaceRendering: 'off',
    renderControlCharacters: false,
    spaceWidth: 8,
    middotWidth: 8,
    wsmiddotWidth: 8,
    useMonospaceOptimizations: useMonospaceOptimizations,
    canUseHalfwidthRightwardsArrow: false,
    stopRenderingLineAfter: stopRenderingLineAfter,
    fontLigatures: EditorFontLigatures.OFF,
    verticalScrollbarSize: 10,
    useGpu: useGpu,
    useTwoCellFullwidthCharacters: useTwoCellFullwidthCharacters,
  );
}

class _IViewLineOptions implements IViewLineOptionsForLine {
  _IViewLineOptions({
    required this.themeType,
    required this.renderWhitespace,
    required this.experimentalWhitespaceRendering,
    required this.renderControlCharacters,
    required this.spaceWidth,
    required this.middotWidth,
    required this.wsmiddotWidth,
    required this.useMonospaceOptimizations,
    required this.canUseHalfwidthRightwardsArrow,
    required this.stopRenderingLineAfter,
    required this.fontLigatures,
    required this.verticalScrollbarSize,
    required this.useGpu,
    required this.useTwoCellFullwidthCharacters,
  });

  @override
  final ColorScheme themeType;
  @override
  final String renderWhitespace;
  @override
  final String experimentalWhitespaceRendering;
  @override
  final bool renderControlCharacters;
  @override
  final num spaceWidth;
  @override
  final num middotWidth;
  @override
  final num wsmiddotWidth;
  @override
  final bool useMonospaceOptimizations;
  @override
  final bool canUseHalfwidthRightwardsArrow;
  @override
  final num stopRenderingLineAfter;
  @override
  final String fontLigatures;
  @override
  final num verticalScrollbarSize;
  @override
  final bool useGpu;
  @override
  final bool useTwoCellFullwidthCharacters;
}

class _Tokens {
  const _Tokens(this.id);
  final String id;

  bool equals(Object other) => other is _Tokens && other.id == id;
}

class _LineData {
  _LineData({
    required this.content,
    this.maxColumn = 7,
    this.isBasicASCII = true,
  })  : continuesWithWrappedLine = false,
        containsRTL = false,
        minColumn = 1,
        tabSize = 4,
        startVisibleColumn = 0,
        hasVariableFonts = false,
        tokens = const _Tokens('tokens'),
        textDirection = 0;

  final String content;
  final int minColumn;
  final int maxColumn;
  final bool continuesWithWrappedLine;
  final bool isBasicASCII;
  final bool containsRTL;
  final List<InlineDecoration> inlineDecorations = const <InlineDecoration>[];
  final int tabSize;
  final int startVisibleColumn;
  final bool hasVariableFonts;
  final _Tokens tokens;
  final int textDirection;
}

class _ViewportModel implements IViewModelForViewportData {
  const _ViewportModel(this.lines);
  final List<_LineData> lines;

  @override
  int getLineMinColumn(int lineNumber) => 1;

  @override
  int getLineMaxColumn(int lineNumber) => lines[lineNumber - 1].maxColumn;

  @override
  Object getViewportViewLineRenderingData(Range visibleRange, int lineNumber) =>
      lines[lineNumber - 1];

  @override
  bool getViewLineContinuesWithWrappedLine(int lineNumber) => false;

  @override
  List<Object> getDecorationsInViewport(Range visibleRange) =>
      const <Object>[];

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

ViewportData _viewport(List<_LineData> lines, [List<Selection> selections = const <Selection>[]]) {
  final IPartialViewLinesViewportData partial = IPartialViewLinesViewportData(
    startLineNumber: 1,
    endLineNumber: lines.length,
    relativeVerticalOffset: List<num>.filled(lines.length, 0),
    bigNumbersDelta: 0,
    lineHeight: 20,
  );
  return ViewportData(selections, partial, const <Object>[], _ViewportModel(lines));
}

class _RectOwner {
  const _RectOwner(this.rectLeft);
  final num rectLeft;
}

class _FakeTextNode implements IElementNode {
  _FakeTextNode(this.owner, this.textContent);
  final _FakeSpan owner;
  @override
  String textContent;
  @override
  Object? get firstChild => null;
  @override
  List<IElementNode> get children => const <IElementNode>[];
  @override
  List<ClientRect> getClientRects() => owner.getClientRects();
}

class _FakeSpan implements IViewLineSpan {
  _FakeSpan(this.textContent, num rectLeft)
      : rectOwner = _RectOwner(rectLeft) {
    firstChildNode = _FakeTextNode(this, textContent);
  }

  final _RectOwner rectOwner;
  @override
  String textContent;
  @override
  num offsetWidth = 0;
  @override
  IViewLineSpan? previousSibling;
  late final _FakeTextNode firstChildNode;

  @override
  Object? get firstChild => firstChildNode;
  @override
  List<IElementNode> get children =>
      <IElementNode>[firstChildNode];
  @override
  List<ClientRect> getClientRects() =>
      <ClientRect>[ClientRect(rectOwner.rectLeft, offsetWidth)];
}

class _FakeTarget implements IViewLineSpan {
  _FakeTarget(List<_FakeSpan> spans)
      : children = List<IElementNode>.from(spans),
        offsetWidth = spans.fold<num>(0, (num sum, _FakeSpan s) => sum + s.offsetWidth) {
    firstSpan = spans.isEmpty ? null : spans.first;
  }

  late final _FakeSpan? firstSpan;
  @override
  final List<IElementNode> children;
  @override
  num offsetWidth;
  final num rectLeft = 10;

  @override
  String? get textContent => null;
  @override
  Object? get firstChild => firstSpan;
  @override
  IViewLineSpan? get previousSibling => null;
  @override
  List<ClientRect> getClientRects() =>
      <ClientRect>[ClientRect(rectLeft, offsetWidth)];
}

class _FakeElement implements IViewLineElement {
  _FakeElement(this.target);
  final _FakeTarget target;
  bool removed = false;

  @override
  IViewLineSpan? get firstChild => target;

  @override
  void remove() => removed = true;
}

class _FakeFastDomNode implements IFastDomNode {
  _FakeFastDomNode(this.domNode);
  @override
  final IViewLineElement domNode;
  final List<List<String>> log = <List<String>>[];

  @override
  void setTop(Object top) => log.add(<String>['top', top.toString()]);
  @override
  void setHeight(Object height) => log.add(<String>['height', height.toString()]);
  @override
  void setLineHeight(Object height) =>
      log.add(<String>['lineHeight', height.toString()]);
}

class _FakeRange implements IDomRange {
  Object? _start;
  Object? _end;
  int _startOffset = 0;
  int _endOffset = 0;

  @override
  void setStart(Object element, int offset) {
    _start = element;
    _startOffset = offset;
  }

  @override
  void setEnd(Object element, int offset) {
    _end = element;
    _endOffset = offset;
  }

  @override
  List<ClientRect>? getClientRects() {
    final dynamic s = _start;
    final dynamic e = _end;
    if (s == null || e == null) return null;
    final num sLeft = (s as _FakeTextNode).owner.rectOwner.rectLeft;
    final num eLeft = (e as _FakeTextNode).owner.rectOwner.rectLeft;
    final int so = _clamp(_startOffset, 0, s.textContent.length);
    final int eo = _clamp(_endOffset, 0, e.textContent.length);
    final num left = _minNum(sLeft + so * 2, eLeft + eo * 2);
    num width = (sLeft + so * 2 - (eLeft + eo * 2)).abs();
    if (so != eo) width += _rangeExpand;
    return <ClientRect>[ClientRect(left, width)];
  }

  @override
  void selectNodeContents(Object endNode) {}
}

int _clamp(int value, int min, int max) =>
    value < min ? min : (value > max ? max : value);

num _minNum(num a, num b) => a < b ? a : b;

class _Made {
  _Made(this.target, this.element);
  final _FakeTarget target;
  final _FakeElement element;
}

_Made _makeElement(List<String> texts) {
  final List<_FakeSpan> spans = <_FakeSpan>[
    for (final String text in texts)
      _FakeSpan(text, 10)..offsetWidth = text.length * 2,
  ];
  for (int i = 1; i < spans.length; i++) {
    spans[i].previousSibling = spans[i - 1];
  }
  final _FakeTarget target = _FakeTarget(spans);
  return _Made(target, _FakeElement(target));
}

DomReadingContext _context(_Made made) => DomReadingContext(
      DomReadElement(
        rectProvider: () => <String, num>{
          'left': made.target.rectLeft,
          'width': made.target.offsetWidth,
        },
        offsetWidth: made.target.offsetWidth,
      ),
      made.element,
    );

class _State {
  final List<_FakeFastDomNode> fastNodes = <_FakeFastDomNode>[];
  int nextForeign = 0;
  RenderLineInput? lastInput;
}

final _State _state = _State();

void _configure() {
  RangeUtil.configure(RangeUtilEnvironment(() => _FakeRange()));
  configureViewLineFastDomNodeForReplay((IViewLineElement element) {
    final _FakeFastDomNode node = _FakeFastDomNode(element);
    _state.fastNodes.add(node);
    return node;
  });
  configureViewLineRendererForReplay((RenderLineInput input, StringBuilder sb) {
    _state.lastInput = input;
    sb.appendString('<render:${input.lineContent}>');
    final CharacterMapping mapping = CharacterMapping(input.lineContent.length, 1);
    for (int column = 1; column <= input.lineContent.length; column++) {
      mapping.setColumnInfo(column, 0, column - 1, column * 2);
    }
    return RenderLineOutput(mapping, _state.nextForeign);
  });
}

void _reset({
  required bool fastAllowed,
  required bool webKit,
}) {
  _state.fastNodes.clear();
  _state.nextForeign = 0;
  _state.lastInput = null;
  setCanUseFastRenderedViewLineForReplay(fastAllowed);
  setIsWebKitForViewLineReplay(webKit);
  setMonospaceAssumptionsForViewLineReplay(true);
}

void main() {
  _configure();
  final Map<String, dynamic> truth = _truth();

  test('viewLine replay TS', () {
    final Map<String, Object?> actual = <String, Object?>{};

    // --- fast monospace path ------------------------------------------------
    _reset(fastAllowed: true, webKit: false);
    final ViewLine line = ViewLine(null, _optionsFor());
    final StringBuilder sb = StringBuilder(10000);
    final ViewportData vp = _viewport(<_LineData>[_LineData(content: 'abcdef')]);
    final Map<String, Object?> fast = <String, Object?>{
      'initial': <String, Object?>{
        'domNode': line.getDomNode(),
        'width': line.getWidth(null),
        'widthFast': line.getWidthIsFast(),
        'needsCheck': line.needsMonospaceFontCheck(),
        'valid': line.monospaceAssumptionsAreValid(),
      },
    };
    fast['render'] = line.renderLine(1, 10, 20, vp, sb);
    fast['html'] = sb.build();
    final _Made made = _makeElement(<String>['abcdef']);
    line.setDomNode(made.element);
    fast['domNodeSet'] = identical(line.getDomNode(), made.element);
    line.layoutLine(1, 30, 22);
    fast['layoutLog'] = _state.fastNodes.single.log
        .map((List<String> entry) => entry)
        .toList();
    final DomReadingContext ctx = _context(made);
    fast['ranges'] = _serializeVisible(
        line.getVisibleRangesForRange(1, 1, 4, ctx));
    fast['column'] = line.getColumnOfNodeOffset(made.target.firstSpan!, 3);
    final num width = line.getWidth(null);
    fast['width'] = width;
    made.target.offsetWidth = width;
    fast['validGood'] = line.monospaceAssumptionsAreValid();
    made.target.offsetWidth = width + 5;
    fast['validBad'] = line.monospaceAssumptionsAreValid();
    fast['needsBefore'] = line.needsMonospaceFontCheck();
    line.onMonospaceAssumptionsInvalidated();
    fast['needsAfter'] = line.needsMonospaceFontCheck();
    fast['widthSlow'] = line.getWidth(null);
    fast['didDomLayout'] = ctx.didDomLayout;
    actual['fast'] = fast;

    // --- slow path ----------------------------------------------------------
    _reset(fastAllowed: false, webKit: false);
    final ViewLine slow = ViewLine(null, _optionsFor(useMonospaceOptimizations: false));
    final StringBuilder slowSb = StringBuilder(10000);
    final Map<String, Object?> s = <String, Object?>{};
    s['render'] = slow.renderLine(
        1,
        5,
        21,
        _viewport(<_LineData>[_LineData(content: 'abc def', maxColumn: 8)]),
        slowSb);
    s['html'] = slowSb.build();
    s['needsCheck'] = slow.needsMonospaceFontCheck();
    s['widthFastBefore'] = slow.getWidthIsFast();
    final _Made slowMade = _makeElement(<String>['abc def']);
    slow.setDomNode(slowMade.element);
    final DomReadingContext slowCtx = _context(slowMade);
    s['width'] = slow.getWidth(slowCtx);
    s['widthFastAfter'] = slow.getWidthIsFast();
    s['fullLine'] = _serializeVisible(
        slow.getVisibleRangesForRange(1, 1, 7, slowCtx));
    s['partial'] = _serializeVisible(
        slow.getVisibleRangesForRange(1, 2, 4, slowCtx));
    s['point'] = _serializeVisible(
        slow.getVisibleRangesForRange(1, 3, 3, slowCtx));
    s['column'] = slow.getColumnOfNodeOffset(slowMade.target.firstSpan!, 3);
    slow.resetCachedWidth();
    s['widthFastReset'] = slow.getWidthIsFast();
    s['selectionChangedDark'] = slow.onSelectionChanged();

    final ViewLine highContrast = ViewLine(
        null, _optionsFor(useMonospaceOptimizations: false, theme: ColorScheme.highContrastDark));
    s['highContrastSelectionChanged'] = highContrast.onSelectionChanged();
    final StringBuilder highSb = StringBuilder(10000);
    highContrast.renderLine(
        1,
        0,
        20,
        _viewport(<_LineData>[_LineData(content: 'abc', maxColumn: 4)]),
        highSb);
    highContrast.onOptionsChanged(_optionsFor(
      useMonospaceOptimizations: false,
      theme: ColorScheme.highContrastDark,
      renderWhitespace: 'selection',
    ));
    highContrast.onContentChanged();
    highContrast.renderLine(
      1,
      0,
      20,
      _viewport(<_LineData>[_LineData(content: 'abc', maxColumn: 4)], <Selection>[
        Selection(1, 2, 1, 4),
      ]),
      highSb,
    );
    final RenderLineInput? highInput = _state.lastInput;
    s['highContrastInput'] = <String, Object?>{
      'decorations': highInput!.lineDecorations
          .map((dynamic d) => <Object?>[
                d.startColumn,
                d.endColumn,
                d.className,
                d.type,
              ])
          .toList(),
      'selections': (highInput.selectionsOnLine ?? <OffsetRange>[])
          .map((OffsetRange r) => <Object?>[r.start, r.endExclusive])
          .toList(),
      'renderWhitespace': highInput.renderWhitespace,
    };

    final ViewLine emptyLine =
        ViewLine(null, _optionsFor(useMonospaceOptimizations: false));
    emptyLine.renderLine(
        1,
        0,
        20,
        _viewport(<_LineData>[_LineData(content: '', maxColumn: 1)]),
        StringBuilder(10000));
    final _Made emptyMade = _makeElement(<String>['']);
    emptyMade.target.firstSpan!.offsetWidth = 20;
    emptyLine.setDomNode(emptyMade.element);
    s['emptyNone'] = _serializeVisible(
        emptyLine.getVisibleRangesForRange(1, 1, 1, _context(emptyMade)));

    _state.nextForeign = 1;
    final ViewLine afterLine =
        ViewLine(null, _optionsFor(useMonospaceOptimizations: false));
    afterLine.renderLine(
        1,
        0,
        20,
        _viewport(<_LineData>[_LineData(content: '', maxColumn: 1)]),
        StringBuilder(10000));
    final _Made afterMade = _makeElement(<String>['']);
    afterMade.target.firstSpan!.offsetWidth = 20;
    afterLine.setDomNode(afterMade.element);
    s['emptyAfter'] = _serializeVisible(
        afterLine.getVisibleRangesForRange(1, 1, 1, _context(afterMade)));

    _state.nextForeign = 2;
    final ViewLine beforeLine =
        ViewLine(null, _optionsFor(useMonospaceOptimizations: false));
    beforeLine.renderLine(
        1,
        0,
        20,
        _viewport(<_LineData>[_LineData(content: '', maxColumn: 1)]),
        StringBuilder(10000));
    final _Made beforeMade = _makeElement(<String>['']);
    beforeMade.target.firstSpan!.offsetWidth = 20;
    beforeLine.setDomNode(beforeMade.element);
    s['emptyBefore'] = _serializeVisible(
        beforeLine.getVisibleRangesForRange(1, 1, 1, _context(beforeMade)));
    _state.nextForeign = 0;

    final ViewLine wideLine = ViewLine(
        null,
        _optionsFor(
            useMonospaceOptimizations: false,
            useTwoCellFullwidthCharacters: true));
    wideLine.renderLine(
        1,
        0,
        20,
        _viewport(<_LineData>[
          _LineData(content: 'Ａ', maxColumn: 2, isBasicASCII: false),
        ]),
        StringBuilder(10000));
    final _Made wideMade = _makeElement(<String>['Ａ']);
    wideMade.target.firstSpan!.offsetWidth = 4;
    wideLine.setDomNode(wideMade.element);
    s['fullWidth'] = _serializeVisible(
        wideLine.getVisibleRangesForRange(1, 1, 2, _context(wideMade)));
    actual['slow'] = s;

    // --- GPU hand-off -------------------------------------------------------
    _reset(fastAllowed: false, webKit: false);
    final Object gpu = _GpuContext();
    final ViewLine gpuLine = ViewLine(gpu, _optionsFor(useGpu: true));
    final StringBuilder gpuSb = StringBuilder(10000);
    final Map<String, Object?> g = <String, Object?>{
      'neverRendered': gpuLine.renderLine(
          1, 0, 20, _viewport(<_LineData>[_LineData(content: 'abcdef')]), gpuSb),
    };
    final ViewLine replacement = ViewLine(
        gpu, _optionsFor(useMonospaceOptimizations: false));
    replacement.renderLine(
        1,
        0,
        20,
        _viewport(<_LineData>[_LineData(content: 'abcdef')]),
        gpuSb);
    final _Made gpuMade = _makeElement(<String>['abcdef']);
    replacement.setDomNode(gpuMade.element);
    replacement.onOptionsChanged(
        _optionsFor(useMonospaceOptimizations: false, useGpu: true));
    g['render'] = replacement.renderLine(
        1,
        0,
        20,
        _viewport(<_LineData>[_LineData(content: 'abcdef')]),
        gpuSb);
    g['removed'] = gpuMade.element.removed;
    g['domNode'] = replacement.getDomNode();
    g['width'] = replacement.getWidth(null);
    actual['gpu'] = g;

    // --- WebKit trimming ----------------------------------------------------
    _reset(fastAllowed: false, webKit: true);
    final ViewLine webkit =
        ViewLine(null, _optionsFor(useMonospaceOptimizations: false));
    webkit.renderLine(
        1,
        0,
        20,
        _viewport(<_LineData>[_LineData(content: 'abcdef')]),
        StringBuilder(10000));
    final _Made webkitMade = _makeElement(<String>['abcdef']);
    webkit.setDomNode(webkitMade.element);
    actual['webkit'] = _serializeVisible(
        webkit.getVisibleRangesForRange(1, 1, 4, _context(webkitMade)));

    // --- stopRenderingLineAfter --------------------------------------------
    _reset(fastAllowed: false, webKit: false);
    final ViewLine stopLine =
        ViewLine(null, _optionsFor(useMonospaceOptimizations: false));
    final StringBuilder stopSb = StringBuilder(10000);
    stopLine.renderLine(
        1,
        0,
        20,
        _viewport(<_LineData>[_LineData(content: 'abcdef', maxColumn: 7)]),
        stopSb);
    final _Made stopMade = _makeElement(<String>['abcdef']);
    stopLine.setDomNode(stopMade.element);
    stopLine.onOptionsChanged(_optionsFor(
      useMonospaceOptimizations: false,
      stopRenderingLineAfter: 2,
    ));
    stopLine.onContentChanged();
    stopLine.renderLine(
        1,
        0,
        20,
        _viewport(<_LineData>[_LineData(content: 'abcdef', maxColumn: 7)]),
        stopSb);
    stopMade.target.firstSpan!.offsetWidth = 12;
    stopLine.resetCachedWidth();
    actual['stop'] = _serializeVisible(
        stopLine.getVisibleRangesForRange(1, 5, 6, _context(stopMade)));

    expect(actual, truth);
  });
}

class _GpuContext {
  bool canRender(Object options, Object viewportData, int lineNumber) => true;
}
