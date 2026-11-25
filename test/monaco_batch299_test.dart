// batch299: viewModelEventDispatcher.ts truth replay.
// Truth from tool/ts2dart/batch299_truth.json (recursive TS transpile + vm,
// real outgoing event merging and collector/handler delivery).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/selection.dart'
    show Selection;
import 'package:semi_design_flutter/src/monaco/editor/common/viewModelEventDispatcher.dart'
    show
        ContentSizeChangedEvent,
        CursorStateChangedEvent,
        FocusChangedEvent,
        HiddenAreasChangedEvent,
        ModelContentChangedEvent,
        ModelDecorationsChangedEvent,
        ModelFontChangedEvent,
        ModelLanguageChangedEvent,
        ModelLanguageConfigurationChangedEvent,
        ModelLineHeightChangedEvent,
        ModelOptionsChangedEvent,
        ModelTokensChangedEvent,
        OutgoingViewModelEvent,
        ReadOnlyEditAttemptEvent,
        ScrollChangedEvent,
        ViewEventHandler,
        ViewModelEventDispatcher,
        ViewZonesChangedEvent,
        WidgetFocusChangedEvent,
        viewModelEventDispatcherWarn;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch299_truth.json').readAsStringSync())
    as Map<String, dynamic>;

Object? _norm(Object? v) {
  if (v == null) return null;
  if (v is Map) {
    return v.map<String, Object?>((k, e) => MapEntry<String, Object?>(k as String, _norm(e)));
  }
  if (v is List) return v.map(_norm).toList();
  return v;
}

int _i(Object? v) => (v as num).toInt();

Selection _selection(List<dynamic> d) =>
    Selection(_i(d[0]), _i(d[1]), _i(d[2]), _i(d[3]));

OutgoingViewModelEvent _event(Map<String, dynamic> s) {
  switch (s['kind'] as String) {
    case 'contentSize':
      return ContentSizeChangedEvent(_i(s['oldW']), _i(s['oldH']),
          _i(s['w']), _i(s['h']));
    case 'focus':
      return FocusChangedEvent(s['old'] as bool, s['next'] as bool);
    case 'widgetFocus':
      return WidgetFocusChangedEvent(s['old'] as bool, s['next'] as bool);
    case 'scroll':
      return ScrollChangedEvent(
        _i(s['oldW']), _i(s['oldL']), _i(s['oldH']), _i(s['oldT']),
        _i(s['w']), _i(s['l']), _i(s['h']), _i(s['t']),
      );
    case 'viewZones':
      return ViewZonesChangedEvent();
    case 'hiddenAreas':
      return HiddenAreasChangedEvent();
    case 'readOnly':
      return ReadOnlyEditAttemptEvent();
    case 'cursor':
      return CursorStateChangedEvent(
        s['old'] == null
            ? null
            : (s['old'] as List<dynamic>)
                .map<Selection>((dynamic d) => _selection(d as List<dynamic>))
                .toList(),
        (s['now'] as List<dynamic>)
            .map<Selection>((dynamic d) => _selection(d as List<dynamic>))
            .toList(),
        _i(s['oldVersion']),
        _i(s['version']),
        s['source'] as String,
        _i(s['reason']),
        s['max'] as bool,
      );
    case 'modelDecorations':
      return ModelDecorationsChangedEvent(s['event']);
    case 'modelLanguage':
      return ModelLanguageChangedEvent(s['event']);
    case 'modelLanguageConfiguration':
      return ModelLanguageConfigurationChangedEvent(s['event']);
    case 'modelContent':
      return ModelContentChangedEvent(s['event']);
    case 'modelOptions':
      return ModelOptionsChangedEvent(s['event']);
    case 'modelTokens':
      return ModelTokensChangedEvent(s['event']);
    case 'modelLineHeight':
      return ModelLineHeightChangedEvent(s['event']);
    case 'modelFont':
      return ModelFontChangedEvent(s['event']);
    default:
      throw StateError('unknown event ${s['kind']}');
  }
}

