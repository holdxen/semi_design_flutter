// 1:1 port of vs/base/common/defaultAccount.ts
// This file is type-only in TS (all `interface`s, erased at runtime). The
// interfaces are carried as Dart classes/typedefs for fidelity; no runtime
// behavior exists in the TS source.

/// 1:1: `export interface IQuotaSnapshotData`
class IQuotaSnapshotData {
  final num overage_count;
  final num overage_entitlement;
  final bool overage_permitted;
  final num? credits_used;
  final num percent_remaining;
  final bool unlimited;
  final num? quota_reset_at;
  final bool? token_based_billing;
  final String? entitlement;
  final num? quota_remaining;
  final bool? has_quota;

  IQuotaSnapshotData({
    required this.overage_count,
    required this.overage_entitlement,
    required this.overage_permitted,
    this.credits_used,
    required this.percent_remaining,
    required this.unlimited,
    this.quota_reset_at,
    this.token_based_billing,
    this.entitlement,
    this.quota_remaining,
    this.has_quota,
  });
}

/// 1:1: `export interface ILegacyQuotaSnapshotData`
class ILegacyQuotaSnapshotData {
  final ILegacyQuotas? limited_user_quotas;
  final ILegacyQuotas? monthly_quotas;

  ILegacyQuotaSnapshotData({this.limited_user_quotas, this.monthly_quotas});
}

/// 1:1: nested `{ chat: number; completions: number }` of ILegacyQuotaSnapshotData
class ILegacyQuotas {
  final num chat;
  final num completions;
  ILegacyQuotas(this.chat, this.completions);
}

/// 1:1: `export interface IEntitlementsData extends ILegacyQuotaSnapshotData`
class IEntitlementsData {
  final String access_type_sku;
  final bool chat_enabled;
  final String assigned_date;
  final bool can_signup_for_limited;
  final String copilot_plan;
  final List<String> organization_login_list;
  final bool? is_staff;
  final String analytics_tracking_id;
  final String? limited_user_reset_date; // for Copilot Free
  final String? quota_reset_date; // for all other Copilot SKUs
  final String? quota_reset_date_utc; // for all other Copilot SKUs (includes time)
  final bool? token_based_billing;
  final bool? can_upgrade_plan;
  final bool? cloud_sessions_enabled;
  final bool? cloud_session_storage_enabled;
  final IQuotaSnapshots? quota_snapshots;
  final Map<String, String>? endpoints;

  // inherited from ILegacyQuotaSnapshotData
  final ILegacyQuotas? limited_user_quotas;
  final ILegacyQuotas? monthly_quotas;

  IEntitlementsData({
    required this.access_type_sku,
    required this.chat_enabled,
    required this.assigned_date,
    required this.can_signup_for_limited,
    required this.copilot_plan,
    required this.organization_login_list,
    this.is_staff,
    required this.analytics_tracking_id,
    this.limited_user_reset_date,
    this.quota_reset_date,
    this.quota_reset_date_utc,
    this.token_based_billing,
    this.can_upgrade_plan,
    this.cloud_sessions_enabled,
    this.cloud_session_storage_enabled,
    this.quota_snapshots,
    this.endpoints,
    this.limited_user_quotas,
    this.monthly_quotas,
  });
}

/// 1:1: `quota_snapshots` nested record of IEntitlementsData
class IQuotaSnapshots {
  final IQuotaSnapshotData? chat;
  final IQuotaSnapshotData? completions;
  final IQuotaSnapshotData? premium_interactions;
  IQuotaSnapshots({this.chat, this.completions, this.premium_interactions});
}

/// 1:1: `export interface IPolicyData`
class IPolicyData {
  final bool? mcp;
  final bool? chat_preview_features_enabled;
  final bool? chat_agent_enabled;
  final bool? cloud_session_storage_enabled;
  final String? mcpRegistryUrl;
  final String? mcpAccess; // 'allow_all' | 'registry_only'
  final Map<String, Object?>? managedSettings;
  final bool? managedSettingsActive;

  IPolicyData({
    this.mcp,
    this.chat_preview_features_enabled,
    this.chat_agent_enabled,
    this.cloud_session_storage_enabled,
    this.mcpRegistryUrl,
    this.mcpAccess,
    this.managedSettings,
    this.managedSettingsActive,
  });
}

/// 1:1: `export interface ICopilotTokenInfo`
class ICopilotTokenInfo {
  final String? sn;
  final String? fcv1;
  final String? st;
  ICopilotTokenInfo({this.sn, this.fcv1, this.st});
}

/// 1:1: `export interface IDefaultAccountAuthenticationProvider`
class IDefaultAccountAuthenticationProvider {
  final String id;
  final String name;
  final bool enterprise;
  IDefaultAccountAuthenticationProvider(this.id, this.name, this.enterprise);
}

/// 1:1: `export interface IDefaultAccount`
class IDefaultAccount {
  final IDefaultAccountAuthenticationProvider authenticationProvider;
  final String accountName;
  final String sessionId;
  final bool enterprise;
  final IEntitlementsData? entitlementsData;

  IDefaultAccount({
    required this.authenticationProvider,
    required this.accountName,
    required this.sessionId,
    required this.enterprise,
    this.entitlementsData,
  });
}
