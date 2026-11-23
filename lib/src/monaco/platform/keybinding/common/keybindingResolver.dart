// 1:1 port of vs/platform/keybinding/common/keybindingResolver.ts
// Truth: tool/ts2dart/batch126_truth.json (real transpiled TypeScript runtime).
// ---------------------------------------------------------------------------
// Constants that are registered after startup are substituted exactly as in
// contextkey.ts; `when` expressions reuse the already-ported contextkey.dart.
// ---------------------------------------------------------------------------

import '../../contextkey/common/contextkey.dart' as contextkey;
import 'keybindingsRegistry.dart' as registry;
import 'resolvedKeybindingItem.dart' as resolved;

/// 1:1: `export const enum ResultKind`
class ResultKind {
  static const int NoMatchingKb = 0;
  static const int MoreChordsNeeded = 1;
  static const int KbFound = 2;
}

/// 1:1: `export type ResolutionResult = ...`
class ResolutionResult {
  const ResolutionResult._(this.kind, this.commandId, this.commandArgs, this.isBubble);

  final int kind;
  final String? commandId;
  final Object? commandArgs;
  final bool? isBubble;

  factory ResolutionResult.noMatchingKb() =>
      const ResolutionResult._(ResultKind.NoMatchingKb, null, null, null);

  factory ResolutionResult.moreChordsNeeded() =>
      const ResolutionResult._(ResultKind.MoreChordsNeeded, null, null, null);

  factory ResolutionResult.kbFound(String? commandId, Object? commandArgs, bool isBubble) =>
      ResolutionResult._(ResultKind.KbFound, commandId, commandArgs, isBubble);
}

/// 1:1: `export const NoMatchingKb: ResolutionResult`
const ResolutionResult NoMatchingKb = ResolutionResult._(
    ResultKind.NoMatchingKb, null, null, null);

/// 1:1: `const MoreChordsNeeded: ResolutionResult`
const ResolutionResult _moreChordsNeeded = ResolutionResult._(
    ResultKind.MoreChordsNeeded, null, null, null);

/// 1:1: `function KbFound(...)`
ResolutionResult _kbFound(String? commandId, Object? commandArgs, bool isBubble) =>
    ResolutionResult.kbFound(commandId, commandArgs, isBubble);

/// 1:1: `export class KeybindingResolver`
class KeybindingResolver {
  final void Function(String) _log;
  final List<resolved.ResolvedKeybindingItem> _defaultKeybindings;
  late final List<resolved.ResolvedKeybindingItem> _keybindings;
  final Map<String, bool> _defaultBoundCommands = <String, bool>{};
  final Map<String, List<resolved.ResolvedKeybindingItem>> _map =
      <String, List<resolved.ResolvedKeybindingItem>>{};
  final Map<String, List<resolved.ResolvedKeybindingItem>> _lookupMap =
      <String, List<resolved.ResolvedKeybindingItem>>{};

  /// 1:1: constructor(defaultKeybindings, overrides, log)
  KeybindingResolver(
    List<resolved.ResolvedKeybindingItem> defaultKeybindings,
    List<resolved.ResolvedKeybindingItem> overrides,
    void Function(String str) log,
  )   : _log = log,
        _defaultKeybindings = defaultKeybindings {
    for (final resolved.ResolvedKeybindingItem defaultKeybinding
        in defaultKeybindings) {
      final String? command = defaultKeybinding.command;
      if (command != null &&
          command.isNotEmpty &&
          command[0] != '-') {
        _defaultBoundCommands[command] = true;
      }
    }

    _keybindings = KeybindingResolver.handleRemovals(
        <resolved.ResolvedKeybindingItem>[...defaultKeybindings, ...overrides]);
    for (final resolved.ResolvedKeybindingItem k in _keybindings) {
      if (k.chords.isEmpty) {
        // unbound
        continue;
      }

      // substitute with constants that are registered after startup
      final contextkey.ContextKeyExpression? when = k.when?.substituteConstants();

      if (when != null &&
          when.type == contextkey.ContextKeyExprType.False) {
        continue;
      }

      _addKeyPress(k.chords[0], k);
    }
  }

