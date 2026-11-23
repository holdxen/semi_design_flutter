// Regression tests for base/common files in the 1:1 Monaco port.
// Assertions mirror the semantics of the TypeScript originals.

import 'dart:math' as math;
import 'dart:convert';
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/nls.dart';
import 'package:semi_design_flutter/src/monaco/base/common/assert.dart';
import 'package:semi_design_flutter/src/monaco/base/common/errors.dart';
import 'package:semi_design_flutter/src/monaco/base/common/collections.dart';
import 'package:semi_design_flutter/src/monaco/base/common/functional.dart';
import 'package:semi_design_flutter/src/monaco/base/common/idGenerator.dart';
import 'package:semi_design_flutter/src/monaco/base/common/hierarchicalKind.dart';
import 'package:semi_design_flutter/src/monaco/base/common/navigator.dart';
import 'package:semi_design_flutter/src/monaco/base/common/diff/diffChange.dart';
import 'package:semi_design_flutter/src/monaco/base/common/range.dart';
import 'package:semi_design_flutter/src/monaco/base/common/uuid.dart';
import 'package:semi_design_flutter/src/monaco/base/common/iterator.dart';
import 'package:semi_design_flutter/src/monaco/base/common/lazy.dart';
import 'package:semi_design_flutter/src/monaco/base/common/linkedList.dart';
import 'package:semi_design_flutter/src/monaco/base/common/map.dart';
import 'package:semi_design_flutter/src/monaco/base/common/marshallingIds.dart';
import 'package:semi_design_flutter/src/monaco/base/common/numbers.dart';
import 'package:semi_design_flutter/src/monaco/base/common/mime.dart';
import 'package:semi_design_flutter/src/monaco/base/common/objects.dart' as objs;
import 'package:semi_design_flutter/src/monaco/base/common/managedSettings.dart' as ms;
import 'package:semi_design_flutter/src/monaco/base/common/layout.dart' as layout;
import 'package:semi_design_flutter/src/monaco/base/common/date.dart' as dt;
import 'package:semi_design_flutter/src/monaco/base/common/comparers.dart' as cmp;
import 'package:semi_design_flutter/src/monaco/base/common/performance.dart' as perf;
import 'package:semi_design_flutter/src/monaco/base/common/normalization.dart' as norm;
import 'package:semi_design_flutter/src/monaco/base/common/jsonSchema.dart' as jsonschema;
import 'package:semi_design_flutter/src/monaco/base/common/keyCodes.dart' as kc;
import 'package:semi_design_flutter/src/monaco/base/common/color.dart' as clr;
import 'package:semi_design_flutter/src/monaco/base/common/json.dart' as js;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart';
import 'package:semi_design_flutter/src/monaco/base/common/path.dart' as path;
import 'package:semi_design_flutter/src/monaco/base/common/platform.dart' as pf;
import 'package:semi_design_flutter/src/monaco/base/common/process.dart' as pr;
import 'package:semi_design_flutter/src/monaco/platform/registry/common/platform.dart' as reg;
import 'package:semi_design_flutter/src/monaco/base/common/jsonFormatter.dart' as fmt;
import 'package:semi_design_flutter/src/monaco/base/common/jsonEdit.dart' as jedit;
import 'package:semi_design_flutter/src/monaco/base/common/keybindings.dart' as kb;
import 'package:semi_design_flutter/src/monaco/base/common/keybindingLabels.dart' as kbl;
import 'package:semi_design_flutter/src/monaco/platform/contextkey/common/scanner.dart' as scan;
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/logging/debugger/rpc.dart' as rpc;
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/debugLocation.dart' as dloc;
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/debugName.dart' as dname;
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/logging/debugger/debuggerApi.d.dart' as dbgapi;
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/logging/debugger/debuggerRpc.dart' as dbgrpc;
import 'package:semi_design_flutter/src/monaco/editor/standalone/common/monarch/monarchTypes.dart' as monarch;
import 'package:semi_design_flutter/src/monaco/platform/environment/common/argv.dart' as argv;
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/graph.dart' as igraph;
import 'package:semi_design_flutter/src/monaco/editor/contrib/inlineCompletions/browser/model/graph.dart' as dgraph;
import 'package:semi_design_flutter/src/monaco/editor/common/model/bracketPairsTextModelPart/bracketPairsTree/smallImmutableSet.dart' as sis;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/list/rangeMap.dart' as rmap;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/bufferDirtyTracker.dart' as bdt;
import 'package:semi_design_flutter/src/monaco/editor/browser/viewParts/minimap/minimapDirtyRows.dart' as mdr;
import 'package:semi_design_flutter/src/monaco/editor/common/viewModel/overviewZoneManager.dart' as ozm;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/scrollbar/scrollbarState.dart' as sb;
import 'package:semi_design_flutter/src/monaco/editor/browser/widget/multiDiffEditor/compressedVirtualizedScrollLayout.dart' as cvsl;
import 'package:semi_design_flutter/src/monaco/base/test/common/executionGraph.dart' as eg;
import 'package:semi_design_flutter/src/monaco/base/common/naturalLanguage/korean.dart' as korean;
import 'package:semi_design_flutter/src/monaco/base/common/stopwatch.dart';
import 'package:semi_design_flutter/src/monaco/base/common/symbols.dart';
import 'package:semi_design_flutter/src/monaco/base/common/types.dart';

/// Test IChannelHandler for debuggerRpc behavior.
class _TestChannelHandler implements rpc.IChannelHandler {
  final List<Object> notifications = <Object>[];
  final List<Object> requests = <Object>[];
  @override
  void handleNotification(Object notificationData) => notifications.add(notificationData);
  @override
  FutureOr<rpc.RpcRequestResult> handleRequest(Object requestData) {
    requests.add(requestData);
    return rpc.RpcResult('ok');
  }
}

/// Minimal API implementation for registerDebugChannel's T extends API bound.
class _TestApi implements rpc.API {
  @override
  rpc.Side get host => _TestApiSide();
  @override
  rpc.Side get client => _TestApiSide();
}

class _TestApiSide implements rpc.Side {
  @override
  Map<String, Function> get notifications => <String, Function>{};
  @override
  Map<String, Function> get requests => <String, Function>{};
}

class _EGHistoryBuilder {
  final List<eg.ExecutionRoot> roots = <eg.ExecutionRoot>[];
  final List<eg.ExecutionEvent> events = <eg.ExecutionEvent>[];

  eg.ExecutionRoot root(String label) {
    final r = eg.ExecutionRoot(label);
    roots.add(r);
    return r;
  }

  eg.ExecutionEvent fire(num time, String label, Object parent) {
    final bool isRoot = parent is eg.ExecutionRoot;
    final eg.ExecutionRoot root = isRoot ? parent : (parent as eg.ExecutionEvent).root;
    final eg.ExecutionEvent? parentEvent = isRoot ? null : parent as eg.ExecutionEvent;
    final e = eg.ExecutionEvent(time: time, label: label, root: root, parent: parentEvent);
    events.add(e);
    return e;
  }

  eg.ExecutionHistory build() => eg.ExecutionHistory(roots: roots, events: events);
}

class _TestSide extends rpc.Side {
  final Map<String, Function> requests = <String, Function>{
    'echo': (String s, int n) => '$s:$n',
  };
  final Map<String, Function> notifications = <String, Function>{
    'note': (String s) {},
  };
}

class _TestChannel implements rpc.IChannel {
  final List<Object> notifications = <Object>[];
  @override
  void sendNotification(Object data) => notifications.add(data);
  @override
  Future<rpc.RpcRequestResult> sendRequest(Object data) async {
    final list = data as List<Object?>;
    final key = list[0] as String;
    final args = list[1] as List<dynamic>;
    final fn = _TestSide().requests[key]!;
    return rpc.RpcResult(Function.apply(fn, args));
  }
}

