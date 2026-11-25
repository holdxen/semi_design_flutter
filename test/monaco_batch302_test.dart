// batch302: editorMarkdownSanitizer.ts truth replay.
// Truth from tool/ts2dart/batch302_truth.json (recursive TS transpile + vm,
// real isMarkdownImageAllowed with the editor's markdownImages option).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/markdownRenderer.dart'
    show MarkdownSanitizerConfig;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/editor/browser/editorMarkdownSanitizer.dart'
    show IEditorForMarkdownSanitizer, getEditorMarkdownSanitizerConfig;
import 'package:semi_design_flutter/src/monaco/editor/common/config/editorOptions.dart'
    show EditorMarkdownImagesOptions;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch302_truth.json').readAsStringSync())
    as Map<String, dynamic>;

class _Editor implements IEditorForMarkdownSanitizer {
  _Editor(this.options);

  final EditorMarkdownImagesOptions options;

  @override
  Object? getOption(Object? id) => options;
}

void main() {
  final Map<String, dynamic> truth = _truth();
  group('batch302 editorMarkdownSanitizer truth replay', () {
    for (final dynamic raw in truth['cases'] as List<dynamic>) {
      final Map<String, dynamic> c = raw as Map<String, dynamic>;
      test(c['name'] as String, () {
        final Object? rawAllowed = c['allowedOrigins'];
        final List<String>? allowed = rawAllowed is List<dynamic>
            ? rawAllowed.map((e) => e as String).toList()
            : null;
        final EditorMarkdownImagesOptions options =
            EditorMarkdownImagesOptions(
                allowedOrigins: rawAllowed == true ? true : allowed);
        final MarkdownSanitizerConfig? config =
            getEditorMarkdownSanitizerConfig(_Editor(options));
        final Map<String, dynamic> expected =
            c['result'] as Map<String, dynamic>;
        if (expected['defined'] == false) {
          expect(config, isNull);
          return;
        }
        expect(config, isNotNull);
        final List<Object?> probes = <Object?>[];
        for (final dynamic rawProbe in expected['remote'] as List<dynamic>) {
          final List<dynamic> p = rawProbe as List<dynamic>;
          probes.add(<Object?>[
            p[0],
            config!.remoteImageIsAllowed!(URI.parse(p[0] as String)),
          ]);
        }
        expect(<String, Object?>{'defined': true, 'remote': probes}, expected);
      });
    }
  });
}
