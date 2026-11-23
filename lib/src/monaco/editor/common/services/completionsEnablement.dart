// 1:1 port of vs/editor/common/services/completionsEnablement.ts

import '../../../base/common/types.dart' show isObject;
import '../../../base/common/uri.dart' show URI;
import '../../../platform/configuration/common/configuration.dart'
    show IConfigurationServiceType;
import '../../../platform/product/common/product.dart' show product;
import 'textResourceConfiguration.dart' show ITextResourceConfigurationServiceType;

/// Source-internal `getCompletionsEnablementSettingName`.
String? _getCompletionsEnablementSettingName() {
  final Object? agent = product['defaultChatAgent'];
  if (agent is! Map) return null;
  final Object? setting = agent['completionsEnablementSetting'];
  return setting is String ? setting : null;
}

/// 1:1: `export function isCompletionsEnabled(configurationService, modeId = '*')`
bool isCompletionsEnabled(
  IConfigurationServiceType configurationService, [
  String modeId = '*',
]) {
  final String? settingName = _getCompletionsEnablementSettingName();
  if (settingName == null) return false;
  return isCompletionsEnabledFromObject(
      configurationService.getValue$1(settingName), modeId);
}

/// 1:1: `export function isCompletionsEnabledWithTextResourceConfig(...)`
bool isCompletionsEnabledWithTextResourceConfig(
  ITextResourceConfigurationServiceType configurationService,
  URI? resource, [
  String modeId = '*',
]) {
  final String? settingName = _getCompletionsEnablementSettingName();
  if (settingName == null) return false;
  return isCompletionsEnabledFromObject(
      configurationService.getValue$1(resource, settingName), modeId);
}

/// 1:1: `export function isCompletionsEnabledFromObject(obj, modeId = '*')`
bool isCompletionsEnabledFromObject(
  Object? completionsEnablementObject, [
  String modeId = '*',
]) {
  if (!isObject(completionsEnablementObject)) return false;
  final Map<dynamic, dynamic> object =
      completionsEnablementObject as Map<dynamic, dynamic>;
  // TS checks `typeof obj[modeId] !== 'undefined'`: an explicit `null` is
  // present and converts to false, while an absent key falls back to '*'.
  if (object.containsKey(modeId)) return _jsBoolean(object[modeId]);
  return _jsBoolean(object['*']);
}

bool _jsBoolean(Object? value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is num) return value != 0 && !value.isNaN;
  if (value is String) return value.isNotEmpty;
  return true;
}
