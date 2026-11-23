import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/base/common/cancellation.dart'
    as cancel;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    as life;
import 'package:semi_design_flutter/src/monaco/base/test/common/virtualScheduling/embedding.dart'
    as emb;
import 'package:semi_design_flutter/src/monaco/base/test/common/virtualScheduling/processor.dart'
    as proc;
import 'package:semi_design_flutter/src/monaco/base/test/common/virtualScheduling/timeApi.dart'
    as api;
import 'package:semi_design_flutter/src/monaco/base/test/common/virtualScheduling/trace.dart'
    as trace;
import 'package:semi_design_flutter/src/monaco/base/test/common/virtualScheduling/virtualClock.dart'
    as vc;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/gpuDisposable.dart'
    as gpu;
import 'package:semi_design_flutter/src/monaco/editor/common/model/tokens/treeSitter/cursorUtils.dart'
    as cu;
import 'package:semi_design_flutter/src/monaco/editor/contrib/inlineCompletions/browser/view/inlineEdits/utils/flexBoxLayout.dart'
    as flex;
import 'package:semi_design_flutter/src/monaco/editor/standalone/common/monarch/monarchCommon.dart'
    as monarch;
import 'package:semi_design_flutter/src/monaco/editor/standalone/common/monarch/monarchCompile.dart'
    as mc;
import 'package:semi_design_flutter/src/monaco/editor/standalone/common/monarch/monarchTypes.dart'
    as mtypes;

// ---------------------------------------------------------------------------
// gpuDisposable
// ---------------------------------------------------------------------------

class _Buf implements gpu.GPUBuffer {
  final List<Object?> log;
  _Buf(this.log);
  @override
  void destroy() => log.add('destroyBuffer');
}

class _Tex implements gpu.GPUTexture {
  final List<Object?> log;
  _Tex(this.log);
  @override
  void destroy() => log.add('destroyTexture');
}

class _Queue implements gpu.GPUQueue {
  final List<Object?> log;
  _Queue(this.log);
  @override
  void writeBuffer(gpu.GPUBuffer buffer, int off, Object data) =>
      log.add(['writeBuffer', off, data]);
}

class _Device implements gpu.GPUDevice {
  final List<Object?> log;
  _Device(this.log);
  @override
  gpu.GPUBuffer createBuffer(Object descriptor) {
    log.add(['createBuffer', descriptor]);
    return _Buf(log);
  }

  @override
  gpu.GPUTexture createTexture(Object descriptor) {
    log.add(['createTexture', descriptor]);
    return _Tex(log);
  }

  @override
  gpu.GPUQueue get queue => _Queue(log);

  @override
  void destroy() => log.add('destroyDevice');
}

class _Adapter implements gpu.GPUAdapter {
  final gpu.GPUDevice device;
  _Adapter(this.device);
  @override
  Future<gpu.GPUDevice> requestDevice() async => device;
}

class _GPU implements gpu.GPU {
  final gpu.GPUAdapter? adapter;
  _GPU(this.adapter);
  @override
  Future<gpu.GPUAdapter?> requestAdapter() async => adapter;
}

