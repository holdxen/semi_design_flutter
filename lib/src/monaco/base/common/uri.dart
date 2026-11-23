// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/uri.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. Structure, members, algorithms and control
// flow are preserved. Dart language adaptations (no semantic change):
//   - `import 'dart:core' as core` alongside default import so the source class
//     name `Uri` (which shadows dart:core.Uri) can coexist with the two JS
//     globals `encodeURIComponent`/`decodeURIComponent` -> core.Uri.*.
//   - `with` is a Dart keyword: method `with(...)` -> `withChanges(...)`.
//   - Object-literal parameters (`with(change)`, `UriComponents`) -> value
//     classes `UriChange` / `UriComponents`; `undefined` via a sentinel.
//   - Overloaded constructors -> one generative constructor with dynamic first
//     argument; generator/mapped type alias -> `typedef UriDto<T> = dynamic`.
//   - `charCodeAt` -> `_charCodeAt` returning -1 out of range (JS returns NaN,
//     so every char-code comparison is false).
//   - `new Error(msg)` -> Dart `StateError(msg)`.
//   - `[Symbol.for('debug.description')]()` -> `debugDescription()`.
// ---------------------------------------------------------------------------

import 'dart:core';
import 'dart:core' as core;

import 'charCode.dart';
import 'marshallingIds.dart';
import 'path.dart' as paths;
import 'platform.dart' show isWindows;

final RegExp _schemePattern = RegExp(r'^\w[\w\d+.-]*$');
final RegExp _singleSlashStart = RegExp(r'^/');
final RegExp _doubleSlashStart = RegExp(r'^//');
final RegExp _badSchemeChar = RegExp(r'[^\w\d+.-]');

/// JS `String.prototype.charCodeAt` returns NaN for an out-of-range index;
/// Dart `codeUnitAt` throws. All source comparisons against NaN are false, so
/// returning -1 preserves the exact behaviour.
int _charCodeAt(String s, int i) => (i >= 0 && i < s.length) ? s.codeUnitAt(i) : -1;

/// JS global `encodeURIComponent` -> dart:core `Uri.encodeComponent`.
String _encodeURIComponent(String s) => core.Uri.encodeComponent(s);

/// JS global `decodeURIComponent` -> dart:core `Uri.decodeComponent`.
String _decodeURIComponent(String s) => core.Uri.decodeComponent(s);

void _validateUri(URI ret, [bool? strict]) {
  // scheme, must be set
  if (ret.scheme.isEmpty && strict == true) {
    throw StateError('[UriError]: Scheme is missing: {scheme: "", authority: "${ret.authority}", path: "${ret.path}", query: "${ret.query}", fragment: "${ret.fragment}"}');
  }

  // scheme, https://tools.ietf.org/html/rfc3986#section-3.1
  // ALPHA *( ALPHA / DIGIT / "+" / "-" / "." )
  if (ret.scheme.isNotEmpty && !_schemePattern.hasMatch(ret.scheme)) {
    final List<RegExpMatch> matches = _badSchemeChar.allMatches(ret.scheme).toList();
    final String detail = matches.isNotEmpty
        ? " Found '${matches[0].group(0)}' at index ${matches[0].start} (${matches.length} total)"
        : '';
    throw StateError('[UriError]: Scheme contains illegal characters.$detail (len:${ret.scheme.length})');
  }

  // path, http://tools.ietf.org/html/rfc3986#section-3.3
  // If a URI contains an authority component, then the path component
  // must either be empty or begin with a slash ("/") character.  If a URI
  // does not contain an authority component, then the path cannot begin
  // with two slash characters ("//").
  if (ret.path.isNotEmpty) {
    if (ret.authority.isNotEmpty) {
      if (!_singleSlashStart.hasMatch(ret.path)) {
        throw StateError('[UriError]: If a URI contains an authority component, then the path component must either be empty or begin with a slash ("/") character');
      }
    } else {
      if (_doubleSlashStart.hasMatch(ret.path)) {
        throw StateError('[UriError]: If a URI does not contain an authority component, then the path cannot begin with two slash characters ("//")');
      }
    }
  }
}

// for a while we allowed uris *without* schemes and this is the migration
// for them, e.g. an uri without scheme and without strict-mode warns and falls
// back to the file-scheme. that should cause the least carnage and still be a
// clear warning
String _schemeFix(String scheme, bool strict) {
  if (scheme.isEmpty && !strict) {
    return 'file';
  }
  return scheme;
}

