// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/services/languagesRegistry.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Carriers:
//   - `IResolvedLanguage` is an internal interface -> concrete carrier.
//   - `ILanguageExtensionPoint` / `ILanguageNameIdPair` / `ILanguageIcon` are
//     reused from languages/language.dart.
//   - `Object` maps `{ [id: string]: T }` -> Dart Map<String, T>.
// ---------------------------------------------------------------------------

import '../../../base/common/event.dart' show Emitter, Event;
import '../../../base/common/lifecycle.dart' show Disposable, IDisposable;
import '../../../base/common/strings.dart'
    show compareIgnoreCase, regExpLeadsToEndlessLoop;
import '../../../base/common/uri.dart' show URI;
import '../../../platform/configuration/common/configurationRegistry.dart'
    as config
    show Extensions, IConfigurationRegistry;
import '../../../platform/registry/common/platform.dart' show Registry;
import '../encodedTokenAttributes.dart' show LanguageId;
import '../languages/language.dart'
    show ILanguageExtensionPoint, ILanguageIcon, ILanguageNameIdPair;
import '../languages/modesRegistry.dart'
    show ModesRegistry, PLAINTEXT_LANGUAGE_ID;
import 'languagesAssociations.dart'
    show
        ILanguageAssociation,
        clearPlatformLanguageAssociations,
        getLanguageIds,
        registerPlatformLanguageAssociation;

const String NULL_LANGUAGE_ID = 'vs.editor.nullLanguage';

/// 1:1: `interface IResolvedLanguage` (internal).
class IResolvedLanguage {
  IResolvedLanguage(this.identifier)
      : name = null,
        mimetypes = <String>[],
        aliases = <String>[],
        extensions = <String>[],
        filenames = <String>[],
        configurationFiles = <URI>[],
        icons = <ILanguageIcon>[];

  String identifier;
  String? name;
  List<String> mimetypes;
  List<String> aliases;
  List<String> extensions;
  List<String> filenames;
  List<URI> configurationFiles;
  List<ILanguageIcon> icons;
}

/// 1:1: `export class LanguageIdCodec implements ILanguageIdCodec`.
class LanguageIdCodec {
  LanguageIdCodec() {
    _register(NULL_LANGUAGE_ID, LanguageId.nullId);
    _register(PLAINTEXT_LANGUAGE_ID, LanguageId.plainText);
    _nextLanguageId = 2;
  }

  late int _nextLanguageId;
  final List<String> _languageIdToLanguage = <String>[];
  final Map<String, int> _languageToLanguageId = <String, int>{};

  void _register(String language, int languageId) {
    while (_languageIdToLanguage.length <= languageId) {
      _languageIdToLanguage.add('');
    }
    _languageIdToLanguage[languageId] = language;
    _languageToLanguageId[language] = languageId;
  }

  /// 1:1: `public register(language)`.
  void register(String language) {
    if (_languageToLanguageId.containsKey(language)) return;
    final int languageId = _nextLanguageId++;
    _register(language, languageId);
  }

  /// 1:1: `public encodeLanguageId(languageId)`.
  int encodeLanguageId(String languageId) =>
      _languageToLanguageId[languageId] ?? LanguageId.nullId;

  /// 1:1: `public decodeLanguageId(languageId)`.
  String decodeLanguageId(int languageId) => _languageIdToLanguage.length > languageId
      ? (_languageIdToLanguage[languageId].isNotEmpty
          ? _languageIdToLanguage[languageId]
          : NULL_LANGUAGE_ID)
      : NULL_LANGUAGE_ID;
}

/// 1:1: `export class LanguagesRegistry extends Disposable`.
class LanguagesRegistry extends Disposable {
  static int instanceCount = 0;

  final Emitter<void> _onDidChange = Emitter<void>();
  late final Event<void> onDidChange;

  late final bool _warnOnOverwrite;
  late final LanguageIdCodec languageIdCodec;
  late List<ILanguageExtensionPoint> _dynamicLanguages;
  late Map<String, IResolvedLanguage> _languages;
  late Map<String, String> _mimeTypesMap;
  late Map<String, String> _nameMap;
  late Map<String, String> _lowercaseNameMap;

  LanguagesRegistry([bool useModesRegistry = true, bool warnOnOverwrite = false]) {
    LanguagesRegistry.instanceCount++;
    _warnOnOverwrite = warnOnOverwrite;
    languageIdCodec = LanguageIdCodec();
    _dynamicLanguages = <ILanguageExtensionPoint>[];
    _languages = <String, IResolvedLanguage>{};
    _mimeTypesMap = <String, String>{};
    _nameMap = <String, String>{};
    _lowercaseNameMap = <String, String>{};
    onDidChange = _onDidChange.event;
    register(_onDidChange);

    if (useModesRegistry) {
      _initializeFromRegistry();
      register(ModesRegistry.onDidChangeLanguages((m) {
        _initializeFromRegistry();
      }));
    }
  }

