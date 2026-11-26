// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/viewParts/lineNumbers/lineNumbers.ts
// Translated 1:1. Structure, members and semantics preserved.
// Verified against the TypeScript transpile truth (batch435).
//
// Adaptations: ViewContext / configuration / viewModel / RenderingContext are
// narrow carriers so the overlay can be replayed without a real editor.
// ---------------------------------------------------------------------------

import '../../view/dynamicViewOverlay.dart' show DynamicViewOverlay;
import '../../view/renderingContext.dart' show RenderingContext;
import '../../../common/config/editorOptions.dart'
    show EditorOption, RenderLineNumbersType;
import '../../../common/core/position.dart' show Position;
import '../../../common/core/range.dart' show Range;

/// 1:1: JS number-to-string (no trailing `.0` for integral doubles).
String _jsNum(num value) {
  if (value is int) return value.toString();
  if (value == value.truncate()) return value.toInt().toString();
  return value.toString();
}

/// 1:1: `LineNumbersOverlay extends DynamicViewOverlay`.
class LineNumbersOverlay extends DynamicViewOverlay {
  static const String className = 'line-numbers';

  final Object _context;
  final bool Function() _isLinux;

  late int _lineHeight;
  late int _renderLineNumbers;
  String Function(int)? _renderCustomLineNumbers;
  late String _renderFinalNewline;
  late num _lineNumbersLeft;
  late num _lineNumbersWidth;
  Position _lastCursorModelPosition = Position(1, 1);
  List<String>? _renderResult;
  int _activeModelLineNumber = 1;

  LineNumbersOverlay(this._context, [bool Function()? isLinux])
      : _isLinux = isLinux ?? (() => false) {
    _readConfig();
    _lastCursorModelPosition = Position(1, 1);
    _renderResult = null;
    _activeModelLineNumber = 1;
    (_context as dynamic).addEventHandler(this);
  }

  void _readConfig() {
    final dynamic options = (_context as dynamic).configuration.options;
    _lineHeight = (options.get(EditorOption.lineHeight) as num).toInt();
    final dynamic lineNumbers = options.get(EditorOption.lineNumbers);
    Object? lnField(String name) => lineNumbers is Map
        ? lineNumbers[name]
        : lineNumbers.$name as Object?;
    _renderLineNumbers = (lnField('renderType') as num).toInt();
    _renderCustomLineNumbers = lnField('renderFn') as String Function(int)?;
    _renderFinalNewline = options.get(EditorOption.renderFinalNewline) as String;
    final dynamic layoutInfo = options.get(EditorOption.layoutInfo);
    Object liField(String name) => layoutInfo is Map
        ? layoutInfo[name] as Object
        : layoutInfo.$name as Object;
    _lineNumbersLeft = liField('lineNumbersLeft') as num;
    _lineNumbersWidth = liField('lineNumbersWidth') as num;
  }

  @override
  void dispose() {
    (_context as dynamic).removeEventHandler(this);
    _renderResult = null;
    super.dispose();
  }

  @override
  bool onConfigurationChanged(Object e) {
    _readConfig();
    return true;
  }

  @override
  bool onCursorStateChanged(Object e) {
    final dynamic ev = e;
    final Object primaryViewPosition = (e is List
        ? (e[0] as dynamic).getPosition()
        : (ev.selections[0] as dynamic).getPosition()) as Object;
    _lastCursorModelPosition = _convertViewToModel(primaryViewPosition);

    bool shouldRender = false;
    if (_activeModelLineNumber != _lastCursorModelPosition.lineNumber) {
      _activeModelLineNumber = _lastCursorModelPosition.lineNumber;
      shouldRender = true;
    }
    if (_renderLineNumbers == RenderLineNumbersType.relative ||
        _renderLineNumbers == RenderLineNumbersType.interval) {
      shouldRender = true;
    }
    return shouldRender;
  }

  @override
  bool onFlushed(Object e) => true;

  @override
  bool onLinesChanged(Object e) => true;

  @override
  bool onLinesDeleted(Object e) => true;

  @override
  bool onLinesInserted(Object e) => true;

  @override
  bool onScrollChanged(Object e) {
    final dynamic ev = e;
    return ev is Map ? ev['scrollTopChanged'] == true : ev.scrollTopChanged as bool;
  }

  @override
  bool onZonesChanged(Object e) => true;

  @override
  bool onDecorationsChanged(Object e) {
    final dynamic ev = e;
    return ev is Map
        ? ev['affectsLineNumber'] == true
        : ev.affectsLineNumber as bool;
  }

  Position _convertViewToModel(Object viewPosition) {
    final dynamic p = viewPosition;
    final dynamic converter =
        (_context as dynamic).viewModel.coordinatesConverter;
    return converter.convertViewPositionToModelPosition(p) as Position;
  }