  /// 1:1: `private static _isTargetedForRemoval(...)`
  static bool _isTargetedForRemoval(
    resolved.ResolvedKeybindingItem defaultKb,
    List<String>? keypress,
    contextkey.ContextKeyExpression? when,
  ) {
    if (keypress != null) {
      for (int i = 0; i < keypress.length; i++) {
        if (keypress[i] != defaultKb.chords[i]) {
          return false;
        }
      }
    }

    // `true` means always, as does `undefined`
    if (when != null && when.type != contextkey.ContextKeyExprType.True) {
      if (defaultKb.when == null) {
        return false;
      }

      final contextkey.ContextKeyExpression? defaultWhen =
          defaultKb.when!.substituteConstants();
      final contextkey.ContextKeyExpression? removalWhen =
          when.substituteConstants();
      if (!KeybindingResolver.whenIsEntirelyIncluded(
          defaultWhen, removalWhen)) {
        return false;
      }
    }
    return true;
  }

  /// 1:1: `public static handleRemovals(...)`
  static List<resolved.ResolvedKeybindingItem> handleRemovals(
      List<resolved.ResolvedKeybindingItem> rules) {
    // Do a first pass and construct a hash-map for removals
    final Map<String, List<resolved.ResolvedKeybindingItem>> removals =
        <String, List<resolved.ResolvedKeybindingItem>>{};
    for (final resolved.ResolvedKeybindingItem rule in rules) {
      final String? command = rule.command;
      if (command != null && command.isNotEmpty && command[0] == '-') {
        final String name = command.substring(1);
        final List<resolved.ResolvedKeybindingItem>? existing = removals[name];
        if (existing == null) {
          removals[name] = <resolved.ResolvedKeybindingItem>[rule];
        } else {
          existing.add(rule);
        }
      }
    }

    if (removals.isEmpty) {
      return rules;
    }

    // Do a second pass and keep only non-removed keybindings
    final List<resolved.ResolvedKeybindingItem> result =
        <resolved.ResolvedKeybindingItem>[];
    for (final resolved.ResolvedKeybindingItem rule in rules) {
      final String? command = rule.command;
      if (command == null || command.isEmpty) {
        result.add(rule);
        continue;
      }
      if (command[0] == '-') {
        continue;
      }
      final List<resolved.ResolvedKeybindingItem>? commandRemovals =
          removals[command];
      if (commandRemovals == null || !rule.isDefault) {
        result.add(rule);
        continue;
      }
      bool isRemoved = false;
      for (final resolved.ResolvedKeybindingItem commandRemoval
          in commandRemovals) {
        if (KeybindingResolver._isTargetedForRemoval(
            rule, commandRemoval.chords, commandRemoval.when)) {
          isRemoved = true;
          break;
        }
      }
      if (!isRemoved) {
        result.add(rule);
      }
    }
    return result;
  }

  /// 1:1: `public static applyAliases(...)`
  static AliasResult applyAliases(
    List<resolved.ResolvedKeybindingItem> defaults,
    List<resolved.ResolvedKeybindingItem> overrides,
    List<registry.IKeybindingAlias> aliases,
  ) {
    if (aliases.isEmpty) {
      return AliasResult(defaults, overrides);
    }

    List<resolved.ResolvedKeybindingItem> inherit(
        List<resolved.ResolvedKeybindingItem> rules) {
      final List<resolved.ResolvedKeybindingItem> result =
          <resolved.ResolvedKeybindingItem>[];
      for (final resolved.ResolvedKeybindingItem rule in rules) {
        result.add(rule);
        for (final registry.IKeybindingAlias alias in aliases) {
          if (rule.command == alias.source) {
            result.add(resolved.ResolvedKeybindingItem(
              rule.resolvedKeybinding,
              alias.command,
              null,
              alias.when as contextkey.ContextKeyExpression?,
              true,
              rule.extensionId,
              rule.isBuiltinExtension,
            ));
          }
        }
      }
      return result;
    }

    final List<resolved.ResolvedKeybindingItem> sourceRemovals = [
      ...defaults, ...overrides
    ].where((resolved.ResolvedKeybindingItem rule) => aliases.any(
        (registry.IKeybindingAlias alias) =>
            rule.command == '-${alias.source}')).toList();

    bool isRemovedWithSource(resolved.ResolvedKeybindingItem rule) =>
        aliases.any((registry.IKeybindingAlias alias) =>
            rule.command == alias.command &&
            sourceRemovals.any((resolved.ResolvedKeybindingItem removal) =>
                removal.command == '-${alias.source}' &&
                KeybindingResolver._isTargetedForRemoval(
                    rule, removal.chords, null)));

    return AliasResult(
      inherit(defaults)
          .where((resolved.ResolvedKeybindingItem rule) =>
              !isRemovedWithSource(rule))
          .toList(),
      inherit(overrides),
    );
  }

