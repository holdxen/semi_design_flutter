// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/cursorEvents.ts
// Translated 1:1 from TypeScript.
//   - `const enum` -> class with static const int members.
//   - `interface` with readonly fields -> class with final fields + const ctor.
//   - `Selection[] | null` -> nullable List.
// ---------------------------------------------------------------------------

import 'core/position.dart';
import 'core/selection.dart';

/// 1:1: `const enum CursorChangeReason`
class CursorChangeReason {
  /// Unknown or not set.
  static const int NotSet = 0;
  /// A `model.setValue()` was called.
  static const int ContentFlush = 1;
  /// The model changed outside this cursor, recovering position from markers.
  static const int RecoverFromMarkers = 2;
  /// Explicit user gesture.
  static const int Explicit = 3;
  /// A paste.
  static const int Paste = 4;
  /// An undo.
  static const int Undo = 5;
  /// A redo.
  static const int Redo = 6;
}

/// 1:1: `ICursorPositionChangedEvent`
class ICursorPositionChangedEvent {
  /// Primary cursor's position.
  final Position position;
  /// Secondary cursors' positions.
  final List<Position> secondaryPositions;
  /// Reason.
  final int reason;
  /// Source of the call that caused the event ('mouse', 'keyboard', 'api').
  final String source;

  const ICursorPositionChangedEvent({
    required this.position,
    required this.secondaryPositions,
    required this.reason,
    required this.source,
  });
}

/// 1:1: `ICursorSelectionChangedEvent`
class ICursorSelectionChangedEvent {
  /// The primary selection.
  final Selection selection;
  /// The secondary selections.
  final List<Selection> secondarySelections;
  /// The model version id.
  final int modelVersionId;
  /// The old selections.
  final List<Selection>? oldSelections;
  /// The model version id that `oldSelections` refer to.
  final int oldModelVersionId;
  /// Source of the call that caused the event ('mouse', 'keyboard', 'api').
  final String source;
  /// Reason.
  final int reason;

  const ICursorSelectionChangedEvent({
    required this.selection,
    required this.secondarySelections,
    required this.modelVersionId,
    required this.oldSelections,
    required this.oldModelVersionId,
    required this.source,
    required this.reason,
  });
}
