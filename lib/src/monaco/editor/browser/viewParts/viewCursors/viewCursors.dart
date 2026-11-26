// 1:1 port of vscode/src/vs/editor/browser/viewParts/viewCursors/viewCursors.ts @bfbf12b
// Adaptations (documented inline):
//   - `ViewPart._context` is library-private in the Dart port, so the part
//     keeps its own reference to the same ViewContext.
//   - `FastDomNode<HTMLElement>` is a narrow carrier with a dom.dart DomElement;
//     append/insert/remove use `.domNode`, since FastDomNode is not a DomNode.
//   - Base handler overrides take `Object` (Dart cannot narrow override
//     parameters) and cast to the concrete view event.
//   - `TextEditorCursorBlinkingStyle` / `CursorPlurality` are int constants;
//     Dart requires `default` last in switches (grouped with Single/Solid).
//   - The top-level theming participant is registered at import time, matching
//     the TS module side effect.
// Runtime truth: tool/ts2dart/_batch342_truth.cjs.

import '../../../../base/browser/dom.dart'
    show DomElement, WindowIntervalTimer, document, getWindow;
import '../../../../base/common/async.dart' show IntervalTimer, TimeoutTimer;
import '../../../../base/common/color.dart' show Color;
import '../../../../base/common/lifecycle.dart' show IDisposable;
import '../../../common/config/editorOptions.dart'
    show EditorOption, TextEditorCursorBlinkingStyle, TextEditorCursorStyle;
import '../../../common/core/editorColorRegistry.dart'
    show editorCursorBackground, editorCursorForeground,
    editorMultiCursorPrimaryBackground, editorMultiCursorPrimaryForeground,
    editorMultiCursorSecondaryBackground, editorMultiCursorSecondaryForeground;
import '../../../common/core/position.dart' show Position;
import '../../../common/core/selection.dart' show Selection;
import '../../../common/cursorEvents.dart' show CursorChangeReason;
import '../../../common/viewEvents.dart'
    show ViewCompositionEndEvent, ViewCompositionStartEvent,
    ViewConfigurationChangedEvent, ViewCursorStateChangedEvent,
    ViewFocusChangedEvent, ViewTokensChangedEvent;
import '../../../common/viewModel/viewContext.dart' show ViewContext;
import '../../../../platform/theme/common/theme.dart' show isHighContrast;
import '../../../../platform/theme/common/themeService.dart'
    show ICssStyleCollector, IColorTheme, registerThemingParticipant;
import '../../view/renderingContext.dart'
    show RenderingContext, RestrictedRenderingContext;
import '../../view/viewPart.dart' show ViewPart;
import 'viewCursor.dart'
    show CursorPlurality, IViewCursorRenderData, ViewCursor;

/// 1:1: `FastDomNode<HTMLElement>` subset used here (opaque carrier).
abstract class IFastDomNodeForCursors {
  DomElement get domNode;
  void setAttribute(String name, String value);
  void setClassName(String className);
  void removeChild(DomElement child);
}

/// 1:1: `createFastDomNode(document.createElement('div'))`.
class _FastDomNodeCarrier implements IFastDomNodeForCursors {
  _FastDomNodeCarrier(this.domNode);

  @override
  final DomElement domNode;

  String _className = '';

  @override
  void setAttribute(String name, String value) =>
      domNode.setAttribute(name, value);

  @override
  void setClassName(String className) {
    if (_className == className) {
      return;
    }
    _className = className;
    domNode.className = className;
  }

  @override
  void removeChild(DomElement child) => domNode.removeChild(child);
}

/// View cursors is a view part responsible for rendering the primary cursor and
/// any secondary cursors that are currently active.
class ViewCursors extends ViewPart {
  static const int BLINK_INTERVAL = 500;

  late final ViewContext _context;

  late bool _readOnly;
  late int _cursorBlinking;
  late int _cursorStyle;
  late String _cursorSmoothCaretAnimation;
  late bool _editContextEnabled;
  bool _selectionIsEmpty = true;
  bool _isComposingInput = false;

  bool _isVisible = false;

  late final IFastDomNodeForCursors _domNode;

  late final TimeoutTimer _startCursorBlinkAnimation;
  late final IntervalTimer _cursorFlatBlinkInterval;
  bool _blinkingEnabled = false;

  bool _editorHasFocus = false;

