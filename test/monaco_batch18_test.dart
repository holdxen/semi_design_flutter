import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' as uri;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/objectCollectionBuffer.dart'
    as ocb;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/raster/raster.dart'
    as raster;
import 'package:semi_design_flutter/src/monaco/editor/common/languageSelector.dart'
    as sel;
import 'package:semi_design_flutter/src/monaco/editor/common/services/treeViewsDnd.dart'
    as dnd;
import 'package:semi_design_flutter/src/monaco/editor/contrib/hover/browser/hoverActionIds.dart'
    as hover;

int _score(
  Object? selector,
  String uriStr,
  String language, {
  bool synchronized = true,
  String? notebookUriStr,
  String? notebookType,
}) {
  return sel.score(
    selector,
    uri.URI.parse(uriStr),
    language,
    synchronized,
    notebookUriStr == null ? null : uri.URI.parse(notebookUriStr),
    notebookType,
  );
}

void main() {
  group('batch18 · languageSelector', () {
    const String modelUri = 'file:///testbed/file.fb';
    const String lang = 'farboo';

    test('score, invalid selector', () {
      expect(_score(<String, Object?>{}, modelUri, lang), 0);
      expect(_score(null, modelUri, lang), 0);
      expect(_score('', modelUri, lang), 0);
    });

    test('score, any language', () {
      expect(_score(<String, Object?>{'language': '*'}, modelUri, lang), 5);
      expect(_score('*', modelUri, lang), 5);
      expect(_score('*', 'foo:bar', lang), 5);
      expect(_score('farboo', 'foo:bar', lang), 10);
    });

    test('score, default schemes', () {
      const String u = 'git:foo/file.txt';
      expect(_score('*', u, lang), 5);
      expect(_score('farboo', u, lang), 10);
      expect(
          _score(<String, Object?>{'language': 'farboo', 'scheme': ''}, u, lang),
          10);
      expect(
          _score(
              <String, Object?>{'language': 'farboo', 'scheme': 'git'}, u, lang),
          10);
      expect(
          _score(
              <String, Object?>{'language': 'farboo', 'scheme': '*'}, u, lang),
          10);
      expect(_score(<String, Object?>{'language': 'farboo'}, u, lang), 10);
      expect(_score(<String, Object?>{'language': '*'}, u, lang), 5);
      expect(_score(<String, Object?>{'scheme': '*'}, u, lang), 5);
      expect(_score(<String, Object?>{'scheme': 'git'}, u, lang), 10);
    });

    test('score, filter', () {
      expect(_score('farboo', modelUri, lang), 10);
      expect(_score(<String, Object?>{'language': 'farboo'}, modelUri, lang), 10);
      expect(
          _score(<String, Object?>{'language': 'farboo', 'scheme': 'file'},
              modelUri, lang),
          10);
      expect(
          _score(<String, Object?>{'language': 'farboo', 'scheme': 'http'},
              modelUri, lang),
          0);

      expect(_score(<String, Object?>{'pattern': '**/*.fb'}, modelUri, lang), 10);
      expect(
          _score(<String, Object?>{'pattern': '**/*.fb', 'scheme': 'file'},
              modelUri, lang),
          10);
      expect(
          _score(<String, Object?>{'pattern': '**/*.fb'}, 'foo:bar', lang), 0);
      expect(
          _score(<String, Object?>{'pattern': '**/*.fb', 'scheme': 'foo'},
              'foo:bar', lang),
          0);

      const String docUri = 'git:/my/file.js';
      expect(_score('javascript', docUri, 'javascript'), 10);
      expect(
          _score(<String, Object?>{'language': 'javascript', 'scheme': 'git'},
              docUri, 'javascript'),
          10);
      expect(_score('*', docUri, 'javascript'), 5);
      expect(_score('fooLang', docUri, 'javascript'), 0);
      expect(_score(<Object?>[
        'fooLang',
        '*'
      ], docUri, 'javascript'), 5);
    });

    test('score, max(filters)', () {
      final Map<String, Object?> match = <String, Object?>{
        'language': 'farboo',
        'scheme': 'file'
      };
      final Map<String, Object?> fail = <String, Object?>{
        'language': 'farboo',
        'scheme': 'http'
      };
      expect(_score(match, modelUri, lang), 10);
      expect(_score(fail, modelUri, lang), 0);
      expect(_score(<Object?>[match, fail], modelUri, lang), 10);
      expect(_score(<Object?>[fail, fail], modelUri, lang), 0);
      expect(_score(<Object?>['farboo', '*'], modelUri, lang), 10);
      expect(_score(<Object?>['*', 'farboo'], modelUri, lang), 10);
    });

    test('score hasAccessToAllModels', () {
      const String docUri = 'file:/my/file.js';
      expect(_score('javascript', docUri, 'javascript', synchronized: false), 0);
      expect(
          _score(<String, Object?>{'language': 'javascript', 'scheme': 'file'},
              docUri, 'javascript', synchronized: false),
          0);
      expect(_score('*', docUri, 'javascript', synchronized: false), 0);
      expect(_score('fooLang', docUri, 'javascript', synchronized: false), 0);
      expect(
          _score(<Object?>[
            'fooLang',
            '*'
          ], docUri, 'javascript', synchronized: false),
          0);
      expect(
          _score(
              <String, Object?>{
                'language': 'javascript',
                'scheme': 'file',
                'hasAccessToAllModels': true
              },
              docUri,
              'javascript',
              synchronized: false),
          10);
      expect(
          _score(
              <Object?>[
                'fooLang',
                '*',
                <String, Object?>{
                  'language': '*',
                  'hasAccessToAllModels': true
                }
              ],
              docUri,
              'javascript',
              synchronized: false),
          5);
    });

    test('score, notebookType', () {
      const String cellUri = 'vscode-notebook-cell:///my/file.js#blabla';
      const String nbUri = 'file:///my/file.js';
      expect(_score('javascript', cellUri, 'javascript'), 10);
      expect(
          _score('javascript', cellUri, 'javascript',
              notebookUriStr: nbUri, notebookType: 'fooBook'),
          10);
      expect(
          _score(<String, Object?>{'notebookType': 'fooBook'}, cellUri,
              'javascript',
              notebookUriStr: nbUri, notebookType: 'fooBook'),
          10);
      expect(
          _score(
              <String, Object?>{
                'notebookType': 'fooBook',
                'language': 'javascript',
                'scheme': 'file'
              },
              cellUri,
              'javascript',
              notebookUriStr: nbUri,
              notebookType: 'fooBook'),
          10);
      expect(
          _score(
              <String, Object?>{
                'notebookType': 'fooBook',
                'language': '*'
              },
              cellUri,
              'javascript',
              notebookUriStr: nbUri,
              notebookType: 'fooBook'),
          10);
      expect(
          _score(
              <String, Object?>{'notebookType': '*', 'language': '*'}, cellUri,
              'javascript',
              notebookUriStr: nbUri, notebookType: 'fooBook'),
          5);
      expect(
          _score(
              <String, Object?>{
                'notebookType': '*',
                'language': 'javascript'
              },
              cellUri,
              'javascript',
              notebookUriStr: nbUri,
              notebookType: 'fooBook'),
          10);
    });

    test('Snippet choices lost #149363', () {
      final Map<String, Object?> selector = <String, Object?>{
        'scheme': 'vscode-notebook-cell',
        'pattern': '/some/path/file.py',
        'language': 'python'
      };
      const String modelUri = 'vscode-notebook-cell:///some/path/file.py';
      const String nbUri = 'file:///some/path/file.py';
      expect(
          _score(selector, modelUri, 'python',
              notebookUriStr: nbUri, notebookType: 'jupyter'),
          10);
      final Map<String, Object?> selector2 = <String, Object?>{
        ...selector,
        'notebookType': 'jupyter'
      };
      expect(
          _score(selector2, modelUri, 'python',
              notebookUriStr: nbUri, notebookType: 'jupyter'),
          0);
    });

    test('Document selector match #60232 and platform paths #99938', () {
      expect(
          _score(
              <String, Object?>{
                'language': 'json',
                'scheme': 'file',
                'pattern': '**/*.interface.json'
              },
              'file:///C:/Users/zlhe/Desktop/test.interface.json',
              'json'),
          10);
      expect(
          _score(
              <String, Object?>{
                'pattern': <String, Object?>{
                  'base': '/home/user/Desktop',
                  'pattern': '*.json'
                }
              },
              'file:///home/user/Desktop/test.json',
              'json'),
          10);
    });

    test('NotebookType without notebook', () {
      const String u = 'file:///my/file.bat';
      expect(
          _score(<String, Object?>{'language': 'bat', 'notebookType': 'xxx'}, u,
              'bat'),
          0);
      expect(
          _score(<String, Object?>{'language': 'bat', 'notebookType': '*'}, u,
              'bat'),
          0);
    });

    test('targetsNotebooks', () {
      expect(sel.targetsNotebooks('typescript'), isFalse);
      expect(sel.targetsNotebooks(<String, Object?>{'scheme': 'file'}), isFalse);
      expect(
          sel.targetsNotebooks(<String, Object?>{'notebookType': 'jupyter'}),
          isTrue);
      expect(
          sel.targetsNotebooks(<Object?>[
            'python',
            <String, Object?>{'notebookType': '*'}
          ]),
          isTrue);
    });

    test('selectLanguageIds', () {
      final Set<String> result = <String>{};
      sel.selectLanguageIds('typescript', result);
      expect(result.toList(), <String>['typescript']);

      result.clear();
      sel.selectLanguageIds(
          <String, Object?>{'language': 'python', 'scheme': 'file'}, result);
      expect(result.toList(), <String>['python']);

      result.clear();
      sel.selectLanguageIds(<String, Object?>{'scheme': 'file'}, result);
      expect(result.toList(), isEmpty);

      result.clear();
      sel.selectLanguageIds(<Object?>[
        'javascript',
        <String, Object?>{'language': 'css'},
        <String, Object?>{'scheme': 'untitled'}
      ], result);
      expect(result.toList()..sort(), <String>['css', 'javascript']);

      result.clear();
      sel.selectLanguageIds('*', result);
      expect(result.toList(), <String>['*']);
    });

    test('LanguageFilter object form works alongside map form', () {
      const sel.LanguageFilter filter = sel.LanguageFilter(language: 'farboo');
      expect(_score(filter, modelUri, lang), 10);
      expect(sel.targetsNotebooks(const sel.LanguageFilter(notebookType: 'x')),
          isTrue);
    });
  });

  group('batch18 · objectCollectionBuffer', () {
    ocb.IObjectCollectionBuffer _buffer(
      List<String> names,
      int capacity,
    ) {
      return ocb.createObjectCollectionBuffer(
        names
            .map((String n) =>
                ocb.ObjectCollectionBufferPropertySpec(name: n))
            .toList(),
        capacity,
      );
    }

    List<num> _used(ocb.IObjectCollectionBuffer b) =>
        b.view.sublist(0, b.viewUsedSize);

    test('createEntry', () {
      final ocb.IObjectCollectionBuffer b = _buffer(<String>['a', 'b'], 5);
      expect(_used(b), isEmpty);
      b.createEntry(<String, num>{'a': 1, 'b': 2});
      b.createEntry(<String, num>{'a': 3, 'b': 4});
      b.createEntry(<String, num>{'a': 5, 'b': 6});
      b.createEntry(<String, num>{'a': 7, 'b': 8});
      b.createEntry(<String, num>{'a': 9, 'b': 10});
      expect(_used(b), <num>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    });

    test('createEntry beyond capacity', () {
      final ocb.IObjectCollectionBuffer b = _buffer(<String>['a', 'b'], 1);
      b.createEntry(<String, num>{'a': 1, 'b': 2});
      expect(b.entryCount, 1);
      expect(b.buffer.lengthInBytes, 8);
      b.createEntry(<String, num>{'a': 3, 'b': 4});
      expect(b.entryCount, 2);
      expect(b.buffer.lengthInBytes, 16);
    });

    test('dispose entry shifts left', () {
      final ocb.IObjectCollectionBuffer b = _buffer(<String>['a', 'b'], 5);
      b.createEntry(<String, num>{'a': 1, 'b': 2});
      final ocb.IObjectCollectionBufferEntry entry1 =
          b.createEntry(<String, num>{'a': 3, 'b': 4});
      b.createEntry(<String, num>{'a': 5, 'b': 6});
      final ocb.IObjectCollectionBufferEntry entry2 =
          b.createEntry(<String, num>{'a': 7, 'b': 8});
      b.createEntry(<String, num>{'a': 9, 'b': 10});
      entry1.dispose();
      entry2.dispose();
      expect(_used(b), <num>[1, 2, 5, 6, 9, 10]);
    });

    test('entryCount, viewUsedSize, bufferUsedSize', () {
      final ocb.IObjectCollectionBuffer b = _buffer(<String>['foo', 'bar'], 5);
      expect(b.entryCount, 0);
      expect(b.bufferUsedSize, 0);
      expect(b.viewUsedSize, 0);
      b.createEntry(<String, num>{'foo': 1, 'bar': 2});
      expect(b.entryCount, 1);
      expect(b.viewUsedSize, 2);
      expect(b.bufferUsedSize, 8);
      final ocb.IObjectCollectionBufferEntry entry =
          b.createEntry(<String, num>{'foo': 3, 'bar': 4});
      expect(b.entryCount, 2);
      expect(b.viewUsedSize, 4);
      expect(b.bufferUsedSize, 16);
      entry.dispose();
      expect(b.entryCount, 1);
      expect(b.viewUsedSize, 2);
      expect(b.bufferUsedSize, 8);
    });

    test('entry.get / entry.set / onDidChange', () {
      final ocb.IObjectCollectionBuffer b = _buffer(<String>['foo', 'bar'], 5);
      final ocb.IObjectCollectionBufferEntry entry =
          b.createEntry(<String, num>{'foo': 1, 'bar': 2});
      expect(entry.get('foo'), 1);
      expect(entry.get('bar'), 2);

      int changeCount = 0;
      b.onDidChange((dynamic _) => changeCount++);
      entry.set('foo', 3);
      expect(changeCount, 1);
      expect(entry.get('foo'), 3);
      entry.set('bar', 4);
      expect(changeCount, 2);
      expect(entry.get('bar'), 4);
    });

    test('setRaw sets all properties and flags dirty', () {
      final ocb.IObjectCollectionBuffer b = _buffer(<String>['foo', 'bar'], 5);
      final ocb.IObjectCollectionBufferEntry entry =
          b.createEntry(<String, num>{'foo': 1, 'bar': 2});
      expect(b.dirtyTracker.isDirty, isTrue);
      b.dirtyTracker.clear();
      expect(b.dirtyTracker.isDirty, isFalse);
      entry.setRaw(<num>[7, 8]);
      expect(entry.get('foo'), 7);
      expect(entry.get('bar'), 8);
      expect(b.dirtyTracker.isDirty, isTrue);
      expect(
          () => entry.setRaw(<num>[1, 2, 3]),
          throwsA(isA<StateError>()));
    });

    test('onDidChangeBuffer fires on expansion', () {
      final ocb.IObjectCollectionBuffer b = _buffer(<String>['a', 'b'], 1);
      int expansions = 0;
      b.onDidChangeBuffer((dynamic _) => expansions++);
      b.createEntry(<String, num>{'a': 1, 'b': 2});
      expect(expansions, 0);
      b.createEntry(<String, num>{'a': 3, 'b': 4});
      expect(expansions, 1);
    });
  });

  group('batch18 · treeViewsDnd', () {
    test('add / remove drag operation transfer', () async {
      final dnd.TreeViewsDnDService<int> service =
          dnd.TreeViewsDnDService<int>();
      final Future<int?> promise = Future<int?>.value(42);
      service.addDragOperationTransfer('u1', promise);
      final Future<int?>? removed = service.removeDragOperationTransfer('u1');
      expect(removed, isNotNull);
      expect(await removed, 42);
      // second removal returns null
      expect(service.removeDragOperationTransfer('u1'), isNull);
    });

    test('remove with null / empty / missing uuid returns null', () {
      final dnd.TreeViewsDnDService<String> service =
          dnd.TreeViewsDnDService<String>();
      expect(service.removeDragOperationTransfer(null), isNull);
      expect(service.removeDragOperationTransfer(''), isNull);
      expect(service.removeDragOperationTransfer('missing'), isNull);
    });

    test('DraggedTreeItemsIdentifier carries identifier', () {
      final dnd.DraggedTreeItemsIdentifier id =
          dnd.DraggedTreeItemsIdentifier('abc');
      expect(id.identifier, 'abc');
    });
  });

  group('batch18 · hoverActionIds', () {
    test('action ids and labels', () {
      expect(hover.SHOW_OR_FOCUS_HOVER_ACTION_ID, 'editor.action.showHover');
      expect(hover.HIDE_HOVER_ACTION_ID, 'editor.action.hideHover');
      expect(hover.GO_TO_TOP_HOVER_ACTION_ID, 'editor.action.goToTopHover');
      expect(hover.INCREASE_HOVER_VERBOSITY_ACTION_ID,
          'editor.action.increaseHoverVerbosityLevel');
      expect(hover.INCREASE_HOVER_VERBOSITY_ACCESSIBLE_ACTION_ID,
          'editor.action.increaseHoverVerbosityLevelFromAccessibleView');
      expect(hover.DECREASE_HOVER_VERBOSITY_ACTION_ID,
          'editor.action.decreaseHoverVerbosityLevel');
      expect(hover.HIDE_LONG_LINE_WARNING_HOVER_ACTION_ID,
          'editor.action.hideLongLineWarningHover');
      // nls.localize with an object key falls back to the message.
      expect(hover.INCREASE_HOVER_VERBOSITY_ACTION_LABEL,
          'Increase Hover Verbosity Level');
      expect(hover.DECREASE_HOVER_VERBOSITY_ACTION_LABEL,
          'Decrease Hover Verbosity Level');
    });
  });

  group('batch18 · raster', () {
    test('carrier classes preserve glyph contract', () {
      final raster.IRasterizedGlyph glyph = raster.RasterizedGlyph(
        source: raster.OffscreenCanvas(Object()),
        boundingBox: const raster.BoundingBox(
            left: 1, top: 2, right: 3, bottom: 4),
        originOffset: const raster.OriginOffset(x: 5, y: 6),
        fontBoundingBoxAscent: 7,
        fontBoundingBoxDescent: 8,
      );
      expect(glyph.boundingBox.left, 1);
      expect(glyph.boundingBox.bottom, 4);
      expect(glyph.originOffset.x, 5);
      expect(glyph.originOffset.y, 6);
      expect(glyph.fontBoundingBoxAscent, 7);
      expect(glyph.fontBoundingBoxDescent, 8);
      expect(glyph.source, isA<raster.OffscreenCanvas>());

      const raster.TextMetrics metrics = raster.TextMetrics(width: 10);
      expect(metrics.width, 10);
    });
  });
}
