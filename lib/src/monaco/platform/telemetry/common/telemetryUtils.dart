// 1:1 port of vscode/src/vs/platform/telemetry/common/telemetryUtils.ts

import 'dart:io' as io;

import '../../../base/common/objects.dart' as objects;
import '../../../base/common/types.dart' as types;
import '../../../base/common/uri.dart' as uri;
import '../../log/common/log.dart' as log;
import '../../remote/common/remoteHosts.dart' as remoteHosts;
import 'telemetry.dart' as telemetry;

/// 1:1: `export class TelemetryTrustedValue<T>`
class TelemetryTrustedValue<T> {
  TelemetryTrustedValue(this.value);

  final T value;

  /// 1:1: `public readonly isTrustedTelemetryValue = true`
  final bool isTrustedTelemetryValue = true;
}

/// 1:1: `export class NullTelemetryServiceShape`
class NullTelemetryServiceShape implements telemetry.ITelemetryServiceType {
  // ignore: unused_element
  Object? get _serviceBrand => null;

  @override
  final int telemetryLevel = telemetry.TelemetryLevel.NONE;
  @override
  final String sessionId = 'someValue.sessionId';
  @override
  final String machineId = 'someValue.machineId';
  @override
  final String sqmId = 'someValue.sqmId';
  @override
  final String devDeviceId = 'someValue.devDeviceId';
  @override
  final String firstSessionDate = 'someValue.firstSessionDate';
  @override
  final bool sendErrorTelemetry = false;
  @override
  bool? get msftInternal => null;

  @override
  void publicLog(String eventName, [telemetry.ITelemetryData? data]) {}
  @override
  void publicLog2(String eventName, [Object? data]) {}
  @override
  void publicLogError(String errorEventName, [telemetry.ITelemetryData? data]) {}
  @override
  void publicLogError2(String errorEventName, [Object? data]) {}
  @override
  void setExperimentProperty(String name, String value) {}
  @override
  void setCommonProperty(String name, Object? value) {}
}

/// 1:1: `export const NullTelemetryService`
final NullTelemetryServiceShape NullTelemetryService =
    NullTelemetryServiceShape();

/// 1:1: `export class NullEndpointTelemetryService`
class NullEndpointTelemetryService
    implements telemetry.ICustomEndpointTelemetryServiceType {
  // ignore: unused_element
  Object? get _serviceBrand => null;

  @override
  void publicLog(telemetry.ITelemetryEndpoint endpoint, String eventName,
      [telemetry.ITelemetryData? data]) {}

  @override
  void publicLogError(telemetry.ITelemetryEndpoint endpoint,
      String errorEventName, [telemetry.ITelemetryData? data]) {}
}

/// 1:1: `export const telemetryLogId`
const String telemetryLogId = 'telemetry';

/// 1:1: `export const TelemetryLogGroup`
final log.LoggerGroup TelemetryLogGroup =
    log.LoggerGroup(id: telemetryLogId, name: 'Telemetry');

/// 1:1: `export interface ITelemetryAppender`
abstract class ITelemetryAppender {
  void log(String eventName, Object? data);
  Future<void> flush();
}

/// 1:1: `export const NullAppender`
final ITelemetryAppender NullAppender = _NullAppender();

class _NullAppender implements ITelemetryAppender {
  @override
  void log(String eventName, Object? data) {}
  @override
  Future<void> flush() => Future<void>.value();
}

/// 1:1: `export interface URIDescriptor`
class URIDescriptor {
  URIDescriptor({this.mimeType, this.scheme, this.ext, this.path});

  final String? mimeType;
  final String? scheme;
  final String? ext;
  final String? path;
}

/// Carrier for the product fields read by this module.
class TelemetryProductInfo {
  TelemetryProductInfo({
    this.enableTelemetry,
    this.ariaKey,
    List<String>? msftInternalDomains,
  }) : msftInternalDomains = msftInternalDomains ?? const <String>[];

  final bool? enableTelemetry;
  final String? ariaKey;
  final List<String> msftInternalDomains;
}

