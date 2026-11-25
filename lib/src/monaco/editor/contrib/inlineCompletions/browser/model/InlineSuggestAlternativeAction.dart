// ---------------------------------------------------------------------------
// 1:1 port of
// vscode/src/vs/editor/contrib/inlineCompletions/browser/model/
// InlineSuggestAlternativeAction.ts (19 lines).
//
// TS declares a `type` alias plus a merged namespace holding one function. The
// alias is carried by a plain class (Dart has no object type aliases), and the
// namespace function becomes a static:
//   - `InlineSuggestAlternativeAction.toString` collides with `Object.toString`,
//     so it is `toStringStatic` (same convention as `MarkerSeverity`).
//
// The TS signature says `string | undefined`, but the body returns the raw
// `command.id` (`action?.command.id ?? undefined`), so a numeric id leaks
// through. The port keeps the **runtime** behaviour and returns `Object?`.
// Like the source, it throws when `command` is null/undefined while `action`
// is present (`action?.command.id` only guards `action`).
// ---------------------------------------------------------------------------

import '../../../../../base/common/themables.dart' show ThemeIcon;

class InlineSuggestAlternativeAction {
  InlineSuggestAlternativeAction({
    required this.label,
    required this.icon,
    required this.command,
    required this.count,
  });

  final String label;
  final ThemeIcon icon;

  /// TS `Command` (erased interface).
  final Object? command;

  final Future<int> count;

  static Object? toStringStatic(Object? action) {
    if (action == null) {
      return null; // `action?.`
    }
    final Object? command = _member(action, 'command');
    final Object? id = _idOf(command);
    return id ?? null; // `?? undefined`
  }
}

/// Reads `obj[member]` like JS: object literals are `Map`s, records expose
/// getters, primitives expose nothing.
Object? _member(Object? obj, String member) {
  if (obj == null) {
    return null;
  }
  if (obj is Map) {
    return obj[member];
  }
  if (obj is num || obj is String || obj is bool || obj is List) {
    return null;
  }
  return (obj as dynamic).noSuchMethod(Invocation.getter(Symbol(member)));
}

/// `action?.command.id` dereferences `command` unconditionally: a null command
/// throws, exactly like the TypeScript runtime.
Object? _idOf(Object? command) {
  if (command == null) {
    throw NoSuchMethodError.withInvocation(
        null, Invocation.getter(const Symbol('id')));
  }
  return _member(command, 'id');
}
