// Truth-driven tests for batch181d:
// externalLinesDiffComputer.ts, linesDiffComputers.ts.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart' show Range;
import 'package:semi_design_flutter/src/monaco/editor/common/core/ranges/lineRange.dart' show LineRange;
import 'package:semi_design_flutter/src/monaco/editor/common/diff/externalLinesDiffComputer.dart' as ext;
import 'package:semi_design_flutter/src/monaco/editor/common/diff/linesDiffComputer.dart' as ldc;
import 'package:semi_design_flutter/src/monaco/editor/common/diff/linesDiffComputers.dart' as factories;
import 'package:semi_design_flutter/src/monaco/editor/common/diff/rangeMapping.dart' as rm;

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch181d_truth.json').readAsStringSync())
        as Map<String, dynamic>;

class _Computer implements ext.IExternalDiffComputer {
  _Computer(this.prefix, this.calls);

  final String prefix;
  final List<Map<String, Object?>> calls;

  @override
  ext.ExternalDiffResult computeDiff(
      String original, String modified, ext.ExternalDiffComputeOptions options) {
    calls.add(<String, Object?>{
      '${prefix}Original': original,
      '${prefix}Modified': modified,
      '${prefix}Options': <String, Object?>{
        'maxComputationTimeMs': options.maxComputationTimeMs,
        'computeMoves': options.computeMoves,
        'extendToSubwords': options.extendToSubwords,
      },
    });
    return ext.ExternalDiffResult(
      ext.ExternalEditResult(<ext.ExternalReplacement>[
        ext.ExternalReplacement(
          const ext.ExternalOffsetRange(0, 5),
          'ALPHA',
          const ext.ExternalReplacementData(false),
        ),
        ext.ExternalReplacement(
          const ext.ExternalOffsetRange(5, 6),
          '',
          const ext.ExternalReplacementData(true),
        ),
      ]),
      <ext.ExternalMove>[
        ext.ExternalMove(
          ext.ExternalMoveRange(
            const ext.ExternalOffsetRange(11, 18),
            const ext.ExternalOffsetRange(24, 30),
          ),
          ext.ExternalInnerEdit(<ext.ExternalReplacement>[
            ext.ExternalReplacement(
              const ext.ExternalOffsetRange(0, 6),
              'SECOND',
              const ext.ExternalReplacementData(false),
            ),
          ]),
        ),
      ],
      true,
    );
  }
}

class _Module implements ext.ExternalDiffModule {
  _Module(this.prefix, this.calls);

  final String prefix;
  final List<Map<String, Object?>> calls;

  @override
  Future<ext.IExternalDiffComputer> createDiffComputer({
    required bool useWasm,
  }) async {
    calls.add(<String, Object?>{
      '${prefix}FactoryOptions': <String, Object?>{'useWasm': useWasm},
    });
    return _Computer(prefix, calls);
  }
}

ldc.ILinesDiffComputerOptions options([
  Map<String, dynamic> patch = const <String, dynamic>{},
]) =>
    ldc.ILinesDiffComputerOptions(
      ignoreTrimWhitespace: patch['ignoreTrimWhitespace'] as bool? ?? false,
      maxComputationTimeMs: patch['maxComputationTimeMs'] as int? ?? 0,
      computeMoves: patch['computeMoves'] as bool? ?? false,
      extendToSubwords: patch['extendToSubwords'] as bool? ?? false,
    );

List<int> jlr(LineRange r) => <int>[
      r.startLineNumber,
      r.endLineNumberExclusive,
    ];

List<int> jrange(Range r) => <int>[
      r.startLineNumber,
      r.startColumn,
      r.endLineNumber,
      r.endColumn,
    ];

Map<String, Object?> jrm(rm.RangeMapping m) => <String, Object?>{
      'original': jrange(m.originalRange),
      'modified': jrange(m.modifiedRange),
    };

Map<String, Object?> jchange(rm.DetailedLineRangeMapping c) =>
    <String, Object?>{
      'original': jlr(c.original),
      'modified': jlr(c.modified),
      'innerChanges': c.innerChanges?.map(jrm).toList(),
    };

Map<String, Object?> jmove(ldc.MovedText m) => <String, Object?>{
      'lineRangeMapping': <String, Object?>{
        'original': jlr(m.lineRangeMapping.original),
        'modified': jlr(m.lineRangeMapping.modified),
      },
      'changes': m.changes.map(jchange).toList(),
    };

Map<String, Object?> jdiff(ldc.LinesDiff d) => <String, Object?>{
      'changes': d.changes.map(jchange).toList(),
      'moves': d.moves.map(jmove).toList(),
      'hitTimeout': d.hitTimeout,
    };

void main() {
  group('batch181d (truth-driven)', () {
    final List<String> originalLines = <String>[
      'alpha beta',
      'second',
      'third',
      'fourth',
    ];
    final List<String> modifiedLines = <String>[
      'ALPHA beta',
      'third',
      'fourth',
      'second',
    ];

    test('exports', () {
      final Map<String, dynamic> e = truth['exports'] as Map<String, dynamic>;
      expect(e['externalLinesDiffComputer'], <dynamic>[
        'createExternalLinesDiffComputer',
        'getExternalLinesDiffComputer',
      ]);
      expect(e['linesDiffComputers'], <dynamic>['linesDiffComputers']);
    });

    test('adapter mapping and external call seam', () async {
      final List<Map<String, Object?>> calls = <Map<String, Object?>>[];
      final _Module module = _Module('direct', calls);
      final ldc.ILinesDiffComputer adapter =
          await ext.createExternalLinesDiffComputer(module, false);

      final Map<String, Object?> ignored = jdiff(adapter.computeDiff(
        originalLines,
        modifiedLines,
        options(<String, dynamic>{
          'ignoreTrimWhitespace': true,
          'computeMoves': true,
        }),
      ));
      final Map<String, Object?> considered = jdiff(adapter.computeDiff(
        originalLines,
        modifiedLines,
        options(),
      ));

      final Map<String, dynamic> expected =
          (truth['directAdapter'] as Map<String, dynamic>);
      expect(ignored, expected['withTrimIgnored']);
      expect(considered, expected['withTrimConsidered']);
      expect(calls, expected['calls']);
    });

    test('linesDiffComputers factories and cache', () async {
      final List<Map<String, Object?>> calls = <Map<String, Object?>>[];
      ext.externalDiffModuleProvider = () async => _Module('module', calls);

      final ldc.ILinesDiffComputer advancedExternal =
          await factories.linesDiffComputers.getAdvancedExternal();
      final ldc.ILinesDiffComputer advancedWasm =
          await factories.linesDiffComputers.getAdvancedWasm();
      final ldc.ILinesDiffComputer cachedAgain =
          await factories.linesDiffComputers.getAdvancedExternal();

      final Map<String, dynamic> expected =
          (truth['moduleFactories'] as Map<String, dynamic>);
      expect(<String>[
        'getAdvancedExternal',
        'getAdvancedWasm',
        'getDefault',
        'getLegacy',
      ], expected['keys']);
      expect(
          factories.linesDiffComputers.getLegacy().runtimeType.toString(),
          expected['legacyType']);
      expect(
          factories.linesDiffComputers.getDefault().runtimeType.toString(),
          expected['defaultType']);
      expect(advancedExternal.runtimeType.toString(),
          expected['advancedExternalType']);
      expect(advancedWasm.runtimeType.toString(),
          expected['advancedWasmType']);
      expect(identical(advancedExternal, cachedAgain),
          expected['cachedSameInstance']);
      expect(calls, expected['factoryCalls']);
    });
  });
}