  late final ViewCursor _primaryCursor;
  final List<ViewCursor> _secondaryCursors = <ViewCursor>[];
  List<IViewCursorRenderData> _renderData = <IViewCursorRenderData>[];

  ViewCursors(ViewContext context) : super(context) {
    _context = context;

    final dynamic options = (_context.configuration as dynamic).options;
    _readOnly = options.get(EditorOption.readOnly) as bool;
    _cursorBlinking = options.get(EditorOption.cursorBlinking) as int;
    _cursorStyle = options.get(EditorOption.effectiveCursorStyle) as int;
    _cursorSmoothCaretAnimation =
        options.get(EditorOption.cursorSmoothCaretAnimation) as String;
    _editContextEnabled = options.get(EditorOption.effectiveEditContext) as bool;
    _selectionIsEmpty = true;
    _isComposingInput = false;

    _isVisible = false;

    _primaryCursor = ViewCursor(_context, CursorPlurality.Single);
    _renderData = <IViewCursorRenderData>[];

    _domNode = _FastDomNodeCarrier(document.createElement('div'));
    _domNode.setAttribute('role', 'presentation');
    _domNode.setAttribute('aria-hidden', 'true');
    _updateDomClassName();

    _domNode.domNode.appendChild(_primaryCursor.getDomNode().domNode);

    _startCursorBlinkAnimation = TimeoutTimer();
    _cursorFlatBlinkInterval = WindowIntervalTimer();

    _blinkingEnabled = false;

    _editorHasFocus = false;
    _updateBlinking();
  }

  @override
  void dispose() {
    super.dispose();
    _startCursorBlinkAnimation.dispose();
    _cursorFlatBlinkInterval.dispose();
  }

  /// 1:1: `public getDomNode()`.
  IFastDomNodeForCursors getDomNode() => _domNode;

  // --- begin event handlers

  @override
  bool onCompositionStart(Object e) {
    e as ViewCompositionStartEvent;
    _isComposingInput = true;
    _updateBlinking();
    return true;
  }

  @override
  bool onCompositionEnd(Object e) {
    e as ViewCompositionEndEvent;
    _isComposingInput = false;
    _updateBlinking();
    return true;
  }

  @override
  bool onConfigurationChanged(Object e) {
    e as ViewConfigurationChangedEvent;
    final dynamic options = (_context.configuration as dynamic).options;

    _readOnly = options.get(EditorOption.readOnly) as bool;
    _cursorBlinking = options.get(EditorOption.cursorBlinking) as int;
    _cursorStyle = options.get(EditorOption.effectiveCursorStyle) as int;
    _cursorSmoothCaretAnimation =
        options.get(EditorOption.cursorSmoothCaretAnimation) as String;
    _editContextEnabled = options.get(EditorOption.effectiveEditContext) as bool;

    _updateBlinking();
    _updateDomClassName();

    _primaryCursor.onConfigurationChanged(e);
    for (final ViewCursor cursor in _secondaryCursors) {
      cursor.onConfigurationChanged(e);
    }
    return true;
  }

  void _onCursorPositionChanged(Position position,
      List<Position> secondaryPositions, int reason) {
    final bool pauseAnimation =
        _secondaryCursors.length != secondaryPositions.length ||
            (_cursorSmoothCaretAnimation == 'explicit' &&
                reason != CursorChangeReason.Explicit);
    _primaryCursor.setPlurality(secondaryPositions.isNotEmpty
        ? CursorPlurality.MultiPrimary
        : CursorPlurality.Single);
    _primaryCursor.onCursorPositionChanged(position, pauseAnimation);
    _updateBlinking();

    if (_secondaryCursors.length < secondaryPositions.length) {
      // Create new cursors
      final int addCnt = secondaryPositions.length - _secondaryCursors.length;
      for (int i = 0; i < addCnt; i++) {
        final ViewCursor newCursor =
            ViewCursor(_context, CursorPlurality.MultiSecondary);
        _domNode.domNode.insertBefore(
          newCursor.getDomNode().domNode,
          _primaryCursor.getDomNode().domNode.nextSibling,
        );
        _secondaryCursors.add(newCursor);
      }
    } else if (_secondaryCursors.length > secondaryPositions.length) {
      // Remove some cursors
      final int removeCnt = _secondaryCursors.length - secondaryPositions.length;
      for (int i = 0; i < removeCnt; i++) {
        _domNode.removeChild(_secondaryCursors[0].getDomNode().domNode);
        _secondaryCursors.removeAt(0);
      }
    }

    for (int i = 0; i < secondaryPositions.length; i++) {
      _secondaryCursors[i].onCursorPositionChanged(
          secondaryPositions[i], pauseAnimation);
    }
  }

