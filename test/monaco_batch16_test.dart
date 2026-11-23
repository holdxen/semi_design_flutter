// 1:1 port parity tests for batch 16:
//   base/common/fuzzyScorer.ts
//   base/common/labels.ts
//   editor/test/common/core/random.ts
//   base/common/observableInternal/commonFacade/cancellation.ts
//   platform/actionWidget/common/actionWidget.ts
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/fuzzyScorer.dart' as fz;
import 'package:semi_design_flutter/src/monaco/base/common/labels.dart' as lbl;
import 'package:semi_design_flutter/src/monaco/base/common/path.dart' as path;
import 'package:semi_design_flutter/src/monaco/base/common/platform.dart' as platform;
import 'package:semi_design_flutter/src/monaco/base/common/cancellation.dart' as cancel;
import 'package:semi_design_flutter/src/monaco/base/common/errors.dart' as err;
import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/commonFacade/cancellation.dart' as cfacade;
import 'package:semi_design_flutter/src/monaco/editor/test/common/core/random.dart' as rnd;
import 'package:semi_design_flutter/src/monaco/editor/common/core/ranges/offsetRange.dart' as rng;
import 'package:semi_design_flutter/src/monaco/platform/actionWidget/common/actionWidget.dart' as aw;

class _Accessor implements fz.IItemAccessor<String> {
  @override
  String? getItemLabel(String item) => item;
  @override
  String? getItemDescription(String item) => null;
  @override
  String? getItemPath(String item) => null;
}

class _PathAccessor implements fz.IItemAccessor<String> {
  @override
  String? getItemLabel(String item) => path.basename(item);
  @override
  String? getItemDescription(String item) => path.dirname(item);
  @override
  String? getItemPath(String item) => item;
}

fz.FuzzyScore _score(String target, String query, [bool? allow]) {
  final fz.IPreparedQuery pq = fz.prepareQuery(query);
  return fz.scoreFuzzy(target, pq.normalized, pq.normalizedLowercase, allow ?? !pq.expectContiguousMatch);
}