// implements a bit of https://tools.ietf.org/html/rfc3986#section-5
String _referenceResolution(String scheme, String path) {
  // the slash-character is our 'default base' as we don't
  // support constructing URIs relative to other URIs. This
  // also means that we alter and potentially break paths.
  // see https://tools.ietf.org/html/rfc3986#section-5.1.4
  switch (scheme) {
    case 'https':
    case 'http':
    case 'file':
      if (path.isEmpty) {
        path = _slash;
      } else if (_charCodeAt(path, 0) != CharCode.Slash) {
        path = _slash + path;
      }
      break;
  }
  return path;
}

const String _empty = '';
const String _slash = '/';
final RegExp _regexp = RegExp(r'^(([^:/?#]+?):)?(\/\/([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?');

/// Sentinel for TypeScript `undefined` in object-literal parameters.
const Object _undefined = Object();

/// Uniform Resource Identifier (URI) http://tools.ietf.org/html/rfc3986.
/// This class is a simple parser which creates the basic component parts
/// (http://tools.ietf.org/html/rfc3986#section-3) with minimal validation
/// and encoding.
///
/// ```txt
///       foo://example.com:8042/over/there?name=ferret#nose
///       \_/   \______________/\_________/ \_________/ \__/
///        |           |            |            |        |
///     scheme     authority       path        query   fragment
///        |   _____________________|__
///       / \ /                        \
///       urn:example:animal:ferret:nose
/// ```
class URI implements UriComponents {
  static bool isUri(dynamic thing) {
    if (thing is URI) {
      return true;
    }
    if (thing == null || thing is! Object) {
      return false;
    }
    // Dart has no runtime reflection for arbitrary structural members;
    // UriComponents is the structural counterpart of the JS object shape.
    return thing is UriComponents;
  }

  /// scheme is the 'http' part of 'http://www.example.com/some/path?query#fragment'.
  /// The part before the first colon.
  @override
  final String scheme;

  /// authority is the 'www.example.com' part of 'http://www.example.com/some/path?query#fragment'.
  /// The part between the first double slashes and the next slash.
  @override
  final String authority;

  /// path is the '/some/path' part of 'http://www.example.com/some/path?query#fragment'.
  @override
  final String path;

  /// query is the 'query' part of 'http://www.example.com/some/path?query#fragment'.
  @override
  final String query;

  /// fragment is the 'fragment' part of 'http://www.example.com/some/path?query#fragment'.
  @override
  final String fragment;

  /// @internal — source declared `protected constructor(scheme, authority?, path?, query?, fragment?, _strict?)`.
  /// @internal — source declared `protected constructor(components: UriComponents)`.
  URI(dynamic schemeOrData, [String? authority, String? path, String? query, String? fragment, bool strict = false])
      : scheme = (schemeOrData is UriComponents)
            ? schemeOrData.scheme.isEmpty ? _empty : schemeOrData.scheme
            : _schemeFix(schemeOrData as String, strict),
        authority = (schemeOrData is UriComponents)
            ? schemeOrData.authority ?? _empty
            : authority ?? _empty,
        path = (schemeOrData is UriComponents)
            ? schemeOrData.path ?? _empty
            : _referenceResolution((schemeOrData is UriComponents)
                ? schemeOrData.scheme.isEmpty ? _empty : schemeOrData.scheme
                : _schemeFix(schemeOrData as String, strict), path ?? _empty),
        query = (schemeOrData is UriComponents)
            ? schemeOrData.query ?? _empty
            : query ?? _empty,
        fragment = (schemeOrData is UriComponents)
            ? schemeOrData.fragment ?? _empty
            : fragment ?? _empty {
    // Note: source skips validation when built from components (commented out).
    if (schemeOrData is! UriComponents) {
      _validateUri(this, strict);
    }
  }

  // ---- filesystem path -----------------------

  /// Returns a string representing the corresponding file system path of this URI.
  /// Will handle UNC paths, normalizes windows drive letters to lower-case, and uses the
  /// platform specific path separator.
  ///
  /// * Will *not* validate the path for invalid characters and semantics.
  /// * Will *not* look at the scheme of this URI.
  /// * The result shall *not* be used for display purposes but for accessing a file on disk.
  String get fsPath => uriToFsPath(this, false);