  @override
  bool onCursorStateChanged(Object e) {
    e as ViewCursorStateChangedEvent;
    final List<Position> positions = <Position>[];
    for (final Selection selection in e.selections) {
      positions.add(selection.getPosition());
    }
    _onCursorPositionChanged(
      positions[0],
      positions.sublist(1),
      e.reason,
    );

    final bool selectionIsEmpty = e.selections[0].isEmpty();
    if (_selectionIsEmpty != selectionIsEmpty) {
      _selectionIsEmpty = selectionIsEmpty;
      _updateDomClassName();
    }

    return true;
  }

  @override
  bool onDecorationsChanged(Object e) {
    // true for inline decorations that can end up relayouting text
    return true;
  }

  @override
  bool onFlushed(Object e) {
    return true;
  }

  @override
  bool onFocusChanged(Object e) {
    e as ViewFocusChangedEvent;
    _editorHasFocus = e.isFocused;
    _updateBlinking();
    return false;
  }

  @override
  bool onLinesChanged(Object e) {
    return true;
  }

  @override
  bool onLinesDeleted(Object e) {
    return true;
  }

  @override
  bool onLinesInserted(Object e) {
    return true;
  }

  @override
  bool onScrollChanged(Object e) {
    return true;
  }

  @override
  bool onTokensChanged(Object e) {
    e as ViewTokensChangedEvent;
    bool shouldRender(Position position) {
      for (final ({int fromLineNumber, int toLineNumber}) range in e.ranges) {
        if (range.fromLineNumber <= position.lineNumber &&
            position.lineNumber <= range.toLineNumber) {
          return true;
        }
      }
      return false;
    }

    if (shouldRender(_primaryCursor.getPosition())) {
      return true;
    }
    for (final ViewCursor secondaryCursor in _secondaryCursors) {
      if (shouldRender(secondaryCursor.getPosition())) {
        return true;
      }
    }
    return false;
  }

  @override
  bool onZonesChanged(Object e) {
    return true;
  }

  // --- end event handlers

  // ---- blinking logic

  int _getCursorBlinking() {
    // TODO: Remove the following if statement when experimental edit context
    // is made default sole implementation
    if (_isComposingInput && !_editContextEnabled) {
      // avoid double cursors
      return TextEditorCursorBlinkingStyle.Hidden;
    }
    if (!_editorHasFocus) {
      return TextEditorCursorBlinkingStyle.Hidden;
    }
    if (_readOnly) {
      return TextEditorCursorBlinkingStyle.Solid;
    }
    return _cursorBlinking;
  }

  void _updateBlinking() {
    _startCursorBlinkAnimation.cancel();
    _cursorFlatBlinkInterval.cancel();

    final int blinkingStyle = _getCursorBlinking();

    // hidden and solid are special as they involve no animations
    final bool isHidden = blinkingStyle == TextEditorCursorBlinkingStyle.Hidden;
    final bool isSolid = blinkingStyle == TextEditorCursorBlinkingStyle.Solid;

    if (isHidden) {
      _hide();
    } else {
      _show();
    }

    _blinkingEnabled = false;
    _updateDomClassName();

    if (!isHidden && !isSolid) {
      if (blinkingStyle == TextEditorCursorBlinkingStyle.Blink) {
        // flat blinking is handled by JavaScript to save battery life due to
        // Chromium step timing issue
        _cursorFlatBlinkInterval.cancelAndSet(() {
          if (_isVisible) {
            _hide();
          } else {
            _show();
          }
        }, ViewCursors.BLINK_INTERVAL, getWindow(_domNode.domNode));
      } else {
        _startCursorBlinkAnimation.setIfNotSet(() {
          _blinkingEnabled = true;
          _updateDomClassName();
        }, ViewCursors.BLINK_INTERVAL);
      }
    }
  }

  // --- end blinking logic

  void _updateDomClassName() => _domNode.setClassName(_getClassName());