  /// 1:1: `private _addKeyPress(...)`
  void _addKeyPress(String keypress, resolved.ResolvedKeybindingItem item) {
    final List<resolved.ResolvedKeybindingItem>? conflicts = _map[keypress];

    if (conflicts == null) {
      _map[keypress] = <resolved.ResolvedKeybindingItem>[item];
      _addToLookupMap(item);
      return;
    }

    for (int i = conflicts.length - 1; i >= 0; i--) {
      final resolved.ResolvedKeybindingItem conflict = conflicts[i];

      if (conflict.command == item.command) {
        continue;
      }

      bool isShorterKbPrefix = true;
      for (int j = 1;
          j < conflict.chords.length && j < item.chords.length;
          j++) {
        if (conflict.chords[j] != item.chords[j]) {
          isShorterKbPrefix = false;
          break;
        }
      }
      if (!isShorterKbPrefix) {
        continue;
      }

      if (KeybindingResolver.whenIsEntirelyIncluded(
          conflict.when, item.when)) {
        _removeFromLookupMap(conflict);
      }
    }

    conflicts.add(item);
    _addToLookupMap(item);
  }

  /// 1:1: `private _addToLookupMap(...)`
  void _addToLookupMap(resolved.ResolvedKeybindingItem item) {
    final String? command = item.command;
    if (command == null || command.isEmpty) {
      return;
    }

    final List<resolved.ResolvedKeybindingItem>? arr = _lookupMap[command];
    if (arr == null) {
      _lookupMap[command] = <resolved.ResolvedKeybindingItem>[item];
    } else {
      arr.add(item);
    }
  }

  /// 1:1: `private _removeFromLookupMap(...)`
  void _removeFromLookupMap(resolved.ResolvedKeybindingItem item) {
    final String? command = item.command;
    if (command == null || command.isEmpty) {
      return;
    }
    final List<resolved.ResolvedKeybindingItem>? arr = _lookupMap[command];
    if (arr == null) {
      return;
    }
    for (int i = 0; i < arr.length; i++) {
      if (identical(arr[i], item)) {
        arr.removeAt(i);
        return;
      }
    }
  }

  /// 1:1: `public static whenIsEntirelyIncluded(a, b)`
  static bool whenIsEntirelyIncluded(
    contextkey.ContextKeyExpression? a,
    contextkey.ContextKeyExpression? b,
  ) {
    if (b == null || b.type == contextkey.ContextKeyExprType.True) {
      return true;
    }
    if (a == null || a.type == contextkey.ContextKeyExprType.True) {
      return false;
    }

    return contextkey.implies(a, b);
  }

  /// 1:1: `public getDefaultBoundCommands()`
  Map<String, bool> getDefaultBoundCommands() => _defaultBoundCommands;

  /// 1:1: `public getDefaultKeybindings()`
  List<resolved.ResolvedKeybindingItem> getDefaultKeybindings() =>
      _defaultKeybindings;

  /// 1:1: `public getKeybindings()`
  List<resolved.ResolvedKeybindingItem> getKeybindings() => _keybindings;

  /// 1:1: `public lookupKeybindings(commandId)`
  List<resolved.ResolvedKeybindingItem> lookupKeybindings(String commandId) {
    final List<resolved.ResolvedKeybindingItem>? items = _lookupMap[commandId];
    if (items == null || items.isEmpty) {
      return <resolved.ResolvedKeybindingItem>[];
    }

    // Reverse to get the most specific item first
    final List<resolved.ResolvedKeybindingItem> result =
        <resolved.ResolvedKeybindingItem>[];
    for (int i = items.length - 1; i >= 0; i--) {
      result.add(items[i]);
    }
    return result;
  }

