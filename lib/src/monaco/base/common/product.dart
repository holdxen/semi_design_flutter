// 1:1 port of vs/base/common/product.ts
// This file is entirely type-only in TS (zero runtime exports). Every
// interface/type is carried here 1:1 so downstream ports can reference it.
// `readonly` -> final, optional -> nullable, `IStringDictionary<V>` -> Map,
// unions -> Object?, `Omit<...>` -> the base type (Dart has no Omit).
import 'platform.dart' show PlatformName;
import 'policy.dart' show IExtensionConfigurationPolicyReference, IPolicy;

/// 1:1: `export interface IBuiltInExtension`
class IBuiltInExtension {
  final String name;
  final String version;
  final String repo;
  final Object? metadata;
  IBuiltInExtension({required this.name, required this.version, required this.repo, this.metadata});
}

/// 1:1: `export interface IProductWalkthrough`
class IProductWalkthrough {
  final String id;
  final List<IProductWalkthroughStep> steps;
  IProductWalkthrough({required this.id, required this.steps});
}

/// 1:1: `export interface IProductWalkthroughStep`
class IProductWalkthroughStep {
  final String id;
  final String title;
  final String when;
  final String description;
  final Object? media;
  IProductWalkthroughStep({required this.id, required this.title, required this.when, required this.description, this.media});
}

/// 1:1: `export interface IFeaturedExtension`
class IFeaturedExtension {
  final String id;
  final String title;
  final String description;
  final String imagePath;
  IFeaturedExtension({required this.id, required this.title, required this.description, required this.imagePath});
}

/// 1:1: `export interface IChatSessionRecommendation`
class IChatSessionRecommendation {
  final String extensionId;
  final String extensionName;
  final String displayName;
  final String name;
  final String description;
  final String? postInstallCommand;
  IChatSessionRecommendation({required this.extensionId, required this.extensionName, required this.displayName, required this.name, required this.description, this.postInstallCommand});
}

/// 1:1: `export type ConfigurationSyncStore`
class ConfigurationSyncStore {
  final String url;
  final String insidersUrl;
  final String stableUrl;
  final bool? canSwitch;
  final Map<String, List<String>> authenticationProviders;
  ConfigurationSyncStore({required this.url, required this.insidersUrl, required this.stableUrl, this.canSwitch, required this.authenticationProviders});
}

/// 1:1: `export type ExtensionUntrustedWorkspaceSupport`
class ExtensionUntrustedWorkspaceSupport {
  final Object? def; // default
  final Object? override;
  ExtensionUntrustedWorkspaceSupport({this.def, this.override});
}

/// 1:1: `export type ExtensionVirtualWorkspaceSupport`
class ExtensionVirtualWorkspaceSupport {
  final bool? def; // default
  final bool? override;
  ExtensionVirtualWorkspaceSupport({this.def, this.override});
}

/// 1:1: `export interface IAgentSdkProductConfig`
class IAgentSdkProductConfig {
  final String version;
  final String urlTemplate;
  IAgentSdkProductConfig({required this.version, required this.urlTemplate});
}

/// 1:1: `export interface IDictationRuntimeProductConfig`
class IDictationRuntimeProductConfig {
  final String version;
  final String urlTemplate;
  IDictationRuntimeProductConfig({required this.version, required this.urlTemplate});
}