Map<String, Object?> _eventJson(OutgoingViewModelEvent e) {
  final Map<String, Object?> out = <String, Object?>{
    'kind': e.kind,
    'noOp': e.isNoOp(),
  };
  void copy(String key, Object? value) {
    if (value != null) out[key] = value;
  }

  if (e is ContentSizeChangedEvent) {
    copy('contentWidth', e.contentWidth);
    copy('contentHeight', e.contentHeight);
    copy('contentWidthChanged', e.contentWidthChanged);
    copy('contentHeightChanged', e.contentHeightChanged);
  } else if (e is FocusChangedEvent) {
    copy('oldHasFocus', e.oldHasFocus);
    copy('hasFocus', e.hasFocus);
  } else if (e is WidgetFocusChangedEvent) {
    copy('oldHasFocus', e.oldHasFocus);
    copy('hasFocus', e.hasFocus);
  } else if (e is ScrollChangedEvent) {
    copy('scrollWidth', e.scrollWidth);
    copy('scrollLeft', e.scrollLeft);
    copy('scrollHeight', e.scrollHeight);
    copy('scrollTop', e.scrollTop);
    copy('scrollWidthChanged', e.scrollWidthChanged);
    copy('scrollLeftChanged', e.scrollLeftChanged);
    copy('scrollHeightChanged', e.scrollHeightChanged);
    copy('scrollTopChanged', e.scrollTopChanged);
  } else if (e is CursorStateChangedEvent) {
    copy('oldModelVersionId', e.oldModelVersionId);
    copy('modelVersionId', e.modelVersionId);
    copy('source', e.source);
    copy('reason', e.reason);
    copy('reachedMaxCursorCount', e.reachedMaxCursorCount);
    out['selections'] = e.selections
        .map((s) => <Object?>[
              s.startLineNumber, s.startColumn, s.endLineNumber, s.endColumn,
            ])
        .toList();
    out['oldSelections'] = e.oldSelections == null
        ? null
        : e.oldSelections!
            .map((s) => <Object?>[
                  s.startLineNumber, s.startColumn, s.endLineNumber, s.endColumn,
                ])
            .toList();
  }
  return out;
}

class _Handler implements ViewEventHandler {
  _Handler(this.id, this.delivered);

  final String id;
  final List<Object?> delivered;

  @override
  void handleEvents(List<Object> events) {
    delivered.add(<Object?>[
      id,
      events.map((e) => (e as Map<String, dynamic>)['id']).toList(),
    ]);
  }
}

void main() {
  final Map<String, dynamic> truth = _truth();
  final List<Object?> warnings = <Object?>[];
  viewModelEventDispatcherWarn = (Object? message) => warnings.add(message);

  group('batch299 viewModelEventDispatcher truth replay', () {
    for (final dynamic rawCase in truth['cases'] as List<dynamic>) {
      final Map<String, dynamic> c = rawCase as Map<String, dynamic>;
      test(c['name'] as String, () {
        final ViewModelEventDispatcher dispatcher = ViewModelEventDispatcher();
        final List<Object?> emitted = <Object?>[];
        final List<Object?> delivered = <Object?>[];
        dispatcher.onEvent((e) => emitted.add(_eventJson(e)));
        final List<ViewEventHandler> handlers = <ViewEventHandler>[];

        final List<dynamic> ops = c['ops'] as List<dynamic>;
        final List<dynamic> results = c['results'] as List<dynamic>;
        for (int i = 0; i < ops.length; i++) {
          final Map<String, dynamic> op = ops[i] as Map<String, dynamic>;
          switch (op['kind'] as String) {
            case 'emit':
              dispatcher.emitOutgoingEvent(_event(op['event'] as Map<String, dynamic>));
              break;
            case 'begin':
              dispatcher.beginEmitViewEvents();
              break;
            case 'end':
              dispatcher.endEmitViewEvents();
              break;
            case 'collectorEmitOutgoing':
              dispatcher
                  .beginEmitViewEvents()
                  .emitOutgoingEvent(_event(op['event'] as Map<String, dynamic>));
              dispatcher.endEmitViewEvents();
              break;
            case 'viewEvent':
              dispatcher
                  .beginEmitViewEvents()
                  .emitViewEvent(<String, dynamic>{'id': op['id']});
              dispatcher.endEmitViewEvents();
              break;
            case 'emitSingle':
              dispatcher.emitSingleViewEvent(<String, dynamic>{'id': op['id']});
              break;
            case 'addHandler':
              handlers.add(_Handler(op['id'] as String, delivered));
              dispatcher.addViewEventHandler(handlers[handlers.length - 1]);
              break;
            case 'removeHandler':
              dispatcher.removeViewEventHandler(handlers[_i(op['index'])]);
              break;
            default:
              fail('unknown op ${op['kind']}');
          }
          expect(
            <String, Object?>{
              'label': op['label'],
              'emitted': emitted,
              'delivered': delivered,
              'warnings': warnings,
            },
            _norm(results[i] as Object?),
          );
          emitted.clear();
          delivered.clear();
          warnings.clear();
        }
      });
    }
  });
}
