// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/userDataProfile/common/userDataProfile.ts
// Translated 1:1 from TypeScript.
//   - TS interfaces with `readonly` fields that the source mutates through
//     `Mutable<T>` are carried by UserDataProfileCarrier (getter + setter).
//   - protected members become public Dart members so cross-library subclasses
//     can override them (the TS `protected` keyword has no Dart equivalent).
//   - fileService methods absent from IFileServiceType are called via dynamic,
//     preserving the source call sequence and error handling.
// ---------------------------------------------------------------------------

import '../../../base/common/async.dart' as async;
import '../../../base/common/errors.dart' as errors;
import '../../../base/common/event.dart' as event;
import '../../../base/common/hash.dart' as hashes;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../../base/common/resources.dart' as resources;
import '../../../base/common/strings.dart' as strings;
import '../../../base/common/types.dart' as types;
import '../../../base/common/uri.dart' as uri;
import '../../../base/common/uuid.dart' as uuid;
import '../../../nls.dart' show localize;
import '../../environment/common/environment.dart' as environment;
import '../../files/common/files.dart' as files;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import '../../log/common/log.dart' as log;
import '../../uriIdentity/common/uriIdentity.dart' as uriIdentity;
import '../../workspace/common/workspace.dart' as workspace;

/// 1:1: `export const AGENTS_WINDOW_PROFILE_ID = 'agents'`
const String AGENTS_WINDOW_PROFILE_ID = 'agents';

/// 1:1: TS object literal carried as a Dart class.
class _AgentsWindowProfileFlags {
  const _AgentsWindowProfileFlags();

  static const Map<String, bool> flags = <String, bool>{
    'settings': true,
    'keybindings': true,
    'prompts': true,
    'mcp': true,
    'languageModels': true,
    'snippets': true,
    'tasks': true,
    'extensions': true,
  };
}

/// 1:1: `export const enum ProfileResourceType`
class ProfileResourceType {
  static const String Settings = 'settings';
  static const String Keybindings = 'keybindings';
  static const String Snippets = 'snippets';
  static const String Prompts = 'prompts';
  static const String Tasks = 'tasks';
  static const String Extensions = 'extensions';
  static const String GlobalState = 'globalState';
  static const String Mcp = 'mcp';
  static const String LanguageModels = 'languageModels';
}

/// 1:1: `export type UseDefaultProfileFlags`
typedef UseDefaultProfileFlags = Map<String, Object?>;

/// 1:1: `export type ProfileResourceTypeFlags = UseDefaultProfileFlags`
typedef ProfileResourceTypeFlags = UseDefaultProfileFlags;

/// 1:1: `export type SettingValue`
typedef SettingValue = Object?;

/// 1:1: `export type ISettingsDictionary = Record<string, SettingValue>`
typedef ISettingsDictionary = Map<String, SettingValue>;

/// 1:1: `export interface IUserDataProfile`
abstract class IUserDataProfile {
  String get id;
  bool get isDefault;
  String get name;
  String? get icon;
  uri.URI get location;
  uri.URI get globalStorageHome;
  uri.URI get settingsResource;
  uri.URI get keybindingsResource;
  uri.URI get tasksResource;
  uri.URI get snippetsHome;
  uri.URI get promptsHome;
  uri.URI get extensionsResource;
  uri.URI get mcpResource;
  uri.URI get languageModelsResource;
  uri.URI get agentPluginsHome;
  uri.URI get cacheHome;
  UseDefaultProfileFlags? get useDefaultFlags;
  bool? get isInternal;
  bool? get isTransient;
  bool? get isAgentsWindowProfile;
  List<uri.URI>? get workspaces;
  set workspaces(List<uri.URI>? value);
}

/// Mutable carrier for TS `Mutable<IUserDataProfile>` writes.
class UserDataProfileCarrier implements IUserDataProfile {
  UserDataProfileCarrier({
    required this.id,
    required this.isDefault,
    required this.name,
    this.icon,
    required this.location,
    required this.globalStorageHome,
    required this.settingsResource,
    required this.keybindingsResource,
    required this.tasksResource,
    required this.snippetsHome,
    required this.promptsHome,
    required this.extensionsResource,
    required this.mcpResource,
    required this.languageModelsResource,
    required this.agentPluginsHome,
    required this.cacheHome,
    this.useDefaultFlags,
    this.isInternal,
    this.isTransient,
    this.isAgentsWindowProfile,
    this.workspaces,
  });

  @override
  final String id;

  @override
  bool isDefault;

  @override
  String name;

  @override
  String? icon;

  @override
  final uri.URI location;

  @override
  final uri.URI globalStorageHome;

  @override
  final uri.URI settingsResource;

  @override
  final uri.URI keybindingsResource;

  @override
  final uri.URI tasksResource;

  @override
  final uri.URI snippetsHome;

  @override
  final uri.URI promptsHome;

  @override
  final uri.URI extensionsResource;

  @override
  final uri.URI mcpResource;

  @override
  final uri.URI languageModelsResource;

  @override
  final uri.URI agentPluginsHome;

  @override
  final uri.URI cacheHome;

  @override
  final UseDefaultProfileFlags? useDefaultFlags;

  @override
  final bool? isInternal;

  @override
  bool? isTransient;

  @override
  final bool? isAgentsWindowProfile;

  @override
  List<uri.URI>? workspaces;

