import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart' as dom;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/iconLabel/iconLabels.dart'
    as browser;
import 'package:semi_design_flutter/src/monaco/base/common/filters.dart' as filters;
import 'package:semi_design_flutter/src/monaco/base/common/iconLabels.dart' as common;
import 'package:semi_design_flutter/src/monaco/base/common/themables.dart' as themables;

final Map<String, Object?> _truth =
    json.decode(File('tool/ts2dart/batch140_truth.json').readAsStringSync())
        as Map<String, Object?>;

List<Object?> _list(Object? value) => (value as List).cast<Object?>();

void main() {
  test('escapeIcons', () {
    expect(
      _list(_truth['escapeIcons']).map((Object? e) => common.escapeIcons(e! as String)).toList(),
      _list(_truth['escapeIcons']),
    );
  });

  test('markdownEscapeEscapedIcons', () {
    // Truth stores the post-escape result; input has a single backslash.
    expect(
      common.markdownEscapeEscapedIcons(r'escaped \$(file) and \$(check~spin)'),
      _truth['markdownEscape'],
    );
  });

  test('stripIcons', () {
    final List<Object?> inputs = _list(_truth['stripIcons']);
    // Truth stores post-strip results; feed the same inputs used by the harness.
    const List<String> source = <String>[
      r'app $(file) icon',
      r'$(file) leading',
      r'trailing $(file)',
      r'escaped \$(file) here',
      'no icons',
    ];
    for (int i = 0; i < source.length; i++) {
      expect(common.stripIcons(source[i]), inputs[i]);
    }
  });

  test('getCodiconAriaLabel', () {
    expect(common.getCodiconAriaLabel(r'hello $(check) world'), _list(_truth['ariaLabel'])[0]);
    expect(common.getCodiconAriaLabel(null), _list(_truth['ariaLabel'])[1]);
    expect(common.getCodiconAriaLabel(''), _list(_truth['ariaLabel'])[2]);
  });

  test('parseLabelWithIcons', () {
    const List<String> source = <String>[
      r'abc $(file)xyz',
      r'$(check~spin)',
      'no icons here',
      r'a$(x)b$(y)c',
    ];
    final List<Object?> rows = _list(_truth['parse']);
    for (int i = 0; i < source.length; i++) {
      final common.IParsedLabelWithIcons p = common.parseLabelWithIcons(source[i]);
      final Map<String, Object?> e = rows[i] as Map<String, Object?>;
      expect(p.text, e['text'], reason: 'text for ${source[i]}');
      expect(p.iconOffsets, _list(e['iconOffsets']), reason: 'offsets for ${source[i]}');
    }
  });

  test('matchesFuzzyIconAware', () {
    final List<Object?> rows = _list(_truth['fuzzy']);
    final common.IParsedLabelWithIcons t1 = common.parseLabelWithIcons(r'abc $(file)xyz');
    final common.IParsedLabelWithIcons t2 = common.parseLabelWithIcons(r'  ab $(x) cd');
    final common.IParsedLabelWithIcons t3 = common.IParsedLabelWithIcons(
        text: 'abc', iconOffsets: <int>[]);

    final List<List<filters.IMatch>?> results = <List<filters.IMatch>?>[
      common.matchesFuzzyIconAware('abx', t1),
      common.matchesFuzzyIconAware('abx', t1, true),
      common.matchesFuzzyIconAware('ab', t2),
      common.matchesFuzzyIconAware('zzz', t2),
      common.matchesFuzzyIconAware('ab', t3),
    ];
    for (int i = 0; i < results.length; i++) {
      final Object? expected = rows[i];
      if (expected == null) {
        expect(results[i], isNull, reason: 'fuzzy $i');
        continue;
      }
      final List<Object?> exp = _list(expected);
      expect(results[i]!.length, exp.length, reason: 'fuzzy $i length');
      for (int j = 0; j < exp.length; j++) {
        final Map<String, Object?> m = exp[j] as Map<String, Object?>;
        expect(results[i]![j].start, m['start'], reason: 'fuzzy $i start $j');
        expect(results[i]![j].end, m['end'], reason: 'fuzzy $i end $j');
      }
    }
  });

  test('renderLabelWithIcons / renderIcon', () {
    final List<Object?> expected = _list(_truth['render']);
    final List<Object> rendered = browser.renderLabelWithIcons(
        r'a $(check~spin) b \$(file) c');
    rendered.add(browser.renderLabelWithIcons(r'$(check)', true).single);
    rendered.add(browser.renderIcon(
        themables.ThemeIcon('check'), true));

    expect(rendered.length, expected.length);
    for (int i = 0; i < rendered.length; i++) {
      final Object e = expected[i]!;
      final Object r = rendered[i];
      if (e is String) {
        expect(r, e, reason: 'render $i');
      } else {
        final Map<String, Object?> em = e as Map<String, Object?>;
        final dom.DomElement node = r as dom.DomElement;
        expect(node.tagName.toLowerCase(), em['tag'], reason: 'render $i tag');
        expect(node.classList.toList(), _list(em['classes']), reason: 'render $i classes');
      }
    }
  });
}
