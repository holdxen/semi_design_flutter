// batch276: viewEvents.ts truth replay.
// Truth from tool/ts2dart/batch276_truth.json (recursive TS transpile+vm).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/scrollable.dart'
    show ScrollEvent;
import 'package:semi_design_flutter/src/monaco/editor/common/config/editorOptions.dart'
    show ConfigurationChangedEvent;
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart'
    show Range;
import 'package:semi_design_flutter/src/monaco/editor/common/core/selection.dart'
    show Selection;
import 'package:semi_design_flutter/src/monaco/editor/common/viewEvents.dart'
    show
      IModelDecorationsChangedEventForView,
      VerticalRevealType,
      ViewCompositionEndEvent,
      ViewCompositionStartEvent,
      ViewConfigurationChangedEvent,
      ViewCursorStateChangedEvent,
      ViewDecorationsChangedEvent,
      ViewEventType,
      ViewFlushedEvent,
      ViewFocusChangedEvent,
      ViewLanguageConfigurationEvent,
      ViewLineMappingChangedEvent,
      ViewLinesChangedEvent,
      ViewLinesDeletedEvent,
      ViewLinesInsertedEvent,
      ViewRevealRangeRequestEvent,
      ViewScrollChangedEvent,
      ViewThemeChangedEvent,
      ViewTokensChangedEvent,
      ViewTokensColorsChangedEvent,
      ViewZonesChangedEvent;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch276_truth.json').readAsStringSync())
    as Map<String, dynamic>;

class _Decorations implements IModelDecorationsChangedEventForView {
  @override
  final bool affectsMinimap;
  @override
  final bool affectsOverviewRuler;
  @override
  final bool affectsGlyphMargin;
  @override
  final bool affectsLineNumber;

  const _Decorations(this.affectsMinimap, this.affectsOverviewRuler,
      this.affectsGlyphMargin, this.affectsLineNumber);
}

List<int> _range(Range r) => <int>[
  r.startLineNumber,
  r.startColumn,
  r.endLineNumber,
  r.endColumn,
];

List<int> _selection(Selection s) => <int>[
  s.startLineNumber,
  s.startColumn,
  s.endLineNumber,
  s.endColumn,
];

