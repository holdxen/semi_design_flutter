// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/mime.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. `Object.freeze({...})` -> class + static
// const (call sites keep `Mimes.X` shape); TS `string | string[]` -> `Object`
// with `is String` / `is List<String>` checks; overloads -> optional param.
// ---------------------------------------------------------------------------

import './path.dart';

class Mimes {
  static const String text = 'text/plain';
  static const String binary = 'application/octet-stream';
  static const String unknown = 'application/unknown';
  static const String markdown = 'text/markdown';
  static const String latex = 'text/latex';
  static const String uriList = 'text/uri-list';
  static const String html = 'text/html';
}

/// TS `interface MapExtToMediaMimes { [index: string]: string | string[] }`
typedef MapExtToMediaMimes = Map<String, Object>;

const Map<String, String> mapExtToTextMimes = <String, String>{
  '.css': 'text/css',
  '.csv': 'text/csv',
  '.htm': 'text/html',
  '.html': 'text/html',
  '.ics': 'text/calendar',
  '.js': 'text/javascript',
  '.json': 'application/json',
  '.map': 'application/json',
  '.mjs': 'text/javascript',
  '.txt': 'text/plain',
  '.xml': 'text/xml',
};

// Known media mimes that we can handle
const MapExtToMediaMimes mapExtToMediaMimes = <String, Object>{
  '.aac': 'audio/x-aac',
  '.avi': 'video/x-msvideo',
  '.avif': 'image/avif',
  '.bmp': 'image/bmp',
  '.flv': 'video/x-flv',
  '.gif': 'image/gif',
  '.ico': 'image/x-icon',
  '.jpe': <String>['image/jpg', 'image/jpeg'],
  '.jpeg': <String>['image/jpg', 'image/jpeg'],
  '.jpg': <String>['image/jpg', 'image/jpeg'],
  '.m1v': 'video/mpeg',
  '.m2a': 'audio/mpeg',
  '.m2v': 'video/mpeg',
  '.m3a': 'audio/mpeg',
  '.mid': 'audio/midi',
  '.midi': 'audio/midi',
  '.mk3d': 'video/x-matroska',
  '.mks': 'video/x-matroska',
  '.mkv': 'video/x-matroska',
  '.mov': 'video/quicktime',
  '.movie': 'video/x-sgi-movie',
  '.mp2': 'audio/mpeg',
  '.mp2a': 'audio/mpeg',
  '.mp3': 'audio/mpeg',
  '.mp4': 'video/mp4',
  '.mp4a': 'audio/mp4',
  '.mp4v': 'video/mp4',
  '.mpe': 'video/mpeg',
  '.mpeg': 'video/mpeg',
  '.mpg': 'video/mpeg',
  '.mpg4': 'video/mp4',
  '.mpga': 'audio/mpeg',
  '.oga': 'audio/ogg',
  '.ogg': 'audio/ogg',
  '.opus': 'audio/opus',
  '.ogv': 'video/ogg',
  '.otf': 'font/otf',
  '.pdf': 'application/pdf',
  '.png': 'image/png',
  '.psd': 'image/vnd.adobe.photoshop',
  '.qt': 'video/quicktime',
  '.spx': 'audio/ogg',
  '.svg': 'image/svg+xml',
  '.tga': 'image/x-tga',
  '.tif': 'image/tiff',
  '.tiff': 'image/tiff',
  '.ttf': 'font/ttf',
  '.wasm': 'application/wasm',
  '.wav': 'audio/x-wav',
  '.webm': 'video/webm',
  '.webp': 'image/webp',
  '.wma': 'audio/x-ms-wma',
  '.wmv': 'video/x-ms-wmv',
  '.woff': 'application/font-woff',
  '.woff2': 'font/woff2',
};

String? getMediaOrTextMime(String path) {
  final String ext = extname(path);
  final String? textMime = mapExtToTextMimes[ext.toLowerCase()];
  if (textMime != null) {
    return textMime;
  } else {
    return getMediaMime(path);
  }
}

String? getMediaMime(String path) {
  final String ext = extname(path);
  final Object? mimeType = mapExtToMediaMimes[ext.toLowerCase()];
  return mimeType is List ? mimeType[0] as String : mimeType as String?;
}

String? getExtensionForMimeType(String mimeType) {
  for (final Map<String, Object> mapping in <Map<String, Object>>[mapExtToTextMimes, mapExtToMediaMimes]) {
    for (final String extension in mapping.keys) {
      final Object value = mapping[extension]!;
      if ((value is List ? value.contains(mimeType) : value == mimeType)) {
        return extension;
      }
    }
  }

  return null;
}

final RegExp _simplePattern = RegExp(r'^(.+)/(.+?)(;.+)?$');

String? normalizeMimeType(String mimeType, [bool? strict]) {
  final RegExpMatch? match = _simplePattern.firstMatch(mimeType);
  if (match == null) {
    return strict == true ? null : mimeType;
  }
  // https://datatracker.ietf.org/doc/html/rfc2045#section-5.1
  // media and subtype must ALWAYS be lowercase, parameter not
  return '${match.group(1)!.toLowerCase()}/${match.group(2)!.toLowerCase()}${match.group(3) ?? ''}';
}

/// Whether the provided mime type is a text stream like `stdout`, `stderr`.
bool isTextStreamMime(String mimeType) {
  return const <String>['application/vnd.code.notebook.stdout', 'application/vnd.code.notebook.stderr'].contains(mimeType);
}