/// 1:1: `export interface IProductConfiguration`
/// (all `readonly` fields, optional fields nullable)
class IProductConfiguration {
  final String version;
  final String? date;
  final String? quality;
  final String? commit;
  final String nameShort;
  final String nameLong;
  final String? win32AppUserModelId;
  final String? win32MutexName;
  final String? win32SetupMutexName;
  final String? win32RegValueName;
  final String? win32NameVersion;
  final bool? win32VersionedUpdate;
  final Map<String, Map<String, String>>? win32ContextMenu;
  final String applicationName;
  final String? linuxDesktopName;
  final String? embedderIdentifier;
  final String? agentsTelemetryAppName;
  final String urlProtocol;
  final String dataFolderName;
  final String sharedDataFolderName;
  final List<IBuiltInExtension>? builtInExtensions;
  final List<IProductWalkthrough>? walkthroughMetadata;
  final List<IFeaturedExtension>? featuredExtensions;
  final String? downloadUrl;
  final String? updateUrl;
  final String? webUrl;
  final String? webEndpointUrlTemplate;
  final String? webviewContentExternalBaseUrlTemplate;
  final String? target;
  final String? nlsCoreBaseUrl;
  final String? nlsMetadataHash;
  final int? settingsSearchBuildId;
  final String? settingsSearchUrl;
  final Map<String, Object?>? tasConfig;
  final Map<String, Object?>? extensionsGallery;
  final Map<String, IAgentSdkProductConfig>? agentSdks;
  final Map<String, Object?>? copilotVersions;
  final IDictationRuntimeProductConfig? dictationRuntime;
  final Map<String, Object?>? mcpGallery;
  final List<String>? extensionPublisherOrgs;
  final List<String>? trustedExtensionPublishers;
  final Map<String, IExtensionRecommendations>? extensionRecommendations;
  final Map<String, Object?>? connectorRecommendations;
  final Map<String, IConfigBasedExtensionTip>? configBasedExtensionTips;
  final Map<String, IExeBasedExtensionTip>? exeBasedExtensionTips;
  final Map<String, IRemoteExtensionTip>? remoteExtensionTips;
  final Map<String, IVirtualWorkspaceExtensionTip>? virtualWorkspaceExtensionTips;
  final Map<String, List<String>>? extensionKeywords;
  final List<String>? keymapExtensionTips;
  final List<String>? webExtensionTips;
  final List<String>? languageExtensionTips;
  final Map<String, List<String>>? trustedExtensionUrlPublicKeys;
  final Object? trustedExtensionAuthAccess; // string[] | IStringDictionary<string[]>
  final Object? trustedMcpAuthAccess;
  final Map<String, List<String>>? inheritAuthAccountPreference;
  final List<String>? trustedExtensionProtocolHandlers;
  final List<String>? commandPaletteSuggestedCommandIds;
  final Map<String, Object?>? crashReporter;
  final bool? removeTelemetryMachineId;
  final Map<String, bool>? enabledTelemetryLevels;
  final bool? enableTelemetry;
  final bool? openToWelcomeMainPage;
  final Map<String, Object?>? aiConfig;
  final String? documentationUrl;
  final String? serverDocumentationUrl;
  final String? releaseNotesUrl;
  final String? keyboardShortcutsUrlMac;
  final String? keyboardShortcutsUrlLinux;
  final String? keyboardShortcutsUrlWin;
  final String? introductoryVideosUrl;
  final String? tipsAndTricksUrl;
  final String? newsletterSignupUrl;
  final String? youTubeUrl;
  final String? requestFeatureUrl;
  final String? reportIssueUrl;
  final String? reportMarketplaceIssueUrl;
  final String? licenseUrl;
  final String? serverLicenseUrl;
  final String? privacyStatementUrl;
  final bool? showTelemetryOptOut;
  final List<String>? serverGreeting;
  final List<String>? serverLicense;
  final String? serverLicensePrompt;
  final String serverApplicationName;
  final String? serverDataFolderName;
  final String? tunnelApplicationName;
  final ITunnelApplicationConfig? tunnelApplicationConfig;
  final String? npsSurveyUrl;
  final List<ISurveyData>? surveys;
  final Map<String, String>? checksums;
  final String? checksumFailMoreInfoUrl;
  final IAppCenterConfiguration? appCenter;
  final String? portable;
  final Map<String, List<String>>? extensionKind;
  final Map<String, List<String>>? extensionPointExtensionKind;
  final Map<String, List<String>>? extensionSyncedKeys;
  final Map<String, List<String>>? extensionEnabledApiProposals;
  final Map<String, ExtensionUntrustedWorkspaceSupport>? extensionUntrustedWorkspaceSupport;
  final Map<String, ExtensionVirtualWorkspaceSupport>? extensionVirtualWorkspacesSupport;
  final Map<String, Map<String, Object?>> extensionProperties;
  final List<String>? extensionsForceVersionByQuality;
  final List<String> builtInExtensionsEnabledWithAutoUpdates;
  final List<String>? sessionsWindowAllowedExtensions;
  final List<String>? msftInternalDomains;
  final List<String>? linkProtectionTrustedDomains;
  final String? authClientIdMetadataUrl;
  final ConfigurationSyncStore? configurationSyncStore; // 'configurationSync.store'
  final Object? editSessionsStore; // Omit<ConfigurationSyncStore, ...>
  final String? darwinUniversalAssetId;
  final String? darwinBundleIdentifier;
  final String? profileTemplatesUrl;
  final List<String>? commonlyUsedSettings;
  final IAiGeneratedWorkspaceTrust? aiGeneratedWorkspaceTrust;
  final IDefaultChatAgent defaultChatAgent;
  final String? chatParticipantRegistry;
  final List<IChatSessionRecommendation>? chatSessionRecommendations;
  final String? emergencyAlertUrl;
  final String? voiceWsUrl;
  final List<String>? remoteDefaultExtensionsIfInstalledLocally;
  final Map<String, Object?>? extensionConfigurationPolicy; // IPolicy | reference
  final List<IProductOnboardingKeymap>? onboardingKeymaps;
  final List<IProductOnboardingTheme>? onboardingThemes;
  final Map<String, Object?>? parentPolicyConfig;