/// Carrier for the environment fields read by this module.
class TelemetryEnvironmentInfo {
  TelemetryEnvironmentInfo({
    this.isBuilt = false,
    this.disableTelemetry = false,
    this.extensionTestsLocationURI,
  });

  final bool isBuilt;
  final bool disableTelemetry;
  final Object? extensionTestsLocationURI;
}

/// Carrier for `IConfigurationService.getValue` in this module.
class TelemetryConfigReader {
  TelemetryConfigReader(this.getValue);

  final Object? Function(String key) getValue;
}

/// 1:1: `supportsTelemetry`
bool supportsTelemetry(
        TelemetryProductInfo productService,
        TelemetryEnvironmentInfo environmentService) =>
    (!environmentService.isBuilt && !environmentService.disableTelemetry)
        ? true
        : !(environmentService.disableTelemetry ||
            (productService.enableTelemetry != true));

/// 1:1: `isLoggingOnly`
bool isLoggingOnly(
  TelemetryProductInfo productService,
  TelemetryEnvironmentInfo environmentService,
) {
  if (environmentService.extensionTestsLocationURI != null) return true;
  if (environmentService.isBuilt) return false;
  if (environmentService.disableTelemetry) return false;
  if (productService.enableTelemetry == true &&
      productService.ariaKey != null) {
    return false;
  }
  return true;
}

/// 1:1: `getTelemetryLevel`
int getTelemetryLevel(TelemetryConfigReader configurationService) {
  final Object? newConfig =
      configurationService.getValue(telemetry.TELEMETRY_SETTING_ID);
  final Object? crashReporterConfig = configurationService.getValue(
      telemetry.TELEMETRY_CRASH_REPORTER_SETTING_ID);
  final Object? oldConfig =
      configurationService.getValue(telemetry.TELEMETRY_OLD_SETTING_ID);

  if (oldConfig == false || crashReporterConfig == false) {
    return telemetry.TelemetryLevel.NONE;
  }

  final Object? effective = newConfig ??
      telemetry.TelemetryConfiguration.ON;
  switch (effective) {
    case telemetry.TelemetryConfiguration.ON:
      return telemetry.TelemetryLevel.USAGE;
    case telemetry.TelemetryConfiguration.ERROR:
      return telemetry.TelemetryLevel.ERROR;
    case telemetry.TelemetryConfiguration.CRASH:
      return telemetry.TelemetryLevel.CRASH;
    case telemetry.TelemetryConfiguration.OFF:
      return telemetry.TelemetryLevel.NONE;
    default:
      return telemetry.TelemetryLevel.NONE;
  }
}

/// 1:1: `interface Properties`
typedef Properties = Map<String, String>;

/// 1:1: `interface Measurements`
typedef Measurements = Map<String, num>;

/// 1:1: `validateTelemetryData`
Map<String, Object?> validateTelemetryData(Object? data) {
  final Properties properties = <String, String>{};
  final Measurements measurements = <String, num>{};
  final Map<String, Object?> flat = <String, Object?>{};
  _flatten(data, flat);

  for (final String key in flat.keys.toList(growable: false)) {
    String prop = key.length > 150 ? key.substring(key.length - 149) : key;
    final Object? value = flat[prop];
    if (value is num) {
      measurements[prop] = value;
    } else if (value is bool) {
      measurements[prop] = value ? 1 : 0;
    } else if (value is String) {
      if (value.length > 8192) {
        consoleWarnProvider(
            'Telemetry property: $prop has been trimmed to 8192, the original length is ${value.length}');
      }
      properties[prop] =
          value.length > 8191 ? value.substring(0, 8191) : value;
    } else if (value != null) {
      properties[prop] = value.toString();
    }
  }

  return <String, Object?>{'properties': properties, 'measurements': measurements};
}

void Function(Object message) consoleWarnProvider = (Object message) {};

/// 1:1: `interface IRemoteAuthoringConfig`
class RemoteAuthoringConfig {
  RemoteAuthoringConfig({
    Map<String, Object?>? remoteExtensionTips,
    Map<String, Object?>? virtualWorkspaceExtensionTips,
  })  : remoteExtensionTips =
            remoteExtensionTips ?? const <String, Object?>{},
        virtualWorkspaceExtensionTips =
            virtualWorkspaceExtensionTips ?? const <String, Object?>{};