  UserDataProfileCarrier copyWith({
    String? name,
    String? icon,
    bool? isDefault,
    bool? isTransient,
    UseDefaultProfileFlags? useDefaultFlags,
    uri.URI? extensionsResource,
    List<uri.URI>? workspaces,
  }) {
    return UserDataProfileCarrier(
      id: id,
      isDefault: isDefault ?? this.isDefault,
      name: name ?? this.name,
      icon: icon,
      location: location,
      globalStorageHome: globalStorageHome,
      settingsResource: settingsResource,
      keybindingsResource: keybindingsResource,
      tasksResource: tasksResource,
      snippetsHome: snippetsHome,
      promptsHome: promptsHome,
      extensionsResource: extensionsResource ?? this.extensionsResource,
      mcpResource: mcpResource,
      languageModelsResource: languageModelsResource,
      agentPluginsHome: agentPluginsHome,
      cacheHome: cacheHome,
      useDefaultFlags: useDefaultFlags ?? this.useDefaultFlags,
      isInternal: isInternal,
      isTransient: isTransient ?? this.isTransient,
      isAgentsWindowProfile: isAgentsWindowProfile,
      workspaces: workspaces ?? this.workspaces,
    );
  }
}

/// 1:1: `export function isUserDataProfile(thing: unknown): thing is IUserDataProfile`
bool isUserDataProfile(Object? thing) {
  if (thing == null) return false;
  final dynamic candidate = thing;
  try {
    return candidate.id is String &&
        candidate.isDefault is bool &&
        candidate.name is String &&
        uri.URI.isUri(candidate.location) &&
        uri.URI.isUri(candidate.globalStorageHome) &&
        uri.URI.isUri(candidate.settingsResource) &&
        uri.URI.isUri(candidate.keybindingsResource) &&
        uri.URI.isUri(candidate.tasksResource) &&
        uri.URI.isUri(candidate.snippetsHome) &&
        uri.URI.isUri(candidate.promptsHome) &&
        uri.URI.isUri(candidate.extensionsResource) &&
        uri.URI.isUri(candidate.mcpResource) &&
        uri.URI.isUri(candidate.languageModelsResource) &&
        uri.URI.isUri(candidate.agentPluginsHome);
  } catch (_) {
    return false;
  }
}

/// 1:1: `export interface IParsedUserDataProfileTemplate`
abstract class IParsedUserDataProfileTemplate {
  String get name;
  String? get icon;
  ISettingsDictionary? get settings;
  Map<String, String>? get globalState;
}

/// 1:1: `export interface ISystemProfileTemplate`
abstract class ISystemProfileTemplate implements IParsedUserDataProfileTemplate {
  String get id;
}

/// 1:1: `export type DidChangeProfilesEvent`
class DidChangeProfilesEvent {
  DidChangeProfilesEvent({required this.added, required this.removed,
      required this.updated, required this.all});

  final List<IUserDataProfile> added;
  final List<IUserDataProfile> removed;
  final List<IUserDataProfile> updated;
  final List<IUserDataProfile> all;
}

/// 1:1: `export type WillCreateProfileEvent`
class WillCreateProfileEvent {
  WillCreateProfileEvent({required this.profile, required this.join});

  final IUserDataProfile profile;
  final void Function(Future<void> promise) join;
}

/// 1:1: `export type WillRemoveProfileEvent`
class WillRemoveProfileEvent {
  WillRemoveProfileEvent({required this.profile, required this.join});

  final IUserDataProfile profile;
  final void Function(Future<void> promise) join;
}

/// 1:1: `export interface IUserDataProfileOptions`
abstract class IUserDataProfileOptions {
  String? get icon;
  UseDefaultProfileFlags? get useDefaultFlags;
  bool? get transient;
  List<uri.URI>? get workspaces;
}

/// Plain carrier for TS `IUserDataProfileOptions` object literals.
class UserDataProfileOptions implements IUserDataProfileOptions {
  UserDataProfileOptions({this.icon, this.useDefaultFlags, this.transient,
      this.workspaces});

  @override
  final String? icon;
  @override
  final UseDefaultProfileFlags? useDefaultFlags;
  @override
  final bool? transient;
  @override
  final List<uri.URI>? workspaces;
}

/// JS `undefined` carrier for optional update fields.
const Object _jsUndefined = Object();

/// 1:1: `export interface IUserDataProfileUpdateOptions`
abstract class IUserDataProfileUpdateOptions {
  String? get name;
  Object? get icon;
  bool? get transient;
  UseDefaultProfileFlags? get useDefaultFlags;
  List<uri.URI>? get workspaces;
}

/// Plain carrier for TS `IUserDataProfileUpdateOptions` object literals.
class UserDataProfileUpdateOptions implements IUserDataProfileUpdateOptions {
  UserDataProfileUpdateOptions({this.name, this.icon = _jsUndefined,
      this.transient, this.useDefaultFlags, this.workspaces});

  @override
  final String? name;
  @override
  final Object? icon;
  @override
  final bool? transient;
  @override
  final UseDefaultProfileFlags? useDefaultFlags;
  @override
  final List<uri.URI>? workspaces;
}

/// 1:1: `export const IUserDataProfilesService`
final ServiceIdentifier<IUserDataProfilesServiceType> IUserDataProfilesService =
    createDecorator<IUserDataProfilesServiceType>('IUserDataProfilesService');