  String _getClassName() {
    String result = 'cursors-layer';
    if (!_selectionIsEmpty) {
      result += ' has-selection';
    }
    switch (_cursorStyle) {
      case TextEditorCursorStyle.Line:
        result += ' cursor-line-style';
        break;
      case TextEditorCursorStyle.Block:
        result += ' cursor-block-style';
        break;
      case TextEditorCursorStyle.Underline:
        result += ' cursor-underline-style';
        break;
      case TextEditorCursorStyle.LineThin:
        result += ' cursor-line-thin-style';
        break;
      case TextEditorCursorStyle.BlockOutline:
        result += ' cursor-block-outline-style';
        break;
      case TextEditorCursorStyle.UnderlineThin:
        result += ' cursor-underline-thin-style';
        break;
      default:
        result += ' cursor-line-style';
    }
    if (_blinkingEnabled) {
      switch (_getCursorBlinking()) {
        case TextEditorCursorBlinkingStyle.Blink:
          result += ' cursor-blink';
          break;
        case TextEditorCursorBlinkingStyle.Smooth:
          result += ' cursor-smooth';
          break;
        case TextEditorCursorBlinkingStyle.Phase:
          result += ' cursor-phase';
          break;
        case TextEditorCursorBlinkingStyle.Expand:
          result += ' cursor-expand';
          break;
        case TextEditorCursorBlinkingStyle.Solid:
        default:
          result += ' cursor-solid';
      }
    } else {
      result += ' cursor-solid';
    }
    if (_cursorSmoothCaretAnimation == 'on' ||
        _cursorSmoothCaretAnimation == 'explicit') {
      result += ' cursor-smooth-caret-animation';
    }
    return result;
  }

  void _show() {
    _primaryCursor.show();
    for (final ViewCursor cursor in _secondaryCursors) {
      cursor.show();
    }
    _isVisible = true;
  }

  void _hide() {
    _primaryCursor.hide();
    for (final ViewCursor cursor in _secondaryCursors) {
      cursor.hide();
    }
    _isVisible = false;
  }

  // ---- IViewPart implementation

  @override
  void prepareRender(RenderingContext ctx) {
    _primaryCursor.prepareRender(ctx);
    for (final ViewCursor cursor in _secondaryCursors) {
      cursor.prepareRender(ctx);
    }
  }

  @override
  void render(RestrictedRenderingContext ctx) {
    final List<IViewCursorRenderData> data = <IViewCursorRenderData>[];

    final IViewCursorRenderData? primary = _primaryCursor.render(ctx);
    if (primary != null) {
      data.add(primary);
    }

    for (final ViewCursor cursor in _secondaryCursors) {
      final IViewCursorRenderData? secondary = cursor.render(ctx);
      if (secondary != null) {
        data.add(secondary);
      }
    }

    _renderData = data;
  }

  /// 1:1: `public getLastRenderData()`.
  List<IViewCursorRenderData> getLastRenderData() => _renderData;
}

/// 1:1: top-level theming participant body (exposed so tests can replay it).
void viewCursorsTheming(
    IColorTheme theme, ICssStyleCollector collector, dynamic environment) {
  const List<String> cursorThemes = <String>[
    '.cursor',
    '.cursor-primary',
    '.cursor-secondary',
  ];
  final List<String> foregrounds = <String>[
    editorCursorForeground,
    editorMultiCursorPrimaryForeground,
    editorMultiCursorSecondaryForeground,
  ];
  final List<String> backgrounds = <String>[
    editorCursorBackground,
    editorMultiCursorPrimaryBackground,
    editorMultiCursorSecondaryBackground,
  ];

  for (int i = 0; i < cursorThemes.length; i++) {
    final Color? caret = theme.getColor(foregrounds[i]);
    if (caret != null) {
      Color? caretBackground = theme.getColor(backgrounds[i]);
      caretBackground ??= caret.opposite();
      collector.addRule(
          '.monaco-editor .cursors-layer ${cursorThemes[i]} { background-color: $caret; border-color: $caret; color: $caretBackground; }');
      if (isHighContrast(theme.type)) {
        collector.addRule(
            '.monaco-editor .cursors-layer.has-selection ${cursorThemes[i]} { border-left: 1px solid $caretBackground; border-right: 1px solid $caretBackground; }');
      }
    }
  }
}

/// 1:1: `registerThemingParticipant(...)` module side effect.
final IDisposable viewCursorsThemingParticipant =
    registerThemingParticipant(viewCursorsTheming);
