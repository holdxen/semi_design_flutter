// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/instantiation/common/descriptors.ts
// Translated 1:1 from TypeScript. `ctor: any` -> `Function`; the TS
// constructor type `new (...args) => T` collapses to `Function` because Dart
// has no reified constructor type. `unknown[]` -> `List<Object?>`.
// ---------------------------------------------------------------------------

/// 1:1: `export class SyncDescriptor<T>`
class SyncDescriptor<T> {
  /// 1:1: `readonly ctor: any`
  final Function ctor;

  /// 1:1: `readonly staticArguments: unknown[]`
  final List<Object?> staticArguments;

  /// 1:1: `readonly supportsDelayedInstantiation: boolean`
  final bool supportsDelayedInstantiation;

  SyncDescriptor(
    this.ctor, [
    List<Object?>? staticArguments,
    this.supportsDelayedInstantiation = false,
  ]) : staticArguments = staticArguments ?? <Object?>[];
}

/// 1:1: `export interface SyncDescriptor0<T>`
///
/// Dart has no distinct constructor type, so this is represented as a
/// marker interface over [SyncDescriptor] with an empty static-argument list.
abstract class SyncDescriptor0<T> {
  Function get ctor;
}