  /// 1:1: `public lookupPrimaryKeybinding(commandId, context, enforceContextCheck)`
  resolved.ResolvedKeybindingItem? lookupPrimaryKeybinding(
    String commandId,
    contextkey.IContextKeyServiceType context, [
    bool enforceContextCheck = false,
  ]) {
    final List<resolved.ResolvedKeybindingItem>? items = _lookupMap[commandId];
    if (items == null || items.isEmpty) {
      return null;
    }
    if (items.length == 1 && !enforceContextCheck) {
      return items[0];
    }

    for (int i = items.length - 1; i >= 0; i--) {
      final resolved.ResolvedKeybindingItem item = items[i];
      if (context.contextMatchesRules(item.when)) {
        return item;
      }
    }

    if (enforceContextCheck) {
      return null;
    }

    return items[items.length - 1];
  }

  /// 1:1: `public resolve(context, currentChords, keypress)`
  ResolutionResult resolve(
    contextkey.IContext context,
    List<String> currentChords,
    String keypress,
  ) {
    final List<String> pressedChords = [...currentChords, keypress];

    _log('| Resolving ${pressedChords.join(',')}');

    final List<resolved.ResolvedKeybindingItem>? kbCandidates =
        _map[pressedChords[0]];
    if (kbCandidates == null) {
      _log('\\ No keybinding entries.');
      return NoMatchingKb;
    }

    List<resolved.ResolvedKeybindingItem>? lookupMap;
    if (pressedChords.length < 2) {
      lookupMap = kbCandidates;
    } else {
      lookupMap = <resolved.ResolvedKeybindingItem>[];
      for (final resolved.ResolvedKeybindingItem candidate in kbCandidates) {
        if (pressedChords.length > candidate.chords.length) {
          continue;
        }

        bool prefixMatches = true;
        for (int i = 1; i < pressedChords.length; i++) {
          if (candidate.chords[i] != pressedChords[i]) {
            prefixMatches = false;
            break;
          }
        }
        if (prefixMatches) {
          lookupMap.add(candidate);
        }
      }
    }

    final resolved.ResolvedKeybindingItem? result =
        _findCommand(context, lookupMap);
    if (result == null) {
      _log('\\ From ${lookupMap.length} keybinding entries, no when clauses matched the context.');
      return NoMatchingKb;
    }

    if (pressedChords.length < result.chords.length) {
      _log('\\ From ${lookupMap.length} keybinding entries, awaiting ${result.chords.length - pressedChords.length} more chord(s), when: ${_printWhenExplanation(result.when)}, source: ${_printSourceExplanation(result)}.');
      return _moreChordsNeeded;
    }

    _log('\\ From ${lookupMap.length} keybinding entries, matched ${result.command}, when: ${_printWhenExplanation(result.when)}, source: ${_printSourceExplanation(result)}.');

    return _kbFound(result.command, result.commandArgs, result.bubble);
  }

  /// 1:1: `private _findCommand(...)`
  resolved.ResolvedKeybindingItem? _findCommand(
    contextkey.IContext context,
    List<resolved.ResolvedKeybindingItem> matches,
  ) {
    for (int i = matches.length - 1; i >= 0; i--) {
      final resolved.ResolvedKeybindingItem k = matches[i];

      if (!KeybindingResolver._contextMatchesRules(context, k.when)) {
        continue;
      }

      return k;
    }

    return null;
  }

  /// 1:1: `private static _contextMatchesRules(...)`
  static bool _contextMatchesRules(
    contextkey.IContext context,
    contextkey.ContextKeyExpression? rules,
  ) {
    if (rules == null) {
      return true;
    }
    return rules.evaluate(context);
  }
}

/// 1:1: anonymous `{ defaults, overrides }` result of `applyAliases`.
class AliasResult {
  const AliasResult(this.defaults, this.overrides);

  final List<resolved.ResolvedKeybindingItem> defaults;
  final List<resolved.ResolvedKeybindingItem> overrides;
}

/// 1:1: `function printWhenExplanation(...)`
String _printWhenExplanation(contextkey.ContextKeyExpression? when) {
  if (when == null) {
    return 'no when condition';
  }
  return when.serialize();
}

/// 1:1: `function printSourceExplanation(...)`
String _printSourceExplanation(resolved.ResolvedKeybindingItem kb) {
  final String? extensionId = kb.extensionId;
  if (extensionId != null) {
    return kb.isBuiltinExtension
        ? 'built-in extension $extensionId'
        : 'user extension $extensionId';
  }
  return kb.isDefault ? 'built-in' : 'user';
}
