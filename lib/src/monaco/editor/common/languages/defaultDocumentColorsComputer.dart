// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/languages/defaultDocumentColorsComputer.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// TS interfaces (`IColor`, `IColorInformation`, `IDocumentColorComputerTarget`,
// `IPosition`, `IRange`) are erased per repo convention. Lightweight carriers
// are kept here so the runtime functions type-check and can be replayed.
// ---------------------------------------------------------------------------

import '../../../base/common/color.dart';
import '../core/position.dart';
import '../core/range.dart';

/// 1:1: `interface IColor { red; green; blue; alpha; }`
class IColor {
  final num red;
  final num green;
  final num blue;
  final num alpha;
  IColor(this.red, this.green, this.blue, this.alpha);
}

/// 1:1: `interface IColorInformation { range: IRange; color: IColor; }`
class IColorInformation {
  final IRange range;
  final IColor color;
  IColorInformation(this.range, this.color);
}

/// 1:1: `interface IDocumentColorComputerTarget`
abstract class IDocumentColorComputerTarget {
  String getValue();
  IPosition positionAt(int offset);
  Iterable<RegExpMatch> findMatches(RegExp regex);
}

/// 1:1 JS `Number(str)` for the numeric capture groups parsed here.
/// The groups are ASCII digits/whitespace from `regexParameters`, so this
/// covers the semantics actually exercised: empty/whitespace-only -> 0,
/// otherwise parse; non-numeric -> null (JS NaN, filtered by caller).
num? _jsNumber(String str) {
  if (str.trim().isEmpty) return 0;
  return num.tryParse(str.trim());
}

/// 1:1: `function _parseCaptureGroups(captureGroups: IterableIterator<string>)`
/// JS: `const parsedNumber = Number(captureGroup);
///      if (parsedNumber || parsedNumber === 0 && captureGroup.replace(/\s/g,'') !== '')`
List<num> _parseCaptureGroups(Iterable<String?> captureGroups) {
  final values = <num>[];
  for (final captureGroup in captureGroups) {
    if (captureGroup == null) continue; // undefined in JS -> Number = NaN
    final parsed = _jsNumber(captureGroup);
    if (parsed == null) continue;
    final nonWhitespace = captureGroup.replaceAll(RegExp(r'\s'), '');
    if (parsed != 0 || (parsed == 0 && nonWhitespace.isNotEmpty)) {
      values.add(parsed);
    }
  }
  return values;
}

/// 1:1: `function _toIColor(r, g, b, a): IColor`
/// Source assigns by name: red: r/255, blue: b/255, green: g/255, alpha: a.
IColor _toIColor(num r, num g, num b, num a) =>
    IColor(r / 255, g / 255, b / 255, a);

/// 1:1: `function _findRange(model, match): IRange | undefined`
IRange? _findRange(IDocumentColorComputerTarget model, RegExpMatch match) {
  final int index = match.start;
  final String matched = match.group(0) ?? '';
  final int length = matched.length;
  final IPosition startPosition = model.positionAt(index);
  return Range(
    startPosition.lineNumber,
    startPosition.column,
    startPosition.lineNumber,
    startPosition.column + length,
  );
}

/// 1:1: `function _findHexColorInformation(range, hexValue)`
IColorInformation? _findHexColorInformation(IRange? range, String hexValue) {
  if (range == null) return null;
  final Color? parsedHexColor = ColorFormatCSS.parseHex(hexValue);
  if (parsedHexColor == null) return null;
  return IColorInformation(
    range,
    _toIColor(parsedHexColor.rgba.r, parsedHexColor.rgba.g,
        parsedHexColor.rgba.b, parsedHexColor.rgba.a),
  );
}

Iterable<String?> _matchGroups(RegExpMatch match) sync* {
  for (int i = 0; i <= match.groupCount; i++) {
    yield match.group(i);
  }
}

/// 1:1: `function _findRGBColorInformation(range, matches, isAlpha)`
IColorInformation? _findRGBColorInformation(
    IRange? range, List<RegExpMatch> matches, bool isAlpha) {
  if (range == null || matches.length != 1) return null;
  final parsed = _parseCaptureGroups(_matchGroups(matches[0]));
  return IColorInformation(
    range,
    _toIColor(parsed[0], parsed[1], parsed[2], isAlpha ? parsed[3] : 1),
  );
}

/// 1:1: `function _findHSLColorInformation(range, matches, isAlpha)`
IColorInformation? _findHSLColorInformation(
    IRange? range, List<RegExpMatch> matches, bool isAlpha) {
  if (range == null || matches.length != 1) return null;
  final parsed = _parseCaptureGroups(_matchGroups(matches[0]));
  final Color colorEquivalent = Color(HSLA(
    parsed[0],
    parsed[1] / 100,
    parsed[2] / 100,
    isAlpha ? parsed[3] : 1,
  ));
  return IColorInformation(
    range,
    _toIColor(colorEquivalent.rgba.r, colorEquivalent.rgba.g,
        colorEquivalent.rgba.b, colorEquivalent.rgba.a),
  );
}

