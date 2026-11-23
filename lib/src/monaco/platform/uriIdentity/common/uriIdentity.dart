// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/uriIdentity/common/uriIdentity.ts
// Translated 1:1 from TypeScript. Pure declaration: one service const/interface
// pair -> const keeps the name, interface gets the `Type` suffix.
// ---------------------------------------------------------------------------

import '../../../base/common/resources.dart' show IExtUri;
import '../../../base/common/uri.dart' show URI;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;

/// 1:1: `export const IUriIdentityService = createDecorator<IUriIdentityService>('IUriIdentityService')`
final ServiceIdentifier<IUriIdentityServiceType> IUriIdentityService =
    createDecorator<IUriIdentityServiceType>('IUriIdentityService');

/// 1:1: `export interface IUriIdentityService`
abstract class IUriIdentityServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  /// Uri extensions that are aware of casing.
  IExtUri get extUri;

  /// Returns a canonical uri for the given resource. Different uris can point to the same
  /// resource. That's because of casing or missing normalization, e.g the following uris
  /// are different but refer to the same document (because windows paths are not case-sensitive)
  ///
  /// ```txt
  /// file:///c:/foo/bar.txt
  /// file:///c:/FOO/BAR.txt
  /// ```
  ///
  /// This function should be invoked when feeding uris into the system that represent the truth,
  /// e.g document uris or marker-to-document associations etc. This function should NOT be called
  /// to pretty print a label nor to sanitize a uri.
  ///
  /// Samples:
  ///
  /// | in | out | |
  /// |---|---|---|
  /// | `file:///foo/bar/../bar` | `file:///foo/bar` | n/a |
  /// | `file:///foo/bar/../bar#frag` | `file:///foo/bar#frag` | keep fragment |
  /// | `file:///foo/BAR` | `file:///foo/bar` | assume ignore case |
  /// | `file:///foo/bar/../BAR?q=2` | `file:///foo/BAR?q=2` | query makes it a different document |
  URI asCanonicalUri(URI uri);
}