Map<String, dynamic> _actual(String name) {
  final selections = <Selection>[
    Selection(1, 2, 1, 4),
    Selection(3, 1, 3, 2),
  ];
  final configValues = List<bool>.filled(9, false);
  configValues[7] = true;
  const decor = _Decorations(true, false, true, false);
  final scroll = ScrollEvent(
    inSmoothScrolling: false,
    oldWidth: 0,
    oldScrollWidth: 0,
    oldScrollLeft: 0,
    width: 0,
    scrollWidth: 100,
    scrollLeft: 5,
    oldHeight: 0,
    oldScrollHeight: 0,
    oldScrollTop: 0,
    height: 0,
    scrollHeight: 200,
    scrollTop: 10,
    widthChanged: false,
    scrollWidthChanged: true,
    scrollLeftChanged: false,
    heightChanged: false,
    scrollHeightChanged: true,
    scrollTopChanged: false,
  );

  switch (name) {
    case 'ViewCompositionStartEvent':
      final e = ViewCompositionStartEvent();
      return <String, dynamic>{'type': e.type, 'props': <String, dynamic>{}};
    case 'ViewCompositionEndEvent':
      final e = ViewCompositionEndEvent();
      return <String, dynamic>{'type': e.type, 'props': <String, dynamic>{}};
    case 'ViewConfigurationChangedEvent':
      final e = ViewConfigurationChangedEvent(ConfigurationChangedEvent(configValues));
      return <String, dynamic>{
        'type': e.type,
        'props': <String, dynamic>{
          'hasChanged7': e.hasChanged(7),
          'hasChanged8': e.hasChanged(8),
        },
      };
    case 'ViewCursorStateChangedEvent':
      final e = ViewCursorStateChangedEvent(selections, selections, 2);
      return <String, dynamic>{
        'type': e.type,
        'props': <String, dynamic>{
          'selections': selections.map(_selection).toList(),
          'modelSelections': selections.map(_selection).toList(),
          'reason': e.reason,
        },
      };
    case 'ViewDecorationsChangedEvent-with-source':
      final e = ViewDecorationsChangedEvent(decor);
      return <String, dynamic>{
        'type': e.type,
        'props': <String, dynamic>{
          'affectsMinimap': e.affectsMinimap,
          'affectsOverviewRuler': e.affectsOverviewRuler,
          'affectsGlyphMargin': e.affectsGlyphMargin,
          'affectsLineNumber': e.affectsLineNumber,
        },
      };
    case 'ViewDecorationsChangedEvent-null-source':
      final e = ViewDecorationsChangedEvent(null);
      return <String, dynamic>{
        'type': e.type,
        'props': <String, dynamic>{
          'affectsMinimap': e.affectsMinimap,
          'affectsOverviewRuler': e.affectsOverviewRuler,
          'affectsGlyphMargin': e.affectsGlyphMargin,
          'affectsLineNumber': e.affectsLineNumber,
        },
      };
    case 'ViewFlushedEvent':
      final e = ViewFlushedEvent();
      return <String, dynamic>{'type': e.type, 'props': <String, dynamic>{}};
    case 'ViewFocusChangedEvent':
      final e = ViewFocusChangedEvent(true);
      return <String, dynamic>{
        'type': e.type,
        'props': <String, dynamic>{'isFocused': e.isFocused},
      };
    case 'ViewLanguageConfigurationEvent':
      final e = ViewLanguageConfigurationEvent();
      return <String, dynamic>{'type': e.type, 'props': <String, dynamic>{}};
    case 'ViewLineMappingChangedEvent':
      final e = ViewLineMappingChangedEvent();
      return <String, dynamic>{'type': e.type, 'props': <String, dynamic>{}};
    case 'ViewLinesChangedEvent':
      final e = ViewLinesChangedEvent(5, 3);
      return <String, dynamic>{
        'type': e.type,
        'props': <String, dynamic>{
          'fromLineNumber': e.fromLineNumber,
          'count': e.count,
        },
      };
    case 'ViewLinesDeletedEvent':
      final e = ViewLinesDeletedEvent(5, 7);
      return <String, dynamic>{
        'type': e.type,
        'props': <String, dynamic>{
          'fromLineNumber': e.fromLineNumber,
          'toLineNumber': e.toLineNumber,
        },
      };
    case 'ViewLinesInsertedEvent':
      final e = ViewLinesInsertedEvent(5, 7);
      return <String, dynamic>{
        'type': e.type,
        'props': <String, dynamic>{
          'fromLineNumber': e.fromLineNumber,
          'toLineNumber': e.toLineNumber,
        },
      };
    case 'ViewRevealRangeRequestEvent':
      final e = ViewRevealRangeRequestEvent(
        'test', true, Range(2, 3, 4, 5), selections, 3, false, 1,
      );
      return <String, dynamic>{
        'type': e.type,
        'props': <String, dynamic>{
          'source': e.source,
          'minimalReveal': e.minimalReveal,
          'range': _range(e.range!),
          'selections': e.selections!.map(_selection).toList(),
          'verticalType': e.verticalType,
          'revealHorizontal': e.revealHorizontal,
          'scrollType': e.scrollType,
        },
      };
    case 'ViewScrollChangedEvent':
      final e = ViewScrollChangedEvent(scroll);
      return <String, dynamic>{
        'type': e.type,
        'props': <String, dynamic>{
          'scrollWidth': e.scrollWidth,
          'scrollLeft': e.scrollLeft,
          'scrollHeight': e.scrollHeight,
          'scrollTop': e.scrollTop,
          'scrollWidthChanged': e.scrollWidthChanged,
          'scrollLeftChanged': e.scrollLeftChanged,
          'scrollHeightChanged': e.scrollHeightChanged,
          'scrollTopChanged': e.scrollTopChanged,
        },
      };
    case 'ViewThemeChangedEvent':
      final e = ViewThemeChangedEvent(<String, Object?>{'id': 'dark'});
      return <String, dynamic>{
        'type': e.type,
        'props': <String, dynamic>{
          'themeId': (e.theme as Map<String, Object?>)['id'],
        },
      };
    case 'ViewTokensChangedEvent':
      final e = ViewTokensChangedEvent(<({int fromLineNumber, int toLineNumber})>[
        (fromLineNumber: 1, toLineNumber: 3),
        (fromLineNumber: 5, toLineNumber: 5),
      ]);
      return <String, dynamic>{
        'type': e.type,
        'props': <String, dynamic>{
          'ranges': e.ranges
              .map((r) => <int>[r.fromLineNumber, r.toLineNumber])
              .toList(),
        },
      };
    case 'ViewTokensColorsChangedEvent':
      final e = ViewTokensColorsChangedEvent();
      return <String, dynamic>{'type': e.type, 'props': <String, dynamic>{}};
    case 'ViewZonesChangedEvent':
      final e = ViewZonesChangedEvent();
      return <String, dynamic>{'type': e.type, 'props': <String, dynamic>{}};
    default:
      fail('unsupported case: $name');
  }
}

