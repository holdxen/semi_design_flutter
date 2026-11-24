// 1:1 port of vscode/src/vs/platform/quickinput/browser/commandsQuickAccess.ts
// @bfbf12b
//
// Carriers: the batch194/196 `platform/quickinput` ports (`PickerQuickAccessProvider`,
// `IPickerQuickAccessItem`, `TriggerAction`, `IQuickPick*`), batch195 `tfIdf`,
// `filters`, `LRUCache`, `lifecycle`, `storage`, `configuration`, `telemetry`
// and `nls` are used as-is. Translated 1:1 from TypeScript. Do not refactor.
//
// Adaptations (documented inline):
//  * `protected override readonly options: ICommandsQuickAccessOptions` — Dart
//    cannot re-declare a parent `final` field with a narrower type while keeping
//    the parent's storage, so the typed view is `_options` and the base field is
//    still fed the same instance through `super(...)`.
//  * `instantiationService.createInstance(CommandsHistory)` relies on TS
//    decorator metadata; the Dart carrier resolves the same three services
//    through `invokeFunction(accessor)` and constructs `CommandsHistory`
//    explicitly (same service order as the TS constructor).
//  * TS object spread (`{ ...commandPick, id, tooltip }`) → explicit
//    `ICommandQuickPick` copy-construction over the same field set.
//  * `accept: async () => { ... }` → the interface slot is `void Function(...)`,
//    so the async body lives in `_acceptCommand` and is fired from the slot.
//  * `config.workbench?.commandPalette?.history` (optional chaining over a plain
//    object literal) → `_pluck` supporting `Map` and dynamic property reads.
//  * `localeCompare` → `compareTo` (labels are compared to order ASCII/Unicode
//    code units; identical for the command labels used here).
import 'dart:convert' as convert;

import '../../../base/common/actions.dart'
    show WorkbenchActionExecutedEvent;
import '../../../base/common/cancellation.dart' show CancellationToken;
import '../../../base/common/codicons.dart' show Codicon;
import '../../../base/common/errorMessage.dart' show toErrorMessage;
import '../../../base/common/errors.dart' show isCancellationError;
import '../../../base/common/filters.dart'
    show IFilter, IMatch, matchesBaseContiguousSubString, matchesWords, or;
import '../../../base/common/functional.dart' show createSingleCallFunction;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../../base/common/map.dart' show LinkedMap, LRUCache;
import '../../../base/common/themables.dart' show ThemeIcon;
import '../../../base/common/tfIdf.dart'
    show
        NormalizedTfIdfScore,
        TfIdfCalculator,
        TfIdfDocument,
        TfIdfScore,
        normalizeTfIdfScores;
import '../../../nls.dart' show localize;
import '../../action/common/action.dart' show ILocalizedString;
import '../../action/common/actionCommonCategories.dart' show Categories;
import '../../commands/common/commands.dart' show ICommandServiceType;
import '../../configuration/common/configuration.dart'
    show IConfigurationChangeEvent,
        IConfigurationService,
        IConfigurationServiceType;
import '../../dialogs/common/dialogs.dart' show IDialogServiceType;
import '../../instantiation/common/instantiation.dart'
    show IInstantiationServiceType, ServicesAccessor;
import '../../keybinding/common/keybinding.dart' show IKeybindingServiceType;
import '../../log/common/log.dart' show ILogService, ILogServiceType;
import '../../storage/common/storage.dart'
    show
        IStorageService,
        IStorageServiceType,
        StorageScope,
        StorageTarget,
        WillSaveStateReason,
        WillSaveStateEvent;
import '../../telemetry/common/telemetry.dart' show ITelemetryServiceType;
import '../common/quickAccess.dart' show IQuickAccessProviderRunOptions;
import '../common/quickInput.dart'
    show
        IKeyMods,
        IQuickInputButton,
        IQuickPickDidAcceptEvent,
        IQuickPickItemHighlights,
        IQuickPickSeparator;