void main() {
  setUp(() => gpu.gpuNavigator = null);

  group('gpuDisposable', () {
    test('createBuffer with initial values writes then wraps destroyable', () {
      final log = <Object?>[];
      final device = _Device(log);
      final values = <double>[1, 2, 3];
      final ref = gpu.GPULifecycle.createBuffer(device, {'size': 12}, values);
      expect(ref.object, isA<_Buf>());
      expect(log[0], equals(['createBuffer', {'size': 12}]));
      expect(log[1], equals(['writeBuffer', 0, values]));
      ref.dispose();
      expect(log.last, 'destroyBuffer');
    });

    test('createBuffer accepts a lazy initial-values function', () {
      final log = <Object?>[];
      final device = _Device(log);
      final values = <double>[9];
      gpu.GPULifecycle.createBuffer(device, {'size': 4}, () => values);
      expect(log[1], equals(['writeBuffer', 0, values]));
    });

    test('createTexture wraps destroyable', () {
      final log = <Object?>[];
      final device = _Device(log);
      final ref = gpu.GPULifecycle.createTexture(device, {'size': [1, 1]});
      expect(ref.object, isA<_Tex>());
      ref.dispose();
      expect(log.last, 'destroyTexture');
    });

    test('requestDevice resolves adapter device and wraps destroy', () async {
      final log = <Object?>[];
      final device = _Device(log);
      gpu.gpuNavigator = _GPU(_Adapter(device));
      final ref = await gpu.GPULifecycle.requestDevice();
      expect(ref.object, same(device));
      ref.dispose();
      expect(log.last, 'destroyDevice');
    });

    test('requestDevice calls fallback and rethrows when no WebGPU', () async {
      String? message;
      await expectLater(
        gpu.GPULifecycle.requestDevice((m) => message = m),
        throwsA(isA<StateError>()),
      );
      expect(message, contains('does not support WebGPU'));
    });
  });

  // -------------------------------------------------------------------------
  // flexBoxLayout
  // -------------------------------------------------------------------------

  group('flexBoxLayout', () {
    test('returns null when minimums exceed total', () {
      expect(
        flex.distributeFlexBoxLayout(5, {
          'a': flex.IFlexBoxPartGrowthRule(min: 3),
          'b': flex.IFlexBoxPartGrowthRule(min: 3),
        }),
        isNull,
      );
    });

    test('single part takes all remaining space up to max', () {
      final r = flex.distributeFlexBoxLayout(100, {
        'a': flex.IFlexBoxPartGrowthRule(
          min: 10,
          max: 50,
          priority: 0,
          share: 1,
        ),
      });
      expect(r!['a'], 50);
    });

    test('two equal-share rules split remaining space evenly', () {
      final r = flex.distributeFlexBoxLayout(100, {
        'a': flex.IFlexBoxPartGrowthRule(priority: 1, share: 1),
        'b': flex.IFlexBoxPartGrowthRule(priority: 1, share: 1),
      });
      expect(r!['a'], 50);
      expect(r['b'], 50);
    });

    test('higher priority consumes space before lower priority', () {
      final r = flex.distributeFlexBoxLayout(100, {
        'a': flex.IFlexBoxPartGrowthRule(max: 30, priority: 2, share: 1),
        'b': flex.IFlexBoxPartGrowthRule(max: 100, priority: 1, share: 1),
      });
      expect(r!['a'], 30);
      expect(r['b'], 70);
    });

    test('share ratio is respected', () {
      final r = flex.distributeFlexBoxLayout(90, {
        'a': flex.IFlexBoxPartGrowthRule(priority: 1, share: 1),
        'b': flex.IFlexBoxPartGrowthRule(priority: 1, share: 2),
      });
      expect(r!['a'], closeTo(30, 0.001));
      expect(r['b'], closeTo(60, 0.001));
    });
  });

  // -------------------------------------------------------------------------
  // cursorUtils
  // -------------------------------------------------------------------------

  group('cursorUtils', () {
    test('gotoNextSibling returns conjunction when both cursors agree', () {
      final a = _Cursor([true]);
      final b = _Cursor([true]);
      expect(cu.gotoNextSibling(a, b), isTrue);
    });

    test('gotoNextSibling throws when trees out of sync', () {
      final a = _Cursor([true]);
      final b = _Cursor([false]);
      expect(
        () => cu.gotoNextSibling(a, b),
        throwsA(isA<StateError>().having(
          (e) => e.toString(),
          'message',
          contains('Trees are out of sync'),
        )),
      );
    });

    test('gotoNthChild advances index siblings', () {
      final a = _Cursor([true, true, true]);
      final b = _Cursor([true, true, true]);
      expect(cu.gotoNthChild(a, b, 2), isTrue);
      expect(a.calls, ['first', 'next', 'next']);
    });

    test('gotoNthChild index 0 only enters first child', () {
      final a = _Cursor([true]);
      final b = _Cursor([true]);
      expect(cu.gotoNthChild(a, b, 0), isTrue);
      expect(a.calls, ['first']);
    });
  });

  // -------------------------------------------------------------------------
  // processor
  // -------------------------------------------------------------------------

  group('processor', () {
    test('untilIdle runs scheduled events in time order', () async {
      addTearDown(() => trace.TraceContext.instance.resetForTesting());
      final clock = vc.VirtualClock();
      final p = proc.VirtualTimeProcessor(
        clock,
        emb.drainMicrotasksEmbedding(api.realTimeApi),
        api.realTimeApi,
        const proc.VirtualTimeProcessorOptions(defaultMaxEvents: 50),
      );
      final log = <String>[];
      clock.schedule(_event(5, 't1', () => log.add('a')));
      clock.schedule(_event(10, 't2', () => log.add('b')));
      await p.run(proc.RunOptions(until: proc.untilIdle));
      expect(log, ['a', 'b']);
      p.dispose();
    });

    test('untilTime resolves even with no events and advances clock', () async {
      addTearDown(() => trace.TraceContext.instance.resetForTesting());
      final clock = vc.VirtualClock();
      final p = proc.VirtualTimeProcessor(
        clock,
        emb.drainMicrotasksEmbedding(api.realTimeApi),
        api.realTimeApi,
      );
      await p.run(proc.RunOptions(until: proc.untilTime(100)));
      expect(clock.now, 100);
      p.dispose();
    });

    test('untilTime does not execute events strictly past deadline', () async {
      addTearDown(() => trace.TraceContext.instance.resetForTesting());
      final clock = vc.VirtualClock();
      final p = proc.VirtualTimeProcessor(
        clock,
        emb.drainMicrotasksEmbedding(api.realTimeApi),
        api.realTimeApi,
      );
      final log = <String>[];
      clock.schedule(_event(50, 'a', () => log.add('a')));
      clock.schedule(_event(100, 'b', () => log.add('b')));
      clock.schedule(_event(101, 'c', () => log.add('c')));
      await p.run(proc.RunOptions(until: proc.untilTime(100)));
      expect(log, ['a', 'b']);
      p.dispose();
    });

    test('maxEvents rejects with overflow error', () async {
      addTearDown(() => trace.TraceContext.instance.resetForTesting());
      final clock = vc.VirtualClock();
      final p = proc.VirtualTimeProcessor(
        clock,
        emb.drainMicrotasksEmbedding(api.realTimeApi),
        api.realTimeApi,
      );
      for (int i = 0; i < 10; i++) {
        clock.schedule(_event(i + 1, 'e$i', () {}));
      }
      await expectLater(
        p.run(proc.RunOptions(until: proc.untilIdle, maxEvents: 3)),
        throwsA(
          isA<StateError>().having(
            (e) => e.toString(),
            'message',
            contains('exceeded maxEvents'),
          ),
        ),
      );
      p.dispose();
    });

    test('dispose rejects active run', () async {
      addTearDown(() => trace.TraceContext.instance.resetForTesting());
      final clock = vc.VirtualClock();
      final p = proc.VirtualTimeProcessor(
        clock,
        emb.drainMicrotasksEmbedding(api.realTimeApi),
        api.realTimeApi,
      );
      final cts = cancel.CancellationTokenSource();
      final future = p.run(proc.RunOptions(until: proc.untilToken(cts.token)));
      p.dispose();
      await expectLater(
        future,
        throwsA(
          isA<StateError>().having(
            (e) => e.toString(),
            'message',
            contains('VirtualTimeProcessor disposed'),
          ),
        ),
      );
    });
  });

  // -------------------------------------------------------------------------
  // monarchCompile
  // -------------------------------------------------------------------------

  group('monarchCompile', () {
    test('compiles a simple language with defaults', () {
      final lang = mtypes.IMonarchLanguage(
        tokenizer: <String, List<mtypes.IMonarchLanguageRule>>{
          'root': <mtypes.IMonarchLanguageRule>[
            mtypes.IExpandedMonarchLanguageRule(
              regex: '[a-z]+',
              action: mtypes.IExpandedMonarchLanguageAction(token: 'word'),
            ),
          ],
        },
      );
      final lexer = mc.compile('test', lang);
      expect(lexer.languageId, 'test');
      expect(lexer.start, 'root');
      expect(lexer.tokenPostfix, '.test');
      expect(lexer.defaultToken, 'source');
      expect(lexer.maxStack, 100);
      expect(lexer.noThrow, isTrue);
      expect(lexer.tokenizer['root']!.length, 1);
      expect(lexer.brackets.length, 4);
      expect(lexer.brackets.first.token, 'delimiter.curly.test');
      expect(lexer.brackets.first.open, '{');
    });

    test('uses configured tokenPostfix/defaultToken/ignoreCase', () {
      final lang = mtypes.IMonarchLanguage(
        ignoreCase: true,
        tokenPostfix: '.custom',
        defaultToken: 'default',
        tokenizer: <String, List<mtypes.IMonarchLanguageRule>>{
          'root': <mtypes.IMonarchLanguageRule>[
            mtypes.IExpandedMonarchLanguageRule(
              regex: 'X',
              action: mtypes.IExpandedMonarchLanguageAction(token: 'x'),
            ),
          ],
        },
      );
      final lexer = mc.compile('t', lang);
      expect(lexer.tokenPostfix, '.custom');
      expect(lexer.defaultToken, 'default');
      expect(lexer.ignoreCase, isTrue);
      expect(lexer.brackets.first.open, '{'); // no case change for '{'
    });

    test('expands @attr references in regex', () {
      final lang = mtypes.IMonarchLanguage(
        tokenizer: <String, List<mtypes.IMonarchLanguageRule>>{
          'root': <mtypes.IMonarchLanguageRule>[
            mtypes.IExpandedMonarchLanguageRule(
              regex: '@foo',
              action: mtypes.IExpandedMonarchLanguageAction(token: 'x'),
            ),
          ],
        },
        extra: <String, Object?>{'foo': 'abc'},
      );
      final lexer = mc.compile('t', lang);
      final rule = lexer.tokenizer['root']!.first;
      final resolved = rule.resolveRegex('root') as RegExp;
      expect(resolved.hasMatch('abc'), isTrue);
      expect(resolved.hasMatch('zzz'), isFalse);
    });

    test('throws when @attr is undefined', () {
      final lang = mtypes.IMonarchLanguage(
        tokenizer: <String, List<mtypes.IMonarchLanguageRule>>{
          'root': <mtypes.IMonarchLanguageRule>[
            mtypes.IExpandedMonarchLanguageRule(
              regex: '@missing',
              action: mtypes.IExpandedMonarchLanguageAction(token: 'x'),
            ),
          ],
        },
      );
      expect(
        () => mc.compile('t', lang),
        throwsA(
          isA<StateError>().having(
            (e) => e.toString(),
            'message',
            contains('does not contain attribute'),
          ),
        ),
      );
    });

    test('expands include rules', () {
      final lang = mtypes.IMonarchLanguage(
        tokenizer: <String, List<mtypes.IMonarchLanguageRule>>{
          'root': <mtypes.IMonarchLanguageRule>[
            mtypes.IExpandedMonarchLanguageRule(include: '@numbers'),
          ],
          'numbers': <mtypes.IMonarchLanguageRule>[
            mtypes.IExpandedMonarchLanguageRule(
              regex: r'\d+',
              action: mtypes.IExpandedMonarchLanguageAction(token: 'number'),
            ),
          ],
        },
      );
      final lexer = mc.compile('t', lang);
      expect(lexer.tokenizer['root']!.length, 1);
      expect(lexer.tokenizer['root']!.first.name, contains('tokenizer.root.numbers'));
    });

    test('compileRegExp handles @@ literal and ignoreCase flag', () {
      final min = _LexerMinFake(ignoreCase: true);
      final re = mc.compileRegExp(min, '@@foo', false) as RegExp;
      expect(re.hasMatch('@foo'), isTrue);
      expect(re.hasMatch('@FOO'), isTrue); // ignoreCase flag applied
    });
  });
}