  final Map<String, Object?> remoteExtensionTips;
  final Map<String, Object?> virtualWorkspaceExtensionTips;
}

/// 1:1: `cleanRemoteAuthority`
String cleanRemoteAuthority(
    String? remoteAuthority, RemoteAuthoringConfig config) {
  if (remoteAuthority == null || remoteAuthority.isEmpty) return 'none';
  final String? remoteName = remoteHosts.getRemoteName(remoteAuthority);
  if (remoteName == null) return 'other';
  if (config.remoteExtensionTips.containsKey(remoteName)) return remoteName;
  if (config.virtualWorkspaceExtensionTips.containsKey(remoteName)) {
    return remoteName;
  }
  return 'other';
}

void _flatten(Object? obj, Map<String, Object?> result,
    [int order = 0, String prefix = '']) {
  if (obj == null ||
      (obj is! Map && obj is! List && obj is! Function)) {
    return;
  }
  final Map<String, Object?> source = obj is Map
      ? obj.cast<String, Object?>()
      : <String, Object?>{};
  for (final String item in source.keys) {
    final Object? value = source[item];
    final String index = prefix.isEmpty ? item : prefix + item;
    if (value is List) {
      result[index] = objects.safeStringify(value);
    } else if (value is DateTime) {
      result[index] = value.toUtc().toIso8601String();
    } else if (types.isObject(value)) {
      if (order < 2) {
        _flatten(value, result, order + 1, '$index.');
      } else {
        result[index] = objects.safeStringify(value);
      }
    } else {
      result[index] = value;
    }
  }
}

/// 1:1: `isInternalTelemetry`
String? Function() userDnsDomainProvider =
    () => io.Platform.environment['USERDNSDOMAIN'];

bool isInternalTelemetry(
        TelemetryProductInfo productService,
        TelemetryConfigReader configService) =>
    _verifyMicrosoftInternalDomain(productService.msftInternalDomains) ||
    configService.getValue('telemetry.internalTesting') == true;

bool _verifyMicrosoftInternalDomain(List<String> domainList) {
  final String? domain = userDnsDomainProvider();
  if (domain == null || domain.isEmpty) return false;
  final String lower = domain.toLowerCase();
  return domainList.any((String d) => lower == d.toLowerCase());
}

/// 1:1: `interface IPathEnvironment`
class IPathEnvironment {
  IPathEnvironment({
    required this.appRoot,
    required this.extensionsPath,
    required this.userDataPath,
    required this.userHome,
    required this.tmpDir,
  });

  final String appRoot;
  final String extensionsPath;
  final String userDataPath;
  final uri.URI userHome;
  final uri.URI tmpDir;
}

/// 1:1: `getPiiPathsFromEnvironment`
List<String> getPiiPathsFromEnvironment(IPathEnvironment paths) => <String>[
      paths.appRoot,
      paths.extensionsPath,
      paths.userHome.fsPath,
      paths.tmpDir.fsPath,
      paths.userDataPath,
    ];

/// 1:1: `getUserContentPathsFromEnvironment`
List<String> getUserContentPathsFromEnvironment(IPathEnvironment paths) =>
    <String>[paths.userHome.fsPath, paths.tmpDir.fsPath];

/// 1:1: regex plus the JS global flag, which controls replacement semantics.
class TelemetryPattern {
  TelemetryPattern(this.regex, [this.global = true]);

  final RegExp regex;
  final bool global;
}

List<List<int>> _matchRanges(String value, List<TelemetryPattern> patterns) {
  final List<List<int>> ranges = <List<int>>[];
  for (final TelemetryPattern p in patterns) {
    final Iterable<RegExpMatch> matches =
        p.global ? p.regex.allMatches(value) : <RegExpMatch>[];
    if (!p.global) {
      final RegExpMatch? first = p.regex.firstMatch(value);
      if (first != null) {
        ranges.add(<int>[first.start, first.end]);
      }
      continue;
    }
    for (final RegExpMatch m in matches) {
      ranges.add(<int>[m.start, m.end]);
    }
  }
  return ranges;
}