  String _getLineRenderLineNumber(int viewLineNumber) {
    final Position modelPosition =
        _convertViewToModel(Position(viewLineNumber, 1));
    if (modelPosition.column != 1) {
      return '';
    }
    final int modelLineNumber = modelPosition.lineNumber;

    final String Function(int)? custom = _renderCustomLineNumbers;
    if (custom != null) {
      return custom(modelLineNumber);
    }

    if (_renderLineNumbers == RenderLineNumbersType.relative) {
      final int diff =
          (_lastCursorModelPosition.lineNumber - modelLineNumber).abs();
      if (diff == 0) {
        return '<span class="relative-current-line-number">$modelLineNumber</span>';
      }
      return diff.toString();
    }

    if (_renderLineNumbers == RenderLineNumbersType.interval) {
      if (_lastCursorModelPosition.lineNumber == modelLineNumber) {
        return modelLineNumber.toString();
      }
      if (modelLineNumber % 10 == 0) {
        return modelLineNumber.toString();
      }
      final int finalLineNumber =
          (_context as dynamic).viewModel.getLineCount() as int;
      if (modelLineNumber == finalLineNumber) {
        return modelLineNumber.toString();
      }
      return '';
    }

    return modelLineNumber.toString();
  }

  @override
  void prepareRender(RenderingContext ctx) {
    if (_renderLineNumbers == RenderLineNumbersType.off) {
      _renderResult = null;
      return;
    }

    final String lineHeightClassName = _isLinux()
        ? (_lineHeight % 2 == 0 ? ' lh-even' : ' lh-odd')
        : '';
    final dynamic rctx = ctx;
    final Range visibleRange = rctx.visibleRange as Range;
    final int visibleStartLineNumber = visibleRange.startLineNumber;
    final int visibleEndLineNumber = visibleRange.endLineNumber;

    final dynamic viewModel = (_context as dynamic).viewModel;
    final List<dynamic> lineNoDecorations =
        (viewModel.getDecorationsInViewport(visibleRange) as List<dynamic>)
            .where((dynamic d) => (d as dynamic).options.lineNumberClassName != null)
            .toList();
    lineNoDecorations.sort((dynamic a, dynamic b) => Range.compareRangesUsingEnds(
          (a as dynamic).range as Range,
          (b as dynamic).range as Range,
        ));
    int decorationStartIndex = 0;

    final int lineCount = viewModel.getLineCount() as int;
    final List<String> output = <String>[];
    for (int lineNumber = visibleStartLineNumber;
        lineNumber <= visibleEndLineNumber;
        lineNumber++) {
      // JS assigns by index (contiguous loop); append preserves the same order.
      final int modelLineNumber =
          _convertViewToModel(Position(lineNumber, 1)).lineNumber;

      String renderLineNumber = _getLineRenderLineNumber(lineNumber);
      String extraClassNames = '';

      while (decorationStartIndex < lineNoDecorations.length &&
          (lineNoDecorations[decorationStartIndex] as dynamic)
                  .range.endLineNumber <
              lineNumber) {
        decorationStartIndex++;
      }
      for (int i = decorationStartIndex; i < lineNoDecorations.length; i++) {
        final dynamic d = lineNoDecorations[i];
        final Range range = d.range as Range;
        if (range.startLineNumber <= lineNumber) {
          extraClassNames += ' ${(d.options as dynamic).lineNumberClassName}';
        }
      }

      if (renderLineNumber.isEmpty && extraClassNames.isEmpty) {
        output.add('');
        continue;
      }

      if (lineNumber == lineCount &&
          (viewModel.getLineLength(lineNumber) as int) == 0) {
        // this is the last line
        if (_renderFinalNewline == 'off') {
          renderLineNumber = '';
        }
        if (_renderFinalNewline == 'dimmed') {
          extraClassNames += ' dimmed-line-number';
        }
      }
      if (modelLineNumber == _activeModelLineNumber) {
        extraClassNames += ' active-line-number';
      }

      output.add(
        '<div class="$className$lineHeightClassName$extraClassNames" '
        'style="left:${_jsNum(_lineNumbersLeft)}px;width:${_jsNum(_lineNumbersWidth)}px;">$renderLineNumber</div>',
      );
    }

    _renderResult = output;
  }

  @override
  String render(int startLineNumber, int lineNumber) {
    final List<String>? result = _renderResult;
    if (result == null) {
      return '';
    }
    final int lineIndex = lineNumber - startLineNumber;
    if (lineIndex < 0 || lineIndex >= result.length) {
      return '';
    }
    return result[lineIndex];
  }
}
