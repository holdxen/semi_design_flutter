// 1:1 port of vs/editor/common/viewEvents.ts
// Const enums are classes of static const ints (repo convention); event classes
// keep their runtime `type` and public fields verbatim.
// Runtime truth: tool/ts2dart/_batch276_truth.cjs (recursive TS transpile+vm).

import '../../base/common/scrollable.dart' show ScrollEvent;
import '../common/core/range.dart' show Range;
import '../common/core/selection.dart' show Selection;
import 'config/editorOptions.dart' show ConfigurationChangedEvent;

/// 1:1: `const enum ViewEventType`
class ViewEventType {
  static const int ViewCompositionStart = 0;
  static const int ViewCompositionEnd = 1;
  static const int ViewConfigurationChanged = 2;
  static const int ViewCursorStateChanged = 3;
  static const int ViewDecorationsChanged = 4;
  static const int ViewFlushed = 5;
  static const int ViewFocusChanged = 6;
  static const int ViewLanguageConfigurationChanged = 7;
  static const int ViewLineMappingChanged = 8;
  static const int ViewLinesChanged = 9;
  static const int ViewLinesDeleted = 10;
  static const int ViewLinesInserted = 11;
  static const int ViewRevealRangeRequest = 12;
  static const int ViewScrollChanged = 13;
  static const int ViewThemeChanged = 14;
  static const int ViewTokensChanged = 15;
  static const int ViewTokensColorsChanged = 16;
  static const int ViewZonesChanged = 17;
}

/// 1:1: `const enum VerticalRevealType`
class VerticalRevealType {
  static const int Simple = 0;
  static const int Center = 1;
  static const int CenterIfOutsideViewport = 2;
  static const int Top = 3;
  static const int Bottom = 4;
  static const int NearTop = 5;
  static const int NearTopIfOutsideViewport = 6;
}

/// 1:1: erased `IModelDecorationsChangedEvent` shape used here.
abstract class IModelDecorationsChangedEventForView {
  bool get affectsMinimap;
  bool get affectsOverviewRuler;
  bool get affectsGlyphMargin;
  bool get affectsLineNumber;
}

/// 1:1: `ViewEvent` union carrier
typedef ViewEvent = Object;

/// 1:1: `ViewCompositionStartEvent`
class ViewCompositionStartEvent {
  final int type = ViewEventType.ViewCompositionStart;
}

/// 1:1: `ViewCompositionEndEvent`
class ViewCompositionEndEvent {
  final int type = ViewEventType.ViewCompositionEnd;
}

/// 1:1: `ViewConfigurationChangedEvent`
class ViewConfigurationChangedEvent {
  final int type = ViewEventType.ViewConfigurationChanged;
  final ConfigurationChangedEvent _source;

  ViewConfigurationChangedEvent(this._source);

  bool hasChanged(int id) => _source.hasChanged(id);
}

/// 1:1: `ViewCursorStateChangedEvent`
class ViewCursorStateChangedEvent {
  final int type = ViewEventType.ViewCursorStateChanged;
  final List<Selection> selections;
  final List<Selection> modelSelections;
  final int reason;

  ViewCursorStateChangedEvent(this.selections, this.modelSelections, this.reason);
}

/// 1:1: `ViewDecorationsChangedEvent`
class ViewDecorationsChangedEvent {
  final int type = ViewEventType.ViewDecorationsChanged;
  final bool affectsMinimap;
  final bool affectsOverviewRuler;
  final bool affectsGlyphMargin;
  final bool affectsLineNumber;

  ViewDecorationsChangedEvent(IModelDecorationsChangedEventForView? source)
      : affectsMinimap = source?.affectsMinimap ?? true,
        affectsOverviewRuler = source?.affectsOverviewRuler ?? true,
        affectsGlyphMargin = source?.affectsGlyphMargin ?? true,
        affectsLineNumber = source?.affectsLineNumber ?? true;
}