import 'pickerQuickAccess.dart'
    show
        FastAndSlowPicks,
        IPickerQuickAccessItem,
        IPickerQuickAccessProviderOptions,
        PickerQuickAccessProvider,
        TriggerAction;

/// 1:1: `export interface ICommandQuickPick extends
/// IPickerQuickAccessItem`.
class ICommandQuickPick extends IPickerQuickAccessItem {
  ICommandQuickPick({
    super.id,
    required super.label,
    super.ariaLabel,
    super.description,
    super.italic,
    super.strikethrough,
    super.iconClasses,
    super.iconPath,
    super.iconClass,
    super.iconColor,
    super.highlights,
    super.buttons,
    super.disabled,
    super.type,
    super.detail,
    super.tooltip,
    super.keybinding,
    super.picked,
    super.alwaysShow,
    super.pickable,
    super.accept,
    super.trigger,
    super.attach,
    required this.commandId,
    this.commandWhen,
    this.commandAlias,
    this.commandDescription,
    this.commandCategory,
    this.args,
    this.tfIdfScore,
  });

  final String commandId;
  final String? commandWhen;
  final String? commandAlias;
  final ILocalizedString? commandDescription;
  final String? commandCategory;

  final List<Object?>? args;

  num? tfIdfScore;
}

/// Copy of [ICommandQuickPick] with the fields overridden by
/// `toCommandPick`; the Dart carrier for the TS object spread.
ICommandQuickPick _copyCommandPick(
  ICommandQuickPick pick, {
  String? id,
  Object? tooltip,
  String? ariaLabel,
  String? detail,
  Object? keybinding,
  List<IQuickInputButton>? buttons,
  void Function(IKeyMods keyMods, IQuickPickDidAcceptEvent event)? accept,
  Object? Function(int buttonIndex, IKeyMods keyMods)? trigger,
}) {
  return ICommandQuickPick(
    id: id,
    label: pick.label,
    ariaLabel: ariaLabel,
    description: pick.description,
    italic: pick.italic,
    strikethrough: pick.strikethrough,
    iconClasses: pick.iconClasses,
    iconPath: pick.iconPath,
    iconClass: pick.iconClass,
    iconColor: pick.iconColor,
    // TS `highlights` is re-declared by `IQuickPickItem`; the carrier keeps
    // both slots pointing at the same value (see `quickInput.dart`).
    highlights: pick.highlights,
    buttons: buttons,
    disabled: pick.disabled,
    type: pick.type,
    detail: detail,
    tooltip: tooltip,
    keybinding: keybinding as dynamic,
    picked: pick.picked,
    alwaysShow: pick.alwaysShow,
    pickable: pick.pickable,
    accept: accept,
    trigger: trigger,
    attach: pick.attach,
    commandId: pick.commandId,
    commandWhen: pick.commandWhen,
    commandAlias: pick.commandAlias,
    commandDescription: pick.commandDescription,
    commandCategory: pick.commandCategory,
    args: pick.args,
    tfIdfScore: pick.tfIdfScore,
  );
}

/// 1:1: `export interface ICommandsQuickAccessOptions extends
/// IPickerQuickAccessProviderOptions<ICommandQuickPick>`.
class ICommandsQuickAccessOptions
    extends IPickerQuickAccessProviderOptions<ICommandQuickPick> {
  ICommandsQuickAccessOptions({
    required this.showAlias,
    this.suggestedCommandIds,
    super.canAcceptInBackground,
    super.noResultsPick,
    super.shouldSkipTrimPickFilter,
  });

  final bool showAlias;
  Set<String>? suggestedCommandIds;
}

