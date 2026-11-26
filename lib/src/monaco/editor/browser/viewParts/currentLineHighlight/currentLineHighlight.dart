// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/viewParts/currentLineHighlight/
//   currentLineHighlight.ts
// Translated 1:1. Structure, members and semantics preserved.
// Verified against the TypeScript transpile truth (batch436).
//
// Adaptations: ViewContext / configuration / viewModel / converter /
// RenderingContext are narrow carriers so the overlays can be replayed.
// ---------------------------------------------------------------------------

import '../../../../base/common/arrays.dart' as arrays;
import '../../view/dynamicViewOverlay.dart' show DynamicViewOverlay;
import '../../view/renderingContext.dart' show RenderingContext;
import '../../../common/config/editorOptions.dart' show EditorOption;
import '../../../common/core/position.dart' show Position;
import '../../../common/core/selection.dart' show Selection;

/// JS number-to-string (no trailing `.0` for integral doubles).
String _jsNum(num value) {
  if (value is int) return value.toString();
  if (value == value.truncate()) return value.toInt().toString();
  return value.toString();
}

/// 1:1: `AbstractLineHighlightOverlay`.
abstract class AbstractLineHighlightOverlay extends DynamicViewOverlay {
  final Object _context;
  late String _renderLineHighlight;
  late bool _wordWrap;
  late num _contentLeft;
  late num _contentWidth;
  bool _selectionIsEmpty = true;
  late bool _renderLineHighlightOnlyWhenFocus;
  bool _focused = false;
  List<int> _cursorLineNumbers = <int>[1];
  List<Selection> _selections = <Selection>[Selection(1, 1, 1, 1)];
  List<String>? _renderData;

  AbstractLineHighlightOverlay(this._context) {
    _readConfig();
    (_context as dynamic).addEventHandler(this);
  }

  void _readConfig() {
    final dynamic options = (_context as dynamic).configuration.options;
    final dynamic layoutInfo = options.get(EditorOption.layoutInfo);
    Object liField(String name) => layoutInfo is Map
        ? layoutInfo[name] as Object
        : layoutInfo.$name as Object;
    _renderLineHighlight = options.get(EditorOption.renderLineHighlight) as String;
    _renderLineHighlightOnlyWhenFocus =
        options.get(EditorOption.renderLineHighlightOnlyWhenFocus) as bool;
    _wordWrap = liField('isViewportWrapping') as bool;
    _contentLeft = liField('contentLeft') as num;
    _contentWidth = liField('contentWidth') as num;
  }

  @override
  void dispose() {
    (_context as dynamic).removeEventHandler(this);
    super.dispose();
  }

  bool _readFromSelections() {
    bool hasChanged = false;

    final Set<int> lineNumbers = <int>{};
    for (final Selection selection in _selections) {
      lineNumbers.add(selection.positionLineNumber);
    }
    final List<int> cursorsLineNumbers = lineNumbers.toList();
    cursorsLineNumbers.sort();
    if (!arrays.equals<int>(_cursorLineNumbers, cursorsLineNumbers)) {
      _cursorLineNumbers = cursorsLineNumbers;
      hasChanged = true;
    }

    final bool selectionIsEmpty = _selections.every((Selection s) => s.isEmpty());
    if (_selectionIsEmpty != selectionIsEmpty) {
      _selectionIsEmpty = selectionIsEmpty;
      hasChanged = true;
    }

    return hasChanged;
  }

  @override
  bool onThemeChanged(Object e) => _readFromSelections();

  @override
  bool onConfigurationChanged(Object e) {
    _readConfig();
    return true;
  }

  @override
  bool onCursorStateChanged(Object e) {
    final dynamic ev = e;
    _selections = (e is List<Selection>
        ? e
        : (ev.selections as List).cast<Selection>());
    return _readFromSelections();
  }

  @override
  bool onFlushed(Object e) => true;

  @override
  bool onLinesDeleted(Object e) => true;

  @override
  bool onLinesInserted(Object e) => true;

  @override
  bool onScrollChanged(Object e) {
    final dynamic ev = e;
    if (ev is Map) {
      return ev['scrollWidthChanged'] == true || ev['scrollTopChanged'] == true;
    }
    return ev.scrollWidthChanged as bool || ev.scrollTopChanged as bool;
  }

  @override
  bool onZonesChanged(Object e) => true;

  @override
  bool onFocusChanged(Object e) {
    if (!_renderLineHighlightOnlyWhenFocus) {
      return false;
    }
    final dynamic ev = e;
    _focused = ev is Map ? ev['isFocused'] == true : ev.isFocused as bool;
    return true;
  }

