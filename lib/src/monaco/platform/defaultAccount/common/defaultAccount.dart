// 1:1 port of vs/platform/defaultAccount/common/defaultAccount.ts
// Truth driven by tool/ts2dart/_batch92_truth.cjs (real TS module via vm).
// The TS file is almost entirely interfaces (erased at runtime); they are
// carried as Dart abstract classes for fidelity. Runtime surface: GitHubPaths,
// MANAGED_SETTINGS_UPDATE_REQUIRED_ERROR_CODE, IDefaultAccountService
// decorator, and the MANAGED_SETTINGS_FRESHNESS_NOT_REQUIRED re-export.
import '../../../base/common/defaultAccount.dart'
    show
        ICopilotTokenInfo,
        IDefaultAccount,
        IDefaultAccountAuthenticationProvider,
        IPolicyData;
import '../../../base/common/event.dart' show Event;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import '../../policy/common/managedSettingsFreshness.dart'
    show
        IManagedSettingsFreshness,
        MANAGED_SETTINGS_FRESHNESS_NOT_REQUIRED;

/// 1:1 re-export of `MANAGED_SETTINGS_FRESHNESS_NOT_REQUIRED`.
export '../../policy/common/managedSettingsFreshness.dart'
    show MANAGED_SETTINGS_FRESHNESS_NOT_REQUIRED;

/// 1:1: `GitHubPaths = {...} as const`
class GitHubPaths {
  static const String copilotSettings = 'settings/copilot/features';
  static const String billingBudgets =
      'settings/copilot/features?utm_source=vscode';
  static const String copilotUpgrade =
      'github-copilot/upgrade?utm_source=vscode';
  const GitHubPaths._();
}

/// 1:1: `ManagedSettingsFetchStatus = number | 'ok' | 'no-url' | 'no-response' | 'parse-error' | null`
typedef ManagedSettingsFetchStatus = Object?;

/// 1:1: `MANAGED_SETTINGS_UPDATE_REQUIRED_ERROR_CODE`
const String MANAGED_SETTINGS_UPDATE_REQUIRED_ERROR_CODE =
    'client_update_required';

/// 1:1: `interface IManagedSettingsCompatibilityError`
class IManagedSettingsCompatibilityError {
  final String errorCode;
  final String? clientVersion;
  final String? minimumClientVersion;
  IManagedSettingsCompatibilityError({
    required this.errorCode,
    this.clientVersion,
    this.minimumClientVersion,
  });
}

/// 1:1: `interface IDefaultAccountRefreshOptions`
class IDefaultAccountRefreshOptions {
  final bool? forceRefresh;
  final bool? refreshEntitlements;
  final bool? retryManagedSettings;
  IDefaultAccountRefreshOptions({
    this.forceRefresh,
    this.refreshEntitlements,
    this.retryManagedSettings,
  });
}

/// 1:1: `interface IDefaultAccountProvider`
abstract class IDefaultAccountProvider {
  IDefaultAccount? get defaultAccount;
  Event<IDefaultAccount?> get onDidChangeDefaultAccount;
  IPolicyData? get policyData;
  Event<IPolicyData?> get onDidChangePolicyData;
  ICopilotTokenInfo? get copilotTokenInfo;
  Event<ICopilotTokenInfo?> get onDidChangeCopilotTokenInfo;
  ManagedSettingsFetchStatus get managedSettingsFetchStatus;
  int? get managedSettingsFetchedAt;
  Object? get managedSettingsRawResponse;
  IManagedSettingsCompatibilityError? get managedSettingsCompatibilityError;
  Event<IManagedSettingsCompatibilityError?>
      get onDidChangeManagedSettingsCompatibilityError;
  IManagedSettingsFreshness get managedSettingsFreshness;
  Event<IManagedSettingsFreshness> get onDidChangeManagedSettingsFreshness;

  IDefaultAccountAuthenticationProvider
      getDefaultAccountAuthenticationProvider();
  String? resolveGitHubUrl(String path);
  Future<IDefaultAccount?> refresh([IDefaultAccountRefreshOptions? options]);
  Future<IDefaultAccount?> signIn([Object? options]);
  Future<void> signOut();
}

/// 1:1: `export const IDefaultAccountService = createDecorator(...)`
final ServiceIdentifier<IDefaultAccountServiceType> IDefaultAccountService =
    createDecorator<IDefaultAccountServiceType>('defaultAccountService');

/// 1:1: `interface IDefaultAccountService`
abstract class IDefaultAccountServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;
  Event<IDefaultAccount?> get onDidChangeDefaultAccount;
  Event<IPolicyData?> get onDidChangePolicyData;
  IPolicyData? get policyData;
  IDefaultAccount? get currentDefaultAccount;
  ICopilotTokenInfo? get copilotTokenInfo;
  Event<ICopilotTokenInfo?> get onDidChangeCopilotTokenInfo;
  ManagedSettingsFetchStatus get managedSettingsFetchStatus;
  int? get managedSettingsFetchedAt;
  Object? get managedSettingsRawResponse;
  IManagedSettingsCompatibilityError? get managedSettingsCompatibilityError;
  Event<IManagedSettingsCompatibilityError?>
      get onDidChangeManagedSettingsCompatibilityError;
  IManagedSettingsFreshness get managedSettingsFreshness;
  Event<IManagedSettingsFreshness> get onDidChangeManagedSettingsFreshness;

  Future<IDefaultAccount?> getDefaultAccount();
  IDefaultAccountAuthenticationProvider
      getDefaultAccountAuthenticationProvider();
  void setDefaultAccountProvider(IDefaultAccountProvider provider);
  Future<IDefaultAccount?> refresh([IDefaultAccountRefreshOptions? options]);
  Future<IDefaultAccount?> signIn([Object? options]);
  Future<void> signOut();
  String? resolveGitHubUrl(String path);
}

/// 1:1: re-export binding (identity carrier check supported in tests).
final IManagedSettingsFreshness reExportedFreshness =
    MANAGED_SETTINGS_FRESHNESS_NOT_REQUIRED;