/// 1:1: `export abstract class AbstractCommandsQuickAccessProvider extends
/// PickerQuickAccessProvider<ICommandQuickPick> implements IDisposable`.
abstract class AbstractCommandsQuickAccessProvider
    extends PickerQuickAccessProvider<ICommandQuickPick> {
  AbstractCommandsQuickAccessProvider(
    ICommandsQuickAccessOptions options,
    IInstantiationServiceType instantiationService,
    this._keybindingService,
    this._commandService,
    this._telemetryService,
    this._dialogService,
  )   : _options = options,
        super(AbstractCommandsQuickAccessProvider.PREFIX, options) {
    // TS: `this._register(instantiationService.createInstance(CommandsHistory))`
    // — the three `@I*` services are resolved through the accessor instead of
    // decorator metadata (see the file header).
    commandsHistory = register(instantiationService.invokeFunction(
      (ServicesAccessor accessor) => CommandsHistory(
        accessor.get(IStorageService) as IStorageServiceType,
        accessor.get(IConfigurationService) as IConfigurationServiceType,
        accessor.get(ILogService) as ILogServiceType,
      ),
      const <Object?>[],
    ) as CommandsHistory);
  }

  static const String PREFIX = '>';

  static const double TFIDF_THRESHOLD = 0.5;
  static const int TFIDF_MAX_RESULTS = 5;

  static final IFilter WORD_FILTER =
      or(<IFilter>[matchesBaseContiguousSubString, matchesWords]);

  // private in source.
  late final CommandsHistory commandsHistory;

  /// `protected override readonly options` — see the file header.
  final ICommandsQuickAccessOptions _options;

  // private in source.
  final IKeybindingServiceType _keybindingService;
  final ICommandServiceType _commandService;
  final ITelemetryServiceType _telemetryService;
  final IDialogServiceType _dialogService;

  @override
  Future<Object?> getPicks(
    String filter,
    lifecycle.DisposableStore _disposables,
    CancellationToken token, [
    IQuickAccessProviderRunOptions? runOptions,
  ]) async {
    // Ask subclass for all command picks
    final List<ICommandQuickPick> allCommandPicks =
        await getCommandPicks(token);

    if (token.isCancellationRequested) {
      return <Object>[];
    }

    final List<NormalizedTfIdfScore> Function() runTfidf =
        createSingleCallFunction(() {
      final TfIdfCalculator tfidf = TfIdfCalculator();
      tfidf.updateDocuments(allCommandPicks
          .map((ICommandQuickPick commandPick) => TfIdfDocument(
                key: commandPick.commandId,
                textChunks: <String>[getTfIdfChunk(commandPick)],
              ))
          .toList());
      final List<TfIdfScore> result = tfidf.calculateScores(filter, token);

      return normalizeTfIdfScores(result)
          .where((NormalizedTfIdfScore score) =>
              score.score > AbstractCommandsQuickAccessProvider.TFIDF_THRESHOLD)
          .take(AbstractCommandsQuickAccessProvider.TFIDF_MAX_RESULTS)
          .toList();
    });

    // Filter
    final List<ICommandQuickPick> filteredCommandPicks = <ICommandQuickPick>[];
    for (final ICommandQuickPick commandPick in allCommandPicks) {
      final List<IMatch>? labelHighlights =
          AbstractCommandsQuickAccessProvider.WORD_FILTER(
              filter, commandPick.label);

      List<IMatch>? aliasHighlights;
      final String? commandAlias = commandPick.commandAlias;
      if (commandAlias != null && commandAlias.isNotEmpty) {
        aliasHighlights = AbstractCommandsQuickAccessProvider.WORD_FILTER(
            filter, commandAlias);
      }

      // Add if matching in label or alias
      if (labelHighlights != null || aliasHighlights != null) {
        commandPick.highlights = IQuickPickItemHighlights(
          label: labelHighlights,
          detail: _options.showAlias ? aliasHighlights : null,
        );

        filteredCommandPicks.add(commandPick);
      }

      // Also add if we have a 100% command ID match
      else if (filter == commandPick.commandId) {
        filteredCommandPicks.add(commandPick);
      }

      // Handle tf-idf scoring for the rest if there's a filter
      else if (filter.length >= 3) {
        final List<NormalizedTfIdfScore> tfidf = runTfidf();
        if (token.isCancellationRequested) {
          return <Object>[];
        }

        // Add if we have a tf-idf score
        final Iterable<NormalizedTfIdfScore> matches =
            tfidf.where((NormalizedTfIdfScore score) =>
                score.key == commandPick.commandId);
        if (matches.isNotEmpty) {
          final NormalizedTfIdfScore tfidfScore = matches.first;
          commandPick.tfIdfScore = tfidfScore.score;
          filteredCommandPicks.add(commandPick);
        }
      }
    }

    // Add description to commands that have duplicate labels
    final Map<String, ICommandQuickPick> mapLabelToCommand =
        <String, ICommandQuickPick>{};
    for (final ICommandQuickPick commandPick in filteredCommandPicks) {
      final ICommandQuickPick? existingCommandForLabel =
          mapLabelToCommand[commandPick.label];
      if (existingCommandForLabel != null) {
        commandPick.description = commandPick.commandId;
        existingCommandForLabel.description = existingCommandForLabel.commandId;
      } else {
        mapLabelToCommand[commandPick.label] = commandPick;
      }
    }

    // Sort by MRU order and fallback to name otherwise
    filteredCommandPicks.sort(
        (ICommandQuickPick commandPickA, ICommandQuickPick commandPickB) {
      // If a result came from tf-idf, we want to put that towards the bottom
      final num? scoreA = commandPickA.tfIdfScore;
      final num? scoreB = commandPickB.tfIdfScore;
      if (scoreA != null && scoreB != null) {
        if (scoreA == scoreB) {
          return commandPickA.label
              .compareTo(commandPickB.label); // prefer lexicographically smaller command
        }

        return scoreB
            .compareTo(scoreA); // prefer higher tf-idf score
      } else if (scoreA != null) {
        return 1; // first command has a score but other doesn't so other wins
      } else if (scoreB != null) {
        return -1; // other command has a score but first doesn't so first wins
      }

      final num? commandACounter = commandsHistory.peek(commandPickA.commandId);
      final num? commandBCounter = commandsHistory.peek(commandPickB.commandId);

      if (commandACounter != null && commandBCounter != null) {
        return commandACounter > commandBCounter
            ? -1
            : 1; // use more recently used command before older
      }

      if (commandACounter != null) {
        return -1; // first command was used, so it wins over the non used one
      }

      if (commandBCounter != null) {
        return 1; // other command was used so it wins over the command
      }

      final Set<String>? suggestedCommandIds = _options.suggestedCommandIds;
      if (suggestedCommandIds != null) {
        final bool commandASuggestion =
            suggestedCommandIds.contains(commandPickA.commandId);
        final bool commandBSuggestion =
            suggestedCommandIds.contains(commandPickB.commandId);
        if (commandASuggestion && commandBSuggestion) {
          return 0; // honor the order of the array
        }

        if (commandASuggestion) {
          return -1; // first command was suggested, so it wins over the non suggested one
        }

        if (commandBSuggestion) {
          return 1; // other command was suggested so it wins over the command
        }
      }

      // if one is Developer and the other isn't, put non-Developer first
      final bool isDeveloperA =
          commandPickA.commandCategory == Categories.Developer.value;
      final bool isDeveloperB =
          commandPickB.commandCategory == Categories.Developer.value;
      if (isDeveloperA && !isDeveloperB) {
        return 1;
      }
      if (!isDeveloperA && isDeveloperB) {
        return -1;
      }

      // both commands were never used, so we sort by name
      return commandPickA.label.compareTo(commandPickB.label);
    });

    final List<Object> commandPicks = <Object>[];

    bool addOtherSeparator = false;
    bool addSuggestedSeparator = true;
    bool addCommonlyUsedSeparator = _options.suggestedCommandIds != null;
    for (int i = 0; i < filteredCommandPicks.length; i++) {
      final ICommandQuickPick commandPick = filteredCommandPicks[i];
      final bool isInHistory = commandsHistory.peek(commandPick.commandId) != null;

      // Separator: recently used
      if (i == 0 && isInHistory) {
        commandPicks.add(IQuickPickSeparator(
            label: localize('recentlyUsed', 'recently used')));
        addOtherSeparator = true;
      }

      if (addSuggestedSeparator && commandPick.tfIdfScore != null) {
        commandPicks.add(IQuickPickSeparator(
            label: localize('suggested', 'similar commands')));
        addSuggestedSeparator = false;
      }

      // Separator: commonly used
      if (addCommonlyUsedSeparator &&
          commandPick.tfIdfScore == null &&
          !isInHistory &&
          (_options.suggestedCommandIds
                  ?.contains(commandPick.commandId) ??
              false)) {
        commandPicks.add(IQuickPickSeparator(
            label: localize('commonlyUsed', 'commonly used')));
        addOtherSeparator = true;
        addCommonlyUsedSeparator = false;
      }

      // Separator: other commands
      if (addOtherSeparator &&
          commandPick.tfIdfScore == null &&
          !isInHistory &&
          !(_options.suggestedCommandIds?.contains(commandPick.commandId) ??
              false)) {
        commandPicks.add(IQuickPickSeparator(
            label: localize('morecCommands', 'other commands')));
        addOtherSeparator = false;
      }

      // Command
      commandPicks.add(toCommandPick(commandPick, runOptions, isInHistory));
    }

    if (!hasAdditionalCommandPicks(filter, token)) {
      return commandPicks;
    }

    return FastAndSlowPicks<ICommandQuickPick>(
      picks: commandPicks,
      additionalPicks: () async {
        final List<Object> additionalCommandPicks =
            await getAdditionalCommandPicks(
                allCommandPicks, filteredCommandPicks, filter, token);
        if (token.isCancellationRequested) {
          return <Object>[];
        }

        final List<Object> picks = additionalCommandPicks
            .map((Object commandPick) => toCommandPick(commandPick, runOptions))
            .toList();
        // Basically, if we haven't already added a separator, we add one before
        // the additional picks so long as one hasn't been added to the start of
        // the array.
        if (addSuggestedSeparator &&
            (picks.isEmpty || (picks[0] as dynamic).type != 'separator')) {
          picks.insert(
              0,
              IQuickPickSeparator(
                  label: localize('suggested', 'similar commands')));
        }
        return picks;
      }(),
    );
  }

  /// TS: `private toCommandPick(commandPick, runOptions?, isRecentlyUsed =
  /// false)`. Kept public: Dart library-private members cannot be called from
  /// another library and subclasses live elsewhere.
  Object toCommandPick(
    Object commandPick, [
    IQuickAccessProviderRunOptions? runOptions,
    bool isRecentlyUsed = false,
  ]) {
    if (commandPick is IQuickPickSeparator) {
      return commandPick;
    }
    final ICommandQuickPick pick = commandPick as ICommandQuickPick;

    final String? commandDescriptionValue = pick.commandDescription?.value;
    final Object? tooltip = pick.tooltip ?? commandDescriptionValue;

    final Object? keybinding =
        _keybindingService.lookupKeybinding(pick.commandId);
    final String ariaLabel = keybinding != null
        ? localize('commandPickAriaLabelWithKeybinding', '{0}, {1}',
            <Object?>[pick.label, (keybinding as dynamic).getAriaLabel()])
        : pick.label;

    // Add remove button for recently used items (as the last button, to the
    // right)
    final List<IQuickInputButton> existingButtons =
        pick.buttons ?? <IQuickInputButton>[];
    final List<IQuickInputButton>? buttons = isRecentlyUsed
        ? <IQuickInputButton>[
            ...existingButtons,
            IQuickInputButton(
              iconClass: ThemeIcon.asClassName(Codicon['close']!),
              tooltip: localize('removeFromRecentlyUsed',
                  'Remove from Recently Used'),
            )
          ]
        : pick.buttons;

    return _copyCommandPick(
      pick,
      id: pick.commandId,
      tooltip: tooltip,
      ariaLabel: ariaLabel,
      detail: _options.showAlias && pick.commandAlias != pick.label
          ? pick.commandAlias
          : null,
      keybinding: keybinding,
      buttons: buttons,
      accept: (IKeyMods keyMods, IQuickPickDidAcceptEvent event) {
        _acceptCommand(pick, runOptions);
      },
      trigger: isRecentlyUsed
          ? (int buttonIndex, IKeyMods keyMods) {
              // The remove button is now the last button
              final int removeButtonIndex = existingButtons.length;
              if (buttonIndex == removeButtonIndex) {
                commandsHistory.remove(pick.commandId);
                return TriggerAction.REMOVE_ITEM;
              }
              // Handle other buttons (e.g., configure keybinding button)
              final Object? Function(int, IKeyMods)? pickTrigger = pick.trigger;
              if (pickTrigger != null) {
                return pickTrigger(buttonIndex, keyMods);
              }
              return TriggerAction.NO_ACTION;
            }
          : pick.trigger,
    );
  }

  /// TS: the `async () => { ... }` body of the replaced `accept` slot.
  Future<void> _acceptCommand(
    ICommandQuickPick commandPick,
    IQuickAccessProviderRunOptions? runOptions,
  ) async {
    // Add to history
    commandsHistory.push(commandPick.commandId);

    // Telementry
    _telemetryService.publicLog2(
        'workbenchActionExecuted',
        WorkbenchActionExecutedEvent(
            commandPick.commandId, runOptions?.from ?? 'quick open'));

    // Run
    try {
      final List<Object?>? args = commandPick.args;
      if (args != null && args.isNotEmpty) {
        await _commandService.executeCommand(commandPick.commandId, args);
      } else {
        await _commandService.executeCommand(
            commandPick.commandId, const <Object?>[]);
      }
    } catch (error) {
      if (!isCancellationError(error)) {
        await _dialogService.error(
            localize('canNotRun', "Command '{0}' resulted in an error",
                <Object?>[commandPick.label]),
            toErrorMessage(error));
      }
    }
  }

  /// TF-IDF string to be indexed
  String getTfIdfChunk(ICommandQuickPick pick) {
    final String label = pick.label;
    final String? commandAlias = pick.commandAlias;
    final ILocalizedString? commandDescription = pick.commandDescription;
    String chunk = label;
    if (commandAlias != null &&
        commandAlias.isNotEmpty &&
        commandAlias != label) {
      chunk += ' - $commandAlias';
    }
    if (commandDescription != null && commandDescription.value != label) {
      // If the original is the same as the value, don't add it
      chunk += ' - ${commandDescription.value == commandDescription.original ? commandDescription.value : '${commandDescription.value} (${commandDescription.original})'}';
    }
    return chunk;
  }

  /// TS: `protected abstract getCommandPicks`. Public for the same reason as
  /// `getPicks` in `PickerQuickAccessProvider`.
  Future<List<ICommandQuickPick>> getCommandPicks(CancellationToken token);

  /// TS: `protected abstract hasAdditionalCommandPicks`.
  bool hasAdditionalCommandPicks(String filter, CancellationToken token);

  /// TS: `protected abstract getAdditionalCommandPicks`.
  Future<List<Object>> getAdditionalCommandPicks(
    List<ICommandQuickPick> allPicks,
    List<ICommandQuickPick> picksSoFar,
    String filter,
    CancellationToken token,
  );
}

