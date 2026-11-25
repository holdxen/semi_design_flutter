// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/services/textResourceConfigurationService.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Carriers:
//   - `IConfigurationValue` is exposed by the configuration service as a flat
//     Map in this port; here a file-local carrier mirrors the nested
//     `.memory/.workspace/... { value, override }` shape used by the source.
//   - `IConfigurationService` / `IModelService` / `ILanguageService` are carried
//     as narrow file-local interfaces declaring only the members used here.
//   - `Promise<void>` -> `Future<void>`.
// ---------------------------------------------------------------------------

import '../../../base/common/event.dart' show Emitter, Event;
import '../../../base/common/lifecycle.dart' show Disposable;
import '../../../base/common/uri.dart' show URI;
import '../core/position.dart' show IPosition;
import 'textResourceConfiguration.dart'
    show
        ITextResourceConfigurationChangeEvent,
        ITextResourceConfigurationServiceType;
import '../../../platform/configuration/common/configuration.dart'
    show
        ConfigurationTarget,
        IConfigurationChangeEvent,
        IConfigurationOverrides,
        IConfigurationValue,
        IInspectValue;

/// 1:1: subset of `IConfigurationService` used by this class.
/// `inspect` returns the nested [IConfigurationValue] carrier (the flat Map
/// variant of the wider port cannot express `.memory?.override`).
abstract class ITextResourceConfigService {
  Event<IConfigurationChangeEvent> get onDidChangeConfiguration;

  Object? getValue$2(Object overrides);

  Object? getValue$3(String section, Object overrides);

  IConfigurationValue<Object?> inspect(String key, [Object? overrides]);

  Future<void> updateValue$5(
    String key,
    Object? value,
    Object overrides,
    int target,
  );
}

/// 1:1: `ITextModel` subset used by [TextResourceConfigurationService].
abstract class ITextResourceConfigModel {
  String getLanguageId();

  String? getLanguageIdAtPosition(int lineNumber, int column);
}

/// 1:1: narrow `IModelService.getModel` carrier.
abstract class ITextResourceConfigModelService {
  ITextResourceConfigModel? getModel(URI resource);
}

/// 1:1: narrow `ILanguageService.guessLanguageIdByFilepathOrFirstLine` carrier.
abstract class ITextResourceConfigLanguageService {
  String? guessLanguageIdByFilepathOrFirstLine(URI resource);
}

/// 1:1: `{ resource, overrideIdentifier }` overrides carrier.
/// Implements the shared [IConfigurationOverrides] so it can be passed to
/// `IConfigurationChangeEvent.affectsConfiguration`.
class ResourceConfigOverrides implements IConfigurationOverrides {
  ResourceConfigOverrides(this.resource, this.overrideIdentifier);

  @override
  final URI? resource;

  @override
  final String? overrideIdentifier;

  Map<String, Object?> toJson() => <String, Object?>{
        'resource': resource?.toString(),
        'overrideIdentifier': overrideIdentifier,
      };
}

