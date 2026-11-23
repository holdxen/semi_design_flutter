// 1:1 port of vs/platform/telemetry/common/commonProperties.ts
// Pure functions producing common telemetry properties. The JS
// `Object.create(null)` + `Object.defineProperties` (enumerable getters) is
// carried by a class implementing ICommonProperties (`operator []`), with the
// three dynamic properties computed on access exactly like JS getters.
import '../../../base/common/platform.dart' as plat;
import '../../../base/common/process.dart' as process;
import '../../../base/common/uuid.dart' show generateUuid;
import 'telemetry.dart' show ICommonProperties;

/// 1:1: `function getPlatformDetail(hostname): string | undefined`
String? getPlatformDetail(String hostname) {
  if (plat.platform == plat.Platform_.Linux &&
      RegExp(r'^penguin(\.|$)', caseSensitive: false).hasMatch(hostname)) {
    return 'chromebook';
  }
  return null;
}

/// Carrier for the JS `Object.create(null)` result with enumerable getter
/// properties. Static keys are stored in [_values]; the three dynamic keys are
/// computed in `operator []` mirroring `Object.defineProperties` getters.
class _CommonProperties implements ICommonProperties {
  final Map<String, Object?> _values = <String, Object?>{};
  int _seq = 0;
  final int _startTime;

  _CommonProperties(this._startTime);

  @override
  Object? operator [](String key) {
    switch (key) {
      case 'timestamp':
        return DateTime.now();
      case 'common.timesincesessionstart':
        return DateTime.now().millisecondsSinceEpoch - _startTime;
      case 'common.sequence':
        return _seq++;
      default:
        return _values[key];
    }
  }

  void operator []=(String key, Object? value) => _values[key] = value;
}

/// 1:1: `export function resolveCommonProperties(...)`
ICommonProperties resolveCommonProperties(
  String release,
  String hostname,
  String arch,
  String? commit,
  String? version,
  String? machineId,
  String? sqmId,
  String? devDeviceId,
  bool isInternalTelemetry,
  String? releaseDate, [
  String? product,
]) {
  final result = _CommonProperties(DateTime.now().millisecondsSinceEpoch);

  result['common.machineId'] = machineId;
  result['common.sqmId'] = sqmId;
  result['common.devDeviceId'] = devDeviceId;
  result['sessionID'] = generateUuid() + DateTime.now().millisecondsSinceEpoch.toString();
  result['commitHash'] = commit;
  result['version'] = version;
  result['common.releaseDate'] = releaseDate;
  // 1:1: `(release || '').replace(/^(\d+)(\.\d+)?(\.\d+)?(.*)/, '$1$2$3')`
  // JS String.replace returns the original string when the regex does not match
  // (e.g. 'abc'), so no-match must preserve `release`, not yield ''.
  final match = RegExp(r'^(\d+)(\.\d+)?(\.\d+)?(.*)').firstMatch(release);
  result['common.platformVersion'] = match == null
      ? release
      : match.groups([1, 2, 3]).map((g) => g ?? '').join();
  result['common.platform'] = plat.PlatformToString(plat.platform);
  result['common.nodePlatform'] = process.platform;
  result['common.nodeArch'] = arch;
  result['common.product'] = product ?? 'desktop';

  if (isInternalTelemetry) {
    result['common.msftInternal'] = isInternalTelemetry;
  }

  // 1:1: dynamic properties (Object.defineProperties enumerable getters) —
  // `timestamp`, `common.timesincesessionstart`, `common.sequence` are handled
  // in _CommonProperties.operator [] above.

  if (plat.isLinuxSnap) {
    result['common.snap'] = 'true';
  }

  final platformDetail = getPlatformDetail(hostname);
  if (platformDetail != null) {
    result['common.platformDetail'] = platformDetail;
  }

  return result;
}

/// 1:1: `export function verifyMicrosoftInternalDomain(domainList): boolean`
bool verifyMicrosoftInternalDomain(List<String> domainList) {
  final String? userDnsDomain = process.env['USERDNSDOMAIN'];
  if (userDnsDomain == null || userDnsDomain.isEmpty) {
    return false;
  }
  final String domain = userDnsDomain.toLowerCase();
  return domainList.any((msftDomain) => domain == msftDomain);
}