/// 1:1: `function _findMatches(model, regex): RegExpMatchArray[]`
List<RegExpMatch> _findMatches(Object model, RegExp regex) {
  if (model is String) {
    return regex.allMatches(model).toList();
  }
  return (model as IDocumentColorComputerTarget).findMatches(regex).toList();
}

// Regex literals — copied 1:1 from the TypeScript source. Dart RegExp supports
// lookbehind and `m` is expressed with `multiLine: true` (JS `/gm`).
final RegExp _initialValidationRegex = RegExp(
  r'''\b(rgb|rgba|hsl|hsla)(\([0-9\s,.\%\/]*\))|^(#)([A-Fa-f0-9]{3})(?=[\s'";,)]|$)|^(#)([A-Fa-f0-9]{4})(?=[\s'";,)]|$)|^(#)([A-Fa-f0-9]{6})(?=[\s'";,)]|$)|^(#)([A-Fa-f0-9]{8})(?=[\s'";,)]|$)|(?<=['"\s])(#)([A-Fa-f0-9]{3})(?=[\s'";,)]|$)|(?<=['"\s])(#)([A-Fa-f0-9]{4})(?=[\s'";,)]|$)|(?<=['"\s])(#)([A-Fa-f0-9]{6})(?=[\s'";,)]|$)|(?<=['"\s])(#)([A-Fa-f0-9]{8})(?=[\s'";,)]|$)''',
  multiLine: true,
);

final RegExp _rgbParamsRegex = RegExp(
  r"^\(\s*(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])\s*[\s,]\s*(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])\s*[\s,]\s*(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])\s*\)$",
  multiLine: true,
);
final RegExp _rgbaParamsRegex = RegExp(
  r"^\(\s*(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])\s*[\s,]\s*(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])\s*[\s,]\s*(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])\s*(?:[\s,]|[\s]*\/)\s*(0[.][0-9]+|[.][0-9]+|[01][.]|[01])\s*\)$",
  multiLine: true,
);
final RegExp _hslParamsRegex = RegExp(
  r"^\(\s*((?:360(?:\.0+)?|(?:36[0]|3[0-5][0-9]|[12][0-9][0-9]|[1-9]?[0-9])(?:\.\d+)?))\s*[\s,]\s*(100(?:\.0+)?|\d{1,2}[.]\d*|\d{1,2})%\s*[\s,]\s*(100(?:\.0+)?|\d{1,2}[.]\d*|\d{1,2})%\s*\)$",
  multiLine: true,
);
final RegExp _hslaParamsRegex = RegExp(
  r"^\(\s*((?:360(?:\.0+)?|(?:36[0]|3[0-5][0-9]|[12][0-9][0-9]|[1-9]?[0-9])(?:\.\d+)?))\s*[\s,]\s*(100(?:\.0+)?|\d{1,2}[.]\d*|\d{1,2})%\s*[\s,]\s*(100(?:\.0+)?|\d{1,2}[.]\d*|\d{1,2})%\s*(?:[\s,]|[\s]*\/)\s*(0[.][0-9]+|[.][0-9]+|[01][.]0*|[01])\s*\)$",
  multiLine: true,
);

/// 1:1: `function computeColors(model): IColorInformation[]`
List<IColorInformation> _computeColors(IDocumentColorComputerTarget model) {
  final result = <IColorInformation>[];
  final initialValidationMatches = _findMatches(model, _initialValidationRegex);

  if (initialValidationMatches.isNotEmpty) {
    for (final initialMatch in initialValidationMatches) {
      // JS: `initialMatch.filter(captureGroup => captureGroup !== undefined)`
      final initialCaptureGroups = _matchGroups(initialMatch)
          .where((g) => g != null)
          .toList();
      if (initialCaptureGroups.length < 3) continue;
      final String colorScheme = initialCaptureGroups[1]!;
      final String colorParameters = initialCaptureGroups[2]!;
      if (colorParameters.isEmpty) continue;

      IColorInformation? colorInformation;
      switch (colorScheme) {
        case 'rgb':
          colorInformation = _findRGBColorInformation(
              _findRange(model, initialMatch),
              _findMatches(colorParameters, _rgbParamsRegex),
              false);
          break;
        case 'rgba':
          colorInformation = _findRGBColorInformation(
              _findRange(model, initialMatch),
              _findMatches(colorParameters, _rgbaParamsRegex),
              true);
          break;
        case 'hsl':
          colorInformation = _findHSLColorInformation(
              _findRange(model, initialMatch),
              _findMatches(colorParameters, _hslParamsRegex),
              false);
          break;
        case 'hsla':
          colorInformation = _findHSLColorInformation(
              _findRange(model, initialMatch),
              _findMatches(colorParameters, _hslaParamsRegex),
              true);
          break;
        case '#':
          colorInformation = _findHexColorInformation(
              _findRange(model, initialMatch), colorScheme + colorParameters);
          break;
      }
      if (colorInformation != null) result.add(colorInformation);
    }
  }
  return result;
}

/// 1:1: `export function computeDefaultDocumentColors(model)`
/// Returns an empty list for an unknown caller (guard preserved from source).
List<IColorInformation> computeDefaultDocumentColors(Object? model) {
  if (model is! IDocumentColorComputerTarget) {
    return [];
  }
  return _computeColors(model);
}
