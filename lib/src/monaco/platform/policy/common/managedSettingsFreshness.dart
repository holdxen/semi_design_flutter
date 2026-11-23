// 1:1 port of vs/platform/policy/common/managedSettingsFreshness.ts
// Truth driven by tool/ts2dart/_batch91_truth.cjs (real TS module via vm).
// Mapping notes:
//   - `const enum` -> class + static const String (runtime values match truth).
//   - the TS discriminated union `IManagedSettingsFreshness` is carried by a
//     single class; `state` is the discriminant, other fields are optional and
//     populated per-variant (readonly -> final).
//   - the `ManagedSettingsChannel` import is type-only (erased).

/// 1:1: `const enum ManagedSettingsFreshnessState`
class ManagedSettingsFreshnessState {
  static const String NotRequired = 'notRequired';
  static const String Pending = 'pending';
  static const String Satisfied = 'satisfied';
  static const String Blocked = 'blocked';
  const ManagedSettingsFreshnessState._();
}

/// 1:1: `const enum ManagedSettingsFreshnessFailure`
class ManagedSettingsFreshnessFailure {
  static const String NoUrl = 'noUrl';
  static const String NoToken = 'noToken';
  static const String Network = 'network';
  static const String RateLimited = 'rateLimited';
  static const String HttpError = 'httpError';
  static const String Malformed = 'malformed';
  static const String UpdateRequired = 'updateRequired';
  const ManagedSettingsFreshnessFailure._();
}

/// 1:1: `interface IManagedSettingsFreshnessScope`
class IManagedSettingsFreshnessScope {
  final String accountId;
  final String authenticationProviderId;
  final String endpointOrigin;
  const IManagedSettingsFreshnessScope({
    required this.accountId,
    required this.authenticationProviderId,
    required this.endpointOrigin,
  });
}

/// 1:1 union carrier: `IManagedSettingsFreshness`.
/// `state` is the discriminant; other fields are populated per-variant.
class IManagedSettingsFreshness {
  final String state;
  final String? source;
  final IManagedSettingsFreshnessScope? scope;
  final int? lastAttemptAt;
  final int? satisfiedAt;
  final String? failure;
  final int? httpStatus;

  const IManagedSettingsFreshness._({
    required this.state,
    this.source,
    this.scope,
    this.lastAttemptAt,
    this.satisfiedAt,
    this.failure,
    this.httpStatus,
  });

  /// `{ readonly state: NotRequired }`
  const factory IManagedSettingsFreshness.notRequired() = _NotRequiredFreshness;

  /// `IManagedSettingsFreshnessEffective & { state: Pending }`
  factory IManagedSettingsFreshness.pending(
    String source, [
    IManagedSettingsFreshnessScope? scope,
    int? lastAttemptAt,
  ]) = _EffectiveFreshness;

  /// `Effective & { state: Satisfied; scope; satisfiedAt }`
  factory IManagedSettingsFreshness.satisfied(
    String source,
    IManagedSettingsFreshnessScope scope,
    int satisfiedAt, [
    int? lastAttemptAt,
  ]) = _SatisfiedFreshness;

  /// `Effective & { state: Blocked; failure; httpStatus? }`
  factory IManagedSettingsFreshness.blocked(
    String source,
    String failure, [
    int? httpStatus,
    IManagedSettingsFreshnessScope? scope,
    int? lastAttemptAt,
  ]) = _BlockedFreshness;
}

class _NotRequiredFreshness extends IManagedSettingsFreshness {
  const _NotRequiredFreshness()
      : super._(state: ManagedSettingsFreshnessState.NotRequired);
}

class _EffectiveFreshness extends IManagedSettingsFreshness {
  _EffectiveFreshness(String source, [scope, lastAttemptAt])
      : super._(
          state: ManagedSettingsFreshnessState.Pending,
          source: source,
          scope: scope,
          lastAttemptAt: lastAttemptAt,
        );
}

class _SatisfiedFreshness extends IManagedSettingsFreshness {
  _SatisfiedFreshness(String source, scope, satisfiedAt, [lastAttemptAt])
      : super._(
          state: ManagedSettingsFreshnessState.Satisfied,
          source: source,
          scope: scope,
          satisfiedAt: satisfiedAt,
          lastAttemptAt: lastAttemptAt,
        );
}

class _BlockedFreshness extends IManagedSettingsFreshness {
  _BlockedFreshness(String source, failure, [httpStatus, scope, lastAttemptAt])
      : super._(
          state: ManagedSettingsFreshnessState.Blocked,
          source: source,
          failure: failure,
          httpStatus: httpStatus,
          scope: scope,
          lastAttemptAt: lastAttemptAt,
        );
}

/// 1:1: `MANAGED_SETTINGS_FRESHNESS_NOT_REQUIRED`
const IManagedSettingsFreshness MANAGED_SETTINGS_FRESHNESS_NOT_REQUIRED =
    IManagedSettingsFreshness.notRequired();

/// 1:1: `isManagedSettingsFreshnessBlocking`
bool isManagedSettingsFreshnessBlocking(IManagedSettingsFreshness freshness) =>
    freshness.state == ManagedSettingsFreshnessState.Pending ||
    freshness.state == ManagedSettingsFreshnessState.Blocked;

/// 1:1: `isSameScope`
bool _isSameScope(
        IManagedSettingsFreshnessScope a, IManagedSettingsFreshnessScope b) =>
    a.accountId == b.accountId &&
    a.authenticationProviderId == b.authenticationProviderId &&
    a.endpointOrigin == b.endpointOrigin;

/// 1:1: `isManagedSettingsFreshnessSatisfiedFor`
bool isManagedSettingsFreshnessSatisfiedFor(
  IManagedSettingsFreshness freshness,
  IManagedSettingsFreshnessScope scope,
) {
  return freshness.state == ManagedSettingsFreshnessState.Satisfied &&
      _isSameScope(freshness.scope!, scope);
}
