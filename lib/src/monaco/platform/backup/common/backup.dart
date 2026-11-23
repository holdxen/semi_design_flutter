// 1:1 port of vs/platform/backup/common/backup.ts
// Declaration module + two hasOwnProperty-based type guards.
import '../../../base/common/uri.dart' show URI;
import '../../workspace/common/workspace.dart' show IWorkspaceIdentifier;

/// 1:1: `export const WORKING_COPY_BACKUP_TEMP_FILE_SUFFIX = '.vsctmp'`
const String WORKING_COPY_BACKUP_TEMP_FILE_SUFFIX = '.vsctmp';

/// 1:1: `export interface IBaseBackupInfo { remoteAuthority?: string }`
abstract class IBaseBackupInfo {
  String? get remoteAuthority;
}

/// 1:1: `export interface IWorkspaceBackupInfo extends IBaseBackupInfo`
abstract class IWorkspaceBackupInfo implements IBaseBackupInfo {
  IWorkspaceIdentifier get workspace;
}

/// 1:1: `export interface IFolderBackupInfo extends IBaseBackupInfo`
abstract class IFolderBackupInfo implements IBaseBackupInfo {
  URI get folderUri;
}

/// 1:1: `isFolderBackupInfo(curr): curr is IFolderBackupInfo`
/// Source: `return curr?.hasOwnProperty('folderUri');` — an own-property check.
/// JS objects map to either a Map carrier (own key) or a concrete implementing
/// class (own field); prototype-inherited keys are excluded (matches truth).
bool isFolderBackupInfo(Object? curr) {
  if (curr == null) return false;
  if (curr is Map) return curr.containsKey('folderUri');
  return curr is IFolderBackupInfo;
}

/// 1:1: `isWorkspaceBackupInfo(curr): curr is IWorkspaceBackupInfo`
/// Source: `return curr?.hasOwnProperty('workspace');`
bool isWorkspaceBackupInfo(Object? curr) {
  if (curr == null) return false;
  if (curr is Map) return curr.containsKey('workspace');
  return curr is IWorkspaceBackupInfo;
}
