// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/browser/cssValue.ts
// Translated 1:1 from TypeScript. `CssFragment` (a branded string) -> a plain
// String typedef (Dart has no nominal string brands). The browser global
// `CSS.escape` is bridged through an injectable top-level [cssEscape] function
// (same convention as other `globalThis` bridges). Template tag `inline` ->
// a normal function taking the static strings plus interpolated values.
// ---------------------------------------------------------------------------

import '../common/color.dart' show Color;
import '../common/network.dart' show FileAccess;
import '../common/uri.dart' show URI;

/// 1:1: `export type CssFragment = string & { readonly __cssFragment: unique
/// symbol }`
typedef CssFragment = String;

CssFragment asFragment(String raw) => raw;

/// Bridge for the browser global `CSS.escape`. Replaceable in tests/platforms.
String Function(String value) cssEscape = _defaultCssEscape;

/// A close 1:1 implementation of the CSSOM `CSS.escape` algorithm (CSS Ident
/// escaping). Used as the default bridge since Dart has no DOM.
String _defaultCssEscape(String value) {
  final StringBuffer out = StringBuffer();
  final List<int> cps = value.runes.toList();
  for (int i = 0; i < cps.length; i++) {
    final int cp = cps[i];
    if (cp == 0) {
      out.write('\uFFFD');
    } else if ((cp >= 1 && cp <= 0x1F) || cp == 0x7F) {
      out.write('\\${cp.toRadixString(16)} ');
    } else if (cp >= 0x30 && cp <= 0x39 && i == 0) {
      out.write('\\${cp.toRadixString(16)} ');
    } else if (cp >= 0x30 && cp <= 0x39 && i == 1 && cps[0] == 0x2D) {
      out.write('\\${cp.toRadixString(16)} ');
    } else if ((cp >= 0x41 && cp <= 0x5A) ||
        (cp >= 0x61 && cp <= 0x7A) ||
        cp == 0x5F ||
        cp >= 0x80) {
      out.write(String.fromCharCode(cp));
    } else if (cp == 0x2D) {
      if (i == cps.length - 1) {
        out.write('\\-');
      } else {
        out.write('-');
      }
    } else {
      out.write('\\${String.fromCharCode(cp)}');
    }
  }
  return out.toString();
}

/// 1:1: `export function asCssValueWithDefault`
String asCssValueWithDefault(String? cssPropertyValue, String dflt) {
  if (cssPropertyValue != null) {
    final RegExp variableMatch = RegExp(r'^\s*var\((.+)\)$');
    final RegExpMatch? match = variableMatch.firstMatch(cssPropertyValue);
    if (match != null) {
      final List<String> varArguments = match.group(1)!.split(',');
      final List<String> args =
          varArguments.length >= 2 ? varArguments.sublist(0, 2) : varArguments;
      if (args.length == 2) {
        dflt = asCssValueWithDefault(args[1].trim(), dflt);
      }
      return 'var(${args[0]}, $dflt)';
    }
    return cssPropertyValue;
  }
  return dflt;
}

/// 1:1: `export function sizeValue`
CssFragment sizeValue(String value) {
  final String out = value.replaceAll(RegExp(r'[^\w.%+-]', caseSensitive: false), '');
  if (out != value) {
    // console.warn(`CSS size ${value} modified to ${out} to be safe for CSS`);
  }
  return asFragment(out);
}

/// 1:1: `export function hexColorValue`
CssFragment hexColorValue(String value) {
  // Dart RegExp matches JS semantics here (verified: `[x]` -> `[`).
  final String out =
      value.replaceAll(RegExp(r'[^[0-9a-fA-F#]]', caseSensitive: false), '');
  if (out != value) {
    // console.warn(`CSS hex color ${value} modified to ${out} to be safe for CSS`);
  }
  return asFragment(out);
}

/// 1:1: `export function identValue`
CssFragment identValue(String value) {
  final String out =
      value.replaceAll(RegExp(r'[^_\-a-z0-9]', caseSensitive: false), '');
  if (out != value) {
    // console.warn(`CSS ident value ${value} modified to ${out} to be safe for CSS`);
  }
  return asFragment(out);
}

/// 1:1: `export function stringValue`
CssFragment stringValue(String value) {
  // JS `'\000027'` == NUL(0) + "027" (verified by code points); Dart
  // `'\x00027'` reproduces the exact same code units.
  return asFragment("'${value.replaceAll(RegExp(r"'"), '\x00027')}'");
}

/// 1:1: `export function asCSSUrl` — returns url('...')
CssFragment asCSSUrl(URI? uri) {
  if (uri == null) {
    return asFragment("url('')");
  }
  final String escaped = cssEscape(FileAccess.uriToBrowserUri(uri).toString(true));
  return inline(<String>["url('", "')"], <Object?>[asFragment(escaped)]);
}

/// 1:1: `export function className`
CssFragment className(String value, [bool escapingExpected = false]) {
  final String out = cssEscape(value);
  if (!escapingExpected && out != value) {
    // console.warn(`CSS class name ${value} modified to ${out} to be safe for CSS`);
  }
  return asFragment(out);
}

/// 1:1: `inline` template tag — `strings` are the static pieces, `values` the
/// interpolated css-safe fragments/colors.
CssFragment inline(List<String> strings, List<Object?> values) {
  final StringBuffer result = StringBuffer();
  for (int i = 0; i < strings.length; i++) {
    final Object? value = i < values.length ? values[i] : null;
    result
      ..write(strings[i])
      ..write(value ?? '');
  }
  return asFragment(result.toString());
}

/// 1:1: `export class Builder`
class Builder {
  final List<CssFragment> _parts = <CssFragment>[];

  void push(List<CssFragment> parts) => _parts.addAll(parts);

  CssFragment join([String joiner = '\n']) => asFragment(_parts.join(joiner));
}
