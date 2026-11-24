import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/event.dart' show Event;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/platform/files/common/files.dart' as f;

final Map<String, Object?> _truth =
    json.decode(File('tool/ts2dart/batch146_truth.json').readAsStringSync())
        as Map<String, Object?>;

Map<String, Object?> _map(Object? v) => (v as Map).cast<String, Object?>();
List<Object?> _list(Object? v) => (v as List).cast<Object>();

class _Provider implements f.IFileSystemProvider {
  _Provider(this.capabilities);
  @override
  final int capabilities;
  @override
  Event<void> get onDidChangeCapabilities => throw UnimplementedError();
}

class _Change implements f.IFileChange {
  _Change(this.type, this.resource, [this.cId]);
  @override
  final int type;
  @override
  final URI resource;
  @override
  final int? cId;
}

void main() {
  test('enums 1:1 truth', () {
    expect(f.FileType.Unknown, _map(_truth['fileType'])['Unknown']);
    expect(f.FileType.File, _map(_truth['fileType'])['File']);
    expect(f.FileType.Directory, _map(_truth['fileType'])['Directory']);
    expect(f.FileType.SymbolicLink, _map(_truth['fileType'])['SymbolicLink']);
    expect(f.FilePermission.Executable,
        _map(_truth['filePermission'])['Executable']);
    expect(f.FileChangeType.UPDATED, _map(_truth['fileChangeType'])['UPDATED']);
    expect(f.FileChangeType.ADDED, _map(_truth['fileChangeType'])['ADDED']);
    expect(f.FileChangeType.DELETED, _map(_truth['fileChangeType'])['DELETED']);
    final caps = _map(_truth['caps']);
    expect(f.FileSystemProviderCapabilities.FileReadWrite, caps['FileReadWrite']);
    expect(f.FileSystemProviderCapabilities.FileAtomicRename, caps['FileAtomicRename']);
    expect(f.FileSystemProviderCapabilities.Readonly, caps['Readonly']);
    final opRes = _map(_truth['operationResult']);
    expect(f.FileOperationResult.FILE_NOT_FOUND, opRes['FILE_NOT_FOUND']);
    expect(f.FileOperationResult.FILE_OTHER_ERROR, opRes['FILE_OTHER_ERROR']);
    final pc = _map(_truth['providerErrorCode']);
    expect(f.FileSystemProviderErrorCode.FileNotFound, pc['FileNotFound']);
    expect(f.FileSystemProviderErrorCode.Unknown, pc['Unknown']);
  });

  test('capability guards 1:1 truth', () {
    expect(f.hasReadWriteCapability(_Provider(f.FileSystemProviderCapabilities.FileReadWrite)),
        _truth['hasReadWrite']);
    expect(f.hasReadWriteCapability(_Provider(0)), _truth['hasReadWrite_neg']);
    expect(f.hasFileAppendCapability(_Provider(f.FileSystemProviderCapabilities.FileAppend)), _truth['hasFileAppend']);
    expect(f.hasFileFolderCopyCapability(_Provider(f.FileSystemProviderCapabilities.FileFolderCopy)), _truth['hasFolderCopy']);
    expect(f.hasFileCloneCapability(_Provider(f.FileSystemProviderCapabilities.FileClone)), _truth['hasFileClone']);
    expect(f.hasFileRealpathCapability(_Provider(f.FileSystemProviderCapabilities.FileRealpath)), _truth['hasRealpath']);
    expect(f.hasOpenReadWriteCloseCapability(_Provider(f.FileSystemProviderCapabilities.FileOpenReadWriteClose)), _truth['hasOpenRWClose']);
    expect(f.hasFileReadStreamCapability(_Provider(f.FileSystemProviderCapabilities.FileReadStream)), _truth['hasReadStream']);
    expect(f.hasFileAtomicReadCapability(_Provider(f.FileSystemProviderCapabilities.FileAtomicRead)), _truth['hasAtomicRead']);
    expect(f.hasFileAtomicWriteCapability(_Provider(f.FileSystemProviderCapabilities.FileAtomicWrite)), _truth['hasAtomicWrite']);
    expect(f.hasFileAtomicDeleteCapability(_Provider(f.FileSystemProviderCapabilities.FileAtomicDelete)), _truth['hasAtomicDelete']);
    expect(f.hasFileAtomicRenameCapability(_Provider(f.FileSystemProviderCapabilities.FileAtomicRename)), _truth['hasAtomicRename']);
    expect(f.hasReadonlyCapability(_Provider(f.FileSystemProviderCapabilities.Readonly)), _truth['hasReadonly']);
    expect(f.isFileOpenForWriteOptions(<String, Object?>{'create': true}), _truth['isFileOpenForWrite_true']);
    expect(f.isFileOpenForWriteOptions(<String, Object?>{}), _truth['isFileOpenForWrite_false']);
  });

  test('error code conversion 1:1 truth', () {
    expect(f.toFileSystemProviderErrorCode(null), _truth['err_unknown']);
    final marked = f.markAsFileSystemProviderError(
        f.FileError('x'), f.FileSystemProviderErrorCode.FileNotFound);
    expect(f.toFileSystemProviderErrorCode(marked), _truth['err_marked_notfound']);
    final markedCustom =
        f.markAsFileSystemProviderError(f.FileError('x'), 'CustomCode');
    expect(f.toFileSystemProviderErrorCode(markedCustom), _truth['err_marked_custom']);
    expect(f.toFileSystemProviderErrorCode(f.FileError('plain')), _truth['err_plain']);

    final fse = f.createFileSystemProviderError(
        'boom', f.FileSystemProviderErrorCode.FileNotFound);
    expect(fse.name, _truth['providerError_name']);
    expect(fse.message, _truth['providerError_message']);
    expect(fse.code, _truth['providerError_code']);
    expect(fse is f.FileSystemProviderError, _truth['providerError_instance']);
    expect(f.ensureFileSystemProviderError(null).toString(),
        contains(_truth['ensure_undefined'] as String));

    final opErr = f.FileOperationError(
        'boom', f.FileOperationResult.FILE_NOT_FOUND);
    expect(f.toFileOperationResult(opErr), _truth['toFileOperationResult_fop']);
    expect(f.toFileOperationResult(marked), _truth['toFileOperationResult_mapped']);
    expect(f.toFileOperationResult(f.FileError('plain')),
        _truth['toFileOperationResult_other']);
  });

  test('isParent 1:1 truth', () {
    final t = _map(_truth['isParent']);
    expect(f.isParent('/a/b', '/a/b/c'), t['basic']);
    expect(f.isParent('/a/b', '/a/b'), t['equal']);
    expect(f.isParent('/a/b/c', '/a/b'), t['reverse']);
    expect(f.isParent('', '/a'), t['empty']);
    expect(f.isParent('/A/b', '/a/b/c', false), t['caseSensitive']);
    expect(f.isParent('/A/b', '/a/b/c', true), t['caseInsensitive']);
    expect(f.isParent('/a/b/', '/a/b/c'), t['trailingSlash']);
  });

  test('etag / ByteSize / limits 1:1 truth', () {
    expect(f.etag(mtime: 1234, size: 5678), _truth['etag_valid']);
    expect(f.etag(mtime: 1234), _truth['etag_missing_size']);
    expect(f.etag(size: 5678), _truth['etag_missing_mtime']);
    expect(f.etag(mtime: 0, size: 0), _truth['etag_zero']);

    final bs = _map(_truth['byteSize']);
    expect(f.ByteSize.formatSize(0), bs['zero']);
    expect(f.ByteSize.formatSize(512), bs['b']);
    expect(f.ByteSize.formatSize(1536), bs['kb']);
    expect(f.ByteSize.formatSize(2 * 1024 * 1024), bs['mb']);
    expect(f.ByteSize.formatSize(3 * 1024 * 1024 * 1024), bs['gb']);
    expect(f.ByteSize.formatSize(2 * 1024 * 1024 * 1024 * 1024), bs['tb']);
    expect(f.ByteSize.formatSize('x'), bs['nan']);
    final bsc = _map(_truth['byteSizeConsts']);
    expect(f.ByteSize.KB, bsc['KB']);
    expect(f.ByteSize.MB, bsc['MB']);

    expect(f.getLargeFileConfirmationLimit(URI.file('/a/b')), _truth['limit_local']);
    expect(f.getLargeFileConfirmationLimit(URI.parse('vscode-remote://host/a')),
        _truth['limit_remote']);
    expect(f.getLargeFileConfirmationLimit('host'), _truth['limit_string']);
    expect(f.getLargeFileConfirmationLimit(), _truth['limit_undefined']);
  });

  test('FileChangesEvent 1:1 truth', () {
    final ev = f.FileChangesEvent([
      _Change(f.FileChangeType.ADDED, URI.file('/a/b/new.ts')),
      _Change(f.FileChangeType.UPDATED, URI.file('/a/b/upd.ts')),
      _Change(f.FileChangeType.DELETED, URI.file('/a/b/del/deep.ts')),
    ], false);
    expect(ev.gotAdded(), _truth['fce_gotAdded']);
    expect(ev.gotUpdated(), _truth['fce_gotUpdated']);
    expect(ev.gotDeleted(), _truth['fce_gotDeleted']);
    expect(ev.contains(URI.file('/a/b/new.ts')), _truth['fce_contains_added']);
    expect(ev.contains(URI.file('/a/b/upd.ts')), _truth['fce_contains_updated']);
    expect(ev.contains(URI.file('/a/b/del/deep.ts')), _truth['fce_contains_deleted_exact']);
    expect(ev.contains(URI.file('/a/b/del')), _truth['fce_contains_deleted_parent']);
    expect(ev.affects(URI.file('/a/b')), _truth['fce_contains_affects']);
    expect(ev.contains(URI.file('/a/b/new.ts'), [f.FileChangeType.ADDED]), _truth['fce_contains_filter_added']);
    expect(ev.contains(URI.file('/a/b/new.ts'), [f.FileChangeType.DELETED]), _truth['fce_contains_filter_wrong']);
    final raw = _map(_truth['fce_raw']);
    expect(ev.rawAdded.map((u) => u.path).toList(), _list(raw['added']));
    expect(ev.rawUpdated.map((u) => u.path).toList(), _list(raw['updated']));
    expect(ev.rawDeleted.map((u) => u.path).toList(), _list(raw['deleted']));

    final evc = f.FileChangesEvent(
        [_Change(f.FileChangeType.ADDED, URI.file('/x'), 1), _Change(f.FileChangeType.UPDATED, URI.file('/y'), 1)],
        false);
    expect(evc.hasCorrelation(), _truth['fce_corr_has']);
    expect(evc.correlates(1), _truth['fce_corr_1']);
    expect(evc.correlates(2), _truth['fce_corr_2']);
    final evmix = f.FileChangesEvent(
        [_Change(f.FileChangeType.ADDED, URI.file('/x'), 1), _Change(f.FileChangeType.UPDATED, URI.file('/y'), 2)],
        false);
    expect(evmix.hasCorrelation(), _truth['fce_mix_has']);
    final evnoc = f.FileChangesEvent([_Change(f.FileChangeType.ADDED, URI.file('/x'))], false);
    expect(evnoc.hasCorrelation(), _truth['fce_nocorr_has']);
  });
}