final RegExp _nodeModulesRegex =
    RegExp(r'(?:^|[\\\/])((node_modules|node_modules\.asar)[\\\/].*)$');
final RegExp _vscodeExtensionsPathRegex = RegExp(
    r'^(.*?)((?:\.vscode(?:-[a-z]+)*|resources[\\\/]app)[\\\/]extensions[\\\/].*)$',
    caseSensitive: false);
final RegExp _fileRegex = RegExp(
    r'(file:\/\/)?([a-zA-Z]:(\\\\|\\|\/)|(\\\\|\\|\/))?([\w\-\._@]+(\\\\|\\|\/))+[\w\-\._@]*',
    multiLine: false);

String _anonymizeFilePaths(String stack, List<TelemetryPattern> relativeRoots,
    List<TelemetryPattern> userContentRoots) {
  if (stack.isEmpty || (!stack.contains('/') && !stack.contains('\\'))) {
    return stack;
  }

  final List<List<int>> cleanUpIndexes = _matchRanges(stack, relativeRoots);
  final List<List<int>> userContentIndexes =
      _matchRanges(stack, userContentRoots);

  String updatedStack = '';
  int lastIndex = 0;
  for (final RegExpMatch result in _fileRegex.allMatches(stack)) {
    final bool overlappingRange = cleanUpIndexes.any((List<int> r) =>
        result.start < r[1] && r[0] < result.end);
    if (!overlappingRange) {
      final bool isUserContent = userContentIndexes.any((List<int> r) =>
          result.start < r[1] && r[0] < result.end);
      final RegExpMatch? vscodeExtMatch = isUserContent
          ? null
          : _vscodeExtensionsPathRegex.firstMatch(result.group(0)!);
      if (vscodeExtMatch != null) {
        updatedStack += stack.substring(lastIndex, result.start) +
            '<REDACTED: user-file-path>/' +
            vscodeExtMatch.group(2)!;
      } else {
        final RegExpMatch? nodeModulesMatch = isUserContent
            ? null
            : _nodeModulesRegex.firstMatch(result.group(0)!);
        if (nodeModulesMatch != null) {
          updatedStack += stack.substring(lastIndex, result.start) +
              '<REDACTED: user-file-path>/' +
              nodeModulesMatch.group(1)!;
        } else {
          updatedStack += stack.substring(lastIndex, result.start) +
              '<REDACTED: user-file-path>';
        }
      }
      lastIndex = result.end;
    }
  }
  if (lastIndex < stack.length) {
    updatedStack += stack.substring(lastIndex);
  }
  return updatedStack;
}

class _SecretPattern {
  _SecretPattern(this.label, String source, {bool caseSensitive = true})
      : regex = RegExp(source, caseSensitive: caseSensitive);

  final String label;
  final RegExp regex;
}