// ---- Helpers ---------------------------------------------------------------

class _Src implements vc.EventSource {
  final String label;
  _Src(this.label);
  @override
  String toString() => label;
  @override
  String? get stackTrace => null;
}

vc.VirtualEvent _event(vc.VirtualTime time, String label, void Function() run) =>
    _SimpleEvent(time: time, source: _Src(label), runFn: run);

class _SimpleEvent implements vc.VirtualEvent {
  @override
  final vc.VirtualTime time;
  @override
  final vc.EventSource source;
  final void Function() runFn;
  _SimpleEvent({required this.time, required this.source, required this.runFn});

  @override
  Trace? get trace => null;

  @override
  bool get preferRealAnimationFrame => false;

  @override
  void run() => runFn();
}

// Import Trace via the trace.dart prefix for the getter type above.
typedef Trace = trace.Trace;

class _Cursor implements cu.TreeCursor {
  final List<bool> results;
  int _idx = 0;
  final List<String> calls = <String>[];
  _Cursor(this.results);

  bool _next(String label) {
    calls.add(label);
    if (_idx >= results.length) return false;
    return results[_idx++];
  }

  @override
  bool gotoNextSibling() => _next('next');

  @override
  bool gotoParent() => _next('parent');

  @override
  bool gotoFirstChild() => _next('first');

  @override
  bool gotoPreviousSibling() => _next('prev');

  @override
  void resetTo(cu.TreeCursor cursor) {}

  @override
  cu.TreeNode get currentNode => _Node();
}

class _Node implements cu.TreeNode {
  @override
  cu.TreeNode? get nextSibling => null;
  @override
  cu.TreeNode? get previousSibling => null;
  @override
  cu.TreeNode? get parent => null;
  @override
  int get endIndex => 0;
  @override
  int get startIndex => 0;
  @override
  Object? get id => null;
}

class _LexerMinFake implements monarch.ILexerMin {
  @override
  final bool ignoreCase;
  _LexerMinFake({this.ignoreCase = false});

  @override
  String get languageId => 'test';
  @override
  bool get includeLF => false;
  @override
  bool get noThrow => false;
  @override
  bool get unicode => false;
  @override
  bool get usesEmbedded => false;
  @override
  String get defaultToken => 'source';
  @override
  Map<String, Object?> get stateNames => <String, Object?>{};
  @override
  Map<String, Object?> get attrs => <String, Object?>{};
}
