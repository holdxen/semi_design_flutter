import 'dart:convert';
import 'dart:io';

import '../lib/src/monaco/base/common/color.dart' show Color;
import '../lib/src/monaco/editor/common/core/misc/rgba.dart' show RGBA8;

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/languages.dart'
    show TokenizationRegistry;
import '../lib/src/monaco/editor/common/viewModel/minimapTokensColorTracker.dart'
    show ColorDynamic, MinimapTokensColorTracker;

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root =
      jsonDecode(File('tool/ts2dart/batch422_truth.json').readAsStringSync())
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

List<Object?> _rgbaJson(Object v) {
  if (v is RGBA8) {
    return <Object?>[
      v.r.toInt(),
      v.g.toInt(),
      v.b.toInt(),
      v.a.toInt(),
    ];
  }
  final List<dynamic> a = v as List<dynamic>;
  return <Object?>[
    (a[0] as num).toInt(),
    (a[1] as num).toInt(),
    (a[2] as num).toInt(),
    (a[3] as num).toInt(),
  ];
}

ColorDynamic _cd(int r, int g, int b, num a, double lum) =>
    ColorDynamic(r, g, b, a, lum);

void main() {
  final Map<String, dynamic> truth = _truth();

  setUp(() {
    MinimapTokensColorTracker.colorMapProviderForReplay = null;
    MinimapTokensColorTracker.resetForReplay();
  });

  test('minimap tokens color tracker truth replay', () {
    final Map<String, Object?> actual = <String, Object?>{};

    // Case 1: no colormap.
    MinimapTokensColorTracker.colorMapProviderForReplay = () => null;
    final MinimapTokensColorTracker t1 = MinimapTokensColorTracker.getInstance();
    actual['no-colormap'] = <String, Object?>{
      'colors': <int>[0, 1, 2, 3]
          .map((int id) => _rgbaJson(t1.getColor(id)))
          .toList(),
      'light': t1.backgroundIsLight(),
    };

    // Case 2: light background.
    MinimapTokensColorTracker.resetForReplay();
    List<ColorDynamic>? cm2 = <ColorDynamic>[
      _cd(0, 0, 0, 0, 0.0),
      _cd(0, 0, 0, 255, 0.0),
      _cd(255, 255, 255, 255, 1.0),
      _cd(255, 0, 0, 0.5, 0.2),
    ];
    MinimapTokensColorTracker.colorMapProviderForReplay = () => cm2;
    final MinimapTokensColorTracker t2 = MinimapTokensColorTracker.getInstance();
    actual['light-bg'] = <String, Object?>{
      'colors': <int>[0, 1, 2, 3, 4]
          .map((int id) => _rgbaJson(t2.getColor(id)))
          .toList(),
      'light': t2.backgroundIsLight(),
    };

    // Case 3: dark background.
    MinimapTokensColorTracker.resetForReplay();
    List<ColorDynamic>? cm3 = <ColorDynamic>[
      _cd(0, 0, 0, 0, 0.0),
      _cd(255, 255, 255, 255, 1.0),
      _cd(0, 0, 0, 255, 0.1),
      _cd(10, 20, 30, 0.25, 0.05),
    ];
    MinimapTokensColorTracker.colorMapProviderForReplay = () => cm3;
    final MinimapTokensColorTracker t3 = MinimapTokensColorTracker.getInstance();
    actual['dark-bg'] = <String, Object?>{
      'colors': <int>[1, 2, 3]
          .map((int id) => _rgbaJson(t3.getColor(id)))
          .toList(),
      'light': t3.backgroundIsLight(),
    };

    // Case 4: events — lang-only change doesn't fire; colorMap change fires.
    MinimapTokensColorTracker.resetForReplay();
    List<ColorDynamic>? cm4 = <ColorDynamic>[
      _cd(0, 0, 0, 0, 0.0),
      _cd(0, 0, 0, 255, 0.0),
      _cd(255, 255, 255, 255, 1.0),
    ];
    MinimapTokensColorTracker.colorMapProviderForReplay = () => cm4;
    final MinimapTokensColorTracker t4 = MinimapTokensColorTracker.getInstance();
    int fired = 0;
    t4.onDidChange((_) => fired++);
    // Language-only registry change (changedColorMap=false) → no fire.
    TokenizationRegistry.handleChange(<String>['ts']);
    final int afterLang = fired;
    // Switch to dark color map, then fire a real registry colorMap change.
    cm4 = <ColorDynamic>[
      _cd(0, 0, 0, 0, 0.0),
      _cd(255, 255, 255, 255, 1.0),
      _cd(0, 0, 0, 255, 0.2),
    ];
    TokenizationRegistry.setColorMap(<Color?>[]);
    actual['events'] = <String, Object?>{
      'afterLang': afterLang,
      'afterColor': fired,
      'light': t4.backgroundIsLight(),
      'bgColor': _rgbaJson(t4.getColor(2)),
    };

    // Case 5: getColor fallback for out-of-range IDs.
    MinimapTokensColorTracker.resetForReplay();
    List<ColorDynamic>? cm5 = <ColorDynamic>[
      _cd(0, 0, 0, 0, 0.0),
      _cd(0, 0, 0, 255, 0.0),
      _cd(128, 128, 128, 255, 0.5),
    ];
    MinimapTokensColorTracker.colorMapProviderForReplay = () => cm5;
    final MinimapTokensColorTracker t5 = MinimapTokensColorTracker.getInstance();
    actual['fallback'] = <String, Object?>{
      'neg': _rgbaJson(t5.getColor(-1)),
      'oob': _rgbaJson(t5.getColor(99)),
      'bg': _rgbaJson(t5.getColor(2)),
      'errors': <Object?>[],
    };

    expect(jsonEncode(actual), jsonEncode(truth));
  });
}