  @override
  void dispose() {
    LanguagesRegistry.instanceCount--;
    super.dispose();
  }

  /// 1:1: `setDynamicLanguages(def)`.
  void setDynamicLanguages(List<ILanguageExtensionPoint> def) {
    _dynamicLanguages = def;
    _initializeFromRegistry();
  }

  void _initializeFromRegistry() {
    _languages = <String, IResolvedLanguage>{};
    _mimeTypesMap = <String, String>{};
    _nameMap = <String, String>{};
    _lowercaseNameMap = <String, String>{};

    clearPlatformLanguageAssociations();
    final List<ILanguageExtensionPoint> desc = <ILanguageExtensionPoint>[
      ...ModesRegistry.getLanguages(),
      ..._dynamicLanguages,
    ];
    _registerLanguages(desc);
  }

  /// 1:1: `registerLanguage(desc)`.
  IDisposable registerLanguage(ILanguageExtensionPoint desc) =>
      ModesRegistry.registerLanguage(desc);

  /// 1:1: `_registerLanguages(desc)`.
  void _registerLanguages(List<ILanguageExtensionPoint> desc) {
    for (final ILanguageExtensionPoint d in desc) {
      _registerLanguage(d);
    }

    // Rebuild fast path maps
    _mimeTypesMap = <String, String>{};
    _nameMap = <String, String>{};
    _lowercaseNameMap = <String, String>{};
    for (final String langId in _languages.keys) {
      final IResolvedLanguage language = _languages[langId]!;
      if (language.name != null) {
        _nameMap[language.name!] = language.identifier;
      }
      for (final String alias in language.aliases) {
        _lowercaseNameMap[alias.toLowerCase()] = language.identifier;
      }
      for (final String mimetype in language.mimetypes) {
        _mimeTypesMap[mimetype] = language.identifier;
      }
    }

    (Registry.as(config.Extensions.Configuration) as config.IConfigurationRegistry)
        .registerOverrideIdentifiers(getRegisteredLanguageIds());

    _onDidChange.fire(null);
  }

  void _registerLanguage(ILanguageExtensionPoint lang) {
    final String langId = lang.id;
    IResolvedLanguage resolvedLanguage;
    if (_languages.containsKey(langId)) {
      resolvedLanguage = _languages[langId]!;
    } else {
      languageIdCodec.register(langId);
      resolvedLanguage = IResolvedLanguage(langId);
      _languages[langId] = resolvedLanguage;
    }
    _mergeLanguage(resolvedLanguage, lang);
  }

  void _mergeLanguage(IResolvedLanguage resolvedLanguage, ILanguageExtensionPoint lang) {
    final String langId = lang.id;
    String? primaryMime;

    if (lang.mimetypes != null && lang.mimetypes!.isNotEmpty) {
      resolvedLanguage.mimetypes.addAll(lang.mimetypes!);
      primaryMime = lang.mimetypes![0];
    }
    primaryMime ??= 'text/x-$langId';
    if (lang.mimetypes == null || lang.mimetypes!.isEmpty) {
      resolvedLanguage.mimetypes.add(primaryMime);
    }

    if (lang.extensions != null) {
      if (lang.configuration != null) {
        resolvedLanguage.extensions =
            <String>[...lang.extensions!, ...resolvedLanguage.extensions];
      } else {
        resolvedLanguage.extensions =
            <String>[...resolvedLanguage.extensions, ...lang.extensions!];
      }
      for (final String extension in lang.extensions!) {
        registerPlatformLanguageAssociation(
          ILanguageAssociation(id: langId, mime: primaryMime, extension: extension),
          _warnOnOverwrite,
        );
      }
    }

    if (lang.filenames != null) {
      for (final String filename in lang.filenames!) {
        registerPlatformLanguageAssociation(
          ILanguageAssociation(id: langId, mime: primaryMime, filename: filename),
          _warnOnOverwrite,
        );
        resolvedLanguage.filenames.add(filename);
      }
    }

    if (lang.filenamePatterns != null) {
      for (final String filenamePattern in lang.filenamePatterns!) {
        registerPlatformLanguageAssociation(
          ILanguageAssociation(id: langId, mime: primaryMime, filepattern: filenamePattern),
          _warnOnOverwrite,
        );
      }
    }

    if (lang.firstLine != null && lang.firstLine!.isNotEmpty) {
      String firstLineRegexStr = lang.firstLine!;
      if (firstLineRegexStr.isEmpty || firstLineRegexStr[0] != '^') {
        firstLineRegexStr = '^$firstLineRegexStr';
      }
      try {
        final RegExp firstLineRegex = RegExp(firstLineRegexStr);
        if (!regExpLeadsToEndlessLoop(firstLineRegex)) {
          registerPlatformLanguageAssociation(
            ILanguageAssociation(id: langId, mime: primaryMime, firstline: firstLineRegex),
            _warnOnOverwrite,
          );
        }
      } catch (_) {
        // Most likely, the regex was bad
      }
    }

    resolvedLanguage.aliases.add(langId);

    List<String?>? langAliases;
    if (lang.aliases != null) {
      langAliases = lang.aliases!.isEmpty
          ? <String?>[null]
          : List<String?>.from(lang.aliases!);
    }

    if (langAliases != null) {
      for (final String? langAlias in langAliases) {
        if (langAlias == null || langAlias.isEmpty) continue;
        resolvedLanguage.aliases.add(langAlias);
      }
    }

    final List<String?>? aliases = langAliases;
    final bool containsAliases = aliases != null && aliases.isNotEmpty;
    final String? firstAlias = aliases != null && aliases.isNotEmpty
        ? aliases[0]
        : null;
    if (firstAlias != null || !containsAliases) {
      final String bestName =
          (firstAlias != null && firstAlias.isNotEmpty) ? firstAlias : langId;
      if (containsAliases || resolvedLanguage.name == null) {
        resolvedLanguage.name = bestName;
      }
    }

    if (lang.configuration != null) {
      resolvedLanguage.configurationFiles.add(lang.configuration!);
    }
    if (lang.icon != null) {
      resolvedLanguage.icons.add(lang.icon!);
    }
  }