void main() {
  group('batch16: fuzzyScorer', () {
    test('scoreFuzzy returns descending scores for HelLo-World (source parity)', () {
      const String target = 'HelLo-World';
      final List<int> scores = [
        for (final String q in ['HelLo-World', 'hello-world', 'HW', 'hw', 'H', 'h', 'W', 'Ld', 'ld', 'w', 'L', 'l'])
          _score(target, q).score,
      ];
      for (int i = 1; i < scores.length; i++) {
        expect(scores[i - 1] >= scores[i], isTrue, reason: '$scores must be descending');
      }
      // exact values cross-checked against the TS algorithm
      expect(scores, [280, 277, 16, 14, 10, 9, 6, 6, 5, 5, 4, 3]);
    });

    test('scoreFuzzy no match and impossible length', () {
      expect(_score('HelLo-World', '4').score, 0);
      expect(_score('HelLo-World', '4').positions, isEmpty);
      expect(fz.scoreFuzzy('abc', 'abcd', 'abcd', true).score, 0);
      expect(fz.scoreFuzzy('', 'a', 'a', true).score, 0);
    });

    test('scoreFuzzy contiguous match positions (source parity)', () {
      final fz.FuzzyScore r = _score('HelLo-World', 'HW', true);
      expect(r.positions, [0, 6]);
      expect(_score('HelLo-World', 'HelLo-World', false).positions.length, 'HelLo-World'.length);
    });

    test('scoreFuzzy non-contiguous behaves per source', () {
      expect(_score('HelLo-World', 'HW', false).score, 0);
      expect(_score('HelLo-World', 'h', false).score, greaterThan(0));
      expect(_score('HelLo-World', 'eo', false).score, 0);
    });

    test('prepareQuery normalization (source parity)', () {
      expect(fz.prepareQuery('f*a').normalized, 'fa');
      expect(fz.prepareQuery('f…a').normalized, 'fa');
      expect(fz.prepareQuery('main#').normalized, 'main');
      expect(fz.prepareQuery('main#').original, 'main#');
      expect(fz.prepareQuery('foo*').normalized, 'foo');
      expect(fz.prepareQuery('model Tester.ts').normalized, 'modelTester.ts');
      expect(fz.prepareQuery('"hello"').expectContiguousMatch, isTrue);
      expect(fz.prepareQuery('"hello"').normalized, 'hello');
    });

    test('prepareQuery splits values on whitespace', () {
      final fz.IPreparedQuery q = fz.prepareQuery('He*llo World');
      expect(q.normalized, 'HelloWorld');
      expect(q.values?.length, 2);
      expect(q.values![0].original, 'He*llo');
      expect(q.values![0].normalized, 'Hello');
      expect(q.values![1].original, 'World');

      final fz.IPreparedQuery multi = fz.prepareQuery(' Hello   World  ');
      expect(multi.normalized, 'HelloWorld');
      expect(multi.values?.length, 2);
    });

    test('pieceToQuery round-trips values', () {
      final fz.IPreparedQuery q = fz.prepareQuery('He*llo World');
      final fz.IPreparedQuery restored = fz.pieceToQuery(q.values!);
      expect(restored.original, q.original);
      expect(restored.values?.length, q.values?.length);
      expect(fz.pieceToQuery(q.values![0]).original, 'He*llo');
    });

    test('scoreItemFuzzy identity matches full path', () {
      // Source ResourceAccessor: label = basename, description = dirname, path = fsPath.
      const String fullPath = '/xyz/some/path/someFile123.txt';
      final fz.IPreparedQuery q = fz.prepareQuery(fullPath);
      final fz.IItemScore res = fz.scoreItemFuzzy(fullPath, q, true, _PathAccessor(), <Object, fz.IItemScore>{});
      expect(res.score, greaterThan(0));
      expect(res.labelMatch, isNotNull);
    });

    test('scoreItemFuzzy invalid input -> no score', () {
      final fz.IPreparedQuery q = fz.prepareQuery('something');
      expect(fz.scoreItemFuzzy<String?>(null, q, true, _Accessor(), <Object, fz.IItemScore>{}).score, 0);
      expect(fz.scoreItemFuzzy('', fz.prepareQuery(''), true, _Accessor(), <Object, fz.IItemScore>{}).score, 0);
    });

    test('scoreItemFuzzy caches by hash', () {
      final fz.FuzzyScorerCache cache = <Object, fz.IItemScore>{};
      final fz.IPreparedQuery q = fz.prepareQuery('abc');
      fz.scoreItemFuzzy('abcFile', q, true, _Accessor(), cache);
      expect(cache.length, 1);
      final fz.IItemScore again = fz.scoreItemFuzzy('abcFile', q, true, _Accessor(), cache);
      expect(cache.length, 1);
      expect(again.score, greaterThan(0));
    });

    test('scoreFuzzy2 single and multiple (source parity)', () {
      final fz.IPreparedQuery pq = fz.prepareQuery('abc');
      final fz.FuzzyScore2 single = fz.scoreFuzzy2('abcFile', pq);
      expect(single.score, isNotNull);
      expect(single.matches, isNotEmpty);

      final fz.IPreparedQuery multi = fz.prepareQuery('abc def');
      final fz.FuzzyScore2 none = fz.scoreFuzzy2('abc only', multi);
      expect(none.score, isNull);
    });

    test('compareItemsByFuzzyScore prefers label match', () {
      final fz.IPreparedQuery q = fz.prepareQuery('file');
      final fz.FuzzyScorerCache cache = <Object, fz.IItemScore>{};
      expect(fz.compareItemsByFuzzyScore('file.txt', 'other-file.txt', q, true, _Accessor(), cache), lessThan(0));
    });
  });

  group('batch16: labels', () {
    test('shorten paths (source algorithm parity)', () {
      expect(lbl.shorten(['a/b/c/d', 'a/f/b/c/d'], '/'), ['a/b/…', '…/f/…']);
      expect(lbl.shorten(['a/b', 'a/b/c'], '/'), ['…/b', '…/c']);
      expect(lbl.shorten(['/etc/hosts', '/etc/hosts2'], '/'), ['/etc/hosts', '/etc/hosts2']);
    });

    test('shorten preserves url schema and trailing slash', () {
      expect(lbl.shorten(['file:///a/b/c', 'file:///a/x/c'], '/'), ['file:///…/b/…', 'file:///…/x/…']);
      expect(lbl.shorten([''], '/'), ['./']);
    });

    test('tildify and untildify', () {
      expect(lbl.tildify('/home/user/foo', '/home/user', platform.OperatingSystem.Linux), '~/foo');
      expect(lbl.tildify('/etc/hosts', '/home/user', platform.OperatingSystem.Linux), '/etc/hosts');
      expect(lbl.tildify('/any', '/any', platform.OperatingSystem.Windows), '/any');
      expect(lbl.untildify('~/foo', '/home/user'), '/home/user/foo');
      expect(lbl.untildify('~\\foo', '/home/user'), '/home/user\\foo');
      expect(lbl.untildify('plain', '/home/user'), 'plain');
    });

    test('normalizeDriveLetter', () {
      expect(lbl.normalizeDriveLetter('c:\\foo', true), 'C:\\foo');
      expect(lbl.normalizeDriveLetter('/foo', true), '/foo');
    });

    test('template variables, separators, and de-duplication', () {
      expect(lbl.template(r'this ${is} a ${template}', {'is': 'is', 'template': 'template'}), 'this is a template');
      expect(lbl.template(r'${a}${sep}${b}', {'a': 'A', 'b': 'B', 'sep': lbl.ISeparator('/')}), 'A/B');
      expect(lbl.template(r'${a}${sep}${sep}${b}', {'a': 'A', 'b': 'B', 'sep': lbl.ISeparator('/')}), 'A/B');
      expect(lbl.template(r'${a}', {'a': ''}), '');
    });

    test('mnemonic labels obey host OS', () {
      // Source: on macOS mnemonics are stripped; on Linux &&->& and &->&&;
      // on Windows &&->& and &->&&.
      // Source always strips `&&` (or `(&&\w)`) first, even when disabling.
      expect(lbl.mnemonicMenuLabel('File && Open', true), 'File  Open');
      final lbl.MnemonicButtonLabelResult r = lbl.mnemonicButtonLabel('&&File');
      expect(r.withoutMnemonic, 'File');
      if (platform.isMacintosh) {
        expect(lbl.mnemonicMenuLabel('File && Open'), 'File  Open');
        expect(r.withMnemonic, 'File');
      } else if (platform.isWindows) {
        expect(lbl.mnemonicMenuLabel('File && Open'), 'File & Open');
        expect(r.withMnemonic, '&&File');
      } else {
        expect(lbl.mnemonicMenuLabel('File && Open'), 'File & Open');
        expect(r.withMnemonic, '_File');
      }
      expect(lbl.unmnemonicLabel('&'), '&&');
    });

    test('splitRecentLabel handles workspace suffix', () {
      expect(lbl.splitRecentLabel('/a/b/name [Remote]'), {'name': 'name [Remote]', 'parentPath': '/a/b'});
      expect(lbl.splitRecentLabel('/a/b/name'), {'name': 'name', 'parentPath': '/a/b'});
    });
  });

  group('batch16: random', () {
    test('MersenneTwister nextIntRange matches JS reference sequence', () {
      final rnd.Random m = rnd.Random.create(42);
      final List<int> seq = List<int>.generate(12, (_) => m.nextIntRange(0, 100));
      expect(seq, [37, 79, 95, 18, 73, 77, 59, 59, 15, 44, 15, 9]);
    });

    test('MersenneTwister byte values match JS reference', () {
      final rnd.Random m = rnd.Random.create(1);
      final List<int> bytes = List<int>.generate(10, (_) => m.nextIntRange(0, 256));
      expect(bytes, [106, 255, 184, 238, 0, 32, 77, 255, 37, 60]);
    });

    test('nextUuid is deterministic, version 4, correct shape', () {
      final rnd.Random m = rnd.Random.create(1);
      final String uuid = m.nextUuid();
      expect(uuid, '6affb8ee-0020-4dff-a53c-17652f6358ab');
      expect(uuid.length, 36);
      expect(uuid.split('-').map((String p) => p.length), [8, 4, 4, 4, 12]);
      expect(uuid[14], '4');
      expect('89ab'.contains(uuid[19]), isTrue);
    });

    test('stringGenerator and nextString use alphabet', () {
      final rnd.Random m = rnd.Random.create(7);
      final rnd.IGenerator<String> gen = m.stringGenerator('ab');
      final String s = m.nextString(8, gen);
      expect(s.length, 8);
      expect(RegExp(r'^[ab]+$').hasMatch(s), isTrue);
    });

    test('nextMultiLineString joins lines with newline', () {
      final rnd.Random m = rnd.Random.create(2);
      final String s = m.nextMultiLineString(3, rng.OffsetRange(2, 5), m.stringGenerator('ab'));
      expect(s.split('\n').length, 3);
      for (final String line in s.split('\n')) {
        expect(line.length, inInclusiveRange(2, 4));
      }
    });

    test('nextConsecutiveOffsets sorts ascending', () {
      final rnd.Random m = rnd.Random.create(9);
      final List<int> offsets = m.nextConsecutiveOffsets(rng.OffsetRange(0, 100), 10);
      for (int i = 1; i < offsets.length; i++) {
        expect(offsets[i] >= offsets[i - 1], isTrue);
      }
    });

    test('nextRandomValues fills list', () {
      final rnd.Random m = rnd.Random.create(3);
      final List<int> data = List<int>.filled(5, 0);
      m.nextRandomValues(data);
      expect(data.every((int v) => v >= 0 && v < 256), isTrue);
    });

    test('sequenceGenerator yields then throws at end', () {
      final rnd.IGenerator<int> gen = rnd.sequenceGenerator<int>([1, 2, 3]);
      expect(gen.next(), 1);
      expect(gen.next(), 2);
      expect(gen.next(), 3);
      expect(() => gen.next(), throwsA(isA<err.BugIndicatingError>()));
    });

    test('nextStringEdit normalizes and stays within target', () {
      final rnd.Random m = rnd.Random.create(11);
      const String target = 'hello world foo';
      final edits = m.nextStringEdit(target, 2);
      expect(edits.replacements.length, lessThanOrEqualTo(2));
      final single = m.nextSingleStringEdit(target);
      expect(single.newText, isA<String>());
    });
  });

  group('batch16: cancellation facade & actionWidget', () {
    test('re-export facade exposes the same classes', () {
      final cancel.CancellationTokenSource cts = cfacade.CancellationTokenSource();
      expect(cts.token, isA<cfacade.CancellationToken>());
      expect(cfacade.CancellationError(), isA<err.CancellationError>());
      cts.dispose();
    });

    test('ActionSet interface can be implemented', () {
      final aw.ActionSet<int> set = _IntActionSet();
      expect(set.validActions, [1]);
      expect(set.allActions, [1, 2]);
      expect(set.hasAutoFix, isFalse);
      expect(set.hasAIFix, isFalse);
      expect(set.allAIFixes, isFalse);
    });
  });
}

class _IntActionSet implements aw.ActionSet<int> {
  @override
  List<int> get validActions => [1];
  @override
  List<int> get allActions => [1, 2];
  @override
  bool get hasAutoFix => false;
  @override
  bool get hasAIFix => false;
  @override
  bool get allAIFixes => false;
  @override
  void dispose() {}
}