  IProductConfiguration({
    required this.version, this.date, this.quality, this.commit,
    required this.nameShort, required this.nameLong,
    this.win32AppUserModelId, this.win32MutexName, this.win32SetupMutexName,
    this.win32RegValueName, this.win32NameVersion, this.win32VersionedUpdate,
    this.win32ContextMenu, required this.applicationName, this.linuxDesktopName,
    this.embedderIdentifier, this.agentsTelemetryAppName,
    required this.urlProtocol, required this.dataFolderName, required this.sharedDataFolderName,
    this.builtInExtensions, this.walkthroughMetadata, this.featuredExtensions,
    this.downloadUrl, this.updateUrl, this.webUrl, this.webEndpointUrlTemplate,
    this.webviewContentExternalBaseUrlTemplate, this.target, this.nlsCoreBaseUrl,
    this.nlsMetadataHash, this.settingsSearchBuildId, this.settingsSearchUrl,
    this.tasConfig, this.extensionsGallery, this.agentSdks, this.copilotVersions,
    this.dictationRuntime, this.mcpGallery, this.extensionPublisherOrgs,
    this.trustedExtensionPublishers, this.extensionRecommendations,
    this.connectorRecommendations, this.configBasedExtensionTips,
    this.exeBasedExtensionTips, this.remoteExtensionTips,
    this.virtualWorkspaceExtensionTips, this.extensionKeywords,
    this.keymapExtensionTips, this.webExtensionTips, this.languageExtensionTips,
    this.trustedExtensionUrlPublicKeys, this.trustedExtensionAuthAccess,
    this.trustedMcpAuthAccess, this.inheritAuthAccountPreference,
    this.trustedExtensionProtocolHandlers, this.commandPaletteSuggestedCommandIds,
    this.crashReporter, this.removeTelemetryMachineId, this.enabledTelemetryLevels,
    this.enableTelemetry, this.openToWelcomeMainPage, this.aiConfig,
    this.documentationUrl, this.serverDocumentationUrl, this.releaseNotesUrl,
    this.keyboardShortcutsUrlMac, this.keyboardShortcutsUrlLinux,
    this.keyboardShortcutsUrlWin, this.introductoryVideosUrl, this.tipsAndTricksUrl,
    this.newsletterSignupUrl, this.youTubeUrl, this.requestFeatureUrl,
    this.reportIssueUrl, this.reportMarketplaceIssueUrl, this.licenseUrl,
    this.serverLicenseUrl, this.privacyStatementUrl, this.showTelemetryOptOut,
    this.serverGreeting, this.serverLicense, this.serverLicensePrompt,
    required this.serverApplicationName, this.serverDataFolderName,
    this.tunnelApplicationName, this.tunnelApplicationConfig, this.npsSurveyUrl,
    this.surveys, this.checksums, this.checksumFailMoreInfoUrl, this.appCenter,
    this.portable, this.extensionKind, this.extensionPointExtensionKind,
    this.extensionSyncedKeys, this.extensionEnabledApiProposals,
    this.extensionUntrustedWorkspaceSupport, this.extensionVirtualWorkspacesSupport,
    required this.extensionProperties, this.extensionsForceVersionByQuality,
    required this.builtInExtensionsEnabledWithAutoUpdates,
    this.sessionsWindowAllowedExtensions, this.msftInternalDomains,
    this.linkProtectionTrustedDomains, this.authClientIdMetadataUrl,
    this.configurationSyncStore, this.editSessionsStore, this.darwinUniversalAssetId,
    this.darwinBundleIdentifier, this.profileTemplatesUrl, this.commonlyUsedSettings,
    this.aiGeneratedWorkspaceTrust, required this.defaultChatAgent,
    this.chatParticipantRegistry, this.chatSessionRecommendations,
    this.emergencyAlertUrl, this.voiceWsUrl,
    this.remoteDefaultExtensionsIfInstalledLocally, this.extensionConfigurationPolicy,
    this.onboardingKeymaps, this.onboardingThemes, this.parentPolicyConfig,
  });
}

