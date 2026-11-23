// Regression tests for base/common files in the 1:1 Monaco port.
// Assertions mirror the semantics of the TypeScript originals.

import 'dart:convert';

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
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart';
import 'package:semi_design_flutter/src/monaco/base/common/path.dart' as path;
import 'package:semi_design_flutter/src/monaco/base/common/platform.dart' as pf;
import 'package:semi_design_flutter/src/monaco/base/common/process.dart' as pr;
import 'package:semi_design_flutter/src/monaco/base/common/stopwatch.dart';
import 'package:semi_design_flutter/src/monaco/base/common/symbols.dart';
import 'package:semi_design_flutter/src/monaco/base/common/types.dart';

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
}
