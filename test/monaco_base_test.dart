// Regression tests for base/common files in the 1:1 Monaco port.
// Assertions mirror the semantics of the TypeScript originals.

import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/nls.dart';
import 'package:semi_design_flutter/src/monaco/base/common/assert.dart';
import 'package:semi_design_flutter/src/monaco/base/common/errors.dart';
import 'package:semi_design_flutter/src/monaco/base/common/collections.dart';
import 'package:semi_design_flutter/src/monaco/base/common/functional.dart';
import 'package:semi_design_flutter/src/monaco/base/common/iterator.dart';
import 'package:semi_design_flutter/src/monaco/base/common/lazy.dart';
import 'package:semi_design_flutter/src/monaco/base/common/linkedList.dart';
import 'package:semi_design_flutter/src/monaco/base/common/map.dart';
import 'package:semi_design_flutter/src/monaco/base/common/marshallingIds.dart';
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
}
