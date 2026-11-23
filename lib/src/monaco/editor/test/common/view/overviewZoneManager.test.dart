// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/common/view/overviewZoneManager.test.ts
// Translated 1:1. The three mocha cases become Dart functions carrying the
// exact `deepStrictEqual` assertions.
// `ColorZone` has no `==` override in the port, so equality is compared by
// fields to reproduce `deepStrictEqual` semantics.
// `ensureNoDisposablesAreLeakedInTestSuite()` is a suite-level harness hook and
// is intentionally omitted here.
// ---------------------------------------------------------------------------

import '../../../common/viewModel/overviewZoneManager.dart'
    show ColorZone, OverviewRulerZone, OverviewZoneManager;

const int _lineCount = 50;
const int _lineHeight = 20;

/// 1:1: manager setup shared by all three cases.
OverviewZoneManager _makeManager(num pixelRatio, num domHeight) {
  final OverviewZoneManager manager =
      OverviewZoneManager((int lineNumber) => _lineHeight * lineNumber);
  manager.setDOMWidth(30);
  manager.setDOMHeight(domHeight);
  manager.setOuterHeight(_lineCount * _lineHeight);
  manager.setLineHeight(_lineHeight);
  manager.setPixelRatio(pixelRatio);
  manager.setZones(<OverviewRulerZone>[
    OverviewRulerZone(1, 1, 0, '1'),
    OverviewRulerZone(10, 10, 0, '2'),
    OverviewRulerZone(30, 31, 0, '3'),
    OverviewRulerZone(50, 50, 0, '4'),
  ]);
  return manager;
}

bool _colorZoneEq(ColorZone a, ColorZone b) =>
    a.from == b.from && a.to == b.to && a.colorId == b.colorId;

void _assertZones(List<ColorZone> actual, List<ColorZone> expected) {
  assert(actual.length == expected.length);
  for (int i = 0; i < expected.length; i++) {
    assert(_colorZoneEq(actual[i], expected[i]),
        'zone $i: (${actual[i].from},${actual[i].to},${actual[i].colorId}) != '
        '(${expected[i].from},${expected[i].to},${expected[i].colorId})');
  }
}

/// 1:1: `test('pixel ratio 1, dom height 600')`
void testPixelRatio1DomHeight600() {
  _assertZones(_makeManager(1, 600).resolveColorZones(), <ColorZone>[
    ColorZone(12, 24, 1),
    ColorZone(120, 132, 2),
    ColorZone(360, 384, 3),
    ColorZone(588, 600, 4),
  ]);
}

/// 1:1: `test('pixel ratio 1, dom height 300')`
void testPixelRatio1DomHeight300() {
  _assertZones(_makeManager(1, 300).resolveColorZones(), <ColorZone>[
    ColorZone(6, 12, 1),
    ColorZone(60, 66, 2),
    ColorZone(180, 192, 3),
    ColorZone(294, 300, 4),
  ]);
}

/// 1:1: `test('pixel ratio 2, dom height 300')`
void testPixelRatio2DomHeight300() {
  _assertZones(_makeManager(2, 300).resolveColorZones(), <ColorZone>[
    ColorZone(12, 24, 1),
    ColorZone(120, 132, 2),
    ColorZone(360, 384, 3),
    ColorZone(588, 600, 4),
  ]);
}

void runAll() {
  testPixelRatio1DomHeight600();
  testPixelRatio1DomHeight300();
  testPixelRatio2DomHeight300();
}
