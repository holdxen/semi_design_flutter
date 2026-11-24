// batch150 truth tests: platform/extensionManagement/common/extensionManagement.dart.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/platform.dart' show Platform_;
import 'package:semi_design_flutter/src/monaco/platform/extensionManagement/common/extensionGalleryManifest.dart'
    show ExtensionGalleryManifestResource, IExtensionGalleryManifest;
import 'package:semi_design_flutter/src/monaco/platform/extensionManagement/common/extensionManagement.dart' as em;
import 'package:semi_design_flutter/src/monaco/platform/extensions/common/extensions.dart'
    show TargetPlatform;

Map<String, dynamic> _loadTruth() {
  final f = File('tool/ts2dart/batch150_truth.json');
  return jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  final t = _loadTruth();
  final constants = t['constants'] as Map<String, dynamic>;
  final serviceIds = t['serviceIds'] as Map<String, dynamic>;
  final enums = t['enums'] as Map<String, dynamic>;

  test('constants match truth', () {
    expect(em.EXTENSION_IDENTIFIER_PATTERN, constants['EXTENSION_IDENTIFIER_PATTERN']);
    expect(em.EXTENSION_PUBLISHER_IDENTIFIER_PATTERN, constants['EXTENSION_PUBLISHER_IDENTIFIER_PATTERN']);
    expect(em.WEB_EXTENSION_TAG, constants['WEB_EXTENSION_TAG']);
    expect(em.LANGUAGE_MODEL_CHAT_PROVIDER_EXTENSION_TAG, constants['LANGUAGE_MODEL_CHAT_PROVIDER_EXTENSION_TAG']);
    expect(em.EXTENSION_INSTALL_SKIP_WALKTHROUGH_CONTEXT, constants['EXTENSION_INSTALL_SKIP_WALKTHROUGH_CONTEXT']);
    expect(em.EXTENSION_INSTALL_SKIP_PUBLISHER_TRUST_CONTEXT, constants['EXTENSION_INSTALL_SKIP_PUBLISHER_TRUST_CONTEXT']);
    expect(em.EXTENSION_INSTALL_SOURCE_CONTEXT, constants['EXTENSION_INSTALL_SOURCE_CONTEXT']);
    expect(em.EXTENSION_INSTALL_DEP_PACK_CONTEXT, constants['EXTENSION_INSTALL_DEP_PACK_CONTEXT']);
    expect(em.EXTENSION_INSTALL_CLIENT_TARGET_PLATFORM_CONTEXT, constants['EXTENSION_INSTALL_CLIENT_TARGET_PLATFORM_CONTEXT']);
    expect(em.DISABLED_EXTENSIONS_STORAGE_PATH, constants['DISABLED_EXTENSIONS_STORAGE_PATH']);
    expect(em.ENABLED_EXTENSIONS_STORAGE_PATH, constants['ENABLED_EXTENSIONS_STORAGE_PATH']);
    expect(em.AllowedExtensionsConfigKey, constants['AllowedExtensionsConfigKey']);
    expect(em.VerifyExtensionSignatureConfigKey, constants['VerifyExtensionSignatureConfigKey']);
    expect(em.ExtensionRequestsTimeoutConfigKey, constants['ExtensionRequestsTimeoutConfigKey']);
    expect(em.ExtensionsLocalizedLabel.value, constants['ExtensionsLocalizedLabel_value']);
    expect(em.PreferencesLocalizedLabel.value, constants['PreferencesLocalizedLabel_value']);
  });

  test('identifier regex matches truth pattern semantics', () {
    // pattern itself is verified above; verify real regex behavior
    expect(em.EXTENSION_IDENTIFIER_REGEX.hasMatch('publisher.name'), isTrue);
    expect(em.EXTENSION_IDENTIFIER_REGEX.hasMatch('PUBLISHEr.N-AMe'), isTrue);
    expect(em.EXTENSION_IDENTIFIER_REGEX.hasMatch('publishername'), isFalse);
    expect(em.EXTENSION_IDENTIFIER_REGEX.hasMatch('publ_isher.name'), isFalse);
    expect(RegExp(em.EXTENSION_PUBLISHER_IDENTIFIER_PATTERN).hasMatch('ms-vscode'), isTrue);
    expect(RegExp(em.EXTENSION_PUBLISHER_IDENTIFIER_PATTERN).hasMatch('ms-vscode.cpptools'), isFalse);
  });

  test('service identifiers match truth', () {
    expect(em.IExtensionGalleryService.serviceId, serviceIds['IExtensionGalleryService']);
    expect(em.IExtensionManagementService.serviceId, serviceIds['IExtensionManagementService']);
    expect(em.IGlobalExtensionEnablementService.serviceId, serviceIds['IGlobalExtensionEnablementService']);
    expect(em.IExtensionTipsService.serviceId, serviceIds['IExtensionTipsService']);
    expect(em.IAllowedExtensionsService.serviceId, serviceIds['IAllowedExtensionsService']);
  });

  test('string/simple enums match truth', () {
    final installSrc = enums['ExtensionInstallSource'] as Map<String, dynamic>;
    expect(em.ExtensionInstallSource.COMMAND, installSrc['COMMAND']);
    expect(em.ExtensionInstallSource.SETTINGS_SYNC, installSrc['SETTINGS_SYNC']);

    final sortBy = enums['SortBy'] as Map<String, dynamic>;
    expect(em.SortBy.NoneOrRelevance, sortBy['NoneOrRelevance']);
    expect(em.SortBy.WeightedRating, sortBy['WeightedRating']);

    final sortOrder = enums['SortOrder'] as Map<String, dynamic>;
    expect(em.SortOrder.Default, sortOrder['Default']);
    expect(em.SortOrder.Ascending, sortOrder['Ascending']);
    expect(em.SortOrder.Descending, sortOrder['Descending']);

    final filterType = enums['FilterType'] as Map<String, dynamic>;
    expect(em.FilterType.Category, filterType['Category']);
    expect(em.FilterType.Target, filterType['Target']);

    final stat = enums['StatisticType'] as Map<String, dynamic>;
    expect(em.StatisticType.Install, stat['Install']);
    expect(em.StatisticType.Uninstall, stat['Uninstall']);

    final installOp = enums['InstallOperation'] as Map<String, dynamic>;
    expect(em.InstallOperation.None, installOp['None']);
    expect(em.InstallOperation.Install, installOp['Install']);
    expect(em.InstallOperation.Update, installOp['Update']);
    expect(em.InstallOperation.Migrate, installOp['Migrate']);

    final blockingOrigin = enums['ExtensionBlockingOrigin'] as Map<String, dynamic>;
    expect(em.ExtensionBlockingOrigin.Service, blockingOrigin['Service']);
    expect(em.ExtensionBlockingOrigin.Policy, blockingOrigin['Policy']);
    final blockingScope = enums['ExtensionBlockingScope'] as Map<String, dynamic>;
    expect(em.ExtensionBlockingScope.Extension, blockingScope['Extension']);
    expect(em.ExtensionBlockingScope.Version, blockingScope['Version']);
  });

  test('error-code enums match truth', () {
    final galleryErr = enums['ExtensionGalleryErrorCode'] as Map<String, dynamic>;
    expect(em.ExtensionGalleryErrorCode.Timeout, galleryErr['Timeout']);
    expect(em.ExtensionGalleryErrorCode.Offline, galleryErr['Offline']);
    final mgmtErr = enums['ExtensionManagementErrorCode'] as Map<String, dynamic>;
    expect(em.ExtensionManagementErrorCode.NotFound, mgmtErr['NotFound']);
    expect(em.ExtensionManagementErrorCode.DownloadFailedWriting, mgmtErr['DownloadFailedWriting']);
    expect(em.ExtensionManagementErrorCode.Internal, mgmtErr['Internal']);
    final sigErr = enums['ExtensionSignatureVerificationCode'] as Map<String, dynamic>;
    for (final v in em.ExtensionSignatureVerificationCode.values) {
      expect(v.name, sigErr[v.name]);
    }
  });

  test('TargetPlatformToString matches truth', () {
    final m = t['targetPlatformToString'] as Map<String, dynamic>;
    m.forEach((k, v) {
      expect(em.TargetPlatformToString(k), v, reason: 'TargetPlatformToString($k)');
    });
    expect(em.TargetPlatformToString('bogus'), isNull);
  });

  test('toTargetPlatform matches truth', () {
    final m = t['toTargetPlatform'] as Map<String, dynamic>;
    m.forEach((k, v) {
      expect(em.toTargetPlatform(k), v, reason: 'toTargetPlatform($k)');
    });
    expect(em.toTargetPlatform('bogus'), TargetPlatform.UNKNOWN);
  });

  test('getTargetPlatform matches truth', () {
    final m = t['getTargetPlatform'] as Map<String, dynamic>;
    m.forEach((k, v) {
      final parts = k.split(':');
      final String platformName = parts[0];
      final String? arch = parts[1] == 'undefined' ? null : parts[1];
      Object platform;
      if (platformName == 'alpine') {
        platform = 'alpine';
      } else {
        platform = switch (platformName) {
          'Web' => Platform_.Web,
          'Mac' => Platform_.Mac,
          'Linux' => Platform_.Linux,
          'Windows' => Platform_.Windows,
          _ => throw StateError('unknown platform $platformName'),
        };
      }
      expect(em.getTargetPlatform(platform, arch), v, reason: 'getTargetPlatform($k)');
    });
  });

  test('target platform compatibility functions match truth', () {
    final cases = t['targetPlatformFunctions'] as List<dynamic>;
    for (final c in cases) {
      final i = c['i'];
      // Reconstruct the cases in the same order as the harness.
      final all = _casesAll[i];
      final prod = _casesProd[i];
      final ext = _casesExt[i];
      expect(em.isNotWebExtensionInWebTargetPlatform(all, prod), c['notWeb'],
          reason: 'notWeb case $i');
      expect(em.isTargetPlatformCompatible(ext, all, prod), c['compat'],
          reason: 'compat case $i');
    }
  });

  test('isIExtensionIdentifier matches truth', () {
    final cases = t['isIExtensionIdentifier'] as List<dynamic>;
    for (final c in cases) {
      final i = c['i'] as int;
      expect(em.isIExtensionIdentifier(_idCases[i]), c['result'],
          reason: 'isIExtensionIdentifier case $i');
    }
  });

  test('error classes carry message/name/code per truth', () {
    final err = t['errors'] as Map<String, dynamic>;
    final g = err['gallery'] as Map<String, dynamic>;
    final ge = em.ExtensionGalleryError('msg', em.ExtensionGalleryErrorCode.Timeout);
    expect(ge.toString(), g['message']);
    expect(ge.name, g['name']);
    expect(ge.code, g['code']);
    final m = err['management'] as Map<String, dynamic>;
    final me = em.ExtensionManagementError('msg2', em.ExtensionManagementErrorCode.NotFound);
    expect(me.toString(), m['message']);
    expect(me.name, m['name']);
    expect(me.code, m['code']);
  });

  test('shouldRequireRepositorySignatureFor matches truth', () {
    final cases = t['signature'] as List<dynamic>;
    for (final c in cases) {
      final i = c['i'] as int;
      final isPrivate = _sigPrivate[i];
      final manifest = _sigManifest[i];
      expect(em.shouldRequireRepositorySignatureFor(isPrivate, manifest), c['result'],
          reason: 'signature case $i');
    }
  });

  test('config registration side effect exposes id extensions', () {
    final node = em.ensureConfigurationRegistered();
    expect(node, isNotNull);
    expect(node!.id, t['registeredConfigId']);
  });
}