  // ---- modify to new -------------------------

  /// Source method name is `with` (a Dart keyword); renamed to `withChanges`.
  URI withChanges(UriChange? change) {
    if (change == null) {
      return this;
    }

    Object? newScheme = change.scheme;
    Object? newAuthority = change.authority;
    Object? newPath = change.path;
    Object? newQuery = change.query;
    Object? newFragment = change.fragment;

    String schemeValue;
    if (identical(newScheme, _undefined)) {
      schemeValue = scheme;
    } else if (newScheme == null) {
      schemeValue = _empty;
    } else {
      schemeValue = newScheme as String;
    }

    String authorityValue;
    if (identical(newAuthority, _undefined)) {
      authorityValue = authority;
    } else if (newAuthority == null) {
      authorityValue = _empty;
    } else {
      authorityValue = newAuthority as String;
    }

    String pathValue;
    if (identical(newPath, _undefined)) {
      pathValue = path;
    } else if (newPath == null) {
      pathValue = _empty;
    } else {
      pathValue = newPath as String;
    }

    String queryValue;
    if (identical(newQuery, _undefined)) {
      queryValue = query;
    } else if (newQuery == null) {
      queryValue = _empty;
    } else {
      queryValue = newQuery as String;
    }

    String fragmentValue;
    if (identical(newFragment, _undefined)) {
      fragmentValue = fragment;
    } else if (newFragment == null) {
      fragmentValue = _empty;
    } else {
      fragmentValue = newFragment as String;
    }

    if (schemeValue == scheme &&
        authorityValue == authority &&
        pathValue == path &&
        queryValue == query &&
        fragmentValue == fragment) {
      return this;
    }

    return Uri(schemeValue, authorityValue, pathValue, queryValue, fragmentValue);
  }

  // ---- parse & validate ------------------------

  /// Creates a new URI from a string, e.g. `http://www.example.com/some/path`,
  /// `file:///usr/home`, or `scheme:with/path`.
  static URI parse(String value, [bool strict = false]) {
    final RegExpMatch? match = _regexp.firstMatch(value);
    if (match == null) {
      return Uri(_empty, _empty, _empty, _empty, _empty);
    }
    return Uri(
      match.group(2) ?? _empty,
      percentDecode(match.group(4) ?? _empty),
      percentDecode(match.group(5) ?? _empty),
      percentDecode(match.group(7) ?? _empty),
      percentDecode(match.group(9) ?? _empty),
      strict,
    );
  }

  /// Creates a new URI from a file system path, e.g. `c:\my\files`,
  /// `/usr/home`, or `\\server\share\some\path`.
  static URI file(String path) {
    String authority = _empty;

    // normalize to fwd-slashes on windows,
    // on other systems bwd-slashes are valid
    // filename character, eg /f\oo/ba\r.txt
    if (isWindows) {
      path = path.replaceAll('\\', _slash);
    }

    // check for authority as used in UNC shares
    // or use the path as given
    if (_charCodeAt(path, 0) == CharCode.Slash && _charCodeAt(path, 1) == CharCode.Slash) {
      final int idx = path.indexOf(_slash, 2);
      if (idx == -1) {
        authority = path.substring(2);
        path = _slash;
      } else {
        authority = path.substring(2, idx);
        path = path.substring(idx).isEmpty ? _slash : path.substring(idx);
      }
    }

    return Uri('file', authority, path, _empty, _empty);
  }

  /// Creates new URI from uri components.
  static URI from(UriComponents components, [bool? strict]) {
    return Uri(
      components.scheme,
      components.authority,
      components.path,
      components.query,
      components.fragment,
      strict ?? false,
    );
  }

  /// Join a URI path with path fragments and normalizes the resulting path.
  /// Source varargs `...pathFragment` -> `List<String>`.
  static URI joinPath(URI uri, List<String> pathFragment) {
    if (uri.path.isEmpty) {
      throw StateError('[UriError]: cannot call joinPath on URI without path: ${uri.toString()}');
    }
    late String newPath;
    if (isWindows && uri.scheme == 'file') {
      newPath = URI.file(paths.win32.join(<String>[uriToFsPath(uri, true), ...pathFragment])).path;
    } else {
      newPath = paths.posix.join(<String>[uri.path, ...pathFragment]);
    }
    return uri.withChanges(UriChange(path: newPath));
  }