  @override
  void prepareRender(RenderingContext ctx) {
    if (!_shouldRenderThis()) {
      _renderData = null;
      return;
    }
    final dynamic rctx = ctx;
    final int visibleStartLineNumber = (rctx.visibleRange.startLineNumber as num).toInt();
    final int visibleEndLineNumber = (rctx.visibleRange.endLineNumber as num).toInt();

    // initialize renderData (contiguous loop → append mirrors JS index writes)
    final List<String> renderData = <String>[];
    for (int lineNumber = visibleStartLineNumber;
        lineNumber <= visibleEndLineNumber;
        lineNumber++) {
      renderData.add('');
    }

    if (_wordWrap) {
      // do a first pass to render wrapped lines
      final String renderedLineWrapped = _renderOne(ctx, false);
      final dynamic converter =
          (_context as dynamic).viewModel.coordinatesConverter;
      for (final int cursorLineNumber in _cursorLineNumbers) {
        final int modelLineNumber = (converter.convertViewPositionToModelPosition(
                Position(cursorLineNumber, 1)) as Position)
            .lineNumber;
        final int firstViewLineNumber =
            (converter.convertModelPositionToViewPosition(Position(modelLineNumber, 1)) as Position)
                .lineNumber;
        final int maxCol = (_context as dynamic).viewModel.model.getLineMaxColumn(modelLineNumber) as int;
        final int lastViewLineNumber =
            (converter.convertModelPositionToViewPosition(Position(modelLineNumber, maxCol)) as Position)
                .lineNumber;

        final int firstLine = firstViewLineNumber > visibleStartLineNumber
            ? firstViewLineNumber
            : visibleStartLineNumber;
        final int lastLine = lastViewLineNumber < visibleEndLineNumber
            ? lastViewLineNumber
            : visibleEndLineNumber;
        for (int lineNumber = firstLine; lineNumber <= lastLine; lineNumber++) {
          final int lineIndex = lineNumber - visibleStartLineNumber;
          if (lineIndex >= 0 && lineIndex < renderData.length) {
            renderData[lineIndex] = renderedLineWrapped;
          }
        }
      }
    }

    // do a second pass to render exact lines
    final String renderedLineExact = _renderOne(ctx, true);
    for (final int cursorLineNumber in _cursorLineNumbers) {
      if (cursorLineNumber < visibleStartLineNumber ||
          cursorLineNumber > visibleEndLineNumber) {
        continue;
      }
      final int lineIndex = cursorLineNumber - visibleStartLineNumber;
      renderData[lineIndex] = renderedLineExact;
    }

    _renderData = renderData;
  }

  @override
  String render(int startLineNumber, int lineNumber) {
    final List<String>? data = _renderData;
    if (data == null) {
      return '';
    }
    final int lineIndex = lineNumber - startLineNumber;
    // Source only guards `lineIndex >= length`; negative indices yield JS
    // `undefined` (omitted by JSON.stringify). Replay returns '' for those.
    if (lineIndex < 0 || lineIndex >= data.length) {
      return '';
    }
    return data[lineIndex];
  }

  bool _shouldRenderInMargin() =>
      (_renderLineHighlight == 'gutter' || _renderLineHighlight == 'all') &&
      (!_renderLineHighlightOnlyWhenFocus || _focused);

  bool _shouldRenderInContent() =>
      (_renderLineHighlight == 'line' || _renderLineHighlight == 'all') &&
      _selectionIsEmpty &&
      (!_renderLineHighlightOnlyWhenFocus || _focused);

  bool _shouldRenderThis();
  bool _shouldRenderOther();
  String _renderOne(RenderingContext ctx, bool exact);
}

/// 1:1: `CurrentLineHighlightOverlay`.
class CurrentLineHighlightOverlay extends AbstractLineHighlightOverlay {
  CurrentLineHighlightOverlay(Object context) : super(context);

  @override
  String _renderOne(RenderingContext ctx, bool exact) {
    final String className = 'current-line' +
        (shouldRenderInMargin ? ' current-line-both' : '') +
        (exact ? ' current-line-exact' : '');
    final num scrollWidth = ((ctx as dynamic).scrollWidth as num);
    final num width = scrollWidth > _contentWidth ? scrollWidth : _contentWidth;
    return '<div class="$className" style="width:${_jsNum(width)}px;"></div>';
  }

  @override
  bool _shouldRenderThis() => _shouldRenderInContent();

  @override
  bool _shouldRenderOther() => _shouldRenderInMargin();

  bool get shouldRenderInMargin => _shouldRenderInMargin();
}

/// 1:1: `CurrentLineMarginHighlightOverlay`.
class CurrentLineMarginHighlightOverlay extends AbstractLineHighlightOverlay {
  CurrentLineMarginHighlightOverlay(Object context) : super(context);

  @override
  String _renderOne(RenderingContext ctx, bool exact) {
    final String className = 'current-line' +
        (_shouldRenderInMargin() ? ' current-line-margin' : '') +
        (_shouldRenderOther() ? ' current-line-margin-both' : '') +
        (_shouldRenderInMargin() && exact ? ' current-line-exact-margin' : '');
    return '<div class="$className" style="width:${_jsNum(_contentLeft)}px"></div>';
  }

  @override
  bool _shouldRenderThis() => true;

  @override
  bool _shouldRenderOther() => _shouldRenderInContent();
}