/// 1:1: `export interface IProductOnboardingKeymap`
class IProductOnboardingKeymap {
  final String id;
  final String label;
  final String? extensionId;
  final String description;
  IProductOnboardingKeymap({required this.id, required this.label, this.extensionId, required this.description});
}

/// 1:1: `export interface IProductOnboardingTheme`
class IProductOnboardingTheme {
  final String id;
  final String label;
  final String themeId;
  final String type; // 'dark' | 'light' | 'hcDark' | 'hcLight'
  IProductOnboardingTheme({required this.id, required this.label, required this.themeId, required this.type});
}

/// 1:1: `export interface ITunnelApplicationConfig`
class ITunnelApplicationConfig {
  final Map<String, List<String>> authenticationProviders;
  final String editorWebUrl;
  final IRemoteExtensionTip extension;
  ITunnelApplicationConfig({required this.authenticationProviders, required this.editorWebUrl, required this.extension});
}

/// 1:1: `export interface IExtensionRecommendations`
class IExtensionRecommendations {
  final List<IFileOpenCondition> onFileOpen;
  final ISettingsEditorOpenCondition? onSettingsEditorOpen;
  IExtensionRecommendations({required this.onFileOpen, this.onSettingsEditorOpen});
}

/// 1:1: `export interface ISettingsEditorOpenCondition`
class ISettingsEditorOpenCondition {
  final Object? prerelease; // boolean | string
  final String? descriptionOverride;
  ISettingsEditorOpenCondition({this.prerelease, this.descriptionOverride});
}

/// 1:1: `export interface IExtensionRecommendationCondition`
class IExtensionRecommendationCondition {
  final bool? important;
  final List<String>? whenInstalled;
  final List<String>? whenNotInstalled;
  IExtensionRecommendationCondition({this.important, this.whenInstalled, this.whenNotInstalled});
}

/// 1:1: `export type IFileOpenCondition = IFileLanguageCondition | IFilePathCondition | IFileContentCondition`
typedef IFileOpenCondition = Object;

/// 1:1: `export interface IFileLanguageCondition`
class IFileLanguageCondition {
  final List<String> languages;
  final bool? important;
  final List<String>? whenInstalled;
  final List<String>? whenNotInstalled;
  IFileLanguageCondition({required this.languages, this.important, this.whenInstalled, this.whenNotInstalled});
}

/// 1:1: `export interface IFilePathCondition`
class IFilePathCondition {
  final String pathGlob;
  final bool? important;
  final List<String>? whenInstalled;
  final List<String>? whenNotInstalled;
  IFilePathCondition({required this.pathGlob, this.important, this.whenInstalled, this.whenNotInstalled});
}

/// 1:1: `export type IFileContentCondition = (IFileLanguageCondition | IFilePathCondition) & { contentPattern: string }`
class IFileContentCondition {
  final String contentPattern;
  final List<String>? languages;
  final String? pathGlob;
  final bool? important;
  final List<String>? whenInstalled;
  final List<String>? whenNotInstalled;
  IFileContentCondition({required this.contentPattern, this.languages, this.pathGlob, this.important, this.whenInstalled, this.whenNotInstalled});
}

/// 1:1: `export interface IAppCenterConfiguration`
class IAppCenterConfiguration {
  final String win32x64;
  final String win32arm64;
  final String linuxx64;
  final String darwin;
  final String darwinUniversal;
  final String darwinarm64;
  IAppCenterConfiguration({required this.win32x64, required this.win32arm64, required this.linuxx64, required this.darwin, required this.darwinUniversal, required this.darwinarm64});
}

/// 1:1: `export interface IConfigBasedExtensionTip`
class IConfigBasedExtensionTip {
  final String configPath;
  final String configName;
  final String? configScheme;
  final Map<String, Map<String, Object?>> recommendations;
  IConfigBasedExtensionTip({required this.configPath, required this.configName, this.configScheme, required this.recommendations});
}

/// 1:1: `export interface IExeBasedExtensionTip`
class IExeBasedExtensionTip {
  final String friendlyName;
  final String? windowsPath;
  final bool? important;
  final Map<String, Map<String, Object?>> recommendations;
  IExeBasedExtensionTip({required this.friendlyName, this.windowsPath, this.important, required this.recommendations});
}

