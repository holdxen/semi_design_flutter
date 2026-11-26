import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/uri.dart' show URI;
import '../lib/src/monaco/editor/common/services/getIconClasses.dart'
    show
        fileIconSelectorEscape,
        getIconClasses,
        getIconClassesForLanguageId;
import '../lib/src/monaco/platform/files/common/files.dart' show FileKind;

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root =
      jsonDecode(File('tool/ts2dart/batch424_truth.json').readAsStringSync())
          as Map<String, dynamic>;
  return <String, dynamic>{
    for (final dynamic r in root['results'] as List<dynamic>)
      (r as Map)['label'] as String: <String, dynamic>{
        for (final MapEntry<Object?, Object?> e
            in (r as Map).cast<Object?, Object?>().entries)
          if (e.key != 'label') e.key as String: e.value,
      },
  };
}

class _ModelService {
  final String? language;
  _ModelService(this.language);
  Object? getModel(URI resource) =>
      language != null ? _Model(language!) : null;
}

class _Model {
  final String language;
  _Model(this.language);
  String getLanguageId() => language;
}

class _LanguageService {
  final String? mimeLanguage;
  final String? guessLanguage;
  _LanguageService(this.mimeLanguage, this.guessLanguage);
  String? getLanguageIdByMimeType(String mime) => mimeLanguage;
  String? guessLanguageIdByFilepathOrFirstLine(URI resource) => guessLanguage;
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('getIconClasses truth replay', () {
    final Map<String, Object?> actual = <String, Object?>{};

    void run(
      String label, {
      URI? resource,
      int? fileKind,
      Object? icon,
      String? modelLanguage,
      String? mimeLanguage,
      String? guessLanguage,
    }) {
      actual[label] = <String, Object?>{
        'classes': getIconClasses(
          _ModelService(modelLanguage),
          _LanguageService(mimeLanguage, guessLanguage),
          resource,
          fileKind,
          icon,
        ),
      };
    }

    run('file-basic', resource: URI.parse('file:///home/user/example.test.ts'));
    run('file-no-ext', resource: URI.parse('file:///home/user/README'));
    run('file-long-ext', resource: URI.parse('file:///a/b/archive.tar.gz.js'));
    run('file-in-dir', resource: URI.parse('file:///home/myproj/src/main.dart'));
    run('folder', resource: URI.parse('file:///home/myproj/src/'), fileKind: FileKind.FOLDER);
    run('rootfolder', resource: URI.parse('file:///home/myproj/'), fileKind: FileKind.ROOT_FOLDER);
    run('no-resource');
    run('model-lang', resource: URI.parse('file:///a/x.txt'), modelLanguage: 'typescript');
    run('model-plaintext-fallback', resource: URI.parse('file:///a/x.unknown'), modelLanguage: 'plaintext', guessLanguage: 'python');
    run('guess-lang', resource: URI.parse('file:///a/x.unknown'), guessLanguage: 'ruby');

    // data URI with label + mime metadata
    const String label = 'My File.ts';
    const String mime = 'text/x-python';
    final String meta = 'label=$label;mime=$mime';
    final URI dataUri = URI.parse(
      'data:text/plain;metadata=${Uri.encodeComponent(meta)},hello',
    );
    run('data-uri', resource: dataUri, mimeLanguage: 'python');

    run('theme-icon', resource: URI.parse('file:///a/x.ts'), icon: <String, Object?>{'id': 'file-code'});
    run('uri-icon', resource: URI.parse('file:///a/x.ts'), icon: URI.parse('http://example.com/icon.png'));

    actual['escape'] = <String, Object?>{
      'values': <String>['a b\tc', 'MiXeD Case', 'no-space']
          .map(fileIconSelectorEscape)
          .toList(),
    };
    actual['lang-helper'] = <String, Object?>{
      'values': <String>['TypeScript', 'c++', 'my lang']
          .map(getIconClassesForLanguageId)
          .toList(),
    };

    expect(jsonEncode(actual), jsonEncode(truth));
  });
}