/// 1:1: `export interface IUserDataProfilesService`
abstract class IUserDataProfilesServiceType {
  Object? get _serviceBrand;
  uri.URI get profilesHome;
  IUserDataProfile get defaultProfile;
  event.Event<DidChangeProfilesEvent> get onDidChangeProfiles;
  List<IUserDataProfile> get profiles;
  event.Event<void> get onDidResetWorkspaces;
  Future<IUserDataProfile> createNamedProfile(String name,
      [IUserDataProfileOptions? options, Object? workspaceIdentifier]);
  Future<IUserDataProfile> createTransientProfile([Object? workspaceIdentifier]);
  Future<IUserDataProfile> createProfile(String id, String name,
      [IUserDataProfileOptions? options, Object? workspaceIdentifier]);
  Future<IUserDataProfile> updateProfile(IUserDataProfile profile,
      [IUserDataProfileUpdateOptions? options]);
  Future<void> removeProfile(IUserDataProfile profile);
  Future<void> setProfileForWorkspace(Object workspaceIdentifier,
      IUserDataProfile profile);
  Future<void> resetWorkspaces();
  Future<void> cleanUp();
  Future<void> cleanUpTransientProfiles();
}

/// 1:1: `export function reviveProfile`
IUserDataProfile reviveProfile(Object? profile, String scheme) {
  final dynamic p = profile;
  uri.URI withScheme(Object? value) =>
      uri.URI.revive(value)!.withChanges(uri.UriChange(scheme: scheme));
  return UserDataProfileCarrier(
    id: p.id as String,
    isDefault: p.isDefault as bool,
    name: p.name as String,
    icon: p.icon as String?,
    location: withScheme(p.location),
    globalStorageHome: withScheme(p.globalStorageHome),
    settingsResource: withScheme(p.settingsResource),
    keybindingsResource: withScheme(p.keybindingsResource),
    tasksResource: withScheme(p.tasksResource),
    snippetsHome: withScheme(p.snippetsHome),
    promptsHome: withScheme(p.promptsHome),
    extensionsResource: withScheme(p.extensionsResource),
    mcpResource: withScheme(p.mcpResource),
    languageModelsResource: withScheme(p.languageModelsResource),
    // 1:1: agentPluginsHome is revived without `.with({scheme})`.
    agentPluginsHome: uri.URI.revive(p.agentPluginsHome)!,
    cacheHome: withScheme(p.cacheHome),
    useDefaultFlags: p.useDefaultFlags as UseDefaultProfileFlags?,
    isTransient: p.isTransient as bool?,
    isInternal: p.isInternal as bool?,
    isAgentsWindowProfile: p.isAgentsWindowProfile as bool?,
    workspaces: p.workspaces == null
        ? null
        : (p.workspaces as List).map((w) => uri.URI.revive(w)!).toList(),
  );
}

/// 1:1: `export function toUserDataProfile`
IUserDataProfile toUserDataProfile(
  String id,
  String name,
  uri.URI location,
  uri.URI profilesCacheHome, [
  IUserDataProfileOptions? options,
  IUserDataProfile? defaultProfile,
]) {
  final isAgentsWindowProfile = id == AGENTS_WINDOW_PROFILE_ID;
  final flags = options?.useDefaultFlags;
  bool useDefault(String key) =>
      defaultProfile != null && (flags?[key] ?? false) == true;

  return UserDataProfileCarrier(
    id: id,
    name: name,
    location: location,
    isDefault: false,
    icon: options?.icon,
    globalStorageHome: useDefault(ProfileResourceType.GlobalState)
        ? defaultProfile!.globalStorageHome
        : resources.joinPath(location, const <String>['globalStorage']),
    settingsResource: useDefault(ProfileResourceType.Settings)
        ? defaultProfile!.settingsResource
        : resources.joinPath(location, const <String>['settings.json']),
    keybindingsResource: useDefault(ProfileResourceType.Keybindings)
        ? defaultProfile!.keybindingsResource
        : resources.joinPath(location, const <String>['keybindings.json']),
    tasksResource: useDefault(ProfileResourceType.Tasks)
        ? defaultProfile!.tasksResource
        : resources.joinPath(location, const <String>['tasks.json']),
    snippetsHome: useDefault(ProfileResourceType.Snippets)
        ? defaultProfile!.snippetsHome
        : resources.joinPath(location, const <String>['snippets']),
    promptsHome: useDefault(ProfileResourceType.Prompts)
        ? defaultProfile!.promptsHome
        : resources.joinPath(location, const <String>['prompts']),
    extensionsResource: useDefault(ProfileResourceType.Extensions)
        ? defaultProfile!.extensionsResource
        : resources.joinPath(location, const <String>['extensions.json']),
    mcpResource: useDefault(ProfileResourceType.Mcp)
        ? defaultProfile!.mcpResource
        : resources.joinPath(location, const <String>['mcp.json']),
    languageModelsResource: useDefault(ProfileResourceType.LanguageModels)
        ? defaultProfile!.languageModelsResource
        : resources.joinPath(location,
            const <String>['chatLanguageModels.json']),
    agentPluginsHome: defaultProfile != null
        ? defaultProfile.agentPluginsHome
        : resources.joinPath(location, const <String>['agent-plugins']),
    cacheHome: resources.joinPath(profilesCacheHome, <String>[id]),
    useDefaultFlags: flags,
    isTransient: options?.transient,
    isInternal: isAgentsWindowProfile || (options?.transient ?? false)
        ? true
        : null,
    isAgentsWindowProfile: isAgentsWindowProfile,
    workspaces: options?.workspaces,
  );
}

