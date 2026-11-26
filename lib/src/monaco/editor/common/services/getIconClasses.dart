// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/services/getIconClasses.ts
// Translated 1:1. Structure, members and semantics preserved.
// Verified against the TypeScript transpile truth (batch424).
// ---------------------------------------------------------------------------

import '../../../base/common/network.dart' show Schemas;
import '../../../base/common/resources.dart' show DataUri;
import '../../../base/common/themables.dart' show ThemeIcon;
import '../../../base/common/uri.dart' show URI;
import '../../../platform/files/common/files.dart' show FileKind;
import '../languages/modesRegistry.dart' show PLAINTEXT_LANGUAGE_ID;

/// 1:1: `fileIconDirectoryRegex`.
final RegExp _fileIconDirectoryRegex = RegExp(r'(?:/|^)(?:([^/]+)/)?([^/]+)$');

/// 1:1: `getIconClasses`.
List<String> getIconClasses(
  Object modelService,
  Object languageService,
  URI? resource, [
  int? fileKind,
  Object? icon,
]) {
  if (ThemeIcon.isThemeIcon(icon)) {
    // `ThemeIcon.isThemeIcon` accepts both ThemeIcon and Map carriers; read
    // the id the same way (its internal `_idOf` helper).
    final Object? id = icon is Map ? icon['id'] : (icon as dynamic).id;
    return <String>['codicon-$id', 'predefined-file-icon'];
  }

  if (URI.isUri(icon)) {
    return <String>[];
  }

  // We always set these base classes even if we do not have a path.
  List<String> classes = fileKind == FileKind.ROOT_FOLDER
      ? <String>['rootfolder-icon']
      : fileKind == FileKind.FOLDER
          ? <String>['folder-icon']
          : <String>['file-icon'];

  if (resource != null) {
    // Get the path and name of the resource. For data-URIs, parse specially.
    String? name;
    if (resource.scheme == Schemas.data) {
      final Map<String, String> metadata = DataUri.parseMetaData(resource);
      name = metadata[DataUri.META_DATA_LABEL];
    } else {
      final RegExpMatch? match =
          _fileIconDirectoryRegex.firstMatch(resource.path);
      if (match != null) {
        name = fileIconSelectorEscape(match.group(2)!.toLowerCase());
        final String? parent = match.group(1);
        if (parent != null) {
          classes.add('${fileIconSelectorEscape(parent.toLowerCase())}-name-dir-icon');
        }
      } else {
        name = fileIconSelectorEscape(resource.authority.toLowerCase());
      }
    }

    // Root folders
    if (fileKind == FileKind.ROOT_FOLDER) {
      classes.add('$name-root-name-folder-icon');
    }
    // Folders
    else if (fileKind == FileKind.FOLDER) {
      classes.add('$name-name-folder-icon');
    }
    // Files
    else {
      // Name & Extension(s)
      if (name != null) {
        classes.add('$name-name-file-icon');
        classes.add('name-file-icon'); // extra segment to increase file-name score
        // Avoid an explosive combination of extensions for very long filenames.
        if (name.length <= 255) {
          final List<String> dotSegments = name.split('.');
          for (int i = 1; i < dotSegments.length; i++) {
            classes.add('${dotSegments.sublist(i).join('.')}-ext-file-icon');
          }
        }
        classes.add('ext-file-icon'); // extra segment to increase file-ext score
      }

      // Detected Mode
      final String? detectedLanguageId =
          _detectLanguageId(modelService, languageService, resource);
      if (detectedLanguageId != null) {
        classes.add('${fileIconSelectorEscape(detectedLanguageId)}-lang-file-icon');
      }
    }
  }
  return classes;
}

/// 1:1: `getIconClassesForLanguageId`.
List<String> getIconClassesForLanguageId(String languageId) =>
    <String>['file-icon', '${fileIconSelectorEscape(languageId)}-lang-file-icon'];

/// 1:1: `detectLanguageId`.
String? _detectLanguageId(
  Object modelService,
  Object languageService,
  URI resource,
) {
  // We need a resource at least.
  String? languageId;

  // Data URI: check for encoded metadata.
  if (resource.scheme == Schemas.data) {
    final Map<String, String> metadata = DataUri.parseMetaData(resource);
    final String? mime = metadata[DataUri.META_DATA_MIME];
    if (mime != null) {
      languageId = (languageService as dynamic).getLanguageIdByMimeType(mime) as String?;
    }
  }
  // Any other URI: check for model if existing.
  else {
    final Object? model = (modelService as dynamic).getModel(resource) as Object?;
    if (model != null) {
      languageId = (model as dynamic).getLanguageId() as String?;
    }
  }

  // Only take if the language id is specific (not just plain text).
  if (languageId != null && languageId != PLAINTEXT_LANGUAGE_ID) {
    return languageId;
  }

  // Otherwise fallback to path based detection.
  return (languageService as dynamic)
      .guessLanguageIdByFilepathOrFirstLine(resource) as String?;
}

/// 1:1: `fileIconSelectorEscape` — HTML class names can't contain whitespace.
String fileIconSelectorEscape(String str) =>
    str.replaceAll(RegExp(r'[\s]'), '/');