  // ---- printing/externalize ---------------------------

  /// Creates a string representation for this URI.
  @override
  String toString([bool skipEncoding = false]) {
    return _asFormatted(this, skipEncoding);
  }

  UriComponents toJSON() => this;

  /// A helper function to revive URIs.
  static URI? revive(dynamic data) {
    if (data == null) {
      return null;
    } else if (data is URI) {
      return data;
    } else {
      final UriComponents components = data as UriComponents;
      final Uri result = Uri(components);
      result._formatted = (components is UriState) ? components.external : null;
      result._fsPath = (components is UriState && components._sep == _pathSepMarker)
          ? components.fsPath
          : null;
      return result;
    }
  }

  /// Source: `[Symbol.for('debug.description')]()`.
  String debugDescription() => 'URI(${toString()})';
}

/// Object-literal interface -> value class. Source fields are optional.
class UriComponents {
  final String scheme;
  final String? authority;
  final String? path;
  final String? query;
  final String? fragment;

  const UriComponents({
    required this.scheme,
    this.authority,
    this.path,
    this.query,
    this.fragment,
  });
}

bool isUriComponents(dynamic thing) {
  if (thing == null || thing is! Object) {
    return false;
  }
  if (thing is! UriComponents) {
    return false;
  }
  return true;
}

/// Source: `interface UriState extends UriComponents`.
class UriState implements UriComponents {
  @override
  String scheme = '';
  @override
  String? authority;
  @override
  String? path;
  @override
  String? query;
  @override
  String? fragment;

  final int $mid;
  String? external;
  String? fsPath;
  int? _sep;

  UriState({this.$mid = MarshalledId.Uri});
}

final int? _pathSepMarker = isWindows ? 1 : null;

/// Object-literal parameter of `with(change)` -> value class. The sentinel
/// `_undefined` distinguishes an omitted field (keep current) from `null`
/// (clear the component), matching the TypeScript `undefined`/`null` split.
class UriChange {
  final Object? scheme;
  final Object? authority;
  final Object? path;
  final Object? query;
  final Object? fragment;

  const UriChange({
    this.scheme = _undefined,
    this.authority = _undefined,
    this.path = _undefined,
    this.query = _undefined,
    this.fragment = _undefined,
  });
}

// This class exists so that URI is compatible with vscode.Uri (API).
class Uri extends URI {
  String? _formatted;
  String? _fsPath;

  Uri(dynamic schemeOrData, [String? authority, String? path, String? query, String? fragment, bool strict = false])
      : super(schemeOrData, authority, path, query, fragment, strict);

  @override
  String get fsPath {
    if (_fsPath == null || _fsPath!.isEmpty) {
      _fsPath = uriToFsPath(this, false);
    }
    return _fsPath!;
  }

  @override
  String toString([bool skipEncoding = false]) {
    if (!skipEncoding) {
      if (_formatted == null || _formatted!.isEmpty) {
        _formatted = _asFormatted(this, false);
      }
      return _formatted!;
    } else {
      // we don't cache that
      return _asFormatted(this, true);
    }
  }

  @override
  UriState toJSON() {
    // eslint-disable-next-line local/code-no-dangerous-type-assertions
    final UriState res = UriState();
    // cached state
    if (_fsPath != null && _fsPath!.isNotEmpty) {
      res.fsPath = _fsPath;
      res._sep = _pathSepMarker;
    }
    if (_formatted != null && _formatted!.isNotEmpty) {
      res.external = _formatted;
    }
    //--- uri components
    if (path.isNotEmpty) {
      res.path = path;
    }
    // TODO
    // this isn't correct and can violate the UriComponents contract but
    // this is part of the vscode.Uri API and we shouldn't change how that
    // works anymore
    if (scheme.isNotEmpty) {
      res.scheme = scheme;
    }
    if (authority.isNotEmpty) {
      res.authority = authority;
    }
    if (query.isNotEmpty) {
      res.query = query;
    }
    if (fragment.isNotEmpty) {
      res.fragment = fragment;
    }
    return res;
  }
}

