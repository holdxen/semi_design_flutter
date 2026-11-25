// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/services/languagesAssociations.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Carriers:
//   - `ParsedPattern` -> glob.ParsedGlobFn (callable); a plain string pattern
//     resolves synchronously to a bool, matching the source's `?.(target)`.
//   - Module-level mutable arrays -> Dart top-level mutable variables.
// ---------------------------------------------------------------------------

import '../../../base/common/glob.dart' as glob
    show GlobOptions, ParsedGlobFn, parse;
import '../../../base/common/mime.dart' show Mimes;
import '../../../base/common/network.dart' show Schemas;
import '../../../base/common/path.dart' as path show basename, posix;
import '../../../base/common/resources.dart' show DataUri;
import '../../../base/common/strings.dart'
    show endsWithIgnoreCase, equals, startsWithUTF8BOM;
import '../../../base/common/uri.dart' show URI;
import '../languages/modesRegistry.dart' show PLAINTEXT_LANGUAGE_ID;

/// 1:1: `export interface ILanguageAssociation`.
class ILanguageAssociation {
  ILanguageAssociation({
    required this.id,
    required this.mime,
    this.filename,
    this.extension,
    this.filepattern,
    this.firstline,
  });

  final String id;
  final String mime;
  final String? filename;
  final String? extension;
  final String? filepattern;
  final RegExp? firstline;
}

/// 1:1: `interface ILanguageAssociationItem` (internal).
class ILanguageAssociationItem {
  ILanguageAssociationItem({
    required this.id,
    required this.mime,
    this.filename,
    this.extension,
    this.filepattern,
    this.firstline,
    required this.userConfigured,
    this.filepatternParsed,
    required this.filepatternOnPath,
  });

  final String id;
  final String mime;
  final String? filename;
  final String? extension;
  final String? filepattern;
  final RegExp? firstline;
  final bool userConfigured;
  final glob.ParsedGlobFn? filepatternParsed;
  final bool filepatternOnPath;
}

/// Module-level registries (mutable, 1:1 with the TS `let` arrays).
List<ILanguageAssociationItem> registeredAssociations =
    <ILanguageAssociationItem>[];
List<ILanguageAssociationItem> nonUserRegisteredAssociations =
    <ILanguageAssociationItem>[];
List<ILanguageAssociationItem> userRegisteredAssociations =
    <ILanguageAssociationItem>[];

/// 1:1: `registerPlatformLanguageAssociation`.
void registerPlatformLanguageAssociation(
  ILanguageAssociation association, [
  bool warnOnOverwrite = false,
]) =>
    _registerLanguageAssociation(association, false, warnOnOverwrite);

/// 1:1: `registerConfiguredLanguageAssociation`.
void registerConfiguredLanguageAssociation(ILanguageAssociation association) =>
    _registerLanguageAssociation(association, true, false);

void _registerLanguageAssociation(
  ILanguageAssociation association,
  bool userConfigured,
  bool warnOnOverwrite,
) {
  final ILanguageAssociationItem associationItem =
      _toLanguageAssociationItem(association, userConfigured);
  registeredAssociations.add(associationItem);
  if (!associationItem.userConfigured) {
    nonUserRegisteredAssociations.add(associationItem);
  } else {
    userRegisteredAssociations.add(associationItem);
  }

  // Check for conflicts unless this is a user configured association
  if (warnOnOverwrite && !associationItem.userConfigured) {
    for (final ILanguageAssociationItem a in registeredAssociations) {
      if (a.mime == associationItem.mime || a.userConfigured) {
        continue; // same mime or userConfigured is ok
      }
      if (associationItem.extension != null &&
          a.extension == associationItem.extension) {
        // console.warn Overwriting extension
      }
      if (associationItem.filename != null &&
          a.filename == associationItem.filename) {
        // console.warn Overwriting filename
      }
      if (associationItem.filepattern != null &&
          a.filepattern == associationItem.filepattern) {
        // console.warn Overwriting filepattern
      }
      if (associationItem.firstline != null &&
          a.firstline == associationItem.firstline) {
        // console.warn Overwriting firstline
      }
    }
  }
}

ILanguageAssociationItem _toLanguageAssociationItem(
  ILanguageAssociation association,
  bool userConfigured,
) {
  return ILanguageAssociationItem(
    id: association.id,
    mime: association.mime,
    filename: association.filename,
    extension: association.extension,
    filepattern: association.filepattern,
    firstline: association.firstline,
    userConfigured: userConfigured,
    filepatternParsed: association.filepattern != null
        ? glob.parse(association.filepattern,
            glob.GlobOptions(ignoreCase: true))
        : null,
    filepatternOnPath: association.filepattern != null
        ? association.filepattern!.contains(path.posix.sep)
        : false,
  );
}

/// 1:1: `clearPlatformLanguageAssociations`.
void clearPlatformLanguageAssociations() {
  registeredAssociations =
      registeredAssociations.where((a) => a.userConfigured).toList();
  nonUserRegisteredAssociations = <ILanguageAssociationItem>[];
}