// Mirrors the harness case arrays exactly.
const List<List<String>> _casesAll = [
  [TargetPlatform.WEB],
  [TargetPlatform.WIN32_X64],
  [TargetPlatform.WEB],
  [TargetPlatform.WEB],
  [TargetPlatform.WEB],
  [TargetPlatform.WEB],
  [TargetPlatform.WIN32_X64],
  [TargetPlatform.WIN32_X64],
];
const List<String> _casesProd = [
  TargetPlatform.WEB,
  TargetPlatform.WEB,
  TargetPlatform.WEB,
  TargetPlatform.WEB,
  TargetPlatform.WEB,
  TargetPlatform.WEB,
  TargetPlatform.WIN32_X64,
  TargetPlatform.WIN32_X64,
];
const List<String> _casesExt = [
  TargetPlatform.WIN32_X64,
  TargetPlatform.WIN32_X64,
  TargetPlatform.UNDEFINED,
  TargetPlatform.UNIVERSAL,
  TargetPlatform.UNKNOWN,
  TargetPlatform.WEB,
  TargetPlatform.WIN32_X64,
  TargetPlatform.WIN32_ARM64,
];

final List<Object?> _idCases = [
  null,
  null, // undefined
  1,
  'x',
  <String, Object?>{},
  <String, Object?>{'id': 'a.b'},
  <String, Object?>{'id': 'a.b', 'uuid': 'u'},
  <String, Object?>{'id': 'a.b', 'uuid': 5},
  <String, Object?>{'id': 5},
  <String, Object?>{'id': '', 'uuid': ''},
];

class _TestManifest implements IExtensionGalleryManifest {
  _TestManifest(this._capabilities);
  final Object? _capabilities;
  @override
  String get version => '1';
  @override
  List<ExtensionGalleryManifestResource> get resources => const [];
  @override
  Object? get capabilities => _capabilities;
}

// Manifest carriers: mirrors the harness stub objects (capabilities.signing).
final List<IExtensionGalleryManifest?> _sigManifest = [
  null,
  null,
  _TestManifest(<String, Object?>{}),
  _TestManifest(<String, Object?>{'signing': <String, Object?>{}}),
  _TestManifest(<String, Object?>{
    'signing': <String, Object?>{'allPrivateRepositorySigned': true}
  }),
  _TestManifest(<String, Object?>{
    'signing': <String, Object?>{'allPublicRepositorySigned': true}
  }),
  _TestManifest(<String, Object?>{
    'signing': <String, Object?>{'allPrivateRepositorySigned': true}
  }),
];
const List<bool> _sigPrivate = [true, false, true, true, true, false, false];
