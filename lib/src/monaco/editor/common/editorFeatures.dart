// 1:1 port of vs/editor/common/editorFeatures.ts
// A simple registry: register features, return a defensive copy.
// NOTE: `BrandedService` / `IConstructorSignature<IEditorFeature>` are type-only
// constraints in TS; they erase in Dart to the callable `EditorFeatureCtor`
// carrier below, so no import is required.

/// 1:1: `export interface IEditorFeature { /* Marker Interface */ }`
abstract class IEditorFeature {}

/// 1:1: `export type EditorFeatureCtor = IConstructorSignature<IEditorFeature>`
/// TS constructor signature -> callable carrier (a Dart constructor Function).
typedef EditorFeatureCtor = Function;

/// 1:1: `const editorFeatures: EditorFeatureCtor[] = []`
final List<EditorFeatureCtor> _editorFeatures = <EditorFeatureCtor>[];

/// 1:1: `registerEditorFeature<Services extends BrandedService[]>(ctor)`
/// Generic branded-services constraint is type-only -> erased; `ctor` is stored
/// as-is, exactly like the TS `editorFeatures.push(ctor as EditorFeatureCtor)`.
void registerEditorFeature(EditorFeatureCtor ctor) {
  _editorFeatures.add(ctor);
}

/// 1:1: `getEditorFeatures(): Iterable<EditorFeatureCtor>`
/// Source returns `editorFeatures.slice(0)` — a new array, so mutating the
/// returned value does not affect the registry (verified by truth).
Iterable<EditorFeatureCtor> getEditorFeatures() => _editorFeatures.toList();