/// 1:1: `export type UserDataProfilesObject`
class UserDataProfilesObject {
  UserDataProfilesObject({required this.profiles,
      required this.emptyWindows});

  List<IUserDataProfile> profiles;
  Map<String, IUserDataProfile> emptyWindows;
}

/// 1:1: `export type StoredUserDataProfile`
class StoredUserDataProfile {
  StoredUserDataProfile({required this.name, required this.location,
      this.icon, this.useDefaultFlags});

  String name;
  uri.URI location;
  String? icon;
  UseDefaultProfileFlags? useDefaultFlags;
}

/// 1:1: `export type StoredProfileAssociations`
class StoredProfileAssociations {
  StoredProfileAssociations({this.workspaces, this.emptyWindows});

  Map<String, String>? workspaces;
  Map<String, String>? emptyWindows;
}

/// 1:1: `UserDataProfilesService`
class UserDataProfilesService extends lifecycle.Disposable
    implements IUserDataProfilesServiceType {
  // 1:1: `protected static readonly PROFILES_KEY = 'userDataProfiles'`
  static const String PROFILES_KEY = 'userDataProfiles';

  // 1:1: `protected static readonly PROFILE_ASSOCIATIONS_KEY`
  static const String PROFILE_ASSOCIATIONS_KEY = 'profileAssociations';

  @override
  // ignore: unused_element
  Object? get _serviceBrand => null;

  final environment.IEnvironmentServiceType environmentService;
  final files.IFileServiceType fileService;
  final uriIdentity.IUriIdentityServiceType uriIdentityService;
  final log.ILogServiceType logService;

  factory UserDataProfilesService(
    environment.IEnvironmentServiceType environmentService,
    files.IFileServiceType fileService,
    uriIdentity.IUriIdentityServiceType uriIdentityService,
    log.ILogServiceType logService,
  ) {
    return UserDataProfilesService._(
      environmentService,
      fileService,
      uriIdentityService,
      logService,
      resources.joinPath(environmentService.userRoamingDataHome,
          const <String>['profiles']),
      resources.joinPath(environmentService.cacheHome,
          const <String>['CachedProfilesData']),
    );
  }

  UserDataProfilesService._(
    this.environmentService,
    this.fileService,
    this.uriIdentityService,
    this.logService,
    this._profilesHome,
    this.profilesCacheHome,
  );

  final uri.URI profilesCacheHome;

  final uri.URI _profilesHome;

  @override
  uri.URI get profilesHome => _profilesHome;

  @override
  IUserDataProfile get defaultProfile => profiles[0];

  @override
  List<IUserDataProfile> get profiles => <IUserDataProfile>[
        ...profilesObject.profiles,
        ...transientProfilesObject.profiles,
      ];

  final event.Emitter<DidChangeProfilesEvent> _onDidChangeProfiles =
      event.Emitter<DidChangeProfilesEvent>();

  @override
  event.Event<DidChangeProfilesEvent> get onDidChangeProfiles =>
      _onDidChangeProfiles.event;

  final event.Emitter<WillCreateProfileEvent> _onWillCreateProfile =
      event.Emitter<WillCreateProfileEvent>();

  event.Event<WillCreateProfileEvent> get onWillCreateProfile =>
      _onWillCreateProfile.event;

  final event.Emitter<WillRemoveProfileEvent> _onWillRemoveProfile =
      event.Emitter<WillRemoveProfileEvent>();

  event.Event<WillRemoveProfileEvent> get onWillRemoveProfile =>
      _onWillRemoveProfile.event;

  final event.Emitter<void> _onDidResetWorkspaces = event.Emitter<void>();

  @override
  event.Event<void> get onDidResetWorkspaces => _onDidResetWorkspaces.event;

  final Map<String, Future<IUserDataProfile>> profileCreationPromises =
      <String, Future<IUserDataProfile>>{};

  final UserDataProfilesObject transientProfilesObject = UserDataProfilesObject(
    profiles: <IUserDataProfile>[],
    emptyWindows: <String, IUserDataProfile>{},
  );

  UserDataProfilesObject? _profilesObject;

  void init() {
    _profilesObject = null;
  }

  UserDataProfilesObject get profilesObject {
    final cached = _profilesObject;
    if (cached == null) {
      final defaultProfile = createDefaultProfile();
      final profiles = <IUserDataProfile>[defaultProfile];
      try {
        for (final storedProfile in getStoredProfiles()) {
          if (isInvalidProfile(storedProfile)) {
            logService.warn('Skipping the invalid stored profile',
                <Object?>[storedProfile.location]);
            continue;
          }
          final id = resources.basename(storedProfile.location);
          profiles.push(toUserDataProfile(
            id,
            storedProfile.name,
            storedProfile.location,
            profilesCacheHome,
            UserDataProfileOptions(
              icon: storedProfile.icon,
              useDefaultFlags: id == AGENTS_WINDOW_PROFILE_ID
                  ? Map<String, Object?>.from(_AgentsWindowProfileFlags.flags)
                  : storedProfile.useDefaultFlags,
            ),
            defaultProfile,
          ));
        }
      } catch (error) {
        logService.error(error);
      }
      final emptyWindows = <String, IUserDataProfile>{};
      if (profiles.isNotEmpty) {
        try {
          final associations = getStoredProfileAssociations();
          if (associations.workspaces != null) {
            for (final entry in associations.workspaces!.entries) {
              final workspace = uri.URI.parse(entry.key);
              final profile = profiles.where((p) => p.id == entry.value).firstOrNull;
              if (profile != null) {
                final workspaces = profile.workspaces == null
                    ? <uri.URI>[]
                    : List<uri.URI>.from(profile.workspaces!);
                workspaces.add(workspace);
                profile.workspaces = workspaces;
              }
            }
          }
          if (associations.emptyWindows != null) {
            for (final entry in associations.emptyWindows!.entries) {
              final profile = profiles.where((p) => p.id == entry.value).firstOrNull;
              if (profile != null) emptyWindows[entry.key] = profile;
            }
          }
        } catch (error) {
          logService.error(error);
        }
      }
      final result = UserDataProfilesObject(
          profiles: profiles, emptyWindows: emptyWindows);
      _profilesObject = result;
      return result;
    }
    return cached;
  }

  /// 1:1: `private isInvalidProfile`
  bool isInvalidProfile(StoredUserDataProfile storedProfile) {
    if (storedProfile.name.isEmpty) return true;
    if (!types.isString(storedProfile.name)) return true;
    // TS `!storedProfile.location` is false for any URI object, including
    // one with an empty path; Dart keeps the URI non-nullable 1:1.
    return false;
  }

  /// 1:1: `protected createDefaultProfile()`
  IUserDataProfile createDefaultProfile() {
    final defaultProfile = toUserDataProfile(
        '__default__profile__',
        localize('defaultProfile', 'Default'),
        environmentService.userRoamingDataHome,
        profilesCacheHome);
    final extensionsResource =
        getDefaultProfileExtensionsLocation() ?? defaultProfile.extensionsResource;
    final carrier = defaultProfile as UserDataProfileCarrier;
    return carrier.copyWith(isDefault: true, extensionsResource: extensionsResource);
  }

  @override
  Future<IUserDataProfile> createTransientProfile(
      [Object? workspaceIdentifier]) async {
    const namePrefix = 'Temp';
    final nameRegEx =
        RegExp('${strings.escapeRegExpCharacters(namePrefix)}\\s(\\d+)');
    var nameIndex = 0;
    for (final profile in profiles) {
      final matches = nameRegEx.firstMatch(profile.name);
      final index = matches == null ? 0 : int.parse(matches.group(1)!);
      nameIndex = index > nameIndex ? index : nameIndex;
    }
    final name = '$namePrefix ${nameIndex + 1}';
    return createProfile(_newId(), name,
        UserDataProfileOptions(transient: true), workspaceIdentifier);
  }

  @override
  Future<IUserDataProfile> createNamedProfile(String name,
      [IUserDataProfileOptions? options, Object? workspaceIdentifier]) {
    return createProfile(_newId(), name, options, workspaceIdentifier);
  }

  @override
  Future<IUserDataProfile> createProfile(String id, String name,
      [IUserDataProfileOptions? options, Object? workspaceIdentifier]) {
    return doCreateProfile(id, name, options, workspaceIdentifier);
  }

  /// Test carrier for the module-scope `generateUuid()` import. Source uses
  /// `generateUuid()` directly; the default value is identical at runtime.
  static String Function() generateUuid = uuid.generateUuid;

  static String _newId() =>
      hashes.hash(generateUuid()).toRadixString(16);

  Future<IUserDataProfile> doCreateProfile(String id, String name,
      [IUserDataProfileOptions? options, Object? workspaceIdentifier]) async {
    if (!types.isString(name) || name.isEmpty) {
      throw errors.BugIndicatingError(
          'Name of the profile is mandatory and must be of type `string`');
    }

    var profileCreationPromise = profileCreationPromises[name];
    if (profileCreationPromise == null) {
      profileCreationPromise = (() async {
        try {
          final existing = profiles.where((p) =>
              p.id == id ||
              (id != AGENTS_WINDOW_PROFILE_ID &&
                  !(p.isTransient ?? false) &&
                  !(options?.transient ?? false) &&
                  p.name == name)).firstOrNull;
          if (existing != null) {
            throw errors.BugIndicatingError(
                'Profile with $name name already exists');
          }

          final workspace = workspaceIdentifier == null
              ? null
              : getWorkspace(workspaceIdentifier);
          IUserDataProfileOptions effectiveOptions = options ?? UserDataProfileOptions();
          if (uri.URI.isUri(workspace)) {
            effectiveOptions = UserDataProfileOptions(
              icon: effectiveOptions.icon,
              useDefaultFlags: effectiveOptions.useDefaultFlags,
              transient: effectiveOptions.transient,
              workspaces: <uri.URI>[workspace as uri.URI],
            );
          }

          final profileLocation = uriIdentityService.extUri.joinPath(
              profilesHome,
              id == AGENTS_WINDOW_PROFILE_ID
                  ? <String>['builtin', id]
                  : <String>[id]);
          final profile = toUserDataProfile(
            id,
            name,
            profileLocation,
            profilesCacheHome,
            id == AGENTS_WINDOW_PROFILE_ID
                ? UserDataProfileOptions()
                : effectiveOptions,
            defaultProfile,
          );
          await (fileService as dynamic).createFolder(profile.location);

          final joiners = <Future<void>>[];
          _onWillCreateProfile.fire(WillCreateProfileEvent(
            profile: profile,
            join: (promise) => joiners.add(promise),
          ));
          await async.Promises.settled(joiners);

          if (workspace != null && !uri.URI.isUri(workspace)) {
            updateEmptyWindowAssociation(
                workspace as String, profile, profile.isTransient ?? false);
          }
          updateProfiles(<IUserDataProfile>[profile],
              <IUserDataProfile>[], <IUserDataProfile>[]);
          return profiles.where((p) => p.id == profile.id).firstOrNull ??
              profile;
        } finally {
          profileCreationPromises.remove(name);
        }
      })();
      profileCreationPromises[name] = profileCreationPromise;
    }
    return profileCreationPromise;
  }

  @override
  Future<IUserDataProfile> updateProfile(IUserDataProfile profile,
      [IUserDataProfileUpdateOptions? options]) async {
    options ??= UserDataProfileUpdateOptions();
    if (profile.isAgentsWindowProfile ?? false) {
      throw errors.BugIndicatingError('Cannot update agents window profile');
    }

    final profilesToUpdate = <IUserDataProfile>[];
    for (final existing in profiles) {
      IUserDataProfile? profileToUpdate;

      if (profile.id == existing.id) {
        if (!existing.isDefault) {
          profileToUpdate = toUserDataProfile(
            existing.id,
            options.name ?? existing.name,
            existing.location,
            profilesCacheHome,
            UserDataProfileOptions(
              icon: identical(options.icon, _jsUndefined)
                  ? existing.icon
                  : (options.icon == null ? null : options.icon as String),
              transient: options.transient ?? existing.isTransient,
              useDefaultFlags:
                  options.useDefaultFlags ?? existing.useDefaultFlags,
              workspaces: options.workspaces ?? existing.workspaces,
            ),
            defaultProfile,
          );
        } else if (options.workspaces != null) {
          profileToUpdate = existing;
          profileToUpdate.workspaces = options.workspaces;
        }
      } else if (options.workspaces != null) {
        final optionWorkspaces = options.workspaces!;
        final workspaces = existing.workspaces
            ?.where((w1) =>
                !optionWorkspaces.any((w2) => uriIdentityService.extUri.isEqual(w1, w2)))
            .toList();
        if (existing.workspaces?.length != workspaces?.length) {
          profileToUpdate = existing;
          profileToUpdate.workspaces = workspaces;
        }
      }

      if (profileToUpdate != null) profilesToUpdate.add(profileToUpdate);
    }

    if (profilesToUpdate.isEmpty) {
      if (profile.isDefault) {
        throw errors.BugIndicatingError('Cannot update default profile');
      }
      throw errors.BugIndicatingError("Profile '${profile.name}' does not exist");
    }

    updateProfiles(<IUserDataProfile>[], <IUserDataProfile>[],
        profilesToUpdate);

    final updatedProfile =
        profiles.where((p) => p.id == profile.id).firstOrNull;
    if (updatedProfile == null) {
      throw errors.BugIndicatingError(
          "Profile '${profile.name}' was not updated");
    }
    return updatedProfile;
  }

  @override
  Future<void> removeProfile(IUserDataProfile profileToRemove) async {
    if (profileToRemove.isDefault) {
      throw errors.BugIndicatingError('Cannot remove default profile');
    }
    final profile = profiles.where((p) => p.id == profileToRemove.id).firstOrNull;
    if (profile == null) {
      throw errors.BugIndicatingError(
          "Profile '${profileToRemove.name}' does not exist");
    }

    final joiners = <Future<void>>[];
    _onWillRemoveProfile.fire(WillRemoveProfileEvent(
      profile: profile,
      join: (promise) => joiners.add(promise),
    ));

    try {
      for (final joiner in joiners) {
        try {
          await joiner;
        } catch (error) {
          // 1:1: Promise.allSettled never rejects; errors are ignored here.
        }
      }
    } catch (error) {
      logService.error(error);
    }

    updateProfiles(<IUserDataProfile>[], <IUserDataProfile>[profile],
        <IUserDataProfile>[]);

    try {
      await (fileService as dynamic).del(profile.cacheHome,
          <String, Object?>{'recursive': true});
    } catch (error) {
      final result = error is files.FileOperationError
          ? files.toFileOperationResult(error)
          : 0;
      if (result != files.FileOperationResult.FILE_NOT_FOUND) {
        logService.error(error);
      }
    }
  }

  @override
  Future<void> setProfileForWorkspace(
      Object workspaceIdentifier, IUserDataProfile profileToSet) async {
    final profile = profiles.where((p) => p.id == profileToSet.id).firstOrNull;
    if (profile == null) {
      throw errors.BugIndicatingError(
          "Profile '${profileToSet.name}' does not exist");
    }

    final workspace = getWorkspace(workspaceIdentifier);
    if (uri.URI.isUri(workspace)) {
      final workspaces = profile.workspaces == null
          ? <uri.URI>[]
          : List<uri.URI>.from(profile.workspaces!);
      if (!workspaces.any(
          (w) => uriIdentityService.extUri.isEqual(w, workspace as uri.URI))) {
        workspaces.add(workspace as uri.URI);
        await updateProfile(profile,
            UserDataProfileUpdateOptions(workspaces: workspaces));
      }
    } else {
      updateEmptyWindowAssociation(
          workspace as String, profile, false);
      updateStoredProfiles(profiles);
    }
  }

  /// 1:1: `unsetWorkspace`
  void unsetWorkspace(Object workspaceIdentifier, [bool transient = false]) {
    final workspace = getWorkspace(workspaceIdentifier);
    if (uri.URI.isUri(workspace)) {
      final currentlyAssociatedProfile =
          getProfileForWorkspace(workspaceIdentifier);
      if (currentlyAssociatedProfile != null) {
        updateProfile(
          currentlyAssociatedProfile,
          UserDataProfileUpdateOptions(
            workspaces: currentlyAssociatedProfile.workspaces
                ?.where((w) => !uriIdentityService.extUri.isEqual(
                    w, workspace as uri.URI))
                .toList(),
          ),
        );
      }
    } else {
      updateEmptyWindowAssociation(workspace as String, null, transient);
      updateStoredProfiles(profiles);
    }
  }

  @override
  Future<void> resetWorkspaces() async {
    transientProfilesObject.emptyWindows.clear();
    profilesObject.emptyWindows.clear();
    for (final profile in profiles) {
      profile.workspaces = null;
    }
    updateProfiles(<IUserDataProfile>[], <IUserDataProfile>[], profiles);
    _onDidResetWorkspaces.fire(null);
  }

  @override
  Future<void> cleanUp() async {
    try {
      if (await (fileService as dynamic).exists(profilesHome) as bool) {
        final stat = await (fileService as dynamic).resolve(profilesHome);
        final children = (stat.children as List?) ?? const <Object>[];
        final toDelete = children
            .where((child) =>
                (child.isDirectory as bool) &&
                child.name != 'builtin' &&
                profiles.every((p) => !uriIdentityService.extUri.isEqual(
                    p.location, child.resource as uri.URI)))
            .map((child) => (fileService as dynamic)
                .del(child.resource as uri.URI,
                    <String, Object?>{'recursive': true}))
            .toList();
        await Future.wait(toDelete.cast<Future<void>>());
      }
    } catch (error) {
      logService.error('Error deleting redundant profile folders',
          <Object?>[error]);
    }

    try {
      final existing = getStoredProfiles();
      final valid = <StoredUserDataProfile>[];
      for (final storedProfile in getStoredProfiles()) {
        if (isInvalidProfile(storedProfile)) {
          logService.warn('Invalid user data profile found: ${storedProfile.name}');
        } else {
          valid.add(storedProfile);
        }
      }
      if (existing.length != valid.length) saveStoredProfiles(valid);
    } catch (error) {
      logService.error('Error removing invalid stored profiles',
          <Object?>[error]);
    }
  }

  @override
  Future<void> cleanUpTransientProfiles() async {
    final unAssociated = transientProfilesObject.profiles
        .where((p) => !isProfileAssociatedToWorkspace(p))
        .toList();
    for (final p in unAssociated) {
      try {
        await removeProfile(p);
      } catch (_) {
        // 1:1: Promise.allSettled swallows rejections.
      }
    }
  }

  /// 1:1: `getProfileForWorkspace`
  IUserDataProfile? getProfileForWorkspace(Object workspaceIdentifier) {
    final workspace = getWorkspace(workspaceIdentifier);

    if (uri.URI.isUri(workspace) &&
        uriIdentityService.extUri.isEqual(
            workspace as uri.URI, environmentService.agentSessionsWorkspace)) {
      return profiles.where((p) => p.isAgentsWindowProfile ?? false).firstOrNull;
    }

    if (uri.URI.isUri(workspace)) {
      return profiles.where((p) => p.workspaces?.any(
              (w) => uriIdentityService.extUri.isEqual(w, workspace as uri.URI)) ??
          false).firstOrNull;
    }
    final workspaceId = workspace as String;
    return profilesObject.emptyWindows[workspaceId] ??
        transientProfilesObject.emptyWindows[workspaceId];
  }

  /// 1:1: `protected getWorkspace`
  Object getWorkspace(Object workspaceIdentifier) {
    if (workspace.isSingleFolderWorkspaceIdentifier(workspaceIdentifier)) {
      return (workspaceIdentifier as Map)['uri'] as uri.URI;
    }
    if (workspace.isWorkspaceIdentifier(workspaceIdentifier)) {
      return (workspaceIdentifier as Map)['configPath'] as uri.URI;
    }
    return (workspaceIdentifier as Map)['id'] as String;
  }

  bool isProfileAssociatedToWorkspace(IUserDataProfile profile) {
    if (profile.workspaces != null && profile.workspaces!.isNotEmpty) return true;
    if (profilesObject.emptyWindows.values.any((windowProfile) =>
        uriIdentityService.extUri.isEqual(
            windowProfile.location, profile.location))) {
      return true;
    }
    if (transientProfilesObject.emptyWindows.values.any((windowProfile) =>
        uriIdentityService.extUri.isEqual(
            windowProfile.location, profile.location))) {
      return true;
    }
    return false;
  }

  /// 1:1: `private updateProfiles`
  void updateProfiles(
    List<IUserDataProfile> added,
    List<IUserDataProfile> removed,
    List<IUserDataProfile> updated, [
    bool donotTrigger = false,
  ]) {
    final allProfiles = <IUserDataProfile>[...profiles, ...added];

    final transientProfiles =
        List<IUserDataProfile>.from(transientProfilesObject.profiles);
    transientProfilesObject.profiles = <IUserDataProfile>[];

    final result = <IUserDataProfile>[];

    for (var profile in allProfiles) {
      if (removed.any((p) => profile.id == p.id)) {
        for (final windowId in profilesObject.emptyWindows.keys.toList()) {
          if (profile.id == profilesObject.emptyWindows[windowId]?.id) {
            profilesObject.emptyWindows.remove(windowId);
          }
        }
        continue;
      }

      if (!profile.isDefault) {
        profile = updated.where((p) => profile.id == p.id).firstOrNull ?? profile;
        final transientProfile =
            transientProfiles.where((p) => profile.id == p.id).firstOrNull;
        if (profile.isTransient ?? false) {
          transientProfilesObject.profiles.add(profile);
        } else if (transientProfile != null) {
          for (final entry in transientProfilesObject.emptyWindows.entries.toList()) {
            if (profile.id == entry.value.id) {
              transientProfilesObject.emptyWindows.remove(entry.key);
              profilesObject.emptyWindows[entry.key] = profile;
              break;
            }
          }
        }
      }

      if (profile.workspaces != null && profile.workspaces!.isEmpty) {
        profile.workspaces = null;
      }

      result.add(profile);
    }

    updateStoredProfiles(result);

    if (!donotTrigger) triggerProfilesChanges(added, removed, updated);
  }

  /// 1:1: `protected triggerProfilesChanges`
  void triggerProfilesChanges(List<IUserDataProfile> added,
      List<IUserDataProfile> removed, List<IUserDataProfile> updated) {
    _onDidChangeProfiles.fire(DidChangeProfilesEvent(
        added: added, removed: removed, updated: updated, all: profiles));
  }

  /// 1:1: `private updateEmptyWindowAssociation`
  void updateEmptyWindowAssociation(
      String windowId, IUserDataProfile? newProfile, bool transient) {
    transient = (newProfile?.isTransient ?? false) ? true : transient;

    if (transient) {
      if (newProfile != null) {
        transientProfilesObject.emptyWindows[windowId] = newProfile;
      } else {
        transientProfilesObject.emptyWindows.remove(windowId);
      }
    } else {
      transientProfilesObject.emptyWindows.remove(windowId);
      if (newProfile != null) {
        profilesObject.emptyWindows[windowId] = newProfile;
      } else {
        profilesObject.emptyWindows.remove(windowId);
      }
    }
  }

  /// 1:1: `private updateStoredProfiles`
  void updateStoredProfiles(List<IUserDataProfile> profiles) {
    final storedProfiles = <StoredUserDataProfile>[];
    final workspaces = <String, String>{};
    final emptyWindows = <String, String>{};

    for (final profile in profiles) {
      if (profile.isTransient ?? false) continue;
      if (!profile.isDefault) {
        storedProfiles.push(StoredUserDataProfile(
          location: profile.location,
          name: profile.name,
          icon: profile.icon,
          useDefaultFlags: profile.useDefaultFlags,
        ));
      }
      if (profile.workspaces != null) {
        for (final workspace in profile.workspaces!) {
          workspaces[workspace.toString()] = profile.id;
        }
      }
    }

    for (final entry in profilesObject.emptyWindows.entries) {
      emptyWindows[entry.key.toString()] = entry.value.id;
    }

    saveStoredProfileAssociations(
        StoredProfileAssociations(workspaces: workspaces, emptyWindows: emptyWindows));
    saveStoredProfiles(storedProfiles);
    _profilesObject = null;
  }

  /// 1:1: `protected getStoredProfiles()`
  List<StoredUserDataProfile> getStoredProfiles() => const <StoredUserDataProfile>[];

  /// 1:1: `protected saveStoredProfiles()`
  void saveStoredProfiles(List<StoredUserDataProfile> storedProfiles) {
    throw errors.BugIndicatingError('not implemented');
  }

  /// 1:1: `protected getStoredProfileAssociations()`
  StoredProfileAssociations getStoredProfileAssociations() =>
      StoredProfileAssociations();

  /// 1:1: `protected saveStoredProfileAssociations()`
  void saveStoredProfileAssociations(
      StoredProfileAssociations storedProfileAssociations) {
    throw errors.BugIndicatingError('not implemented');
  }

  /// 1:1: `protected getDefaultProfileExtensionsLocation()`
  uri.URI? getDefaultProfileExtensionsLocation() => null;

  /// Test carrier for emitter `fire` where TS fires `void`.
  void fireUpdateProfiles(DidChangeProfilesEvent e) =>
      _onDidChangeProfiles.fire(e);
}