// reserved characters: https://tools.ietf.org/html/rfc3986#section-2.2
const Map<int, String> encodeTable = <int, String>{
  CharCode.Colon: '%3A', // gen-delims
  CharCode.Slash: '%2F',
  CharCode.QuestionMark: '%3F',
  CharCode.Hash: '%23',
  CharCode.OpenSquareBracket: '%5B',
  CharCode.CloseSquareBracket: '%5D',
  CharCode.AtSign: '%40',

  CharCode.ExclamationMark: '%21', // sub-delims
  CharCode.DollarSign: '%24',
  CharCode.Ampersand: '%26',
  CharCode.SingleQuote: '%27',
  CharCode.OpenParen: '%28',
  CharCode.CloseParen: '%29',
  CharCode.Asterisk: '%2A',
  CharCode.Plus: '%2B',
  CharCode.Comma: '%2C',
  CharCode.Semicolon: '%3B',
  CharCode.Equals: '%3D',

  CharCode.Space: '%20',
};

String encodeURIComponentFast(String uriComponent, bool isPath, bool isAuthority) {
  String? res;
  int nativeEncodePos = -1;

  for (int pos = 0; pos < uriComponent.length; pos++) {
    final int code = uriComponent.codeUnitAt(pos);

    // unreserved characters: https://tools.ietf.org/html/rfc3986#section-2.3
    if ((code >= CharCode.a && code <= CharCode.z) ||
        (code >= CharCode.A && code <= CharCode.Z) ||
        (code >= CharCode.Digit0 && code <= CharCode.Digit9) ||
        code == CharCode.Dash ||
        code == CharCode.Period ||
        code == CharCode.Underline ||
        code == CharCode.Tilde ||
        (isPath && code == CharCode.Slash) ||
        (isAuthority && code == CharCode.OpenSquareBracket) ||
        (isAuthority && code == CharCode.CloseSquareBracket) ||
        (isAuthority && code == CharCode.Colon)) {
      // check if we are delaying native encode
      if (nativeEncodePos != -1) {
        res = (res ?? '') + _encodeURIComponent(uriComponent.substring(nativeEncodePos, pos));
        nativeEncodePos = -1;
      }
      // check if we write into a new string (by default we try to return the param)
      if (res != null) {
        res = res + uriComponent.substring(pos, pos + 1);
      }
    } else {
      // encoding needed, we need to allocate a new string
      if (res == null) {
        res = uriComponent.substring(0, pos);
      }

      // check with default table first
      final String? escaped = encodeTable[code];
      if (escaped != null) {
        // check if we are delaying native encode
        if (nativeEncodePos != -1) {
          res = res + _encodeURIComponent(uriComponent.substring(nativeEncodePos, pos));
          nativeEncodePos = -1;
        }

        // append escaped variant to result
        res = res + escaped;
      } else if (nativeEncodePos == -1) {
        // use native encode only when needed
        nativeEncodePos = pos;
      }
    }
  }

  if (nativeEncodePos != -1) {
    res = (res ?? '') + _encodeURIComponent(uriComponent.substring(nativeEncodePos));
  }

  return res ?? uriComponent;
}

String encodeURIComponentMinimal(String path) {
  int pos = path.indexOf('?');
  final int hashPos = path.indexOf('#');
  if (pos == -1 || (hashPos != -1 && hashPos < pos)) {
    pos = hashPos;
  }
  if (pos == -1) {
    return path;
  }

  String res = path.substring(0, pos);
  int copyStart = pos;
  for (; pos < path.length; pos++) {
    final int code = path.codeUnitAt(pos);
    if (code == CharCode.Hash || code == CharCode.QuestionMark) {
      if (copyStart < pos) {
        res += path.substring(copyStart, pos);
      }
      res += encodeTable[code]!;
      copyStart = pos + 1;
    }
  }
  if (copyStart < path.length) {
    res += path.substring(copyStart);
  }
  return res;
}

/// Compute `fsPath` for the given uri
String uriToFsPath(URI uri, bool keepDriveLetterCasing) {
  late String value;
  if (uri.authority.isNotEmpty && uri.path.length > 1 && uri.scheme == 'file') {
    // unc path: file://shares/c$/far/boo
    value = '//${uri.authority}${uri.path}';
  } else if (_charCodeAt(uri.path, 0) == CharCode.Slash &&
      ((_charCodeAt(uri.path, 1) >= CharCode.A && _charCodeAt(uri.path, 1) <= CharCode.Z) ||
          (_charCodeAt(uri.path, 1) >= CharCode.a && _charCodeAt(uri.path, 1) <= CharCode.z)) &&
      _charCodeAt(uri.path, 2) == CharCode.Colon) {
    if (!keepDriveLetterCasing) {
      // windows drive letter: file:///c:/far/boo
      value = uri.path.substring(1, 2).toLowerCase() + uri.path.substring(2);
    } else {
      value = uri.path.substring(1);
    }
  } else {
    // other path
    value = uri.path;
  }
  if (isWindows) {
    value = value.replaceAll('/', '\\');
  }
  return value;
}

