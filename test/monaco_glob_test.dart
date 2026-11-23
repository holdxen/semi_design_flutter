import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/base/common/glob.dart' as g;

/// 1:1 mirror of glob.test.ts `assertGlobMatch`/`assertNoGlobMatch`.
/// Host is macOS so `sep == '/'` and nativeSep is a no-op.
void matchYes(Object pattern, String input, [bool? ignoreCase]) {
  expect(g.match(pattern, input, g.GlobOptions(ignoreCase: ignoreCase)), isTrue,
      reason: '$pattern should match $input');
}

void matchNo(Object pattern, String input, [bool? ignoreCase]) {
  expect(g.match(pattern, input, g.GlobOptions(ignoreCase: ignoreCase)), isFalse,
      reason: '$pattern should not match $input');
}

void main() {
  group('glob · simple / dot / star', () {
    test('simple', () {
      matchYes('node_modules', 'node_modules');
      matchNo('node_modules', 'node_module');
      matchNo('node_modules', '/node_modules');
      matchNo('node_modules', 'test/node_modules');
      matchYes('test.txt', 'test.txt');
      matchNo('test.txt', 'test?txt');
      matchNo('test.txt', '/text.txt');
      matchYes('test(.txt', 'test(.txt');
      matchYes('*', '');
      matchYes('/DNXConsoleApp/**/*.cs', '/DNXConsoleApp/Program.cs');
      matchYes('/DNXConsoleApp/**/*.cs', '/DNXConsoleApp/foo/Program.cs');
      matchYes('C:/DNXConsoleApp/**/*.cs', r'C:\DNXConsoleApp\foo\Program.cs');
    });

    test('dot hidden', () {
      matchYes('.*', '.git');
      matchYes('.*', '.hidden.txt');
      matchNo('.*', 'git');
      matchNo('.*', 'path/.git');
      matchYes('**/.*', '.git');
      matchYes('**/.*', '/path/.hidden.txt');
      matchNo('**/.*', 'path/git');
      matchNo('**/.*', 'pat.h/hidden.txt');
      matchYes('**/._*', '._git');
      matchYes('**/._*', 'path/._git');
      matchNo('**/._*', 'hidden._txt');
    });

    test('file pattern / star', () {
      matchYes('*.js', 'foo.js');
      matchNo('*.js', 'folder/foo.js');
      matchNo('*.js', 'foo.jss');
      matchYes('*.*', 'html.js');
      matchNo('*.*', 'folder/foo.js');
      matchYes('node*modules', 'node_modules');
      matchYes('node*modules', 'node_super_modules');
      matchNo('node*modules', 'node_module');
      matchNo('node*modules', 'test/node_modules');
    });

    test('questionmark', () {
      matchYes('test?txt', 'test.txt');
      matchNo('test?txt', 'test.txtx');
      matchNo('test.txt', 'test?txt');
    });
  });

  group('glob · globstar / brace / bracket', () {
    test('globstar', () {
      matchYes('**/*.js', 'foo.js');
      matchYes('**/*.js', '/foo.js');
      matchYes('**/*.js', 'folder/foo.js');
      matchNo('**/*.js', 'foo.jss');
      matchNo('**/*.js', 'some.js/test');
      matchYes('**/project.json', 'some/folder/project.json');
      matchNo('**/project.json', 'some/folder/file_project.json');
      matchYes('test/**', 'test');
      matchYes('test/**', 'test/foo/');
      matchNo('test/**', 'est/other/foo.js');
      matchYes('**', '/');
      matchYes('**', 'folder/foo/');
      matchYes('test/**/*.js', 'test/other/more/foo.js');
      matchNo('test/**/*.js', 'test/other/foo.ts');
      matchYes('**/**/*.js', 'folder/foo.js');
      matchYes('**/node_modules/**/*.js', 'node_modules/some/folder/foo.js');
      matchNo('**/node_modules/**/*.js', 'folder/foo.js');
      matchYes(r'{**/node_modules/**,**/.git/**}', 'some/test/node_modules');
      matchYes(r'{**/node_modules/**,**/.git/**}', r'some\test\node_modules');
    });

    test('brace expansion', () {
      matchYes('*.{ts,js}', 'a.ts');
      matchYes('*.{ts,js}', 'a.js');
      matchNo('*.{ts,js}', 'a.py');
      matchYes(r'{**/baz,**/foo}', 'a/foo');
      matchNo(r'{**/baz,**/foo}', 'a/bar');
      matchYes('file.{txt,md,json}', 'file.json');
    });

    test('brackets', () {
      matchYes('foo.[0-9]', 'foo.5');
      matchNo('foo.[0-9]', 'foo.x');
      matchYes('foo.[!0-9]', 'foo.x');
      matchNo('foo.[!0-9]', 'foo.5');
      matchYes('foo.[a-z]', 'foo.m');
      matchNo('foo.[a-z]', 'foo.5');
    });

    test('splitGlobAware', () {
      expect(g.splitGlobAware('a/b/{c,d}/e', '/'), ['a', 'b', '{c,d}', 'e']);
      expect(g.splitGlobAware('a/[x/y]/b', '/'), ['a', '[x/y]', 'b']);
      expect(g.splitGlobAware('', '/'), isEmpty);
    });
  });

  group('glob · expression', () {
    g.HasSiblingFn syncSibling(List<String> siblings) =>
        (name) => siblings.contains(name);

    test('single expression with sibling clause', () {
      final expr = <String, Object?>{
        '**/*.js': g.SiblingClause(when: r'$(basename).ts')
      };
      final siblings = ['test.html', 'test.txt', 'test.ts', 'test.js'];
      expect(g.parse(expr)('test.js', null, syncSibling(siblings)), '**/*.js');
      expect(g.parse(expr)('test.js', null, (n) => false), isNull);
      expect(g.parse(expr)('test.js', null, (n) => n == 'te.ts'), isNull);
      expect(g.parse(expr)('test.js'), isNull);

      final emptyWhen = <String, Object?>{
        '**/*.js': g.SiblingClause(when: '')
      };
      expect(g.parse(emptyWhen)('test.js', null, syncSibling(siblings)), isNull);

      final anyValue = <String, Object?>{'**/*.js': <String, Object?>{}};
      expect(g.parse(anyValue)('test.js', null, syncSibling(siblings)), '**/*.js');
      expect(g.parse(<String, Object?>{}), g.NULL_FN);
    });

    test('multiple expression', () {
      final expr = <String, Object?>{
        '**/*.js': g.SiblingClause(when: r'$(basename).ts'),
        '**/*.as': true,
        '**/*.foo': false,
        '**/*.bananas': g.SiblingClause(when: 'xyz'),
      };
      final siblings = ['test.html', 'test.txt', 'test.ts', 'test.js'];
      final fn = syncSibling(siblings);
      expect(g.parse(expr)('test.js', null, fn), '**/*.js');
      expect(g.parse(expr)('test.as', null, fn), '**/*.as');
      expect(g.parse(expr)('test.foo', null, fn), isNull);
      expect(g.parse(expr)('test.bananas', null, fn), isNull);
      expect(g.parse(expr)('test.bananas', null), isNull);
    });

    test('async sibling clause (promise)', () async {
      final siblings = ['test.html', 'test.txt', 'test.ts'];
      g.HasSiblingFn hs = (name) async => siblings.contains(name);
      final expr = <String, Object?>{
        '**/test.js': g.SiblingClause(when: r'$(basename).js'),
        '**/*.js': g.SiblingClause(when: r'$(basename).ts'),
      };
      expect(await g.parse(expr)('test.js', null, hs), '**/*.js');
    });

    test('parse basename and base', () {
      expect(g.parse('**/foo')('bar/baz', 'baz'), false);
      expect(g.parse('**/foo')('bar/foo', 'foo'), true);
      expect(g.parse('{**/baz,**/foo}')('baz/bar', 'bar'), false);
      expect(g.parse('{**/baz,**/foo}')('baz/foo', 'foo'), true);
      final expr = <String, Object?>{
        '**/*.js': g.SiblingClause(when: r'$(basename).ts')
      };
      final hs = syncSibling(['baz', 'baz.zip', 'nope']);
      expect(g.parse(expr)('bar/baz.js', 'baz.js', hs), isNull);
      expect(g.parse(expr)('bar/baz.js', 'baz.js', (n) => n == 'baz.ts'),
          '**/*.js');
    });
  });

  group('glob · terms / optimization', () {
    test('basename terms', () {
      expect(g.getBasenameTerms(g.parse('**/*.foo')), isEmpty);
      expect(g.getBasenameTerms(g.parse('**/foo')), ['foo']);
      expect(g.getBasenameTerms(g.parse('**/foo/')), ['foo']);
      expect(g.getBasenameTerms(g.parse('{**/baz,**/foo}')), ['baz', 'foo']);
      expect(g.getBasenameTerms(g.parse(<String, Object?>{
        '**/foo': true,
        '{**/bar,**/baz}': true,
        '{**/bar2/,**/baz2/}': true,
        '**/bulb': false,
      })), ['foo', 'bar', 'baz', 'bar2', 'baz2']);
      expect(g.getBasenameTerms(g.parse(<String, Object?>{
        '**/foo': g.SiblingClause(when: r'$(basename).zip'),
        '**/bar': true,
      })), ['bar']);
    });

    test('basename optimization with trimForExclusions', () {
      expect(g.getBasenameTerms(g.parse('**/foo/**')), isEmpty);
      expect(g.getBasenameTerms(
          g.parse('**/foo/**', g.GlobOptions(trimForExclusions: true))), ['foo']);
      final parsed = g.parse('{**/baz/**,**/foo/**}',
          g.GlobOptions(trimForExclusions: true));
      expect(g.getBasenameTerms(parsed), ['baz', 'foo']);
      expect(parsed('bar/baz'), true);
      expect(parsed('bar/foo'), true);
    });

    test('path terms', () {
      expect(g.getPathTerms(g.parse('**/*.foo')), isEmpty);
      expect(g.getPathTerms(g.parse('**/foo')), isEmpty);
      expect(g.getPathTerms(g.parse('**/foo/bar')), ['*/foo/bar']);
      expect(g.getPathTerms(g.parse('**/foo/bar/')), ['*/foo/bar']);
      final parsed = g.parse(<String, Object?>{
        '**/foo/bar': true,
        '**/foo2/bar2': true,
        '**/bulb': true,
        '**/bulb2': true,
        '**/bulb/foo': false,
      });
      expect(g.getPathTerms(parsed), ['*/foo/bar', '*/foo2/bar2']);
      expect(g.getBasenameTerms(parsed), ['bulb', 'bulb2']);
    });

    test('path optimization with trimForExclusions', () {
      expect(g.getPathTerms(g.parse('**/foo/bar/**')), isEmpty);
      expect(g.getPathTerms(g.parse('**/foo/bar/**',
          g.GlobOptions(trimForExclusions: true))), ['*/foo/bar']);
      final parsed = g.parse('**/foo/bar/**',
          g.GlobOptions(trimForExclusions: true));
      expect(parsed('bar/foo/bar'), true);
      expect(parsed('bar/foo/bar/baz'), false);
    });
  });

  group('glob · relative / case / misc', () {
    test('relative pattern', () {
      final rp = g.RelativePattern(base: '/DNXConsoleApp/foo', pattern: '**/*.cs');
      matchYes(rp, '/DNXConsoleApp/foo/Program.cs');
      matchYes(rp, '/DNXConsoleApp/foo/bar/Program.cs');
      matchNo(rp, '/DNXConsoleApp/foo/Program.ts');
      matchNo(rp, '/DNXConsoleApp/Program.cs');
      final oneStar = g.RelativePattern(base: '/DNXConsoleApp/foo', pattern: '*.cs');
      matchYes(oneStar, '/DNXConsoleApp/foo/Program.cs');
      matchNo(oneStar, '/DNXConsoleApp/foo/bar/Program.cs');
      matchYes(g.RelativePattern(base: '/', pattern: 'foo.cs'), '/foo.cs');
      matchYes(g.RelativePattern(base: '/bar/', pattern: 'foo.cs'), '/bar/foo.cs');
    });

    test('case insensitive', () {
      matchNo('PATH/FOO.js', 'path/foo.js');
      matchYes('PATH/FOO.js', 'path/foo.js', true);
      matchNo('**/*.JS', 'bar/foo.js');
      matchYes('**/*.JS', 'bar/foo.js', true);
      matchNo('**/package', 'bar/Package');
      matchYes('**/package', 'bar/Package', true);
      matchYes('{**/*.JS,**/*.TS}', 'bar/foo.ts', true);
      matchYes('{**/BAR,**/BAZ}', 'bar', true);
      matchYes('**/FOO/Bar', 'bar/foo/bar', true);
      matchYes('FOO/Bar', 'foo/bar', true);
      matchYes('some/*/Random/*/Path.FILE',
          'some/very/random/unusual/path.file', true);
    });

    test('isEmptyPattern / patternsEquals / isRelativePattern', () {
      expect(g.isEmptyPattern(g.parse('')), isTrue);
      expect(g.isEmptyPattern(g.parse(null)), isTrue);
      expect(g.isEmptyPattern(g.parse(<String, Object?>{})), isTrue);
      expect(g.isEmptyPattern(g.parse(<String, Object?>{'': true})), isTrue);
      expect(g.isEmptyPattern(
          g.parse(<String, Object?>{'**/*.js': false})), isTrue);
      expect(g.isEmptyPattern(g.parse('**/*.js')), isFalse);

      expect(g.patternsEquals(['a'], ['a']), isTrue);
      expect(g.patternsEquals(['a'], ['b']), isFalse);
      expect(g.patternsEquals(['a', 'b', 'c'], ['a', 'b', 'c']), isTrue);
      expect(g.patternsEquals(['1', '2'], ['1', '3']), isFalse);
      expect(g.patternsEquals(null, null), isTrue);
      expect(g.patternsEquals(null, ['b']), isFalse);
      expect(g.patternsEquals(['a'], null), isFalse);

      expect(g.isRelativePattern(g.RelativePattern(base: 'a', pattern: '*')),
          isTrue);
      expect(g.isRelativePattern({'base': true}), isFalse);
    });
  });

  group('glob · exclude exceptions', () {
    Map<String, bool> excluded(IExpressionLike expression, List<String> paths,
        [g.GlobOptions? options]) {
      final parsed = g.parseExcludeExpression(expression, options);
      return <String, bool>{
        for (final path in paths) path: parsed.matches(path) != null
      };
    }

    Map<String, bool> beneath(
        IExpressionLike expression, List<String> folders) {
      final parsed = g.parseExcludeExpression(expression);
      return <String, bool>{
        for (final folder in folders)
          folder: parsed.couldExceptionMatchBeneath(folder)
      };
    }

    test('exceptions carve paths and their children out of excludes', () {
      expect(
        excluded(
          <String, Object?>{
            'node_modules/*': true,
            '!node_modules/susa': true
          },
          [
            'node_modules/a',
            'node_modules/susa',
            'node_modules/susa/index.js',
            'src/a.js'
          ],
        ),
        {
          'node_modules/a': true,
          'node_modules/susa': false,
          'node_modules/susa/index.js': false,
          'src/a.js': false,
        },
      );
      expect(
        excluded(<String, Object?>{'*.js': true, '!gulpfile.js': true},
            ['a.js', 'gulpfile.js']),
        {'a.js': true, 'gulpfile.js': false},
      );
      expect(
        excluded(
          <String, Object?>{
            r'**/.vscode': true,
            r'**/.vscode/*': true,
            r'!**/.vscode/launch.json': true
          },
          [
            'a/.vscode',
            'a/.vscode/settings.json',
            'a/.vscode/launch.json'
          ],
        ),
        {
          'a/.vscode': true,
          'a/.vscode/settings.json': true,
          'a/.vscode/launch.json': false,
        },
      );
    });

    test('exceptions on their own / win over excludes beneath', () {
      expect(
        excluded(<String, Object?>{'!*.js': true, '!*.ts': true},
            ['a.js', 'a.ts', 'a.md']),
        {'a.js': false, 'a.ts': false, 'a.md': false},
      );
      expect(
        excluded(
          <String, Object?>{
            'node_modules/*': true,
            '!node_modules/@types': true,
            'node_modules/@types/*': true
          },
          ['node_modules/a', 'node_modules/@types/node'],
        ),
        {'node_modules/a': true, 'node_modules/@types/node': false},
      );
    });

    test('disabled/escaped exception keys + ignoreCase', () {
      expect(
        excluded(<String, Object?>{'*.js': true, '!gulpfile.js': false},
            ['gulpfile.js']),
        {'gulpfile.js': true},
      );
      expect(
        excluded(<String, Object?>{'{!}notes.txt': true},
            ['!notes.txt', 'notes.txt']),
        {'!notes.txt': true, 'notes.txt': false},
      );
      expect(g.escapeExcludeException('!notes.txt'), '{!}notes.txt');
      expect(g.escapeExcludeException('notes.txt'), 'notes.txt');
      expect(
        excluded(
          <String, Object?>{
            'node_modules': true,
            'node_modules/*': true,
            '!node_modules/@Types': true
          },
          ['node_modules/@types'],
          g.GlobOptions(ignoreCase: true),
        ),
        {'node_modules/@types': false},
      );
      expect(
        excluded(
          <String, Object?>{
            'node_modules': true,
            'node_modules/*': true,
            '!node_modules/@Types': true
          },
          ['node_modules/@types'],
        ),
        {'node_modules/@types': true},
      );
    });

    test('sibling clauses are subject to exceptions (promise)', () async {
      final parsed = g.parseExcludeExpression(<String, Object?>{
        r'**/*.js': g.SiblingClause(when: r'$(basename).ts'),
        '!keep.js': true,
      });
      g.HasSiblingFn hs = (name) async => name == 'keep.ts' || name == 'drop.ts';
      expect(await parsed.matches('keep.js', 'keep.js', hs), isNull);
      expect(await parsed.matches('drop.js', 'drop.js', hs), '**/*.js');
    });

    test('getExcludeExceptions', () {
      expect(
        g.getExcludeExceptions(<String, Object?>{
          'a': true,
          '!node_modules/@types/**': true,
          '!**/Scripts/': true,
          '!src/*.js': true,
          '!off': false,
          '!': true,
          '!/workspace/keep.js': true,
        }),
        ['node_modules/@types/**', '**/Scripts', 'src/*.js'],
      );
    });

    test('evaluateExcludeTreeEntry', () {
      final parsed = g.parseExcludeExpression(<String, Object?>{
        'node_modules': true,
        '!node_modules/@types': true
      });
      g.ExcludeTreeEntryResult evaluate(String path, bool isDirectory,
              bool isParentExcluded,
              [bool isHidden = false]) =>
          g.evaluateExcludeTreeEntry(
            parsed,
            g.IExcludeTreeEntry(
              path: path,
              isDirectory: isDirectory,
              isParentExcluded: isParentExcluded,
              isHidden: () => isHidden,
            ),
          );
      final results = <String, Map<String, bool>>{
        'excludedFolderLeadingToException': _ev(evaluate('node_modules', true, false)),
        'excludedFolder': _ev(evaluate('node_modules/react', true, true)),
        'excludedFile': _ev(evaluate('node_modules/a.js', false, true)),
        'exceptedFolder': _ev(evaluate('node_modules/@types', true, true)),
        'hiddenFile': _ev(evaluate('dist/a.js', false, false, true)),
        'includedFile': _ev(evaluate('src/a.js', false, false)),
      };
      expect(results, {
        'excludedFolderLeadingToException': {'isExcluded': true, 'isVisited': true},
        'excludedFolder': {'isExcluded': true, 'isVisited': false},
        'excludedFile': {'isExcluded': true, 'isVisited': false},
        'exceptedFolder': {'isExcluded': false, 'isVisited': true},
        'hiddenFile': {'isExcluded': true, 'isVisited': false},
        'includedFile': {'isExcluded': false, 'isVisited': true},
      });
    });

    test('couldExceptionMatchBeneath', () {
      expect(
        beneath(<String, Object?>{
          'node_modules': true,
          '!node_modules/@types': true
        }, ['node_modules', 'node_modules/@types', 'node_modules/react', 'src']),
        {
          'node_modules': true,
          'node_modules/@types': true,
          'node_modules/react': false,
          'src': false,
        },
      );
      expect(
        beneath(<String, Object?>{'a': true, '!a/*/c/**/d.txt': true},
            ['a', 'a/b', 'a/b/c', 'a/b/x', 'a/b/c/e/f']),
        {
          'a': true,
          'a/b': true,
          'a/b/c': true,
          'a/b/x': false,
          'a/b/c/e/f': true,
        },
      );
      expect(
        beneath(<String, Object?>{'a': true}, ['a']),
        {'a': false},
      );
      expect(
        beneath(
            <String, Object?>{'src': true, '!src/**.keep': true}, ['src', 'src/a']),
        {'src': true, 'src/a': false},
      );
      expect(
        beneath(<String, Object?>{'**': true, '!{**,foo}/keep.txt': true},
            ['a', 'a/b']),
        {'a': true, 'a/b': true},
      );
    });

    test('version control folders', () {
      final unnamed = g.parseExcludeExpression(<String, Object?>{
        r'**/.git': true,
        'third_party': true,
        '!third_party/lib': true,
      });
      final named = g.parseExcludeExpression(<String, Object?>{
        r'**/.git': true,
        r'!.git/hooks': true,
      });
      expect(
        [
          'third_party/lib/a.js',
          'third_party/lib/.git',
          'third_party/lib/.git/config'
        ].map((p) => unnamed.isExcepted(p)).toList(),
        [true, false, false],
      );
      expect(
        ['.git/hooks/pre-commit', '.git/config']
            .map((p) => named.isExcepted(p))
            .toList(),
        [true, false],
      );
      expect(
        beneath(<String, Object?>{'**/*': true, r'!**/Scripts': true},
            ['.git', 'a/.hg/b', 'a']),
        {'.git': false, 'a/.hg/b': false, 'a': true},
      );
      expect(
        beneath(
            <String, Object?>{'**/*': true, r'!**/Scripts': true, r'!.git/hooks': true},
            ['.git', 'a/.hg/b']),
        {'.git': true, 'a/.hg/b': false},
      );
      expect(
        beneath(<String, Object?>{'**/*': true, r'!{.git,.hg}/hooks': true},
            ['.git', '.hg', '.svn']),
        {'.git': true, '.hg': true, '.svn': false},
      );
    });

    test('expressions without exceptions parse unchanged', () {
      final parsed = g.parseExcludeExpression(
          <String, Object?>{r'**/node_modules': true});
      expect(identical(parsed.matches, parsed.matchesExclude), isTrue);
      expect(g.getBasenameTerms(parsed.matches), ['node_modules']);
    });
  });
}

/// TS IExpression alias used by the test helpers.
typedef IExpressionLike = Map<String, Object?>;

Map<String, bool> _ev(g.ExcludeTreeEntryResult r) =>
    {'isExcluded': r.isExcluded, 'isVisited': r.isVisited};
