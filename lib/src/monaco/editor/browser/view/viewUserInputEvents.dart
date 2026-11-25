// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/view/viewUserInputEvents.ts
// Translated 1:1. Mouse targets/events are `Map` carriers (TS object spread),
// keyboard/wheel events stay opaque; the coordinates converter is a local
// contract.
// ---------------------------------------------------------------------------
import '../../common/core/position.dart' show Position;
import '../../common/core/range.dart' show Range;

/// 1:1: `EventCallback<T>`.
typedef EventCallback<T> = void Function(T event);

/// 1:1: `MouseTargetType` members used here.
class MouseTargetTypeForViewInput {
  const MouseTargetTypeForViewInput._();
  static const int GUTTER_VIEW_ZONE = 5;
  static const int CONTENT_VIEW_ZONE = 8;
}

/// 1:1: `ICoordinatesConverter` members read here.
abstract class ICoordinatesConverterForViewInput {
  Position convertViewPositionToModelPosition(Position viewPosition);
  Range convertViewRangeToModelRange(Range viewRange);
}

/// 1:1: `export class ViewUserInputEvents`.
class ViewUserInputEvents {
  EventCallback<Object?>? onKeyDown;
  EventCallback<Object?>? onKeyUp;
  EventCallback<Object>? onContextMenu;
  EventCallback<Object>? onMouseMove;
  EventCallback<Object>? onMouseLeave;
  EventCallback<Object>? onMouseDown;
  EventCallback<Object>? onMouseUp;
  EventCallback<Object>? onMouseDrag;
  EventCallback<Object>? onMouseDrop;
  void Function()? onMouseDropCanceled;
  EventCallback<Object?>? onMouseWheel;

  final ICoordinatesConverterForViewInput _coordinatesConverter;

  ViewUserInputEvents(this._coordinatesConverter);

  void emitKeyDown(Object e) => onKeyDown?.call(e);
  void emitKeyUp(Object e) => onKeyUp?.call(e);
  void emitContextMenu(Object e) =>
      onContextMenu?.call(_convertViewToModelMouseEvent(e));
  void emitMouseMove(Object e) =>
      onMouseMove?.call(_convertViewToModelMouseEvent(e));
  void emitMouseLeave(Object e) =>
      onMouseLeave?.call(_convertViewToModelMouseEvent(e));
  void emitMouseDown(Object e) =>
      onMouseDown?.call(_convertViewToModelMouseEvent(e));
  void emitMouseUp(Object e) =>
      onMouseUp?.call(_convertViewToModelMouseEvent(e));
  void emitMouseDrag(Object e) =>
      onMouseDrag?.call(_convertViewToModelMouseEvent(e));
  void emitMouseDrop(Object e) =>
      onMouseDrop?.call(_convertViewToModelMouseEvent(e));
  void emitMouseDropCanceled() => onMouseDropCanceled?.call();
  void emitMouseWheel(Object e) => onMouseWheel?.call(e);

  Object _convertViewToModelMouseEvent(Object e) {
    final Map<String, Object?> event = e as Map<String, Object?>;
    final Object? target = event['target'];
    if (target != null) {
      return <String, Object?>{
        'event': event['event'],
        'target': convertViewToModelMouseTarget(
            target as Map<String, Object?>, _coordinatesConverter),
      };
    }
    return e;
  }

  /// 1:1: `public static convertViewToModelMouseTarget`.
  static Map<String, Object?> convertViewToModelMouseTarget(
    Map<String, Object?> target,
    ICoordinatesConverterForViewInput coordinatesConverter,
  ) {
    final Map<String, Object?> result = Map<String, Object?>.from(target);
    if (result['position'] != null) {
      result['position'] = coordinatesConverter.convertViewPositionToModelPosition(
          result['position'] as Position);
    }
    if (result['range'] != null) {
      result['range'] = coordinatesConverter.convertViewRangeToModelRange(
          result['range'] as Range);
    }
    if (result['type'] == MouseTargetTypeForViewInput.GUTTER_VIEW_ZONE ||
        result['type'] == MouseTargetTypeForViewInput.CONTENT_VIEW_ZONE) {
      result['detail'] = _convertViewToModelViewZoneData(
          result['detail'] as Map<String, Object?>, coordinatesConverter);
    }
    return result;
  }

  static Map<String, Object?> _convertViewToModelViewZoneData(
    Map<String, Object?> data,
    ICoordinatesConverterForViewInput coordinatesConverter,
  ) {
    Object? convert(Object? p) => p == null
        ? null
        : coordinatesConverter.convertViewPositionToModelPosition(p as Position);
    return <String, Object?>{
      'viewZoneId': data['viewZoneId'],
      'positionBefore': convert(data['positionBefore']),
      'positionAfter': convert(data['positionAfter']),
      'position': convert(data['position']),
      'afterLineNumber': coordinatesConverter
          .convertViewPositionToModelPosition(
              Position(data['afterLineNumber'] as int, 1))
          .lineNumber,
    };
  }
}
