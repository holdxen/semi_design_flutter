// 1:1 replay of `editor/common/viewModel/inlineDecorations.ts`.
// Truth: `tool/ts2dart/_batch412_truth.cjs` -> `batch412_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/coordinatesConverter.dart'
    show ICoordinatesConverter;
import '../lib/src/monaco/editor/common/core/position.dart' show Position;
import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/common/model.dart' show PositionAffinity;
import '../lib/src/monaco/editor/common/viewModel.dart'
    show ViewModelDecoration;
import '../lib/src/monaco/editor/common/viewModel/inlineDecorations.dart';

Map<String, dynamic> _map(dynamic v) => (v as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root = _map(
    jsonDecode(File('tool/ts2dart/batch412_truth.json').readAsStringSync()),
  );
  return <String, dynamic>{
    for (final dynamic r in root['results'] as List<dynamic>)
      (r as Map)['label'] as String: <String, dynamic>{
        for (final MapEntry<Object?, Object?> e
            in (r as Map).cast<Object?, Object?>().entries)
          if (e.key != 'label') e.key as String: e.value,
      },
  };
}

class _Options implements IInlineModelDecorationOptions {
  @override
  final String? inlineClassName;
  @override
  final bool? inlineClassNameAffectsLetterSpacing;
  @override
  final String? beforeContentClassName;
  @override
  final String? afterContentClassName;
  @override
  final bool? affectsFont;
  @override
  final bool? isWholeLine;
  @override
  final bool? visible;

  _Options({
    this.inlineClassName,
    this.inlineClassNameAffectsLetterSpacing,
    this.beforeContentClassName,
    this.afterContentClassName,
    this.affectsFont,
    this.isWholeLine,
    this.visible,
  });
}

class _Decoration implements IInlineModelDecoration {
  @override
  final String id;
  @override
  final Range range;
  @override
  final IInlineModelDecorationOptions options;

  _Decoration(this.id, this.range, this.options);
}

class _Context implements IInlineModelDecorationsComputerContext {
  final List<IInlineModelDecoration> decorations;
  _Context(this.decorations);

  @override
  List<IInlineModelDecoration> getModelDecorations(
    Range viewRange,
    bool onlyMinimapDecorations,
    bool onlyMarginDecorations,
  ) =>
      decorations
          .where((IInlineModelDecoration d) =>
              d.range.endLineNumber >= viewRange.startLineNumber &&
              d.range.startLineNumber <= viewRange.endLineNumber)
          .toList();
}

class _Model implements IInlineTextModel {
  @override
  int getLineMaxColumn(int lineNumber) => 100;
}

class _Converter implements ICoordinatesConverter {
  @override
  Range convertModelRangeToViewRange(Range range, {Object? affinity}) =>
      Range(
        range.startLineNumber,
        range.startColumn,
        range.endLineNumber,
        range.endColumn,
      );

  @override
  Position convertModelPositionToViewPosition(
    Position modelPosition, {
    Object? affinity,
    bool allowZeroLineNumber = false,
    bool belowHiddenRanges = false,
  }) =>
      modelPosition;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Map<String, Object?> _rangeJson(Range r) => <String, Object?>{
      'startLineNumber': r.startLineNumber,
      'startColumn': r.startColumn,
      'endLineNumber': r.endLineNumber,
      'endColumn': r.endColumn,
    };

Map<String, Object?> _inlineJson(InlineDecoration d) => <String, Object?>{
      'startLineNumber': d.range.startLineNumber,
      'startColumn': d.range.startColumn,
      'endLineNumber': d.range.endLineNumber,
      'endColumn': d.range.endColumn,
      'className': d.inlineClassName,
      'type': d.type,
    };

Map<String, Object?> _collectionJson(IViewDecorationsCollection c) =>
    <String, Object?>{
      'decorations': c.decorations.map((ViewModelDecoration d) {
        final IInlineModelDecorationOptions o =
            d.options as IInlineModelDecorationOptions;
        final Map<String, Object?> opts = <String, Object?>{};
        if (o.inlineClassName != null) {
          opts['inlineClassName'] = o.inlineClassName;
        }
        if (o.inlineClassNameAffectsLetterSpacing != null) {
          opts['inlineClassNameAffectsLetterSpacing'] =
              o.inlineClassNameAffectsLetterSpacing;
        }
        if (o.affectsFont != null) opts['affectsFont'] = o.affectsFont;
        if (o.beforeContentClassName != null) {
          opts['beforeContentClassName'] = o.beforeContentClassName;
        }
        if (o.afterContentClassName != null) {
          opts['afterContentClassName'] = o.afterContentClassName;
        }
        if (o.visible != null) opts['visible'] = o.visible;
        return <String, Object?>{
          'range': _rangeJson(d.range),
          'options': opts,
        };
      }).toList(),
      'inlineDecorations': c.inlineDecorations
          .map((List<InlineDecoration> line) =>
              line.map(_inlineJson).toList())
          .toList(),
      'hasVariableFonts': c.hasVariableFonts,
    };

class _InjectOptions implements InjectedTextOptions {
  @override
  final String content;
  @override
  final num? widthInEm;
  @override
  final String? inlineClassName;
  @override
  final bool? inlineClassNameAffectsLetterSpacing;