/// 1:1: `export class InMemoryUserDataProfilesService`
class InMemoryUserDataProfilesService extends UserDataProfilesService {
  InMemoryUserDataProfilesService(environment.IEnvironmentServiceType environmentService,
      files.IFileServiceType fileService,
      uriIdentity.IUriIdentityServiceType uriIdentityService,
      log.ILogServiceType logService)
      : super._(
          environmentService,
          fileService,
          uriIdentityService,
          logService,
          resources.joinPath(environmentService.userRoamingDataHome,
              const <String>['profiles']),
          resources.joinPath(environmentService.cacheHome,
              const <String>['CachedProfilesData']),
        );

  List<StoredUserDataProfile> storedProfiles = <StoredUserDataProfile>[];
  StoredProfileAssociations storedProfileAssociations = StoredProfileAssociations();

  @override
  List<StoredUserDataProfile> getStoredProfiles() => storedProfiles;

  @override
  void saveStoredProfiles(List<StoredUserDataProfile> storedProfiles) {
    this.storedProfiles = storedProfiles;
  }

  @override
  StoredProfileAssociations getStoredProfileAssociations() =>
      storedProfileAssociations;

  @override
  void saveStoredProfileAssociations(
      StoredProfileAssociations storedProfileAssociations) {
    this.storedProfileAssociations = storedProfileAssociations;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

extension _Push<T> on List<T> {
  void push(T value) => add(value);
}
