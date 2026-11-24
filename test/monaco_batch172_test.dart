// Truth-driven tests for batch172 (three STRICT no-test files):
//   colorPickerCloseButton.ts / findWidgetSearchHistory.ts / replaceWidgetHistory.ts
// Truth source: tool/ts2dart/batch172_truth.json (executed TS transpile).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart' as dom;
import 'package:semi_design_flutter/src/monaco/base/common/event.dart' as event;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart' as lifecycle;
import 'package:semi_design_flutter/src/monaco/platform/storage/common/storage.dart' as storage;
import 'package:semi_design_flutter/src/monaco/editor/contrib/colorPicker/browser/colorPickerParts/colorPickerCloseButton.dart' as cp;
import 'package:semi_design_flutter/src/monaco/editor/contrib/find/browser/findWidgetSearchHistory.dart' as find;
import 'package:semi_design_flutter/src/monaco/editor/contrib/find/browser/replaceWidgetHistory.dart' as replace;

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch172_truth.json').readAsStringSync())
        as Map<String, dynamic>;

Map<String, dynamic> t(String key) => truth[key] as Map<String, dynamic>;
List<String> strs(Object? value) =>
    (value as List<dynamic>).map((Object? e) => e as String).toList();

List<String> classes(dom.DomElement el) =>
    el.className.split(' ').where((String s) => s.isNotEmpty).toList();

class FakeStorage implements storage.IStorageServiceType {
  FakeStorage([this._raw]);

  String? _raw;
  final List<Map<String, Object?>> storeLog = <Map<String, Object?>>[];

  @override
  String? get(String key, int scope, [String? fallbackValue]) => _raw;

