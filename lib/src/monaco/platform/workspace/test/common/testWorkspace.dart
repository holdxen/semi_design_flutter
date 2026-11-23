// 1:1 port of vs/platform/workspace/test/common/testWorkspace.ts
// ignore_for_file: unused_element_parameter
import '../../../../base/common/platform.dart' show isLinux, isWindows;
import '../../../../base/common/uri.dart' show URI;
import '../../common/workspace.dart' as ws
    show IWorkspace, IWorkspaceFolder, Workspace, WorkspaceFolder,
        toWorkspaceFolder;

/// 1:1: `export class Workspace extends BaseWorkspace`
/// TS defaults: `folders = []`, `configuration = null`, `ignorePathCasing = () => !isLinux`.
class Workspace extends ws.Workspace {
  Workspace(
    String id, [
    List<ws.WorkspaceFolder>? folders,
    URI? configuration,
    bool Function(URI)? ignorePathCasing,
  ]) : super(
          id,
          folders ?? <ws.WorkspaceFolder>[],
          false,
          configuration,
          ignorePathCasing ?? ((_) => !isLinux),
        );
}

/// 1:1: `const wsUri = URI.file(isWindows ? 'C:\\testWorkspace' : '/testWorkspace')`
final URI _wsUri = URI.file(isWindows ? 'C:\\testWorkspace' : '/testWorkspace');

/// 1:1: `export const TestWorkspace = testWorkspace(wsUri)`
final Workspace TestWorkspace = testWorkspace(<URI>[_wsUri]);

/// 1:1: `export function testWorkspace(...resource: URI[]): Workspace`
/// Dart has no rest parameters; the variadic URI list is a `List<URI>` carrier.
Workspace testWorkspace([List<URI> resource = const <URI>[]]) =>
    Workspace('test-workspace', resource.map(ws.toWorkspaceFolder).toList());

/// 1:1 carrier for `Omit<IWorkspace,'uri'> & { uri?: URI }`.
class WorkspaceInput {
  final String id;
  final List<ws.IWorkspaceFolder> folders;
  final bool? transient;
  final URI? configuration;
  final String? name;
  final URI? uri;
  WorkspaceInput({
    required this.id,
    required this.folders,
    this.transient,
    this.configuration,
    this.name,
    this.uri,
  });
}

/// Minimal `IWorkspace` carrier produced by [testIWorkspace].
class _TestIWorkspace implements ws.IWorkspace {
  @override
  final String id;
  @override
  final URI? uri;
  @override
  final List<ws.IWorkspaceFolder> folders;
  @override
  final bool? transient;
  @override
  final URI? configuration;
  @override
  final String? name;
  _TestIWorkspace({
    required this.id,
    required this.uri,
    required this.folders,
    required this.transient,
    required this.configuration,
    required this.name,
  });
}

/// 1:1: `testIWorkspace(workspace): IWorkspace`
/// Returns `{ uri: workspace.configuration ?? (folders.length === 1 ? folders[0].uri : undefined), ...workspace }`.
/// TS spread: an explicit `workspace.uri` overrides the computed uri.
ws.IWorkspace testIWorkspace(WorkspaceInput workspace) {
  final computedUri = workspace.configuration ??
      (workspace.folders.length == 1 ? workspace.folders[0].uri : null);
  final effectiveUri = workspace.uri ?? computedUri;
  return _TestIWorkspace(
    id: workspace.id,
    uri: effectiveUri,
    folders: workspace.folders,
    transient: workspace.transient,
    configuration: workspace.configuration,
    name: workspace.name,
  );
}
