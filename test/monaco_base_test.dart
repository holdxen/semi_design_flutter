// Regression tests for base/common files in the 1:1 Monaco port.
// Assertions mirror the semantics of the TypeScript originals.

import 'dart:math' as math;
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/nls.dart';
import 'package:semi_design_flutter/src/monaco/base/common/assert.dart';
import 'package:semi_design_flutter/src/monaco/base/common/errors.dart';
import 'package:semi_design_flutter/src/monaco/base/common/equals.dart' as eq;
import 'package:semi_design_flutter/src/monaco/base/common/arrays.dart' as arr;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart' as lc;
import 'package:semi_design_flutter/src/monaco/base/common/event.dart' as ev;
import 'package:semi_design_flutter/src/monaco/base/common/tfIdf.dart' as tf;
import 'package:semi_design_flutter/src/monaco/base/common/sequence.dart' as seq;
import 'package:semi_design_flutter/src/monaco/base/common/cache.dart' as cache;
import 'package:semi_design_flutter/src/monaco/base/common/cancellation.dart' as cancellation;
import 'package:semi_design_flutter/src/monaco/base/common/history.dart' as hist;
import 'package:semi_design_flutter/src/monaco/base/common/actions.dart' as actions;
import 'package:semi_design_flutter/src/monaco/base/common/stream.dart' as streams;
import 'package:semi_design_flutter/src/monaco/base/common/scrollable.dart' as scroll;
import 'package:semi_design_flutter/src/monaco/base/common/decorators/cancelPreviousCalls.dart' as canceldec;
import 'package:semi_design_flutter/src/monaco/base/common/paging.dart' as paging;
import 'package:semi_design_flutter/src/monaco/base/common/decorators.dart' as decorators;
import 'package:semi_design_flutter/src/monaco/base/common/buffer.dart' as buffer;
import 'package:semi_design_flutter/src/monaco/base/common/linkedText.dart' as linkedText;
import 'package:semi_design_flutter/src/monaco/base/common/marshalling.dart' as marshalling;
import 'package:semi_design_flutter/src/monaco/base/common/errorMessage.dart' as errorMessage;
import 'package:semi_design_flutter/src/monaco/editor/common/core/position.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/text/textLength.dart' as textLength;
import 'package:semi_design_flutter/src/monaco/editor/common/services/semanticTokensDto.dart' as semTok;
import 'package:semi_design_flutter/src/monaco/base/common/strings.dart' as strings;
import 'package:semi_design_flutter/src/monaco/base/common/hash.dart' as hash;
import 'package:semi_design_flutter/src/monaco/editor/common/core/stringBuilder.dart' as stringBuilder;
import 'package:semi_design_flutter/src/monaco/editor/common/core/cursorColumns.dart' as cursorColumns;
import 'package:semi_design_flutter/src/monaco/editor/common/core/textChange.dart' as textChange;
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
import 'package:semi_design_flutter/src/monaco/base/common/validation.dart' as val;
import 'package:semi_design_flutter/src/monaco/base/common/diff/diff.dart' as diff;
import 'package:semi_design_flutter/src/monaco/base/common/filters.dart' as filters;
import 'package:semi_design_flutter/src/monaco/base/common/network.dart' as net;
import 'package:semi_design_flutter/src/monaco/base/common/resources.dart' as resources;
import 'package:semi_design_flutter/src/monaco/platform/remote/common/remoteHosts.dart' as remoteHosts;
import 'package:semi_design_flutter/src/monaco/editor/common/core/wordHelper.dart' as wh;
import 'package:semi_design_flutter/src/monaco/base/common/path.dart' as path;
import 'package:semi_design_flutter/src/monaco/base/common/charCode.dart' as cc;
import 'package:semi_design_flutter/src/monaco/base/common/extpath.dart' as extpath;
import 'package:semi_design_flutter/src/monaco/base/common/ternarySearchTree.dart' as tst;
import 'package:semi_design_flutter/src/monaco/base/common/search.dart' as search;
import 'package:semi_design_flutter/src/monaco/base/common/severity.dart' as severity;
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

  group('equals (1:1 equals.ts)', () {
    test('arrays.equals: same ref / null / length / itemEquals', () {
      final List<int> a = <int>[1, 2, 3];
      expect(arr.equals<int>(a, a), isTrue); // one === other
      expect(arr.equals<int>(null, null), isTrue);
      expect(arr.equals<int>(a, null), isFalse);
      expect(arr.equals<int>(a, <int>[1, 2]), isFalse);
      expect(arr.equals<int>(a, <int>[1, 2, 3]), isTrue);
      expect(arr.equals<int>(a, <int>[1, 2, 4]), isFalse);
      // custom itemEquals: compare modulo 10
      expect(arr.equals<int>(<int>[1, 2], <int>[11, 12], (x, y) => x % 10 == y % 10), isTrue);
    });

    test('strictEquals / strictEqualsC / arrayEquals / arrayEqualsC', () {
      expect(eq.strictEquals<int>(1, 1), isTrue);
      expect(eq.strictEquals<int>(1, 2), isFalse);
      final Object o = Object();
      expect(eq.strictEquals<Object>(o, o), isTrue);
      expect(eq.strictEquals<Object>(o, Object()), isFalse);
      expect(eq.strictEqualsC<int>()(3, 3), isTrue);
      expect(eq.arrayEquals<int>(<int>[1, 2], <int>[1, 2]), isTrue);
      expect(eq.arrayEquals<int>(<int>[1, 2], <int>[1, 3]), isFalse);
      expect(eq.arrayEqualsC<int>()(<int>[5], <int>[5]), isTrue);
    });

    test('structuralEquals: nested lists and maps', () {
      expect(eq.structuralEquals<Object>(<Object>[1, <int>[2, 3]], <Object>[1, <int>[2, 3]]), isTrue);
      expect(eq.structuralEquals(<int>[1, 2], <int>[1, 2, 3]), isFalse);
      expect(
        eq.structuralEquals(
          <String, Object?>{'a': 1, 'b': <int>[2, 3]},
          <String, Object?>{'b': <int>[2, 3], 'a': 1},
        ),
        isTrue,
      );
      expect(
        eq.structuralEquals(
          <String, Object?>{'a': 1},
          <String, Object?>{'a': 2},
        ),
        isFalse,
      );
      // key mismatch
      expect(eq.structuralEquals(<String, int>{'a': 1}, <String, int>{'b': 1}), isFalse);
      expect(eq.structuralEqualsC<List<int>>()(<int>[1], <int>[1]), isTrue);
    });

    test('getStructuralKey: key order normalized, object identity for non-plain', () {
      final String k1 = eq.getStructuralKey(<String, Object?>{'a': 1, 'b': 2});
      final String k2 = eq.getStructuralKey(<String, Object?>{'b': 2, 'a': 1});
      expect(k1, k2);
      expect(eq.getStructuralKey(<Object?>[1, 'x', true]), '[1,"x",true]');
      // non-plain object -> stable identity string (same object twice = same key)
      final Object o = Object();
      expect(eq.getStructuralKey(o), eq.getStructuralKey(o));
      expect(eq.getStructuralKey(o), isNot(eq.getStructuralKey(Object())));
    });

    test('jsonStringifyEquals / equalsIfDefined / thisEqualsC', () {
      expect(eq.jsonStringifyEquals(<String, int>{'a': 1}, <String, int>{'a': 1}), isTrue);
      expect(eq.jsonStringifyEqualsC<Map<String, int>>()(<String, int>{'a': 1}, <String, int>{'a': 2}), isFalse);
      expect(eq.equalsIfDefined<int>(null, null, eq.strictEquals), isTrue);
      expect(eq.equalsIfDefined<int>(null, 1, eq.strictEquals), isFalse);
      expect(eq.equalsIfDefined<int>(1, 1, eq.strictEquals), isTrue);
      expect(eq.equalsIfDefinedC<int>(eq.strictEquals)(null, null), isTrue);
      expect(eq.Equals.strictValue<int>(2, 2), isTrue);
      expect(eq.Equals.array<int>()(<int>[1], <int>[1]), isTrue);
    });
  });

  group('lifecycle (1:1 lifecycle.ts)', () {
    test('dispose single / array / iterable; rethrows composite on multiple', () {
      int calls = 0;
      final lc.IDisposable d = lc.toDisposable(() => calls++);
      lc.dispose(d);
      lc.dispose(d); // FunctionDisposable is idempotent
      expect(calls, 1);

      int n = 0;
      final List<lc.IDisposable> items = <lc.IDisposable>[
        lc.toDisposable(() => n++),
        lc.toDisposable(() => n++),
      ];
      final Object? result = lc.dispose(items);
      expect(n, 2);
      expect(result, isA<List<Object>>()); // source returns [] for arrays

      // multiple throw -> AggregateError
      final List<lc.IDisposable> bad = <lc.IDisposable>[
        lc.toDisposable(() => throw StateError('a')),
        lc.toDisposable(() => throw StateError('b')),
      ];
      expect(() => lc.dispose(bad), throwsA(isA<lc.AggregateError>()));
    });

    test('DisposableStore: add/delete/deleteAndLeak/idempotent dispose', () {
      final lc.DisposableStore store = lc.DisposableStore();
      int a = 0, b = 0;
      final lc.IDisposable da = lc.toDisposable(() => a++);
      final lc.IDisposable db = lc.toDisposable(() => b++);
      store.add(da);
      store.add(db);
      expect(store.isDisposed, isFalse);
      store.delete(da);
      expect(a, 1);
      store.deleteAndLeak(db);
      expect(b, 0); // not disposed
      store.dispose();
      store.dispose(); // idempotent
      expect(store.isDisposed, isTrue);
    });

    test('DisposableSet: values / Symbol.iterator / deleteAndLeak', () {
      final lc.DisposableSet<lc.IDisposable> set = lc.DisposableSet<lc.IDisposable>();
      int v = 0;
      final lc.IDisposable d = lc.toDisposable(() => v++);
      set.add(d);
      expect(set.has(d), isTrue);
      expect(set.size, 1);
      expect(set.toList(), <lc.IDisposable>[d]); // implements Iterable
      expect(set.deleteAndLeak(d), d);
      expect(set.has(d), isFalse);
      expect(v, 0);
      set.add(d);
      set.deleteAndDispose(d);
      expect(v, 1);
    });

    test('MutableDisposable / MandatoryMutableDisposable / RefCountedDisposable', () {
      final lc.MutableDisposable<lc.IDisposable> m = lc.MutableDisposable<lc.IDisposable>();
      int a = 0, b = 0;
      m.value = lc.toDisposable(() => a++);
      m.value = lc.toDisposable(() => b++);
      expect(a, 1); // old disposed on replace
      expect(m.value, isNotNull);
      final Object? leaked = m.clearAndLeak();
      expect(leaked, isNotNull);
      expect(b, 0);
      m.dispose();

      final lc.MandatoryMutableDisposable<lc.IDisposable> mm =
          lc.MandatoryMutableDisposable<lc.IDisposable>(lc.toDisposable(() {}));
      expect(mm.value, isA<lc.IDisposable>());
      mm.dispose();

      int disposed = 0;
      final lc.RefCountedDisposable rc = lc.RefCountedDisposable(lc.toDisposable(() => disposed++));
      rc.acquire(); // counter = 2
      rc.release(); // counter = 1
      expect(disposed, 0);
      rc.release(); // counter = 0
      expect(disposed, 1);
    });

    test('ReferenceCollection / DisposableMap / thenIfNotDisposed', () async {
      int created = 0, destroyed = 0;
      final _TestRefCollection refs = _TestRefCollection(() => created++, (_) => destroyed++);
      final lc.IReference<int> r1 = refs.acquire('k');
      final lc.IReference<int> r2 = refs.acquire('k');
      expect(r1.object, 1);
      expect(created, 1); // cached
      r1.dispose();
      r2.dispose();
      expect(destroyed, 1); // destroyed when counter hits 0

      final lc.DisposableMap<String, lc.IDisposable> dm = lc.DisposableMap<String, lc.IDisposable>();
      int d = 0;
      dm.set('a', lc.toDisposable(() => d++));
      dm.set('a', lc.toDisposable(() => d++)); // disposes old
      expect(d, 1);
      expect(dm.has('a'), isTrue);
      dm.deleteAndDispose('a');
      expect(d, 2);

      bool ran = false;
      final Completer<int> c = Completer<int>();
      final lc.IDisposable sub = lc.thenIfNotDisposed(c.future, (int v) => ran = true);
      sub.dispose();
      c.complete(1);
      await c.future;
      await Future<void>.delayed(Duration.zero);
      expect(ran, isFalse); // disposed before resolve
    });
  });

  group('event (1:1 event.ts)', () {
    test('Emitter plain: fire then dispose listener', () {
      final ev.Emitter<String> emitter = ev.Emitter<String>();
      final _EventCounter counter = _EventCounter();
      final lc.IDisposable sub = emitter.event(counter.onEvent);
      emitter.fire('far');
      emitter.fire('boo');
      sub.dispose();
      emitter.fire('boo');
      expect(counter.count, 2);
      emitter.dispose();
    });

    test('Emitter duplicate functions: same fn added twice', () {
      final List<String> calls = <String>[];
      void a(dynamic v) => calls.add('a$v');
      void b(dynamic v) => calls.add('b$v');
      final ev.Emitter<String> emitter = ev.Emitter<String>();
      emitter.event(a);
      emitter.event(b);
      final lc.IDisposable s2 = emitter.event(a);
      emitter.fire('1');
      expect(calls, <String>['a1', 'b1', 'a1']);
      s2.dispose();
      calls.clear();
      emitter.fire('2');
      expect(calls, <String>['a2', 'b2']);
      emitter.dispose();
    });

    test('Emitter handles removal during emission', () {
      final List<String> fn1 = <String>[];
      final List<String> fn2 = <String>[];
      final ev.Emitter<String> emitter = ev.Emitter<String>();
      emitter.event((dynamic v) => fn1.add(v as String));
      late final lc.IDisposable h;
      h = emitter.event((dynamic v) => h.dispose());
      emitter.event((dynamic v) => fn2.add(v as String));
      emitter.fire('foo');
      expect(fn1, <String>['foo']);
      expect(fn2, <String>['foo']);
      emitter.dispose();
    });

    test('onWillAddFirst / onDidRemoveLast listener counts', () {
      int first = 0, last = 0;
      final ev.Emitter<dynamic> emitter = ev.Emitter<dynamic>(ev.EmitterOptions(
        onWillAddFirstListener: () => first++,
        onDidRemoveLastListener: () => last++,
      ));
      expect(first, 0);
      expect(last, 0);
      final lc.IDisposable s1 = emitter.event((dynamic _) {});
      final lc.IDisposable s2 = emitter.event((dynamic _) {});
      expect(first, 1);
      expect(last, 0);
      s1.dispose();
      expect(first, 1);
      expect(last, 0);
      s2.dispose();
      expect(first, 1);
      expect(last, 1);
      emitter.event((dynamic _) {}).dispose();
      expect(first, 2);
      emitter.dispose();
    });

    test('throwing listener does not block other listeners', () {
      final ev.Emitter<dynamic> emitter = ev.Emitter<dynamic>(ev.EmitterOptions(
        onListenerError: (dynamic e) {}, // swallow
      ));
      bool hit = false;
      emitter.event((dynamic _) => throw StateError('boom'));
      emitter.event((dynamic _) => hit = true);
      emitter.fire(null);
      expect(hit, isTrue);
      emitter.dispose();
    });

    test('Event.map / filter / once / signal helpers', () {
      final ev.Emitter<int> emitter = ev.Emitter<int>();
      final ev.Event<String> mapped = ev.eventMap<int, String>(emitter.event, (i) => 'v$i');
      final List<String> got = <String>[];
      mapped((dynamic v) => got.add(v as String));
      emitter.fire(1);
      emitter.fire(2);
      expect(got, <String>['v1', 'v2']);

      final ev.Event<int> filtered = ev.eventFilter<int>(emitter.event, (i) => i.isEven);
      final List<int> even = <int>[];
      filtered((dynamic v) => even.add(v as int));
      emitter.fire(3);
      emitter.fire(4);
      // snapshot filters subscribe lazily, so only fires after subscription count.
      expect(even, <int>[4]);

      int onceCount = 0;
      ev.eventOnce<int>(emitter.event)((dynamic _) => onceCount++);
      emitter.fire(5);
      emitter.fire(6);
      expect(onceCount, 1);
      emitter.dispose();
    });

    test('PauseableEmitter: pause/resume no merge and with merge', () {
      final List<int> data = <int>[];
      final ev.PauseableEmitter<int> emitter = ev.PauseableEmitter<int>();
      emitter.event((dynamic e) => data.add(e as int));
      emitter.fire(1);
      emitter.fire(2);
      expect(data, <int>[1, 2]);
      emitter.pause();
      emitter.fire(3);
      emitter.fire(4);
      expect(data, <int>[1, 2]);
      emitter.resume();
      expect(data, <int>[1, 2, 3, 4]);
      emitter.fire(5);
      expect(data, <int>[1, 2, 3, 4, 5]);
      emitter.dispose();

      final List<int> merged = <int>[];
      final ev.PauseableEmitter<int> m = ev.PauseableEmitter<int>(
        ev.EmitterOptionsWithMerge<int>((List<int> xs) => xs.fold<int>(0, (a, b) => a + b)),
      );
      m.event((dynamic e) => merged.add(e as int));
      m.pause();
      m.fire(1);
      m.fire(2);
      m.fire(3);
      m.resume();
      expect(merged, <int>[6]);
      m.dispose();
    });

    test('Relay forwards from swappable input; ValueWithChangeEvent fires on change', () {
      final ev.Emitter<int> a = ev.Emitter<int>();
      final ev.Emitter<int> b = ev.Emitter<int>();
      final ev.Relay<int> relay = ev.Relay<int>();
      final List<int> got = <int>[];
      relay.event((dynamic v) => got.add(v as int));
      relay.input = a.event;
      a.fire(1);
      relay.input = b.event;
      a.fire(2); // no longer forwarded
      b.fire(3);
      expect(got, <int>[1, 3]);
      relay.dispose();

      int changes = 0;
      final ev.ValueWithChangeEvent<int> vwc = ev.ValueWithChangeEvent<int>(1);
      vwc.onDidChange((dynamic _) => changes++);
      vwc.value = 1; // no change
      vwc.value = 2;
      expect(changes, 1);
      expect(vwc.value, 2);
    });
  });

  group('tfIdf / sequence / cache (1:1)', () {
    tf.TfIdfDocument _doc(String key, Object chunks) => tf.TfIdfDocument(
        key: key,
        textChunks: chunks is String ? <String>[chunks] : List<String>.from(chunks as List));

    List<String> _scoreKeys(List<tf.TfIdfScore> scores) {
      final List<tf.TfIdfScore> sorted = List<tf.TfIdfScore>.from(scores)
        ..sort((tf.TfIdfScore a, tf.TfIdfScore b) {
          final int byScore = b.score.compareTo(a.score);
          return byScore != 0 ? byScore : a.key.compareTo(b.key);
        });
      return sorted.map((tf.TfIdfScore s) => s.key).toList();
    }

    test('TfIdf: no docs / term not present / exact match', () {
      final cancellationToken = cancellation.CancellationToken.none;
      expect(tf.TfIdfCalculator().calculateScores('something', cancellationToken), isEmpty);

      final calc2 = tf.TfIdfCalculator()
        ..updateDocuments(<tf.TfIdfDocument>[_doc('A', 'cat dog fish')]);
      expect(calc2.calculateScores('elephant', cancellationToken), isEmpty);

      final calc3 = tf.TfIdfCalculator()
        ..updateDocuments(<tf.TfIdfDocument>[
          _doc('A', 'cat dog cat'),
          _doc('B', 'cat fish'),
        ]);
      expect(_scoreKeys(calc3.calculateScores('dog', cancellationToken)), <String>['A']);
    });

    test('TfIdf: more matches first / weighting / camelCase / ignore case', () {
      final cancellationToken = cancellation.CancellationToken.none;
      final calc = tf.TfIdfCalculator()
        ..updateDocuments(<tf.TfIdfDocument>[
          _doc('/A', 'cat dog cat'),
          _doc('/B', 'cat fish'),
          _doc('/C', 'frog'),
        ]);
      expect(_scoreKeys(calc.calculateScores('cat', cancellationToken)), <String>['/A', '/B']);

      final camel = tf.TfIdfCalculator()
        ..updateDocuments(<tf.TfIdfDocument>[
          _doc('/A', 'catDog cat'),
          _doc('/B', 'fishCatFish'),
          _doc('/C', 'frogcat'),
        ]);
      expect(_scoreKeys(camel.calculateScores('catDOG', cancellationToken)), <String>['/A', '/B']);

      final ci = tf.TfIdfCalculator()
        ..updateDocuments(<tf.TfIdfDocument>[
          _doc('/A', 'Cat doG.cat'),
          _doc('/B', 'cAt fiSH'),
          _doc('/C', 'frOg'),
        ]);
      expect(_scoreKeys(ci.calculateScores('. ,CaT!  ', cancellationToken)), <String>['/A', '/B']);
    });

    test('TfIdf: chunks weighting / delete document / normalize', () {
      final cancellationToken = cancellation.CancellationToken.none;
      final calc = tf.TfIdfCalculator()
        ..updateDocuments(<tf.TfIdfDocument>[
          _doc('/A', <String>['cat dog cat', 'fish']),
          _doc('/B', <String>['cat cat cat cat dog', 'dog']),
        ]);
      expect(_scoreKeys(calc.calculateScores('cat', cancellationToken)), <String>['/B', '/A']);

      final del = tf.TfIdfCalculator()
        ..updateDocuments(<tf.TfIdfDocument>[_doc('/A', 'cat dog cat'), _doc('/B', 'cat fish')]);
      expect(_scoreKeys(del.calculateScores('cat', cancellationToken)), <String>['/A', '/B']);
      del.deleteDocument('/A');
      expect(_scoreKeys(del.calculateScores('cat', cancellationToken)), <String>['/B']);

      final normalized = tf.normalizeTfIdfScores(<tf.TfIdfScore>[
        tf.TfIdfScore(key: 'a', score: 2),
        tf.TfIdfScore(key: 'b', score: 1),
      ]);
      expect(normalized.first.key, 'a');
      expect(normalized.first.score, 1.0);
      expect(normalized.last.score, 0.5);
    });

    test('Sequence: splice fires onDidSplice with correct data', () {
      final seq.Sequence<int> s = seq.Sequence<int>();
      final List<seq.ISplice<int>> events = <seq.ISplice<int>>[];
      s.onDidSplice((dynamic e) => events.add(e as seq.ISplice<int>));
      s.splice(0, 0, <int>[1, 2, 3]);
      expect(s.elements, <int>[1, 2, 3]);
      s.splice(1, 1, <int>[9]);
      expect(s.elements, <int>[1, 9, 3]);
      expect(events.length, 2);
      expect(events.first.start, 0);
      expect(events.first.deleteCount, 0);
      expect(events.first.toInsert, <int>[1, 2, 3]);
    });

    test('Cache: caches result, retries after dispose', () async {
      int counter = 0;
      final cache.Cache<int> c = cache.Cache<int>((_) async => counter++);
      final int first = await c.get().promise;
      final int second = await c.get().promise;
      expect(first, 0);
      expect(second, 0); // cached
      expect(counter, 1);
      c.get().dispose();
      final int third = await c.get().promise;
      expect(third, 1); // recomputed after dispose
    });

    test('CachedFunction / LRUCachedFunction / WeakCachedFunction', () {
      int calls = 0;
      final cache.CachedFunction<int, int> cf = cache.CachedFunction<int, int>((int x) {
        calls++;
        return x * 2;
      });
      expect(cf.get(3), 6);
      expect(cf.get(3), 6);
      expect(calls, 1);
      expect(cf.cachedValues.length, 1);

      int lruCalls = 0;
      final cache.LRUCachedFunction<int, int> lru = cache.LRUCachedFunction<int, int>((int x) {
        lruCalls++;
        return x + 1;
      });
      expect(lru.get(1), 2);
      expect(lru.get(1), 2);
      expect(lru.get(2), 3);
      expect(lruCalls, 2); // last-key only

      final Object key = Object();
      int weakCalls = 0;
      final cache.WeakCachedFunction<Object, int> weak =
          cache.WeakCachedFunction<Object, int>((Object _) => ++weakCalls);
      expect(weak.get(key), 1);
      expect(weak.get(key), 1);
      expect(weakCalls, 1);
    });
  });

  group('arrays.ts (1:1 full)', () {
    test('tail / removeFast / binarySearch / quickSelect', () {
      expect(arr.tail(<int>[1, 2, 3]).rest, <int>[1, 2]);
      expect(arr.tail(<int>[1, 2, 3]).last, 3);
      expect(() => arr.tail(<int>[]), throwsStateError);
      final a = <int>[1, 2, 3, 4];
      arr.removeFastWithoutKeepingOrder(a, 1);
      expect(a, <int>[1, 4, 3]);
      final sorted = <int>[1, 3, 5, 7];
      expect(arr.binarySearch(sorted, 5, arr.numberComparator), 2);
      expect(arr.binarySearch(sorted, 4, arr.numberComparator), -3);
      expect(arr.binarySearch2(4, (int i) => sorted[i] - 6), -4);
      expect(arr.quickSelect(2, <int>[9, 1, 5, 3, 7], arr.numberComparator), 5);
    });

    test('groupBy / groupAdjacentBy / adjacent helpers', () {
      expect(arr.groupBy(<int>[1, 2, 2, 3], arr.numberComparator),
          <List<int>>[<int>[1], <int>[2, 2], <int>[3]]);
      final grouped = arr.groupAdjacentBy<String>(
          ['a', 'a', 'b', 'b', 'a'], (String x, String y) => x == y);
      expect(grouped.toList(), <List<String>>[
        <String>['a', 'a'],
        <String>['b', 'b'],
        <String>['a']
      ]);
      final adjacent = <List<Object?>>[];
      arr.forEachAdjacent<int>([1, 2],
          (Object? a, Object? b) => adjacent.add(<Object?>[a, b]));
      expect(adjacent, <List<Object?>>[
        <Object?>[null, 1],
        <Object?>[1, 2],
        <Object?>[2, null]
      ]);
      final neighbors = <List<Object?>>[];
      arr.forEachWithNeighbors<int>([1, 2, 3],
          (Object? b, int e, Object? a) => neighbors.add(<Object?>[b, e, a]));
      expect(neighbors[0], <Object?>[null, 1, 2]);
      expect(neighbors[2], <Object?>[2, 3, null]);
      expect(arr.concatArrays<int>([
        <int>[1],
        <int>[2, 3]
      ]), <int>[1, 2, 3]);
    });

    test('sortedDiff / delta / top / topAsync', () async {
      final splices = arr.sortedDiff<int>(
          [1, 2, 4], [1, 3, 4], arr.numberComparator);
      // Source merges adjacent splices: delete 2 at 1 and insert 3 at 2.
      expect(splices.length, 1);
      expect(splices.first.start, 1);
      expect(splices.first.deleteCount, 1);
      expect(splices.first.toInsert, <int>[3]);
      final d = arr.delta<int>([1, 2, 4], [1, 3, 4], arr.numberComparator);
      expect(d.removed, <int>[2]);
      expect(d.added, <int>[3]);
      expect(arr.top<int>([5, 1, 9, 3], arr.numberComparator, 2), <int>[1, 3]);
      final cancellation.CancellationTokenSource cts =
          cancellation.CancellationTokenSource();
      expect(await arr.topAsync<int>(
          [5, 1, 9, 3], arr.numberComparator, 2, 1, cts.token), <int>[1, 3]);
      cts.cancel();
      expect(() => arr.topAsync<int>(
          [5, 1], arr.numberComparator, 1, 1, cts.token), throwsA(isA<dynamic>()));
    });

    test('coalesce / distinct / range / index / insert-remove', () {
      expect(arr.coalesce<int>(<int?>[1, null, 0, 2]), <int>[1, 2]);
      final inplace = <int?>[1, null, 0, 2];
      arr.coalesceInPlace<int>(inplace);
      expect(inplace, <int>[1, 2]);
      final moved = <Object?>[1, 2, 3];
      arr.move(moved, 0, 2);
      expect(moved, <Object?>[2, 3, 1]);
      expect(arr.isFalsyOrEmpty(<int>[]), isTrue);
      expect(arr.isFalsyOrEmpty(<int>[1]), isFalse);
      expect(arr.isNonEmptyArray(<int>[1]), isTrue);
      expect(arr.distinct<int>([1, 2, 1, 3]), <int>[1, 2, 3]);
      final unique = arr.uniqueFilter<int, int>((int x) => x % 2);
      expect([1, 2, 3, 4].where(unique).toList(), <int>[1, 2]);
      expect(arr.commonPrefixLength<int>([1, 2, 3], [1, 2, 4]), 2);
      expect(arr.range(3), <int>[0, 1, 2]);
      expect(arr.range(3, 1), <int>[3, 2]);
      expect(arr.index<String, int>(['a', 'bb'], (String s) => s, (String s) => s.length),
          <String, Object?>{'a': 1, 'bb': 2});
      final list = <int>[1, 2];
      final undo = arr.insert(list, 3);
      expect(list, <int>[1, 2, 3]);
      undo();
      expect(list, <int>[1, 2]);
      expect(arr.remove(list, 1), 1);
      expect(arr.arrayInsert<int>([1, 4], 1, [2, 3]), <int>[1, 2, 3, 4]);
    });

    test('shuffle / push / map / splice helpers', () {
      final a = <int>[1, 2, 3, 4];
      arr.shuffle(a, 42);
      expect(a.length, 4);
      final b = <int>[1, 2, 3];
      arr.pushToStart(b, 3);
      expect(b, <int>[3, 1, 2]);
      arr.pushToEnd(b, 3);
      expect(b, <int>[1, 2, 3]);
      arr.pushMany(b, [4, 5]);
      expect(b, <int>[1, 2, 3, 4, 5]);
      expect(arr.mapArrayOrNot<int, int>(3, (int x) => x * 2), 6);
      expect(arr.mapArrayOrNot<int, int>([3, 4], (int x) => x * 2), <int>[6, 8]);
      expect(arr.mapFilter<int, int>([1, 2, 3], (int x) => x.isEven ? x : null),
          <int>[2]);
      expect(arr.withoutDuplicates<int>([1, 2, 1]), <int>[1, 2]);
      expect(arr.asArray<int>(1), <int>[1]);
      expect(arr.asArray<int>([1, 2]), <int>[1, 2]);
      expect(arr.getRandomElement<int>(<int>[]), isNull);
      final c = <int>[1, 2, 3];
      arr.insertInto(c, 1, [8, 9]);
      expect(c, <int>[1, 8, 9, 2, 3]);
      expect(arr.splice(c, 1, 2, [7]), <int>[8, 9]);
      expect(c, <int>[1, 7, 2, 3]);
    });

    test('comparators / ArrayQueue / CallbackIterable / Permutation', () async {
      expect(arr.compareResultIsLessThan(-1), isTrue);
      expect(arr.compareResultIsGreaterThan(1), isTrue);
      expect(arr.compareResultIsNeitherLessOrGreaterThan(0), isTrue);
      final tie = arr.tieBreakComparators<int>([
        (int a, int b) => a.compareTo(b),
        (int a, int b) => -a.compareTo(b),
      ]);
      expect(tie(1, 2), -1);
      expect(tie(1, 1), 0);
      expect(arr.reverseOrder<int>(arr.numberComparator)(1, 2), 1);
      final undef = arr.compareUndefinedSmallest<int>(arr.numberComparator);
      expect(undef(null, 1), -1);
      expect(undef(1, null), 1);
      expect(arr.booleanComparator(false, true), -1);

      final q = arr.ArrayQueue<int>([1, 2, 3, 4]);
      expect(q.length, 4);
      expect(q.peek(), 1);
      expect(q.takeWhile((int x) => x < 3), <int>[1, 2]);
      expect(q.peek(), 3);
      expect(q.peekLast(), 4);
      expect(q.takeFromEndWhile((int x) => x > 3), <int>[4]);
      final q2 = arr.ArrayQueue<int>([1, 2, 3, 4]);
      expect(q2.dequeue(), 1);
      expect(q2.removeLast(), 4);
      expect(q2.takeCount(2), <int>[2, 3]);
      expect(q2.length, 0);

      final ci = arr.CallbackIterable<int>((bool Function(int item) cb) {
        for (int i = 1; i <= 4; i++) {
          if (!cb(i)) return;
        }
      });
      expect(ci.toArray(), <int>[1, 2, 3, 4]);
      expect(ci.filter((int x) => x.isEven).toArray(), <int>[2, 4]);
      expect(ci.map((int x) => x * 2).toArray(), <int>[2, 4, 6, 8]);
      expect(ci.some((int x) => x == 3), isTrue);
      expect(ci.findFirst((int x) => x > 2), 3);
      expect(ci.findLast((int x) => x.isEven), 4);
      expect(ci.findLastMaxBy(arr.numberComparator), 4);
      expect(arr.CallbackIterable.empty.toArray(), isEmpty);

      final p = arr.Permutation.createSortPermutation<int>(
          [3, 1, 2], arr.numberComparator);
      expect(p.apply([3, 1, 2]), <int>[1, 2, 3]);
      expect(p.inverse().apply([1, 2, 3]), <int>[3, 1, 2]);
      expect(await arr.findAsync<int>([1, 2, 3], (int e, int i) async => e == 2), 2);
      expect(arr.sum(<num>[1, 2, 3]), 6);
      expect(arr.sumBy<int>([1, 2], (int x) => x * 3), 9);
    });
  });

  group('history.ts (1:1)', () {
    test('create reduces input to limit and navigates', () {
      final hist.HistoryNavigator<String> h =
          hist.HistoryNavigator<String>(_TestHistory({'1', '2', '3', '4'}), 2);
      expect(h.getHistory(), <String>['3', '4']);
      expect(h.current(), isNull);
      expect(h.isNowhere(), isTrue);
      expect(h.next(), isNull);
      expect(h.previous(), '4');
      expect(h.isLast(), isTrue);
      expect(h.first(), '3');
      expect(h.isFirst(), isTrue);
      expect(h.next(), '4');
      expect(h.next(), isNull);
      expect(h.isLast(), isFalse); // stepped past last
    });

    test('add reorders and clear resets', () {
      final hist.HistoryNavigator<String> h =
          hist.HistoryNavigator<String>(_TestHistory({'1', '2', '3'}));
      h.add('1');
      expect(h.getHistory(), <String>['2', '3', '1']);
      h.add('4');
      expect(h.getHistory(), <String>['2', '3', '1', '4']);
      expect(h.has('4'), isTrue);
      h.clear();
      expect(h.current(), isNull);
      expect(h.isNowhere(), isTrue);
    });

    test('HistoryNavigator2: navigation, dedup, replaceLast, prepend', () {
      final hist.HistoryNavigator2<String> h =
          hist.HistoryNavigator2<String>(['1', '2', '3', '4']);
      expect(h.current(), '4');
      expect(h.isAtEnd(), isTrue);
      expect(h.next(), '4');
      expect(h.previous(), '3');
      expect(h.previous(), '2');
      expect(h.previous(), '1');
      expect(h.previous(), '1');
      expect(h.resetCursor(), '4');

      h.add('2');
      expect(h.current(), '2');
      expect(h.previous(), '4');
      expect(h.previous(), '3');
      expect(h.previous(), '1');

      h.resetCursor(); // source replaceLast does not move the cursor
      expect(h.replaceLast('5'), '2');
      expect(h.current(), '5');
      expect(h.has('2'), isFalse);
      h.prepend('0');
      expect(h.toList(), <String>['0', '1', '3', '4', '5']);
      h.prepend('3'); // duplicate — ignored
      expect(h.toList(), <String>['0', '1', '3', '4', '5']);
    });

    test('capacity + identityFn + onDidChange subscription', () {
      final hist.HistoryNavigator2<String> h =
          hist.HistoryNavigator2<String>(['1', '2', '3', '4'], 3,
              (String s) => s.toLowerCase());
      expect(h.size, 3);
      expect(h.has('1'), isFalse);
      expect(h.has('2'), isTrue);

      final ev.Emitter<List<String>> emitter = ev.Emitter<List<String>>();
      final _TestHistory notify = _TestHistory({'a'}, emitter.event);
      int changes = 0;
      final lc.IDisposable ownSub = emitter.event((dynamic _) => changes++);
      final hist.HistoryNavigator<String> nav =
          hist.HistoryNavigator<String>(notify, 10);
      emitter.fire(<String>['x']);
      expect(changes, 1);
      nav.dispose();
      ownSub.dispose();
      emitter.fire(<String>['y']);
      expect(changes, 1);
    });
  });

  group('actions.ts (1:1)', () {
    test('getActionForAltMode', () {
      final alt = actions.Action('alt', 'alt');
      final main = _ActionWithAlt(alt);
      expect(identical(actions.getActionForAltMode(main, (altKey: false, shiftKey: false)), main), isTrue);
      expect(identical(actions.getActionForAltMode(main, (altKey: true, shiftKey: false)), alt), isTrue);
      if (pf.isWindows || pf.isLinux) {
        expect(identical(
            actions.getActionForAltMode(main, (altKey: false, shiftKey: true)), alt), isTrue);
      } else {
        expect(identical(
            actions.getActionForAltMode(main, (altKey: false, shiftKey: true)), main), isTrue);
      }
    });

    test('Action emits changes and runs callback', () async {
      Object? received;
      final actions.Action action = actions.Action(
          'id', 'label', 'css', true, (Object? e) async {
        received = e;
      });
      final List<actions.IActionChangeEvent> changes = <actions.IActionChangeEvent>[];
      action.onDidChange((dynamic e) => changes.add(e as actions.IActionChangeEvent));
      action.label = 'new';
      action.enabled = false;
      action.checked = true;
      expect(changes.map((actions.IActionChangeEvent e) => e.label), <Object?>[
        'new', null, null
      ]);
      expect(changes[1].enabled, false);
      expect(changes[2].checked, true);
      await action.run(42);
      expect(received, 42);
    });

    test('ActionRunner will/did run and captures error', () async {
      final runner = actions.ActionRunner();
      final actions.IAction good = actions.Action('g', '', '', true, (Object? _) async {});
      final actions.IAction bad = actions.Action('b', '', '', true, (Object? _) async {
        throw StateError('boom');
      });
      final List<String> log = <String>[];
      runner.onWillRun((dynamic e) => log.add('will:${(e as actions.IRunEvent).action.id}'));
      runner.onDidRun((dynamic e) {
        final actions.IRunEvent ev = e as actions.IRunEvent;
        log.add('did:${ev.action.id}:${ev.error != null}');
      });
      await runner.run(good);
      await runner.run(bad);
      expect(log, <String>['will:g', 'did:g:false', 'will:b', 'did:b:true']);
    });

    test('Separator join/clean, SubmenuAction, toAction', () {
      final a = actions.Action('a');
      final b = actions.Action('b');
      final joined = actions.Separator.join([
        <actions.IAction>[a],
        <actions.IAction>[b],
      ]);
      expect(joined.length, 3);
      expect(joined[1].id, actions.Separator.ID);
      final cleaned = actions.Separator.clean(<actions.IAction>[
        actions.Separator(),
        a,
        actions.Separator(),
        actions.Separator(),
        b,
        actions.Separator(),
      ]);
      expect(cleaned.map((actions.IAction x) => x.id), <String>['a', actions.Separator.ID, 'b']);

      final sub = actions.SubmenuAction('s', 'sub', [a]);
      expect(sub.actions.length, 1);
      expect(actions.EmptySubmenuAction().label, '(empty)');

      final converted = actions.toAction(actions.ActionProps(
        id: 'x',
        label: 'X',
        run: (Object? v) => v,
      ));
      expect(converted.tooltip, 'X');
      expect(converted.enabled, isTrue);
      expect(converted.run(7), 7);
    });
  });

  group('stream.ts (1:1)', () {
    test('write buffers until data listener, reducer merges buffer', () async {
      final streams.WriteableStream<int> s =
          streams.newWriteableStream<int>((List<int> chunks) => chunks.fold<int>(0, (int a, int b) => a + b));
      expect(s.write(1), isNull);
      expect(s.write(2), isNull);
      final List<Object?> got = <Object?>[];
      bool ended = false;
      s.on('end', () => ended = true);
      s.on('data', (dynamic d) => got.add(d as int));
      expect(got, <Object?>[3]);
      s.end();
      expect(ended, isTrue);
    });

    test('highWaterMark resolves pending writes on flow', () async {
      final streams.WriteableStream<int> s = streams.newWriteableStream<int>(
          null, streams.WriteableStreamOptions(1));
      expect(s.write(1), isNull);
      final Future<void>? pending = s.write(2);
      expect(pending, isNotNull);
      bool resolved = false;
      pending!.then((_) => resolved = true);
      final List<int> got = <int>[];
      s.on('data', (dynamic d) => got.add(d as int));
      await pending;
      expect(resolved, isTrue);
      expect(got, <int>[1, 2]);
    });

    test('consumeStream / prefixedStream / toReadable / peekReadable', () async {
      final streams.WriteableStream<int> s = streams.newWriteableStream<int>(null);
      final Future<Object?> sum = streams.consumeStream<int>(
          s, (List<int> chunks) => chunks.fold<int>(0, (int a, int b) => a + b));
      s.write(1);
      s.write(2);
      s.end();
      expect(await sum, 3);

      final streams.WriteableStream<int> source = streams.newWriteableStream<int>(null);
      final streams.ReadableStream<int> prefixed = streams.prefixedStream<int>(
          0, source, (List<int> parts) => parts.fold<int>(0, (int a, int b) => a + b));
      final Future<Object?> prefixedSum = streams.consumeStream<int>(
          prefixed, (List<int> chunks) => chunks.fold<int>(0, (int a, int b) => a + b));
      source.write(1);
      source.write(2);
      source.end();
      expect(await prefixedSum, 3);

      final streams.Readable<int> readable = streams.toReadable<int>(7);
      expect(
          streams.consumeReadable<int>(
              readable, (List<int> chunks) => chunks.fold<int>(0, (int a, int b) => a + b)),
          7);
      final Object? peeked = streams.peekReadable<int>(
          streams.toReadable<int>(9),
          (List<int> chunks) => chunks.fold<int>(0, (int a, int b) => a + b),
          0);
      expect(peeked, isA<streams.PeekReadable<int>>());
      expect((peeked as streams.PeekReadable<int>).read(), 9);
      expect(peeked.read(), isNull);
    });
  });

  group('scrollable.ts (1:1)', () {
    test('ScrollState validates and coerces integers', () {
      final scroll.ScrollState s =
          scroll.ScrollState(false, 100, 300, 250, 50, 500, 480);
      expect(s.scrollLeft, 200);
      expect(s.scrollTop, 450);
      expect(s.rawScrollLeft, 250);

      final scroll.ScrollState f =
          scroll.ScrollState(true, 10.7, 30.9, 25.8, 5.2, 50.9, 48.8);
      expect(f.width, 10);
      expect(f.scrollWidth, 30);
      expect(f.rawScrollLeft, 25); // truncated, before validation
      expect(f.scrollLeft, 20);
      expect(f.scrollTop, 45);
      expect(f.withScrollPosition(scroll.NewScrollPosition()).rawScrollLeft, 25);
      expect(f.withScrollPosition(scroll.NewScrollPosition()).scrollLeft, 20);
    });

    test('Scrollable emits scroll events', () {
      final scroll.Scrollable s = scroll.Scrollable(scroll.ScrollableOptions(
        forceIntegerValues: false,
        smoothScrollDuration: 0,
        scheduleAtNextAnimationFrame: (void Function() cb) => lc.toDisposable(() {}),
      ));
      final List<scroll.ScrollEvent> events = <scroll.ScrollEvent>[];
      s.onScroll((dynamic e) => events.add(e as scroll.ScrollEvent));
      s.setScrollDimensions(
          scroll.NewScrollDimensions(width: 100, scrollWidth: 300, height: 50, scrollHeight: 500),
          false);
      expect(events.length, 1);
      expect(events.single.widthChanged, isTrue);
      s.setScrollPositionNow(scroll.NewScrollPosition(scrollLeft: 250, scrollTop: 480));
      expect(s.getCurrentScrollPosition().scrollLeft, 200);
      expect(events.last.scrollLeftChanged, isTrue);
      expect(s.hasPendingScrollAnimation(), isFalse);
    });

    test('smooth scrolling helpers', () {
      expect(scroll.easeInCubic(0.5), 0.125);
      expect(scroll.easeOutCubic(0.5), closeTo(0.875, 1e-12));
      final scroll.IAnimation a = scroll.createEaseOutCubic(0, 100);
      expect(a(0), 0);
      expect(a(1), 100);
      final scroll.IAnimation composed = scroll.createComposed(a, a, 0.5);
      expect(composed(0.5), 0.0);
    });
  });

  group('cancelPreviousCalls.ts (1:1)', () {
    test('appends token and cancels previous call', () async {
      final _Decorated obj = _Decorated();
      final canceldec.CancelPreviousCallsMethod decorated =
          canceldec.cancelPreviousCalls(obj, 'one', obj.one);
      await (decorated([1, 'foo']) as Future<void>);
      expect(obj.calls1.length, 1);
      final cancellation.CancellationToken first =
          obj.calls1[0][2] as cancellation.CancellationToken;
      expect(cancellation.CancellationToken.isCancellationToken(first), isTrue);
      expect(first.isCancellationRequested, isFalse);

      decorated([2, 'bar']);
      expect(obj.calls1.length, 2);
      expect(first.isCancellationRequested, isTrue);
      expect((obj.calls1[1][2] as cancellation.CancellationToken).isCancellationRequested, isFalse);

      decorated([3, 'baz']);
      expect(obj.calls2, isEmpty);
    });

    test('reuses trailing token as parent', () async {
      final _Decorated obj = _Decorated();
      final canceldec.CancelPreviousCallsMethod decorated =
          canceldec.cancelPreviousCalls(obj, 'two', obj.two);
      final cancellation.CancellationTokenSource parent =
          cancellation.CancellationTokenSource();
      decorated([1, 'x', parent.token]);
      expect(obj.calls2.length, 1);
      expect(obj.calls2[0].length, 3);
      parent.cancel();
      expect((obj.calls2[0][2] as cancellation.CancellationToken).isCancellationRequested, isTrue);
    });
  });

  group('paging.ts (1:1)', () {
    test('PagedModel resolves pages and dedups in-flight requests', () async {
      final pager = _TestPager([1, 2, 3, 4, 5, 6], 2);
      final paging.PagedModel<int> model = paging.PagedModel<int>(pager);
      expect(model.length, 6);
      expect(model.isResolved(0), isTrue);
      expect(model.get(0), 1);
      expect(model.isResolved(4), isFalse);

      final cancellation.CancellationTokenSource cts =
          cancellation.CancellationTokenSource();
      // index 4 is page 2 -> fetch second page (indices 2..3 in pager page index 1? page size 2 -> page 2 = values[4..5])
      final int v4 = await model.resolve(4, cts.token);
      expect(v4, 5);
      expect(model.isResolved(5), isTrue);
      expect(model.get(5), 6);
      expect(pager.getPageCalls, 1); // single fetch served the whole page

      // resolved page returns synchronously without another fetch
      expect(await model.resolve(4, cts.token), 5);
      expect(pager.getPageCalls, 1);
    });

    test('PagedModel rejects already-cancelled token', () async {
      final paging.PagedModel<int> model =
          paging.PagedModel<int>(<int>[1, 2]);
      final cancellation.CancellationTokenSource cts =
          cancellation.CancellationTokenSource();
      cts.cancel();
      await expectLater(model.resolve(0, cts.token),
          throwsA(isA<CancellationError>()));
    });

    test('DelayedPagedModel delays then delegates', () async {
      final paging.PagedModel<int> model =
          paging.PagedModel<int>(<int>[10, 20]);
      final paging.DelayedPagedModel<int> delayed =
          paging.DelayedPagedModel<int>(model, 1);
      final cancellation.CancellationTokenSource cts =
          cancellation.CancellationTokenSource();
      expect(await delayed.resolve(1, cts.token), 20);
      expect(delayed.length, 2);
    });

    test('mapPager maps across pages', () async {
      final pager = _TestPager([1, 2, 3, 4], 2);
      final paging.IPager<String> mapped =
          paging.mapPager<int, String>(pager, (int x) => 'v$x');
      expect(mapped.firstPage, <String>['v1', 'v2']);
      expect(mapped.total, 4);
      final cancellation.CancellationTokenSource cts =
          cancellation.CancellationTokenSource();
      expect(await mapped.getPage(1, cts.token), <String>['v3', 'v4']);
    });

    test('IterativePagedModel sentinel loads next page and fires event', () async {
      final iterative = _TestIterativePager();
      final paging.IterativePagedModel<int> model =
          paging.IterativePagedModel<int>(iterative);
      expect(model.length, 3); // 2 items + sentinel
      expect(model.isResolved(2), isFalse);
      final List<num> lengths = <num>[];
      model.onDidIncrementLength((dynamic n) => lengths.add(n as num));
      final cancellation.CancellationTokenSource cts =
          cancellation.CancellationTokenSource();
      expect(await model.resolve(2, cts.token), 3);
      expect(model.length, 3); // 3 items, no more pages
      expect(lengths, <num>[3]);
      expect(iterative.getNextPageCalls, 1);
      model.dispose();
    });
  });

  group('decorators.ts (1:1)', () {
    test('memoize caches per instance', () {
      final counter = _MemoTarget();
      final decorators.DecoratedMethod wrapped =
          decorators.memoize(counter, 'value', counter.compute);
      expect(wrapped([]), 1);
      expect(wrapped([]), 1);
      expect(counter.calls, 1);
    });

    test('debounce coalesces with reducer and resets after fire', () async {
      final target = _SumTarget();
      final decorators.DecoratorFactory factory = decorators.debounce<int>(
        5,
        reducer: (int prev, List<Object?> args) =>
            prev + (args[0] as int),
        initialValueProvider: () => 0,
      );
      final decorators.DecoratedMethod wrapped =
          factory(target, 'add', target.add);
      wrapped([1]);
      wrapped([2]);
      wrapped([3]);
      expect(target.sum, 0); // not fired yet
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(target.sum, 6);
      expect(target.lastArg, 6); // reducer result forwarded
    });
  });

  group('buffer.ts (1:1)', () {
    test('fromString/toString round trips UTF-8 incl BOM', () {
      const String s = '\uFEFFc.txt';
      final buffer.VSBuffer b = buffer.VSBuffer.fromString(s);
      expect(b.toString(), s);
      expect(b.toString().codeUnitAt(0), 0xFEFF);
      expect(buffer.VSBuffer.fromString('hi').toString(), 'hi');
    });

    test('wrap slice preserves bytes; concat/clone/equals', () {
      final buffer.VSBuffer b =
          buffer.VSBuffer.fromByteArray([1, 2, 104, 105, 4, 5]);
      expect(b.slice(2, 4).toString(), 'hi');
      final buffer.VSBuffer a = buffer.VSBuffer.fromByteArray([1, 2]);
      final buffer.VSBuffer c = buffer.VSBuffer.fromByteArray([3, 4]);
      expect(buffer.VSBuffer.concat([a, c]).buffer, <int>[1, 2, 3, 4]);
      expect(a.clone().equals(a), isTrue);
      expect(a.equals(c), isFalse);
      expect(a.indexOf(c), -1);
      expect(b.indexOf(buffer.VSBuffer.fromByteArray([104, 105])), 2);
    });

    test('read/write UInt32 BE/LE and UInt8', () {
      final buffer.VSBuffer b = buffer.VSBuffer.alloc(8);
      b.writeUInt32BE(0x12345678, 0);
      expect(buffer.readUInt32BE_(b.buffer, 0), 0x12345678);
      b.writeUInt32LE(0x12345678, 4);
      expect(buffer.readUInt32LE_(b.buffer, 4), 0x12345678);
      b.writeUInt8(200, 7);
      expect(buffer.readUInt8_(b.buffer, 7), 200);
    });

    test('base64 and hex encode/decode match source vectors', () {
      final cases = <List<Object>>[
        <Object>[<int>[1, 2, 3], 'AQID', '010203'],
        <Object>[
          <int>[184, 227, 214, 171, 244, 175, 141, 53],
          'uOPWq/SvjTU=',
          'b8e3d6abf4af8d35'
        ],
        <Object>[
          <int>[53, 98, 93, 130, 71, 117, 191, 137, 156],
          'NWJdgkd1v4mc',
          '35625d824775bf899c'
        ],
      ];
      for (final c in cases) {
        final buffer.VSBuffer b = buffer.VSBuffer.fromByteArray(c[0] as List<int>);
        expect(buffer.encodeBase64(b), c[1]);
        expect(buffer.encodeHex(b), c[2]);
        expect(buffer.decodeBase64(c[1] as String).buffer, c[0]);
        expect(buffer.decodeHex(c[2] as String).buffer, c[0]);
      }
      // padded/url-safe variants
      final buffer.VSBuffer payload =
          buffer.VSBuffer.fromByteArray(<int>[251, 255, 254]);
      expect(buffer.encodeBase64(payload, true, false), '+//+');
      expect(buffer.encodeBase64(payload, true, true), '-__-');
      expect(buffer.decodeBase64('+//+').buffer, <int>[251, 255, 254]);
      expect(buffer.decodeBase64('-__-').buffer, <int>[251, 255, 254]);
      expect(() => buffer.decodeBase64('invalid!'), throwsA(isA<FormatException>()));
      expect(() => buffer.decodeHex('abc'), throwsA(isA<FormatException>()));
    });

    test('binaryIndexOf boyer-moore-horspool', () {
      final buffer.VSBuffer hay = buffer.VSBuffer.fromString('hello world');
      final buffer.VSBuffer needle = buffer.VSBuffer.fromString('world');
      expect(hay.indexOf(needle), 6);
      expect(hay.indexOf(buffer.VSBuffer.fromString('xyz')), -1);
      expect(hay.indexOf(buffer.VSBuffer.fromString(''), 0), 0);
    });

    test('bufferToReadable/readableToBuffer and bufferToStream/streamToBuffer',
        () async {
      final buffer.VSBuffer b = buffer.VSBuffer.fromString('Hello World');
      expect(buffer.readableToBuffer(buffer.bufferToReadable(b)).toString(),
          'Hello World');
      expect((await buffer.streamToBuffer(buffer.bufferToStream(b))).toString(),
          'Hello World');
    });
  });

  group('linkedText.ts (1:1)', () {
    test('parses text, links, titles and non-links', () {
      expect(linkedText.parseLinkedText('').nodes, isEmpty);
      expect(linkedText.parseLinkedText('hello').nodes, ['hello']);
      expect(linkedText.parseLinkedText('hello there').nodes, ['hello there']);
      final l = linkedText.parseLinkedText(
          'Some message with [link text](http://link.href).');
      expect(l.nodes.length, 3);
      expect(l.nodes[0], 'Some message with ');
      expect(l.nodes[1], isA<linkedText.ILink>());
      expect((l.nodes[1] as linkedText.ILink).label, 'link text');
      expect((l.nodes[1] as linkedText.ILink).href, 'http://link.href');
      expect(l.nodes[2], '.');
      expect(l.toString(), 'Some message with link text.');
    });

    test('parses quoted titles (single and double), including opposite quote', () {
      final a = linkedText.parseLinkedText(
          '[link](http://link.href "and a title")');
      expect((a.nodes.single as linkedText.ILink).title, 'and a title');
      final b = linkedText.parseLinkedText(
          "[link](http://link.href 'and a title')");
      expect((b.nodes.single as linkedText.ILink).title, 'and a title');
      final c = linkedText.parseLinkedText(
          "[link](http://link.href 'and a \"title\"')");
      expect((c.nodes.single as linkedText.ILink).title, 'and a "title"');
      final d = linkedText.parseLinkedText(
          '[link](http://link.href "and a \'title\'")');
      expect((d.nodes.single as linkedText.ILink).title, "and a 'title'");
    });

    test('rejects non-url hrefs and scheme-only urls; matches command/file/https', () {
      expect(linkedText.parseLinkedText('[x](random stuff)').nodes,
          ['[x](random stuff)']);
      expect(linkedText.parseLinkedText('[x](https:)').nodes, ['[x](https:)']);
      expect((linkedText.parseLinkedText('[x](command:foo)').nodes.single
              as linkedText.ILink)
          .href, 'command:foo');
      expect((linkedText.parseLinkedText('[x](file:///a)').nodes.single
              as linkedText.ILink)
          .href, 'file:///a');
      expect((linkedText.parseLinkedText('[x](https://a.b)').nodes.single
              as linkedText.ILink)
          .href, 'https://a.b');
    });

    test('matches non-greedily across multiple links', () {
      final l = linkedText.parseLinkedText(
          'a [one](http://a "t1") b [two](http://b "t2") c');
      expect(l.nodes.length, 5);
      expect(l.nodes[0], 'a ');
      expect((l.nodes[1] as linkedText.ILink).label, 'one');
      expect((l.nodes[1] as linkedText.ILink).title, 't1');
      expect(l.nodes[2], ' b ');
      expect((l.nodes[3] as linkedText.ILink).label, 'two');
      expect(l.nodes[4], ' c');
    });
  });

  group('marshalling.ts (1:1)', () {
    test('RegExp round trips source and flags', () {
      final Object? raw = marshalling.parse(marshalling.stringify(RegExp(
          'foo', caseSensitive: false, multiLine: true)));
      expect(raw, isA<RegExp>());
      final RegExp clone = raw as RegExp;
      expect(clone.pattern, 'foo');
      expect(clone.isCaseSensitive, isFalse);
      expect(clone.isMultiLine, isTrue);
    });

    test('URI round trips all components', () {
      final URI value = URI.from(UriComponents(
        scheme: 'file',
        authority: 'server',
        path: '/shares/c#files',
        query: 'q',
        fragment: 'f',
      ));
      final URI clone = marshalling.parse(marshalling.stringify(value));
      expect(clone.scheme, 'file');
      expect(clone.authority, 'server');
      expect(clone.path, '/shares/c#files');
      expect(clone.query, 'q');
      expect(clone.fragment, 'f');
    });

    test('Bug 16793: # in folder name survives round trip', () {
      final URI uri1 = URI.file('C:\\C#\\file.txt');
      expect(marshalling.parse(marshalling.stringify(uri1)).toString(),
          uri1.toString());
    });
  });

  group('errorMessage.ts (1:1)', () {
    test('toErrorMessage handles string, null and default', () {
      setNlsMessages(null);
      expect(errorMessage.toErrorMessage('oops'), 'oops');
      expect(errorMessage.toErrorMessage(null),
          'An unknown error occurred. Please consult the log for more details.');
    });

    test('toErrorMessage array joins with count', () {
      setNlsMessages(null);
      expect(errorMessage.toErrorMessage(['a', 'b', null]),
          'a (2 errors in total)');
      expect(errorMessage.toErrorMessage(['only']), 'only');
    });

    test('toErrorMessage reads .message and .detail', () {
      setNlsMessages(null);
      expect(errorMessage.toErrorMessage(_MsgErr('boom')), 'boom');
      final Object withDetail = _DetailErr(_DetailInner(_MsgErr('inner')));
      expect(errorMessage.toErrorMessage(withDetail), 'inner');
    });

    test('createErrorWithActions / isErrorWithActions', () {
      final e = errorMessage.createErrorWithActions('hi', <actions.IAction>[]);
      expect(e.message, 'hi');
      expect(errorMessage.isErrorWithActions(e), isTrue);
      expect(errorMessage.isErrorWithActions('not an error'), isFalse);
    });
  });

  group('textLength.ts (1:1)', () {
    String fmt(textLength.TextLength t) => '${t.lineCount},${t.columnCount}';

    test('ofText counts UTF-16 code units', () {
      expect(fmt(textLength.TextLength.ofText('')), '0,0');
      expect(fmt(textLength.TextLength.ofText('abc')), '0,3');
      expect(fmt(textLength.TextLength.ofText('😀')), '0,2');
      expect(fmt(textLength.TextLength.ofText('a😀𝄞b')), '0,6');
      expect(fmt(textLength.TextLength.ofText('e\u0301')), '0,2');
      expect(fmt(textLength.TextLength.ofText('\ud83d')), '0,1');
      expect(fmt(textLength.TextLength.ofText('\ude00')), '0,1');
    });

    test('ofText counts UTF-16 columns after the last newline', () {
      expect(fmt(textLength.TextLength.ofText('😀\nx')), '1,1');
      expect(fmt(textLength.TextLength.ofText('x\n😀𝄞')), '1,4');
      expect(fmt(textLength.TextLength.ofText('😀\n𝄞\n')), '2,0');
    });

    test('comparison, add and toString', () {
      final a = textLength.TextLength(1, 2);
      final b = textLength.TextLength(1, 3);
      expect(a.isLessThan(b), isTrue);
      expect(b.isGreaterThan(a), isTrue);
      expect(a.isGreaterThanOrEqualTo(a), isTrue);
      expect(a.equals(textLength.TextLength(1, 2)), isTrue);
      expect(a.compare(b), -1);
      expect(a.add(b).lineCount, 2); // other.lineCount != 0 -> adds lines
      expect(a.add(textLength.TextLength(0, 4)).columnCount, 6);
      expect(a.toString(), '1,2');
      expect(textLength.TextLength.zero.isZero(), isTrue);
    });

    test('lengthDiffNonNegative and betweenPositions', () {
      final start = textLength.TextLength(1, 5);
      final end = textLength.TextLength(3, 2);
      final diff = textLength.TextLength.lengthDiffNonNegative(start, end);
      expect(diff.lineCount, 2);
      expect(diff.columnCount, 2);
      expect(textLength.TextLength.lengthDiffNonNegative(end, start).isZero(),
          isTrue);
      final t = textLength.TextLength.betweenPositions(
          Position(2, 3), Position(4, 7));
      expect(t.lineCount, 2);
      expect(t.columnCount, 6);
    });
  });

  group('semanticTokensDto.ts (1:1)', () {
    Uint32List u32(List<int> v) => Uint32List.fromList(v);
    List<int> toList(Uint32List a) => List<int>.from(a);

    test('full encoding round trip', () {
      final dto = semTok.IFullSemanticTokensDto(
          12, u32([(1 << 24) + (2 << 16) + (3 << 8) + 4]));
      final decoded = semTok.decodeSemanticTokensDto(
          semTok.encodeSemanticTokensDto(dto));
      expect(decoded, isA<semTok.IFullSemanticTokensDto>());
      final d = decoded as semTok.IFullSemanticTokensDto;
      expect(d.id, 12);
      expect(toList(d.data), toList(dto.data));
    });

    test('delta encoding round trip', () {
      final v = u32([(1 << 24) + (2 << 16) + (3 << 8) + 4]);
      final dto = semTok.IDeltaSemanticTokensDto(12, [
        semTok.SemanticTokensDelta(0, 4),
        semTok.SemanticTokensDelta(15, 0, v),
        semTok.SemanticTokensDelta(
            27, 5, u32([(1 << 24) + (2 << 16) + (3 << 8) + 4, 1, 2, 3, 4, 5, 6, 7, 8, 9])),
      ]);
      final decoded = semTok.decodeSemanticTokensDto(
          semTok.encodeSemanticTokensDto(dto)) as semTok.IDeltaSemanticTokensDto;
      expect(decoded.id, 12);
      expect(decoded.deltas.length, 3);
      expect(decoded.deltas[0].start, 0);
      expect(decoded.deltas[0].deleteCount, 4);
      expect(decoded.deltas[0].data, isNull);
      expect(toList(decoded.deltas[1].data!), toList(v));
      expect(decoded.deltas[2].data!.length, 10);
    });

    test('partial / misaligned backing buffer (issue #94521)', () {
      final dto = semTok.IFullSemanticTokensDto(5, u32([1, 2, 3, 4, 5]));
      final encoded = semTok.encodeSemanticTokensDto(dto);
      for (final p in [1, 4]) {
        for (final s in [1, 4]) {
          final padded = Uint8List(p + encoded.buffer.length + s);
          padded.setAll(p, encoded.buffer);
          final sliced = Uint8List.sublistView(padded, p, p + encoded.buffer.length);
          final decoded = semTok.decodeSemanticTokensDto(
              buffer.VSBuffer.wrap(sliced)) as semTok.IFullSemanticTokensDto;
          expect(decoded.id, 5);
          expect(toList(decoded.data), [1, 2, 3, 4, 5]);
        }
      }
    });
  });

  group('strings.ts (1:1)', () {
    test('equals / equalsIgnoreCase / startsWithIgnoreCase / endsWithIgnoreCase', () {
      expect(strings.equalsIgnoreCase('', ''), isTrue);
      expect(strings.equalsIgnoreCase('abc', 'ABC'), isTrue);
      expect(strings.equalsIgnoreCase('Höhenmeter', 'HÖhenmeter'), isTrue);
      expect(strings.equalsIgnoreCase('ÖL', 'Öl'), isTrue);
      expect(strings.equals(null, 'abc'), isFalse);
      expect(strings.equals(null, null), isTrue);
      expect(strings.equals('abc', 'ABC', true), isTrue);
      expect(strings.equals('ÖL', 'Öl', true), isTrue);
      expect(strings.startsWithIgnoreCase('alles klar', 'ALLES K'), isTrue);
      expect(strings.startsWithIgnoreCase('alles klar', ' ALLES K'), isFalse);
      expect(strings.endsWithIgnoreCase('alles klar', 'S KLAR'), isTrue);
      expect(strings.endsWithIgnoreCase('alles klar', 'S KLAR '), isFalse);
    });

    test('compareIgnoreCase and compareSubstringIgnoreCase', () {
      int sign(int v) => v > 0 ? 1 : (v < 0 ? -1 : 0);
      expect(sign(strings.compareIgnoreCase('abc', 'ABC')), 0);
      expect(sign(strings.compareIgnoreCase('B', 'a')), 1);
      expect(sign(strings.compareIgnoreCase('a', 'B')), -1);
      expect(sign(strings.compareIgnoreCase('foo', 'föo')),
          sign('foo'.toLowerCase().compareTo('föo'.toLowerCase())));
      expect(
          sign(strings.compareSubstringIgnoreCase('abcABc', 'ABcd', 3, 6, 0, 4)),
          sign('ABc'.toLowerCase().compareTo('ABcd'.toLowerCase())));
    });

    test('format / format2', () {
      expect(strings.format('Foo Bar'), 'Foo Bar');
      expect(strings.format('Foo {0} Bar'), 'Foo {0} Bar');
      expect(strings.format('Foo {0} Bar {0}', ['yes']), 'Foo yes Bar yes');
      expect(strings.format('Foo {0} Bar {1}{2}', ['yes', 5, false]),
          'Foo yes Bar 5false');
      expect(strings.format2('Foo {foo} Bar', {'foo': 'bar'}), 'Foo bar Bar');
      expect(strings.format2('Foo {foo} Bar {bar}', {'foo': 'bar'}),
          'Foo bar Bar {bar}');
    });

    test('lcut / rcut', () {
      expect(strings.lcut('foo bar', 0), '');
      expect(strings.lcut('foo bar', 1), 'bar');
      expect(strings.lcut('foo bar', 5), 'foo bar');
      expect(strings.lcut('foo bar', 1, '…'), '…bar');
      expect(strings.lcut('test string 0.1.2.3', 3, '…'), '…2.3');
      expect(strings.lcut('            a', 10), 'a');
      expect(strings.rcut('foo bar', 0), '');
      expect(strings.rcut('foo bar', 3), 'foo');
      expect(strings.rcut('foo bar', 7), 'foo bar');
      expect(strings.rcut('foo bar', 3, '…'), 'foo…');
      expect(strings.rcut('test string 0.1.2.3', 6, '…'), 'test…');
      expect(strings.rcut('a            ', 10), 'a');
    });

    test('escape / htmlAttributeEncodeValue / escapeControlAndFormatCharacters', () {
      expect(strings.escape('<foo>Hello</foo>'), '&lt;foo&gt;Hello&lt;/foo&gt;');
      expect(strings.htmlAttributeEncodeValue('<>&\'"'),
          '&lt;&gt;&amp;&apos;&quot;');
      expect(strings.escapeControlAndFormatCharacters(
          '/work/api\n\nWorking directory: /work/web'),
          '/work/api\\u{a}\\u{a}Working directory: /work/web');
      expect(strings.escapeControlAndFormatCharacters('root-\u202ea-toor\u200b\t\u2028'),
          'root-\\u{202e}a-toor\\u{200b}\\u{9}\\u{2028}');
    });

    test('ltrim / rtrim / trim / lastNonWhitespaceIndex', () {
      expect(strings.ltrim('foo', 'f'), 'oo');
      expect(strings.ltrim('http://www.test.de', 'http://'), 'www.test.de');
      expect(strings.ltrim('------hello', '---'), 'hello');
      expect(strings.rtrim('foo', 'o'), 'f');
      expect(strings.rtrim('http://www.test.de', '.de'), 'http://www.test');
      expect(strings.rtrim('hello---------', '---'), 'hello');
      expect(strings.rtrim('path/to/file///', '//'), 'path/to/file/');
      expect(strings.trim(' foo '), 'foo');
      expect(strings.trim('foo bar', 'bar'), 'foo ');
      expect(strings.lastNonWhitespaceIndex('abc  \t \t '), 2);
      expect(strings.lastNonWhitespaceIndex('  \t \t '), -1);
      expect(strings.lastNonWhitespaceIndex('abc  \t \t abc \t \t ', 8), 2);
    });

    test('containsRTL / isEmojiImprecise / isFullWidthCharacter / isBasicASCII', () {
      expect(strings.containsRTL('hello world!'), isFalse);
      expect(strings.containsRTL('هناك حقيقة مثبتة منذ زمن طويل'), isTrue);
      expect(strings.containsRTL('זוהי עובדה מבוססת שדעתו'), isTrue);
      expect(strings.isEmojiImprecise(
          strings.getNextCodePoint('⭐', '⭐'.length, 0)), isTrue);
      expect(strings.isFullWidthCharacter('Ａ'.codeUnitAt(0)), isTrue);
      expect(strings.isBasicASCII(' \t\n\r~'), isTrue);
      expect(strings.isBasicASCII('ä'), isFalse);
    });

    test('createRegExp / getLeadingWhitespace / fuzzyContains', () {
      final re = strings.createRegExp('foo', false, strings.RegExpOptions());
      expect(re.hasMatch('Foo'), isTrue);
      expect(strings.createRegExp('a.c', false).hasMatch('a.c'), isTrue);
      expect(strings.createRegExp('a.c', true).hasMatch('abc'), isTrue);
      expect(strings.getLeadingWhitespace('  foo'), '  ');
      expect(strings.getLeadingWhitespace('  foo', 0, 1), ' ');
      expect(strings.fuzzyContains('hello world', 'hw'), isTrue);
      expect(strings.fuzzyContains('hello world', 'wh'), isFalse);
      expect(strings.fuzzyContains('\u0130ab', '\u0130b'), isTrue);
    });

    test('BOM / uppercaseFirstLetter / getNLines / count', () {
      expect(strings.startsWithUTF8BOM(strings.UTF8_BOM_CHARACTER), isTrue);
      expect(strings.startsWithUTF8BOM('foo'), isFalse);
      expect(strings.stripUTF8BOM('${strings.UTF8_BOM_CHARACTER}foobar'), 'foobar');
      expect(strings.uppercaseFirstLetter('foo'), 'Foo');
      expect(strings.uppercaseFirstLetter(''), '');
      expect(strings.getNLines('foo\nbar'), 'foo');
      expect(strings.getNLines('foo\nbar\nsomething', 2), 'foo\nbar');
      expect(strings.getNLines('foo', 0), '');
      expect(strings.count('hello world', 'l'), 3);
      expect(strings.count('hello world', 'hello world'), 1);
    });

    test('truncate / truncateMiddle', () {
      expect(strings.truncate('hello world', 100), 'hello world');
      expect(strings.truncate('hello world', 5), 'hello…');
      expect(strings.truncateMiddle('hello world', 5), 'he…ld');
      expect(strings.truncateMiddle('a😀bcde', 5), 'a…de');
      expect(strings.truncateMiddle('abcde😀f', 5), 'ab…f');
    });

    test('replaceAsync', () async {
      int i = 0;
      final String result = await strings.replaceAsync(
          'abcabcabcabc', RegExp(r'b(.)'),
          (String match, List<Object?> rest) async {
        expect(match, 'bc');
        expect(rest[0], 'c');
        return '${i++}${rest[0]}';
      });
      expect(result, 'a0ca1ca2ca3c');
    });

    test('removeAnsiEscapeCodes / removeAnsiEscapeCodesFromPrompt', () {
      expect(strings.removeAnsiEscapeCodes('\u001b[31mHello\u001b[0m'), 'Hello');
      expect(strings.removeAnsiEscapeCodesFromPrompt('\u001b[31m\$ \u001b[0m'), '\$ ');
      final parts = strings.forAnsiStringParts('a\u001b[31mb\u001b[0mc').toList();
      expect(parts.length, 5);
      expect(parts[0]['str'], 'a');
      expect(parts[0]['isCode'], isFalse);
      expect(parts[1]['isCode'], isTrue);
    });

    test('getGraphemeBreakType / AmbiguousCharacters / InvisibleCharacters / btoa', () {
      expect(strings.getGraphemeBreakType(0xBC1),
          strings.GraphemeBreakType.SpacingMark);
      final amb = strings.AmbiguousCharacters.getInstance(<String>{});
      expect(amb.containsAmbiguousCharacter('abcd'), isFalse);
      expect(amb.containsAmbiguousCharacter('ο'), isTrue);
      expect(amb.containsAmbiguousCharacter('abɡc'), isTrue);
      expect(strings.InvisibleCharacters.containsInvisibleCharacter('abcd'), isFalse);
      expect(strings.InvisibleCharacters.containsInvisibleCharacter(' '), isTrue);
      expect(strings.InvisibleCharacters.containsInvisibleCharacter('a\u{e004e}b'), isTrue);
      expect(strings.multibyteAwareBtoa('hello world').isNotEmpty, isTrue);
      expect(strings.multibyteAwareBtoa('平仮名').isNotEmpty, isTrue);
    });
  });

  group('hash.ts (1:1)', () {
    test('isStringInSample stable membership and boundaries', () {
      final List<bool> sample = List<bool>.generate(
          9, (int i) => hash.isStringInSample('session-${i + 60}', 5));
      expect(sample, <bool>[false, false, true, true, true, true, true, false, false]);
      expect(hash.isStringInSample('session', 0), isFalse);
      expect(hash.isStringInSample('session', 100), isTrue);
      expect(() => hash.isStringInSample('session', -1), throwsA(isA<Exception>()));
      expect(() => hash.isStringInSample('session', 101), throwsA(isA<Exception>()));
    });

    test('ConstantStringHash matches stringHash for int32 accumulators', () {
      for (final String value in ['', 'a', 'label', 'description', 'ünïcödé', '\u0000\u0001', '\uD83D\uDE80', 'x' * 200]) {
        for (final int hv in [0, 1, -1, 149417, 2147483647, -2147483648, 123456789]) {
          expect(hash.ConstantStringHash(value).apply(hv), hash.stringHash(value, hv));
        }
      }
      final int chained = hash.ConstantStringHash('b')
          .apply(hash.ConstantStringHash('a').apply(0));
      expect(chained, hash.stringHash('b', hash.stringHash('a', 0)));
    });

    test('numberHash / doHash primitive values', () {
      expect(hash.numberHash(0, 0), 0);
      expect(hash.numberHash(1, 0), 1);
      expect(hash.numberHash(31, 0), 31);
      expect(hash.doHash(null, 0), hash.numberHash(349, 0));
      expect(hash.doHash(true, 0), hash.numberHash(433, 0));
      expect(hash.doHash(false, 0), hash.numberHash(863, 0));
    });

    test('StringSHA1 known vectors', () async {
      final s = hash.StringSHA1();
      s.update('abc');
      expect(s.digest(), 'a9993e364706816aba3e25717850c26c9cd0d89d');
      final s2 = hash.StringSHA1();
      s2.update('hello world');
      expect(s2.digest(), '2aae6c35c94fcfb415dbe95f408b9ce91ee846ed');
      // emoji (surrogate pair) + large string
      final s3 = hash.StringSHA1();
      s3.update('😀');
      expect(s3.digest(), await hash.hashAsync('😀'));
      expect((await hash.hashAsync('x' * 300)).length, 40);
    });
  });

  group('stringBuilder.ts (1:1)', () {
    test('decodeUTF16LE keeps leading BOM', () {
      final Uint8List b1 = Uint8List(2);
      _writeU16LE(b1, 0, 0xFEFF);
      expect(stringBuilder.decodeUTF16LE(b1, 0, 1), '\uFEFF');

      final Uint8List b2 = Uint8List(4);
      _writeU16LE(b2, 0, 0x61);
      _writeU16LE(b2, 2, 0xFEFF);
      expect(stringBuilder.decodeUTF16LE(b2, 0, 2), 'a\uFEFF');

      final Uint8List b3 = Uint8List(6);
      _writeU16LE(b3, 0, 0x61);
      _writeU16LE(b3, 2, 0xFEFF);
      _writeU16LE(b3, 4, 0x62);
      expect(stringBuilder.decodeUTF16LE(b3, 0, 3), 'a\uFEFFb');
    });

    test('StringBuilder basic / reset / surrogate / appendString', () {
      final sb = stringBuilder.StringBuilder(100);
      sb.appendASCIICharCode(65); // CharCode.A
      sb.appendASCIICharCode(32); // CharCode.Space
      sb.appendString('😊');
      expect(sb.build(), 'A 😊');
      sb.reset();
      expect(sb.build(), '');

      final sb2 = stringBuilder.StringBuilder(3);
      sb2.appendString('ab');
      sb2.appendString('cd');
      expect(sb2.build(), 'abcd');

      final sb3 = stringBuilder.StringBuilder(1);
      sb3.appendCharCode(0xD83D); // high surrogate flushes
      sb3.appendCharCode(0xDE00);
      expect(sb3.build(), '😀');
    });
  });

  group('cursorColumns.ts (1:1)', () {
    test('visibleColumnFromColumn', () {
      int v(String t, int c, [int tab = 4]) =>
          cursorColumns.CursorColumns.visibleColumnFromColumn(t, c, tab);
      expect(v('\t\tvar x = 3;', 1), 0);
      expect(v('\t\tvar x = 3;', 2), 4);
      expect(v('\t\tvar x = 3;', 4), 9);
      expect(v('\t\tvar x = 3;', 13), 18);
      expect(v('baz', 1), 0);
      expect(v('baz', 4), 3);
      expect(v('📚az', 1), 0);
      expect(v('📚az', 2), 1);
      expect(v('📚az', 5), 4);
      expect(v('\t  \tx\t', -1), 0);
    });

    test('toStatusbarColumn', () {
      int s(String t, int c, [int tab = 4]) =>
          cursorColumns.CursorColumns.toStatusbarColumn(t, c, tab);
      expect(s('    spaces', 1), 1);
      expect(s('    spaces', 11), 11);
      expect(s('\ttab', 2), 5);
      expect(s('🎈🎈🎈🎈', 3), 2);
      expect(s('何何何何', 4), 4);
    });

    test('columnFromVisibleColumn', () {
      int c(String t, int vc, [int tab = 4]) =>
          cursorColumns.CursorColumns.columnFromVisibleColumn(t, vc, tab);
      expect(c('\t\tvar x = 3;', 1), 1);
      expect(c('\t\tvar x = 3;', 3), 2);
      expect(c('\t\tvar x = 3;', 9), 4);
      expect(c('\t\tvar x = 3;', 18), 13);
      expect(c('baz', 0), 1);
      expect(c('baz', 3), 4);
      expect(c('📚az', 1), 1);
      expect(c('📚az', 2), 3);
      expect(c('\t  \tx\t', -2), 1);
    });

    test('next/prev tab stops', () {
      for (final int tab in [1, 2, 4]) {
        for (int i = 0; i <= 8; i++) {
          final int expected = i + tab - i % tab;
          expect(cursorColumns.CursorColumns.nextRenderTabStop(i, tab), expected);
          expect(cursorColumns.CursorColumns.nextIndentTabStop(i, tab), expected);
        }
      }
      expect(cursorColumns.CursorColumns.prevRenderTabStop(0, 4), 0);
      expect(cursorColumns.CursorColumns.prevRenderTabStop(4, 4), 0);
      expect(cursorColumns.CursorColumns.prevRenderTabStop(5, 4), 4);
      expect(cursorColumns.CursorColumns.prevRenderTabStop(9, 4), 8);
      expect(cursorColumns.CursorColumns.prevIndentTabStop(9, 2), 8);
    });
  });

  group('textChange.ts (1:1)', () {
    // Mirrors the source test's assertCompression: verify do + undo round trips.
    String resulting(String initial, List<List<dynamic>> edits) {
      String content = initial;
      for (int i = edits.length - 1; i >= 0; i--) {
        final int off = edits[i][0] as int;
        final int len = edits[i][1] as int;
        content = content.substring(0, off) +
            (edits[i][2] as String) +
            content.substring(off + len);
      }
      return content;
    }

    List<textChange.TextChange> getChanges(
        String initial, List<List<dynamic>> edits) {
      String content = initial;
      final List<textChange.TextChange> changes = <textChange.TextChange>[];
      int delta = 0;
      for (final List<dynamic> edit in edits) {
        final int off = edit[0] as int;
        final int len = edit[1] as int;
        final String text = edit[2] as String;
        final int position = off + delta;
        final String oldText = content.substring(position, position + len);
        content = content.substring(0, position) + text + content.substring(position + len);
        changes.add(textChange.TextChange(off, oldText, position, text));
        delta += text.length - len;
      }
      return changes;
    }

    void assertCompression(String initial, List<List<dynamic>> e1,
        List<List<dynamic>> e2) {
      final String tmp = resulting(initial, e1);
      final String finalText = resulting(tmp, e2);
      final List<textChange.TextChange> compressed =
          textChange.compressConsecutiveTextChanges(getChanges(initial, e1), getChanges(tmp, e2));
      final List<List<dynamic>> doEdits = compressed
          .map((textChange.TextChange c) => <dynamic>[c.oldPosition, c.oldLength, c.newText])
          .toList();
      expect(resulting(initial, doEdits), finalText);
      final List<List<dynamic>> undoEdits = compressed
          .map((textChange.TextChange c) => <dynamic>[c.newPosition, c.newLength, c.oldText])
          .toList();
      expect(resulting(finalText, undoEdits), initial);
    }

    test('source cases: simple/complex1/gen1-6', () {
      assertCompression('', <List<dynamic>>[<dynamic>[0, 0, 'h']], <List<dynamic>>[<dynamic>[1, 0, 'e']]);
      assertCompression('|', <List<dynamic>>[<dynamic>[0, 0, 'h']], <List<dynamic>>[<dynamic>[2, 0, 'e']]);
      assertCompression('abcdefghij', <List<dynamic>>[
        <dynamic>[0, 3, 'qh'],
        <dynamic>[5, 0, '1'],
        <dynamic>[8, 2, 'X'],
      ], <List<dynamic>>[
        <dynamic>[1, 0, 'Z'],
        <dynamic>[3, 3, 'Y'],
      ]);
      assertCompression('kxm', <List<dynamic>>[<dynamic>[0, 1, 'tod_neu']], <List<dynamic>>[<dynamic>[1, 2, 'sag_e']]);
      assertCompression('kpb_r_v', <List<dynamic>>[<dynamic>[5, 2, 'a_jvf_l']], <List<dynamic>>[<dynamic>[10, 2, 'w']]);
      assertCompression('slu_w', <List<dynamic>>[<dynamic>[4, 1, '_wfw']], <List<dynamic>>[<dynamic>[3, 5, '']]);
      assertCompression('_e', <List<dynamic>>[<dynamic>[2, 0, 'zo_b']], <List<dynamic>>[<dynamic>[1, 3, 'tra']]);
      assertCompression('ssn_', <List<dynamic>>[<dynamic>[0, 2, 'tat_nwe']], <List<dynamic>>[<dynamic>[2, 6, 'jm']]);
      assertCompression('kl_nru', <List<dynamic>>[<dynamic>[4, 1, '']], <List<dynamic>>[<dynamic>[1, 4, '__ut']]);
    });

    test('binary write/read round trip (issue #118041)', () {
      final c = textChange.TextChange(428, '\uFEFF', 428, '');
      final Uint8List buff = Uint8List(c.writeSize());
      final int end = c.write(buff, 0);
      expect(end, c.writeSize());
      final List<textChange.TextChange> actual = <textChange.TextChange>[];
      textChange.TextChange.read(buff, 0, actual);
      expect(actual.length, 1);
      expect(actual[0].oldPosition, c.oldPosition);
      expect(actual[0].oldText, c.oldText);
      expect(actual[0].newPosition, c.newPosition);
      expect(actual[0].newText, c.newText);
    });

    test('toString / properties', () {
      final ins = textChange.TextChange(3, '', 3, 'ab');
      expect(ins.toString(), '(insert@3 "ab")');
      expect(ins.oldLength, 0);
      expect(ins.newEnd, 5);
      final del = textChange.TextChange(2, 'xy', 2, '');
      expect(del.toString(), '(delete@2 "xy")');
      final rep = textChange.TextChange(0, 'a\nb', 0, 'c\rd');
      expect(rep.toString(), '(replace@0 "a\\nb" with "c\\rd")');
    });

    test('property: random edit sequences round trip (500 iterations)', () {
      final rand = math.Random(12345);
      String randStr(int min, int max) {
        final int len = min + rand.nextInt(max - min + 1);
        final StringBuffer sb = StringBuffer();
        for (int i = 0; i < len; i++) {
          sb.writeCharCode(97 + rand.nextInt(26));
        }
        return sb.toString();
      }
      List<List<dynamic>> randEdits(String content) {
        final List<List<dynamic>> result = <List<dynamic>>[];
        int cnt = 1 + rand.nextInt(5);
        int maxOffset = content.length;
        while (cnt > 0 && maxOffset > 0) {
          final int off = rand.nextInt(maxOffset + 1);
          final int len = rand.nextInt(maxOffset - off + 1);
          result.add(<dynamic>[off, len, randStr(0, 3)]);
          maxOffset = off;
          cnt--;
        }
        return result.reversed.toList();
      }
      for (int it = 0; it < 500; it++) {
        final String initial = randStr(0, 12);
        final List<List<dynamic>> e1 = randEdits(initial);
        final String tmp = resulting(initial, e1);
        final List<List<dynamic>> e2 = randEdits(tmp);
        assertCompression(initial, e1, e2);
      }
    });
  });

  group('extpath.ts (1:1)', () {
    test('toSlashes', () {
      expect(extpath.toSlashes(r'\\server\share\some\path'), '//server/share/some/path');
      expect(extpath.toSlashes(r'c:\test'), 'c:/test');
      expect(extpath.toSlashes(r'foo\bar'), 'foo/bar');
      expect(extpath.toSlashes('/user/far'), '/user/far');
    });

    test('getRoot', () {
      expect(extpath.getRoot('/user/far'), '/');
      expect(extpath.getRoot(r'\\server\share\some\path'), '//server/share/');
      expect(extpath.getRoot('//server/share/some/path'), '//server/share/');
      expect(extpath.getRoot('//server/share'), '/');
      expect(extpath.getRoot('//server'), '/');
      expect(extpath.getRoot('//server//'), '/');
      expect(extpath.getRoot('c:/user/far'), 'c:/');
      expect(extpath.getRoot('c:user/far'), 'c:');
      expect(extpath.getRoot('http://www'), '');
      expect(extpath.getRoot('http://www/'), 'http://www/');
      expect(extpath.getRoot('file:///foo'), 'file:///');
      expect(extpath.getRoot('file://foo'), '');
    });

    test('isUNC (non-Windows platform)', () {
      expect(extpath.isUNC('foo'), isFalse);
      expect(extpath.isUNC('/foo'), isFalse);
      expect(extpath.isUNC(r'\foo'), isFalse);
      expect(extpath.isUNC(r'\\foo'), isFalse);
      expect(extpath.isUNC(r'\\a\b'), isFalse);
      expect(extpath.isUNC('//a/b'), isFalse);
      expect(extpath.isUNC(r'\\server\share'), isFalse);
    });

    test('isValidBasename', () {
      expect(extpath.isValidBasename(null), isFalse);
      expect(extpath.isValidBasename(''), isFalse);
      expect(extpath.isValidBasename('test.txt'), isTrue);
      expect(extpath.isValidBasename('/test.txt'), isFalse);
      expect(extpath.isValidBasename(r'\test.txt'), isTrue);
      expect(extpath.isValidBasename(r'\test.txt', true), isFalse);
      expect(extpath.isValidBasename('aux', true), isFalse);
      expect(extpath.isValidBasename('Aux', true), isFalse);
      expect(extpath.isValidBasename('LPT0', true), isFalse);
      expect(extpath.isValidBasename('aux.txt', true), isFalse);
      expect(extpath.isValidBasename('com0.abc', true), isFalse);
      expect(extpath.isValidBasename('LPT00', true), isTrue);
      expect(extpath.isValidBasename('aux1', true), isTrue);
      expect(extpath.isValidBasename('aux1.txt', true), isTrue);
      expect(extpath.isValidBasename('aux1.aux.txt', true), isTrue);
      expect(extpath.isValidBasename('test.txt.', true), isFalse);
      expect(extpath.isValidBasename('test.txt..', true), isFalse);
      expect(extpath.isValidBasename('test.txt ', true), isFalse);
      expect(extpath.isValidBasename('test.txt\t', true), isFalse);
      expect(extpath.isValidBasename('tes:t.txt', true), isFalse);
      expect(extpath.isValidBasename('tes"t.txt', true), isFalse);
    });

    test('sanitizeFilePath (posix)', () {
      expect(extpath.sanitizeFilePath('.', '/the/cwd'), '/the/cwd');
      expect(extpath.sanitizeFilePath('', '/the/cwd'), '/the/cwd');
      expect(extpath.sanitizeFilePath('/', '/the/cwd'), '/');
      expect(extpath.sanitizeFilePath('/folder/my.txt', '/the/cwd'), '/folder/my.txt');
      expect(extpath.sanitizeFilePath('/folder/my', '/the/cwd'), '/folder/my');
      expect(extpath.sanitizeFilePath('/folder/../my', '/the/cwd'), '/my');
      expect(extpath.sanitizeFilePath('/folder/my/', '/the/cwd'), '/folder/my');
      expect(extpath.sanitizeFilePath('/folder/my///', '/the/cwd'), '/folder/my');
      expect(extpath.sanitizeFilePath('my.txt', '/the/cwd'), '/the/cwd/my.txt');
      expect(extpath.sanitizeFilePath('my.txt/', '/the/cwd'), '/the/cwd/my.txt');
    });

    test('isRootOrDriveLetter / hasDriveLetter / getDriveLetter', () {
      expect(extpath.isRootOrDriveLetter('/'), isTrue);
      expect(extpath.isRootOrDriveLetter('/path'), isFalse);
      expect(extpath.hasDriveLetter('/'), isFalse);
      expect(extpath.hasDriveLetter('/path'), isFalse);
      expect(extpath.hasDriveLetter('c:', true), isTrue);
      expect(extpath.hasDriveLetter('D:', true), isTrue);
      expect(extpath.hasDriveLetter('D:/', true), isTrue);
      expect(extpath.hasDriveLetter(r'D:\', true), isTrue);
      expect(extpath.hasDriveLetter(r'D:\path', true), isTrue);
      expect(extpath.hasDriveLetter('D:/path', true), isTrue);
      expect(extpath.getDriveLetter('/'), isNull);
      expect(extpath.getDriveLetter('/path'), isNull);
      expect(extpath.getDriveLetter('c:', true), 'c');
      expect(extpath.getDriveLetter('D:', true), 'D');
      expect(extpath.getDriveLetter('D:/', true), 'D');
      expect(extpath.getDriveLetter(r'D:\path', true), 'D');
    });

    test('isWindowsDriveLetter', () {
      expect(extpath.isWindowsDriveLetter(0), isFalse);
      expect(extpath.isWindowsDriveLetter(-1), isFalse);
      expect(extpath.isWindowsDriveLetter(cc.CharCode.A), isTrue);
      expect(extpath.isWindowsDriveLetter(cc.CharCode.z), isTrue);
    });

    test('indexOfPath', () {
      expect(extpath.indexOfPath('/foo', '/bar', true), -1);
      expect(extpath.indexOfPath('/foo', '/FOO', false), -1);
      expect(extpath.indexOfPath('/foo', '/FOO', true), 0);
      expect(extpath.indexOfPath('/some/long/path', '/some/long', false), 0);
      expect(extpath.indexOfPath('/some/long/path', '/PATH', true), 10);
    });

    test('parseLineAndColumnAware', () {
      var res = extpath.parseLineAndColumnAware('/foo/bar');
      expect(res.path, '/foo/bar');
      expect(res.line, isNull);
      expect(res.column, isNull);

      res = extpath.parseLineAndColumnAware('/foo/bar:33');
      expect(res.path, '/foo/bar');
      expect(res.line, 33);
      expect(res.column, 1);

      res = extpath.parseLineAndColumnAware('/foo/bar:33:34');
      expect(res.path, '/foo/bar');
      expect(res.line, 33);
      expect(res.column, 34);

      res = extpath.parseLineAndColumnAware(r'C:\foo\bar');
      expect(res.path, r'C:\foo\bar');
      expect(res.line, isNull);
      expect(res.column, isNull);

      res = extpath.parseLineAndColumnAware(r'C:\foo\bar:33');
      expect(res.path, r'C:\foo\bar');
      expect(res.line, 33);
      expect(res.column, 1);

      res = extpath.parseLineAndColumnAware(r'C:\foo\bar:33:34');
      expect(res.path, r'C:\foo\bar');
      expect(res.line, 33);
      expect(res.column, 34);

      res = extpath.parseLineAndColumnAware('/foo/bar:abb');
      expect(res.path, '/foo/bar:abb');
      expect(res.line, isNull);
      expect(res.column, isNull);
    });

    test('randomPath', () {
      expect(extpath.randomPath('/foo/bar').isNotEmpty, isTrue);
      expect(extpath.randomPath('/foo/bar', 'prefix-').contains('prefix-'), isTrue);
      expect(extpath.randomPath('/foo/bar') != extpath.randomPath('/foo/bar'), isTrue);
      expect(extpath.randomPath('', '', 3).length, 3);
      expect(extpath.randomPath().isNotEmpty, isTrue);
    });
  });

  group('ternarySearchTree.ts (1:1)', () {
    test('PathIterator', () {
      final iter = tst.PathIterator();
      iter.reset('file:///usr/bin/file.txt');

      expect(iter.value(), 'file:');
      expect(iter.hasNext(), isTrue);
      expect(iter.cmp('file:'), 0);
      expect(iter.cmp('a') < 0, isTrue);
      expect(iter.cmp('aile:') < 0, isTrue);
      expect(iter.cmp('z') > 0, isTrue);
      expect(iter.cmp('zile:') > 0, isTrue);

      iter.next();
      expect(iter.value(), 'usr');
      expect(iter.hasNext(), isTrue);
      iter.next();
      expect(iter.value(), 'bin');
      expect(iter.hasNext(), isTrue);
      iter.next();
      expect(iter.value(), 'file.txt');
      expect(iter.hasNext(), isFalse);
      iter.next();
      expect(iter.value(), '');
      expect(iter.hasNext(), isFalse);
      iter.next();
      expect(iter.value(), '');
      expect(iter.hasNext(), isFalse);

      iter.reset('/foo/bar/');
      expect(iter.value(), 'foo');
      expect(iter.hasNext(), isTrue);
      iter.next();
      expect(iter.value(), 'bar');
      expect(iter.hasNext(), isFalse);
    });

    test('UriIterator', () {
      final iter = tst.UriIterator((URI key) => false, (URI key) => false);
      iter.reset(URI.parse('file:///usr/bin/file.txt'));

      expect(iter.value(), 'file');
      expect(iter.cmp('file'), 0);
      expect(iter.hasNext(), isTrue);
      iter.next();
      expect(iter.value(), 'usr');
      iter.next();
      expect(iter.value(), 'bin');
      iter.next();
      expect(iter.value(), 'file.txt');
      expect(iter.hasNext(), isFalse);

      iter.reset(URI.parse('file://share/usr/bin/file.txt?foo'));
      expect(iter.value(), 'file');
      expect(iter.cmp('file'), 0);
      iter.next();
      expect(iter.value(), 'share');
      expect(iter.cmp('SHARe'), 0);
      iter.next();
      expect(iter.value(), 'usr');
      iter.next();
      expect(iter.value(), 'bin');
      iter.next();
      expect(iter.value(), 'file.txt');
      expect(iter.hasNext(), isTrue);
      iter.next();
      expect(iter.value(), 'foo');
      expect(iter.cmp('z') > 0, isTrue);
      expect(iter.cmp('a') < 0, isTrue);
      expect(iter.hasNext(), isFalse);
    });

    test('UriIterator - ignore query/fragment', () {
      final iter = tst.UriIterator((URI key) => false, (URI key) => true);
      iter.reset(URI.parse('file://share/usr/bin/file.txt?foo'));
      expect(iter.value(), 'file');
      iter.next();
      expect(iter.value(), 'share');
      iter.next();
      expect(iter.value(), 'usr');
      iter.next();
      expect(iter.value(), 'bin');
      iter.next();
      expect(iter.value(), 'file.txt');
      expect(iter.hasNext(), isFalse);
    });

    test('set / set w/ undefined / findLongestMatch / basics', () {
      var trie = tst.TernarySearchTree.forStrings<int>();
      trie.set('foobar', 1);
      trie.set('foobaz', 2);
      _assertTstDfs(trie, <MapEntry<String, int>>[
        MapEntry('foobar', 1),
        MapEntry('foobaz', 2),
      ]);

      trie = tst.TernarySearchTree.forStrings<int>();
      trie.set('foobar', 1);
      trie.set('fooba', 2);
      _assertTstDfs(trie, <MapEntry<String, int>>[
        MapEntry('fooba', 2),
        MapEntry('foobar', 1),
      ]);

      trie = tst.TernarySearchTree.forStrings<int>();
      trie.set('foo', 1);
      trie.set('foo', 2);
      _assertTstDfs(trie, <MapEntry<String, int>>[MapEntry('foo', 2)]);

      trie = tst.TernarySearchTree.forStrings<int>();
      trie.set('foo', 1);
      trie.set('foobar', 2);
      trie.set('bar', 3);
      trie.set('foob', 4);
      trie.set('bazz', 5);
      _assertTstDfs(trie, <MapEntry<String, int>>[
        MapEntry('bar', 3),
        MapEntry('bazz', 5),
        MapEntry('foo', 1),
        MapEntry('foob', 4),
        MapEntry('foobar', 2),
      ]);

      final Object? trie2 = tst.TernarySearchTree.forStrings<Object?>();
      final dynamic dynamicTrie = trie2;
      dynamicTrie.set('foobar', null);
      dynamicTrie.set('foobaz', 2);
      expect(dynamicTrie.get('foobar'), isNull);
      expect(dynamicTrie.get('foobaz'), 2);
      expect(dynamicTrie.get('NOT HERE'), isNull);
      expect(dynamicTrie.has('foobar'), isTrue);
      expect(dynamicTrie.has('NOT HERE'), isFalse);
      expect(dynamicTrie.set('foobar', 3), isNull);
      expect(dynamicTrie.get('foobar'), 3);

      trie = tst.TernarySearchTree.forStrings<int>();
      trie.set('foo', 1);
      trie.set('foobar', 2);
      trie.set('foobaz', 3);
      expect(trie.findSubstr('f'), isNull);
      expect(trie.findSubstr('z'), isNull);
      expect(trie.findSubstr('foo'), 1);
      expect(trie.findSubstr('fooö'), 1);
      expect(trie.findSubstr('fooba'), 1);
      expect(trie.findSubstr('foobarr'), 2);
      expect(trie.findSubstr('foobazrr'), 3);
    });

    test('delete & cleanup / BST+AVL delete', () {
      var trie = tst.TernarySearchTree<String, int>(tst.StringIterator());
      trie.set('foo', 1);
      trie.set('foobar', 2);
      trie.set('bar', 3);
      trie.delete('foo');
      _assertTstDfs(trie, <MapEntry<String, int>>[
        MapEntry('bar', 3),
        MapEntry('foobar', 2),
      ]);
      trie.delete('foobar');
      _assertTstDfs(trie, <MapEntry<String, int>>[MapEntry('bar', 3)]);

      trie = tst.TernarySearchTree<String, int>(tst.StringIterator());
      trie.set('foo', 1);
      trie.set('foobar', 2);
      trie.set('bar', 3);
      trie.set('foobarbaz', 4);
      trie.deleteSuperstr('foo');
      _assertTstDfs(trie, <MapEntry<String, int>>[
        MapEntry('bar', 3),
        MapEntry('foo', 1),
      ]);
      trie.deleteSuperstr('fo');
      _assertTstDfs(trie, <MapEntry<String, int>>[MapEntry('bar', 3)]);

      trie = tst.TernarySearchTree<String, int>(tst.StringIterator());
      trie.set('d', 1);
      trie.delete('d');
      expect(trie.toList(), isEmpty);
      trie.set('d', 1);
      trie.set('b', 1);
      trie.set('f', 1);
      trie.delete('d');
      _assertTstDfs(trie, <MapEntry<String, int>>[
        MapEntry('b', 1),
        MapEntry('f', 1),
      ]);

      trie = tst.TernarySearchTree<String, int>(tst.StringIterator());
      for (final String k in <String>['d', 'b', 'f', 'e', 'z']) {
        trie.set(k, 1);
      }
      trie.delete('b');
      expect(trie.isBalanced(), isTrue);
      expect(trie.toList().map((e) => e.key).toList(),
          <String>['d', 'e', 'f', 'z']);

      trie = tst.TernarySearchTree<String, int>(tst.StringIterator());
      for (final String k in <String>['a', 'ad', 'ab', 'af', 'ae', 'az']) {
        trie.set(k, 1);
      }
      trie.delete('ab');
      trie.delete('a');
      expect(trie.toList().map((e) => e.key).toList(),
          <String>['ad', 'ae', 'af', 'az']);
    });

    test('(AVL) set rotations', () {
      tst.TernarySearchTree<String, int> make() =>
          tst.TernarySearchTree<String, int>(tst.PathIterator());
      var trie = make();
      trie.set('/fileA', 1);
      trie.set('/fileB', 2);
      trie.set('/fileC', 3);
      _assertTstDfs(trie, <MapEntry<String, int>>[
        MapEntry('/fileA', 1),
        MapEntry('/fileB', 2),
        MapEntry('/fileC', 3),
      ]);

      trie = make();
      trie.set('/foo/fileC', 3);
      trie.set('/foo/fileB', 2);
      trie.set('/foo/fileA', 1);
      _assertTstDfs(trie, <MapEntry<String, int>>[
        MapEntry('/foo/fileA', 1),
        MapEntry('/foo/fileB', 2),
        MapEntry('/foo/fileC', 3),
      ]);

      trie = make();
      for (final List<dynamic> pair in <List<dynamic>>[
        <dynamic>['/fileD', 7],
        <dynamic>['/fileB', 2],
        <dynamic>['/fileG', 42],
        <dynamic>['/fileF', 24],
        <dynamic>['/fileZ', 73],
        <dynamic>['/fileE', 15],
      ]) {
        trie.set(pair[0] as String, pair[1] as int);
      }
      expect(trie.toList().map((e) => e.key).toList(), <String>[
        '/fileB',
        '/fileD',
        '/fileE',
        '/fileF',
        '/fileG',
        '/fileZ',
      ]);
      expect(trie.isBalanced(), isTrue);
    });

    test('issue #138284 (simple + random AVL invariant)', () {
      final tst.TernarySearchTree<String, bool> simple =
          tst.TernarySearchTree.forStrings<bool>();
      for (final String k in <String>['C', 'A', 'D', 'B']) {
        simple.set(k, true);
      }
      expect(simple.isBalanced(), isTrue);
      simple.delete('C');
      expect(simple.toList().map((e) => e.key).toList(),
          <String>['A', 'B', 'D']);

      final rand = math.Random(4242);
      const String chars =
          'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
      for (int round = 0; round < 10; round++) {
        final List<String> keys = <String>[];
        for (int i = 0; i < 100; i++) {
          final StringBuffer sb = StringBuffer();
          for (int j = 0; j < 10; j++) {
            sb.write(chars[rand.nextInt(chars.length)]);
          }
          keys.add(sb.toString());
        }
        final tst.TernarySearchTree<String, bool> tree =
            tst.TernarySearchTree.forStrings<bool>();
        for (final String k in keys) {
          tree.set(k, true);
          expect(tree.isBalanced(), isTrue);
        }
        for (final String k in keys) {
          tree.delete(k);
          expect(tree.isBalanced(), isTrue);
        }
      }
    });

    test('(PathSegments) basics / lookup / superstr / delete_superstr', () {
      tst.TernarySearchTree<String, int> make() =>
          tst.TernarySearchTree<String, int>(tst.PathIterator());
      var trie = make();
      trie.set('/user/foo/bar', 1);
      trie.set('/user/foo', 2);
      trie.set('/user/foo/flip/flop', 3);
      expect(trie.get('/user/foo/bar'), 1);
      expect(trie.get('/user/foo'), 2);
      expect(trie.get('/user//foo'), 2);
      expect(trie.get(r'/user\foo'), 2);
      expect(trie.findSubstr('/user/bar'), isNull);
      expect(trie.findSubstr('/user/foo'), 2);
      expect(trie.findSubstr(r'\user\foo'), 2);
      expect(trie.findSubstr('/user//foo'), 2);
      expect(trie.findSubstr('/user/foo/ba'), 2);
      expect(trie.findSubstr('/user/foo/far/boo'), 2);
      expect(trie.findSubstr('/user/foo/bar'), 1);
      expect(trie.findSubstr('/user/foo/bar/far/boo'), 1);

      trie = make();
      trie.set('/user/foo/bar', 1);
      trie.set('/user/foo', 2);
      trie.set('/user/foo/flip/flop', 3);
      trie.set('/usr/foo', 4);
      expect(trie.findSuperstr('/user')!.map((e) => e.value).toList(),
          <int>[2, 1, 3]);
      expect(trie.findSuperstr('/usr')!.map((e) => e.value).toList(), <int>[4]);
      expect(trie.findSuperstr('/not'), isNull);
      expect(trie.findSuperstr('/us'), isNull);
      expect(trie.findSuperstr('/usrr'), isNull);
      expect(trie.findSuperstr('/userr'), isNull);

      _assertTstDfs(trie, <MapEntry<String, int>>[
        MapEntry('/user/foo', 2),
        MapEntry('/user/foo/bar', 1),
        MapEntry('/user/foo/flip/flop', 3),
        MapEntry('/usr/foo', 4),
      ]);
      trie.deleteSuperstr('/user/fo');
      expect(trie.toList().length, 4);
      trie.deleteSuperstr('/user/foo');
      _assertTstDfs(trie, <MapEntry<String, int>>[
        MapEntry('/user/foo', 2),
        MapEntry('/usr/foo', 4),
      ]);
    });

    test('(URI) basics / query / lookup / casing / superstr', () {
      tst.TernarySearchTree<URI, int> make() =>
          tst.TernarySearchTree<URI, int>(
              tst.UriIterator((URI key) => false, (URI key) => false));
      var trie = make();
      trie.set(URI.file('/user/foo/bar'), 1);
      trie.set(URI.file('/user/foo'), 2);
      trie.set(URI.file('/user/foo/flip/flop'), 3);
      expect(trie.get(URI.file('/user/foo/bar')), 1);
      expect(trie.get(URI.file('/user/foo')), 2);
      expect(trie.findSubstr(URI.file('/user/bar')), isNull);
      expect(trie.findSubstr(URI.file('/user/foo')), 2);
      expect(trie.findSubstr(URI.file('/user/foo/ba')), 2);
      expect(trie.findSubstr(URI.file('/user/foo/far/boo')), 2);
      expect(trie.findSubstr(URI.file('/user/foo/bar')), 1);
      expect(trie.findSubstr(URI.file('/user/foo/bar/far/boo')), 1);

      final queryTrie = tst.TernarySearchTree<URI, int>(
          tst.UriIterator((URI key) => false, (URI key) => true));
      queryTrie.set(URI.parse('memfs:/?param=1'), 1);
      expect(queryTrie.get(URI.parse('memfs:/?param=1')), 1);
      expect(queryTrie.findSubstr(URI.parse('memfs:/aaa?param=1')), 1);

      trie = make();
      trie.set(URI.parse('http://foo.bar/user/foo/bar'), 1);
      trie.set(URI.parse('http://foo.bar/user/foo?query'), 2);
      trie.set(URI.parse('http://foo.bar/user/foo?QUERY'), 3);
      trie.set(URI.parse('http://foo.bar/user/foo/flip/flop'), 3);
      expect(trie.get(URI.parse('http://foo.bar/foo')), isNull);
      expect(trie.get(URI.parse('http://foo.bar/user')), isNull);
      expect(trie.get(URI.parse('http://foo.bar/user/foo/bar')), 1);
      expect(trie.get(URI.parse('http://foo.bar/user/foo?query')), 2);
      expect(trie.get(URI.parse('http://foo.bar/user/foo?Query')), isNull);
      expect(trie.get(URI.parse('http://foo.bar/user/foo?QUERY')), 3);
      expect(trie.get(URI.parse('http://foo.bar/user/foo/bar/boo')), isNull);

      final caseTrie = tst.TernarySearchTree<URI, int>(tst.UriIterator(
          (URI uri) => RegExp(r'^https?$').hasMatch(uri.scheme),
          (URI key) => false));
      caseTrie.set(URI.parse('http://foo.bar/user/foo/bar'), 1);
      expect(caseTrie.get(URI.parse('http://foo.bar/USER/foo/bar')), 1);
      caseTrie.set(URI.parse('foo://foo.bar/user/foo/bar'), 1);
      expect(caseTrie.get(URI.parse('foo://foo.bar/USER/foo/bar')), isNull);

      trie = make();
      trie.set(URI.file('/user/foo/bar'), 1);
      trie.set(URI.file('/user/foo'), 2);
      trie.set(URI.file('/user/foo/flip/flop'), 3);
      trie.set(URI.file('/usr/foo'), 4);
      expect(trie.findSuperstr(URI.file('/user'))!.map((e) => e.value).toList(),
          <int>[2, 1, 3]);
      expect(trie.findSuperstr(URI.file('/usr'))!.map((e) => e.value).toList(),
          <int>[4]);
      expect(trie.findSuperstr(URI.file('/'))!.map((e) => e.value).toList(),
          <int>[2, 1, 3, 4]);
      expect(trie.findSuperstr(URI.file('/not')), isNull);
      expect(trie.findSuperstr(URI.file('/us')), isNull);
      expect(trie.findSuperstr(URI.file('/usrr')), isNull);
      expect(trie.findSuperstr(URI.file('/userr')), isNull);
    });

    test('(ConfigKeySegments) basics / lookup / superstr / delete_superstr', () {
      tst.TernarySearchTree<String, int> make() =>
          tst.TernarySearchTree<String, int>(tst.ConfigKeysIterator());
      var trie = make();
      trie.set('config.foo.bar', 1);
      trie.set('config.foo', 2);
      trie.set('config.foo.flip.flop', 3);
      expect(trie.get('config.foo.bar'), 1);
      expect(trie.get('config.foo'), 2);
      expect(trie.get('config.foo.flip.flop'), 3);
      expect(trie.findSubstr('config.bar'), isNull);
      expect(trie.findSubstr('config.foo'), 2);
      expect(trie.findSubstr('config.foo.ba'), 2);
      expect(trie.findSubstr('config.foo.far.boo'), 2);
      expect(trie.findSubstr('config.foo.bar'), 1);
      expect(trie.findSubstr('config.foo.bar.far.boo'), 1);
      expect(trie.get('foo'), isNull);
      expect(trie.get('config'), isNull);
      expect(trie.get('config.foo.bar.boo'), isNull);

      trie = make();
      trie.set('config.foo.bar', 1);
      trie.set('config.foo', 2);
      trie.set('config.foo.flip.flop', 3);
      trie.set('boo', 4);
      expect(trie.findSuperstr('config')!.map((e) => e.value).toList(),
          <int>[2, 1, 3]);
      expect(trie.findSuperstr('foo'), isNull);
      expect(trie.findSuperstr('config.foo.no'), isNull);
      expect(trie.findSuperstr('config.foop'), isNull);

      _assertTstDfs(trie, <MapEntry<String, int>>[
        MapEntry('boo', 4),
        MapEntry('config.foo', 2),
        MapEntry('config.foo.bar', 1),
        MapEntry('config.foo.flip.flop', 3),
      ]);
      trie.deleteSuperstr('config.fo');
      expect(trie.toList().length, 4);
      trie.deleteSuperstr('config.foo');
      _assertTstDfs(trie, <MapEntry<String, int>>[
        MapEntry('boo', 4),
        MapEntry('config.foo', 2),
      ]);
    });

    test('fill and hasElementOrSubtree', () {
      final tst.TernarySearchTree<String, bool> trie =
          tst.TernarySearchTree.forStrings<bool>();
      final List<String> keys = <String>['foo', 'bar', 'bang', 'bazz'];
      trie.fill(true, keys);
      for (final String key in keys) {
        expect(trie.get(key), isTrue);
      }
      expect(trie.hasElementOrSubtree('fo'), isTrue);
      expect(trie.hasElementOrSubtree('fooz'), isFalse);

      final tst.TernarySearchTree<String, int> pairs =
          tst.TernarySearchTree.forStrings<int>();
      pairs.fill(<dynamic>[
        <dynamic>['a', 1],
        <dynamic>['b', 2],
      ]);
      expect(pairs.get('a'), 1);
      expect(pairs.get('b'), 2);
    });
  });

  group('search.ts + severity.ts (1:1)', () {
    test('buildReplaceStringWithCasePreserved (source cases)', () {
      void assertReplace(List<String> target, String replaceString, String expected) {
        expect(search.buildReplaceStringWithCasePreserved(target, replaceString), expected);
      }

      assertReplace(<String>['abc'], 'Def', 'def');
      assertReplace(<String>['Abc'], 'Def', 'Def');
      assertReplace(<String>['ABC'], 'Def', 'DEF');
      assertReplace(<String>['abc', 'Abc'], 'Def', 'def');
      assertReplace(<String>['Abc', 'abc'], 'Def', 'Def');
      assertReplace(<String>['ABC', 'abc'], 'Def', 'DEF');
      assertReplace(<String>['aBc', 'abc'], 'Def', 'def');
      assertReplace(<String>['AbC'], 'Def', 'Def');
      assertReplace(<String>['aBC'], 'Def', 'def');
      assertReplace(<String>['aBc'], 'DeF', 'deF');
      assertReplace(<String>['Foo-Bar'], 'newfoo-newbar', 'Newfoo-Newbar');
      assertReplace(<String>['Foo-Bar-Abc'], 'newfoo-newbar-newabc', 'Newfoo-Newbar-Newabc');
      assertReplace(<String>['Foo-Bar-abc'], 'newfoo-newbar', 'Newfoo-newbar');
      assertReplace(<String>['foo-Bar'], 'newfoo-newbar', 'newfoo-Newbar');
      assertReplace(<String>['foo-BAR'], 'newfoo-newbar', 'newfoo-NEWBAR');
      assertReplace(<String>['foO-BAR'], 'NewFoo-NewBar', 'newFoo-NEWBAR');
      assertReplace(<String>['Foo_Bar'], 'newfoo_newbar', 'Newfoo_Newbar');
      assertReplace(<String>['Foo_Bar_Abc'], 'newfoo_newbar_newabc', 'Newfoo_Newbar_Newabc');
      assertReplace(<String>['Foo_Bar_abc'], 'newfoo_newbar', 'Newfoo_newbar');
      assertReplace(<String>['Foo_Bar-abc'], 'newfoo_newbar-abc', 'Newfoo_newbar-abc');
      assertReplace(<String>['foo_Bar'], 'newfoo_newbar', 'newfoo_Newbar');
      assertReplace(<String>['Foo_BAR'], 'newfoo_newbar', 'Newfoo_NEWBAR');
      expect(search.buildReplaceStringWithCasePreserved(null, 'Def'), 'Def');
      expect(search.buildReplaceStringWithCasePreserved(<String>[''], 'Def'), 'Def');
    });

    test('Severity.fromValue / toString', () {
      expect(severity.Severity.fromValue(''), severity.Severity.Ignore);
      expect(severity.Severity.fromValue('error'), severity.Severity.Error);
      expect(severity.Severity.fromValue('ERROR'), severity.Severity.Error);
      expect(severity.Severity.fromValue('warning'), severity.Severity.Warning);
      expect(severity.Severity.fromValue('WARN'), severity.Severity.Warning);
      expect(severity.Severity.fromValue('Info'), severity.Severity.Info);
      expect(severity.Severity.fromValue('nonsense'), severity.Severity.Ignore);
      expect(severity.Severity.toStringStatic(severity.Severity.Error), 'error');
      expect(severity.Severity.toStringStatic(severity.Severity.Warning), 'warning');
      expect(severity.Severity.toStringStatic(severity.Severity.Info), 'info');
      expect(severity.Severity.toStringStatic(severity.Severity.Ignore), 'ignore');
      expect(severity.Severity.toStringStatic(42), 'ignore');
    });
  });

  group('wordHelper.ts (1:1)', () {
    test('USUAL_WORD_SEPARATORS runtime value', () {
      expect(wh.USUAL_WORD_SEPARATORS, '`~!@#\$%^&*()-=+[{]}\\|;:\'",.<>/?');
    });

    test('getWordAtText: simple identifier', () {
      // "  hello world"  column of the 'h' is 3.
      final res = wh.getWordAtText(3, wh.DEFAULT_WORD_REGEXP, '  hello world', 0)!;
      expect(res.word, 'hello');
      expect(res.startColumn, 3);
      expect(res.endColumn, 8);
    });

    test('getWordAtText: word at middle', () {
      // "hello world"  column 8 -> 'world'
      final res = wh.getWordAtText(8, wh.DEFAULT_WORD_REGEXP, 'hello world', 0)!;
      expect(res.word, 'world');
      expect(res.startColumn, 7);
      expect(res.endColumn, 12);
    });

    test('getWordAtText: number (floating) matched by first group', () {
      final res = wh.getWordAtText(3, wh.DEFAULT_WORD_REGEXP, 'x 1.5 y', 0)!;
      expect(res.word, '1.5');
    });

    test('getWordAtText: with textOffset', () {
      // text = "world" located at document offset 10; cursor at 1-based
      // document column 11 => pos = 11 - 1 - 10 = 0 inside "world".
      final res = wh.getWordAtText(11, wh.DEFAULT_WORD_REGEXP, 'world', 10)!;
      expect(res.word, 'world');
      expect(res.startColumn, 11);
      expect(res.endColumn, 16);
    });

    test('getWordAtText: no word -> null', () {
      expect(wh.getWordAtText(1, wh.DEFAULT_WORD_REGEXP, '   ', 0), isNull);
    });

    test('ensureValidWordDefinition resets lastIndex', () {
      final def = wh.WordDefinition(RegExp(r'\w+', caseSensitive: false));
      def.lastIndex = 5;
      final ensured = wh.ensureValidWordDefinition(def);
      expect(identical(ensured, def), isTrue);
      expect(ensured.lastIndex, 0);
    });
  });

  group('validation.ts (1:1)', () {
    test('vString/vNumber/vBoolean type validators', () {
      final s = val.vString();
      expect(s.validate('hi').error, isNull);
      expect(s.validate('hi').content, 'hi');
      expect(s.validate(42).error!.message, 'Expected string, but got number');
      expect(s.validate(null).error!.message, 'Expected string, but got undefined');

      expect(val.vNumber().validate(3.5).error, isNull);
      expect(val.vBoolean().validate(true).error, isNull);
      expect(val.vBoolean().validate(1).error!.message, 'Expected boolean, but got number');
    });

    test('vObjAny / vUndefined / vUnknown / vUnchecked', () {
      expect(val.vObjAny().validate(<String, dynamic>{}).error, isNull);
      expect(val.vUndefined().validate(null).error, isNull);
      expect(val.vUndefined().validate(0).error!.message, 'Expected undefined, but got number');
      expect(val.vUnknown().validate('anything').error, isNull);
      expect(val.vUnchecked<Object?>().validate(123).content, 123);
    });

    test('validateOrThrow throws on error', () {
      expect(() => val.vString().validateOrThrow(1), throwsA(isA<Exception>()));
      expect(val.vNumber().validateOrThrow(7), 7);
    });

    test('vObj required + optional fields', () {
      final v = val.vObj(<String, Object?>{
        'name': val.vString(),
        'age': val.vOptionalProp<num>(val.vNumber()),
      });
      final ok = v.validate(<String, dynamic>{'name': 'Ada', 'age': 36});
      expect(ok.error, isNull);
      expect(ok.content!['name'], 'Ada');
      expect(ok.content!['age'], 36);

      final noAge = v.validate(<String, dynamic>{'name': 'Ada'});
      expect(noAge.error, isNull);
      expect(noAge.content!.containsKey('age'), isFalse);

      final bad = v.validate(<String, dynamic>{'name': 5});
      expect(bad.error!.message, "Error in property 'name': Expected string, but got number");
      expect(v.validate('not an object').error!.message, 'Expected object');
    });

    test('vArray / vTuple / vUnion / vEnum / vLiteral', () {
      expect(val.vArray<num>(val.vNumber()).validate(<dynamic>[1, 2, 3]).content, <dynamic>[1, 2, 3]);
      expect(val.vArray<num>(val.vNumber()).validate(<dynamic>[1, 'x']).error!.message,
          'Error in element 1: Expected number, but got string');

      final tuple = val.vTuple(<val.IValidator<dynamic>>[val.vString(), val.vNumber()]);
      expect(tuple.validate(<dynamic>['a', 1]).content, <dynamic>['a', 1]);
      expect(tuple.validate(<dynamic>['a']).error!.message,
          'Expected tuple of length 2, but got 1');

      final uni = val.vUnion<dynamic>(<val.IValidator<dynamic>>[val.vString(), val.vNumber()]);
      expect(uni.validate('a').content, 'a');
      expect(uni.validate(9).content, 9);
      expect(uni.validate(true).error, isNotNull);

      expect(val.vEnum<String>(<String>['a', 'b']).validate('a').error, isNull);
      expect(val.vEnum<String>(<String>['a', 'b']).validate('c').error!.message,
          'Expected one of: a, b');
      expect(val.vLiteral<String>('x').validate('x').error, isNull);
      expect(val.vLiteral<String>('x').validate('y').error!.message, 'Expected: x');
    });

    test('vLazy / vWithJsonSchemaRef / JSON schema shape', () {
      expect(val.vLazy<String>(() => val.vString()).validate('z').content, 'z');
      final ref = val.vWithJsonSchemaRef<String>('#/defs/S', val.vString());
      expect(ref.getJSONSchema()['\$ref'], '#/defs/S');
      expect(val.vString().getJSONSchema(), <String, Object?>{'type': 'string'});
      expect(val.vArray<num>(val.vNumber()).getJSONSchema()['type'], 'array');
      final objSchema = val.vObj(<String, Object?>{
        'a': val.vString(),
        'b': val.vOptionalProp<num>(val.vNumber()),
      }).getJSONSchema();
      expect(objSchema['type'], 'object');
      expect((objSchema['required'] as List).length, 1);
      expect(objSchema['required'], <String>['a']);
      // Union schema filters out UndefinedValidator
      final uniSchema = val.vUnion<dynamic>(<val.IValidator<dynamic>>[
        val.vUndefined(), val.vString(),
      ]).getJSONSchema();
      expect((uniSchema['oneOf'] as List).length, 1);
    });
  });

  group('network.ts (1:1)', () {
    test('Schemas constants', () {
      expect(net.Schemas.file, 'file');
      expect(net.Schemas.vscodeRemote, 'vscode-remote');
      expect(net.Schemas.vscodeFileResource, 'vscode-file');
      expect(net.Schemas.inMemory, 'inmemory');
    });

    test('matchesScheme / matchesSomeScheme', () {
      expect(net.matchesScheme(URI.parse('file:///a'), 'FILE'), isTrue);
      expect(net.matchesScheme('https://example', 'https'), isTrue);
      expect(net.matchesScheme('https://example', 'http'), isFalse);
      expect(net.matchesSomeScheme('file:///a', <String>['http', 'file']), isTrue);
    });

    test('getServerProductSegment', () {
      expect(net.getServerProductSegment(<String, Object?>{}), 'oss-dev');
      expect(
          net.getServerProductSegment(<String, Object?>{'quality': 'stable', 'commit': 'abc'}),
          'stable-abc');
    });

    test('RemoteAuthorities: set + rewrite + connection token', () {
      final ra = net.RemoteAuthoritiesImpl();
      ra.set('auth', 'example.com', 8080);
      ra.setConnectionToken('auth', 'tok');
      final uri = URI.parse('vscode-remote://auth/path/to/file');
      final rewritten = ra.rewrite(uri);
      expect(rewritten.scheme, net.Schemas.vscodeRemoteResource);
      expect(rewritten.authority, 'example.com:8080');
      expect(rewritten.query, contains('path=%2Fpath%2Fto%2Ffile'));
      expect(rewritten.query, contains('tkn=tok'));
    });

    test('RemoteAuthorities: IPv6 host bracketed, delegate', () {
      final ra = net.RemoteAuthoritiesImpl();
      ra.set('v6', '::1', 3000);
      expect(ra.rewrite(URI.parse('vscode-remote://v6/x')).authority, '[::1]:3000');
      final called = ra.rewrite(URI.parse('vscode-remote://other/x'));
      expect(called.authority, 'null:null'); // no host/port registered
      ra.setDelegate((u) => URI.parse('file:///delegated'));
      expect(ra.rewrite(URI.parse('vscode-remote://v6/x')).path, '/delegated');
    });

    test('FileAccess native URI round-trip (no authority)', () {
      final original = URI.file('network.test.ts');
      final browser = net.FileAccess.uriToBrowserUri(original);
      expect(browser.authority.isNotEmpty, isTrue);
      expect(browser.scheme, net.Schemas.vscodeFileResource);
      final file = net.FileAccess.uriToFileUri(browser);
      expect(file.authority.isEmpty, isTrue);
      expect(file.toString(), original.toString());
    });

    test('FileAccess native URI round-trip (with authority)', () {
      final original = URI.file('network.test.ts').withChanges(
          const UriChange(authority: 'test-authority'));
      final browser = net.FileAccess.uriToBrowserUri(original);
      expect(browser.authority, 'test-authority');
      final file = net.FileAccess.uriToFileUri(browser);
      expect(file.authority, 'test-authority');
    });

    test('FileAccess drops query/fragment on conversion; keeps if already vscode-file', () {
      final original = URI.file('network.test.ts').withChanges(
          const UriChange(query: 'foo=bar', fragment: 'something'));
      final browser = net.FileAccess.uriToBrowserUri(original);
      expect(browser.query, '');
      expect(browser.fragment, '');

      final alreadyCode = original.withChanges(const UriChange(scheme: net.Schemas.vscodeFileResource));
      final browser2 = net.FileAccess.uriToBrowserUri(alreadyCode);
      expect(browser2.query, 'foo=bar');
      expect(browser2.fragment, 'something');
      expect(net.FileAccess.uriToFileUri(original).query, 'foo=bar');
    });

    test('FileAccess remote URI changes scheme', () {
      final remote = URI.file('network.test.ts').withChanges(
          const UriChange(scheme: net.Schemas.vscodeRemote));
      final browser = net.FileAccess.uriToBrowserUri(remote);
      expect(browser.scheme, isNot(net.Schemas.vscodeRemote));
    });

    test('FileAccess toUri via module root (path and URL)', () {
      net.globalVSCodeFileRoot = '/root';
      // asFileUri keeps the file scheme; asBrowserUri converts file -> vscode-file on native.
      final u1 = net.FileAccess.asFileUri('vs/x');
      expect(u1.scheme, net.Schemas.file);
      expect(u1.path, '/root/vs/x');
      final b1 = net.FileAccess.asBrowserUri('vs/x');
      expect(b1.scheme, net.Schemas.vscodeFileResource);
      net.globalVSCodeFileRoot = 'file:///root';
      final u2 = net.FileAccess.asFileUri('vs/x');
      expect(u2.path, '/root/vs/x');
      net.globalVSCodeFileRoot = null;
    });

    test('COI headers from query', () {
      expect(net.COI.getHeadersFromQuery('http://x/?vscode-coi=3'),
          net.COI.CoopAndCoep);
      expect(net.COI.getHeadersFromQuery('http://x/?vscode-coi=1'),
          containsPair('Cross-Origin-Opener-Policy', 'same-origin'));
      expect(net.COI.getHeadersFromQuery('http://x/'), isNull);
      expect(net.COI.getHeadersFromQuery('http://x/?vscode-coi=zzz'), isNull);
    });
  });

  group('diff.ts (1:1)', () {
    // Mirror of diff.test.ts assertAnswer: apply changes as masks, keep common substring.
    void assertAnswer(String originalStr, String modifiedStr, List<diff.IDiffChange> changes, String answerStr,
        [bool onlyLength = false]) {
      final List<bool> originalMask = List<bool>.filled(originalStr.length, true);
      final List<bool> modifiedMask = List<bool>.filled(modifiedStr.length, true);
      for (final change in changes) {
        if (change.originalLength > 0) {
          for (int j = 0; j < change.originalLength; j++) {
            originalMask[change.originalStart + j] = false;
          }
        }
        if (change.modifiedLength > 0) {
          for (int j = 0; j < change.modifiedLength; j++) {
            modifiedMask[change.modifiedStart + j] = false;
          }
        }
      }
      String maskBased(String str, List<bool> mask) {
        final StringBuffer r = StringBuffer();
        for (int i = 0; i < str.length; i++) {
          if (mask[i]) r.write(str[i]);
        }
        return r.toString();
      }

      final String originalAnswer = maskBased(originalStr, originalMask);
      final String modifiedAnswer = maskBased(modifiedStr, modifiedMask);
      if (onlyLength) {
        expect(originalAnswer.length, answerStr.length);
        expect(modifiedAnswer.length, answerStr.length);
      } else {
        expect(originalAnswer, answerStr);
        expect(modifiedAnswer, answerStr);
      }
    }

    List<diff.IDiffChange> lcsChanges(String originalStr, String modifiedStr) =>
        diff.LcsDiff(diff.StringDiffSequence(originalStr), diff.StringDiffSequence(modifiedStr))
            .ComputeDiff(false)
            .changes;

    String stringPower(String str, int power) {
      String r = str;
      for (int i = 0; i < power; i++) {
        r += r;
      }
      return r;
    }

    void lcsInner(String originalStr, String modifiedStr, String answerStr, [bool onlyLength = false]) =>
        assertAnswer(originalStr, modifiedStr, lcsChanges(originalStr, modifiedStr), answerStr, onlyLength);

    void lcsTest(String originalStr, String modifiedStr, String answerStr) {
      lcsInner(originalStr, modifiedStr, answerStr);
      for (int i = 2; i <= 5; i++) {
        lcsInner(stringPower(originalStr, i), stringPower(modifiedStr, i),
            stringPower(answerStr, i), true);
      }
    }

    test('LcsDiff - different strings tests', () {
      lcsTest('heLLo world', 'hello orlando', 'heo orld');
      lcsTest('abcde', 'acd', 'acd');
      lcsTest('abcdbce', 'bcede', 'bcde');
      lcsTest('abcdefgabcdefg', 'bcehafg', 'bceafg');
      lcsTest('abcde', 'fgh', '');
      lcsTest('abcfabc', 'fabc', 'fabc');
      lcsTest('0azby0', '9axbzby9', 'azby');
      lcsTest('0abc00000', '9a1b2c399999', 'abc');
      lcsTest('fooBar', 'myfooBar', 'fooBar');
      lcsTest('fooBar', 'fooMyBar', 'fooBar');
      lcsTest('fooBar', 'fooBar', 'fooBar');
    });

    test('stringDiff does not split surrogate pairs', () {
      for (final bool pretty in <bool>[false, true]) {
        var c = diff.stringDiff('\u{2B7F9}', '\u{2B14D}', pretty);
        expect(c.length, 1);
        expect(c[0].originalStart, 0);
        expect(c[0].originalLength, 2);
        expect(c[0].modifiedStart, 0);
        expect(c[0].modifiedLength, 2);

        c = diff.stringDiff('a\u{1F600}b', 'a\u{1F603}b', pretty);
        expect(c.length, 1);
        expect(c[0].originalStart, 1);
        expect(c[0].originalLength, 2);

        c = diff.stringDiff('\u{1F600}a', '\u{1F600}b', pretty);
        expect(c.length, 1);
        expect(c[0].originalStart, 2);
        expect(c[0].originalLength, 1);
      }
    });

    test('stringDiff maps insertions/deletions at surrogate boundaries', () {
      final insertion = diff.stringDiff('a', 'a\u{1F600}', false);
      expect(insertion.length, 1);
      expect(insertion[0].originalStart, 1);
      expect(insertion[0].originalLength, 0);
      expect(insertion[0].modifiedStart, 1);
      expect(insertion[0].modifiedLength, 2);

      final deletion = diff.stringDiff('\u{1F600}a', 'a', false);
      expect(deletion.length, 1);
      expect(deletion[0].originalStart, 0);
      expect(deletion[0].originalLength, 2);
      expect(deletion[0].modifiedStart, 0);
      expect(deletion[0].modifiedLength, 0);
    });

    test('using continue processing predicate to quit early', () {
      const String left = 'abcdef';
      const String right = 'abxxcyyydzzzzezzzzzzzzzzzzzzzzzzzzf';

      int predicateCallCount = 0;
      var d = diff.LcsDiff(diff.StringDiffSequence(left), diff.StringDiffSequence(right),
          (int leftIndex, num longestMatchSoFar) {
        expect(predicateCallCount, 0);
        predicateCallCount++;
        expect(leftIndex, 1);
        return false;
      });
      var changes = d.ComputeDiff(true).changes;
      expect(predicateCallCount, 1);
      assertAnswer(left, right, changes, 'abf');

      d = diff.LcsDiff(diff.StringDiffSequence(left), diff.StringDiffSequence(right),
          (int leftIndex, num longestMatchSoFar) {
        expect(longestMatchSoFar <= 1, isTrue);
        return longestMatchSoFar < 1;
      });
      changes = d.ComputeDiff(true).changes;
      assertAnswer(left, right, changes, 'abcf');

      d = diff.LcsDiff(diff.StringDiffSequence(left), diff.StringDiffSequence(right),
          (int leftIndex, num longestMatchSoFar) {
        expect(longestMatchSoFar <= 2, isTrue);
        return longestMatchSoFar < 2;
      });
      changes = d.ComputeDiff(true).changes;
      assertAnswer(left, right, changes, 'abcdf');

      bool hitSecondMatch = false;
      d = diff.LcsDiff(diff.StringDiffSequence(left), diff.StringDiffSequence(right),
          (int leftIndex, num longestMatchSoFar) {
        expect(longestMatchSoFar <= 2, isTrue);
        final bool hitYet = hitSecondMatch;
        hitSecondMatch = longestMatchSoFar > 1;
        return !hitYet;
      });
      changes = d.ComputeDiff(true).changes;
      assertAnswer(left, right, changes, 'abcdf');

      d = diff.LcsDiff(diff.StringDiffSequence(left), diff.StringDiffSequence(right),
          (int leftIndex, num longestMatchSoFar) {
        expect(longestMatchSoFar <= 3, isTrue);
        return longestMatchSoFar < 3;
      });
      changes = d.ComputeDiff(true).changes;
      assertAnswer(left, right, changes, 'abcdef');
    });

    test('computeLevenshteinDistance', () {
      expect(diff.computeLevenshteinDistance('kitten', 'sitting'), 3);
      expect(diff.computeLevenshteinDistance('', 'abc'), 3);
      expect(diff.computeLevenshteinDistance('abc', ''), 3);
      expect(diff.computeLevenshteinDistance('same', 'same'), 0);
      expect(diff.computeLevenshteinDistance('flaw', 'lawn'), 2);
      // long-string branch (>32): single-char edit distance over a 40-char string
      final String a = 'a' * 40;
      final String b = 'a' * 20 + 'x' + 'a' * 19;
      expect(diff.computeLevenshteinDistance(a, b), 1);
      expect(diff.computeLevenshteinDistance(a, a), 0);
    });
  });

  group('filters.ts (1:1)', () {
    void filterOk(filters.IFilter filter, String word, String target, [List<filters.IMatch>? highlights]) {
      final List<filters.IMatch>? r = filter(word, target);
      expect(r, isNotNull, reason: '$word didn\'t match $target');
      if (highlights != null) expect(r, highlights);
    }

    void filterNotOk(filters.IFilter filter, String word, String target) {
      expect(filter(word, target), isNull, reason: '$word matched $target');
    }

    List<int>? fscore(String pattern, String word,
        {int patternPos = 0, int wordPos = 0, bool firstMatchCanBeWeak = false}) {
      return filters.fuzzyScore(pattern, pattern.toLowerCase(), patternPos,
          word, word.toLowerCase(), wordPos,
          filters.FuzzyScoreOptions(firstMatchCanBeWeak, true));
    }

    // Mirror of filters.test.ts assertMatches: '^' marks matched chars.
    void assertMatches(String pattern, String word, String? decoratedWord,
        {int patternPos = 0, int wordPos = 0, bool firstMatchCanBeWeak = false}) {
      final List<int>? r = fscore(pattern, word,
          patternPos: patternPos, wordPos: wordPos, firstMatchCanBeWeak: firstMatchCanBeWeak);
      expect(r == null, decoratedWord == null, reason: 'match presence for $pattern / $word');
      if (r != null) {
        final List<filters.IMatch> matches = filters.createMatches(r);
        final StringBuffer actual = StringBuffer();
        int pos = 0;
        for (final m in matches) {
          actual.write(word.substring(pos, m.start));
          actual.write('^');
          actual.write(word.substring(m.start, m.end).split('').join('^'));
          pos = m.end;
        }
        actual.write(word.substring(pos));
        expect(actual.toString(), decoratedWord);
      }
    }

    test('empty queries share immutable matches', () {
      for (final f in <filters.IFilter>[
        filters.matchesFuzzy,
        filters.matchesContiguousSubString,
        filters.matchesBaseContiguousSubString,
      ]) {
        expect(identical(f('', 'first'), filters.emptyMatches), isTrue);
        expect(identical(f('', ''), filters.emptyMatches), isTrue);
        expect(f('', '')![0].start, 0);
      }
    });

    test('or', () {
      final counters = <int>[0, 0];
      filters.IFilter newFilter(int i, bool r) => (String w, String t) {
        counters[i]++;
        return r ? <filters.IMatch>[filters.IMatch(0, 1)] : null;
      };
      filters.IFilter f = filters.or(<filters.IFilter>[newFilter(0, false), newFilter(1, false)]);
      filterNotOk(f, 'a', 'a');
      expect(counters, <int>[1, 1]);
      counters.setAll(0, <int>[0, 0]);
      f = filters.or(<filters.IFilter>[newFilter(0, true), newFilter(1, false)]);
      filterOk(f, 'a', 'a');
      expect(counters, <int>[1, 0]);
    });

    test('matchesStrictPrefix / matchesPrefix', () {
      filterNotOk(filters.matchesStrictPrefix, '', '');
      filterOk(filters.matchesStrictPrefix, '', 'anything', <filters.IMatch>[]);
      filterOk(filters.matchesStrictPrefix, 'alpha', 'alpha', <filters.IMatch>[filters.IMatch(0, 5)]);
      filterNotOk(filters.matchesStrictPrefix, 'alpha', 'alp');
      filterNotOk(filters.matchesStrictPrefix, 'A', 'alpha');
      filterOk(filters.matchesPrefix, 'ä', 'Älpha', <filters.IMatch>[filters.IMatch(0, 1)]);
      filterOk(filters.matchesPrefix, 'A', 'alpha', <filters.IMatch>[filters.IMatch(0, 1)]);
      filterOk(filters.matchesPrefix, 'AlPh', 'alPHA', <filters.IMatch>[filters.IMatch(0, 4)]);
      filterNotOk(filters.matchesPrefix, 'T', '4');
    });

    test('matchesCamelCase', () {
      filterNotOk(filters.matchesCamelCase, '', '');
      filterOk(filters.matchesCamelCase, 'alpha', 'alpha', <filters.IMatch>[filters.IMatch(0, 5)]);
      filterOk(filters.matchesCamelCase, 'AlPhA', 'alpha', <filters.IMatch>[filters.IMatch(0, 5)]);
      filterOk(filters.matchesCamelCase, 'c', 'CamelCaseRocks', <filters.IMatch>[filters.IMatch(0, 1)]);
      filterOk(filters.matchesCamelCase, 'cc', 'CamelCaseRocks',
          <filters.IMatch>[filters.IMatch(0, 1), filters.IMatch(5, 6)]);
      filterOk(filters.matchesCamelCase, 'cacar', 'CamelCaseRocks',
          <filters.IMatch>[filters.IMatch(0, 2), filters.IMatch(5, 7), filters.IMatch(9, 10)]);
      filterNotOk(filters.matchesCamelCase, 'alpha', 'alp');
    });

    test('matchesContiguousSubString / matchesBaseContiguousSubString / matchesSubString', () {
      filterOk(filters.matchesContiguousSubString, '', 'x', <filters.IMatch>[filters.IMatch(0, 0)]);
      filterOk(filters.matchesContiguousSubString, 'abc', 'xxabcxx', <filters.IMatch>[filters.IMatch(2, 5)]);
      filterNotOk(filters.matchesContiguousSubString, 'ab c', 'xxabcxx');
      filterOk(filters.matchesSubString, 'ab', 'aXXb', <filters.IMatch>[filters.IMatch(0, 1), filters.IMatch(3, 4)]);
      filterNotOk(filters.matchesSubString, 'abc', 'acb');
    });

    test('matchesWords', () {
      filterOk(filters.matchesWords, 'g p', 'Git: Pull', <filters.IMatch>[
        filters.IMatch(0, 1), filters.IMatch(5, 6),
      ]);
      filterOk(filters.matchesWords, 'gp', 'Git: Pull', <filters.IMatch>[
        filters.IMatch(0, 1), filters.IMatch(5, 6),
      ]);
      filterNotOk(filters.matchesWords, 'xyz', 'Git: Pull');
    });

    test('matchesFuzzy', () {
      // Regex path: literal substring match returns a single contiguous range.
      filterOk(filters.matchesFuzzy, 'am', 'CamelCase', <filters.IMatch>[filters.IMatch(1, 3)]);
      // Fallback filter path (camelCase) when regex fails.
      filterOk(filters.matchesFuzzy, 'cc', 'CamelCase');
      filterNotOk(filters.matchesFuzzy, 'zz', 'CamelCase');
    });

    test('fuzzyScore core cases', () {
      assertMatches('tit', 'win.tit', 'win.^t^i^t');
      assertMatches('title', 'win.title', 'win.^t^i^t^l^e');
      assertMatches('WordCla', 'WordCharacterClassifier', '^W^o^r^dCharacter^C^l^assifier');
      assertMatches('ab', 'abA', '^a^bA');
      assertMatches('ccm', 'cacmelCase', '^ca^c^melCase');
      assertMatches('BK', 'the_black_knight', 'the_^black_^knight');
      assertMatches('TEdit', 'TextEdit', '^Text^E^d^i^t');
      assertMatches('-moz', '-moz-foo', '^-^m^o^z-foo');
      assertMatches('moz', '-moz-foo', '-^m^o^z-foo');
      assertMatches('close', 'workbench.quickOpen.closeOnFocusOut', 'workbench.quickOpen.^c^l^o^s^eOnFocusOut');
      assertMatches('highlight', 'editorHoverHighlight', 'editorHover^H^i^g^h^l^i^g^h^t');
      assertMatches('dete', '"editor.quickSuggestionsDelay"', null);
      assertMatches('bti', 'the_black_knight', null);
      assertMatches('ccm', 'camelCase', null);
    });

    test('fuzzyScore firstMatchCanBeWeak', () {
      // Source: fuzzyScore (first match can be weak)
      assertMatches('Three', 'HTMLHRElement', 'H^TML^H^R^El^ement', firstMatchCanBeWeak: true);
      assertMatches('tor', 'constructor', 'construc^t^o^r', firstMatchCanBeWeak: true);
      assertMatches('ur', 'constructor', 'constr^ucto^r', firstMatchCanBeWeak: true);
      // Weak match without option => no match
      assertMatches('tor', 'constructor', null);
    });

    test('createMatches / isPatternInWord / graceful', () {
      expect(filters.createMatches(null), isEmpty);
      expect(filters.isPatternInWord('abc', 0, 3, 'aXbYc', 0, 5), isTrue);
      expect(filters.isPatternInWord('abc', 0, 3, 'acb', 0, 3), isFalse);
      final graceful = filters.fuzzyScoreGraceful('cno', 'cno', 0, 'console', 'console', 0);
      expect(graceful, isNotNull);
      expect(filters.FuzzyScoreNS.isDefault(filters.FuzzyScoreNS.Default), isTrue);
      expect(filters.nextTypoPermutation('cnoso', 1), 'conso');
      expect(filters.anyScore('ab', 'ab', 0, 'ab', 'ab', 0)[0] > 0, isTrue);
    });
  });

  group('resources.ts', () {
    test('distinctParents', () {
      List<URI> uris = <URI>[
        URI.file('/some/folderA/file.txt'),
        URI.file('/some/folderB/file.txt'),
        URI.file('/some/folderC/file.txt'),
      ];
      List<URI> distinct = resources.distinctParents<URI>(uris, (URI r) => r);
      expect(distinct.length, 3);
      expect(distinct[0].toString(), uris[0].toString());
      expect(distinct[1].toString(), uris[1].toString());
      expect(distinct[2].toString(), uris[2].toString());

      uris = <URI>[
        URI.file('/some/folderA'),
        URI.file('/some/folderA/file.txt'),
        URI.file('/some/folderA/child/file.txt'),
        URI.file('/some/folderA2/file.txt'),
        URI.file('/some/file.txt'),
      ];
      distinct = resources.distinctParents<URI>(uris, (URI r) => r);
      expect(distinct.length, 3);
      expect(distinct[0].toString(), uris[0].toString());
      expect(distinct[1].toString(), uris[3].toString());
      expect(distinct[2].toString(), uris[4].toString());
    });

    test('dirname / basename / extname', () {
      if (!pf.isWindows) {
        expect(resources.dirname(URI.file('/some/file/test.txt')).toString(),
            'file:///some/file');
        expect(resources.dirname(URI.file('/some/file/')).toString(),
            'file:///some');
        expect(resources.dirname(URI.file('/some/file')).toString(),
            'file:///some');
        expect(resources.basename(URI.file('/some/file/test.txt')), 'test.txt');
        expect(resources.basename(URI.file('/some/file/')), 'file');
        expect(resources.basename(URI.file('/some')), 'some');
      }
      expect(resources.dirname(URI.parse('foo://a/some/file/test.txt')).toString(),
          'foo://a/some/file');
      expect(resources.dirname(URI.parse('foo://a/some')).toString(), 'foo://a/');
      expect(resources.dirname(URI.parse('foo://a')).toString(), 'foo://a');
      expect(resources.dirname(URI.parse('foo://a/b/c?q')).toString(),
          'foo://a/b?q');
      expect(resources.basename(URI.parse('foo://a/some/file/')), 'file');
      expect(resources.basename(URI.parse('foo://a/')), '');
      expect(resources.extname(URI.parse('foo://a/file.txt')), '.txt');
      expect(resources.basenameOrAuthority(URI.parse('foo://a')), 'a');
    });

    test('joinPath / normalizePath / relativePath / resolvePath', () {
      if (!pf.isWindows) {
        expect(resources.joinPath(URI.file('/foo/bar'), <String>['/file.js'])
            .toString(), 'file:///foo/bar/file.js');
        expect(resources.joinPath(URI.file('/foo/bar'), <String>['../file.js'])
            .toString(), 'file:///foo/file.js');
      }
      expect(resources.joinPath(URI.parse('foo://a/foo/bar'), <String>[])
          .toString(), 'foo://a/foo/bar');
      expect(resources.joinPath(URI.parse('foo://a/foo/bar/'), <String>['/file.js'])
          .toString(), 'foo://a/foo/bar/file.js');
      expect(
          resources
              .joinPath(
                  URI.parse(
                      'myScheme://authority/path?query#fragment'),
                  <String>['/file.js'])
              .toString(),
          'myScheme://authority/path/file.js?query#fragment');

      expect(resources.normalizePath(URI.parse('foo://a/b/../c')).toString(),
          'foo://a/c');
      expect(resources.relativePath(URI.parse('foo://a/b/c'), URI.parse('foo://a/b/d/e')),
          '../d/e');
      expect(resources.relativePath(URI.parse('foo://a/b'), URI.parse('bar://a/b')),
          isNull);
      expect(resources.resolvePath(URI.parse('foo://a/b/c'), '../d').toString(),
          'foo://a/b/d');
    });

    test('comparison / trailing separators', () {
      expect(resources.extUri.isEqual(URI.parse('foo://a/b'), URI.parse('foo://a/b')),
          isTrue);
      expect(resources.extUri.isEqual(URI.parse('foo://a/b'), URI.parse('foo://a/B')),
          isFalse);
      expect(
          resources.extUriIgnorePathCase
              .isEqual(URI.parse('foo://a/b'), URI.parse('foo://a/B')),
          isTrue);
      expect(
          resources.extUri.isEqualOrParent(
              URI.parse('foo://a/b/c'), URI.parse('foo://a/b')),
          isTrue);
      expect(resources.extUri.getComparisonKey(URI.parse('foo://a/b'), true),
          'foo://a/b');
      expect(resources.extUri.ignorePathCasing(URI.parse('foo://a/b')), isFalse);
      expect(resources.extUri.compare(URI.parse('foo://a/a'), URI.parse('foo://a/b')) < 0,
          isTrue);
      expect(resources.isAbsolutePath(URI.parse('foo://a/b')), isTrue);
      expect(resources.isAbsolutePath(URI.parse('foo://a')), isFalse);
      expect(resources.isEqualAuthority('AUTH', 'auth'), isTrue);

      final URI withSep = URI.parse('foo://a/b/');
      expect(resources.hasTrailingPathSeparator(withSep), isTrue);
      expect(resources.removeTrailingPathSeparator(withSep).path, '/b');
      expect(
          resources.addTrailingPathSeparator(URI.parse('foo://a/b')).path, '/b/');
      expect(resources.addTrailingPathSeparator(URI.parse('foo://a/')).path, '/');
    });

    test('DataUri / toLocalResource / originalFSPath', () {
      final Map<String, String> meta = resources.DataUri.parseMetaData(
          URI.parse(
              'data:image/png;size:2313;label:SomeLabel;description:SomeDescription;base64,77+9UE5'));
      expect(meta[resources.DataUri.META_DATA_MIME], 'image/png');
      expect(meta[resources.DataUri.META_DATA_SIZE], '2313');
      expect(meta[resources.DataUri.META_DATA_LABEL], 'SomeLabel');
      expect(meta[resources.DataUri.META_DATA_DESCRIPTION], 'SomeDescription');

      expect(
          resources
              .toLocalResource(URI.parse('foo://authority/path'), 'remote', 'vscode-remote')
              .toString(),
          'vscode-remote://remote/path');
      expect(
          resources
              .toLocalResource(URI.parse('foo://authority/path'), null, 'vscode-remote')
              .toString(),
          'vscode-remote://authority/path');
      if (!pf.isWindows) {
        expect(resources.originalFSPath(URI.file('/some/file')), '/some/file');
      }
    });
  });

  group('remoteHosts.ts', () {
    test('getRemoteAuthority / getRemoteName / getRemoteServerRootPath', () {
      expect(
          remoteHosts.getRemoteAuthority(URI.parse('vscode-remote://ssh+host/path')),
          'ssh+host');
      expect(remoteHosts.getRemoteAuthority(URI.file('/path')), isNull);
      expect(remoteHosts.getRemoteName(null), isNull);
      expect(remoteHosts.getRemoteName(''), isNull);
      expect(remoteHosts.getRemoteName('localhost:8000'), 'localhost:8000');
      expect(remoteHosts.getRemoteName('ssh+host'), 'ssh');
      expect(remoteHosts.getRemoteServerRootPath(null), isNull);
      expect(remoteHosts.getRemoteServerRootPath('localhost:8000'), isNull);
      expect(remoteHosts.getRemoteServerRootPath('tunnel+myTunnel'), 'myTunnel');
    });

    test('parseAuthorityWithPort / WithOptionalPort', () {
      final a = remoteHosts.parseAuthorityWithPort('localhost:8080');
      expect(a.host, 'localhost');
      expect(a.port, 8080);
      final b = remoteHosts.parseAuthorityWithPort('127.0.0.1:8080');
      expect(b.host, '127.0.0.1');
      expect(b.port, 8080);
      final c = remoteHosts.parseAuthorityWithPort(
          '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]:8080');
      expect(c.host, '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]');
      expect(c.port, 8080);

      final d = remoteHosts.parseAuthorityWithOptionalPort('localhost', 123);
      expect(d.host, 'localhost');
      expect(d.port, 123);
      final e = remoteHosts.parseAuthorityWithOptionalPort(
          '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]', 123);
      expect(e.host, '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]');
      expect(e.port, 123);
      final f = remoteHosts.parseAuthorityWithOptionalPort(
          'codespaces+aaaaa-aaaaa-aaaa-aaaaa-a111aa111', 123);
      expect(f.host, 'codespaces+aaaaa-aaaaa-aaaa-aaaaa-a111aa111');
      expect(f.port, 123);
      expect(() => remoteHosts.parseAuthorityWithPort('localhost'), throwsA(isA<StateError>()));
    });

    test('isLoopbackHost', () {
      for (final String host in <String>[
        'localhost', 'LOCALHOST', '127.0.0.1', '::1', '[::1]'
      ]) {
        expect(remoteHosts.isLoopbackHost(host), isTrue, reason: host);
      }
      for (final String host in <String>[
        'evil.com', '192.168.0.1', '10.0.0.1',
        '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]'
      ]) {
        expect(remoteHosts.isLoopbackHost(host), isFalse, reason: host);
      }
    });
  });

}

void _assertTstDfs<E>(tst.TernarySearchTree<String, E> trie,
    List<MapEntry<String, E>> elements) {
  expect(trie.isBalanced(), isTrue, reason: 'TST is not balanced');

  final List<MapEntry<String, E>> actual = trie.toList();
  expect(actual.length, elements.length);
  for (int i = 0; i < actual.length; i++) {
    expect(actual[i].key, elements[i].key);
    expect(actual[i].value, elements[i].value);
  }

  final Map<String, E> map = <String, E>{};
  for (final MapEntry<String, E> e in elements) {
    map[e.key] = e.value;
  }
  map.forEach((String key, E value) {
    expect(trie.get(key), value);
  });

  int forEachCount = 0;
  trie.forEach((E value, String key) {
    expect(value, map[key]);
    forEachCount++;
  });
  expect(map.length, forEachCount);

  int iterCount = 0;
  for (final MapEntry<String, E> e in trie.entries) {
    expect(e.value, map[e.key]);
    iterCount++;
  }
  expect(map.length, iterCount);
}

void _writeU16LE(Uint8List bytes, int offset, int value) {
  ByteData.view(bytes.buffer).setUint16(offset, value, Endian.little);
}

class _MsgErr {
  final String message;
  _MsgErr(this.message);
}

class _DetailErr {
  final Object detail;
  _DetailErr(this.detail);
}

class _DetailInner {
  final Object error;
  _DetailInner(this.error);
}

class _TestPager implements paging.IPager<int> {
  final List<int> all;
  final int pageSize;
  int getPageCalls = 0;

  _TestPager(this.all, this.pageSize);

  @override
  List<int> get firstPage => all.take(pageSize).toList();

  @override
  int get total => all.length;

  @override
  Future<List<int>> getPage(int pageIndex, cancellation.CancellationToken token) async {
    getPageCalls++;
    final int start = pageIndex * pageSize;
    return all.skip(start).take(pageSize).toList();
  }
}

class _TestIterativePage implements paging.IIterativePage<int> {
  final List<int> items;
  final bool hasMore;
  _TestIterativePage(this.items, this.hasMore);
}

class _TestIterativePager implements paging.IIterativePager<int> {
  int getNextPageCalls = 0;
  final List<List<int>> pages = <List<int>>[
    <int>[1, 2],
    <int>[3],
  ];

  @override
  paging.IIterativePage<int> get firstPage =>
      _TestIterativePage(pages[0], true);

  @override
  Future<paging.IIterativePage<int>> getNextPage(
      cancellation.CancellationToken token) async {
    final int idx = ++getNextPageCalls;
    return _TestIterativePage(pages[idx], false);
  }
}

class _MemoTarget {
  int calls = 0;
  int compute() {
    calls++;
    return calls;
  }
}

class _SumTarget {
  int sum = 0;
  int? lastArg;
  void add(int value) {
    sum = value;
    lastArg = value;
  }
}

class _TestHistory implements hist.IHistory<String> {
  final Set<String> _set;
  final ev.Event<List<String>>? _onDidChange;

  _TestHistory(Iterable<String> values, [this._onDidChange])
      : _set = <String>{...values};

  @override
  bool delete(String t) => _set.remove(t);

  @override
  hist.IHistory<String> add(String t) {
    _set.add(t);
    return this;
  }

  @override
  bool has(String t) => _set.contains(t);

  @override
  void clear() => _set.clear();

  @override
  void forEach(void Function(String value, String value2, Set<String> set) callbackfn,
      [Object? thisArg]) {
    for (final String value in _set) {
      callbackfn(value, value, _set);
    }
  }

  @override
  void Function(List<String> values)? get replace => null;

  @override
  ev.Event<List<String>>? get onDidChange => _onDidChange;
}

class _ActionWithAlt implements actions.IAction {
  @override
  final actions.IAction? alt;
  _ActionWithAlt(this.alt);

  @override
  String get id => 'main';
  @override
  String get label => 'main';
  @override
  String get tooltip => '';
  @override
  String? get cssClass => null;
  @override
  bool get enabled => true;
  @override
  bool? get checked => null;
  @override
  FutureOr<Object?> run([Object? event, Object? data]) async => null;
}

class _Decorated extends lc.Disposable {
  final List<List<Object?>> calls1 = <List<Object?>>[];
  final List<List<Object?>> calls2 = <List<Object?>>[];

  Future<void> one(int a, String b, [cancellation.CancellationToken? token]) async {
    calls1.add(<Object?>[a, b, token]);
  }

  Future<void> two(int a, String b, [cancellation.CancellationToken? token]) async {
    calls2.add(<Object?>[a, b, token]);
  }
}

class _TestRefCollection extends lc.ReferenceCollection<int> {
  final void Function() _onCreated;
  final void Function(int) _onDestroyed;
  int _next = 0;
  _TestRefCollection(this._onCreated, this._onDestroyed);

  @override
  int createReferencedObject(String key, List<Object?> args) {
    _onCreated();
    return ++_next;
  }

  @override
  void destroyReferencedObject(String key, int object) {
    _onDestroyed(object);
  }
}

class _EventCounter {
  int count = 0;
  void onEvent(dynamic e) => count++;
}
