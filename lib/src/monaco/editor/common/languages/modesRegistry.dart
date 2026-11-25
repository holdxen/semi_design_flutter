// 1:1 port of vs/editor/common/languages/modesRegistry.ts
// Module-level side effects are folded into the lazy-initialized ModesRegistry
// (Dart has no top-level statements): Registry.add, plaintext registration,
// and default configuration registration.
// Runtime truth: tool/ts2dart/_batch273_truth.cjs (recursive TS transpile+vm).

import '../../../base/common/event.dart' show Emitter, Event;
import '../../../base/common/lifecycle.dart' show Disposable, IDisposable, toDisposable;
import '../../../base/common/mime.dart' show Mimes;
import '../../../nls.dart' show localize;
import '../../../platform/configuration/common/configurationRegistry.dart'
    as config
    show
        Extensions,
        IConfigurationDefaults,
        IConfigurationRegistry,
        configurationRegistry;
import '../../../platform/registry/common/platform.dart' show Registry;
import 'language.dart' show ILanguageExtensionPoint;

/// 1:1: `Extensions = { ModesRegistry: 'editor.modesRegistry' }`
class Extensions {
  static const String ModesRegistry = 'editor.modesRegistry';

  const Extensions._();
}

/// 1:1: `EditorModesRegistry extends Disposable`
class EditorModesRegistry extends Disposable {
  final List<ILanguageExtensionPoint> _languages = <ILanguageExtensionPoint>[];

  final Emitter<void> _onDidChangeLanguages = Emitter<void>();
  late final Event<void> onDidChangeLanguages = _onDidChangeLanguages.event;

  EditorModesRegistry() : super();

  /// 1:1: `registerLanguage(def)`
  IDisposable registerLanguage(ILanguageExtensionPoint def) {
    _languages.add(def);
    _onDidChangeLanguages.fire(null);
    return toDisposable(() {
      for (int i = 0; i < _languages.length; i++) {
        if (identical(_languages[i], def)) {
          _languages.removeAt(i);
          return;
        }
      }
    });
  }

  /// 1:1: `getLanguages()`
  List<ILanguageExtensionPoint> getLanguages() => _languages;
}

/// 1:1: `PLAINTEXT_LANGUAGE_ID`
const String PLAINTEXT_LANGUAGE_ID = 'plaintext';

/// 1:1: `PLAINTEXT_EXTENSION`
const String PLAINTEXT_EXTENSION = '.txt';

/// 1:1 module-load side effects + `export const ModesRegistry = new EditorModesRegistry()`
final EditorModesRegistry ModesRegistry = () {
  final EditorModesRegistry registry = EditorModesRegistry();
  Registry.add(Extensions.ModesRegistry, registry);

  registry.registerLanguage(ILanguageExtensionPoint(
    id: PLAINTEXT_LANGUAGE_ID,
    extensions: <String>[PLAINTEXT_EXTENSION],
    aliases: <String>[localize('plainText.alias', 'Plain Text'), 'text'],
    mimetypes: <String>[Mimes.text],
  ));

  // TS module import eagerly registers the configuration registry; Dart's
  // private lazy side-effect in that library needs an explicit mirror here.
  if (!Registry.knows(config.Extensions.Configuration)) {
    Registry.add(config.Extensions.Configuration, config.configurationRegistry);
  }
  (Registry.as(config.Extensions.Configuration) as config.IConfigurationRegistry)
      .registerDefaultConfigurations(<config.IConfigurationDefaults>[
    config.IConfigurationDefaults(<String, Object?>{
      '[plaintext]': <String, Object?>{
        'editor.unicodeHighlight.ambiguousCharacters': false,
        'editor.unicodeHighlight.invisibleCharacters': false,
      },
      '[go]': <String, Object?>{
        'editor.insertSpaces': false,
      },
      '[makefile]': <String, Object?>{
        'editor.insertSpaces': false,
      },
      '[shellscript]': <String, Object?>{
        'files.eol': '\n',
      },
      '[yaml]': <String, Object?>{
        'editor.insertSpaces': true,
        'editor.tabSize': 2,
      },
    }),
  ]);

  return registry;
}();