/// 1:1: `interface ISerializedCommandHistory`.
class _SerializedCommandHistory {
  _SerializedCommandHistory({this.usesLRU, required this.entries});

  final bool? usesLRU;
  final List<_SerializedCommandHistoryEntry> entries;

  Map<String, Object?> toJson() => <String, Object?>{
        'usesLRU': usesLRU,
        'entries': entries
            .map((_SerializedCommandHistoryEntry entry) => entry.toJson())
            .toList(),
      };
}

class _SerializedCommandHistoryEntry {
  _SerializedCommandHistoryEntry(this.key, this.value);

  final String key;
  final num value;

  Map<String, Object?> toJson() =>
      <String, Object?>{'key': key, 'value': value};
}

/// JS optional-chaining property read over a plain object literal: config
/// values arrive either as `Map` or as dynamically-typed carriers.
Object? _pluck(Object? value, String key) {
  if (value == null) {
    return null;
  }
  if (value is Map) {
    return value[key];
  }
  if (value is ICommandsQuickAccessConfiguration) {
    switch (key) {
      case 'workbench':
        return value.workbench;
    }
    return null;
  }
  if (value is ICommandsQuickAccessWorkbenchConfiguration) {
    switch (key) {
      case 'commandPalette':
        return value.commandPalette;
    }
    return null;
  }
  if (value is ICommandPaletteConfiguration) {
    switch (key) {
      case 'history':
        return value.history;
      case 'preserveInput':
        return value.preserveInput;
    }
    return null;
  }
  return null;
}