/// Create the external version of a uri
String _asFormatted(URI uri, bool skipEncoding) {
  final String Function(String, bool, bool) encoder = skipEncoding
      ? (String s, bool isPath, bool isAuthority) => encodeURIComponentMinimal(s)
      : encodeURIComponentFast;

  String res = '';
  String scheme = uri.scheme;
  String authority = uri.authority;
  String path = uri.path;
  final String query = uri.query;
  final String fragment = uri.fragment;
  if (scheme.isNotEmpty) {
    res += scheme;
    res += ':';
  }
  if (authority.isNotEmpty || scheme == 'file') {
    res += _slash;
    res += _slash;
  }
  if (authority.isNotEmpty) {
    int idx = authority.indexOf('@');
    if (idx != -1) {
      // <user>@<auth>
      final String userinfo = authority.substring(0, idx);
      authority = authority.substring(idx + 1);
      idx = userinfo.indexOf(':');
      if (idx == -1) {
        res += encoder(userinfo, false, false);
      } else {
        // <user>:<pass>@<auth>
        res += encoder(userinfo.substring(0, idx), false, false);
        res += ':';
        res += encoder(userinfo.substring(idx + 1), false, false);
      }
      res += '@';
    }
    authority = authority.toLowerCase();
    idx = authority.lastIndexOf(':');
    if (idx == -1) {
      res += encoder(authority, false, true);
    } else {
      // <auth>:<port>
      res += encoder(authority.substring(0, idx), false, true);
      res += authority.substring(idx);
    }
  }
  if (path.isNotEmpty) {
    // HTTP paths are case-sensitive, even when their first segment resembles a drive letter.
    final String lowerScheme = scheme.toLowerCase();
    if (path.length >= 3 && _charCodeAt(path, 0) == CharCode.Slash && _charCodeAt(path, 2) == CharCode.Colon) {
      final int code = _charCodeAt(path, 1);
      if (code >= CharCode.A && code <= CharCode.Z && lowerScheme != 'http' && lowerScheme != 'https') {
        path = '/${String.fromCharCodes(<int>[code + 32])}:${path.substring(3)}'; // "/c:".length === 3
      }
    } else if (path.length >= 2 && _charCodeAt(path, 1) == CharCode.Colon) {
      final int code = _charCodeAt(path, 0);
      if (code >= CharCode.A && code <= CharCode.Z && lowerScheme != 'http' && lowerScheme != 'https') {
        path = '${String.fromCharCodes(<int>[code + 32])}:${path.substring(2)}'; // "/c:".length === 3
      }
    }
    // encode the rest of the path
    res += encoder(path, true, false);
  }
  if (query.isNotEmpty) {
    res += '?';
    res += encoder(query, false, false);
  }
  if (fragment.isNotEmpty) {
    res += '#';
    res += !skipEncoding ? encodeURIComponentFast(fragment, false, false) : fragment;
  }
  return res;
}

// --- decode

String decodeURIComponentGraceful(String str) {
  try {
    return _decodeURIComponent(str);
  } catch (_) {
    if (str.length > 3) {
      return str.substring(0, 3) + decodeURIComponentGraceful(str.substring(3));
    } else {
      return str;
    }
  }
}

final RegExp _rEncodedAsHex = RegExp(r'(%[0-9A-Za-z][0-9A-Za-z])+');

String percentDecode(String str) {
  if (!_rEncodedAsHex.hasMatch(str)) {
    return str;
  }
  return str.replaceAllMapped(_rEncodedAsHex, (Match match) => decodeURIComponentGraceful(match.group(0)!));
}

/// Mapped-type that replaces all occurrences of URI with UriComponents.
/// Dart has no mapped/conditional types; consumers substitute manually.
typedef UriDto<T> = dynamic;
