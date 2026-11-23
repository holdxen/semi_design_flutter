// 1:1 port of
// vs/editor/contrib/inlineCompletions/browser/view/inlineEdits/inlineEditsViewInterface.ts
//
// The TS module's runtime surface is two string enums, a click event wrapper
// and a plain data class. DOM traces are carried via the existing `getWindow`
// / `StandardMouseEvent` bridges.

import '../../../../../../base/browser/dom.dart'
    show domIframeWindowProvider, getWindow;
import '../../../../../../base/browser/mouseEvent.dart'
    show IMouseEvent, MouseEvent, StandardMouseEvent;
import '../../../../../../base/common/event.dart' show Event;
import '../../../../../../base/common/observable.dart' show IObservable;

/// 1:1: `export enum InlineEditTabAction`
class InlineEditTabAction {
  static const String Jump = 'jump';
  static const String Accept = 'accept';
  static const String Inactive = 'inactive';
}

/// 1:1: `export class InlineEditClickEvent`
class InlineEditClickEvent {
  final IMouseEvent event;
  final bool alternativeAction;

  InlineEditClickEvent(this.event, [this.alternativeAction = false]);

  /// 1:1: `static create(event, alternativeAction = false)`
  static InlineEditClickEvent create(MouseEvent event,
          [bool alternativeAction = false]) =>
      InlineEditClickEvent(
          StandardMouseEvent(
              domIframeWindowProvider(getWindow(event)), event),
          alternativeAction);
}

/// 1:1: `export interface IInlineEditsView`
abstract class IInlineEditsView {
  IObservable<bool> get isHovered;
  IObservable<num>? get minEditorScrollHeight;
  Event<InlineEditClickEvent> get onDidClick;
}

/// 1:1: `export enum InlineCompletionViewKind`
class InlineCompletionViewKind {
  static const String GhostText = 'ghostText';
  static const String Custom = 'custom';
  static const String SideBySide = 'sideBySide';
  static const String Deletion = 'deletion';
  static const String InsertionInline = 'insertionInline';
  static const String InsertionMultiLine = 'insertionMultiLine';
  static const String WordReplacements = 'wordReplacements';
  static const String LineReplacement = 'lineReplacement';
  static const String Collapsed = 'collapsed';
  static const String JumpTo = 'jumpTo';
}

/// 1:1: `export class InlineCompletionViewData`
class InlineCompletionViewData {
  bool? longDistanceHintVisible;
  num? longDistanceHintDistance;

  /// `undefined` for inline completions / ghost text.
  bool? isForAnotherDocument;

  final num cursorColumnDistance;
  final num cursorLineDistance;
  final num lineCountOriginal;
  final num lineCountModified;
  final num characterCountOriginal;
  final num characterCountModified;
  final num disjointReplacements;
  final bool? sameShapeReplacements;

  InlineCompletionViewData(
    this.cursorColumnDistance,
    this.cursorLineDistance,
    this.lineCountOriginal,
    this.lineCountModified,
    this.characterCountOriginal,
    this.characterCountModified,
    this.disjointReplacements, [
    this.sameShapeReplacements,
  ]);

  void setLongDistanceViewData(num lineNumber, num inlineEditLineNumber) {
    longDistanceHintVisible = true;
    longDistanceHintDistance = (inlineEditLineNumber - lineNumber).abs();
  }

  Map<String, Object?> getData() => <String, Object?>{
        'cursorColumnDistance': cursorColumnDistance,
        'cursorLineDistance': cursorLineDistance,
        'lineCountOriginal': lineCountOriginal,
        'lineCountModified': lineCountModified,
        'characterCountOriginal': characterCountOriginal,
        'characterCountModified': characterCountModified,
        'disjointReplacements': disjointReplacements,
        'sameShapeReplacements': sameShapeReplacements,
        'longDistanceHintVisible': longDistanceHintVisible,
        'longDistanceHintDistance': longDistanceHintDistance,
        'isForAnotherDocument': isForAnotherDocument,
      };
}
