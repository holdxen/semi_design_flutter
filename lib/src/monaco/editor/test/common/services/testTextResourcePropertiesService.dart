// 1:1 port of vs/editor/test/common/services/testTextResourcePropertiesService.ts
import '../../../../base/common/platform.dart' as platform;
import '../../../../base/common/uri.dart' show URI;
import '../../../common/services/textResourceConfiguration.dart'
    show ITextResourcePropertiesServiceType;
import '../../../../platform/configuration/common/configuration.dart'
    show IConfigurationOverrides, IConfigurationServiceType;

/// Minimal `IConfigurationOverrides` carrier for `{ overrideIdentifier, resource }`.
class _Overrides implements IConfigurationOverrides {
  @override
  final String? overrideIdentifier;
  @override
  final URI? resource;
  _Overrides(this.overrideIdentifier, this.resource);
}

/// 1:1: `export class TestTextResourcePropertiesService implements ITextResourcePropertiesService`
class TestTextResourcePropertiesService
    implements ITextResourcePropertiesServiceType {
  // ignore: unused_element
  Object? get _serviceBrand => null;

  final IConfigurationServiceType _configurationService;

  /// 1:1: `@IConfigurationService constructor(private readonly configurationService: IConfigurationService)`
  TestTextResourcePropertiesService(this._configurationService);

  /// 1:1: `getEOL(resource, language?): string`
  @override
  String getEOL(URI resource, [String? language]) {
    final eol = _configurationService.getValue$3(
        'files.eol', _Overrides(language, resource));
    if (eol != null && eol is String && eol != 'auto') {
      return eol;
    }
    return (platform.isLinux || platform.isMacintosh) ? '\n' : '\r\n';
  }
}
