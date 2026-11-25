// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/viewParts/wordWrapIndicator/
//   wordWrapIndicator.ts
// Translated 1:1 from TypeScript.
//
// Adaptations (documented inline):
//  * `ViewContext` / `IEditorConfiguration` / `RenderingContext` are used via
//    file-local narrow carriers so the overlay can be replayed without a real
//    editor; the member surface read here matches the TS source exactly.
//  * TS number-to-string uses JS semantics; `_jsNum` avoids a trailing `.0`.
// ---------------------------------------------------------------------------

import '../../view/dynamicViewOverlay.dart' show DynamicViewOverlay;
import '../../view/renderingContext.dart' show RenderingContext;
import '../../../common/viewEventHandler.dart' show ViewEventHandler;
import '../../../common/config/editorOptions.dart' show EditorOption;

/// U+21A9 - LEFTWARDS ARROW WITH HOOK.
const int WORD_WRAP_INDICATOR_CHAR_CODE = 0x21A9;

/// 1:1: JS number-to-string (no trailing `.0` for integral doubles).
String _jsNum(num value) {
  if (value is int) return value.toString();
  if (value == value.truncate()) return value.toInt().toString();
  return value.toString();
}

/// 1:1: `IEditorConfiguration.options` subset read by the options snapshot.
abstract class IWordWrapIndicatorEditorOptions {
  Object? get(Object id);
}

/// 1:1: `IEditorConfiguration` subset read here (opaque carrier).
abstract class IWordWrapIndicatorConfiguration {
  IWordWrapIndicatorEditorOptions get options;
}

/// 1:1: `ViewContext` subset used by this overlay (opaque carrier).
abstract class IWordWrapIndicatorViewContext {
  IWordWrapIndicatorConfiguration get configuration;
  void addEventHandler(ViewEventHandler eventHandler);
  void removeEventHandler(ViewEventHandler eventHandler);
}

/// The word wrap indicator overlay renders a small glyph at the wrapping
/// column of every view line which is soft wrapped.
class WordWrapIndicatorOverlay extends DynamicViewOverlay {
  final IWordWrapIndicatorViewContext _context;
  WordWrapIndicatorOptions _options;
  List<String>? _renderResult;

  WordWrapIndicatorOverlay(this._context) : _options = WordWrapIndicatorOptions(
          _context.configuration) {
    _context.addEventHandler(this);
  }

  @override
  void dispose() {
    _context.removeEventHandler(this);
    _renderResult = null;
    super.dispose();
  }

  /// Whether the overlay paints anything at all.
  bool get _isEnabled =>
      _options.wordWrapIndicator && _options.isWrapping;

  // --- begin event handlers

  @override
  bool onConfigurationChanged(Object e) {
    final bool wasEnabled = _isEnabled;
    final WordWrapIndicatorOptions newOptions =
        WordWrapIndicatorOptions(_context.configuration);
    final bool optionsChanged = !_options.equals(newOptions);
    _options = newOptions;
    return (wasEnabled || _isEnabled) && optionsChanged;
  }

  @override
  bool onDecorationsChanged(Object e) => _isEnabled;

  @override
  bool onFlushed(Object e) => _isEnabled;

  @override
  bool onLineMappingChanged(Object e) => _isEnabled;

  @override
  bool onLinesChanged(Object e) => _isEnabled;

  @override
  bool onLinesDeleted(Object e) => _isEnabled;

  @override
  bool onLinesInserted(Object e) => _isEnabled;

  @override
  bool onScrollChanged(Object e) {
    final bool scrollTopChanged = e is Map && e['scrollTopChanged'] == true;
    return _isEnabled && scrollTopChanged;
  }

  @override
  bool onTokensChanged(Object e) => false;

  @override
  bool onZonesChanged(Object e) => _isEnabled;

  // --- end event handlers

  @override
  void prepareRender(RenderingContext ctx) {
    if (!_isEnabled) {
      _renderResult = null;
      return;
    }
    _renderResult = <String>[];
    for (int lineNumber = ctx.viewportData.startLineNumber;
        lineNumber <= ctx.viewportData.endLineNumber;
        lineNumber++) {
      // JS assigns by index (auto-extending a sparse array); the view loop is
      // contiguous from startLineNumber, so append preserves the same result.
      _renderResult!.add(_renderLine(ctx, lineNumber));
    }
  }

  String _renderLine(RenderingContext ctx, int lineNumber) {
    if (!ctx.viewportData.getViewLineContinuesWithWrappedLine(lineNumber)) {
      return '';
    }
    final num lineHeight = ctx.getLineHeightForLineNumber(lineNumber);
    return '<div class="wwi" style="left:${_jsNum(_options.indicatorLeft)}px;'
        'height:${_jsNum(lineHeight)}px;">'
        '${String.fromCharCode(WORD_WRAP_INDICATOR_CHAR_CODE)}</div>';
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

/// The subset of the editor configuration the overlay reads, snapshotted so
/// that a configuration change can be told apart from one that leaves the
/// rendered result untouched.
class WordWrapIndicatorOptions {
  late final bool wordWrapIndicator;
  late final bool isWrapping;
  late final num indicatorLeft;

  WordWrapIndicatorOptions(IWordWrapIndicatorConfiguration config) {
    final IWordWrapIndicatorEditorOptions options = config.options;
    final Object? fontInfo = options.get(EditorOption.fontInfo);
    final Object? wrappingInfo = options.get(EditorOption.wrappingInfo);
    wordWrapIndicator =
        options.get(EditorOption.wordWrapIndicator) as bool? ?? false;
    final num wrappingColumn = _wrappingColumnOf(wrappingInfo);
    isWrapping = wrappingColumn != -1;
    indicatorLeft = wrappingColumn * _halfWidthOf(fontInfo);
  }

  bool equals(WordWrapIndicatorOptions other) =>
      wordWrapIndicator == other.wordWrapIndicator &&
      isWrapping == other.isWrapping &&
      indicatorLeft == other.indicatorLeft;
}

/// 1:1: `fontInfo.typicalHalfwidthCharacterWidth` read from the option.
num _halfWidthOf(Object? fontInfo) {
  if (fontInfo == null) return 0;
  final dynamic value = (fontInfo as dynamic).typicalHalfwidthCharacterWidth;
  return value is num ? value : 0;
}

/// 1:1: `wrappingInfo.wrappingColumn` read from the option.
num _wrappingColumnOf(Object? wrappingInfo) {
  if (wrappingInfo == null) return -1;
  final dynamic value = (wrappingInfo as dynamic).wrappingColumn;
  return value is num ? value : -1;
}