/// 1:1: `interface ICommandsQuickAccessConfiguration`.
class ICommandsQuickAccessConfiguration {
  ICommandsQuickAccessConfiguration({required this.workbench});

  final ICommandsQuickAccessWorkbenchConfiguration? workbench;
}

class ICommandsQuickAccessWorkbenchConfiguration {
  ICommandsQuickAccessWorkbenchConfiguration({required this.commandPalette});

  final ICommandPaletteConfiguration? commandPalette;
}

class ICommandPaletteConfiguration {
  ICommandPaletteConfiguration(
      {required this.history, required this.preserveInput});

  final int history;
  final bool preserveInput;
}

/// 1:1: `export class CommandsHistory extends Disposable`.
class CommandsHistory extends lifecycle.Disposable {
  CommandsHistory(
    this._storageService,
    this._configurationService,
    this._logService,
  ) {
    updateConfiguration();
    load();

    registerListeners();
  }

  static const int DEFAULT_COMMANDS_HISTORY_LENGTH = 50;

  static const String _PREF_KEY_CACHE = 'commandPalette.mru.cache';
  static const String _PREF_KEY_COUNTER = 'commandPalette.mru.counter';

  // private static in source.
  static LRUCache<String, num>? cache;
  static int counter = 1;
  static bool hasChanges = false;

