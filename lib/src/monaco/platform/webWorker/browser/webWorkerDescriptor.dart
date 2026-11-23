// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/webWorker/browser/webWorkerDescriptor.ts
// Translated 1:1. `URI` and `URL` are opaque carriers; the union
// `URI | (() => URI)` is modelled as `Object?` holding either a URI carrier or
// a `Object Function()` thunk, preserving the source's lazy-location form.
// ---------------------------------------------------------------------------

/// 1:1: `export class WebWorkerDescriptor`
class WebWorkerDescriptor {
  WebWorkerDescriptor({
    required this.label,
    this.esmModuleLocation,
    this.esmModuleLocationBundler,
  });

  /// 1:1: `readonly esmModuleLocation: URI | (() => URI) | undefined`
  final Object? esmModuleLocation;

  /// 1:1: `readonly esmModuleLocationBundler: URL | (() => URL) | undefined`
  final Object? esmModuleLocationBundler;

  /// 1:1: `readonly label: string`
  final String label;
}