/// 1:1: `export interface IRemoteExtensionTip`
class IRemoteExtensionTip {
  final String friendlyName;
  final String extensionId;
  final List<PlatformName>? supportedPlatforms;
  final Map<String, Object?>? startEntry;
  IRemoteExtensionTip({required this.friendlyName, required this.extensionId, this.supportedPlatforms, this.startEntry});
}

/// 1:1: `export interface IVirtualWorkspaceExtensionTip`
class IVirtualWorkspaceExtensionTip {
  final String friendlyName;
  final String extensionId;
  final List<PlatformName>? supportedPlatforms;
  final Map<String, Object?> startEntry;
  IVirtualWorkspaceExtensionTip({required this.friendlyName, required this.extensionId, this.supportedPlatforms, required this.startEntry});
}

/// 1:1: `export interface ISurveyData`
class ISurveyData {
  final String surveyId;
  final String surveyUrl;
  final String languageId;
  final int editCount;
  final num userProbability;
  ISurveyData({required this.surveyId, required this.surveyUrl, required this.languageId, required this.editCount, required this.userProbability});
}

/// 1:1: `export interface IAiGeneratedWorkspaceTrust`
class IAiGeneratedWorkspaceTrust {
  final String title;
  final String checkboxText;
  final String trustOption;
  final String dontTrustOption;
  final String startupTrustRequestLearnMore;
  IAiGeneratedWorkspaceTrust({required this.title, required this.checkboxText, required this.trustOption, required this.dontTrustOption, required this.startupTrustRequestLearnMore});
}

/// 1:1: `export interface IDefaultChatAgent`
class IDefaultChatAgent {
  final String extensionId;
  final String chatExtensionId;
  final String chatExtensionOutputId;
  final String chatExtensionOutputExtensionStateCommand;
  final String documentationUrl;
  final String skusDocumentationUrl;
  final String optimizeUsageDocumentationUrl;
  final String publicCodeMatchesUrl;
  final String managePlanUrl;
  final String upgradePlanUrl;
  final String signUpUrl;
  final String termsStatementUrl;
  final String privacyStatementUrl;
  final Map<String, Map<String, String>> provider;
  final String providerExtensionId;
  final String providerUriSetting;
  final List<List<String>> providerScopes;
  final String entitlementUrl;
  final String entitlementSignupLimitedUrl;
  final String tokenEntitlementUrl;
  final String mcpRegistryDataUrl;
  final String? mcpConnectorsUrl;
  final String managedSettingsUrl;
  final String chatQuotaExceededContext;
  final String completionsQuotaExceededContext;
  final String walkthroughCommand;
  final String completionsMenuCommand;
  final String chatRefreshTokenCommand;
  final String generateCommitMessageCommand;
  final String resolveMergeConflictsCommand;
  final String completionsAdvancedSetting;
  final String completionsEnablementSetting;
  final String nextEditSuggestionsSetting;
  IDefaultChatAgent({
    required this.extensionId, required this.chatExtensionId,
    required this.chatExtensionOutputId, required this.chatExtensionOutputExtensionStateCommand,
    required this.documentationUrl, required this.skusDocumentationUrl,
    required this.optimizeUsageDocumentationUrl, required this.publicCodeMatchesUrl,
    required this.managePlanUrl, required this.upgradePlanUrl, required this.signUpUrl,
    required this.termsStatementUrl, required this.privacyStatementUrl,
    required this.provider, required this.providerExtensionId, required this.providerUriSetting,
    required this.providerScopes, required this.entitlementUrl,
    required this.entitlementSignupLimitedUrl, required this.tokenEntitlementUrl,
    required this.mcpRegistryDataUrl, this.mcpConnectorsUrl, required this.managedSettingsUrl,
    required this.chatQuotaExceededContext, required this.completionsQuotaExceededContext,
    required this.walkthroughCommand, required this.completionsMenuCommand,
    required this.chatRefreshTokenCommand, required this.generateCommitMessageCommand,
    required this.resolveMergeConflictsCommand, required this.completionsAdvancedSetting,
    required this.completionsEnablementSetting, required this.nextEditSuggestionsSetting,
  });
}

/// Bridges for the imported policy types (used by product.json-derived data).
/// Re-exported aliases keep the TS names available to downstream ports.
typedef ProductPolicy = IPolicy;
typedef ProductPolicyReference = IExtensionConfigurationPolicyReference;