/// 1:1: `ViewFlushedEvent`
class ViewFlushedEvent {
  final int type = ViewEventType.ViewFlushed;
}

/// 1:1: `ViewFocusChangedEvent`
class ViewFocusChangedEvent {
  final int type = ViewEventType.ViewFocusChanged;
  final bool isFocused;

  ViewFocusChangedEvent(this.isFocused);
}

/// 1:1: `ViewLanguageConfigurationEvent`
class ViewLanguageConfigurationEvent {
  final int type = ViewEventType.ViewLanguageConfigurationChanged;
}

/// 1:1: `ViewLineMappingChangedEvent`
class ViewLineMappingChangedEvent {
  final int type = ViewEventType.ViewLineMappingChanged;
}

/// 1:1: `ViewLinesChangedEvent`
class ViewLinesChangedEvent {
  final int type = ViewEventType.ViewLinesChanged;
  final int fromLineNumber;
  final int count;

  ViewLinesChangedEvent(this.fromLineNumber, this.count);
}

/// 1:1: `ViewLinesDeletedEvent`
class ViewLinesDeletedEvent {
  final int type = ViewEventType.ViewLinesDeleted;
  final int fromLineNumber;
  final int toLineNumber;

  ViewLinesDeletedEvent(this.fromLineNumber, this.toLineNumber);
}

/// 1:1: `ViewLinesInsertedEvent`
class ViewLinesInsertedEvent {
  final int type = ViewEventType.ViewLinesInserted;
  final int fromLineNumber;
  final int toLineNumber;

  ViewLinesInsertedEvent(this.fromLineNumber, this.toLineNumber);
}

/// 1:1: `ViewRevealRangeRequestEvent`
class ViewRevealRangeRequestEvent {
  final int type = ViewEventType.ViewRevealRangeRequest;
  final String? source;
  final bool minimalReveal;
  final Range? range;
  final List<Selection>? selections;
  final int verticalType;
  final bool revealHorizontal;
  final int scrollType;

  ViewRevealRangeRequestEvent(
    this.source,
    this.minimalReveal,
    this.range,
    this.selections,
    this.verticalType,
    this.revealHorizontal,
    this.scrollType,
  );
}

/// 1:1: `ViewScrollChangedEvent`
class ViewScrollChangedEvent {
  final int type = ViewEventType.ViewScrollChanged;
  final num scrollWidth;
  final num scrollLeft;
  final num scrollHeight;
  final num scrollTop;
  final bool scrollWidthChanged;
  final bool scrollLeftChanged;
  final bool scrollHeightChanged;
  final bool scrollTopChanged;

  ViewScrollChangedEvent(ScrollEvent source)
      : scrollWidth = source.scrollWidth,
        scrollLeft = source.scrollLeft,
        scrollHeight = source.scrollHeight,
        scrollTop = source.scrollTop,
        scrollWidthChanged = source.scrollWidthChanged,
        scrollLeftChanged = source.scrollLeftChanged,
        scrollHeightChanged = source.scrollHeightChanged,
        scrollTopChanged = source.scrollTopChanged;
}

/// 1:1: `ViewThemeChangedEvent`
class ViewThemeChangedEvent {
  final int type = ViewEventType.ViewThemeChanged;
  final Object theme;

  ViewThemeChangedEvent(this.theme);
}

/// 1:1: `ViewTokensChangedEvent`
class ViewTokensChangedEvent {
  final int type = ViewEventType.ViewTokensChanged;
  final List<({int fromLineNumber, int toLineNumber})> ranges;

  ViewTokensChangedEvent(this.ranges);
}

/// 1:1: `ViewTokensColorsChangedEvent`
class ViewTokensColorsChangedEvent {
  final int type = ViewEventType.ViewTokensColorsChanged;
}

/// 1:1: `ViewZonesChangedEvent`
class ViewZonesChangedEvent {
  final int type = ViewEventType.ViewZonesChanged;
}