  // private in source.
  final IStorageServiceType _storageService;
  final IConfigurationServiceType _configurationService;
  final ILogServiceType _logService;

  int _configuredCommandsHistoryLength = 0;

  void registerListeners() {
    register(_configurationService.onDidChangeConfiguration(
        (IConfigurationChangeEvent e) => updateConfiguration(e)));
    register(_storageService.onWillSaveState((WillSaveStateEvent e) {
      if (e.reason == WillSaveStateReason.SHUTDOWN) {
        // Commands history is very dynamic and so we limit impact
        // on storage to only save on shutdown. This helps reduce
        // the overhead of syncing this data across machines.
        saveState();
      }
    }));
  }

  void updateConfiguration([IConfigurationChangeEvent? e]) {
    if (e != null && !e.affectsConfiguration('workbench.commandPalette.history')) {
      return;
    }

    _configuredCommandsHistoryLength =
        CommandsHistory.getConfiguredCommandHistoryLength(_configurationService);

    final LRUCache<String, num>? existing = CommandsHistory.cache;
    if (existing != null &&
        existing.limit != _configuredCommandsHistoryLength) {
      existing.limit = _configuredCommandsHistoryLength;
      CommandsHistory.hasChanges = true;
    }
  }

  void load() {
    final String? raw = _storageService.get(
        CommandsHistory._PREF_KEY_CACHE, StorageScope.PROFILE);
    _SerializedCommandHistory? serializedCache;
    if (raw != null && raw.isNotEmpty) {
      try {
        final Object? decoded = convert.jsonDecode(raw);
        if (decoded is Map) {
          final Object? entriesValue = decoded['entries'];
          serializedCache = _SerializedCommandHistory(
            usesLRU: decoded['usesLRU'] as bool?,
            entries: entriesValue is List
                ? entriesValue
                    .whereType<Map>()
                    .map((Map entry) => _SerializedCommandHistoryEntry(
                          entry['key'] as String,
                          entry['value'] as num,
                        ))
                    .toList()
                : <_SerializedCommandHistoryEntry>[],
          );
        }
      } catch (error) {
        _logService.error('[CommandsHistory] invalid data: $error');
      }
    }

    final LRUCache<String, num> cache = CommandsHistory.cache =
        LRUCache<String, num>(_configuredCommandsHistoryLength, 1);
    if (serializedCache != null) {
      List<_SerializedCommandHistoryEntry> entries;
      if (serializedCache.usesLRU == true) {
        entries = serializedCache.entries;
      } else {
        entries = List<_SerializedCommandHistoryEntry>.of(
            serializedCache.entries)
          ..sort((_SerializedCommandHistoryEntry a,
                  _SerializedCommandHistoryEntry b) =>
              a.value.compareTo(b.value));
      }
      for (final _SerializedCommandHistoryEntry entry in entries) {
        cache.set(entry.key, entry.value);
      }
    }

    CommandsHistory.counter =
        (_storageService.getNumber(CommandsHistory._PREF_KEY_COUNTER,
                    StorageScope.PROFILE, CommandsHistory.counter) ??
                CommandsHistory.counter)
            .toInt();
  }