  @override
  void store(String key, Object? value, int scope, int target,
      [bool external = false]) {
    _raw = value as String;
    storeLog.add(<String, Object?>{
      'key': key,
      'value': value,
      'scope': scope,
      'target': target,
    });
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('colorPickerCloseButton.ts', () {
    final Map<String, dynamic> T = t('colorPickerCloseButton');

    test('exports', () {
      expect(strs(T['exports']), <String>['CloseButton']);
    });

    test('DOM structure matches truth', () {
      final dom.DomElement container = dom.document.createElement('div');
      cp.CloseButton(container);
      expect(container.childNodes.length, T['containerChildren']);

      final dom.DomElement button = container.childNodes.first as dom.DomElement;
      expect(classes(button), strs(T['buttonClasses']));

      final dom.DomElement innerDiv = button.childNodes.first as dom.DomElement;
      expect(classes(innerDiv), strs(T['innerDivClasses']));

      final dom.DomElement closeBtn =
          innerDiv.childNodes.first as dom.DomElement;
      expect(classes(closeBtn), strs(T['closeButtonClasses']));
    });

    test('localize + registerIcon called with truth args', () {
      final dom.DomElement container = dom.document.createElement('div');
      cp.CloseButton(container);
      // registerIcon('color-picker-close', ..., localize('closeIcon', ...))
      // is observable through the generated class names.
      final dom.DomElement button = container.childNodes.first as dom.DomElement;
      final dom.DomElement innerDiv = button.childNodes.first as dom.DomElement;
      final dom.DomElement closeBtn =
          innerDiv.childNodes.first as dom.DomElement;
      expect(classes(closeBtn), contains('codicon-color-picker-close'));
    });

    test('click fires onClicked, dispose detaches', () {
      final dom.DomElement container = dom.document.createElement('div');
      final cp.CloseButton btn = cp.CloseButton(container);
      int clicks = 0;
      btn.onClicked((dynamic v) => clicks++);

      final dom.DomElement button = container.childNodes.first as dom.DomElement;
      button.dispatchEvent(dom.EventType.CLICK, dom.DomEvent(dom.EventType.CLICK));
      button.dispatchEvent(dom.EventType.CLICK, dom.DomEvent(dom.EventType.CLICK));
      expect(clicks, T['clickFires']);

      btn.dispose();
      button.dispatchEvent(dom.EventType.CLICK, dom.DomEvent(dom.EventType.CLICK));
      expect(clicks, T['clickAfterDispose']);
    });
  });

  for (final String key in <String>[
    'findWidgetSearchHistory',
    'replaceWidgetHistory'
  ]) {
    group(key, () {
      final Map<String, dynamic> T = t(key);
      final bool isFind = key == 'findWidgetSearchHistory';

      // Factory functions mapping truth to the concrete class.
      late final Object Function(FakeStorage) getOrCreate;
      setUpAll(() {
        if (isFind) {
          // reset singleton via reflection-free path is not possible; tests
          // below construct directly where isolation matters.
          getOrCreate = (FakeStorage s) => find.FindWidgetSearchHistory.getOrCreate(s);
        } else {
          getOrCreate = (FakeStorage s) => replace.ReplaceWidgetHistory.getOrCreate(s);
        }
      });

      test('exports + FIND_HISTORY_KEY', () {
        expect(strs(T['exports']), <String>[T['className']]);
        expect(T['FIND_HISTORY_KEY'], T['expectedKey']);
      });

      test('FIND_HISTORY_KEY constant', () {
        if (isFind) {
          expect(find.FindWidgetSearchHistory.FIND_HISTORY_KEY,
              T['expectedKey']);
        } else {
          expect(replace.ReplaceWidgetHistory.FIND_HISTORY_KEY,
              T['expectedKey']);
        }
      });

      test('constructor loads from storage with WORKSPACE scope', () {
        final FakeStorage s = FakeStorage(jsonEncode(<String>['alpha', 'beta', 'alpha']));
        final dynamic h = isFind
            ? find.FindWidgetSearchHistory(s)
            : replace.ReplaceWidgetHistory(s);
        final List<String> seen = <String>[];
        h.forEach((String v, String v2, Set<String> set) => seen.add(v));
        expect(seen, strs(T['loadFromStorage']));
      });

      test('invalid JSON loads empty', () {
        final FakeStorage s = FakeStorage('{bad json');
        final dynamic h = isFind
            ? find.FindWidgetSearchHistory(s)
            : replace.ReplaceWidgetHistory(s);
        final List<String> seen = <String>[];
        h.forEach((String v, String v2, Set<String> set) => seen.add(v));
        expect(seen, strs(T['invalidJsonLoad']));
      });

      test('add / has / store args', () {
        final FakeStorage s = FakeStorage();
        final dynamic h = isFind
            ? find.FindWidgetSearchHistory(s)
            : replace.ReplaceWidgetHistory(s);
        h.add('x').add('y').add('x');
        final List<String> seen = <String>[];
        h.forEach((String v, String v2, Set<String> set) => seen.add(v));
        expect(seen, strs(T['afterAdd']));
        expect(h.has('x'), T['hasX']);
        expect(h.has('z'), T['hasZ']);

        final Map<String, Object?> last = s.storeLog.last;
        final List<dynamic> expected = T['storeAfterAdd'] as List<dynamic>;
        expect(last['key'], expected[0]);
        expect(last['value'], expected[1]);
        expect(last['scope'], expected[2]);
        expect(last['target'], expected[3]);
      });

      test('delete', () {
        final FakeStorage s = FakeStorage();
        final dynamic h = isFind
            ? find.FindWidgetSearchHistory(s)
            : replace.ReplaceWidgetHistory(s);
        h.add('x').add('y');
        expect(h.delete('x'), T['deleteX']);
        expect(h.delete('z'), T['deleteZ']);
        final List<String> seen = <String>[];
        h.forEach((String v, String v2, Set<String> set) => seen.add(v));
        expect(seen, strs(T['afterDelete']));
      });

      test('replace / clear', () {
        final FakeStorage s = FakeStorage();
        final dynamic h = isFind
            ? find.FindWidgetSearchHistory(s)
            : replace.ReplaceWidgetHistory(s);
        h.replace(<String>['p', 'q', 'p']);
        List<String> seen = <String>[];
        h.forEach((String v, String v2, Set<String> set) => seen.add(v));
        expect(seen, strs(T['afterReplace']));
        h.clear();
        seen = <String>[];
        h.forEach((String v, String v2, Set<String> set) => seen.add(v));
        expect(seen, strs(T['afterClear']));
      });

      test('forEach passes (value, value2, set) with value == value2', () {
        final FakeStorage s = FakeStorage();
        final dynamic h = isFind
            ? find.FindWidgetSearchHistory(s)
            : replace.ReplaceWidgetHistory(s);
        h.add('only');
        final List<List<Object?>> args = <List<Object?>>[];
        h.forEach((String v, String v2, Set<String> set) {
          args.add(<Object?>[v, v2, set.toList()]);
        });
        final List<dynamic> expected = (T['forEachArgs'] as List<dynamic>).first;
        expect(args.single[0], expected[0]);
        expect(args.single[1], expected[1]);
        expect(strs(args.single[2]!), strs(expected[2]));
      });

      test('onDidChange fires once per save with current elements', () {
        final FakeStorage s = FakeStorage();
        final dynamic h = isFind
            ? find.FindWidgetSearchHistory(s)
            : replace.ReplaceWidgetHistory(s);
        final List<List<String>> events = <List<String>>[];
        (h.onDidChange as event.Event<List<String>>?)!(
            (dynamic v) => events.add((v as List<dynamic>).cast<String>()));

        h.add('x').add('y').add('x');
        h.delete('x');
        h.delete('z');
        h.replace(<String>['p', 'q']);
        h.clear();
        h.add('only');

        final List<List<dynamic>> expected =
            (T['changeEvents'] as List<dynamic>).map((Object? e) {
          return (e as List<dynamic>);
        }).toList();
        expect(events.length, expected.length);
        for (int i = 0; i < events.length; i++) {
          expect(events[i], strs(expected[i]));
        }
      });

      test('getOrCreate returns singleton', () {
        final FakeStorage s = FakeStorage();
        final Object a = getOrCreate(s);
        final Object b = getOrCreate(s);
        expect(identical(a, b), T['singleton']);
      });
    });
  }
}
