// Truth replay for batch211:
//   `editor/browser/config/charWidthReader.ts`.
//
// Expectations come from `tool/ts2dart/batch211_truth.json`, produced by
// `tool/ts2dart/_batch211_truth.cjs` (real transpiled reader + real
// `domFontInfo`/`BareFontInfo`; the DOM is a deterministic element model whose
// `offsetWidth` derives from the inherited font style).
//
// NOTE: `charWidthReader.ts` has no official test of its own; truth comes from
// executing the real source.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/browser/dom.dart' as dom;
import '../lib/src/monaco/base/browser/window.dart' show mainWindow;
import '../lib/src/monaco/editor/browser/config/charWidthReader.dart' as reader;
import '../lib/src/monaco/editor/common/config/fontInfo.dart' as fontInfo;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

List<dynamic> _list(dynamic value) => value as List<dynamic>;

Matcher _exp(dynamic value) => value == null ? isNull : equals(value);

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch211_truth.json').readAsStringSync()));

/// Inherited font style of the nearest styled ancestor (the fake layout rule
/// mirrors the harness: bold = 12px/char, italic = 11px/char, else 10px).
Map<String, Object?>? _styleGroup(dom.DomElement element) {
  dom.DomNode? node = element.parentNode;
  while (node is dom.DomElement) {
    final dom.DomStyle style = node.style;
    if (style['fontFamily'] != null) {
      return <String, Object?>{
        'fontWeight': style['fontWeight'],
        'fontStyle': style['fontStyle'],
        'fontFamily': style['fontFamily'],
        'fontSize': style['fontSize'],
        'fontFeatureSettings': style['fontFeatureSettings'],
        'fontVariationSettings': style['fontVariationSettings'],
        'lineHeight': style['lineHeight'],
        'letterSpacing': style['letterSpacing'],
      };
    }
    node = node.parentNode;
  }
  return null;
}

int _charWidthOf(dom.DomElement element) {
  dom.DomNode? node = element.parentNode;
  while (node is dom.DomElement) {
    if (node.style['fontWeight'] == 'bold') return 12;
    if (node.style['fontStyle'] == 'italic') return 11;
    node = node.parentNode;
  }
  return 10;
}

bool _mapEquals(Map<String, Object?> a, Map<String, Object?> b) {
  if (a.length != b.length) return false;
  for (final String key in a.keys) {
    if (!b.containsKey(key) || a[key] != b[key]) return false;
  }
  return true;
}

void main() {
  final Map<String, dynamic> truth = _truth();

  tearDown(() => reader.offsetWidthOverride = null);

  test('batch211 measures every request through the DOM', () {
    final dom.DomWindowCarrier targetWindow = dom.windowCarrier(mainWindow);
    final fontInfo.BareFontInfo bareFontInfo = fontInfo.BareFontInfo.create(
        'monospace', 'normal', 14, '"liga" 0', '"wdth" 100', 19, 1, 1, false);

    final List<reader.CharWidthRequest> requests = <reader.CharWidthRequest>[
      reader.CharWidthRequest('M', reader.CharWidthRequestType.Regular),
      reader.CharWidthRequest('i', reader.CharWidthRequestType.Italic),
      reader.CharWidthRequest('W', reader.CharWidthRequestType.Bold),
      reader.CharWidthRequest(' ', reader.CharWidthRequestType.Regular),
      reader.CharWidthRequest('ab', reader.CharWidthRequestType.Bold),
    ];

    final List<Map<String, Object?>> spanInfo = <Map<String, Object?>>[];
    final List<Map<String, Object?>?> groups = <Map<String, Object?>?>[];
    int widthReads = 0;

    reader.offsetWidthOverride = (dom.DomElement element) {
      widthReads++;
      final String text = element.textContent;
      spanInfo.add(<String, Object?>{
        'length': text.length,
        'first': text.isEmpty ? null : text[0],
        'last': text.isEmpty ? null : text[text.length - 1],
      });
      groups.add(_styleGroup(element));
      return text.length * _charWidthOf(element);
    };

    reader.readCharWidths(targetWindow, bareFontInfo, requests);

    expect(requests.map((reader.CharWidthRequest r) => r.width).toList(),
        _exp(_list(truth['widths'])));
    expect(
        requests
            .map((reader.CharWidthRequest r) => <String, Object?>{
                  'chr': r.chr,
                  'type': r.type,
                  'width': r.width,
                })
            .toList(),
        _exp(_list(truth['fulfilledWidths'])));
    expect(spanInfo, _exp(_list(truth['spanInfo'])));
    expect(widthReads, truth['widthReads']);

    // Three distinct font groups, matching the harness snapshots.
    final List<Map<String, Object?>> actualGroups =
        groups.whereType<Map<String, Object?>>().toList();
    final List<Map<String, Object?>> uniqueGroups = <Map<String, Object?>>[];
    for (final Map<String, Object?> group in actualGroups) {
      if (!uniqueGroups.any((Map<String, Object?> g) =>
          _mapEquals(g, group))) {
        uniqueGroups.add(group);
      }
    }
    final List<Map<String, dynamic>> expectedGroups =
        _list(truth['fontGroups']).map((dynamic g) => _map(g)).toList();
    expect(uniqueGroups.length, expectedGroups.length);
    // `fontFamily` is host-dependent (`EDITOR_FONT_DEFAULTS.fontFamily`), so the
    // expected value is derived from the same `BareFontInfo` the reader used
    // instead of being baked into the truth JSON.
    final String massagedFontFamily = bareFontInfo.getMassagedFontFamily();
    for (final Map<String, dynamic> expected in expectedGroups) {
      final Map<String, Object?> withFamily = <String, Object?>{
        ...expected,
        'fontFamily': massagedFontFamily,
      }..remove('children'); // the harness also records the child tags
      expect(
          uniqueGroups.any((Map<String, Object?> group) =>
              _mapEquals(group, withFamily)),
          isTrue,
          reason: 'missing font group ${expected['fontWeight']}/${expected['fontStyle']}; actual=$uniqueGroups');
    }
  });

  test('batch211 removes the measurement container and keeps request types',
      () {
    final dom.DomWindowCarrier targetWindow = dom.windowCarrier(mainWindow);
    final fontInfo.BareFontInfo bareFontInfo = fontInfo.BareFontInfo.create(
        'monospace', 'normal', 14, '', '', 19, 0, 1, false);
    reader.offsetWidthOverride = (dom.DomElement element) => element.textContent.length;

    reader.readCharWidths(
      targetWindow,
      bareFontInfo,
      <reader.CharWidthRequest>[
        reader.CharWidthRequest('M', reader.CharWidthRequestType.Regular),
      ],
    );

    final Map<String, dynamic> defaults = _map(truth['defaults']);
    expect(reader.CharWidthRequestType.Regular, defaults['regular']);
    expect(reader.CharWidthRequestType.Italic, defaults['italic']);
    expect(reader.CharWidthRequestType.Bold, defaults['bold']);
    expect(targetWindow.document.body.childNodes.length,
        truth['bodyChildCountAfterRead']);
  });

  test('batch211 fulfill() overwrites the measured width', () {
    final reader.CharWidthRequest request =
        reader.CharWidthRequest('x', reader.CharWidthRequestType.Regular);
    expect(request.width, 0);
    request.fulfill(7);
    expect(request.width, 7);
    expect(request.chr, 'x');
    expect(request.type, reader.CharWidthRequestType.Regular);
  });
}
