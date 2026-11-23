// ---------------------------------------------------------------------------
// Port of vscode/src/vs/nls.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. JS globals `globalThis._VSCODE_NLS_MESSAGES`
// / `_VSCODE_NLS_LANGUAGE` -> top-level Dart variables with setters. The
// browser `document.location.hash` check for pseudo-localization has no Flutter
// counterpart and is folded to the language check only. Source path `vs/nls.ts`
// mirrors to `monaco/nls.dart` (sibling of `base/`).
// ---------------------------------------------------------------------------

List<String>? _messages;
String? _language;

void setNlsMessages(List<String>? value) => _messages = value;
void setNlsLanguage(String? value) => _language = value;

List<String>? getNLSMessages() => _messages;
String? getNLSLanguage() => _language;

final bool isPseudo = getNLSLanguage() == 'pseudo';

/// Describes the id and comments associated with a localized string.
class ILocalizeInfo {
  final String key;
  final List<String> comment;
  ILocalizeInfo(this.key, this.comment);
}

/// A localized string plus its original form.
class ILocalizedString {
  final String original;
  final String value;
  ILocalizedString({required this.original, required this.value});
}

String _format(String message, List<Object?> args) {
  String result;

  if (args.isEmpty) {
    result = message;
  } else {
    result = message.replaceAllMapped(RegExp(r'\{(\d+)\}'), (match) {
      final int index = int.parse(match.group(1)!);
      final Object? arg = index < args.length ? args[index] : null;
      String result = match.group(0)!;
      if (arg is String) {
        result = arg;
      } else if (arg is num || arg is bool || arg == null) {
        result = arg.toString();
      }
      return result;
    });
  }

  if (isPseudo) {
    // FF3B and FF3D is the Unicode zenkaku representation for [ and ]
    result = '\uFF3B' + result.replaceAllMapped(RegExp(r'[aouei]'), (m) => '${m.group(0)}${m.group(0)}') + '\uFF3D';
  }

  return result;
}

/// Marks a string to be localized. Returns the localized string.
String localize(Object data, String message, [List<Object?> args = const []]) {
  if (data is int) {
    return _format(lookupMessage(data, message), args);
  }
  return _format(message, args);
}

/// Looks up the message in the global NLS table.
String lookupMessage(int index, String? fallback) {
  final String? message = (_messages != null && index < _messages!.length) ? _messages![index] : null;
  if (message == null) {
    if (fallback != null) {
      return fallback;
    }
    throw StateError('!!! NLS MISSING: $index !!!');
  }
  return message;
}

/// Marks a string to be localized. Returns an [ILocalizedString] containing
/// both the localized string and the original string.
ILocalizedString localize2(Object data, String originalMessage, [List<Object?> args = const []]) {
  String message;
  if (data is int) {
    message = lookupMessage(data, originalMessage);
  } else {
    message = originalMessage;
  }

  final String value = _format(message, args);

  return ILocalizedString(
    value: value,
    original: originalMessage == message ? value : _format(originalMessage, args),
  );
}

class INLSLanguagePackConfiguration {
  final String translationsConfigFile;
  final String messagesFile;
  final String corruptMarkerFile;
  INLSLanguagePackConfiguration({
    required this.translationsConfigFile,
    required this.messagesFile,
    required this.corruptMarkerFile,
  });
}

class INLSConfiguration {
  final String userLocale;
  final String osLocale;
  final String? regionalLocale;
  final String resolvedLanguage;
  final INLSLanguagePackConfiguration? languagePack;
  final String defaultMessagesFile;
  final String locale;
  final Map<String, String> availableLanguages;
  final bool? languagePackSupport;
  final String? languagePackId;
  final String? translationsConfigFile;
  final String? cacheRoot;
  final String? resolvedLanguagePackCoreLocation;
  final String? corruptedFile;

  INLSConfiguration({
    required this.userLocale,
    required this.osLocale,
    this.regionalLocale,
    required this.resolvedLanguage,
    this.languagePack,
    required this.defaultMessagesFile,
    required this.locale,
    required this.availableLanguages,
    this.languagePackSupport,
    this.languagePackId,
    this.translationsConfigFile,
    this.cacheRoot,
    this.resolvedLanguagePackCoreLocation,
    this.corruptedFile,
  });
}

class ILanguagePackExtension {
  final ILanguagePackExtensionIdentifier extensionIdentifier;
  final String version;
  ILanguagePackExtension({required this.extensionIdentifier, required this.version});
}

class ILanguagePackExtensionIdentifier {
  final String id;
  final String? uuid;
  ILanguagePackExtensionIdentifier({required this.id, this.uuid});
}

class ILanguagePack {
  final String hash;
  final String? label;
  final List<ILanguagePackExtension> extensions;
  final Map<String, String?> translations;
  ILanguagePack({
    required this.hash,
    required this.label,
    required this.extensions,
    required this.translations,
  });
}

// TS type alias ILanguagePacks = Record<string, ILanguagePack | undefined>
// -> Map<String, ILanguagePack?> (no runtime body).