void main() {
  final t = _truth();

  test('b276 const enum values match truth', () {
    final c = t['consts'] as Map<String, dynamic>;
    expect(c['ViewEventType'], <String, int>{
      'ViewCompositionStart': ViewEventType.ViewCompositionStart,
      'ViewCompositionEnd': ViewEventType.ViewCompositionEnd,
      'ViewConfigurationChanged': ViewEventType.ViewConfigurationChanged,
      'ViewCursorStateChanged': ViewEventType.ViewCursorStateChanged,
      'ViewDecorationsChanged': ViewEventType.ViewDecorationsChanged,
      'ViewFlushed': ViewEventType.ViewFlushed,
      'ViewFocusChanged': ViewEventType.ViewFocusChanged,
      'ViewLanguageConfigurationChanged':
          ViewEventType.ViewLanguageConfigurationChanged,
      'ViewLineMappingChanged': ViewEventType.ViewLineMappingChanged,
      'ViewLinesChanged': ViewEventType.ViewLinesChanged,
      'ViewLinesDeleted': ViewEventType.ViewLinesDeleted,
      'ViewLinesInserted': ViewEventType.ViewLinesInserted,
      'ViewRevealRangeRequest': ViewEventType.ViewRevealRangeRequest,
      'ViewScrollChanged': ViewEventType.ViewScrollChanged,
      'ViewThemeChanged': ViewEventType.ViewThemeChanged,
      'ViewTokensChanged': ViewEventType.ViewTokensChanged,
      'ViewTokensColorsChanged': ViewEventType.ViewTokensColorsChanged,
      'ViewZonesChanged': ViewEventType.ViewZonesChanged,
    });
    expect(c['VerticalRevealType'], <String, int>{
      'Simple': VerticalRevealType.Simple,
      'Center': VerticalRevealType.Center,
      'CenterIfOutsideViewport': VerticalRevealType.CenterIfOutsideViewport,
      'Top': VerticalRevealType.Top,
      'Bottom': VerticalRevealType.Bottom,
      'NearTop': VerticalRevealType.NearTop,
      'NearTopIfOutsideViewport': VerticalRevealType.NearTopIfOutsideViewport,
    });
  });

  for (final raw in t['cases'] as List<dynamic>) {
    final c = raw as Map<String, dynamic>;
    test('b276 ${c['name']}: fields match truth', () {
      expect(_actual(c['name'] as String), <String, dynamic>{
        'type': c['type'],
        'props': c['props'],
      });
    });
  }
}
