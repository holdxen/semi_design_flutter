// 1:1 port of vs/editor/common/languages/language.ts
// Declaration-only module: 1 decorator + 5 interfaces.
// Adaptations: const keeps the bare name, interfaces use `Type` suffix where
// needed; `ILanguageIdCodec` is reused from the already-ported lineTokens.dart.
// Runtime truth: tool/ts2dart/_batch271_truth.cjs (recursive TS transpile+vm).

import '../../../base/common/event.dart' show Event;
import '../../../base/common/lifecycle.dart' show IDisposable;
import '../../../base/common/uri.dart' show URI;
import '../../../platform/instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import '../tokens/lineTokens.dart' show ILanguageIdCodec;

/// 1:1: `export const ILanguageService = createDecorator<...>('languageService')`
final ServiceIdentifier<ILanguageServiceType> ILanguageService =
    createDecorator<ILanguageServiceType>('languageService');

/// 1:1: `ILanguageExtensionPoint`
class ILanguageExtensionPoint {
  String id;
  List<String>? extensions;
  List<String>? filenames;
  List<String>? filenamePatterns;
  String? firstLine;
  List<String>? aliases;
  List<String>? mimetypes;
  URI? configuration;
  ILanguageIcon? icon;

  ILanguageExtensionPoint({
    required this.id,
    this.extensions,
    this.filenames,
    this.filenamePatterns,
    this.firstLine,
    this.aliases,
    this.mimetypes,
    this.configuration,
    this.icon,
  });
}

/// 1:1: `ILanguageSelection`
abstract class ILanguageSelection {
  String get languageId;
  Event<String> get onDidChange;
}

/// 1:1: `ILanguageNameIdPair`
class ILanguageNameIdPair {
  final String languageName;
  final String languageId;

  const ILanguageNameIdPair(this.languageName, this.languageId);
}

/// 1:1: `ILanguageIcon`
class ILanguageIcon {
  final URI light;
  final URI dark;

  const ILanguageIcon(this.light, this.dark);
}

/// 1:1: `ILanguageService` (const keeps bare name)
abstract class ILanguageServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  ILanguageIdCodec get languageIdCodec;

  Event<String> get onDidRequestBasicLanguageFeatures;
  Event<String> get onDidRequestRichLanguageFeatures;
  Event<void> get onDidChange;

  IDisposable registerLanguage(ILanguageExtensionPoint def);
  bool isRegisteredLanguageId(String languageId);
  List<String> getRegisteredLanguageIds();
  List<ILanguageNameIdPair> getSortedRegisteredLanguageNames();
  String? getLanguageName(String languageId);
  String? getMimeType(String languageId);
  ILanguageIcon? getIcon(String languageId);
  List<String> getExtensions(String languageId);
  List<String> getFilenames(String languageId);
  List<URI> getConfigurationFiles(String languageId);
  String? getLanguageIdByLanguageName(String languageName);
  String? getLanguageIdByMimeType(String? mimeType);
  String? guessLanguageIdByFilepathOrFirstLine(URI resource, [String? firstLine]);
  ILanguageSelection createById(String? languageId);
  ILanguageSelection createByMimeType(String? mimeType);
  ILanguageSelection createByFilepathOrFirstLine(URI? resource,
      [String? firstLine]);
  void requestBasicLanguageFeatures(String languageId);
  void requestRichLanguageFeatures(String languageId);
}