/// 1:1: `clearConfiguredLanguageAssociations`.
void clearConfiguredLanguageAssociations() {
  registeredAssociations =
      registeredAssociations.where((a) => !a.userConfigured).toList();
  userRegisteredAssociations = <ILanguageAssociationItem>[];
}

/// internal `{ id, mime }`.
class IdAndMime {
  IdAndMime(this.id, this.mime);
  final String id;
  final String mime;

  Map<String, Object?> toJson() => <String, Object?>{'id': id, 'mime': mime};
}

/// 1:1: `getMimeTypes`.
List<String> getMimeTypes(URI? resource, [String? firstLine]) =>
    _getAssociations(resource, firstLine).map((i) => i.mime).toList();

/// 1:1: `getLanguageIds`.
List<String> getLanguageIds(URI? resource, [String? firstLine]) =>
    _getAssociations(resource, firstLine).map((i) => i.id).toList();

/// 1:1: `getAssociations`.
List<IdAndMime> _getAssociations(URI? resource, [String? firstLine]) {
  String? pathValue;
  if (resource != null) {
    switch (resource.scheme) {
      case Schemas.file:
        pathValue = resource.fsPath;
        break;
      case Schemas.data: {
        final Map<String, String> metadata =
            DataUri.parseMetaData(resource);
        pathValue = metadata[DataUri.META_DATA_LABEL];
        break;
      }
      case Schemas.vscodeNotebookCell:
        pathValue = null;
        break;
      default:
        pathValue = resource.path;
    }
  }

  if (pathValue == null) {
    return <IdAndMime>[IdAndMime('unknown', Mimes.unknown)];
  }

  pathValue = pathValue.toLowerCase();
  final String filename = path.basename(pathValue);

  // 1.) User configured mappings have highest priority
  final ILanguageAssociationItem? configuredLanguage = _getAssociationByPath(
      pathValue, filename, userRegisteredAssociations);
  if (configuredLanguage != null) {
    return <IdAndMime>[
      IdAndMime(configuredLanguage.id, configuredLanguage.mime),
      IdAndMime(PLAINTEXT_LANGUAGE_ID, Mimes.text),
    ];
  }

  // 2.) Registered mappings have middle priority
  final ILanguageAssociationItem? registeredLanguage = _getAssociationByPath(
      pathValue, filename, nonUserRegisteredAssociations);
  if (registeredLanguage != null) {
    return <IdAndMime>[
      IdAndMime(registeredLanguage.id, registeredLanguage.mime),
      IdAndMime(PLAINTEXT_LANGUAGE_ID, Mimes.text),
    ];
  }

  // 3.) Firstline has lowest priority
  if (firstLine != null) {
    final ILanguageAssociationItem? firstlineLanguage =
        _getAssociationByFirstline(firstLine);
    if (firstlineLanguage != null) {
      return <IdAndMime>[
        IdAndMime(firstlineLanguage.id, firstlineLanguage.mime),
        IdAndMime(PLAINTEXT_LANGUAGE_ID, Mimes.text),
      ];
    }
  }

  return <IdAndMime>[IdAndMime('unknown', Mimes.unknown)];
}

/// 1:1: `getAssociationByPath`.
ILanguageAssociationItem? _getAssociationByPath(
  String pathValue,
  String filename,
  List<ILanguageAssociationItem> associations,
) {
  ILanguageAssociationItem? filenameMatch;
  ILanguageAssociationItem? patternMatch;
  ILanguageAssociationItem? extensionMatch;

  for (int i = associations.length - 1; i >= 0; i--) {
    final ILanguageAssociationItem association = associations[i];

    // First exact name match
    if (equals(filename, association.filename, true)) {
      filenameMatch = association;
      break; // take it!
    }

    // Longest pattern match
    if (association.filepattern != null) {
      if (patternMatch == null ||
          association.filepattern!.length > patternMatch.filepattern!.length) {
        final String target = association.filepatternOnPath
            ? pathValue
            : filename; // match on full path if pattern contains path separator
        final Object? patternResult =
            association.filepatternParsed?.call(target);
        if (patternResult == true) {
          patternMatch = association;
        }
      }
    }

    // Longest extension match
    if (association.extension != null) {
      if (extensionMatch == null ||
          association.extension!.length > extensionMatch.extension!.length) {
        if (endsWithIgnoreCase(filename, association.extension!)) {
          extensionMatch = association;
        }
      }
    }
  }

  // 1.) Exact name match has second highest priority
  if (filenameMatch != null) return filenameMatch;
  // 2.) Match on pattern
  if (patternMatch != null) return patternMatch;
  // 3.) Match on extension comes next
  if (extensionMatch != null) return extensionMatch;
  return null;
}

/// 1:1: `getAssociationByFirstline`.
ILanguageAssociationItem? _getAssociationByFirstline(String firstLine) {
  if (startsWithUTF8BOM(firstLine)) {
    firstLine = firstLine.substring(1);
  }

  if (firstLine.isNotEmpty) {
    for (int i = registeredAssociations.length - 1; i >= 0; i--) {
      final ILanguageAssociationItem association = registeredAssociations[i];
      if (association.firstline == null) continue;
      final RegExpMatch? matches = association.firstline!.firstMatch(firstLine);
      if (matches != null) {
        return association;
      }
    }
  }
  return null;
}