  _InjectOptions(
    this.content,
    this.widthInEm,
    this.inlineClassName,
    this.inlineClassNameAffectsLetterSpacing,
  );
}

class _InjectContext implements IInjectedTextContext {
  final List<int>? offsets;
  final List<InjectedTextOptions>? options;
  final List<int> breakOffsets;
  final int indentLength;
  final int baseViewLine;

  _InjectContext({
    this.offsets,
    this.options,
    required this.breakOffsets,
    this.indentLength = 0,
    this.baseViewLine = 1,
  });

  @override
  List<int>? getInjectionOffsets(int modelLineNumber) => offsets;

  @override
  List<InjectedTextOptions>? getInjectionOptions(int modelLineNumber) => options;

  @override
  List<int> getBreakOffsets(int modelLineNumber) => breakOffsets;

  @override
  int getWrappedTextIndentLength(int modelLineNumber) => indentLength;

  @override
  int getBaseViewLineNumber(int modelLineNumber) => baseViewLine;
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('inline decorations replay TS truth', () {
    final Map<String, Object?> actual = <String, Object?>{};

    final List<IInlineModelDecoration> modelDecorations =
        <IInlineModelDecoration>[
      _Decoration(
        'd1',
        Range(1, 2, 3, 5),
        _Options(
          inlineClassName: 'inline',
          inlineClassNameAffectsLetterSpacing: false,
          affectsFont: false,
          visible: true,
        ),
      ),
      _Decoration(
        'd2',
        Range(2, 3, 2, 7),
        _Options(
          inlineClassName: 'spaced',
          inlineClassNameAffectsLetterSpacing: true,
          affectsFont: true,
          beforeContentClassName: 'before',
          afterContentClassName: 'after',
          visible: true,
        ),
      ),
      _Decoration(
        'd3',
        Range(1, 1, 1, 4),
        _Options(inlineClassName: 'hidden', affectsFont: false, visible: false),
      ),
    ];
    final InlineModelDecorationsComputer computer =
        InlineModelDecorationsComputer(
      _Context(modelDecorations),
      _Model(),
      _Converter(),
    );

    actual['model-get-decorations'] = <String, Object?>{
      'data': _collectionJson(
        computer.getDecorations(Range(1, 1, 3, 100), false, false),
      ),
    };

    actual['model-get-inline'] = <String, Object?>{
      'inline': computer
          .getInlineDecorations(2)
          .map((List<InlineDecoration> line) =>
              line.map(_inlineJson).toList())
          .toList(),
    };

    final IViewDecorationsCollection c1 =
        computer.getDecorations(Range(1, 1, 3, 100), false, false);
    final IViewDecorationsCollection c2 =
        computer.getDecorations(Range(1, 1, 3, 100), false, false);
    final bool sameBefore = identical(c1.decorations[0], c2.decorations[0]);
    computer.onModelDecorationsChanged();
    final IViewDecorationsCollection c3 =
        computer.getDecorations(Range(1, 1, 3, 100), false, false);
    actual['model-cache'] = <String, Object?>{
      'sameBefore': sameBefore,
      'sameAfter': identical(c1.decorations[0], c3.decorations[0]),
    };

    // injected
    final InjectedTextInlineDecorationsComputer inj =
        InjectedTextInlineDecorationsComputer(_InjectContext(
      offsets: <int>[2, 6],
      options: <InjectedTextOptions>[
        _InjectOptions('XY', null, 'inj', false),
        _InjectOptions('Z', null, 'wide', true),
      ],
      breakOffsets: <int>[4, 10],
      indentLength: 3,
      baseViewLine: 5,
    ));
    actual['injected'] = <String, Object?>{
      'inline': inj
          .getInlineDecorations(1)
          .map((List<InlineDecoration> line) =>
              line.map(_inlineJson).toList())
          .toList(),
    };

    final InjectedTextInlineDecorationsComputer injEmpty =
        InjectedTextInlineDecorationsComputer(
      _InjectContext(offsets: null, options: null, breakOffsets: <int>[]),
    );
    actual['injected-empty'] = <String, Object?>{
      'inline': injEmpty
          .getInlineDecorations(1)
          .map((List<InlineDecoration> line) =>
              line.map(_inlineJson).toList())
          .toList(),
    };

    final InjectedTextInlineDecorationsComputer injWidth =
        InjectedTextInlineDecorationsComputer(_InjectContext(
      offsets: <int>[3],
      options: <InjectedTextOptions>[
        _InjectOptions('', 1, 'wonly', null),
      ],
      breakOffsets: <int>[5],
    ));
    actual['injected-width-only'] = <String, Object?>{
      'inline': injWidth
          .getInlineDecorations(1)
          .map((List<InlineDecoration> line) =>
              line.map(_inlineJson).toList())
          .toList(),
    };

    for (final String key in truth.keys) {
      expect(
        jsonEncode(actual[key]),
        jsonEncode(truth[key]),
        reason: 'mismatch at $key',
      );
    }
  });
}