  /// 1:1: `isRegisteredLanguageId(languageId)`.
  bool isRegisteredLanguageId(String? languageId) {
    if (languageId == null || languageId.isEmpty) return false;
    return _languages.containsKey(languageId);
  }

  /// 1:1: `getRegisteredLanguageIds()`.
  List<String> getRegisteredLanguageIds() => _languages.keys.toList();

  /// 1:1: `getSortedRegisteredLanguageNames()`.
  List<ILanguageNameIdPair> getSortedRegisteredLanguageNames() {
    final List<ILanguageNameIdPair> result = <ILanguageNameIdPair>[];
    for (final String languageName in _nameMap.keys) {
      result.add(ILanguageNameIdPair(_nameMap[languageName]!, languageName));
    }
    result.sort((a, b) => compareIgnoreCase(a.languageName, b.languageName));
    return result;
  }

  /// 1:1: `getLanguageName(languageId)`.
  String? getLanguageName(String languageId) =>
      _languages.containsKey(languageId) ? _languages[languageId]!.name : null;

  /// 1:1: `getMimeType(languageId)`.
  String? getMimeType(String languageId) {
    if (!_languages.containsKey(languageId)) return null;
    final IResolvedLanguage language = _languages[languageId]!;
    return language.mimetypes.isNotEmpty ? language.mimetypes[0] : null;
  }

  /// 1:1: `getExtensions(languageId)`.
  List<String> getExtensions(String languageId) =>
      _languages.containsKey(languageId) ? _languages[languageId]!.extensions : <String>[];

  /// 1:1: `getFilenames(languageId)`.
  List<String> getFilenames(String languageId) =>
      _languages.containsKey(languageId) ? _languages[languageId]!.filenames : <String>[];

  /// 1:1: `getIcon(languageId)`.
  ILanguageIcon? getIcon(String languageId) {
    if (!_languages.containsKey(languageId)) return null;
    final IResolvedLanguage language = _languages[languageId]!;
    return language.icons.isNotEmpty ? language.icons[0] : null;
  }

  /// 1:1: `getConfigurationFiles(languageId)`.
  List<URI> getConfigurationFiles(String languageId) =>
      _languages.containsKey(languageId)
          ? _languages[languageId]!.configurationFiles
          : <URI>[];

  /// 1:1: `getLanguageIdByLanguageName(languageName)`.
  String? getLanguageIdByLanguageName(String languageName) =>
      _lowercaseNameMap[languageName.toLowerCase()];

  /// 1:1: `getLanguageIdByMimeType(mimeType)`.
  String? getLanguageIdByMimeType(String? mimeType) {
    if (mimeType == null || mimeType.isEmpty) return null;
    return _mimeTypesMap[mimeType];
  }

  /// 1:1: `guessLanguageIdByFilepathOrFirstLine(resource, firstLine?)`.
  List<String> guessLanguageIdByFilepathOrFirstLine(
    URI? resource, [
    String? firstLine,
  ]) {
    if (resource == null && firstLine == null) return <String>[];
    return getLanguageIds(resource, firstLine);
  }
}
