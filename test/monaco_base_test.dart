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
import 'package:semi_design_flutter/src/monaco/base/common/marshallingIds.dart';
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
}
