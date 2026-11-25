// batch319: dropOrPasteInto/edit.ts truth replay.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/hierarchicalKind.dart'
    show HierarchicalKind;
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart'
    show Range;
import 'package:semi_design_flutter/src/monaco/editor/contrib/dropOrPasteInto/browser/edit.dart'
    show
      DropYieldToForEdit,
      IYieldToEdit,
      SnippetInsertText,
      createCombinedWorkspaceEdit,
      sortEditsByYieldTo,
      yieldToCycleWarn;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch319_truth.json').readAsStringSync())
    as Map<String, dynamic>;

class _Edit implements IYieldToEdit {
  _Edit(this.id, this.kind, this.handledMimeType, this.yieldTo);

  final String id;

  @override
  final HierarchicalKind? kind;

  @override
  final String? handledMimeType;

  @override
  final List<DropYieldToForEdit>? yieldTo;
}

void main() {
  final Map<String, dynamic> truth = _truth();
  final List<Object?> additional = <Object?>[
    <String, Object?>{'label': 'extra'},
  ];

  group('createCombinedWorkspaceEdit', () {
    for (final dynamic raw in truth['combined'] as List<dynamic>) {
      final Map<String, dynamic> c = raw as Map<String, dynamic>;
      test(c['label'] as String, () {
        Object insertText;
        switch (c['label'] as String) {
          case 'empty-string':
            insertText = '';
            break;
          case 'empty-snippet':
            insertText = SnippetInsertText('');
            break;
          case 'snippet':
            insertText = SnippetInsertText('foo\$1');
            break;
          default:
            insertText = r'a$b\c';
        }
        final List<Range> ranges = <Range>[];
        for (final dynamic rawRange in c['label'] == 'empty-string' ||
                c['label'] == 'empty-snippet'
            ? <dynamic>[
                <int>[1, 1, 1, 5],
              ]
            : c['label'] == 'snippet'
                ? <dynamic>[
                    <int>[3, 2, 3, 4],
                  ]
                : <dynamic>[
                    <int>[1, 1, 1, 5],
                    <int>[2, 1, 2, 3],
                  ]) {
          final List<dynamic> r = rawRange as List<dynamic>;
          ranges.add(Range(r[0] as int, r[1] as int, r[2] as int, r[3] as int));
        }
        final Object? result = createCombinedWorkspaceEdit(
            'file:///a.ts', ranges, insertText, additional);
        expect((result as dynamic).edits, c['result']);
      });
    }
  });

  test('sortEditsByYieldTo matches truth', () {
    final List<String> warnings = <String>[];
    yieldToCycleWarn = (Object node) => warnings.add((node as _Edit).id);

    for (final dynamic raw in truth['sorted'] as List<dynamic>) {
      final Map<String, dynamic> c = raw as Map<String, dynamic>;
      warnings.clear();
      late List<_Edit> edits;
      switch (c['label'] as String) {
        case 'mime-yield':
          edits = <_Edit>[
            _Edit('a', null, 'text/plain', <DropYieldToForEdit>[
              DropYieldToForEdit(mimeType: 'text/html'),
            ]),
            _Edit('b', null, 'text/html', null),
            _Edit('c', null, 'text/x', null),
          ];
          break;
        case 'kind-chain':
          edits = <_Edit>[
            _Edit('a', HierarchicalKind('foo.bar'), null, <DropYieldToForEdit>[
              DropYieldToForEdit(kind: HierarchicalKind('foo')),
            ]),
            _Edit('b', HierarchicalKind('foo'), null, null),
            _Edit('c', HierarchicalKind('other'), null, null),
          ];
          break;
        case 'cycle':
          edits = <_Edit>[
            _Edit('a', HierarchicalKind('foo'), null, <DropYieldToForEdit>[
              DropYieldToForEdit(kind: HierarchicalKind('foo')),
            ]),
          ];
          break;
        default:
          edits = <_Edit>[
            _Edit('a', HierarchicalKind('foo'), null, null),
            _Edit('b', HierarchicalKind('bar'), null, null),
          ];
      }
      final List<_Edit> sorted = sortEditsByYieldTo<_Edit>(edits);
      expect(sorted.map((e) => e.id).toList(), c['order'],
          reason: c['label'] as String);
      expect(warnings, c['warnings'], reason: c['label'] as String);
    }
  });
}