final List<_SecretPattern> _userDataRegexes = <_SecretPattern>[
  _SecretPattern('URL', r'''[a-zA-Z][a-zA-Z0-9+.-]*:\/\/[^\s]*'''),
  _SecretPattern('Google API Key', r'''AIza[0-9A-Za-z_\-]{20,}'''),
  _SecretPattern('JWT',
      r'''eyJ[0eXAiOiJKV1Qi|hbGci|a-zA-Z0-9\-_]+\.[a-zA-Z0-9\-_]+\.[a-zA-Z0-9\-_]+'''),
  _SecretPattern('Slack Token', r'''xox[pbar]\-[A-Za-z0-9]'''),
  _SecretPattern('GitHub Token',
      r'''(gh[psuro]_[a-zA-Z0-9]{36}|github_pat_[a-zA-Z0-9]{22}_[a-zA-Z0-9]{59})'''),
  _SecretPattern('Generic Secret',
      r'''(key|token|sig|secret|signature|password|passwd|pwd|android:value)[^a-zA-Z0-9]''',
      caseSensitive: false),
  _SecretPattern(
      'CLI Credentials',
      r'''((login|psexec|(certutil|psexec)\.exe).{1,50}(\s-u(ser(name)?)?\s+.{3,100})?\s-(admin|user|vm|root)?p(ass(word)?)?\s+["']?[^$\-\/\s]|(^|[\s\r\n\\])net(\.exe)?.{1,5}(user\s+|share\s+\/user:| user -? secrets ? set) \s + [^ $\s \/])'''),
  _SecretPattern(
      'CLI Password Flag',
      r'''(?:^|[\s"'`])(?:--?(?:pw|pass)(?:\s+|=)|\/pass:|sshpass\s+-p\s*)["']?[^\s"'$\-]''',
      caseSensitive: false),
  _SecretPattern('CLI Basic Auth',
      r'''(?:^|\s)(?:-u(?:\s+|=)?|--user(?:\s+|=))["']?(?!\d+:\d+\b)[^\s:"']+:[^\s"']+'''),
  _SecretPattern('Microsoft Entra ID',
      r'''eyJ(?:0eXAiOiJKV1Qi|hbGci|[a-zA-Z0-9\-_]+\.[a-zA-Z0-9\-_]+\.)'''),
  _SecretPattern('Email', r'''[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'''),
];

String _redactIfPossibleUserInfo(String value, [String? probe]) {
  for (final _SecretPattern p in _userDataRegexes) {
    if (p.regex.hasMatch(probe ?? value)) {
      return '<REDACTED: ${p.label}>';
    }
  }
  return value;
}

final RegExp _oneDriveOrganizationRegex = RegExp(r'''OneDrive - (?:[^\\\/\r\n"<>|:*?]+(?=[\\\/])|[^\\\/\r\n"'`]+)''');

String _removePropertiesWithPossibleUserInfo(String property) {
  if (property.isEmpty) return property;
  if (!_userDataRegexes.any((_SecretPattern p) => p.regex.hasMatch(property))) {
    return property;
  }
  if (!property.contains('\n')) return _redactIfPossibleUserInfo(property);
  final List<String> lines = property.split('\n');
  for (int i = 0; i < lines.length; i++) {
    final String probe = i < lines.length - 1 ? '${lines[i]}\n' : lines[i];
    lines[i] = _redactIfPossibleUserInfo(lines[i], probe);
  }
  return lines.join('\n');
}

/// 1:1: `cleanData`
Map<String, Object?> cleanData(
  Object? data,
  List<TelemetryPattern> cleanUpPatterns, [
  List<TelemetryPattern>? relativePathRootPatterns,
  List<TelemetryPattern>? userContentRootPatterns,
]) {
  if (data == null) return <String, Object>{};
  final List<TelemetryPattern> relative =
      relativePathRootPatterns ?? cleanUpPatterns;
  final List<TelemetryPattern> userContent =
      userContentRootPatterns ?? const <TelemetryPattern>[];

  final Object? cleaned = objects.cloneAndChange(data, (Object? value) {
    if (value is TelemetryTrustedValue) return value.value;
    if (value is Map && value.containsKey('isTrustedTelemetryValue')) {
      return value['isTrustedTelemetryValue'] == true ? value['value'] : null;
    }
    if (value is String) {
      String updated = value.replaceAll('%20', ' ');
      if (updated.contains('OneDrive - ')) {
        updated = updated.replaceAll(_oneDriveOrganizationRegex, 'OneDrive');
      }
      updated = _anonymizeFilePaths(updated, relative, userContent);
      for (final TelemetryPattern p in cleanUpPatterns) {
        updated = p.global
            ? updated.replaceAll(p.regex, '')
            : updated.replaceFirst(p.regex, '');
      }
      return _removePropertiesWithPossibleUserInfo(updated);
    }
    return null;
  });
  return (cleaned as Map).cast<String, Object?>();
}

/// Exposed for parity with the source's use of `process.env` in
/// `commonProperties.verifyMicrosoftInternalDomain`.
String? get userDnsDomain => io.Platform.environment['USERDNSDOMAIN'];