void main() {
  group('lazy.ts', () {
    test('evaluates once and caches', () {
      int calls = 0;
      final l = Lazy<int>(() {
        calls++;
        return 42;
      });
      expect(l.hasValue, isFalse);
      expect(l.rawValue, isNull);
      expect(l.value, 42);
      expect(l.value, 42);
      expect(calls, 1);
      expect(l.hasValue, isTrue);
    });
  });

  group('functional.ts', () {
    test('single call with callback', () {
      int n = 0, cb = 0;
      final f = createSingleCallFunction<int>(() => ++n, fnDidRunCallback: () => cb++);
      expect(f(), 1);
      expect(f(), 1);
      expect(n, 1);
      expect(cb, 1);
    });
  });

  group('assert.ts', () {
    test('assert conditions', () {
      assertCondition(true);
      expect(() => assertCondition(false, 'x'), throwsA(isA<BugIndicatingError>()));
      expect(checkAdjacentItems([1, 2, 3], (a, b) => a < b), isTrue);
      expect(checkAdjacentItems([1, 3, 2], (a, b) => a < b), isFalse);
    });
  });

  group('types.ts', () {
    test('type guards', () {
      expect(isString('a'), isTrue);
      expect(isString(1), isFalse);
      expect(isNumber(3.5), isTrue);
      expect(isNumber(double.nan), isFalse);
      expect(isBoolean(true), isTrue);
      expect(isDefined(0), isTrue);
      expect(isUndefinedOrNull(null), isTrue);
      expect(isOneOf('a', ['a', 'b']), isTrue);
    });
  });

  group('collections.ts', () {
    test('group/diff/equal/intersection', () {
      final g = groupBy([1, 2, 3, 4], (e) => e % 2);
      expect(g[0]!.length, 2);
      expect(g[1]!.length, 2);
      final d = diffSets({1, 2, 3}.toSet(), {2, 3, 4}.toSet());
      expect(d.removed, [1]);
      expect(d.added, [4]);
      expect(equalSets({1, 2}.toSet(), {2, 1}.toSet()), isTrue);
      expect(intersection({1, 2}.toSet(), [2, 3]), {2});
    });
    test('SetWithKey', () {
      final swk = SetWithKey<String>(['a', 'bb', 'cc'], (s) => s.length);
      expect(swk.length, 2);
      expect(swk.contains('zz'), isTrue);
      expect(swk.contains('xxxx'), isFalse); // key=4 not present
    });
  });

  group('linkedList.ts', () {
    test('push/pop/unshift/shift/remove', () {
      final ll = LinkedList<int>();
      expect(ll.isEmpty(), isTrue);
      final rm = ll.push(1);
      ll.push(2);
      ll.unshift(0);
      expect(ll.size, 3);
      expect(ll.peek(), 2);
      expect(ll.iterable.toList(), [0, 1, 2]);
      rm();
      expect(ll.size, 2);
      expect(ll.iterable.toList(), [0, 2]);
      expect(ll.shift(), 0);
      expect(ll.pop(), 2);
      expect(ll.isEmpty(), isTrue);
    });
  });

  group('iterator.ts', () {
    test('slice/reverse/some/map/consume', () {
      expect(IterableX.length(IterableX.slice([1, 2, 3, 4], 1, 3)), 2);
      expect(IterableX.first(IterableX.reverse([1, 2, 3])), 3);
      expect(IterableX.some([1, 2, 3], (e, i) => e == 2), isTrue);
      expect(IterableX.map([1, 2, 3], (e, i) => e * 2).toList(), [2, 4, 6]);
      final c = IterableX.consume([1, 2, 3, 4], 2);
      expect(c.$1, [1, 2]);
      expect(c.$2.toList(), [3, 4]);
    });
  });

  group('platform/nls/marshallingIds.ts', () {
    test('platform constants and nls formatting', () {
      expect(pf.LANGUAGE_DEFAULT, 'en');
      expect(pf.PlatformToString(pf.Platform_.Mac), 'Mac');
      expect(pf.Language.isDefaultVariant(), isTrue);
      expect(pf.OS, anyOf(pf.OperatingSystem.Linux, pf.OperatingSystem.Macintosh, pf.OperatingSystem.Windows));
      expect(pr.platform, anyOf('win32', 'darwin', 'linux'));
      expect(MarshalledId.Uri, 1);
      expect(MarshalledId.ChatResponsePullRequestPart, 26);
      setNlsLanguage(null);
      expect(localize('key', 'hello {0}', ['world']), 'hello world');
      expect(localize2('key', 'hi {0}', ['x']).original, 'hi x');
    });
  });

  group('path.ts (Node.js path copy)', () {
    test('win32 normalize/join/dirname/basename/extname', () {
      expect(path.win32.normalize('c:\\foo\\bar\\..'), 'c:\\foo');
      expect(path.win32.normalize(''), '.');
      expect(path.win32.isAbsolute(r'C:\foo'), isTrue);
      expect(path.win32.join(['//server', 'share']), '\\\\server\\share\\');
      expect(path.win32.dirname(r'C:\foo\bar'), r'C:\foo');
      expect(path.win32.basename(r'C:\foo\bar.txt', '.txt'), 'bar');
      expect(path.win32.extname('index.html'), '.html');
      expect(path.win32.extname('index'), '');
    });
    test('win32 relative/parse/format', () {
      expect(path.win32.relative(r'C:\orandea\test\aaa', r'C:\orandea\impl\bbb'), r'..\..\impl\bbb');
      final wp = path.win32.parse(r'C:\foo\bar.txt');
      expect(wp.root, r'C:\');
      expect(wp.name, 'bar');
      expect(wp.ext, '.txt');
      expect(path.win32.format(path.ParsedPath(dir: r'C:\foo', base: 'bar.txt')), r'C:\foo\bar.txt');
    });
    test('posix normalize/join/relative/parse', () {
      expect(path.posix.normalize('/foo/bar/..'), '/foo');
      expect(path.posix.normalize('foo//bar'), 'foo/bar');
      expect(path.posix.join(['foo', 'bar']), 'foo/bar');
      expect(path.posix.relative('/foo/bar', '/foo/baz'), '../baz');
      final pp = path.posix.parse('/foo/bar.txt');
      expect(pp.root, '/');
      expect(pp.name, 'bar');
      expect(pp.ext, '.txt');
      expect(path.posix.format(path.ParsedPath(dir: '/foo', base: 'bar.txt')), '/foo/bar.txt');
    });
  });

  group('stopwatch/symbols.ts', () {
    test('stopwatch and sentinel', () {
      final sw = StopWatch.create(false);
      sw.elapsed();
      expect(sw.elapsed() >= 0, isTrue);
      expect(MicrotaskDelay, isNotNull);
      expect(MicrotaskDelay == Object(), isFalse);
    });
  });

  group('uri.ts', () {
    test('file#toString / http#toString', () {
      expect(URI.file('c:/win/path').toString(), 'file:///c%3A/win/path');
      expect(URI.file('C:/win/path').toString(), 'file:///c%3A/win/path');
      expect(URI.file('c:/win/path/').toString(), 'file:///c%3A/win/path/');
      expect(URI.file('/c:/win/path').toString(), 'file:///c%3A/win/path');
      expect(URI.from(UriComponents(scheme: 'http', authority: 'www.EXAMPLE.com', path: '/my/path')).toString(), 'http://www.example.com/my/path');
      expect(URI.from(UriComponents(scheme: 'http', authority: '', path: 'my/path')).toString(), 'http:/my/path');
      expect(URI.from(UriComponents(scheme: 'http', authority: 'example.com', path: '/', query: 'test=true')).toString(), 'http://example.com/?test%3Dtrue');
    });

    test('parse / percent decode / skip encoding', () {
      final value = URI.parse('file://shares/pröjects/c%23/#l12');
      expect(value.authority, 'shares');
      expect(value.path, '/pröjects/c#/');
      expect(value.fragment, 'l12');
      expect(value.toString(), 'file://shares/pr%C3%B6jects/c%23/#l12');
      expect(value.toString(true), 'file://shares/pröjects/c%23/#l12');
      final v = URI.parse('http://api/files/test.me?t=1234');
      expect(v.scheme, 'http');
      expect(v.authority, 'api');
      expect(v.path, '/files/test.me');
      expect(v.query, 't=1234');
      expect(URI.parse('file://%2Fhome%2Fticino%2Ftest.cpp').authority, '/home/ticino/test.cpp');
    });

    test('with identity / changes / validation', () {
      final uri = URI.parse('foo:bar/path');
      expect(identical(uri, uri.withChanges(null)), isTrue);
      expect(identical(uri, uri.withChanges(const UriChange())), isTrue);
      expect(identical(uri, uri.withChanges(UriChange(scheme: 'foo', path: 'bar/path'))), isTrue);
      expect(URI.parse('before:some/file/path').withChanges(UriChange(scheme: 'after')).toString(), 'after:some/file/path');
      expect(URI.parse('scheme://authority/path').withChanges(UriChange(authority: '')).toString(), 'scheme:/path');
      expect(URI.parse('scheme:/path').withChanges(UriChange(authority: 'authority')).withChanges(UriChange(authority: null)).toString(), 'scheme:/path');
      expect(URI.parse('scheme:/path').withChanges(UriChange(authority: 'authority')).withChanges(UriChange(path: null)).toString(), 'scheme://authority');
      expect(() => uri.withChanges(UriChange(scheme: 'fai:l')), throwsStateError);
      expect(() => uri.withChanges(UriChange(scheme: 'fäil')), throwsStateError);
      expect(() => uri.withChanges(UriChange(authority: 'fail')), throwsStateError);
      expect(() => uri.withChanges(UriChange(path: '//fail')), throwsStateError);
    });

    test('fsPath / joinPath / revive / isUri', () {
      expect(URI.file('c:/win/path').fsPath, 'c:/win/path');
      expect(URI.file('C:/win/path').fsPath, 'c:/win/path');
      expect(URI.file('./c/win/path').fsPath, '/./c/win/path');
      expect(URI.joinPath(URI.parse('foo://server/foo'), ['bar', 'baz']).toString(), 'foo://server/foo/bar/baz');
      expect(URI.joinPath(URI.parse('file:///foo'), ['bar']).toString(), 'file:///foo/bar');
      final u = URI.parse('http://a/b?c#d');
      expect(URI.revive(u.toJSON()).toString(), 'http://a/b?c#d');
      expect(URI.isUri(u), isTrue);
      expect(isUriComponents(UriComponents(scheme: 'x')), isTrue);
    });

    test('minimal encoding boundaries', () {
      expect(URI.from(UriComponents(scheme: 'test', path: '?#')).toString(true), 'test:%3F%23');
      expect(URI.from(UriComponents(scheme: 'test', path: '?tail')).toString(true), 'test:%3Ftail');
      expect(URI.from(UriComponents(scheme: 'test', path: 'head#')).toString(true), 'test:head%23');
      expect(URI.from(UriComponents(scheme: 'test', path: 'before?between#after')).toString(true), 'test:before%3Fbetween%23after');
    });
  });

  group('map.ts', () {
    test('LinkedMap basics / touch order', () {
      final map = LinkedMap<String, int>();
      map.set('1', 1);
      expect(map.size, 1);
      expect(map.get('1'), 1);
      expect(map.has('1'), isTrue);
      expect(map.delete('1'), isTrue);
      expect(map.size, 0);
      final touch = LinkedMap<int, int>();
      touch.set(1, 1); touch.set(2, 2); touch.set(3, 3);
      touch.get(1, Touch.AsOld);
      expect(touch.keys().toList(), [1, 2, 3]);
      touch.get(1, Touch.AsNew);
      expect(touch.keys().toList(), [2, 3, 1]);
    });

    test('LinkedMap iterators guard modification', () {
      final map = LinkedMap<int, int>();
      map.set(1, 1); map.set(2, 2); map.set(3, 3);
      expect(map.keys().toList(), [1, 2, 3]);
      expect(map.values().toList(), [1, 2, 3]);
      expect(map.entries().toList().map((e) => e.$1).toList(), [1, 2, 3]);
      final keys = map.keys();
      final values = map.values();
      final entries = map.entries();
      map.get(1, Touch.AsNew);
      int exceptions = 0;
      for (final it in <Iterator>[keys.iterator, values.iterator, entries.iterator]) {
        try { it.moveNext(); } catch (_) { exceptions++; }
      }
      expect(exceptions, 3);
    });

    test('LRU / MRU cache', () {
      final cache = LRUCache<int, int>(5);
      for (final value in [1, 2, 3, 4, 5]) { cache.set(value, value); }
      expect(cache.size, 5);
      cache.set(6, 6);
      expect(cache.size, 5);
      expect(cache.keys().toList(), [2, 3, 4, 5, 6]);
      final mru = MRUCache<int, int>(5);
      for (final value in [1, 2, 3, 4, 5]) { mru.set(value, value); }
      mru.set(6, 6);
      expect(mru.size, 5);
    });

    test('LinkedMap toJSON / fromJSON / delete head-tail', () {
      final map = LinkedMap<int, String>();
      map.set(1, 'a'); map.set(2, 'b');
      final restored = LinkedMap<int, String>();
      restored.fromJSON(map.toJSON());
      expect(restored.keys().toList(), [1, 2]);
      expect(restored.get(2), 'b');
      final dm = LinkedMap<int, int>();
      dm.set(1, 1); dm.set(2, 2); dm.set(3, 3);
      dm.delete(1); dm.delete(3);
      expect(dm.keys().toList(), [2]);
      expect(dm.first, 2);
      expect(dm.last, 2);
    });

    test('ResourceMap basics / clone / strict-equal', () {
      final rm = ResourceMap<int>();
      final u1 = URI.parse('foo://a/1');
      final u2 = URI.parse('foo://a/2');
      rm.set(u1, 1); rm.set(u2, 2);
      expect(rm.size, 2);
      expect(rm.get(u1), 1);
      expect(rm.has(u2), isTrue);
      expect(rm.delete(u1), isTrue);
      expect(rm.size, 1);
      final clone = ResourceMap<int>(rm);
      expect(clone.get(u2), 2);
      expect(mapsStrictEqualIgnoreOrder(<dynamic, dynamic>{1: 'a', 2: 'b'}, <dynamic, dynamic>{2: 'b', 1: 'a'}), isTrue);
      expect(mapsStrictEqualIgnoreOrder(<dynamic, dynamic>{1: 'a'}, <dynamic, dynamic>{1: 'b'}), isFalse);
    });

    test('BidirectionalMap / SetMap / NKeyMap / CounterSet', () {
      final bm = BidirectionalMap<String, int>();
      bm.set('a', 1); bm.set('b', 2);
      expect(bm.get('a'), 1);
      expect(bm.getKey(2), 'b');
      bm.set('a', 3);
      expect(bm.getKey(1), isNull);
      expect(bm.delete('a'), isTrue);
      expect(bm.getKey(3), isNull);

      final sm = SetMap<String, int>();
      sm.add('a', 1); sm.add('a', 2); sm.add('b', 3);
      expect(sm.get('a'), <int>{1, 2});
      sm.delete('a', 1);
      expect(sm.get('a'), <int>{2});

      final nk = NKeyMap<int, List<Object>>();
      nk.set(42, ['a', 'b']);
      expect(nk.get(['a', 'b']), 42);
      expect(nk.getAll(['a']).toList(), [42]);
      expect(nk.delete(['a', 'b']), isTrue);
      expect(nk.get(['a', 'b']), isNull);

      final cs = CounterSet<String>();
      cs.add('x'); cs.add('x');
      expect(cs.has('x'), isTrue);
      expect(cs.delete('x'), isTrue);
      expect(cs.has('x'), isTrue);
      expect(cs.delete('x'), isTrue);
      expect(cs.has('x'), isFalse);

      final m = <String, int>{};
      expect(getOrSet(m, 'k', 5), 5);
      expect(getOrSet(m, 'k', 9), 5);
      expect(mapToString(<String, int>{'a': 1}), 'Map(1) {a => 1}');
      expect(setToString(<String>{'a'}), 'Set(1) {a}');
    });
  });

  group('idGenerator.ts', () {
    test('increments ids with prefix', () {
      final g = IdGenerator('id#');
      expect(g.nextId(), 'id#1');
      expect(g.nextId(), 'id#2');
      expect(defaultGenerator.nextId().startsWith('id#'), isTrue);
    });
  });

  group('hierarchicalKind.ts', () {
    test('equals/contains/intersects/append', () {
      final a = HierarchicalKind('a');
      final ab = HierarchicalKind('a.b');
      final abc = HierarchicalKind('a.b.c');
      expect(HierarchicalKind.sep, '.');
      expect(a.equals(HierarchicalKind('a')), isTrue);
      expect(a.contains(ab), isTrue);
      expect(a.contains(abc), isTrue);
      expect(ab.contains(a), isFalse);
      expect(a.intersects(ab), isTrue);
      expect(ab.intersects(a), isTrue);
      expect(HierarchicalKind.Empty.contains(abc), isTrue);
      expect(HierarchicalKind.None.contains(a), isFalse);
      expect(a.append(['b', 'c']).value, 'a.b.c');
      expect(HierarchicalKind.Empty.append(['a', 'b']).value, 'a.b');
    });
  });

  group('navigator.ts', () {
    test('ArrayNavigator traversal', () {
      final nav = ArrayNavigator<int>([1, 2, 3]);
      expect(nav.current(), isNull);
      expect(nav.next(), 1);
      expect(nav.next(), 2);
      expect(nav.next(), 3);
      expect(nav.next(), isNull);
      expect(nav.first(), 1);
      expect(nav.previous(), isNull);
      expect(nav.last(), 3);
      final sub = ArrayNavigator<int>([1, 2, 3, 4], 1, 3);
      expect(sub.current(), isNull);
      expect(sub.next(), 2);
      expect(sub.next(), 3);
      expect(sub.next(), isNull);
    });
  });

  group('diff/diffChange.ts', () {
    test('end points are exclusive', () {
      final c = DiffChange(2, 3, 5, 1);
      expect(c.getOriginalEnd(), 5);
      expect(c.getModifiedEnd(), 6);
    });
  });

  group('range.ts', () {
    test('intersect/isEmpty/intersects/relativeComplement', () {
      expect(Range.intersect(IRange(0, 5), IRange(3, 8)).start, 3);
      expect(Range.intersect(IRange(0, 5), IRange(3, 8)).end, 5);
      expect(Range.isEmpty(Range.intersect(IRange(0, 2), IRange(5, 8))), isTrue);
      expect(Range.intersects(IRange(0, 5), IRange(5, 8)), isFalse);
      expect(Range.isEmpty(IRange(3, 3)), isTrue);
      final comp = Range.relativeComplement(IRange(0, 10), IRange(3, 6));
      expect(comp.length, 2);
      expect(comp[0].start, 0);
      expect(comp[0].end, 3);
      expect(comp[1].start, 6);
      expect(comp[1].end, 10);
    });
  });

  group('uuid.ts', () {
    test('generation (mirrors uuid.test.ts)', () {
      final asHex = generateUuid();
      expect(asHex.length, 36);
      expect(asHex[14], '4');
      expect(<String>['8', '9', 'a', 'b'], contains(asHex[19]));
    });

    test('self-check', () {
      for (int i = 0; i < 100; i++) {
        expect(isUUID(generateUuid()), isTrue);
      }
      expect(isUUID('not-a-uuid'), isFalse);
    });

    test('prefixedUuid', () {
      const namespace = 'abc';
      final result = prefixedUuid(namespace);
      expect(result.startsWith('$namespace-'), isTrue);
      expect(result.length, namespace.length + 1 + 36);
      expect(isUUID(result.substring(namespace.length + 1)), isTrue);
    });
  });

  group('numbers.ts', () {
    test('isPointWithinTriangle (mirrors numbers.test.ts)', () {
      expect(isPointWithinTriangle(0.25, 0.25, 0, 0, 1, 0, 0, 1), isTrue);
      expect(isPointWithinTriangle(2, 2, 0, 0, 1, 0, 0, 1), isFalse);
      expect(isPointWithinTriangle(0.5, 0, 0, 0, 1, 0, 0, 1), isTrue);
    });

    test('formatTokenCount (mirrors numbers.test.ts)', () {
      expect(formatTokenCount(1000000), '1M');
      expect(formatTokenCount(935997), '1M');
      expect(formatTokenCount(1100000), '1.1M');
      expect(formatTokenCount(1990000), '1.9M');
      expect(formatTokenCount(2500000), '2.5M');
      expect(formatTokenCount(128000), '128K');
      expect(formatTokenCount(900000), '900K');
      expect(formatTokenCount(500), '500');
    });

    test('clamp/rot/Counter/MovingAverage', () {
      expect(clamp(5, 0, 3), 3);
      expect(rot(-1, 3), 2);
      final c = Counter();
      expect(c.getNext(), 0);
      expect(c.getNext(), 1);
      final m = MovingAverage();
      expect(m.update(10), 10);
      expect(m.value, 10);
      final s = SlidingWindowAverage(2);
      expect(s.update(1), 1);
      expect(s.update(3), 2);
    });
  });

  group('mime.ts', () {
    test('normalize (mirrors mime.test.ts)', () {
      expect(normalizeMimeType('invalid'), 'invalid');
      expect(normalizeMimeType('invalid', true), isNull);
      expect(normalizeMimeType('Text/plain'), 'text/plain');
      expect(normalizeMimeType('Text/pläin'), 'text/pläin');
      expect(normalizeMimeType('Text/plain;UPPER'), 'text/plain;UPPER');
      expect(normalizeMimeType('Text/plain;lower'), 'text/plain;lower');
    });

    test('getExtensionForMimeType / getMediaMime / getMediaOrTextMime', () {
      expect(<String>['.jpe', '.jpeg', '.jpg'], contains(getExtensionForMimeType('image/jpg')));
      expect(getExtensionForMimeType('image/avif'), '.avif');
      expect(getExtensionForMimeType('text/plain'), '.txt');
      expect(getExtensionForMimeType('unknown/type'), isNull);
      expect(getMediaMime('profile.avif'), 'image/avif');
      final inputs = ['a.json', 'a.js.map', 'a.pdf', 'a.wasm', 'a.woff2', 'a.ttf', 'a.otf', 'a.PDF', 'a.png', 'a.unknown'];
      final expectMimes = ['application/json', 'application/json', 'application/pdf', 'application/wasm', 'font/woff2', 'font/ttf', 'font/otf', 'application/pdf', 'image/png', null];
      for (int i = 0; i < inputs.length; i++) {
        expect(getMediaOrTextMime(inputs[i]), expectMimes[i]);
      }
      expect(Mimes.text, 'text/plain');
      expect(isTextStreamMime('application/vnd.code.notebook.stdout'), isTrue);
    });
  });

  group('objects.ts', () {
    test('equals (mirrors objects.test.ts)', () {
      expect(objs.equals(null, null), isTrue);
      expect(objs.equals(1234, 1234), isTrue);
      expect(objs.equals('1234', '1234'), isTrue);
      expect(objs.equals(<Object?>[], <Object?>[]), isTrue);
      expect(objs.equals(<Object?>[<Object?>[1, 2, 3]], <Object?>[<Object?>[1, 2, 3]]), isTrue);
      expect(objs.equals(<String, Object?>{'a': 1, 'b': '123'}, <String, Object?>{'b': '123', 'a': 1}), isTrue);
      expect(objs.equals(null, ''), isFalse);
      expect(objs.equals('', <Object?>[]), isFalse);
      expect(objs.equals(<Object?>[], <String, Object?>{}), isFalse);
      expect(objs.equals('1234', 1234), isFalse);
    });

    test('mixin / cloneAndChange / distinct', () {
      final foo = <String, Object?>{};
      objs.mixin(foo, <String, Object?>{'bar': <Object?>[1, 2, 3]});
      expect((foo['bar'] as List).length, 3);
      final foo2 = <String, Object?>{'bar': '123'};
      objs.mixin(foo2, <String, Object?>{'bar': '456'}, false);
      expect(foo2['bar'], '123');
      final o1 = <String, Object?>{'something': 'hello'};
      final o = <String, Object?>{'o1': o1, 'o2': o1};
      expect(objs.equals(objs.cloneAndChange(o, (x) => null), o), isTrue);
      final base = <String, Object?>{'one': 'one', 'two': 2, 'four': false};
      final obj = <String, Object?>{'one': 'two', 'two': 2, 'four': true};
      final diff = objs.distinct(base, obj);
      expect(diff.length, 2);
      expect(diff['one'], 'two');
      expect(diff['four'], true);
      expect(objs.getCaseInsensitive(<String, Object?>{'mIxEdCaSe': 456}, 'MIXEDCASE'), 456);
      expect(objs.mapValues<String, String>(<String, String>{'a': '1'}, (v, k) => '$k:$v')['a'], 'a:1');
    });

    test('safeStringify circular / shared (mirrors objects.test.ts)', () {
      final obj1 = <String, Object?>{'friend': null};
      final obj2 = <String, Object?>{'friend': null};
      obj1['friend'] = obj2;
      obj2['friend'] = obj1;
      final arr = <Object?>[1];
      arr.add(arr);
      final circular = <String, Object?>{'a': 42, 'b': null, 'c': <Object?>[obj1, obj2], 'd': null, 'e': BigInt.from(42)};
      arr.add(circular);
      circular['b'] = circular;
      circular['d'] = arr;
      final parsed = jsonDecode(objs.safeStringify(circular)) as Map<String, dynamic>;
      expect(parsed['a'], 42);
      expect(parsed['b'], '[Circular]');
      expect((parsed['c'] as List)[0]['friend']['friend'], '[Circular]');
      expect(parsed['d'][0], 1);
      expect(parsed['d'][1], '[Circular]');
      expect(parsed['e'], '[BigInt 42]');
      final shared = <String, Object?>{'a': 1};
      expect(objs.safeStringify(<Object?>[shared, <String, Object?>{'x': shared, 'y': <Object?>[shared]}]), '[{"a":1},{"x":{"a":1},"y":[{"a":1}]}]');
    });

    test('stableStringify (mirrors objects.test.ts)', () {
      final a = <String, Object?>{'b': 1, 'a': 2, 'c': <String, Object?>{'y': 1, 'x': 2}};
      final b = <String, Object?>{'c': <String, Object?>{'x': 2, 'y': 1}, 'a': 2, 'b': 1};
      expect(objs.stableStringify(a), objs.stableStringify(b));
      expect(objs.stableStringify(a), '{"a":2,"b":1,"c":{"x":2,"y":1}}');
      expect(objs.stableStringify(<Object?>[<String, Object?>{'b': 1, 'a': 2}, 'x', null, 3]), '[{"a":2,"b":1},"x",null,3]');
      expect(objs.stableStringify(null), 'undefined');
      expect(objs.stableStringify(0), '0');
      expect(objs.stableStringify(''), '""');
      final circ = <String, Object?>{'a': 1};
      circ['self'] = circ;
      expect(objs.stableStringify(circ), '{"a":1,"self":"[Circular]"}');
      final shared = <String, Object?>{'a': 1};
      expect(objs.stableStringify(<String, Object?>{'x': shared, 'y': shared}), '{"x":{"a":1},"y":{"a":1}}');
    });
  });

  group('managedSettings.ts', () {
    test('extraKnownMarketplacesToConfigDict', () {
      expect(ms.extraKnownMarketplacesToConfigDict(null), isNull);
      expect(ms.extraKnownMarketplacesToConfigDict(<Object?>[]), isNull);
      final dict = ms.extraKnownMarketplacesToConfigDict(<Object?>[
        'plain-source',
        '__proto__', // unsafe key, skipped
        ms.GithubMarketplaceEntry('github-entry', ms.GithubMarketplaceSource('org/repo')),
        ms.GitMarketplaceEntry('git-entry', ms.GitMarketplaceSource('https://example.com/repo', 'main')),
        ms.GithubMarketplaceEntry('auto-entry', ms.GithubMarketplaceSource('org/repo2'), true),
      ]);
      expect(dict, isNotNull);
      expect(dict!['plain-source'], 'plain-source');
      expect(dict.containsKey('__proto__'), isFalse);
      expect(dict['github-entry'], 'org/repo');
      expect(dict['git-entry'], 'https://example.com/repo#main');
      expect(dict['auto-entry'], '{"source":"org/repo2","autoUpdate":true}');
      expect(ms.isUnsafeMarketplaceKey('constructor'), isTrue);
      expect(ms.isUnsafeMarketplaceKey('prototype'), isTrue);
      expect(ms.isUnsafeMarketplaceKey('safe'), isFalse);
    });
  });

  group('layout.ts', () {
    test('layout 1d', () {
      final a = layout.ILayoutAnchor(30, 20, layout.LayoutAnchorPosition.Before);
      final r = layout.layout(100, 30, a);
      expect(r.position, 50);
      expect(r.result, 'ok');
      final aligned = layout.ILayoutAnchor(30, 20, layout.LayoutAnchorPosition.Before, layout.LayoutAnchorMode.ALIGN);
      expect(layout.layout(100, 30, aligned).position, 30);
      expect(layout.layout(100, 80, a).result, 'overlap');
      // flipped reachable when before boundary > viewport - after boundary:
      final late = layout.ILayoutAnchor(60, 10, layout.LayoutAnchorPosition.Before);
      expect(layout.layout(100, 40, late).result, 'flipped');
    });

    test('layout2d', () {
      final viewport = layout.IRect(0, 0, 100, 100);
      final view = layout.ISize(20, 10);
      final anchor = layout.IRect(30, 30, 10, 10);
      final result = layout.layout2d(viewport, view, anchor);
      expect(result.top >= 0, isTrue);
      expect(result.left >= 0, isTrue);
      expect(result.anchorAlignment, layout.AnchorAlignment.LEFT);
      expect(result.anchorPosition, layout.AnchorPosition.BELOW);
    });
  });

  group('date.ts', () {
    test('expiration helpers (mirrors date.test.ts)', () {
      expect(dt.getRemainingTimeInSeconds(null, 1000), isNull);
      expect(dt.getRemainingTimeInSeconds(1000, 1000), isNull);
      expect(dt.getRemainingTimeInSeconds(1001, 1000), 1);
      expect(dt.getRemainingTimeInSeconds(2001, 1000), 2);
      expect(dt.getExpirationTime(null, 1000), isNull);
      expect(dt.getExpirationTime(0, 1000), 1000);
      expect(dt.getExpirationTime(2, 1000), 3000);
      expect(dt.isExpired(null, 1000), isFalse);
      expect(dt.isExpired(1000, 1000), isTrue);
      expect(dt.isExpired(1001, 1000), isFalse);
    });

    test('fromNow / fromNowByDay (mirrors date.test.ts)', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      expect(dt.fromNow(now - 35000), '35 secs');
      expect(dt.fromNow(now - 35000, true), '35 secs ago');
      expect(dt.fromNow(now - 35000, null, true), '35 seconds');
      expect(dt.fromNow(now + 4 * 60 * 60 * 1000, false, true), 'in 4 hours');
      expect(dt.fromNow(now - 5000), 'now');
      expect(dt.fromNow(now - 5000, null, null, true), '5 secs');
      expect(dt.fromNowByDay(DateTime.now()), 'Today');
      expect(dt.fromNowByDay(DateTime.now().subtract(const Duration(days: 1))), 'Yesterday');
      expect(dt.fromNowByDay(DateTime.now().subtract(const Duration(days: 5, hours: 2)), true), '5 days ago');
    });

    test('getDurationString / safeIntl (mirrors date.test.ts)', () {
      expect(dt.getDurationString(1), '1ms');
      expect(dt.getDurationString(1000), '1s');
      expect(dt.getDurationString(1000 * 60 - 1), '59.999s');
      expect(dt.getDurationString(1000 * 60), '1 mins');
      expect(dt.getDurationString(1000 * 60 * 60), '1 hrs');
      expect(dt.getDurationString(1000 * 60 * 60 * 24), '1 days');
      expect(dt.getDurationString(1, true), '1 milliseconds');
      expect(dt.getDurationString(1000, true), '1 seconds');
      expect(dt.safeIntl.Collator('en_IT').value.compare('a', 'b'), -1);
      expect(dt.safeIntl.Locale('en_IT').value.baseName, pf.LANGUAGE_DEFAULT);
    });
  });

  group('comparers.ts', () {
    // Note: JS Intl.Collator full ICU locale collation has no Dart-stdlib
    // equivalent. Assertions here mirror the source's numeric/disambiguation,
    // unicode, path and prefix logic; pure ICU-locale-order cases are omitted.
    test('compareFileNames numeric / null / dotfiles', () {
      expect(cmp.compareFileNames(null, null), 0);
      expect(cmp.compareFileNames(null, 'abc') < 0, isTrue);
      expect(cmp.compareFileNames('', ''), 0);
      expect(cmp.compareFileNames('abc', 'abc'), 0);
      expect(cmp.compareFileNames('1', '1'), 0);
      expect(cmp.compareFileNames('abc1.txt', 'abc2.txt') < 0, isTrue);
      expect(cmp.compareFileNames('abc2.txt', 'abc10.txt') < 0, isTrue);
      expect(cmp.compareFileNames('abc02.txt', 'abc010.txt') < 0, isTrue);
      expect(cmp.compareFileNames('.abc', '.abc'), 0);
      expect(cmp.compareFileNames(null, '.abc') < 0, isTrue);
      final arr = <String>['abc2.txt', 'abc10.txt', 'abc1.txt']..sort(cmp.compareFileNames);
      expect(arr, <String>['abc1.txt', 'abc2.txt', 'abc10.txt']);
    });

    test('compareFileNamesUnicode / compareByPrefix / comparePaths', () {
      expect(cmp.compareFileNamesUnicode('a', 'a'), 0);
      expect(cmp.compareFileNamesUnicode('b', 'a') > 0, isTrue);
      expect(cmp.compareByPrefix('apple', 'application', 'app'), -1);
      expect(cmp.compareByPrefix('apple', 'banana', 'app') < 0, isTrue);
      expect(cmp.compareByPrefix('app', 'apple', 'app') < 0, isTrue);
      expect(cmp.comparePaths('a/b/c', 'a/b/c'), 0);
      expect(cmp.comparePaths('a/b', 'a/b/c') < 0, isTrue);
      expect(cmp.compareFileExtensionsUnicode('a.png', 'a.txt') < 0, isTrue);
    });
  });

  group('performance.ts', () {
    test('polyfill mark / getMarks / clearMarks', () {
      perf.clearMarks();
      perf.mark('code/test', <String, Object>{'startTime': 100});
      perf.mark('code/other');
      final marks = perf.getMarks();
      expect(marks.length, 2);
      expect(marks[0].name, 'code/test');
      expect(marks[0].startTime, 100);
      perf.clearMarks('code/test');
      expect(perf.getMarks().length, 1);
      expect(perf.getMarks()[0].name, 'code/other');
      perf.clearMarks();
      expect(perf.getMarks(), isEmpty);
    });
  });

  group('normalization.ts', () {
    test('tryNormalizeToBase — precomposed accents fold to base', () {
      for (final s in ['joào', 'joáo', 'joâo', 'joäo', 'joão', 'joåo', 'joāo']) {
        expect(norm.tryNormalizeToBase(s), 'joao');
      }
      for (final s in ['fôo', 'föo', 'fòo', 'fóo', 'fōo', 'fõo']) {
        expect(norm.tryNormalizeToBase(s), 'foo');
      }
      for (final s in ['andrè', 'andré', 'andrê', 'andrë', 'andrē', 'andrė', 'andrę']) {
        expect(norm.tryNormalizeToBase(s), 'andre');
      }
      for (final s in ['hvîc', 'hvïc', 'hvíc', 'hvīc', 'hvįc', 'hvìc']) {
        expect(norm.tryNormalizeToBase(s), 'hvic');
      }
      for (final s in ['ûdo', 'üdo', 'ùdo', 'údo', 'ūdo']) {
        expect(norm.tryNormalizeToBase(s), 'udo');
      }
      expect(norm.tryNormalizeToBase('heÿ'), 'hey');
      expect(norm.tryNormalizeToBase('gruś'), 'grus');
      expect(norm.tryNormalizeToBase('gruš'), 'grus');
      expect(norm.tryNormalizeToBase('çool'), 'cool');
      expect(norm.tryNormalizeToBase('ćool'), 'cool');
      expect(norm.tryNormalizeToBase('čool'), 'cool');
      expect(norm.tryNormalizeToBase('ñice'), 'nice');
      expect(norm.tryNormalizeToBase('ńice'), 'nice');
    });
    test('tryNormalizeToBase — cases, precomposed and combining marks', () {
      for (final s in ['CAFÉ', 'Café', 'café', 'CaFé']) {
        expect(norm.tryNormalizeToBase(s), 'cafe');
      }
      for (final s in ['JOÃO', 'João', 'JoÃo']) {
        expect(norm.tryNormalizeToBase(s), 'joao');
      }
      expect(norm.tryNormalizeToBase('AnDrÉ'), 'andre');
      expect(norm.tryNormalizeToBase('\u00E9'), 'e');
      expect(norm.tryNormalizeToBase('\u00E0'), 'a');
      expect(norm.tryNormalizeToBase('caf\u00E9'), 'cafe');
      // base + combining accent: NFD keeps them, length unchanged after strip => lower only
      expect(norm.tryNormalizeToBase('\u0065\u0301'), '\u0065\u0301');
      expect(norm.tryNormalizeToBase('Ã\u0061\u0300'), 'ã\u0061\u0300');
      expect(norm.tryNormalizeToBase('CaF\u0065\u0301'), 'caf\u0065\u0301');
    });
    test('normalizeNFC / normalizeNFD', () {
      expect(norm.normalizeNFD('\u00E9'), 'e\u0301');
      expect(norm.normalizeNFC('e\u0301'), '\u00E9');
      expect(norm.normalizeNFD('abc'), 'abc');
      expect(norm.normalizeNFC(''), '');
    });
  });

  group('jsonSchema.ts', () {
    test('getCompressedContent — shared subtree extracted to \$defs', () {
      jsonschema.IJSONSchema js(String src) => jsonDecode(src) as Map<String, Object?>;
      const s1 = '{"type":"object","properties":{"a":{"type":"object","description":"a","properties":{"b":{"type":"object","properties":{"c":{"type":"object","properties":{"d":{"type":"string"}}}}}}},"e":{"type":"object","description":"e","properties":{"b":{"type":"object","properties":{"c":{"type":"object","properties":{"d":{"type":"string"}}}}}}}}}';
      const x1 = '{"type":"object","properties":{"a":{"type":"object","description":"a","properties":{"b":{"\$ref":"#/\$defs/_0"}}},"e":{"type":"object","description":"e","properties":{"b":{"\$ref":"#/\$defs/_0"}}}},"\$defs":{"_0":{"type":"object","properties":{"c":{"type":"object","properties":{"d":{"type":"string"}}}}}}}';
      expect(jsonschema.getCompressedContent(js(s1)), jsonEncode(jsonDecode(x1)));
    });
    test('getCompressedContent — identical nodes replaced by \$ref', () {
      jsonschema.IJSONSchema js(String src) => jsonDecode(src) as Map<String, Object?>;
      const s2 = '{"type":"object","properties":{"a":{"type":"object","properties":{"b":{"type":"object","properties":{"c":{"type":"object","properties":{"d":{"type":"string"}}}}}}},"e":{"type":"object","properties":{"b":{"type":"object","properties":{"c":{"type":"object","properties":{"d":{"type":"string"}}}}}}}}}';
      const x2 = '{"type":"object","properties":{"a":{"\$ref":"#/\$defs/_0"},"e":{"\$ref":"#/\$defs/_0"}},"\$defs":{"_0":{"type":"object","properties":{"b":{"type":"object","properties":{"c":{"type":"object","properties":{"d":{"type":"string"}}}}}}}}}';
      expect(jsonschema.getCompressedContent(js(s2)), jsonEncode(jsonDecode(x2)));
    });
  });

  group('keyCodes.ts', () {
    test('mapping for Minus (mirrors keyCodes.test.ts)', () {
      expect(kc.EVENT_KEY_CODE_MAP[189], kc.KeyCode.Minus);
      expect(kc.NATIVE_WINDOWS_KEY_CODE_TO_KEY_CODE['VK_OEM_MINUS'], kc.KeyCode.Minus);
      expect(kc.ScanCodeUtils.lowerCaseToEnum('minus'), kc.ScanCode.Minus);
      expect(kc.ScanCodeUtils.toEnum('Minus'), kc.ScanCode.Minus);
      expect(kc.ScanCodeUtils.toStringValue(kc.ScanCode.Minus), 'Minus');
      expect(kc.IMMUTABLE_CODE_TO_KEY_CODE[kc.ScanCode.Minus], kc.KeyCode.DependsOnKbLayout);
      expect(kc.IMMUTABLE_KEY_CODE_TO_CODE[kc.KeyCode.Minus], kc.KeyCode.DependsOnKbLayout);
      expect(kc.KeyCodeUtils.toStringValue(kc.KeyCode.Minus), '-');
      expect(kc.KeyCodeUtils.fromString('-'), kc.KeyCode.Minus);
      expect(kc.KeyCodeUtils.toUserSettingsUS(kc.KeyCode.Minus), '-');
      expect(kc.KeyCodeUtils.toUserSettingsGeneral(kc.KeyCode.Minus), 'OEM_MINUS');
      expect(kc.KeyCodeUtils.fromUserSettings('-'), kc.KeyCode.Minus);
      expect(kc.KeyCodeUtils.fromUserSettings('OEM_MINUS'), kc.KeyCode.Minus);
      expect(kc.KeyCodeUtils.fromUserSettings('oem_minus'), kc.KeyCode.Minus);
    });
    test('mapping for Space (mirrors keyCodes.test.ts)', () {
      expect(kc.EVENT_KEY_CODE_MAP[32], kc.KeyCode.Space);
      expect(kc.NATIVE_WINDOWS_KEY_CODE_TO_KEY_CODE['VK_SPACE'], kc.KeyCode.Space);
      expect(kc.ScanCodeUtils.lowerCaseToEnum('space'), kc.ScanCode.Space);
      expect(kc.ScanCodeUtils.toEnum('Space'), kc.ScanCode.Space);
      expect(kc.ScanCodeUtils.toStringValue(kc.ScanCode.Space), 'Space');
      expect(kc.IMMUTABLE_CODE_TO_KEY_CODE[kc.ScanCode.Space], kc.KeyCode.Space);
      expect(kc.IMMUTABLE_KEY_CODE_TO_CODE[kc.KeyCode.Space], kc.ScanCode.Space);
      expect(kc.KeyCodeUtils.toStringValue(kc.KeyCode.Space), 'Space');
      expect(kc.KeyCodeUtils.fromString('Space'), kc.KeyCode.Space);
      expect(kc.KeyCodeUtils.toUserSettingsUS(kc.KeyCode.Space), 'Space');
      expect(kc.KeyCodeUtils.toUserSettingsGeneral(kc.KeyCode.Space), 'Space');
      expect(kc.KeyCodeUtils.fromUserSettings('Space'), kc.KeyCode.Space);
      expect(kc.KeyCodeUtils.fromUserSettings('space'), kc.KeyCode.Space);
    });
    test('enum values, modifiers, chord and accelerator', () {
      expect(kc.KeyCode.Unknown, 0);
      expect(kc.KeyCode.Digit0, 21);
      expect(kc.KeyCode.KeyA, 31);
      expect(kc.KeyCode.MAX_VALUE, 132);
      expect(kc.ScanCode.KeyA, 10);
      expect(kc.ScanCode.MAX_VALUE, 193);
      expect(kc.isModifierKey(kc.KeyCode.Ctrl), isTrue);
      expect(kc.isModifierKey(kc.KeyCode.KeyA), isFalse);
      expect(kc.KeyMod.CtrlCmd, 2048);
      expect(kc.KeyMod.Shift, 1024);
      final chord = kc.KeyChord(kc.KeyCode.Enter, kc.KeyMod.Alt);
      expect(chord & 0xFFFF, kc.KeyCode.Enter);
      expect((chord >> 16) & 0xFFFF, kc.KeyMod.Alt);
      expect(kc.KeyCodeUtils.toElectronAccelerator(kc.KeyCode.UpArrow), 'Up');
      expect(kc.KeyCodeUtils.toElectronAccelerator(kc.KeyCode.Numpad0), isNull);
    });
  });
  group('color.ts', () {
    test('getRelativeLuminance / blend / contrast (mirrors color.test.ts)', () {
      expect(clr.Color(clr.RGBA(0, 0, 0)).getRelativeLuminance(), 0);
      expect(clr.Color(clr.RGBA(255, 255, 255)).getRelativeLuminance(), 1);
      expect(clr.Color(clr.RGBA(255, 0, 0)).getRelativeLuminance(), 0.2126);
      expect(clr.Color(clr.RGBA(0, 255, 0)).getRelativeLuminance(), 0.7152);
      expect(clr.Color(clr.RGBA(0, 0, 255)).getRelativeLuminance(), 0.0722);
      expect(clr.Color(clr.RGBA(255, 255, 0)).getRelativeLuminance(), 0.9278);
      expect(clr.Color(clr.RGBA(128, 128, 128)).getRelativeLuminance(), 0.2159);
      void expectRgba(Object c, int r, int g, int b, [double a = 1.0]) {
        final v = c is clr.Color ? c.rgba : c as clr.RGBA;
        expect(v.r, r); expect(v.g, g); expect(v.b, b); expect(v.a, a);
      }
      expectRgba(clr.Color(clr.RGBA(0, 0, 0, 0)).blend(clr.Color(clr.RGBA(243, 34, 43))), 243, 34, 43);
      expectRgba(clr.Color(clr.RGBA(255, 255, 255)).blend(clr.Color(clr.RGBA(243, 34, 43))), 255, 255, 255);
      expectRgba(clr.Color(clr.RGBA(122, 122, 122, 0.7)).blend(clr.Color(clr.RGBA(243, 34, 43))), 158, 95, 98);
      expectRgba(clr.Color(clr.RGBA(0, 0, 0, 0.58)).blend(clr.Color(clr.RGBA(255, 255, 255, 0.33))), 49, 49, 49, 0.719);
      expect(clr.Color(clr.RGBA(0, 0, 0)).getContrastRatio(clr.Color(clr.RGBA(255, 255, 255))) > 20, isTrue);
    });
    test('lighter / darker colors (mirrors color.test.ts)', () {
      final c1 = clr.Color(clr.HSLA(60, 1, 0.5, 1)), c2 = clr.Color(clr.HSLA(0, 0, 0.753, 1));
      expect(c1.isLighterThan(c2), isTrue);
      void expectHsla(clr.Color c, int h, double s, double l, double a) {
        final x = c.hsla;
        expect(x.h, h); expect(x.s, s); expect(x.l, l); expect(x.a, a);
      }
      expectHsla(clr.Color.getLighterColor(c2, c1), 0, 0, 0.916, 1);
      expectHsla(clr.Color.getLighterColor(c2, c1, 0.3), 0, 0, 0.851, 1);
      expectHsla(clr.Color.getLighterColor(c2, c1, 1), 0, 0, 1, 1);
      expectHsla(clr.Color.getDarkerColor(c1, c2), 60, 1, 0.392, 1);
      expectHsla(clr.Color.getDarkerColor(c1, c2, 0.7), 60, 1, 0.349, 1);
      expectHsla(clr.Color.getDarkerColor(clr.Color.fromHex('#770811'), clr.Color.fromHex('#000c18'), 0.4), 355, 0.874, 0.157, 1);
    });
    test('HSLA / HSVA conversions (mirrors color.test.ts)', () {
      void expectRgba(Object c, int r, int g, int b) {
        final v = c is clr.Color ? c.rgba : c as clr.RGBA;
        expect(v.r, r); expect(v.g, g); expect(v.b, b);
      }
      expectRgba(clr.HSLA.toRGBA(clr.HSLA(0, 1, 0.5, 1)), 255, 0, 0);
      expectRgba(clr.HSLA.toRGBA(clr.HSLA(120, 1, 0.5, 1)), 0, 255, 0);
      expectRgba(clr.HSLA.toRGBA(clr.HSLA(240, 1, 0.5, 1)), 0, 0, 255);
      expect(clr.Color(clr.HSLA.fromRGBA(clr.RGBA(255, 0, 0))).hsla.h, 0);
      expect(clr.Color(clr.HSLA.fromRGBA(clr.RGBA(0, 255, 0))).hsla.h, 120);
      expectRgba(clr.HSVA.toRGBA(clr.HSVA(0, 1, 1, 1)), 255, 0, 0);
      expectRgba(clr.HSVA.toRGBA(clr.HSVA(120, 1, 1, 1)), 0, 255, 0);
      expectRgba(clr.HSVA.toRGBA(clr.HSVA(240, 1, 1, 1)), 0, 0, 255);
      expect(clr.HSVA.fromRGBA(clr.HSLA.toRGBA(clr.HSLA(120, 0, 0.5, 1))).h, 0);
    });
    test('parseHex / parse / format / toNumber32Bit (mirrors color.test.ts)', () {
      void expectRgba(clr.Color c, int r, int g, int b, [double a = 1.0]) {
        expect(c.rgba.r, r); expect(c.rgba.g, g); expect(c.rgba.b, b); expect(c.rgba.a, a);
      }
      expectRgba(clr.ColorFormatCSS.parseHex('#abc')!, 170, 187, 204);
      expectRgba(clr.ColorFormatCSS.parseHex('#abcd')!, 170, 187, 204, 0.867);
      expectRgba(clr.ColorFormatCSS.parseHex('#aabbcc')!, 170, 187, 204);
      expectRgba(clr.ColorFormatCSS.parseHex('#aabbccdd')!, 170, 187, 204, 0.867);
      expect(clr.ColorFormatCSS.parseHex(''), isNull);
      expect(clr.ColorFormatCSS.parseHex('abc'), isNull);
      expect(clr.ColorFormatCSS.parse('transparent'), clr.Color.transparentColor);
      expectRgba(clr.ColorFormatCSS.parse('red')!, 255, 0, 0);
      expectRgba(clr.ColorFormatCSS.parse('#f00')!, 255, 0, 0);
      expectRgba(clr.ColorFormatCSS.parse('rgb(1, 2, 3)')!, 1, 2, 3);
      expectRgba(clr.ColorFormatCSS.parse('rgba(1, 2, 3, 0.5)')!, 1, 2, 3, 0.5);
      expect(clr.ColorFormatCSS.parse('bogus'), isNull);
      expect(clr.Color.fromHex('#00000000').toString(), 'rgba(0, 0, 0, 0)');
      expect(clr.Color.fromHex('#00000080').toString(), 'rgba(0, 0, 0, 0.5)');
      expect(clr.Color.fromHex('#000000FF').toString(), '#000000');
      expect(clr.ColorFormatCSS.formatRGB(clr.Color(clr.RGBA(1, 2, 3))), 'rgb(1, 2, 3)');
      expect(clr.ColorFormatCSS.formatHSL(clr.Color(clr.HSLA(120, 1, 0.5, 1))), 'hsl(120, 100%, 50%)');
      expect(clr.ColorFormatCSS.formatHexA(clr.Color(clr.RGBA(0, 0, 0, 0.5))), '#00000080');
      expect(clr.Color.fromHex('#00000000').toNumber32Bit(), 0);
      expect(clr.Color.fromHex('#000000FF').toNumber32Bit(), 255);
      expect(clr.Color.fromHex('#01020300').toNumber32Bit(), 0x01020300);
    });
  });

  group('json.ts', () {
    void expectKinds(String text, List<int> expected) {
      final scanner = js.createScanner(text);
      final got = <int>[];
      int k;
      while ((k = scanner.scan()) != js.SyntaxKind.eof) got.add(k);
      expect(got, expected);
    }
    test('scanner tokens / comments / strings / numbers (mirrors json.test.ts)', () {
      expectKinds('{', [js.SyntaxKind.openBraceToken]);
      expectKinds('}', [js.SyntaxKind.closeBraceToken]);
      expectKinds('[', [js.SyntaxKind.openBracketToken]);
      expectKinds(',', [js.SyntaxKind.commaToken]);
      expectKinds('// comment', [js.SyntaxKind.lineCommentTrivia]);
      expectKinds('// comment\n', [js.SyntaxKind.lineCommentTrivia, js.SyntaxKind.lineBreakTrivia]);
      expectKinds('/* comment */', [js.SyntaxKind.blockCommentTrivia]);
      expectKinds('/ ttt', [js.SyntaxKind.unknown, js.SyntaxKind.trivia, js.SyntaxKind.unknown]);
      expectKinds('"test"', [js.SyntaxKind.stringLiteral]);
      expectKinds('"\\n"', [js.SyntaxKind.stringLiteral]);
      expectKinds('"test', [js.SyntaxKind.stringLiteral]);
      expectKinds('"test\n"', [js.SyntaxKind.stringLiteral, js.SyntaxKind.lineBreakTrivia, js.SyntaxKind.stringLiteral]);
      expectKinds('0', [js.SyntaxKind.numericLiteral]);
      expectKinds('0.1', [js.SyntaxKind.numericLiteral]);
      expectKinds('-0.1', [js.SyntaxKind.numericLiteral]);
      expectKinds('123456789', [js.SyntaxKind.numericLiteral]);
      expectKinds('true', [js.SyntaxKind.trueKeyword]);
      expectKinds('false', [js.SyntaxKind.falseKeyword]);
      expectKinds('null', [js.SyntaxKind.nullKeyword]);
      expectKinds(' { ', [js.SyntaxKind.trivia, js.SyntaxKind.openBraceToken, js.SyntaxKind.trivia]);
      final s2 = js.createScanner(' { ', true);
      expect(s2.scan(), js.SyntaxKind.openBraceToken);
    });
    test('parse literals / objects / arrays / errors (mirrors json.test.ts)', () {
      void valid(String input, Object? expected) {
        final errors = <js.ParseError>[];
        final actual = js.parse(input, errors);
        expect(errors, isEmpty);
        expect(actual.toString(), expected.toString());
      }
      valid('true', true);
      valid('false', false);
      valid('null', null);
      valid('123', 123);
      valid('"hello"', 'hello');
      valid('[]', <Object?>[]);
      valid('[1,2,3]', <Object?>[1, 2, 3]);
      valid('{}', <String, Object?>{});
      valid('{"a":1}', <String, Object?>{'a': 1});
      valid('{"a":1,"b":[2,3]}', <String, Object?>{'a': 1, 'b': <Object?>[2, 3]});
      valid('{"a":1,}', <String, Object?>{'a': 1});
      final e1 = <js.ParseError>[];
      js.parse('{', e1);
      expect(e1, isNotEmpty);
      final e2 = <js.ParseError>[];
      js.parse('[1,', e2);
      expect(e2, isNotEmpty);
      final e3 = <js.ParseError>[];
      js.parse('{"a":1 /* c */}', e3, js.ParseOptions(disallowComments: true));
      expect(e3, isNotEmpty);
      // __proto__ own property preserved
      final e4 = <js.ParseError>[];
      final obj = js.parse('{"__proto__": 5}', e4) as Map<String, Object?>;
      expect(e4, isEmpty);
      expect(obj['__proto__'], 5);
    });
    test('parseTree / getLocation / findNode / getNodeValue (mirrors json.test.ts)', () {
      for (final input in ['[]', '{}', '{"a":1}', '[1,2,3]', '{"a":[1,{"b":2}]}']) {
        final errors = <js.ParseError>[];
        final root = js.parseTree(input, errors);
        expect(errors, isEmpty);
        expect(root!.type, input.startsWith('[') ? js.NodeType.array : js.NodeType.object);
      }
      final root = js.parseTree('{"a":[1,2],"b":3}')!;
      final n1 = js.findNodeAtLocation(root, <Object>['a', 1]);
      expect(n1, isNotNull);
      expect(n1!.value, 2);
      final path = js.getNodePath(n1);
      expect(path, ['a', 1]);
      final val = js.getNodeValue(root) as Map<String, Object?>;
      expect(val['a'].toString(), '[1, 2]');
      expect(val['b'], 3);
      final loc = js.getLocation('{"a":1,"b":2}', 4);
      expect(loc.path, ['a']);
      expect(js.getLocation('{"a":1,"b":2}', 3).isAtPropertyKey, isTrue);
      expect(js.contains(js.Node(js.NodeType.string, 2, 3), 3), isTrue);
      expect(js.getNodeType(true), js.NodeType.boolean);
      expect(js.getNodeType(1), js.NodeType.number);
      expect(js.getNodeType(null), js.NodeType.nullValue);
      expect(js.getNodeType(<Object?>[]), js.NodeType.array);
      expect(js.getNodeType(<String, Object?>{}), js.NodeType.object);
    });
  });

  group('jsonFormatter.ts', () {
    // Mirrors the `format` helper from jsonFormatter.test.ts: `|` markers
    // delimit the range, edits are applied from last to first.
    String runFormat(String content, {bool insertSpaces = true}) {
      fmt.FormatRange? range;
      final int rangeStart = content.indexOf('|');
      final int rangeEnd = content.lastIndexOf('|');
      if (rangeStart != -1 && rangeEnd != -1) {
        content = content.substring(0, rangeStart) +
            content.substring(rangeStart + 1, rangeEnd) +
            content.substring(rangeEnd + 1);
        range = fmt.FormatRange(rangeStart, rangeEnd - rangeStart);
      }
      final List<fmt.Edit> edits = fmt.format(
          content,
          range,
          fmt.FormattingOptions(tabSize: 2, insertSpaces: insertSpaces, eol: '\n'));
      int lastEditOffset = content.length;
      for (int i = edits.length - 1; i >= 0; i--) {
        final edit = edits[i];
        expect(edit.offset >= 0 && edit.length >= 0 && edit.offset + edit.length <= content.length,
            isTrue);
        expect(lastEditOffset >= edit.offset + edit.length, isTrue);
        lastEditOffset = edit.offset;
        content = content.substring(0, edit.offset) +
            edit.content +
            content.substring(edit.offset + edit.length);
      }
      return content;
    }

    test('object + array formatting (mirrors jsonFormatter.test.ts)', () {
      expect(runFormat('{"x" : 1}'), ['{', '  "x": 1', '}'].join('\n'));
      expect(runFormat('{"x" : 1,  "y" : "foo", "z"  : true}'),
          ['{', '  "x": 1,', '  "y": "foo",', '  "z": true', '}'].join('\n'));
      expect(runFormat('{"x" : {    },  "y" : {}}'),
          ['{', '  "x": {},', '  "y": {}', '}'].join('\n'));
      expect(runFormat('{"x" : {  "y" : { "z"  : { }}, "a": true}}'),
          ['{', '  "x": {', '    "y": {', '      "z": {}', '    },', '    "a": true', '  }', '}']
              .join('\n'));
      expect(runFormat('["[]"]'), ['[', '  "[]"', ']'].join('\n'));
      expect(runFormat('[true,null,1.2]'), ['[', '  true,', '  null,', '  1.2', ']'].join('\n'));
      expect(runFormat('[      ]'), ['[]'].join('\n'));
      expect(runFormat('[ [], [ [ {} ], "a" ]  ]'),
          ['[', '  [],', '  [', '    [', '      {}', '    ],', '    "a"', '  ]', ']'].join('\n'));
      expect(runFormat('[ null 1.2 ]'), ['[', '  null 1.2', ']'].join('\n'));
    });

    test('comments (mirrors jsonFormatter.test.ts)', () {
      expect(runFormat(['{', '"a": true,', '', '"b": true', '}'].join('\n'), insertSpaces: false),
          ['{', '\t"a": true,', '\t"b": true', '}'].join('\n'));
      expect(runFormat(['[ ', '//comment', '"foo", "bar"', '] '].join('\n')),
          ['[', '  //comment', '  "foo",', '  "bar"', ']'].join('\n'));
      expect(runFormat(['[{', '        /*comment*/     ', '"foo" : true', '}] '].join('\n')),
          ['[', '  {', '    /*comment*/', '    "foo": true', '  }', ']'].join('\n'));
      expect(runFormat([' {  ', '        "a": {}// comment    ', ' } '].join('\n')),
          ['{', '  "a": {} // comment    ', '}'].join('\n'));
      expect(runFormat(['{ //comment', '}'].join('\n')),
          ['{ //comment', '}'].join('\n'));
      expect(runFormat(['{      "a": {}, /*comment*/    ', '        /*comment*/ "b": {},    ',
              '        "c": {/*comment*/}    } '].join('\n')),
          ['{', '  "a": {}, /*comment*/', '  /*comment*/ "b": {},', '  "c": { /*comment*/}', '}']
              .join('\n'));
      expect(runFormat([' {       "d": [', '             null', '        ] /*comment*/',
              '        ,"e": /*comment*/ [null] }'].join('\n')),
          ['{', '  "d": [', '    null', '  ] /*comment*/,', '  "e": /*comment*/ [', '    null',
                  '  ]', '}']
              .join('\n'));
      expect(runFormat(['{      "a": {} /*comment*/, /*comment*/   ',
              '        /*comment*/ "b": {}  /*comment*/  } '].join('\n')),
          ['{', '  "a": {} /*comment*/, /*comment*/', '  /*comment*/ "b": {} /*comment*/', '}']
              .join('\n'));
      expect(runFormat(['[ /*comment*/  /*comment*/   // comment ', ']'].join('\n')),
          ['[ /*comment*/ /*comment*/ // comment ', ']'].join('\n'));
      expect(runFormat(['{ "a": [ 1', '/* comment */', ', 2', '/* comment */', ']',
              '/* comment */', ',', ' "b": true', '/* comment */', '}'].join('\n')),
          ['{', '  "a": [', '    1', '    /* comment */', '    ,', '    2',
                  '    /* comment */', '  ]', '  /* comment */', '  ,', '  "b": true',
                  '  /* comment */', '}']
              .join('\n'));
      expect(runFormat(['{ "a":', '// comment', 'null,', ' "b"', '// comment', ': null',
              '// comment', '}'].join('\n')),
          ['{', '  "a":', '  // comment', '  null,', '  "b"', '  // comment', '  : null',
                  '  // comment', '}']
              .join('\n'));
    });

    test('range formatting (mirrors jsonFormatter.test.ts)', () {
      expect(runFormat(['{ "a": {},', '|"b": [null, null]|', '} '].join('\n')),
          ['{ "a": {},', '"b": [', '  null,', '  null', ']', '} '].join('\n'));
      expect(runFormat(['{ "a": {},', '   |"b": [null],', '"c": {}', '}|'].join('\n')),
          ['{ "a": {},', '   "b": [', '    null', '  ],', '  "c": {}', '}'].join('\n'));
      expect(
          runFormat(['{ "a": {},', '|  "b": [null],   ', '"c": {}', '} |    '].join('\n'),
              insertSpaces: false),
          ['{ "a": {},', '\t"b": [', '\t\tnull', '\t],', '\t"c": {}', '}'].join('\n'));
    });

    test('toFormattedString (mirrors jsonFormatter.test.ts)', () {
      final Object obj = <String, Object?>{
        'a': <String, Object?>{'b': 1, 'd': <Object?>['hello']}
      };
      String getExpected(String tab, String eol) => [
            '{',
            '${tab}"a": {',
            '${tab}${tab}"b": 1,',
            '${tab}${tab}"d": [',
            '${tab}${tab}${tab}"hello"',
            '${tab}${tab}]',
            '${tab}}',
            '}'
          ].join(eol);
      expect(fmt.toFormattedString(obj, fmt.FormattingOptions(insertSpaces: true, tabSize: 2, eol: '\n')),
          getExpected('  ', '\n'));
      expect(fmt.toFormattedString(obj, fmt.FormattingOptions(insertSpaces: true, tabSize: 2, eol: '\r\n')),
          getExpected('  ', '\r\n'));
      expect(fmt.toFormattedString(obj, fmt.FormattingOptions(insertSpaces: false, eol: '\r\n')),
          getExpected('\t', '\r\n'));
    });
  });

  group('keybindings.ts', () {
    test('issue #173325: KeyCodeChord hash != ScanCodeChord hash', () {
      final a = kb.KeyCodeChord(true, false, false, false, kc.KeyCode.KeyV);
      final b = kb.ScanCodeChord(true, false, false, false, kc.ScanCode.Equal);
      expect(a.getHashCode() == b.getHashCode(), isFalse);
    });
    test('decodeKeybinding / createSimpleKeybinding / equals', () {
      // KeyV with ctrlCmd bit set; on non-Mac this is ctrlKey
      final simple = kb.createSimpleKeybinding(
          (1 << 11) | kc.KeyCode.KeyV, pf.OperatingSystem.Windows);
      expect(simple.ctrlKey, isTrue);
      expect(simple.keyCode, kc.KeyCode.KeyV);
      expect(simple.isModifierKey(), isFalse);
      expect(kb.decodeKeybinding(0, pf.OperatingSystem.Windows), isNull);
      final single = kb.decodeKeybinding(
          (1 << 11) | kc.KeyCode.KeyV, pf.OperatingSystem.Windows)!;
      expect(single.chords.length, 1);
      expect(single.equals(kb.Keybinding([kb.KeyCodeChord(true, false, false, false, kc.KeyCode.KeyV)])),
          isTrue);
      // two-chord (chord) encoding
      final int chord = ((1 << 11) | kc.KeyCode.KeyK) | (((1 << 10) | kc.KeyCode.KeyS) << 16);
      final decoded = kb.decodeKeybinding(chord, pf.OperatingSystem.Windows)!;
      expect(decoded.chords.length, 2);
      expect(decoded.getHashCode(), isNotEmpty);
      // array form
      final arr = kb.decodeKeybinding(<int>[kc.KeyCode.KeyA, kc.KeyCode.KeyB], pf.OperatingSystem.Windows)!;
      expect(arr.chords.length, 2);
      // modifier duplicate cases
      expect(kb.KeyCodeChord(true, false, false, false, kc.KeyCode.Ctrl).isDuplicateModifierCase(), isTrue);
      expect(kb.ScanCodeChord(false, true, false, false, kc.ScanCode.ShiftLeft).isDuplicateModifierCase(), isTrue);
    });
  });

  group('korean.ts', () {
    String altForString(String text) {
      final result = StringBuffer();
      for (int i = 0; i < text.length; i++) {
        final chars = korean.getKoreanAltChars(text.codeUnitAt(i));
        if (chars != null) {
          for (final c in chars) { result.writeCharCode(c); }
        } else {
          result.writeCharCode(text.codeUnitAt(i));
        }
      }
      return result.toString();
    }
    test("Modern initial consonants", () {
      final cases = <String, String>{
        "ᄀ": "r",
        "ᄁ": "R",
        "ᄂ": "s",
        "ᄃ": "e",
        "ᄄ": "E",
        "ᄅ": "f",
        "ᄆ": "a",
        "ᄇ": "q",
        "ᄈ": "Q",
        "ᄉ": "t",
        "ᄊ": "T",
        "ᄋ": "d",
        "ᄌ": "w",
        "ᄍ": "W",
        "ᄎ": "c",
        "ᄏ": "z",
        "ᄐ": "x",
        "ᄑ": "v",
        "ᄒ": "g",
      };
      for (final entry in cases.entries) {
        expect(altForString(entry.key), entry.value,
            reason: '"${entry.key}" should result in "${entry.value}"');
      }
    });
    test("Modern latter consonants", () {
      final cases = <String, String>{
        "ᆨ": "r",
        "ᆩ": "R",
        "ᆪ": "rt",
        "ᆫ": "s",
        "ᆬ": "sw",
        "ᆭ": "sg",
        "ᆮ": "e",
        "ᆯ": "f",
        "ᆰ": "fr",
        "ᆱ": "fa",
        "ᆲ": "fq",
        "ᆳ": "ft",
        "ᆴ": "fx",
        "ᆵ": "fv",
        "ᆶ": "fg",
        "ᆷ": "a",
        "ᆸ": "q",
        "ᆹ": "qt",
        "ᆺ": "t",
        "ᆻ": "T",
        "ᆼ": "d",
        "ᆽ": "w",
        "ᆾ": "c",
        "ᆿ": "z",
        "ᇀ": "x",
        "ᇁ": "v",
        "ᇂ": "g",
      };
      for (final entry in cases.entries) {
        expect(altForString(entry.key), entry.value,
            reason: '"${entry.key}" should result in "${entry.value}"');
      }
    });
    test("Modern vowels", () {
      final cases = <String, String>{
        "ᅡ": "k",
        "ᅢ": "o",
        "ᅣ": "i",
        "ᅤ": "O",
        "ᅥ": "j",
        "ᅦ": "p",
        "ᅧ": "u",
        "ᅨ": "P",
        "ᅩ": "h",
        "ᅪ": "hk",
        "ᅫ": "ho",
        "ᅬ": "hl",
        "ᅭ": "y",
        "ᅮ": "n",
        "ᅯ": "nj",
        "ᅰ": "np",
        "ᅱ": "nl",
        "ᅲ": "b",
        "ᅳ": "m",
        "ᅴ": "ml",
        "ᅵ": "l",
      };
      for (final entry in cases.entries) {
        expect(altForString(entry.key), entry.value,
            reason: '"${entry.key}" should result in "${entry.value}"');
      }
    });
    test("Compatibility Jamo", () {
      final cases = <String, String>{
        "ㄱ": "r",
        "ㄲ": "R",
        "ㄳ": "rt",
        "ㄴ": "s",
        "ㄵ": "sw",
        "ㄶ": "sg",
        "ㄷ": "e",
        "ㄸ": "E",
        "ㄹ": "f",
        "ㄺ": "fr",
        "ㄻ": "fa",
        "ㄼ": "fq",
        "ㄽ": "ft",
        "ㄾ": "fx",
        "ㄿ": "fv",
        "ㅀ": "fg",
        "ㅁ": "a",
        "ㅂ": "q",
        "ㅃ": "Q",
        "ㅄ": "qt",
        "ㅅ": "t",
        "ㅆ": "T",
        "ㅇ": "d",
        "ㅈ": "w",
        "ㅉ": "W",
        "ㅊ": "c",
        "ㅋ": "z",
        "ㅌ": "x",
        "ㅍ": "v",
        "ㅎ": "g",
        "ㅏ": "k",
        "ㅐ": "o",
        "ㅑ": "i",
        "ㅒ": "O",
        "ㅓ": "j",
        "ㅔ": "p",
        "ㅕ": "u",
        "ㅖ": "P",
        "ㅗ": "h",
        "ㅘ": "hk",
        "ㅙ": "ho",
        "ㅚ": "hl",
        "ㅛ": "y",
        "ㅜ": "n",
        "ㅝ": "nj",
        "ㅞ": "np",
        "ㅟ": "nl",
        "ㅠ": "b",
        "ㅡ": "m",
        "ㅢ": "ml",
        "ㅣ": "l",
      };
      for (final entry in cases.entries) {
        expect(altForString(entry.key), entry.value,
            reason: '"${entry.key}" should result in "${entry.value}"');
      }
    });
    test("Composed samples", () {
      final cases = <String, String>{
        "ㅁㅊㅊㄷㄴ냐ㅠㅑㅣㅑ쇼": "accessibility",
        "ㅁㅊ채ㅕㅜㅅ뚜샤시드둣ㄴ": "accountEntitlements",
        "며야ㅐ쳗ㄴ": "audioCues",
        "ㅠㄱㅁ찯셰먁채ㅣㅐ걐ㄷㄱ2ㅆ디듣ㅅ교": "bracketPairColorizer2Telemetry",
        "ㅠㅕㅣㅏㄸ얏": "bulkEdit",
        "ㅊ미ㅣㅗㅑㄷㄱㅁㄱ초ㅛ": "callHierarchy",
        "촘ㅅ": "chat",
        "챙ㄷㅁㅊ샤ㅐㅜㄴ": "codeActions",
        "챙ㄷㄸ야색": "codeEditor",
        "채ㅡㅡ뭉ㄴ": "commands",
        "채ㅡㅡ둣ㄴ": "comments",
        "채ㅜ럏ㄸ테ㅐㄳㄷㄱ": "configExporter",
        "채ㅜㅅㄷㅌ스두ㅕ": "contextmenu",
        "쳔새ㅡㄸ야색": "customEditor",
        "ㅇ듀ㅕㅎ": "debug",
        "ㅇ덱ㄷㅊㅁㅅㄷㅇㄸㅌㅅ두냐ㅐㅜㅡㅑㅎㄱㅁ색": "deprecatedExtensionMigrator",
        "ㄷ얏ㄴㄷㄴ냐ㅐㅜㄴ": "editSessions",
        "드ㅡㄷㅅ": "emmet",
        "ㄷㅌㅅ두냐ㅐㅜㄴ": "extensions",
        "ㄷㅌㅅㄷ구밌ㄷ그ㅑㅜ미": "externalTerminal",
        "ㄷㅌㅅㄷ구미ㅕ갸ㅒㅔ둗ㄱ": "externalUriOpener",
        "랴ㅣㄷㄴ": "files",
        "래ㅣ야ㅜㅎ": "folding",
        "래금ㅅ": "format",
        "ㅑㅟ묘ㅗㅑㅜㅅㄴ": "inlayHints",
        "ㅑㅟㅑㅜㄷ촘ㅅ": "inlineChat",
        "ㅑㅜㅅㄷㄱㅁㅊ샾ㄷ": "interactive",
        "ㅑㄴ녇": "issue",
        "ㅏ됴ㅠㅑㅜ야ㅜㅎㄴ": "keybindings",
        "ㅣ무혐ㅎㄷㅇㄷㅅㄷㅊ샤ㅐㅜ": "languageDetection",
        "ㅣ무혐ㅎㄷㄴㅅㅁ션": "languageStatus",
        "ㅣㅑㅡㅑ샤ㅜ얓ㅁ색": "limitIndicator",
        "ㅣㅑㄴㅅ": "list",
        "ㅣㅐㅊ미ㅗㅑㄴ새교": "localHistory",
        "ㅣㅐㅊ미ㅑㅋㅁ샤ㅐㅜ": "localization",
        "ㅣㅐㅎㄴ": "logs",
        "ㅡ메ㅔㄷㅇㄸ얏ㄴ": "mappedEdits",
        "ㅡㅁ가애주": "markdown",
        "ㅡㅁ갇ㄱㄴ": "markers",
        "ㅡㄷㄱㅎㄷㄸ야색": "mergeEditor",
        "ㅡㅕㅣ샤얄ㄹㄸ야색": "multiDiffEditor",
        "ㅜㅐㅅ듀ㅐㅐㅏ": "notebook",
        "ㅐㅕ시ㅑㅜㄷ": "outline",
        "ㅐㅕ세ㅕㅅ": "output",
        "ㅔㄷㄱ래그뭋ㄷ": "performance",
        "ㅔㄱㄷㄹㄷㄱ둧ㄷㄴ": "preferences",
        "벼ㅑ참ㅊㅊㄷㄴㄴ": "quickaccess",
        "ㄱ디며ㅜ촏ㄱ": "relauncher",
        "ㄱ드ㅐㅅㄷ": "remote",
        "ㄱ드ㅐㅅㄷ쎠ㅜㅜ디": "remoteTunnel",
        "ㄴㅁ노": "sash",
        "ㄴ츠": "scm",
        "ㄴㄷㅁㄱ초": "search",
        "ㄴㄷㅁㄱ초ㄸ야색": "searchEditor",
        "놈ㄱㄷ": "share",
        "누ㅑㅔㅔㄷㅅㄴ": "snippets",
        "넫ㄷ초": "speech",
        "네ㅣㅁ노": "splash",
        "녁ㅍ됸": "surveys",
        "ㅅㅁㅎㄴ": "tags",
        "ㅅㅁ난": "tasks",
        "ㅅ디듣ㅅ교": "telemetry",
        "ㅅㄷ그ㅑㅜ미": "terminal",
        "ㅅㄷ그ㅑㅜ미채ㅜㅅ갸ㅠ": "terminalContrib",
        "ㅅㄷㄴ샤ㅜㅎ": "testing",
        "소듣ㄴ": "themes",
        "샤ㅡ디ㅑㅜㄷ": "timeline",
        "쇼ㅔ도ㅑㄷㄱㅁㄱ초ㅛ": "typeHierarchy",
        "ㅕㅔㅇㅁㅅㄷ": "update",
        "ㅕ기": "url",
        "ㅕㄴㄷㄱㅇㅁㅅ몌개랴ㅣㄷ": "userDataProfile",
        "ㅕㄴㄷㄱㅇㅁㅅㅁ뇨ㅜㅊ": "userDataSync",
        "ㅈ듀퍋ㅈ": "webview",
        "ㅈ듀퍋졔무디": "webviewPanel",
        "ㅈ듀퍋ㅈ퍋ㅈ": "webviewView",
        "ㅈ디채ㅡ듀무ㅜㄷㄱ": "welcomeBanner",
        "ㅈ디채ㅡㄷ야미ㅐㅎ": "welcomeDialog",
        "ㅈ디채ㅡㄷㅎㄷㅅ샤ㅜㅎㄴㅅㅁㄳㄷㅇ": "welcomeGettingStarted",
        "ㅈ디채ㅡㄷ퍋ㅈㄴ": "welcomeViews",
        "ㅈ디채ㅡㄷㅉ미ㅏ소개ㅕ호": "welcomeWalkthrough",
        "재가넴ㅊㄷ": "workspace",
        "재가넴ㅊㄷㄴ": "workspaces",
      };
      for (final entry in cases.entries) {
        expect(altForString(entry.key).toLowerCase(), entry.value.toLowerCase(),
            reason: '"${entry.key}" should result in "${entry.value}"');
      }
    });
  });
  group('jsonEdit.ts', () {
    // Mirrors assertEdit from jsonEdit.test.ts
    void assertEdit(String content, List<fmt.Edit> edits, String expected) {
      for (int i = edits.length - 1; i >= 0; i--) {
        final e = edits[i];
        expect(e.offset >= 0 && e.length >= 0 && e.offset + e.length <= content.length, isTrue);
        content = content.substring(0, e.offset) + e.content + content.substring(e.offset + e.length);
      }
      expect(content, expected);
    }
    final opts = fmt.FormattingOptions(insertSpaces: true, tabSize: 2, eol: '\n');

    test('set / insert / remove property (mirrors jsonEdit.test.ts)', () {
      assertEdit('{\n  "x": "y"\n}', jedit.setProperty('{\n  "x": "y"\n}', ['x'], 'bar', opts),
          '{\n  "x": "bar"\n}');
      assertEdit('true', jedit.setProperty('true', [], 'bar', opts), '"bar"');
      assertEdit('{\n  "x": "y"\n}',
          jedit.setProperty('{\n  "x": "y"\n}', ['x'], {'key': true}, opts),
          '{\n  "x": {\n    "key": true\n  }\n}');
      assertEdit('{}', jedit.setProperty('{}', ['foo'], 'bar', opts),
          '{\n  "foo": "bar"\n}');
      assertEdit('{}', jedit.setProperty('{}', ['foo', 'foo2'], 'bar', opts),
          '{\n  "foo": {\n    "foo2": "bar"\n  }\n}');
      assertEdit('{\n  "x": "y"\n}', jedit.setProperty('{\n  "x": "y"\n}', ['foo'], 'bar', opts),
          '{\n  "x": "y",\n  "foo": "bar"\n}');
      // insertion index callback
      const content = '{\n  "x": {\n    "a": 1,\n    "b": true\n  }\n}\n';
      assertEdit(content,
          jedit.setProperty(content, ['x', 'c'], 'bar', opts, (_) => 0),
          '{\n  "x": {\n    "c": "bar",\n    "a": 1,\n    "b": true\n  }\n}\n');
      assertEdit(content,
          jedit.setProperty(content, ['x', 'c'], 'bar', opts, (_) => 1),
          '{\n  "x": {\n    "a": 1,\n    "c": "bar",\n    "b": true\n  }\n}\n');
      assertEdit(content,
          jedit.setProperty(content, ['x', 'c'], 'bar', opts, (_) => 2),
          '{\n  "x": {\n    "a": 1,\n    "b": true,\n    "c": "bar"\n  }\n}\n');
      // empty document → nested array
      assertEdit('', jedit.setProperty('', ['foo', 0], 'bar', opts),
          '{\n  "foo": [\n    "bar"\n  ]\n}');
      assertEdit('//comment', jedit.setProperty('//comment', ['foo', 0], 'bar', opts),
          '{\n  "foo": [\n    "bar"\n  ]\n} //comment');
    });

    test('removeProperty (mirrors jsonEdit.test.ts)', () {
      assertEdit('{\n  "x": "y"\n}', jedit.removeProperty('{\n  "x": "y"\n}', ['x'], opts),
          '{\n}');
      assertEdit('{\n  "x": "y", "a": []\n}',
          jedit.removeProperty('{\n  "x": "y", "a": []\n}', ['x'], opts),
          '{\n  "a": []\n}');
      // trailing comma / comment
      assertEdit('{\n  "x": "y",\n}', jedit.removeProperty('{\n  "x": "y",\n}', ['x'], opts),
          '{\n}');
      assertEdit('{\n  "x": "y" /* x */, // trailing\n}',
          jedit.removeProperty('{\n  "x": "y" /* x */, // trailing\n}', ['x'], opts),
          '{ // trailing\n}');
    });

    test('array insert / remove (mirrors jsonEdit.test.ts)', () {
      assertEdit('[\n  2,\n  3\n]', jedit.setProperty('[\n  2,\n  3\n]', [0], 1, opts),
          '[\n  1,\n  2,\n  3\n]');
      assertEdit('[\n]', jedit.setProperty('[\n]', [0], 1, opts), '[\n  1\n]');
      assertEdit('[\n  1,\n  3\n]', jedit.setProperty('[\n  1,\n  3\n]', [1], 2, opts),
          '[\n  1,\n  2,\n  3\n]');
      assertEdit('[\n  1,\n  2\n]', jedit.setProperty('[\n  1,\n  2\n]', [-1], 'bar', opts),
          '[\n  1,\n  2,\n  "bar"\n]');
      assertEdit('[\n  1\n]', jedit.setProperty('[\n  1\n]', [0], null, opts), '[]');
      assertEdit('[\n  1,\n  2,\n  3\n]',
          jedit.setProperty('[\n  1,\n  2,\n  3\n]', [1], null, opts),
          '[\n  1,\n  3\n]');
      assertEdit('[\n  1,\n  2,\n  "bar"\n]',
          jedit.setProperty('[\n  1,\n  2,\n  "bar"\n]', [2], null, opts),
          '[\n  1,\n  2\n]');
      assertEdit('[1,2]', jedit.setProperty('[1,2]', [1], null, opts), '[\n  1\n]');
    });

    test('applyEdit / applyEdits', () {
      expect(jedit.applyEdit('hello', fmt.Edit(1, 3, 'XYZ')), 'hXYZo');
      expect(jedit.applyEdits('hello', <fmt.Edit>[
        fmt.Edit(0, 1, 'H'),
        fmt.Edit(4, 1, 'O'),
      ]), 'HellO');
      expect(() => jedit.applyEdits('abc', <fmt.Edit>[
        fmt.Edit(0, 2, 'X'),
        fmt.Edit(1, 1, 'Y'),
      ]), throwsA(isA<StateError>()));
    });
  });

  group('keybindingLabels.ts', () {
    String? ui(int OS, kb.KeyCodeChord m, String key) =>
        kbl.UILabelProvider.toLabel(OS, <kb.KeyCodeChord>[m], (_) => key);
    String? us(int OS, kb.KeyCodeChord m, String key) =>
        kbl.UserSettingsLabelProvider.toLabel(OS, <kb.KeyCodeChord>[m], (_) => key);

    test('UILabelProvider modifiers (mirrors keybindingLabels.test.ts semantics)', () {
      expect(ui(pf.OperatingSystem.Windows, kb.KeyCodeChord(false, false, false, false, 0), 'A'), 'A');
      expect(ui(pf.OperatingSystem.Windows, kb.KeyCodeChord(true, false, false, false, 0), 'A'), 'Ctrl+A');
      expect(ui(pf.OperatingSystem.Windows, kb.KeyCodeChord(false, true, false, false, 0), 'A'), 'Shift+A');
      expect(ui(pf.OperatingSystem.Windows, kb.KeyCodeChord(false, false, true, false, 0), 'A'), 'Alt+A');
      expect(ui(pf.OperatingSystem.Windows, kb.KeyCodeChord(false, false, false, true, 0), 'A'), 'Windows+A');
      expect(ui(pf.OperatingSystem.Windows, kb.KeyCodeChord(true, true, true, true, 0), 'A'),
          'Ctrl+Shift+Alt+Windows+A');
      expect(ui(pf.OperatingSystem.Linux, kb.KeyCodeChord(false, false, false, true, 0), 'A'), 'Super+A');
      expect(ui(pf.OperatingSystem.Macintosh, kb.KeyCodeChord(true, false, false, false, 0), 'A'), '⌃A');
      expect(ui(pf.OperatingSystem.Macintosh, kb.KeyCodeChord(false, false, false, true, 0), 'A'), '⌘A');
      // null provider result cannot be expressed
      expect(kbl.UILabelProvider.toLabel<kb.KeyCodeChord>(pf.OperatingSystem.Windows, <kb.KeyCodeChord>[kb.KeyCodeChord(true, false, false, false, 0)], (_) => null),
          isNull);
      // multiple chords joined with space
      expect(kbl.UILabelProvider.toLabel(pf.OperatingSystem.Windows,
          <kb.KeyCodeChord>[kb.KeyCodeChord(true, false, false, false, 0), kb.KeyCodeChord(true, false, false, false, 0)], (m) => 'A'),
          'Ctrl+A Ctrl+A');
    });

    test('UserSettings / Electron / Aria label providers', () {
      expect(us(pf.OperatingSystem.Windows, kb.KeyCodeChord(true, false, false, true, 0), 'A'), 'ctrl+win+A');
      expect(us(pf.OperatingSystem.Macintosh, kb.KeyCodeChord(true, false, false, true, 0), 'A'), 'ctrl+cmd+A');
      expect(kbl.UserSettingsLabelProvider.toLabel(pf.OperatingSystem.Linux, <kb.KeyCodeChord>[kb.KeyCodeChord(false, false, false, true, 0)], (_) => 'A'),
          'meta+A');
      expect(kbl.ElectronAcceleratorLabelProvider.toLabel(pf.OperatingSystem.Windows, <kb.KeyCodeChord>[kb.KeyCodeChord(true, false, false, true, 0)], (_) => 'A'),
          'Ctrl+Super+A');
      expect(kbl.AriaLabelProvider.toLabel(pf.OperatingSystem.Windows, <kb.KeyCodeChord>[kb.KeyCodeChord(true, false, false, false, 0)], (_) => 'A'),
          'Control+A');
      // empty chords → null
      expect(kbl.UILabelProvider.toLabel<kb.KeyCodeChord>(pf.OperatingSystem.Windows, <kb.KeyCodeChord>[], (_) => 'A'), isNull);
    });
  });

  group('platform/registry/common/platform.ts', () {
    test('registry - api / mixin / knows / as / duplicate (mirrors platform.test.ts)', () {
      reg.Registry.add('foo', <String, Object?>{'bar': true});
      expect(reg.Registry.knows('foo'), isTrue);
      expect((reg.Registry.as('foo') as Map<String, Object?>)['bar'], true);

      final Object ext = <String, Object?>{};
      reg.Registry.add('knows,as', ext);
      expect(reg.Registry.knows('knows,as'), isTrue);
      expect(reg.Registry.knows('knows,as1234'), isFalse);
      expect(identical(reg.Registry.as('knows,as'), ext), isTrue);
      expect(reg.Registry.as('knows,as1234'), isNull);

      reg.Registry.add('foo-dup', <String, Object?>{'bar': true});
      expect(() => reg.Registry.add('foo-dup', <String, Object?>{'bar': false}),
          throwsA(isA<Error>()));
    });
  });

  group('contextkey/scanner.ts', () {
    List<Map<String, Object?>> scanTokens(String input) {
      final s = scan.Scanner().reset(input).scan();
      return s.map((t) => <String, Object?>{
        'type': t.type, 'offset': t.offset,
        if (t.lexeme != null) 'lexeme': t.lexeme,
        if (t.isTripleEq != null) 'isTripleEq': t.isTripleEq,
      }).toList();
    }
    test("foo.bar<C-shift+2>", () {
      final actual = scanTokens("foo.bar<C-shift+2>");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "foo.bar<C-shift+2>"},
        {'type': scan.TokenType.EOF, 'offset': 18},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("!foo", () {
      final actual = scanTokens("!foo");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Neg, 'offset': 0},
        {'type': scan.TokenType.Str, 'offset': 1, 'lexeme': "foo"},
        {'type': scan.TokenType.EOF, 'offset': 4},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("foo === bar", () {
      final actual = scanTokens("foo === bar");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "foo"},
        {'type': scan.TokenType.Eq, 'offset': 4, 'isTripleEq': true},
        {'type': scan.TokenType.Str, 'offset': 8, 'lexeme': "bar"},
        {'type': scan.TokenType.EOF, 'offset': 11},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("foo  !== bar", () {
      final actual = scanTokens("foo  !== bar");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "foo"},
        {'type': scan.TokenType.NotEq, 'offset': 5, 'isTripleEq': true},
        {'type': scan.TokenType.Str, 'offset': 9, 'lexeme': "bar"},
        {'type': scan.TokenType.EOF, 'offset': 12},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("!(foo && bar)", () {
      final actual = scanTokens("!(foo && bar)");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Neg, 'offset': 0},
        {'type': scan.TokenType.LParen, 'offset': 1},
        {'type': scan.TokenType.Str, 'offset': 2, 'lexeme': "foo"},
        {'type': scan.TokenType.And, 'offset': 6},
        {'type': scan.TokenType.Str, 'offset': 9, 'lexeme': "bar"},
        {'type': scan.TokenType.RParen, 'offset': 12},
        {'type': scan.TokenType.EOF, 'offset': 13},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("=~ ", () {
      final actual = scanTokens("=~ ");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.RegexOp, 'offset': 0},
        {'type': scan.TokenType.EOF, 'offset': 3},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("foo =~ /bar/", () {
      final actual = scanTokens("foo =~ /bar/");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "foo"},
        {'type': scan.TokenType.RegexOp, 'offset': 4},
        {'type': scan.TokenType.RegexStr, 'offset': 7, 'lexeme': "/bar/"},
        {'type': scan.TokenType.EOF, 'offset': 12},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("foo =~ /zee/i", () {
      final actual = scanTokens("foo =~ /zee/i");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "foo"},
        {'type': scan.TokenType.RegexOp, 'offset': 4},
        {'type': scan.TokenType.RegexStr, 'offset': 7, 'lexeme': "/zee/i"},
        {'type': scan.TokenType.EOF, 'offset': 13},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("foo =~ /zee/gm", () {
      final actual = scanTokens("foo =~ /zee/gm");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "foo"},
        {'type': scan.TokenType.RegexOp, 'offset': 4},
        {'type': scan.TokenType.RegexStr, 'offset': 7, 'lexeme': "/zee/gm"},
        {'type': scan.TokenType.EOF, 'offset': 14},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("foo in barrr  ", () {
      final actual = scanTokens("foo in barrr  ");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "foo"},
        {'type': scan.TokenType.In, 'offset': 4},
        {'type': scan.TokenType.Str, 'offset': 7, 'lexeme': "barrr"},
        {'type': scan.TokenType.EOF, 'offset': 14},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("resource =~ //FileCabinet/(SuiteScripts|Templates/(E-mail%20Templates|Marketing%20Templates)|Web%20Site%20Hosting%20Files)(/.*)*\$/", () {
      final actual = scanTokens("resource =~ //FileCabinet/(SuiteScripts|Templates/(E-mail%20Templates|Marketing%20Templates)|Web%20Site%20Hosting%20Files)(/.*)*\$/");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "resource"},
        {'type': scan.TokenType.RegexOp, 'offset': 9},
        {'type': scan.TokenType.RegexStr, 'offset': 12, 'lexeme': "//"},
        {'type': scan.TokenType.Str, 'offset': 14, 'lexeme': "FileCabinet/"},
        {'type': scan.TokenType.LParen, 'offset': 26},
        {'type': scan.TokenType.Str, 'offset': 27, 'lexeme': "SuiteScripts"},
        {'type': scan.TokenType.Error, 'offset': 39, 'lexeme': "|"},
        {'type': scan.TokenType.Str, 'offset': 40, 'lexeme': "Templates/"},
        {'type': scan.TokenType.LParen, 'offset': 50},
        {'type': scan.TokenType.Str, 'offset': 51, 'lexeme': "E-mail%20Templates"},
        {'type': scan.TokenType.Error, 'offset': 69, 'lexeme': "|"},
        {'type': scan.TokenType.Str, 'offset': 70, 'lexeme': "Marketing%20Templates"},
        {'type': scan.TokenType.RParen, 'offset': 91},
        {'type': scan.TokenType.Error, 'offset': 92, 'lexeme': "|"},
        {'type': scan.TokenType.Str, 'offset': 93, 'lexeme': "Web%20Site%20Hosting%20Files"},
        {'type': scan.TokenType.RParen, 'offset': 121},
        {'type': scan.TokenType.LParen, 'offset': 122},
        {'type': scan.TokenType.RegexStr, 'offset': 123, 'lexeme': "/.*)*\$/"},
        {'type': scan.TokenType.EOF, 'offset': 130},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("editorLangId in testely.supportedLangIds && resourceFilename =~ /^.+(.test.(w+))\$/gm", () {
      final actual = scanTokens("editorLangId in testely.supportedLangIds && resourceFilename =~ /^.+(.test.(w+))\$/gm");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "editorLangId"},
        {'type': scan.TokenType.In, 'offset': 13},
        {'type': scan.TokenType.Str, 'offset': 16, 'lexeme': "testely.supportedLangIds"},
        {'type': scan.TokenType.And, 'offset': 41},
        {'type': scan.TokenType.Str, 'offset': 44, 'lexeme': "resourceFilename"},
        {'type': scan.TokenType.RegexOp, 'offset': 61},
        {'type': scan.TokenType.RegexStr, 'offset': 64, 'lexeme': "/^.+(.test.(w+))\$/gm"},
        {'type': scan.TokenType.EOF, 'offset': 84},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("!(foo && bar) && baz", () {
      final actual = scanTokens("!(foo && bar) && baz");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Neg, 'offset': 0},
        {'type': scan.TokenType.LParen, 'offset': 1},
        {'type': scan.TokenType.Str, 'offset': 2, 'lexeme': "foo"},
        {'type': scan.TokenType.And, 'offset': 6},
        {'type': scan.TokenType.Str, 'offset': 9, 'lexeme': "bar"},
        {'type': scan.TokenType.RParen, 'offset': 12},
        {'type': scan.TokenType.And, 'offset': 14},
        {'type': scan.TokenType.Str, 'offset': 17, 'lexeme': "baz"},
        {'type': scan.TokenType.EOF, 'offset': 20},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("foo.bar:zed==completed - equality with no space", () {
      final actual = scanTokens("foo.bar:zed==completed");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "foo.bar:zed"},
        {'type': scan.TokenType.Eq, 'offset': 11},
        {'type': scan.TokenType.Str, 'offset': 13, 'lexeme': "completed"},
        {'type': scan.TokenType.EOF, 'offset': 22},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("a && b || c", () {
      final actual = scanTokens("a && b || c");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "a"},
        {'type': scan.TokenType.And, 'offset': 2},
        {'type': scan.TokenType.Str, 'offset': 5, 'lexeme': "b"},
        {'type': scan.TokenType.Or, 'offset': 7},
        {'type': scan.TokenType.Str, 'offset': 10, 'lexeme': "c"},
        {'type': scan.TokenType.EOF, 'offset': 11},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("fooBar && baz.jar && fee.bee<K-loo+1>", () {
      final actual = scanTokens("fooBar && baz.jar && fee.bee<K-loo+1>");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "fooBar"},
        {'type': scan.TokenType.And, 'offset': 7},
        {'type': scan.TokenType.Str, 'offset': 10, 'lexeme': "baz.jar"},
        {'type': scan.TokenType.And, 'offset': 18},
        {'type': scan.TokenType.Str, 'offset': 21, 'lexeme': "fee.bee<K-loo+1>"},
        {'type': scan.TokenType.EOF, 'offset': 37},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("foo.barBaz<C-r> < 2", () {
      final actual = scanTokens("foo.barBaz<C-r> < 2");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "foo.barBaz<C-r>"},
        {'type': scan.TokenType.Lt, 'offset': 16},
        {'type': scan.TokenType.Str, 'offset': 18, 'lexeme': "2"},
        {'type': scan.TokenType.EOF, 'offset': 19},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("foo.bar >= -1", () {
      final actual = scanTokens("foo.bar >= -1");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "foo.bar"},
        {'type': scan.TokenType.GtEq, 'offset': 8},
        {'type': scan.TokenType.Str, 'offset': 11, 'lexeme': "-1"},
        {'type': scan.TokenType.EOF, 'offset': 13},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("foo.bar <= -1", () {
      final actual = scanTokens("foo.bar <= -1");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "foo.bar"},
        {'type': scan.TokenType.LtEq, 'offset': 8},
        {'type': scan.TokenType.Str, 'offset': 11, 'lexeme': "-1"},
        {'type': scan.TokenType.EOF, 'offset': 13},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("resource =~ /\\/Objects\\/.+\\.xml\$/", () {
      final actual = scanTokens("resource =~ /\\/Objects\\/.+\\.xml\$/");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "resource"},
        {'type': scan.TokenType.RegexOp, 'offset': 9},
        {'type': scan.TokenType.RegexStr, 'offset': 12, 'lexeme': "/\\/Objects\\/.+\\.xml\$/"},
        {'type': scan.TokenType.EOF, 'offset': 33},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("view == vsc-packages-activitybar-folders && vsc-packages-folders-loaded", () {
      final actual = scanTokens("view == vsc-packages-activitybar-folders && vsc-packages-folders-loaded");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "view"},
        {'type': scan.TokenType.Eq, 'offset': 5},
        {'type': scan.TokenType.Str, 'offset': 8, 'lexeme': "vsc-packages-activitybar-folders"},
        {'type': scan.TokenType.And, 'offset': 41},
        {'type': scan.TokenType.Str, 'offset': 44, 'lexeme': "vsc-packages-folders-loaded"},
        {'type': scan.TokenType.EOF, 'offset': 71},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("sfdx:project_opened && resource =~ /.*\\/functions\\/.*\\/[^\\/]+(\\/[^\\/]+.(ts|js|java|json|toml))?\$/ && resourceFilename != package.json && resourceFilename != package-lock.json && resourceFilename != tsconfig.json", () {
      final actual = scanTokens("sfdx:project_opened && resource =~ /.*\\/functions\\/.*\\/[^\\/]+(\\/[^\\/]+.(ts|js|java|json|toml))?\$/ && resourceFilename != package.json && resourceFilename != package-lock.json && resourceFilename != tsconfig.json");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "sfdx:project_opened"},
        {'type': scan.TokenType.And, 'offset': 20},
        {'type': scan.TokenType.Str, 'offset': 23, 'lexeme': "resource"},
        {'type': scan.TokenType.RegexOp, 'offset': 32},
        {'type': scan.TokenType.RegexStr, 'offset': 35, 'lexeme': "/.*\\/functions\\/.*\\/[^\\/]+(\\/[^\\/]+.(ts|js|java|json|toml))?\$/"},
        {'type': scan.TokenType.And, 'offset': 98},
        {'type': scan.TokenType.Str, 'offset': 101, 'lexeme': "resourceFilename"},
        {'type': scan.TokenType.NotEq, 'offset': 118},
        {'type': scan.TokenType.Str, 'offset': 121, 'lexeme': "package.json"},
        {'type': scan.TokenType.And, 'offset': 134},
        {'type': scan.TokenType.Str, 'offset': 137, 'lexeme': "resourceFilename"},
        {'type': scan.TokenType.NotEq, 'offset': 154},
        {'type': scan.TokenType.Str, 'offset': 157, 'lexeme': "package-lock.json"},
        {'type': scan.TokenType.And, 'offset': 175},
        {'type': scan.TokenType.Str, 'offset': 178, 'lexeme': "resourceFilename"},
        {'type': scan.TokenType.NotEq, 'offset': 195},
        {'type': scan.TokenType.Str, 'offset': 198, 'lexeme': "tsconfig.json"},
        {'type': scan.TokenType.EOF, 'offset': 211},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("view =~ '/(servers)/' && viewItem =~ '/^(Starting|Started|Debugging|Stopping|Stopped)/'", () {
      final actual = scanTokens("view =~ '/(servers)/' && viewItem =~ '/^(Starting|Started|Debugging|Stopping|Stopped)/'");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "view"},
        {'type': scan.TokenType.RegexOp, 'offset': 5},
        {'type': scan.TokenType.QuotedStr, 'offset': 9, 'lexeme': "/(servers)/"},
        {'type': scan.TokenType.And, 'offset': 22},
        {'type': scan.TokenType.Str, 'offset': 25, 'lexeme': "viewItem"},
        {'type': scan.TokenType.RegexOp, 'offset': 34},
        {'type': scan.TokenType.QuotedStr, 'offset': 38, 'lexeme': "/^(Starting|Started|Debugging|Stopping|Stopped)/"},
        {'type': scan.TokenType.EOF, 'offset': 87},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("resourcePath =~ /.md(.yml|.txt)*\$/gim", () {
      final actual = scanTokens("resourcePath =~ /.md(.yml|.txt)*\$/gim");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "resourcePath"},
        {'type': scan.TokenType.RegexOp, 'offset': 13},
        {'type': scan.TokenType.RegexStr, 'offset': 16, 'lexeme': "/.md(.yml|.txt)*\$/gim"},
        {'type': scan.TokenType.EOF, 'offset': 37},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("foo === bar'", () {
      final actual = scanTokens("foo === bar'");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "foo"},
        {'type': scan.TokenType.Eq, 'offset': 4, 'isTripleEq': true},
        {'type': scan.TokenType.Str, 'offset': 8, 'lexeme': "bar"},
        {'type': scan.TokenType.Error, 'offset': 11, 'lexeme': "'"},
        {'type': scan.TokenType.EOF, 'offset': 12},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("foo === '", () {
      final actual = scanTokens("foo === '");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "foo"},
        {'type': scan.TokenType.Eq, 'offset': 4, 'isTripleEq': true},
        {'type': scan.TokenType.Error, 'offset': 8, 'lexeme': "'"},
        {'type': scan.TokenType.EOF, 'offset': 9},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("foo && 'bar - unterminated single quote", () {
      final actual = scanTokens("foo && 'bar");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "foo"},
        {'type': scan.TokenType.And, 'offset': 4},
        {'type': scan.TokenType.Error, 'offset': 7, 'lexeme': "'bar"},
        {'type': scan.TokenType.EOF, 'offset': 11},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("vim<c-r> == 1 && vim<2 <= 3", () {
      final actual = scanTokens("vim<c-r> == 1 && vim<2 <= 3");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "vim<c-r>"},
        {'type': scan.TokenType.Eq, 'offset': 9},
        {'type': scan.TokenType.Str, 'offset': 12, 'lexeme': "1"},
        {'type': scan.TokenType.And, 'offset': 14},
        {'type': scan.TokenType.Str, 'offset': 17, 'lexeme': "vim<2"},
        {'type': scan.TokenType.LtEq, 'offset': 23},
        {'type': scan.TokenType.Str, 'offset': 26, 'lexeme': "3"},
        {'type': scan.TokenType.EOF, 'offset': 27},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("vim<c-r>==1 && vim<2<=3", () {
      final actual = scanTokens("vim<c-r>==1 && vim<2<=3");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "vim<c-r>"},
        {'type': scan.TokenType.Eq, 'offset': 8},
        {'type': scan.TokenType.Str, 'offset': 10, 'lexeme': "1"},
        {'type': scan.TokenType.And, 'offset': 12},
        {'type': scan.TokenType.Str, 'offset': 15, 'lexeme': "vim<2<"},
        {'type': scan.TokenType.Error, 'offset': 21, 'lexeme': "="},
        {'type': scan.TokenType.Str, 'offset': 22, 'lexeme': "3"},
        {'type': scan.TokenType.EOF, 'offset': 23},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("foo|bar", () {
      final actual = scanTokens("foo|bar");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "foo"},
        {'type': scan.TokenType.Error, 'offset': 3, 'lexeme': "|"},
        {'type': scan.TokenType.Str, 'offset': 4, 'lexeme': "bar"},
        {'type': scan.TokenType.EOF, 'offset': 7},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("resource =~ //foo/(barr|door/(Foo-Bar%20Templates|Soo%20Looo)|Web%20Site%Jjj%20Llll)(/.*)*\$/", () {
      final actual = scanTokens("resource =~ //foo/(barr|door/(Foo-Bar%20Templates|Soo%20Looo)|Web%20Site%Jjj%20Llll)(/.*)*\$/");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "resource"},
        {'type': scan.TokenType.RegexOp, 'offset': 9},
        {'type': scan.TokenType.RegexStr, 'offset': 12, 'lexeme': "//"},
        {'type': scan.TokenType.Str, 'offset': 14, 'lexeme': "foo/"},
        {'type': scan.TokenType.LParen, 'offset': 18},
        {'type': scan.TokenType.Str, 'offset': 19, 'lexeme': "barr"},
        {'type': scan.TokenType.Error, 'offset': 23, 'lexeme': "|"},
        {'type': scan.TokenType.Str, 'offset': 24, 'lexeme': "door/"},
        {'type': scan.TokenType.LParen, 'offset': 29},
        {'type': scan.TokenType.Str, 'offset': 30, 'lexeme': "Foo-Bar%20Templates"},
        {'type': scan.TokenType.Error, 'offset': 49, 'lexeme': "|"},
        {'type': scan.TokenType.Str, 'offset': 50, 'lexeme': "Soo%20Looo"},
        {'type': scan.TokenType.RParen, 'offset': 60},
        {'type': scan.TokenType.Error, 'offset': 61, 'lexeme': "|"},
        {'type': scan.TokenType.Str, 'offset': 62, 'lexeme': "Web%20Site%Jjj%20Llll"},
        {'type': scan.TokenType.RParen, 'offset': 83},
        {'type': scan.TokenType.LParen, 'offset': 84},
        {'type': scan.TokenType.RegexStr, 'offset': 85, 'lexeme': "/.*)*\$/"},
        {'type': scan.TokenType.EOF, 'offset': 92},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("/((/foo/(?!bar)(.*)/)|((/src/).*/)).*\$/", () {
      final actual = scanTokens("/((/foo/(?!bar)(.*)/)|((/src/).*/)).*\$/");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.RegexStr, 'offset': 0, 'lexeme': "/((/"},
        {'type': scan.TokenType.Str, 'offset': 4, 'lexeme': "foo/"},
        {'type': scan.TokenType.LParen, 'offset': 8},
        {'type': scan.TokenType.Str, 'offset': 9, 'lexeme': "?"},
        {'type': scan.TokenType.Neg, 'offset': 10},
        {'type': scan.TokenType.Str, 'offset': 11, 'lexeme': "bar"},
        {'type': scan.TokenType.RParen, 'offset': 14},
        {'type': scan.TokenType.LParen, 'offset': 15},
        {'type': scan.TokenType.Str, 'offset': 16, 'lexeme': ".*"},
        {'type': scan.TokenType.RParen, 'offset': 18},
        {'type': scan.TokenType.RegexStr, 'offset': 19, 'lexeme': "/)|((/s"},
        {'type': scan.TokenType.Str, 'offset': 26, 'lexeme': "rc/"},
        {'type': scan.TokenType.RParen, 'offset': 29},
        {'type': scan.TokenType.Str, 'offset': 30, 'lexeme': ".*/"},
        {'type': scan.TokenType.RParen, 'offset': 33},
        {'type': scan.TokenType.RParen, 'offset': 34},
        {'type': scan.TokenType.Str, 'offset': 35, 'lexeme': ".*\$/"},
        {'type': scan.TokenType.EOF, 'offset': 39},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("resourcePath =~ //foo/barr// || resourcePath =~ //view/(jarrr|doooor|bees)/(web|templates)// && resourceExtname in foo.Bar", () {
      final actual = scanTokens("resourcePath =~ //foo/barr// || resourcePath =~ //view/(jarrr|doooor|bees)/(web|templates)// && resourceExtname in foo.Bar");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "resourcePath"},
        {'type': scan.TokenType.RegexOp, 'offset': 13},
        {'type': scan.TokenType.RegexStr, 'offset': 16, 'lexeme': "//"},
        {'type': scan.TokenType.Str, 'offset': 18, 'lexeme': "foo/barr//"},
        {'type': scan.TokenType.Or, 'offset': 29},
        {'type': scan.TokenType.Str, 'offset': 32, 'lexeme': "resourcePath"},
        {'type': scan.TokenType.RegexOp, 'offset': 45},
        {'type': scan.TokenType.RegexStr, 'offset': 48, 'lexeme': "//"},
        {'type': scan.TokenType.Str, 'offset': 50, 'lexeme': "view/"},
        {'type': scan.TokenType.LParen, 'offset': 55},
        {'type': scan.TokenType.Str, 'offset': 56, 'lexeme': "jarrr"},
        {'type': scan.TokenType.Error, 'offset': 61, 'lexeme': "|"},
        {'type': scan.TokenType.Str, 'offset': 62, 'lexeme': "doooor"},
        {'type': scan.TokenType.Error, 'offset': 68, 'lexeme': "|"},
        {'type': scan.TokenType.Str, 'offset': 69, 'lexeme': "bees"},
        {'type': scan.TokenType.RParen, 'offset': 73},
        {'type': scan.TokenType.RegexStr, 'offset': 74, 'lexeme': "/(web|templates)/"},
        {'type': scan.TokenType.Error, 'offset': 91, 'lexeme': "/ && resourceExtname in foo.Bar"},
        {'type': scan.TokenType.EOF, 'offset': 122},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
    test("foo =~ /file:// || bar", () {
      final actual = scanTokens("foo =~ /file:// || bar");
      final expected = <Map<String, Object?>>[
        {'type': scan.TokenType.Str, 'offset': 0, 'lexeme': "foo"},
        {'type': scan.TokenType.RegexOp, 'offset': 4},
        {'type': scan.TokenType.RegexStr, 'offset': 7, 'lexeme': "/file:/"},
        {'type': scan.TokenType.Error, 'offset': 14, 'lexeme': "/ || bar"},
        {'type': scan.TokenType.EOF, 'offset': 22},
      ];
      expect(actual.length, expected.length, reason: 'token count');
      for (int i = 0; i < expected.length; i++) {
        expect(actual[i]['type'], expected[i]['type'], reason: '$i type');
        expect(actual[i]['offset'], expected[i]['offset'], reason: '$i offset');
        if (expected[i].containsKey('lexeme')) expect(actual[i]['lexeme'], expected[i]['lexeme'], reason: '$i lexeme');
        if (expected[i].containsKey('isTripleEq')) expect(actual[i]['isTripleEq'], expected[i]['isTripleEq'], reason: '$i isTripleEq');
      }
    });
  });

  group('observableInternal/logging/debugger/rpc.ts', () {
    test('API proxies are not thenable', () async {
      final channel = _TestChannel();
      final connection = rpc.SimpleTypedRpcConnection.createHost((_) => channel, () => _TestSide());
      expect(connection.api.requests.then, isNull);
      expect(connection.api.notifications.then, isNull);
      expect(await connection.api.requests, same(connection.api.requests));
      expect(await connection.api.notifications, same(connection.api.notifications));
    });
    test('requests/notification forwarding (extra)', () async {
      final channel = _TestChannel();
      final connection = rpc.SimpleTypedRpcConnection.createHost((_) => channel, () => _TestSide());
      final result = await connection.api.requests.echo('hello', 42);
      expect(result, 'hello:42');
      connection.api.notifications.note('x');
      expect(channel.notifications.length, 1);
    });
  });
  group('platform/instantiation/common/graph.ts', () {
    // Mirrors graph.ts semantics (no direct .test.ts; self-authored from source).
    String hash(String s) => s;
    test('roots / insertEdge / removeNode / lookup / isEmpty', () {
      final g = igraph.Graph<String>(hash);
      expect(g.isEmpty(), isTrue);
      g.insertEdge('a', 'b');
      g.insertEdge('b', 'c');
      expect(g.isEmpty(), isFalse);
      // b has incoming a and outgoing c; c is a root (no outgoing)
      final roots = g.roots().map((n) => n.key).toList()..sort();
      expect(roots, <String>['c']);
      expect(g.lookup('a')!.outgoing.containsKey('b'), isTrue);
      expect(g.lookup('b')!.incoming.containsKey('a'), isTrue);
      expect(g.lookup('zzz'), isNull);
      g.removeNode('b');
      expect(g.lookup('b'), isNull);
      expect(g.lookup('a')!.outgoing.isEmpty, isTrue);
    });
    test('findCycleSlow', () {
      final g = igraph.Graph<String>(hash);
      g.insertEdge('a', 'b');
      g.insertEdge('b', 'c');
      expect(g.findCycleSlow(), isNull);
      g.insertEdge('c', 'a');
      final cyc = g.findCycleSlow();
      expect(cyc, isNotNull);
      expect(cyc, contains('a'));
      expect(cyc, contains('->'));
    });
    test('toString', () {
      final g = igraph.Graph<String>(hash);
      g.insertEdge('a', 'b');
      expect(g.toString(), contains('a'));
      expect(g.toString(), contains('(outgoing ->)'));
    });
  });

  group('editor/contrib/inlineCompletions/browser/model/graph.ts', () {
    // Mirrors graph.test.ts (DirectedGraph) exactly.
    List<String> Function(String) outgoing(Map<String, List<String>> m) =>
        (node) => m[node] ?? <String>[];

    test('from - creates empty graph', () {
      final g = dgraph.DirectedGraph.from<String>(<String>[], outgoing({}));
      expect(g.getOutgoing('a'), isEmpty);
    });
    test('from - creates graph with single node', () {
      final g = dgraph.DirectedGraph.from<String>(<String>['a'], outgoing({}));
      expect(g.getOutgoing('a'), isEmpty);
    });
    test('from - nodes and edges', () {
      final g = dgraph.DirectedGraph.from<String>(
          <String>['a', 'b', 'c'],
          outgoing({'a': ['b', 'c'], 'b': ['c'], 'c': []}));
      expect((g.getOutgoing('a')..sort()), <String>['b', 'c']);
      expect(g.getOutgoing('b'), <String>['c']);
      expect(g.getOutgoing('c'), isEmpty);
    });
    test('from - handles duplicate edges', () {
      final g = dgraph.DirectedGraph.from<String>(
          <String>['a', 'b'], outgoing({'a': ['b', 'b'], 'b': []}));
      expect(g.getOutgoing('a'), <String>['b']);
      expect(g.getOutgoing('b'), isEmpty);
    });
    test('removeCycles - no cycles', () {
      final g = dgraph.DirectedGraph.from<String>(
          <String>['a', 'b', 'c'],
          outgoing({'a': ['b'], 'b': ['c'], 'c': []}));
      final r = g.removeCycles();
      expect(r['foundCycles'], isEmpty);
      expect(g.getOutgoing('a'), <String>['b']);
      expect(g.getOutgoing('b'), <String>['c']);
    });
    test('removeCycles - simple cycle', () {
      final g = dgraph.DirectedGraph.from<String>(
          <String>['a', 'b'], outgoing({'a': ['b'], 'b': ['a']}));
      final r = g.removeCycles();
      final found = r['foundCycles'] as List<String>;
      expect(found.length, 1);
      expect(found.contains('a') || found.contains('b'), isTrue);
      final aO = g.getOutgoing('a'); final bO = g.getOutgoing('b');
      expect((aO.isEmpty && bO.length == 1) || (aO.length == 1 && bO.isEmpty), isTrue);
    });
    test('removeCycles - self loop', () {
      final g = dgraph.DirectedGraph.from<String>(
          <String>['a'], outgoing({'a': ['a']}));
      final r = g.removeCycles();
      expect(r['foundCycles'], <String>['a']);
      expect(g.getOutgoing('a'), isEmpty);
    });
    test('removeCycles - complex cycle', () {
      final g = dgraph.DirectedGraph.from<String>(
          <String>['a', 'b', 'c', 'd'],
          outgoing({'a': ['b'], 'b': ['c'], 'c': ['d', 'a'], 'd': []}));
      final r = g.removeCycles();
      expect((r['foundCycles'] as List).length, greaterThanOrEqualTo(1));
      expect(g.getOutgoing('c').contains('a'), isFalse);
    });
    test('removeCycles - multiple disconnected cycles', () {
      final g = dgraph.DirectedGraph.from<String>(
          <String>['a', 'b', 'c', 'd'],
          outgoing({'a': ['b'], 'b': ['a'], 'c': ['d'], 'd': ['c']}));
      final r = g.removeCycles();
      expect((r['foundCycles'] as List).length, greaterThanOrEqualTo(2));
      final aO = g.getOutgoing('a'); final bO = g.getOutgoing('b');
      final cO = g.getOutgoing('c'); final dO = g.getOutgoing('d');
      expect((aO.isEmpty && bO.length == 1) || (aO.length == 1 && bO.isEmpty), isTrue);
      expect((cO.isEmpty && dO.length == 1) || (cO.length == 1 && dO.isEmpty), isTrue);
    });
    test('getOutgoing - non-existent node', () {
      final g = dgraph.DirectedGraph.from<String>(<String>['a'], outgoing({}));
      expect(g.getOutgoing('b'), isEmpty);
    });
    test('with number nodes', () {
      final g = dgraph.DirectedGraph.from<int>(<int>[1, 2, 3],
          (n) => ({1: [2, 3], 2: [3], 3: <int>[]}[n] ?? <int>[]));
      expect((g.getOutgoing(1)..sort()), <int>[2, 3]);
      expect(g.getOutgoing(2), <int>[3]);
      expect(g.getOutgoing(3), isEmpty);
    });
  });

  group('smallImmutableSet.ts', () {
    // Mirrors smallImmutableSet.test.ts.
    test('Basic', () {
      final kp = sis.DenseKeyProvider<String>();
      final empty = sis.SmallImmutableSet.getEmpty<String>();
      final items1 = empty.add('item1', kp);
      final items12 = items1.add('item2', kp);
      final items2 = empty.add('item2', kp);
      final items21 = items2.add('item1', kp);
      final items3 = empty.add('item3', kp);
      expect(items12.intersects(items1), isTrue);
      expect(items12.has('item1', kp), isTrue);
      expect(items12.intersects(items3), isFalse);
      expect(items12.has('item3', kp), isFalse);
      expect(items21.equals(items12), isTrue);
      expect(items21.equals(items2), isFalse);
    });
    test('Many Elements', () {
      final kp = sis.DenseKeyProvider<String>();
      var set = sis.SmallImmutableSet.getEmpty<String>();
      for (int i = 0; i < 100; i++) {
        kp.getKey('item$i');
        if (i % 2 == 0) set = set.add('item$i', kp);
      }
      for (int i = 0; i < 100; i++) {
        expect(set.has('item$i', kp), i % 2 == 0);
      }
    });
    test('DenseKeyProvider reverseLookup / keys', () {
      final kp = sis.DenseKeyProvider<String>();
      kp.getKey('a'); kp.getKey('b');
      expect(kp.reverseLookup(0), 'a');
      expect(kp.reverseLookup(1), 'b');
      expect(kp.reverseLookup(99), isNull);
      expect(kp.keys().toList(), <String>['a', 'b']);
    });
  });

  group('base/browser/ui/list/rangeMap.ts', () {
    // Mirrors rangeMap.test.ts.
    IRange rg(num s, num e) => IRange(s, e);
    IRangedGroup grp(num s, num e, num sz) => IRangedGroup(IRange(s, e), sz);
    void expectRange(IRange a, IRange b) {
      expect(a.start, b.start); expect(a.end, b.end);
    }
    void expectGroups(List<IRangedGroup> a, List<IRangedGroup> b) {
      expect(a.length, b.length);
      for (int i = 0; i < a.length; i++) {
        expectRange(a[i].range, b[i].range);
        expect(a[i].size, b[i].size);
      }
    }
    final one = rmap.IItem(1); final two = rmap.IItem(2); final three = rmap.IItem(3);
    final five = rmap.IItem(5); final ten = rmap.IItem(10);

    test('intersection (Range.intersect)', () {
      expectRange(Range.intersect(rg(0,0), rg(0,0)), rg(0,0));
      expectRange(Range.intersect(rg(0,1), rg(5,6)), rg(0,0));
      expectRange(Range.intersect(rg(0,1), rg(0,1)), rg(0,1));
      expectRange(Range.intersect(rg(0,10), rg(0,5)), rg(0,5));
      expectRange(Range.intersect(rg(0,10), rg(5,15)), rg(5,10));
      expectRange(Range.intersect(rg(2,8), rg(0,10)), rg(2,8));
    });
    test('multiIntersect (groupIntersect)', () {
      expect(rmap.groupIntersect(rg(0,0), [grp(0,10,1)]), isEmpty);
      expect(rmap.groupIntersect(rg(10,20), [grp(0,10,1)]), isEmpty);
      expectGroups(rmap.groupIntersect(rg(2,8), [grp(0,10,1)]), [grp(2,8,1)]);
      expectGroups(rmap.groupIntersect(rg(2,18), [grp(0,10,1),grp(10,20,5)]), [grp(2,10,1),grp(10,18,5)]);
      expectGroups(rmap.groupIntersect(rg(2,28), [grp(0,10,1),grp(10,20,5),grp(20,30,10)]), [grp(2,10,1),grp(10,20,5),grp(20,28,10)]);
    });
    test('consolidate', () {
      expect(rmap.consolidate([]), isEmpty);
      expectGroups(rmap.consolidate([grp(0,10,1),grp(10,20,1)]), [grp(0,20,1)]);
      expectGroups(rmap.consolidate([grp(0,10,1),grp(10,20,1),grp(20,100,1)]), [grp(0,100,1)]);
      expectGroups(rmap.consolidate([grp(0,10,1),grp(10,20,5),grp(20,30,10)]), [grp(0,10,1),grp(10,20,5),grp(20,30,10)]);
      expectGroups(rmap.consolidate([grp(0,10,1),grp(10,20,2),grp(20,100,2)]), [grp(0,10,1),grp(10,100,2)]);
    });
    test('empty', () {
      final m = rmap.RangeMap();
      expect(m.size, 0); expect(m.count, 0);
    });
    test('length & count', () {
      final m = rmap.RangeMap(); m.splice(0,0,[one]);
      expect(m.size,1); expect(m.count,1);
      final m2 = rmap.RangeMap(); m2.splice(0,0,[five,five,five,five,five]);
      expect(m2.size,25); expect(m2.count,5);
    });
    test('insert', () {
      final m = rmap.RangeMap();
      m.splice(0,0,[five,five,five,five,five]);
      expect(m.size,25); expect(m.count,5);
      m.splice(0,0,[five,five,five,five,five]);
      expect(m.size,50); expect(m.count,10);
      m.splice(5,0,[ten,ten]);
      expect(m.size,70); expect(m.count,12);
      m.splice(12,0,[rmap.IItem(200)]);
      expect(m.size,270); expect(m.count,13);
    });
    test('delete', () {
      final m = rmap.RangeMap();
      m.splice(0,0,List<rmap.IItem>.filled(20, five));
      expect(m.size,100); expect(m.count,20);
      m.splice(10,5); expect(m.size,75); expect(m.count,15);
      m.splice(0,1); expect(m.size,70); expect(m.count,14);
      m.splice(1,13); expect(m.size,5); expect(m.count,1);
      m.splice(1,1); expect(m.size,5); expect(m.count,1);
    });
    test('insert & delete', () {
      final m = rmap.RangeMap();
      expect(m.size,0); expect(m.count,0);
      m.splice(0,0,[one]); expect(m.size,1); expect(m.count,1);
      m.splice(0,1); expect(m.size,0); expect(m.count,0);
    });
    test('insert & delete #3', () {
      final m = rmap.RangeMap();
      m.splice(0,0,[...List<rmap.IItem>.filled(10, one), ...List<rmap.IItem>.filled(10, two)]);
      m.splice(8,4);
      expect(m.count,16); expect(m.size,24);
    });
    test('insert & delete #4', () {
      final m = rmap.RangeMap();
      m.splice(0,0,[...List<rmap.IItem>.filled(10, one), ...List<rmap.IItem>.filled(10, two)]);
      m.splice(5,0,List<rmap.IItem>.filled(5, three));
      expect(m.count,25); expect(m.size,45);
      m.splice(4,7);
      expect(m.count,18); expect(m.size,28);
    });
    test('indexAt, positionAt - empty/simple', () {
      final m = rmap.RangeMap();
      expect(m.indexAt(0),0); expect(m.indexAt(10),0); expect(m.indexAt(-1),-1);
      expect(m.positionAt(0),-1); expect(m.positionAt(10),-1); expect(m.positionAt(-1),-1);
      final m2 = rmap.RangeMap(); m2.splice(0,0,[one]);
      expect(m2.indexAt(0),0); expect(m2.indexAt(1),1);
      expect(m2.positionAt(0),0); expect(m2.positionAt(1),-1);
      final m3 = rmap.RangeMap(); m3.splice(0,0,[ten]);
      expect(m3.indexAt(0),0); expect(m3.indexAt(5),0); expect(m3.indexAt(9),0); expect(m3.indexAt(10),1);
      expect(m3.positionAt(0),0); expect(m3.positionAt(1),-1);
    });
    test('indexAt, positionAt - insert/delete', () {
      final m = rmap.RangeMap();
      m.splice(0,0,List<rmap.IItem>.filled(10, one));
      expect(m.indexAt(0),0); expect(m.indexAt(5),5); expect(m.indexAt(9),9); expect(m.indexAt(10),10); expect(m.indexAt(11),10);
      m.splice(10,0,List<rmap.IItem>.filled(10, one));
      expect(m.indexAt(19),19); expect(m.indexAt(20),20); expect(m.indexAt(21),20);
      expect(m.positionAt(0),0); expect(m.positionAt(19),19); expect(m.positionAt(20),-1);
      final d = rmap.RangeMap();
      d.splice(0,0,List<rmap.IItem>.filled(10, one)); d.splice(2,6);
      expect(d.indexAt(0),0); expect(d.indexAt(1),1); expect(d.indexAt(3),3); expect(d.indexAt(4),4); expect(d.indexAt(5),4);
      expect(d.positionAt(0),0); expect(d.positionAt(3),3); expect(d.positionAt(4),-1);
    });
    test('indexAt, positionAt - delete #2', () {
      final m = rmap.RangeMap();
      m.splice(0,0,List<rmap.IItem>.filled(10, ten)); m.splice(2,6);
      expect(m.indexAt(0),0); expect(m.indexAt(1),0); expect(m.indexAt(30),3); expect(m.indexAt(40),4); expect(m.indexAt(50),4);
      expect(m.positionAt(0),0); expect(m.positionAt(1),10); expect(m.positionAt(2),20); expect(m.positionAt(3),30); expect(m.positionAt(4),-1);
    });
    test('with top padding', () {
      final m = rmap.RangeMap(10);
      expect(m.size,10); expect(m.count,0);
      m.splice(0,0,[one]); expect(m.size,11); expect(m.count,1);
      final m2 = rmap.RangeMap(10); m2.splice(0,0,[five,five,five,five,five]);
      expect(m2.size,35); expect(m2.count,5);
      final m3 = rmap.RangeMap(10);
      expect(m3.indexAt(0),0); expect(m3.indexAt(10),0); expect(m3.indexAt(-1),-1);
      expect(m3.positionAt(0),-1);
      final m4 = rmap.RangeMap(10); m4.splice(0,0,[one]);
      expect(m4.indexAt(0),0); expect(m4.indexAt(1),0); expect(m4.indexAt(10),0); expect(m4.indexAt(11),1);
      expect(m4.positionAt(0),10); expect(m4.positionAt(1),-1);
    });
  });

  group('editor/browser/gpu/bufferDirtyTracker.ts', () {
    // Mirrors bufferDirtyTracker.test.ts exactly.
    void assertState(bdt.BufferDirtyTracker b, int? dataOffset, int? dirtySize) {
      expect(b.dataOffset, dataOffset);
      expect(b.dirtySize, dirtySize);
      expect(b.isDirty, dataOffset != null);
    }

    test('flag(index)', () {
      final b = bdt.BufferDirtyTracker();
      expect(b.flag(0), 0);
      assertState(b, 0, 1);
      expect(b.flag(31), 31);
      assertState(b, 0, 32);
      b.clear();
      assertState(b, null, null);
      expect(b.flag(10), 10);
      assertState(b, 10, 1);
      expect(b.flag(15), 15);
      assertState(b, 10, 6);
    });

    test('flag(index, length)', () {
      final b = bdt.BufferDirtyTracker();
      b.flag(0, 32);
      assertState(b, 0, 32);
      b.clear();
      assertState(b, null, null);
      b.flag(10, 6);
      assertState(b, 10, 6);
    });
  });

  group('editor/browser/viewParts/minimap/minimapDirtyRows.ts', () {
    // Mirrors minimapDirtyRows.test.ts RowSignatures.diff cases.
    mdr.RowSignatures rows(List<List<dynamic>> drawings, [int height = 10]) {
      final result = mdr.RowSignatures(height);
      for (final d in drawings) {
        result.add(d[0] as num, d[1] as num, d[2] as String, d[3] as bool);
      }
      return result;
    }
    void expectRows(mdr.IDirtyRows? a, mdr.IDirtyRows? b) {
      if (b == null) { expect(a, isNull); return; }
      expect(a, isNotNull);
      expect(a!.start, b.start);
      expect(a.end, b.end);
    }

    test('finds the band of rows drawn differently', () {
      final List<dynamic> cursor = <dynamic>[2, 2, 'red', true];
      final List<dynamic> label = <dynamic>[5, 3, 'Header', false];
      final mdr.RowSignatures empty10 = rows(<List<dynamic>>[]);
      final mdr.RowSignatures empty8 = rows(<List<dynamic>>[], 8);
      final actual = <mdr.IDirtyRows?>[
        mdr.RowSignatures.diff(null, rows(<List<dynamic>>[])),
        mdr.RowSignatures.diff(empty10, rows(<List<dynamic>>[])),
        mdr.RowSignatures.diff(rows(<List<dynamic>>[cursor, label]), rows(<List<dynamic>>[cursor, label])),
        mdr.RowSignatures.diff(rows(<List<dynamic>>[cursor]), rows(<List<dynamic>>[<dynamic>[3, 2, 'red', true]])),
        mdr.RowSignatures.diff(rows(<List<dynamic>>[cursor]), rows(<List<dynamic>>[<dynamic>[2, 2, 'blue', true]])),
        mdr.RowSignatures.diff(rows(<List<dynamic>>[cursor]), rows(<List<dynamic>>[<dynamic>[2, 2.5, 'red', true]])),
        mdr.RowSignatures.diff(rows(<List<dynamic>>[<dynamic>[1, 4, 'red', true]]), rows(<List<dynamic>>[<dynamic>[1, 2, 'red', true], <dynamic>[3, 2, 'red', true]])),
        mdr.RowSignatures.diff(rows(<List<dynamic>>[label]), rows(<List<dynamic>>[<dynamic>[6, 3, 'Header', false]])),
        mdr.RowSignatures.diff(rows(<List<dynamic>>[cursor, <dynamic>[3, 3, 'Header', false]]), rows(<List<dynamic>>[<dynamic>[3, 3, 'Header', false], cursor])),
        mdr.RowSignatures.diff(rows(<List<dynamic>>[<dynamic>[0, 1, 'a', true], <dynamic>[9, 1, 'a', true]]), rows(<List<dynamic>>[<dynamic>[0, 1, 'b', true], <dynamic>[9, 1, 'b', true]])),
        mdr.RowSignatures.diff(empty10, empty8),
      ];
      final expected = <mdr.IDirtyRows?>[
        const mdr.IDirtyRows(0, 10),
        null,
        null,
        const mdr.IDirtyRows(2, 5),
        const mdr.IDirtyRows(2, 4),
        const mdr.IDirtyRows(4, 5),
        null,
        const mdr.IDirtyRows(5, 9),
        const mdr.IDirtyRows(3, 4),
        const mdr.IDirtyRows(0, 10),
        const mdr.IDirtyRows(0, 8),
      ];
      expect(actual.length, expected.length);
      for (int i = 0; i < expected.length; i++) {
        expectRows(actual[i], expected[i]);
      }
    });
  });

  group('editor/common/viewModel/overviewZoneManager.ts', () {
    // Mirrors overviewZoneManager.test.ts exactly.
    void expectZones(List<ozm.ColorZone> a, List<ozm.ColorZone> b) {
      expect(a.length, b.length);
      for (int i = 0; i < b.length; i++) {
        expect(a[i].from, b[i].from, reason: '$i from');
        expect(a[i].to, b[i].to, reason: '$i to');
        expect(a[i].colorId, b[i].colorId, reason: '$i colorId');
      }
    }
    ozm.OverviewZoneManager makeManager(int lineCount, int lineHeight, int domHeight, num pixelRatio) {
      final m = ozm.OverviewZoneManager((lineNumber) => lineHeight * lineNumber);
      m.setDOMWidth(30);
      m.setDOMHeight(domHeight);
      m.setOuterHeight(lineCount * lineHeight);
      m.setLineHeight(lineHeight);
      m.setPixelRatio(pixelRatio);
      m.setZones(<ozm.OverviewRulerZone>[
        ozm.OverviewRulerZone(1, 1, 0, '1'),
        ozm.OverviewRulerZone(10, 10, 0, '2'),
        ozm.OverviewRulerZone(30, 31, 0, '3'),
        ozm.OverviewRulerZone(50, 50, 0, '4'),
      ]);
      return m;
    }

    test('pixel ratio 1, dom height 600', () {
      expectZones(makeManager(50, 20, 600, 1).resolveColorZones(), <ozm.ColorZone>[
        ozm.ColorZone(12, 24, 1),
        ozm.ColorZone(120, 132, 2),
        ozm.ColorZone(360, 384, 3),
        ozm.ColorZone(588, 600, 4),
      ]);
    });
    test('pixel ratio 1, dom height 300', () {
      expectZones(makeManager(50, 20, 300, 1).resolveColorZones(), <ozm.ColorZone>[
        ozm.ColorZone(6, 12, 1),
        ozm.ColorZone(60, 66, 2),
        ozm.ColorZone(180, 192, 3),
        ozm.ColorZone(294, 300, 4),
      ]);
    });
    test('pixel ratio 2, dom height 300', () {
      expectZones(makeManager(50, 20, 300, 2).resolveColorZones(), <ozm.ColorZone>[
        ozm.ColorZone(12, 24, 1),
        ozm.ColorZone(120, 132, 2),
        ozm.ColorZone(360, 384, 3),
        ozm.ColorZone(588, 600, 4),
      ]);
    });
  });

  group('base/browser/ui/scrollbar/scrollbarState.ts', () {
    // Mirrors scrollbarState.test.ts exactly.
    void assertState(sb.ScrollbarState a, num arrow, num pos, num large, num small,
        bool needed, num sliderSize, num sliderPos) {
      expect(a.getArrowSize(), arrow);
      expect(a.getScrollPosition(), pos);
      expect(a.getRectangleLargeSize(), large);
      expect(a.getRectangleSmallSize(), small);
      expect(a.isNeeded(), needed);
      expect(a.getSliderSize(), sliderSize);
      expect(a.getSliderPosition(), sliderPos);
    }

    test('inflates slider size', () {
      final a = sb.ScrollbarState(0, 14, 0, 339, 42423, 32787);
      assertState(a, 0, 32787, 339, 14, true, 20, 249);
      expect(a.getDesiredScrollPositionFromOffset(259), 32849);
      // 259 is greater than 230 so page down, 32787 + 339 = 33126
      expect(a.getDesiredScrollPositionFromOffsetPaged(259), 33126);
      a.setScrollPosition(32849);
      assertState(a, 0, 32849, 339, 14, true, 20, 249);
    });

    test('inflates slider size with arrows', () {
      final a = sb.ScrollbarState(12, 14, 0, 339, 42423, 32787);
      assertState(a, 12, 32787, 339, 14, true, 20, 230);
      expect(a.getDesiredScrollPositionFromOffset(240 + 12), 32811);
      // 240 + 12 = 252; greater than 230 so page down, 32787 + 339 = 33126
      expect(a.getDesiredScrollPositionFromOffsetPaged(240 + 12), 33126);
      a.setScrollPosition(32811);
      assertState(a, 12, 32811, 339, 14, true, 20, 230);
    });
  });

  group('editor/browser/widget/multiDiffEditor/compressedVirtualizedScrollLayout.ts', () {
    // Mirrors the 4 pure-function cases of compressedVirtualizedScrollLayout.test.ts.
    // (The other cases exercise DOM/CSS view code not in this port.)
    test('describes mixed-height content in complete and rendered coordinates', () {
      final layout = cvsl.computeCompressedVirtualizedScrollLayout(
          const cvsl.ICompressedVirtualizedScrollLayoutInput(
              scrollTop: 500, viewportHeight: 400, itemGap: 10,
              itemHeights: <int>[200, 900, 300]));
      expect(layout.scrollTop, 500);
      expect(layout.scrollHeight, 1420);
      expect(layout.renderedHeight, 920);
      expect(layout.renderedViewport.start, 210);
      expect(layout.hiddenContentHeightAboveViewport, 290);
      expect(layout.items.map((i) => i.contentRange.toString()).toList(),
          <String>['[0, 200)', '[210, 1110)', '[1120, 1420)']);
      expect(layout.items.map((i) => i.renderedRange.toString()).toList(),
          <String>['[0, 200)', '[210, 610)', '[620, 920)']);
      expect(layout.items.map((i) => i.maxScrollOffset).toList(), <int>[0, 500, 0]);
      expect(layout.items.map((i) => i.scrollOffset).toList(), <int>[0, 290, 0]);
      expect(layout.items.map((i) => i.visibility).toList(),
          <String>['before', 'visible', 'after']);
    });

    test('conserves vertical displacement', () {
      // Property-based: verify displacement conservation over random layouts.
      final rnd = math.Random(873245);
      int nextIntRange(int min, int max) => min + rnd.nextInt(max - min + 1);
      final failures = <String>[];
      for (int caseIndex = 0; caseIndex < 2000; caseIndex++) {
        final int viewportHeight = nextIntRange(1, 1000);
        final int itemGap = nextIntRange(0, 41);
        final List<int> itemHeights = List<int>.generate(
            nextIntRange(0, 31), (_) => nextIntRange(0, 2501));
        final initial = cvsl.computeCompressedVirtualizedScrollLayout(
            cvsl.ICompressedVirtualizedScrollLayoutInput(
                scrollTop: nextIntRange(0, 50001),
                viewportHeight: viewportHeight,
                itemGap: itemGap,
                itemHeights: itemHeights));
        final next = cvsl.computeCompressedVirtualizedScrollLayout(
            cvsl.ICompressedVirtualizedScrollLayoutInput(
                scrollTop: initial.scrollTop + nextIntRange(-2000, 2001),
                viewportHeight: viewportHeight,
                itemGap: itemGap,
                itemHeights: itemHeights));
        final int scrollDelta = next.scrollTop - initial.scrollTop;
        final int renderedDelta = next.renderedViewport.start - initial.renderedViewport.start;
        final int hiddenDelta =
            next.hiddenContentHeightAboveViewport - initial.hiddenContentHeightAboveViewport;
        final int residual = scrollDelta - renderedDelta - hiddenDelta;
        final invalidItem = next.items.any((item) =>
            item.scrollOffset < 0 ||
            item.scrollOffset > item.maxScrollOffset ||
            item.maxScrollOffset !=
                (item.contentRange.length - item.renderedRange.length > 0
                    ? item.contentRange.length - item.renderedRange.length
                    : 0));
        if (residual.abs() > 0.0001 || invalidItem) {
          failures.add('case $caseIndex: residual=$residual, invalidItem=$invalidItem');
          if (failures.length == 10) break;
        }
      }
      expect(failures, isEmpty);
    });

    test('keeps transient scroll slack outside logical item ranges', () {
      final layout = cvsl.computeCompressedVirtualizedScrollLayout(
          const cvsl.ICompressedVirtualizedScrollLayoutInput(
              revision: 7,
              scrollTop: 0,
              viewportHeight: 400,
              itemGap: 10,
              itemHeights: <int>[200, 300],
              leadingScrollSlack: 100,
              trailingScrollSlack: 150));
      expect(layout.revision, 7);
      expect(layout.logicalScrollHeight, 510);
      expect(layout.scrollHeight, 760);
      expect(layout.renderedHeight, 760);
      expect(layout.contentViewport.toString(), '[-100, 300)');
      expect(layout.items.map((i) => i.contentRange.toString()).toList(),
          <String>['[0, 200)', '[210, 510)']);
      expect(layout.items.map((i) => i.renderedRange.toString()).toList(),
          <String>['[100, 300)', '[310, 610)']);
    });

    test('maps a revisioned viewport anchor through simultaneous size edits', () {
      final edit = cvsl.createAnchoredSizeEditBatch(
          cvsl.asLayoutRevision(3), cvsl.asLayoutRevision(4),
          <int>[200, 900, 300], <int>[300, 40, 500], 10, 10, 750);
      expect(edit.edits.map((e) => e.oldRange.toString()).toList(),
          <String>['[0, 200)', '[210, 1110)', '[1120, 1420)']);
      expect(edit.edits.map((e) => e.newRange.toString()).toList(),
          <String>['[0, 300)', '[310, 350)', '[360, 860)']);
      expect(edit.anchor.revision, 3);
      expect(edit.anchor.offset, 750);
      final mapped = cvsl.mapLogicalPosition(edit.anchor, edit);
      expect(mapped.revision, 4);
      expect(mapped.offset, 310);
      final mappedEnd = cvsl.mapLogicalPosition(
          edit.anchor, edit, cvsl.RemovedPositionAffinity.itemEnd);
      expect(mappedEnd.offset, 350);
      final afterAll = cvsl.mapLogicalPosition(
          const cvsl.ILogicalPosition(3, 1420), edit);
      expect(afterAll.offset, 860);
    });
  });

  group('base/test/common/executionGraph.ts', () {
    // Mirrors executionGraph.test.ts exactly (renderSwimlanes / renderLaneGraph).

    test('renderSwimlanes: empty history', () {
      expect(eg.renderSwimlanes(eg.ExecutionHistory(roots: <eg.ExecutionRoot>[], events: <eg.ExecutionEvent>[])),
          '(empty history)');
    });

    test('renderSwimlanes: single root, linear chain', () {
      final h = _EGHistoryBuilder();
      final A = h.root('A');
      final t0 = h.fire(0, 'setTimeout', A);
      final t1 = h.fire(16, 'rAF', t0);
      h.fire(32, 'rAF', t1);
      expect(eg.renderSwimlanes(h.build()), <String>[
        '            A',
        ' +0ms ├─ setTimeout',
        '+16ms    └─ rAF',
        '+32ms       └─ rAF',
      ].join('\n'));
    });

    test('renderSwimlanes: forest with forks across two roots', () {
      final h = _EGHistoryBuilder();
      final A = h.root('A');
      final B = h.root('B');
      final aT0 = h.fire(0, 'setTimeout', A);
      final bT10 = h.fire(10, 'setTimeout', B);
      final aRaf16 = h.fire(16, 'requestAnimationFrame', aT0);
      final bRaf26 = h.fire(26, 'requestAnimationFrame', bT10);
      h.fire(32, 'requestAnimationFrame', aRaf16);
      h.fire(46, 'setTimeout', bRaf26);
      h.fire(50, 'setTimeout', aT0);
      expect(eg.renderSwimlanes(h.build()), <String>[
        '                     A                             B',
        ' +0ms ├─ setTimeout',
        '+10ms │  |                            ├─ setTimeout',
        '+16ms │  ├─ requestAnimationFrame     │',
        '+26ms │  │                               └─ requestAnimationFrame',
        '+32ms │     └─ requestAnimationFrame     │',
        '+46ms │                                     └─ setTimeout',
        '+50ms    └─ setTimeout',
      ].join('\n'));
    });

    test('renderSwimlanes: degenerate linked-list tree (5 nodes)', () {
      final h = _EGHistoryBuilder();
      final A = h.root('A');
      final e1 = h.fire(0, 'n1', A);
      final e2 = h.fire(10, 'n2', e1);
      final e3 = h.fire(20, 'n3', e2);
      h.fire(30, 'n4', e3);
      expect(eg.renderSwimlanes(h.build()), <String>[
        '             A',
        ' +0ms ├─ n1',
        '+10ms    └─ n2',
        '+20ms       └─ n3',
        '+30ms          └─ n4',
      ].join('\n'));
    });

    test('renderLaneGraph: degenerate linked-list tree (5 nodes)', () {
      final h = _EGHistoryBuilder();
      final A = h.root('A');
      final e1 = h.fire(0, 'n1', A);
      final e2 = h.fire(10, 'n2', e1);
      final e3 = h.fire(20, 'n3', e2);
      h.fire(30, 'n4', e3);
      expect(eg.renderLaneGraph(h.build()), <String>[
        '+A',
        '└─╷─    [   +0ms] n1',
        '  └─╷─  [  +10ms] n2',
        '    └─╷─[  +20ms] n3',
        '      └─[  +30ms] n4',
      ].join('\n'));
    });

    test('renderLaneGraph: forest with forks across two roots', () {
      final h = _EGHistoryBuilder();
      final A = h.root('A');
      final B = h.root('B');
      final aT0 = h.fire(0, 'setTimeout', A);
      final bT10 = h.fire(10, 'setTimeout', B);
      final aRaf16 = h.fire(16, 'requestAnimationFrame', aT0);
      final bRaf26 = h.fire(26, 'requestAnimationFrame', bT10);
      h.fire(32, 'requestAnimationFrame', aRaf16);
      h.fire(46, 'setTimeout', bRaf26);
      h.fire(50, 'setTimeout', aT0);
      expect(eg.renderLaneGraph(h.build()), <String>[
        '+A',
        '└─╷─        [   +0ms] setTimeout',
        '  │ +B',
        '  │ └─╷─    [  +10ms] setTimeout',
        '  ├───┼─╷─  [  +16ms] requestAnimationFrame',
        '  │   └─┼─╷─[  +26ms] requestAnimationFrame',
        '  │     └─┼─[  +32ms] requestAnimationFrame',
        '  │       └─[  +46ms] setTimeout',
        '  └─────────[  +50ms] setTimeout',
      ].join('\n'));
    });

    test('buildHistoryFromTasks / extractCallerFrame', () {
      // Trace object identity drives root/parent grouping.
      final rootObj = eg.TraceRootLike('A');
      final traceA = eg.TraceLike(null, rootObj);
      final traceB = eg.TraceLike(traceA, rootObj);
      final hist = eg.buildHistoryFromTasks(
        <eg.ScheduledTaskLike>[
          eg.ScheduledTaskLike(time: 100, source: 'taskA', trace: traceA),
          eg.ScheduledTaskLike(time: 116, source: 'taskB', trace: traceB),
        ],
        100,
        <eg.LogEntryLike>[
          eg.LogEntryLike(trace: traceB, message: 'hi'),
        ],
      );
      expect(hist.roots.map((r) => r.label).toList(), <String>['A']);
      expect(hist.events.length, 3);
      expect(hist.events[0].time, 0);
      expect(hist.events[0].label, 'taskA');
      expect(hist.events[1].parent, same(hist.events[0]));
      expect(hist.events[2].label, 'log: hi');
      expect(hist.events[2].time, 16);
      expect(eg.extractCallerFrame('  at foo.ts:1\n  at /virtualScheduling/x\n  at bar.ts:2'),
          'foo.ts:1\nbar.ts:2');
      expect(eg.extractCallerFrame(null), isNull);
    });
  });

  group('observableInternal debugLocation 1:1', () {
    test('parseLine handles both stack formats and rejects garbage', () {
      final dloc.ILocation? a = dloc.parseLine('  at foo (/path/to/file.ts:12:34)');
      expect(a, isNotNull);
      expect(a!.fileName, '/path/to/file.ts');
      expect(a.line, 12);
      expect(a.column, 34);
      expect(a.id, '  at foo (/path/to/file.ts:12:34)');

      final dloc.ILocation? b = dloc.parseLine('  at /another/f.ts:7:9');
      expect(b, isNotNull);
      expect(b!.fileName, '/another/f.ts');
      expect(b.line, 7);
      expect(b.column, 9);

      expect(dloc.parseLine('no location here'), isNull);
    });

    test('DebugLocationImpl.fromStack picks parentIdx+1 and returns null on miss', () {
      const String stack = 'Error: x\n  at frame0 (a.ts:1:1)\n  at frame1 (b.ts:2:3)';
      final dloc.DebugLocationImpl? loc = dloc.DebugLocationImpl.fromStack(stack, 0);
      expect(loc, isNotNull);
      expect(loc!.fileName, 'a.ts');
      expect(loc.line, 1);
      expect(loc.column, 1);
      expect(dloc.DebugLocationImpl.fromStack('Error\n  garbage', 0), isNull);
    });
  });

  group('observableInternal debugName 1:1', () {
    test('getDebugName: string source, owner prefix, #count suffix, cache', () {
      final Object t1 = Object();
      final Object t2 = Object();
      final dname.DebugNameData d1 = dname.DebugNameData(null, 'work', null);
      expect(dname.getDebugName(t1, d1), 'work');
      // same target is cached (identity), returns the same name
      expect(dname.getDebugName(t1, d1), 'work');
      // second target with same name gets the #2 suffix
      final dname.DebugNameData d2 = dname.DebugNameData(null, 'work', null);
      expect(dname.getDebugName(t2, d2), 'work#2');
      // method delegates to the same top-level function
      expect(d1.getDebugName(t1), 'work');
    });

    test('getDebugName: owner prefix and function source', () {
      final Object target = Object();
      // findKey with a Map owner resolves by identity
      final Map<String, Object?> fields = <String, Object?>{'myObs': target};
      final dname.DebugNameData data =
          dname.DebugNameData(fields, null, null);
      final String? name = dname.getDebugName(target, data);
      expect(name, endsWith('.myObs'));

      // function source returning a string
      final Object t3 = Object();
      expect(
        dname.getDebugName(t3, dname.DebugNameData(null, () => 'fnName', null)),
        'fnName',
      );
    });

    test('getClassName / getFunctionName', () {
      expect(dname.getClassName(Object()), isNull); // ctor.name === 'Object'
      expect(dname.getClassName(<int>[1, 2]), isNotNull);
      expect(
        dname.getFunctionName(() {
          /* @description annotated */
        }),
        isNull, // Dart closures don't carry source text for the JSDoc regex
      );
    });
  });

  group('observableInternal debuggerApi type shapes', () {
    test('declaration type constants and value carriers', () {
      expect(dbgapi.ObsDebuggerApi.channelId, 'observableDevTools');
      expect(dbgapi.ObsDeclarationType.observableValue, 'observable/value');
      expect(dbgapi.ObsDeclarationType.observableDerived, 'observable/derived');
      expect(dbgapi.ObsDeclarationType.autorun, 'autorun');
      expect(dbgapi.ObsDeclarationType.transaction, 'transaction');
      final dbgapi.IObsDeclaration decl = dbgapi.IObsDeclaration(
        1,
        dbgapi.ObsDeclarationType.observableValue,
        'file.ts',
        10,
        20,
      );
      expect(decl.id, 1);
      expect(decl.line, 10);
      expect(decl.column, 20);
    });
  });

  group('observableInternal debuggerRpc 1:1', () {
    test('createChannelFactoryFromDebugChannel wires channel and handler', () {
      final List<Object> hostNotifications = <Object>[];
      final dbgrpc.IHost host = dbgrpc.IHost((Object data) => hostNotifications.add(data));
      final dbgrpc.DebugChannelFactoryResult result =
          dbgrpc.createChannelFactoryFromDebugChannel(host);
      final _TestChannelHandler handler = _TestChannelHandler();

      final rpc.IChannel channel = result.channel(handler);
      channel.sendNotification('n1');
      expect(hostNotifications, <Object>['n1']);
      expect(() => channel.sendRequest('r1'), throwsA(isA<StateError>()));

      // handler dispatches notification vs request based on `type`
      result.handler.handleRequest(<String, Object?>{'type': 'notification', 'data': 'dn'});
      expect(handler.notifications, <Object>['dn']);
      result.handler.handleRequest(<String, Object?>{'type': 'request', 'data': 'dr'});
      expect(handler.requests, <Object>['dr']);
    });

    test('registerDebugChannel queues notifications before host connects', () {
      const String cid = 'test.channel';
      dbgrpc.$$debugValueEditor_debugChannels.remove(cid);
      final rpc.SimpleTypedRpcConnection<rpc.MakeSideAsync> conn =
          dbgrpc.registerDebugChannel<_TestApi>(cid, () => _TestApi());
      expect(conn, isA<rpc.SimpleTypedRpcConnection>());
      expect(dbgrpc.$$debugValueEditor_debugChannels.containsKey(cid), isTrue);
    });
  });

  group('monarchTypes / argv type shapes', () {
    test('monarch language definition carriers', () {
      final lang = monarch.IMonarchLanguage(
        tokenizer: <String, List<monarch.IMonarchLanguageRule>>{
          'root': <monarch.IMonarchLanguageRule>[
            monarch.IExpandedMonarchLanguageRule(
              regex: 'abc',
              action: monarch.IExpandedMonarchLanguageAction(token: 'keyword'),
            ),
          ],
        },
        ignoreCase: true,
        defaultToken: 'source',
      );
      expect(lang.tokenizer['root']!.length, 1);
      expect(lang.tokenizer['root']!.first, isA<monarch.IExpandedMonarchLanguageRule>());
      expect(lang.ignoreCase, isTrue);
      expect(lang.defaultToken, 'source');
      expect(lang.extra, isEmpty);

      final shortRule = monarch.IShortMonarchLanguageRule1(
        '\\d+', monarch.IShortActionCarrier('number'));
      expect(shortRule.action, isA<monarch.IShortActionCarrier>());
      final bracket = monarch.IMonarchLanguageBracket('{', '}', 'delimiter.curly');
      expect(bracket.token, 'delimiter.curly');
    });

    test('argv interface value carriers', () {
      final args = argv.NativeParsedArgs(
        underscore: <String>['file.ts'],
        help: true,
        folderUri: <String>['file:///work'],
        telemetryLevel: 'off',
      );
      expect(args.underscore, <String>['file.ts']);
      expect(args.help, isTrue);
      expect(args.folderUri, <String>['file:///work']);
      expect(args.telemetryLevel, 'off');
      expect(args.version, isNull);

      final tunnel = argv.NativeTunnelOptions(
        user: argv.NativeTunnelLogin(accessToken: 'tok', provider: 'github'),
      );
      expect(tunnel.user!.accessToken, 'tok');
      final chat = argv.NativeChatOptions(underscore: <String>['hi'], maximize: true);
      expect(chat.underscore, <String>['hi']);
      expect(chat.maximize, isTrue);
    });
  });

}