  void push(String commandId) {
    final LRUCache<String, num>? cache = CommandsHistory.cache;
    if (cache == null) {
      return;
    }

    cache.set(commandId, CommandsHistory.counter++); // set counter to command
    CommandsHistory.hasChanges = true;
  }

  num? peek(String commandId) {
    return CommandsHistory.cache?.peek(commandId);
  }

  void remove(String commandId) {
    final LRUCache<String, num>? cache = CommandsHistory.cache;
    if (cache == null) {
      return;
    }

    cache.delete(commandId);
    CommandsHistory.hasChanges = true;
  }

  void saveState() {
    final LRUCache<String, num>? cache = CommandsHistory.cache;
    if (cache == null) {
      return;
    }

    if (!CommandsHistory.hasChanges) {
      return;
    }

    final _SerializedCommandHistory serializedCache =
        _SerializedCommandHistory(
            usesLRU: true, entries: <_SerializedCommandHistoryEntry>[]);
    cache.forEach(
        (num value, String key, LinkedMap<String, num> _) {
      serializedCache.entries.add(_SerializedCommandHistoryEntry(key, value));
    });

    _storageService.store(CommandsHistory._PREF_KEY_CACHE,
        convert.jsonEncode(serializedCache.toJson()), StorageScope.PROFILE,
        StorageTarget.USER);
    _storageService.store(CommandsHistory._PREF_KEY_COUNTER,
        CommandsHistory.counter, StorageScope.PROFILE, StorageTarget.USER);
    CommandsHistory.hasChanges = false;
  }

  static int getConfiguredCommandHistoryLength(
      IConfigurationServiceType configurationService) {
    final Object? config = configurationService.getValue$0();

    final Object? configuredCommandHistoryLength =
        _pluck(_pluck(_pluck(config, 'workbench'), 'commandPalette'), 'history');
    if (configuredCommandHistoryLength is num) {
      return configuredCommandHistoryLength.toInt();
    }

    return CommandsHistory.DEFAULT_COMMANDS_HISTORY_LENGTH;
  }

  static void clearHistory(IConfigurationServiceType configurationService,
      IStorageServiceType storageService) {
    final int commandHistoryLength =
        CommandsHistory.getConfiguredCommandHistoryLength(configurationService);
    CommandsHistory.cache = LRUCache<String, num>(commandHistoryLength);
    CommandsHistory.counter = 1;

    CommandsHistory.hasChanges = true;
  }
}