// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/triggerInlineEditCommandsRegistry.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
// ---------------------------------------------------------------------------

/// 1:1: `export abstract class TriggerInlineEditCommandsRegistry`
///
/// The source class is abstract and only carries static members; in Dart this
/// is expressed as a class with a private constructor so it cannot be
/// instantiated, preserving the "registry namespace" shape.
abstract class TriggerInlineEditCommandsRegistry {
  static final Set<String> _registeredCommands = <String>{};

  /// 1:1: `getRegisteredCommands(): readonly string[]`
  static List<String> getRegisteredCommands() {
    return List<String>.from(_registeredCommands);
  }

  /// 1:1: `registerCommand(commandId: string): void`
  static void registerCommand(String commandId) {
    _registeredCommands.add(commandId);
  }
}