/// 1:1: `TextResourceConfigurationService extends Disposable implements
/// ITextResourceConfigurationService`.
class TextResourceConfigurationService extends Disposable
    implements ITextResourceConfigurationServiceType {
  // ignore: unused_element
  Object? get _serviceBrand => null;

  final ITextResourceConfigService _configurationService;
  final ITextResourceConfigModelService _modelService;
  final ITextResourceConfigLanguageService _languageService;

  final Emitter<ITextResourceConfigurationChangeEvent>
      _onDidChangeConfiguration =
      Emitter<ITextResourceConfigurationChangeEvent>();

  @override
  Event<ITextResourceConfigurationChangeEvent> get onDidChangeConfiguration =>
      _onDidChangeConfiguration.event;

  TextResourceConfigurationService(
    this._configurationService,
    this._modelService,
    this._languageService,
  ) {
    register(_configurationService.onDidChangeConfiguration((dynamic e) {
      _onDidChangeConfiguration.fire(
          _toResourceConfigurationChangeEvent(e as IConfigurationChangeEvent));
    }));
  }

  /// 1:1: `getValue<T>(resource, arg2?, arg3?)`.
  @override
  Object? getValue$1(URI? resource, [String? section]) =>
      _getValue(resource, null, section);

  @override
  Object? getValue$2(URI? resource, [IPosition? position, String? section]) =>
      _getValue(resource, position, section);

  Object? _getValue(URI? resource, IPosition? position, String? section) {
    final String? language = resource != null
        ? _getLanguage(resource, position)
        : null;
    final ResourceConfigOverrides overrides =
        ResourceConfigOverrides(resource, language);
    if (section == null) {
      return _configurationService.getValue$2(overrides);
    }
    return _configurationService.getValue$3(section, overrides);
  }

  /// 1:1: `updateValue(resource, key, value, configurationTarget?)`.
  @override
  Future<void> updateValue(
    URI? resource,
    String key,
    Object value, [
    int? configurationTarget,
  ]) async {
    final String? language =
        resource != null ? _getLanguage(resource, null) : null;
    final IConfigurationValue<Object?> configurationValue =
        _configurationService.inspect(
            key, ResourceConfigOverrides(resource, language));
    configurationTarget ??=
        _deriveConfigurationTarget(configurationValue, language);
    final String? overrideIdentifier = language != null &&
            (configurationValue.overrideIdentifiers?.contains(language) ?? false)
        ? language
        : null;
    return _configurationService.updateValue$5(
      key,
      value,
      ResourceConfigOverrides(resource, overrideIdentifier),
      configurationTarget,
    );
  }

  /// 1:1: `deriveConfigurationTarget(configurationValue, language)`.
  int _deriveConfigurationTarget(
    IConfigurationValue<Object?> configurationValue,
    String? language,
  ) {
    if (language != null) {
      if (_inspectOverrideDefined(configurationValue.memory)) {
        return ConfigurationTarget.MEMORY;
      }
      if (_inspectOverrideDefined(configurationValue.workspaceFolder)) {
        return ConfigurationTarget.WORKSPACE_FOLDER;
      }
      if (_inspectOverrideDefined(configurationValue.workspace)) {
        return ConfigurationTarget.WORKSPACE;
      }
      if (_inspectOverrideDefined(configurationValue.userRemote)) {
        return ConfigurationTarget.USER_REMOTE;
      }
      if (_inspectOverrideDefined(configurationValue.userLocal)) {
        return ConfigurationTarget.USER_LOCAL;
      }
    }
    if (_inspectValueDefined(configurationValue.memory)) {
      return ConfigurationTarget.MEMORY;
    }
    if (_inspectValueDefined(configurationValue.workspaceFolder)) {
      return ConfigurationTarget.WORKSPACE_FOLDER;
    }
    if (_inspectValueDefined(configurationValue.workspace)) {
      return ConfigurationTarget.WORKSPACE;
    }
    if (_inspectValueDefined(configurationValue.userRemote)) {
      return ConfigurationTarget.USER_REMOTE;
    }
    return ConfigurationTarget.USER_LOCAL;
  }

  /// 1:1: `xxx?.override !== undefined`.
  bool _inspectOverrideDefined(IInspectValue<Object?>? inspectValue) =>
      inspectValue?.override != null;

  /// 1:1: `xxx?.value !== undefined`.
  bool _inspectValueDefined(IInspectValue<Object?>? inspectValue) =>
      inspectValue?.value != null;

  /// 1:1: `inspect<T>(resource, position, section)`.
  @override
  IConfigurationValue<Object?> inspect(
    URI? resource,
    IPosition? position,
    String section,
  ) {
    final String? language = resource != null
        ? _getLanguage(resource, position)
        : null;
    return _configurationService.inspect(
        section, ResourceConfigOverrides(resource, language));
  }

  /// 1:1: `getLanguage(resource, position)`.
  String? _getLanguage(URI resource, IPosition? position) {
    final ITextResourceConfigModel? model = _modelService.getModel(resource);
    if (model != null) {
      return position != null
          ? model.getLanguageIdAtPosition(position.lineNumber, position.column)
          : model.getLanguageId();
    }
    return _languageService.guessLanguageIdByFilepathOrFirstLine(resource);
  }

  /// 1:1: `toResourceConfigurationChangeEvent(configurationChangeEvent)`.
  ITextResourceConfigurationChangeEvent _toResourceConfigurationChangeEvent(
    IConfigurationChangeEvent configurationChangeEvent,
  ) =>
      _ResourceConfigurationChangeEvent(
          this, configurationChangeEvent);
}

/// 1:1: returned `ITextResourceConfigurationChangeEvent` object literal.
class _ResourceConfigurationChangeEvent
    implements ITextResourceConfigurationChangeEvent {
  _ResourceConfigurationChangeEvent(this._service, this._event);

  final TextResourceConfigurationService _service;
  final IConfigurationChangeEvent _event;

  @override
  Set<String> get affectedKeys => _event.affectedKeys;

  @override
  bool affectsConfiguration(URI? resource, String configuration) {
    final String? overrideIdentifier =
        resource != null ? _service._getLanguage(resource, null) : null;
    final ResourceConfigOverrides overrides =
        ResourceConfigOverrides(resource, overrideIdentifier);
    if (_event.affectsConfiguration(configuration, overrides)) {
      return true;
    }
    if (overrideIdentifier != null) {
      // workaround for https://github.com/microsoft/vscode/issues/240410
      return _event.affectedKeys.contains('[$overrideIdentifier]');
    }
    return false;
  }
}
