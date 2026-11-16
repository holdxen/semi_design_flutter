// SemiUpload — 上传（Semi Design 组件移植）。
//
// 上游：packages/semi-foundation/upload/{variables.scss, upload.scss, rtl.scss,
// constants.ts, foundation.ts, fileCardFoundation.ts, utils.ts}、
// packages/semi-ui/upload/{index.tsx, fileCard.tsx, interface.ts} + zh_CN.ts
// locale。主题对账 85 = 85 FIELDS + 0 MOTION + 0 INTERNAL
// （tool/generate_upload.py；本模块无 animation.scss）——★3 死变量
// （`$color-upload_pic_remove-bg`、`$height-upload_file_card_retry-icon` 真死；
// `$width-upload_file_card_info_name` 唯一出现是注释掉的 `// width:`
// ——事实死），留档不消费（落 theme + docs「（上游未消费）」；本文件不得出现
// 这些字段名，生成器 assertNotIn 断言）。
//
// HARDCODES（另列）上游片段以注释逐字留档在 `_UploadMetrics` / 调用点，
// 生成器 HARDCODES 锚点断言这些片段出现在本文件。
//
// ★Flutter 侧差异（docs 详列）：浏览器 `input[type=file]` / 系统文件拖拽 /
// 粘贴上传不可用——文件获取收敛为 [SemiUpload.onPickFiles]（应用自行打开
// picker 并返回 [SemiUploadFile]）；`draggable` 的 OS 拖拽事件不移植，但拖拽
// 区域 UI / 合法-非法提示仍可经 [SemiUpload.dragAreaStatus] 驱动；默认 XHR
// 上传（`action`）收敛为 [SemiUpload.onRequest] 自定义请求。
import 'dart:async';

import 'package:flutter/widgets.dart';

import '../overlay/tooltip_positioning.dart';
import '../theme/semi_icon_theme.dart';
import '../theme/semi_spin_theme.dart';
import '../theme/semi_spin_theme_data.dart';
import '../theme/semi_theme.dart';
import '../theme/semi_theme_data.dart';
import '../theme/semi_upload_theme.dart';
import '../theme/semi_upload_theme_data.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icon_data.dart';
import 'icon/semi_icons.dart';
import 'semi_button.dart';
import 'semi_progress.dart';
import 'semi_spin.dart';
import 'semi_tooltip.dart';

/// 列表形态（上游 `listType: 'list' | 'picture'`；`none` 收敛为 showUploadList=false）。
enum SemiUploadListType { list, picture }

/// 提示位置（上游 `promptPosition: 'left' | 'right' | 'bottom'`，缺省 right）。
enum SemiUploadPromptPosition { left, right, bottom }

/// 文件状态（constants.ts FILE_STATUS_*）。
enum SemiUploadFileStatus {
  wait,
  uploading,
  success,
  uploadFail,
  validating,
  validateFail,
}

/// 校验样式（上游 `validateStatus`，挂在根容器）。
enum SemiUploadValidateStatus { defaultStatus, error, warning, success }

/// 拖拽区域状态（上游 `dragAreaStatus: default | legal | illegal`；OS 拖拽
/// 未移植——由使用方驱动）。
enum SemiUploadDragAreaStatus { defaultStatus, legal, illegal }

/// 单个文件（上游 `FileItem`：File + uid/status/percent/url/validateMessage...）。
class SemiUploadFile {
  const SemiUploadFile({
    this.uid = '',
    required this.name,
    this.size = 0,
    this.status = SemiUploadFileStatus.wait,
    this.percent = 0,
    this.url,
    this.thumbnail,
    this.isImage = false,
    this.validateMessage,
    this.response,
    this.shouldUpload = true,
  });

  /// 唯一 id（空串由 [SemiUpload] 自动补齐）。
  final String uid;

  /// 文件名。
  final String name;

  /// 字节数。
  final int size;

  final SemiUploadFileStatus status;

  /// 上传进度（0–100）。
  final double percent;

  /// 预览图片地址（仅元数据；缩略图走 [thumbnail]）。
  final String? url;

  /// 图片墙/预览缩略图（null 走文件图标占位）。
  final Widget? thumbnail;

  /// 图片文件标记（`preview` 态——缺省按扩展名推断）。
  final bool isImage;

  /// 校验信息（String | Widget；失败时缺省 locale「上传失败」/「文件尺寸不合法」）。
  final Object? validateMessage;

  /// 上传响应。
  final Object? response;

  /// beforeUpload 结果（false 时不发起请求）。
  final bool shouldUpload;

  SemiUploadFile copyWith({
    String? uid,
    String? name,
    int? size,
    SemiUploadFileStatus? status,
    double? percent,
    String? url,
    Widget? thumbnail,
    bool? isImage,
    Object? validateMessage,
    Object? response,
    bool? shouldUpload,
  }) => SemiUploadFile(
    uid: uid ?? this.uid,
    name: name ?? this.name,
    size: size ?? this.size,
    status: status ?? this.status,
    percent: percent ?? this.percent,
    url: url ?? this.url,
    thumbnail: thumbnail ?? this.thumbnail,
    isImage: isImage ?? this.isImage,
    validateMessage: validateMessage ?? this.validateMessage,
    response: response ?? this.response,
    shouldUpload: shouldUpload ?? this.shouldUpload,
  );
}

/// beforeUpload 对象形态（上游 `BeforeUploadObjectResult`）。
class SemiUploadBeforeResult {
  const SemiUploadBeforeResult({
    this.shouldUpload = true,
    this.status,
    this.validateMessage,
    this.autoRemove = false,
  });

  final bool shouldUpload;
  final SemiUploadFileStatus? status;
  final Object? validateMessage;

  /// 直接从列表移除（上游 `autoRemove`）。
  final bool autoRemove;
}

/// 自定义请求参数（上游 `customRequest` 载荷；XHR 收敛为回调）。
class SemiUploadRequestArgs {
  const SemiUploadRequestArgs({
    required this.file,
    required this.action,
    required this.onProgress,
    required this.onSuccess,
    required this.onError,
  });

  final SemiUploadFile file;

  /// 目标地址元数据（上游 `action`）。
  final String action;

  /// 上传进度（0–100）。
  final ValueChanged<double> onProgress;

  /// 上传成功（response 会写入 file.response）。
  final ValueChanged<Object?> onSuccess;

  /// 上传失败（message 缺省走 locale「上传失败」）。
  final void Function(Object? error, [String? message]) onError;
}

/// onChange 载荷（上游 `{fileList, currentFile}`）。
class SemiUploadChangeInfo {
  const SemiUploadChangeInfo({required this.fileList, this.currentFile});

  final List<SemiUploadFile> fileList;
  final SemiUploadFile? currentFile;
}

/// beforeUpload（bool / [SemiUploadBeforeResult] / Future 均可）。
typedef SemiUploadBeforeUpload = FutureOr<Object?> Function(
  SemiUploadFile file,
  List<SemiUploadFile> fileList,
);

/// 文件获取（Flutter 侧替代浏览器文件选择框）。
typedef SemiUploadPickFiles = Future<List<SemiUploadFile>> Function();

/// renderFileItem 参数（上游 `RenderFileItemProps` 子集）。
class SemiUploadItemProps {
  const SemiUploadItemProps({
    required this.file,
    required this.index,
    required this.listType,
    required this.disabled,
    required this.showRetry,
    required this.showReplace,
    required this.onRemove,
    required this.onRetry,
    required this.onReplace,
    this.onPreview,
  });

  final SemiUploadFile file;
  final int index;
  final SemiUploadListType listType;
  final bool disabled;
  final bool showRetry;
  final bool showReplace;
  final VoidCallback onRemove;
  final VoidCallback onRetry;
  final VoidCallback onReplace;
  final VoidCallback? onPreview;
}

/// 上传。
///
/// 生命周期（foundation.ts:315-419 handleChange）：取得文件 → accept 过滤
/// （非法回调 onAcceptInvalid）→ 补 uid → 尺寸校验（KB；非法 → validateFail +
/// onSizeError）→ 超限处理（limit：超出回调 onExceed；limit==1 用最后一个
/// 替换整表；否则截断到剩余名额）→ 入表（wait）+ onChange（逐文件）→ 自动
/// 上传（beforeUpload → 请求）。请求（customRequest 口径）：[onRequest] 拿
/// 回调驱动 uploading/success/uploadFail；afterUpload 返回 false 时不改成功态。
/// 删除/清空/重试/替换均走 beforeXxx 守卫 + onChange（受控 fileList 只回调）。
class SemiUpload extends StatefulWidget {
  const SemiUpload({
    super.key,
    this.children,
    this.action = '',
    this.accept,
    this.multiple = false,
    this.limit,
    this.maxSize,
    this.minSize,
    this.fileList,
    this.defaultFileList = const <SemiUploadFile>[],
    this.disabled = false,
    this.dragArea = false,
    this.dragIcon,
    this.dragMainText,
    this.dragSubText,
    this.dragAreaStatus = SemiUploadDragAreaStatus.defaultStatus,
    this.listType = SemiUploadListType.list,
    this.hotSpotLocation = SemiUploadHotSpot.end,
    this.prompt,
    this.promptPosition = SemiUploadPromptPosition.right,
    this.showUploadList = true,
    this.showClear = true,
    this.showReplace = false,
    this.showRetry = true,
    this.showPicInfo = false,
    this.picWidth,
    this.picHeight,
    this.validateMessage,
    this.validateStatus = SemiUploadValidateStatus.defaultStatus,
    this.fileListTitle,
    this.onPickFiles,
    this.onOpenFileDialog,
    this.beforeUpload,
    this.afterUpload,
    this.onRequest,
    this.onChange,
    this.onProgress,
    this.onSuccess,
    this.onError,
    this.onAcceptInvalid,
    this.onExceed,
    this.onSizeError,
    this.onRemove,
    this.beforeRemove,
    this.onClear,
    this.beforeClear,
    this.onRetry,
    this.onPreviewClick,
    this.renderFileItem,
    this.renderThumbnail,
    this.itemStyle,
    this.semanticsLabel,
  });

  /// Root key.
  static const Key rootKey = Key('SemiUpload.root');

  /// 触发区（add / drag area）key。
  static const Key triggerKey = Key('SemiUpload.trigger');

  /// 列表容器 key。
  static const Key listKey = Key('SemiUpload.list');

  /// 自定义触发内容（缺省 + `dragArea: true` 时渲染拖拽区；两者皆空则不渲染触发）。
  final Widget? children;

  /// 上传地址元数据（浏览器 XHR 路径未移植——请求交给 [onRequest]）。
  final String action;

  /// 允许类型（逗号分隔：`.png,.jpg` 后缀或 `image/*` 类别）。
  final String? accept;

  /// 多选（触发时传给 picker 的语义提示——由应用自行处理）。
  final bool multiple;

  /// 最大文件数。
  final int? limit;

  /// 最大尺寸（KB；`size > maxSize * byteKB` 非法）。
  final double? maxSize;

  /// 最小尺寸（KB；`size < minSize * byteKB` 非法）。
  final double? minSize;

  /// 文件列表（非 null 即受控：交互只回调 onChange，展示跟随 props）。
  final List<SemiUploadFile>? fileList;

  /// 未受控初值。
  final List<SemiUploadFile> defaultFileList;

  /// 整体禁用。
  final bool disabled;

  /// 渲染拖拽区域（OS 拖拽未移植；点击仍可选择）。
  final bool dragArea;

  /// 拖拽区域图标（缺省 upload 24）。
  final Widget? dragIcon;

  /// 拖拽区域主文案（缺省 locale「点击上传文件或拖拽文件到这里」）。
  final Object? dragMainText;

  /// 拖拽区域副文案。
  final Object? dragSubText;

  /// 拖拽区域状态（合法/非法提示由使用方驱动）。
  final SemiUploadDragAreaStatus dragAreaStatus;

  /// 列表形态。
  final SemiUploadListType listType;

  /// 图片墙 add 的位置（start/end；缺省 end）。
  final SemiUploadHotSpot hotSpotLocation;

  /// 触发区旁提示。
  final Object? prompt;

  /// 提示位置。
  final SemiUploadPromptPosition promptPosition;

  /// 展示文件列表。
  final bool showUploadList;

  /// 标题行「清空」。
  final bool showClear;

  /// 成功文件展示替换按钮。
  final bool showReplace;

  /// 失败文件展示重试。
  final bool showRetry;

  /// 图片墙展示序号信息条（info bar）。
  final bool showPicInfo;

  /// 图片墙卡片宽高（缺省 token 96）。
  final double? picWidth;
  final double? picHeight;

  /// 根级校验信息（渲染在列表下方）。
  final Object? validateMessage;

  /// 根级校验样式（仅语义，颜色由 validateMessage 自带）。
  final SemiUploadValidateStatus validateStatus;

  /// 列表标题（String | Widget | `Widget Function(List<SemiUploadFile> fileList, VoidCallback onClear, String clearText)`）。
  final Object? fileListTitle;

  /// 文件获取入口（点击触发区 / 替换时调用）。
  final SemiUploadPickFiles? onPickFiles;

  /// 打开选择框前回调。
  final VoidCallback? onOpenFileDialog;

  /// 上传前校验（bool 或 [SemiUploadBeforeResult]）。
  final SemiUploadBeforeUpload? beforeUpload;

  /// 上传完成后处理（返回 false 时不改成功态）。
  final FutureOr<Object?> Function(
    Object? response,
    SemiUploadFile file,
    List<SemiUploadFile> fileList,
  )?
  afterUpload;

  /// 自定义请求（缺省不发请求：文件停在 wait）。
  final void Function(SemiUploadRequestArgs args)? onRequest;

  /// 列表变更。
  final ValueChanged<SemiUploadChangeInfo>? onChange;

  /// 进度（0–100）。
  final void Function(
    double percent,
    SemiUploadFile file,
    List<SemiUploadFile> fileList,
  )?
  onProgress;

  /// 成功。
  final void Function(
    Object? response,
    SemiUploadFile file,
    List<SemiUploadFile> fileList,
  )?
  onSuccess;

  /// 失败。
  final void Function(
    Object? error,
    SemiUploadFile file,
    List<SemiUploadFile> fileList,
  )?
  onError;

  /// accept 不合法文件。
  final ValueChanged<List<SemiUploadFile>>? onAcceptInvalid;

  /// 超出 limit（未被加入的文件）。
  final ValueChanged<List<SemiUploadFile>>? onExceed;

  /// 尺寸非法。
  final void Function(SemiUploadFile file, List<SemiUploadFile> fileList)?
  onSizeError;

  /// 移除后。
  final void Function(SemiUploadFile file, List<SemiUploadFile> fileList)?
  onRemove;

  /// 移除前守卫（false 取消）。
  final FutureOr<bool> Function(
    SemiUploadFile file,
    List<SemiUploadFile> fileList,
  )?
  beforeRemove;

  /// 清空后。
  final ValueChanged<List<SemiUploadFile>>? onClear;

  /// 清空前守卫（false 取消）。
  final FutureOr<bool> Function(List<SemiUploadFile> fileList)? beforeClear;

  /// 重试。
  final ValueChanged<SemiUploadFile>? onRetry;

  /// 预览点击。
  final ValueChanged<SemiUploadFile>? onPreviewClick;

  /// 自定义条目（list/picture 共用；null 走默认 FileCard）。
  final Widget Function(SemiUploadItemProps props)? renderFileItem;

  /// 图片墙缩略图（覆盖 [SemiUploadFile.thumbnail]）。
  final Widget Function(SemiUploadFile file)? renderThumbnail;

  /// 条目外层样式（宽度等）。
  final EdgeInsetsGeometry? itemStyle;

  /// 根语义标签。
  final String? semanticsLabel;

  @override
  State<SemiUpload> createState() => _SemiUploadState();
}

/// 图片墙 add 位（上游 `hotSpotLocation`）。
enum SemiUploadHotSpot { start, end }

class _SemiUploadState extends State<SemiUpload> {
  late List<SemiUploadFile> _fileList = List<SemiUploadFile>.of(
    widget.fileList ?? widget.defaultFileList,
  );
  int _uid = 0;

  List<SemiUploadFile> get _effective => widget.fileList ?? _fileList;

  bool get _controlled => widget.fileList != null;

  /// 更新单个文件（找不到则忽略——异步回调可能晚于移除）。
  void _updateFile(
    SemiUploadFile file,
    SemiUploadFile Function(SemiUploadFile) update, {
    bool notifyChange = true,
  }) {
    final list = List<SemiUploadFile>.of(_effective);
    final index = list.indexWhere((item) => item.uid == file.uid);
    if (index < 0) {
      return;
    }
    final next = update(list[index]);
    list[index] = next;
    if (!_controlled) {
      setState(() => _fileList = list);
    }
    if (notifyChange) {
      widget.onChange?.call(
        SemiUploadChangeInfo(fileList: list, currentFile: next),
      );
    }
  }

  // -- selection -------------------------------------------------------------

  Future<void> _openPicker({int? replaceIndex}) async {
    if (widget.disabled) {
      return;
    }
    widget.onOpenFileDialog?.call();
    final picker = widget.onPickFiles;
    if (picker == null) {
      return;
    }
    final files = await picker();
    if (!mounted || files.isEmpty) {
      return;
    }
    if (replaceIndex != null) {
      _handleReplace(files, replaceIndex);
    } else {
      _handleChange(files);
    }
  }

  /// foundation.ts:315-367 `handleChange`。
  void _handleChange(List<SemiUploadFile> incoming) {
    var files = List<SemiUploadFile>.of(incoming);
    files = _filterAccept(files);
    if (files.isEmpty) {
      return;
    }
    files = files.map(_prepareFile).toList();

    final current = List<SemiUploadFile>.of(_effective);
    final limit = widget.limit;
    if (limit != null) {
      final total = current.length + files.length;
      if (total > limit) {
        widget.onExceed?.call(List<SemiUploadFile>.of(files));
        if (limit == 1) {
          // 用最后一个文件替换整表（foundation.ts:349-359）。
          _replaceAll([files.last]);
          return;
        }
        final rest = limit - current.length;
        files = files.take(rest).toList();
      }
    }
    if (files.isEmpty) {
      return;
    }
    final next = [...current];
    for (final file in files) {
      final item = _toListItem(file);
      next.add(item);
      // 上游逐个文件 onChange（foundation.ts:477-483）。
      widget.onChange?.call(
        SemiUploadChangeInfo(fileList: List.of(next), currentFile: item),
      );
    }
    if (!_controlled) {
      setState(() => _fileList = next);
    }
    for (final file in files) {
      if (!_sizeInvalid(file)) {
        _upload(file);
      }
    }
  }

  void _replaceAll(List<SemiUploadFile> files) {
    final items = files.map(_toListItem).toList();
    if (!_controlled) {
      setState(() => _fileList = items);
    }
    widget.onChange?.call(
      SemiUploadChangeInfo(
        fileList: items,
        currentFile: items.isEmpty ? null : items.first,
      ),
    );
    for (final file in files) {
      if (!_sizeInvalid(file)) {
        _upload(file);
      }
    }
  }

  /// foundation.ts:370-421 `handleReplaceChange`。
  void _handleReplace(List<SemiUploadFile> picked, int index) {
    var files = List<SemiUploadFile>.of(picked);
    final last = files.removeLast();
    final filtered = _filterAccept([last]);
    if (filtered.isEmpty) {
      return;
    }
    final prepared = _prepareFile(filtered.single);
    final item = _toListItem(prepared);
    final next = List<SemiUploadFile>.of(_effective);
    if (index < 0 || index >= next.length) {
      return;
    }
    next[index] = item;
    if (!_controlled) {
      setState(() => _fileList = next);
    }
    widget.onChange?.call(
      SemiUploadChangeInfo(fileList: next, currentFile: item),
    );
    if (!_sizeInvalid(prepared)) {
      _upload(prepared);
    }
  }

  List<SemiUploadFile> _filterAccept(List<SemiUploadFile> files) {
    final accept = widget.accept;
    if (accept == null) {
      return files;
    }
    final tokens = accept
        .split(',')
        .map((token) => token.trim().toLowerCase())
        .where((token) => token.isNotEmpty)
        .toList();
    final valid = <SemiUploadFile>[];
    final invalid = <SemiUploadFile>[];
    for (final file in files) {
      final name = file.name.toLowerCase();
      final ok = tokens.any((token) {
        if (token.startsWith('.')) {
          return name.endsWith(token);
        }
        if (token.endsWith('/*') || token.endsWith('/')) {
          return _isImageName(name);
        }
        return name.endsWith('.$token');
      });
      (ok ? valid : invalid).add(file);
    }
    if (invalid.isNotEmpty) {
      widget.onAcceptInvalid?.call(invalid);
    }
    return valid;
  }

  bool _isImageName(String name) => _UploadMetrics.imageExtensions.any(
    (extension) => name.endsWith('.$extension'),
  );

  /// 补 uid + 尺寸校验（非法 → validateFail + onSizeError，foundation.ts:333-345）。
  SemiUploadFile _prepareFile(SemiUploadFile file) {
    var prepared = file;
    if (prepared.uid.isEmpty) {
      prepared = prepared.copyWith(uid: _nextUid());
    }
    if (_sizeIllegal(prepared)) {
      prepared = prepared.copyWith(
        status: SemiUploadFileStatus.validateFail,
        validateMessage:
            prepared.validateMessage ?? _UploadMetrics.localeIllegalSize,
      );
      widget.onSizeError?.call(prepared, List.of(_effective));
    }
    if (prepared.isImage == false &&
        _isImageName(prepared.name.toLowerCase())) {
      prepared = prepared.copyWith(isImage: true);
    }
    return prepared;
  }

  bool _sizeIllegal(SemiUploadFile file) {
    final size = file.size;
    final max = widget.maxSize;
    final min = widget.minSize;
    final bytes = _UploadMetrics.byteKB;
    if (max != null && size > max * bytes) {
      return true;
    }
    if (min != null && size < min * bytes) {
      return true;
    }
    return false;
  }

  bool _sizeInvalid(SemiUploadFile file) =>
      file.status == SemiUploadFileStatus.validateFail &&
      identical(file.validateMessage, _UploadMetrics.localeIllegalSize);

  SemiUploadFile _toListItem(SemiUploadFile file) => file.copyWith(
    status: file.status == SemiUploadFileStatus.validateFail
        ? SemiUploadFileStatus.validateFail
        : SemiUploadFileStatus.wait,
    percent: 0,
  );

  String _nextUid() {
    _uid += 1;
    // `getUuidv4()` 口径（唯一 id 即可）。
    return 'semi-upload-${DateTime.now().microsecondsSinceEpoch}-$_uid';
  }

  // -- upload ----------------------------------------------------------------

  /// foundation.ts:574-630 `upload`（beforeUpload 三态）。
  Future<void> _upload(SemiUploadFile file) async {
    final before = widget.beforeUpload;
    if (before == null) {
      _post(file);
      return;
    }
    final Object? result;
    try {
      result = await before(file, List.of(_effective));
    } catch (_) {
      await _applyBeforeResult(
        file,
        const SemiUploadBeforeResult(shouldUpload: false),
      );
      return;
    }
    if (result is bool) {
      if (result) {
        _post(file);
      } else {
        await _applyBeforeResult(
          file,
          const SemiUploadBeforeResult(shouldUpload: false),
        );
      }
      return;
    }
    if (result is SemiUploadBeforeResult) {
      await _applyBeforeResult(file, result);
    }
    // 其余类型：上游 default 分支不发起请求（foundation.ts:627-629）。
  }

  Future<void> _applyBeforeResult(
    SemiUploadFile file,
    SemiUploadBeforeResult result,
  ) async {
    if (result.autoRemove) {
      final next = _effective.where((item) => item.uid != file.uid).toList();
      if (!_controlled) {
        setState(() => _fileList = next);
      }
      widget.onChange?.call(
        SemiUploadChangeInfo(fileList: next, currentFile: file),
      );
      return;
    }
    _updateFile(
      file,
      (current) => current.copyWith(
        status:
            result.status ??
            (result.shouldUpload
                ? SemiUploadFileStatus.wait
                : SemiUploadFileStatus.validateFail),
        validateMessage: result.validateMessage,
        shouldUpload: result.shouldUpload,
      ),
    );
    if (result.shouldUpload) {
      _post(file);
    }
  }

  /// foundation.ts:641-767 `post`（customRequest 口径）。
  void _post(SemiUploadFile file) {
    final request = widget.onRequest;
    _updateFile(
      file,
      (current) =>
          current.copyWith(status: SemiUploadFileStatus.uploading, percent: 0),
    );
    if (request == null) {
      // 浏览器 XHR 路径未移植——无 onRequest 时文件停在 uploading 前的 wait？
      // 上游无 customRequest 时发起 XHR；Flutter 无内置网络请求语义，保持
      // uploading（应用应提供 onRequest）。
      return;
    }
    request(
      SemiUploadRequestArgs(
        file: file,
        action: widget.action,
        onProgress: (percent) => _handleProgress(file, percent),
        onSuccess: (response) => _handleSuccess(file, response),
        onError: (error, [message]) => _handleError(file, error, message),
      ),
    );
  }

  void _handleProgress(SemiUploadFile file, double percent) {
    if (!mounted) {
      return;
    }
    final clamped = percent.clamp(0.0, 100.0).toDouble();
    _updateFile(
      file,
      (current) => current.copyWith(
        status: SemiUploadFileStatus.uploading,
        percent: clamped,
      ),
      notifyChange: false,
    );
    widget.onProgress?.call(clamped, file, List.of(_effective));
  }

  Future<void> _handleSuccess(SemiUploadFile file, Object? response) async {
    if (!mounted) {
      return;
    }
    final after = widget.afterUpload;
    var apply = true;
    var finalResponse = response;
    if (after != null) {
      final result = await after(response, file, List.of(_effective));
      if (result is bool && !result) {
        apply = false;
      }
    }
    if (!mounted || !apply) {
      return;
    }
    _updateFile(
      file,
      (current) => current.copyWith(
        status: SemiUploadFileStatus.success,
        percent: 100,
        response: finalResponse,
      ),
    );
    widget.onSuccess?.call(finalResponse, file, List.of(_effective));
  }

  void _handleError(SemiUploadFile file, Object? error, String? message) {
    if (!mounted) {
      return;
    }
    _updateFile(
      file,
      (current) => current.copyWith(
        status: SemiUploadFileStatus.uploadFail,
        validateMessage: message ?? _UploadMetrics.localeFail,
      ),
    );
    widget.onError?.call(error, file, List.of(_effective));
  }

  // -- list operations -------------------------------------------------------

  Future<void> _removeFile(SemiUploadFile file) async {
    final current = List.of(_effective);
    final guard = widget.beforeRemove;
    if (guard != null) {
      final allowed = await guard(file, current);
      if (!allowed || !mounted) {
        return;
      }
    }
    final next = current.where((item) => item.uid != file.uid).toList();
    if (!_controlled) {
      setState(() => _fileList = next);
    }
    widget.onRemove?.call(file, next);
    widget.onChange?.call(
      SemiUploadChangeInfo(fileList: next, currentFile: file),
    );
  }

  Future<void> _clear() async {
    final current = List.of(_effective);
    final guard = widget.beforeClear;
    if (guard != null) {
      final allowed = await guard(current);
      if (!allowed || !mounted) {
        return;
      }
    }
    if (!_controlled) {
      setState(() => _fileList = const <SemiUploadFile>[]);
    }
    widget.onClear?.call(current);
    widget.onChange?.call(
      SemiUploadChangeInfo(fileList: const <SemiUploadFile>[]),
    );
  }

  void _retry(SemiUploadFile file) {
    widget.onRetry?.call(file);
    _updateFile(
      file,
      (current) => current.copyWith(
        status: SemiUploadFileStatus.wait,
        percent: 0,
        validateMessage: null,
      ),
      notifyChange: false,
    );
    _upload(file);
  }

  // -- build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final t = SemiUploadTheme.resolve(context);
    final global = SemiTheme.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final fileList = _effective;
    final showList =
        widget.showUploadList && widget.listType == SemiUploadListType.list;
    final list = fileList.isNotEmpty && showList
        ? _buildFileList(t, global, fileList)
        : null;
    final trigger = _buildTrigger(t, global, rtl, fileList);

    final Widget body;
    if (widget.listType == SemiUploadListType.picture) {
      final row = _buildPictureRow(t, global, rtl, fileList);
      body = switch (widget.promptPosition) {
        SemiUploadPromptPosition.right => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [row, if (widget.prompt != null) _buildPrompt(t)],
        ),
        SemiUploadPromptPosition.left => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [if (widget.prompt != null) _buildPrompt(t), row],
        ),
        SemiUploadPromptPosition.bottom => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [row, if (widget.prompt != null) _buildPrompt(t)],
        ),
      };
      // picture 模式 trigger 已并入 row（add 卡）。
      return _wrapRoot(t, body, validateBelow: true);
    }

    final topRow = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.promptPosition == SemiUploadPromptPosition.left &&
            widget.prompt != null)
          _buildPrompt(t),
        trigger,
        if (widget.promptPosition == SemiUploadPromptPosition.right &&
            widget.prompt != null)
          _buildPrompt(t),
      ],
    );
    body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        topRow,
        if (widget.promptPosition == SemiUploadPromptPosition.bottom &&
            widget.prompt != null)
          _buildPrompt(t),
        ?list,
      ],
    );
    return _wrapRoot(t, body, validateBelow: true);
  }

  Widget _wrapRoot(
    SemiResolvedUploadThemeData t,
    Widget body, {
    required bool validateBelow,
  }) {
    return Semantics(
      container: true,
      label: widget.semanticsLabel,
      child: Column(
        key: SemiUpload.rootKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          body,
          if (validateBelow && widget.validateMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: t.colorUploadFileCardFailInfoText),
                child: _content(widget.validateMessage),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrompt(SemiResolvedUploadThemeData t) => Padding(
    padding: const EdgeInsetsDirectional.only(start: 8),
    child: DefaultTextStyle.merge(
      style: TextStyle(fontSize: _UploadMetrics.fontSizeSmall),
      child: _content(widget.prompt),
    ),
  );

  Widget _content(Object? value) {
    if (value is Widget) {
      return value;
    }
    return Text(value?.toString() ?? '');
  }

  /// 触发区（fill 默认 add / drag area / 自定义 children）。
  Widget _buildTrigger(
    SemiResolvedUploadThemeData t,
    SemiThemeData global,
    bool rtl,
    List<SemiUploadFile> fileList,
  ) {
    if (widget.listType == SemiUploadListType.picture) {
      return const SizedBox.shrink();
    }
    // 列表模式 add 触发恒渲染（上游 renderAddContent 不按 limit 隐藏；
    // limit 满后点击仍走 handleChange 的替换/截断逻辑）。picture 模式才隐藏。
    if (widget.dragArea) {
      return _UploadDragArea(
        key: SemiUpload.triggerKey,
        t: t,
        disabled: widget.disabled,
        status: widget.dragAreaStatus,
        icon: widget.dragIcon,
        mainText: widget.dragMainText,
        subText: widget.dragSubText,
        child: widget.children,
        onTap: () => _openPicker(),
      );
    }
    if (widget.children == null) {
      return const SizedBox.shrink();
    }
    return MouseRegion(
      key: SemiUpload.triggerKey,
      cursor: widget.disabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openPicker(),
        child: widget.children!,
      ),
    );
  }

  Widget _buildPictureRow(
    SemiResolvedUploadThemeData t,
    SemiThemeData global,
    bool rtl,
    List<SemiUploadFile> fileList,
  ) {
    final limitFull = widget.limit != null && fileList.length >= widget.limit!;
    final add = limitFull
        ? null
        : _UploadPictureAdd(
            key: SemiUpload.triggerKey,
            t: t,
            width: widget.picWidth ?? t.widthUploadFilePicCard,
            height: widget.picHeight ?? t.heightUploadFilePicCard,
            disabled: widget.disabled,
            onTap: () => _openPicker(),
          );
    final cards = <Widget>[
      if (add != null && widget.hotSpotLocation == SemiUploadHotSpot.start) add,
      for (var i = 0; i < fileList.length; i++)
        _UploadPictureCard(
          key: ValueKey('SemiUpload.pic.${fileList[i].uid}'),
          file: fileList[i],
          index: i,
          t: t,
          width: widget.picWidth ?? t.widthUploadFilePicCard,
          height: widget.picHeight ?? t.heightUploadFilePicCard,
          disabled: widget.disabled,
          showReplace: widget.showReplace,
          showRetry: widget.showRetry,
          showPicInfo: widget.showPicInfo,
          thumbnail: widget.renderThumbnail?.call(fileList[i]),
          onRemove: () => _removeFile(fileList[i]),
          onRetry: () => _retry(fileList[i]),
          onReplace: () => _openPicker(replaceIndex: i),
          onPreview: widget.onPreviewClick == null
              ? null
              : () => widget.onPreviewClick!(fileList[i]),
        ),
      if (add != null && widget.hotSpotLocation == SemiUploadHotSpot.end) add,
    ];
    return Padding(
      key: SemiUpload.listKey,
      padding: EdgeInsetsDirectional.only(
        bottom: t.spacingUploadPictureFileCardMarginBottom,
      ),
      child: Wrap(
        spacing: t.spacingUploadPictureFileCardGap,
        runSpacing: t.spacingUploadPictureFileCardGap,
        children: cards,
      ),
    );
  }

  Widget _buildFileList(
    SemiResolvedUploadThemeData t,
    SemiThemeData global,
    List<SemiUploadFile> fileList,
  ) {
    final showTitle = widget.limit != 1 && fileList.isNotEmpty;
    final titleBuilder = widget.fileListTitle;
    Widget titleContent;
    if (titleBuilder
        is Widget Function(List<SemiUploadFile>, VoidCallback, String)) {
      titleContent = titleBuilder(
        fileList,
        () => _clear(),
        _UploadMetrics.localeClear,
      );
    } else {
      titleContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(
              end: t.spacingUploadTitleChoosenMarginRight,
            ),
            child: _content(titleBuilder ?? _UploadMetrics.localeSelectedFiles),
          ),
          if (widget.showClear && !widget.disabled)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _clear(),
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: t.colorUploadClearText),
                  child: const Text(_UploadMetrics.localeClear),
                ),
              ),
            ),
        ],
      );
    }
    return Padding(
      key: SemiUpload.listKey,
      padding: EdgeInsets.symmetric(
        vertical: t.spacingUploadFileCardPreviewMargin, // 8（title/list 上下距）
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showTitle)
            Padding(
              padding: EdgeInsetsDirectional.only(
                bottom: t.spacingUploadTitleMarginBottom,
              ),
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  fontSize: _UploadMetrics.fontSizeSmall,
                  color: t.colorUploadAssistText,
                ),
                child: titleContent,
              ),
            ),
          Wrap(
            spacing: t.spacingUploadFileCardPreviewMargin,
            runSpacing: t.spacingUploadFileCardPreviewMargin,
            children: [
              for (var i = 0; i < fileList.length; i++)
                _buildFileItem(t, fileList[i], i),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(
    SemiResolvedUploadThemeData t,
    SemiUploadFile file,
    int index,
  ) {
    final props = SemiUploadItemProps(
      file: file,
      index: index,
      listType: SemiUploadListType.list,
      disabled: widget.disabled,
      showRetry: widget.showRetry,
      showReplace: widget.showReplace,
      onRemove: () => _removeFile(file),
      onRetry: () => _retry(file),
      onReplace: () => _openPicker(replaceIndex: index),
      onPreview: widget.onPreviewClick == null
          ? null
          : () => widget.onPreviewClick!(file),
    );
    final builder = widget.renderFileItem;
    if (builder != null) {
      return builder(props);
    }
    return _UploadFileCard(
      key: ValueKey('SemiUpload.item.${file.uid}'),
      props: props,
      t: t,
      itemStyle: widget.itemStyle,
    );
  }
}

// -- Trigger widgets ----------------------------------------------------------

class _UploadDragArea extends StatefulWidget {
  const _UploadDragArea({
    super.key,
    required this.t,
    required this.disabled,
    required this.status,
    required this.icon,
    required this.mainText,
    required this.subText,
    required this.child,
    required this.onTap,
  });

  final SemiResolvedUploadThemeData t;
  final bool disabled;
  final SemiUploadDragAreaStatus status;
  final Widget? icon;
  final Object? mainText;
  final Object? subText;
  final Widget? child;
  final VoidCallback onTap;

  @override
  State<_UploadDragArea> createState() => _UploadDragAreaState();
}

class _UploadDragAreaState extends State<_UploadDragArea> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final custom = widget.child != null;
    final disabled = widget.disabled;
    final legal = widget.status == SemiUploadDragAreaStatus.legal;
    final illegal = widget.status == SemiUploadDragAreaStatus.illegal;
    final Color borderColor = disabled
        ? t.colorUploadBorder
        : legal || _hover
        ? t.colorUploadDragAreaBorderHover
        : t.colorUploadBorder;
    final Color bg = disabled || custom
        ? (custom ? const Color(0x00000000) : t.colorUploadDragAreaBg)
        : legal || _hover
        ? t.colorUploadDragAreaBgHover
        : t.colorUploadDragAreaBg;

    final Widget content =
        widget.child ??
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DefaultTextStyle.merge(
              style: TextStyle(
                color: disabled
                    ? t.colorUploadDragAreaDisabledText
                    : t.colorUploadDragAreaIcon,
              ),
              child:
                  widget.icon ??
                  // `IconUpload size="extra-large"`（24）。
                  const SemiIcon(
                    SemiIcons.upload,
                    size: SemiIconSize.extraLarge,
                  ),
            ),
            const SizedBox(height: 4),
            _DragAreaText(
              t: t,
              disabled: disabled,
              main: true,
              text: widget.mainText ?? _UploadMetrics.localeMainText,
            ),
            _DragAreaText(
              t: t,
              disabled: disabled,
              main: false,
              text: widget.subText,
            ),
            if (legal)
              DefaultTextStyle.merge(
                style: TextStyle(
                  fontSize: _UploadMetrics.fontSizeSmall,
                  fontWeight: t.fontUploadDragAreaTipsFontWeight,
                  color: t.colorUploadDragAreaTipsText,
                ),
                // `-tips-legal` 颜色（dragAreaStatus: legal 驱动）。
                child: const Text(_UploadMetrics.localeLegalTips),
              ),
            if (illegal)
              DefaultTextStyle.merge(
                style: TextStyle(
                  fontSize: _UploadMetrics.fontSizeSmall,
                  fontWeight: t.fontUploadDragAreaTipsFontWeight,
                ),
                child: const Text(_UploadMetrics.localeIllegalTips),
              ),
          ],
        );

    return MouseRegion(
      cursor: disabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      onEnter: disabled ? null : (_) => setState(() => _hover = true),
      onExit: disabled ? null : (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: disabled ? null : widget.onTap,
        child: custom
            ? content
            : LayoutBuilder(
                builder: (context, constraints) => Container(
                  // `width: 100%`（有界宽度下铺满；无界时按内容收窄）。
                  width: constraints.hasBoundedWidth
                      ? constraints.maxWidth
                      : null,
                  padding: EdgeInsets.all(t.spacingUploadDragAreaPadding),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(t.radiusUploadDragArea),
                    border: Border.all(
                      width: t.widthUploadDragAreaBorder,
                      color: borderColor,
                    ),
                  ),
                  child: content,
                ),
              ),
      ),
    );
  }
}

class _DragAreaText extends StatefulWidget {
  const _DragAreaText({
    required this.t,
    required this.disabled,
    required this.main,
    required this.text,
  });

  final SemiResolvedUploadThemeData t;
  final bool disabled;
  final bool main;
  final Object? text;

  @override
  State<_DragAreaText> createState() => _DragAreaTextState();
}

class _DragAreaTextState extends State<_DragAreaText> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    if (widget.text == null) {
      return const SizedBox.shrink();
    }
    final Color color;
    if (widget.disabled) {
      color = t.colorUploadDragAreaDisabledText;
    } else if (widget.main) {
      color = _pressed
          ? t.colorUploadDragAreaMainTextActive
          : _hover
          ? t.colorUploadDragAreaMainTextHover
          : t.colorUploadDragAreaMainTextDefault;
    } else {
      color = _pressed
          ? t.colorUploadDragAreaSubTextActive
          : _hover
          ? t.colorUploadDragAreaSubTextHover
          : t.colorUploadDragAreaSubTextDefault;
    }
    return MouseRegion(
      cursor: widget.disabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      onEnter: widget.disabled ? null : (_) => setState(() => _hover = true),
      onExit: widget.disabled ? null : (_) => setState(() => _hover = false),
      child: Listener(
        onPointerDown: widget.disabled
            ? null
            : (_) => setState(() => _pressed = true),
        onPointerUp: widget.disabled
            ? null
            : (_) => setState(() => _pressed = false),
        onPointerCancel: widget.disabled
            ? null
            : (_) => setState(() => _pressed = false),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            fontSize: widget.main
                ? _UploadMetrics.fontSizeRegular
                : _UploadMetrics.fontSizeSmall,
            color: color,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: widget.main
                  ? t.spacingUploadDragAreaMainTextMarginBottom
                  : 0,
            ),
            child: widget.text is Widget
                ? widget.text! as Widget
                : Text(widget.text.toString(), textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}

class _UploadPictureAdd extends StatefulWidget {
  const _UploadPictureAdd({
    super.key,
    required this.t,
    required this.width,
    required this.height,
    required this.disabled,
    required this.onTap,
  });

  final SemiResolvedUploadThemeData t;
  final double width;
  final double height;
  final bool disabled;
  final VoidCallback onTap;

  @override
  State<_UploadPictureAdd> createState() => _UploadPictureAddState();
}

class _UploadPictureAddState extends State<_UploadPictureAdd> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final Color bg;
    if (widget.disabled) {
      bg = t.colorUploadPicAddBg;
    } else if (_hover) {
      bg = t.colorUploadPicAddBgHover;
    } else if (_pressed) {
      bg = t.colorUploadPicAddBgActive;
    } else {
      bg = t.colorUploadPicAddBg;
    }
    return MouseRegion(
      cursor: widget.disabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      onEnter: widget.disabled ? null : (_) => setState(() => _hover = true),
      onExit: widget.disabled ? null : (_) => setState(() => _hover = false),
      child: Listener(
        onPointerDown: widget.disabled
            ? null
            : (_) => setState(() => _pressed = true),
        onPointerUp: widget.disabled
            ? null
            : (_) => setState(() => _pressed = false),
        onPointerCancel: widget.disabled
            ? null
            : (_) => setState(() => _pressed = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.disabled ? null : widget.onTap,
          child: Container(
            width: widget.width,
            height: widget.height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(t.radiusUploadPictureAdd),
              border: Border.all(
                width: t.widthUploadPictureAddBorder,
                color: t.colorUploadBorder,
              ),
            ),
            child: SemiIconTheme(
              data: SemiIconThemeData(color: t.colorUploadIcon),
              child: const SemiIcon(SemiIcons.plus, size: SemiIconSize.large),
            ),
          ),
        ),
      ),
    );
  }
}

// -- File card (list) ---------------------------------------------------------

class _UploadFileCard extends StatefulWidget {
  const _UploadFileCard({
    super.key,
    required this.props,
    required this.t,
    this.itemStyle,
  });

  final SemiUploadItemProps props;
  final SemiResolvedUploadThemeData t;
  final EdgeInsetsGeometry? itemStyle;

  @override
  State<_UploadFileCard> createState() => _UploadFileCardState();
}

class _UploadFileCardState extends State<_UploadFileCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final file = widget.props.file;
    final failed =
        file.status == SemiUploadFileStatus.uploadFail ||
        file.status == SemiUploadFileStatus.validateFail;
    final uploading = file.status == SemiUploadFileStatus.uploading;
    final showProgress = uploading && file.percent < 100;
    final showRetry =
        file.status == SemiUploadFileStatus.uploadFail &&
        widget.props.showRetry &&
        !widget.props.disabled;
    final showReplace =
        file.status == SemiUploadFileStatus.success &&
        widget.props.showReplace &&
        !widget.props.disabled;

    final Color bg = failed
        ? (_hover ? t.colorUploadCardFailBgHover : t.colorUploadCardFailBg)
        : (_hover ? t.colorUploadCardBgHover : t.colorUploadCardBg);

    final validateContent = _buildValidateMessage(t, file);
    return MouseRegion(
      cursor: widget.props.disabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.props.onPreview,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 0),
          width: t.widthUploadFileCard,
          height: t.heightUploadFileCard,
          padding: EdgeInsetsDirectional.only(
            end: t.spacingUploadFileCardCloseMarginRight,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(t.radiusUploadFileCard),
          ),
          child: Row(
            children: [
              _buildPreview(t, file),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DefaultTextStyle.merge(
                            style: TextStyle(
                              fontSize: _UploadMetrics.fontSizeRegular,
                              fontWeight:
                                  t.fontUploadFileCardInfoNameFontWeight,
                              color: t.colorUploadText,
                            ),
                            child: Text(
                              file.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.only(
                            start: t.spacingUploadFileCardInfoSizeMarginLeft,
                          ),
                          child: DefaultTextStyle.merge(
                            style: TextStyle(
                              fontSize: _UploadMetrics.fontSizeSmall,
                              fontWeight:
                                  t.fontUploadFileCardInfoSizeFontWeight,
                              color: t.colorUploadAssistText,
                            ),
                            child: Text(_formatFileSize(file.size)),
                          ),
                        ),
                        if (showReplace)
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                              start: t.spacingUploadFileCardInfoSizeMarginLeft,
                            ),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: widget.props.onReplace,
                                child: _UploadTooltip(
                                  message: _UploadMetrics.localeReplace,
                                  position: SemiTooltipPosition.top,
                                  child: SemiIconTheme(
                                    data: SemiIconThemeData(
                                      color: t.colorUploadAssistText,
                                    ),
                                    child: const SemiIcon(
                                      SemiIcons.folderOpen,
                                      size: SemiIconSize.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (showProgress)
                      Padding(
                        padding: EdgeInsets.only(
                          top: t.spacingUploadFileCardInfoProgressMarginTop,
                        ),
                        child: SemiProgress(
                          percent: file.percent,
                          showInfo: false,
                          height: 4,
                          semanticsLabel: 'uploading file progress',
                        ),
                      ),
                    if (validateContent != null || showRetry)
                      Row(
                        children: [
                          if (validateContent != null)
                            Flexible(
                              child: DefaultTextStyle.merge(
                                style: TextStyle(
                                  fontSize: _UploadMetrics.fontSizeSmall,
                                  color: failed
                                      ? t.colorUploadFileCardFailInfoText
                                      : t.colorUploadText,
                                ),
                                child: validateContent,
                              ),
                            ),
                          if (showRetry)
                            Padding(
                              padding: EdgeInsetsDirectional.only(
                                start:
                                    t.spacingUploadFileCardInfoRetryMarginLeft,
                              ),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: widget.props.onRetry,
                                  child: DefaultTextStyle.merge(
                                    style: TextStyle(
                                      fontSize: _UploadMetrics.fontSizeSmall,
                                      color: t.colorUploadRetryText,
                                    ),
                                    child: const Text(
                                      _UploadMetrics.localeRetry,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(
                  start: t.spacingUploadFileCardCloseMarginLeft,
                ),
                child: SemiButton(
                  null,
                  key: ValueKey('SemiUpload.remove.${widget.props.file.uid}'),
                  type: SemiButtonType.tertiary,
                  variant: SemiButtonVariant.borderless,
                  size: SemiButtonSize.small,
                  disabled: widget.props.disabled,
                  icon: const SemiIcon(SemiIcons.close),
                  onPressed: () => widget.props.onRemove(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(SemiResolvedUploadThemeData t, SemiUploadFile file) {
    final Widget child;
    if (file.thumbnail != null) {
      child = SizedBox(
        width: t.widthUploadFileCardPreviewImg,
        height: t.widthUploadFileCardPreviewImg,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(t.radiusUploadFileCardPreview),
          child: FittedBox(fit: BoxFit.cover, child: file.thumbnail),
        ),
      );
    } else if (file.isImage) {
      // `-preview { color: $color-upload_preview-icon }`（非占位态——图片缺
      // 缩略图时的兜底图标）。
      child = SemiIconTheme(
        data: SemiIconThemeData(color: t.colorUploadPreviewIcon),
        child: const SemiIcon(SemiIcons.image, size: SemiIconSize.large),
      );
    } else {
      // `-preview-placeholder`：灰底 + 白色文件图标。
      child = SemiIconTheme(
        data: SemiIconThemeData(
          color: t.colorUploadFileCardPreviewPlaceholderText,
        ),
        child: const SemiIcon(SemiIcons.file, size: SemiIconSize.large),
      );
    }
    return Container(
      width: t.widthUploadFileCardPreview,
      height: t.heightUploadFileCardPreview,
      margin: EdgeInsets.all(t.spacingUploadFileCardPreviewMargin),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: (file.thumbnail != null || file.isImage)
            ? const Color(0x00000000)
            : t.colorUploadFileCardPreviewPlaceholderBg,
        borderRadius: BorderRadius.circular(t.radiusUploadFileCardPreview),
      ),
      child: child,
    );
  }

  Widget? _buildValidateMessage(
    SemiResolvedUploadThemeData t,
    SemiUploadFile file,
  ) {
    final message = file.validateMessage;
    if (message == null) {
      return null;
    }
    if (message is Widget) {
      return message;
    }
    if (file.status == SemiUploadFileStatus.validating) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: t.widthUploadFileCardIcon,
            height: t.widthUploadFileCardIcon,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: const SemiSpin(size: SemiSpinSize.small),
            ),
          ),
          SizedBox(width: t.spacingUploadFileCardIconMarginRight),
          Flexible(child: Text(message.toString())),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SemiIcon(
          SemiIcons.alertCircle,
          customSize: t.widthUploadFileCardIcon,
          color: t.colorUploadFileCardFailInfoText,
        ),
        SizedBox(width: t.spacingUploadFileCardIconMarginRight),
        Flexible(child: Text(message.toString())),
      ],
    );
  }
}

// -- Picture card -------------------------------------------------------------

class _UploadPictureCard extends StatefulWidget {
  const _UploadPictureCard({
    super.key,
    required this.file,
    required this.index,
    required this.t,
    required this.width,
    required this.height,
    required this.disabled,
    required this.showReplace,
    required this.showRetry,
    required this.showPicInfo,
    required this.thumbnail,
    required this.onRemove,
    required this.onRetry,
    required this.onReplace,
    required this.onPreview,
  });

  final SemiUploadFile file;
  final int index;
  final SemiResolvedUploadThemeData t;
  final double width;
  final double height;
  final bool disabled;
  final bool showReplace;
  final bool showRetry;
  final bool showPicInfo;
  final Widget? thumbnail;
  final VoidCallback onRemove;
  final VoidCallback onRetry;
  final VoidCallback onReplace;
  final VoidCallback? onPreview;

  @override
  State<_UploadPictureCard> createState() => _UploadPictureCardState();
}

class _UploadPictureCardState extends State<_UploadPictureCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final file = widget.file;
    final failed =
        file.status == SemiUploadFileStatus.uploadFail ||
        file.status == SemiUploadFileStatus.validateFail;
    final uploading =
        file.status == SemiUploadFileStatus.uploading && file.percent < 100;
    final success = file.status == SemiUploadFileStatus.success;
    final showRetry = failed && widget.showRetry && !widget.disabled;
    final showReplace = success && widget.showReplace && !widget.disabled;
    final showPreview = widget.onPreview != null && success;
    final overlayVisible = _hover || uploading;

    Widget thumbnail;
    final custom = widget.thumbnail;
    if (custom != null) {
      thumbnail = SizedBox(
        width: widget.width,
        height: widget.height,
        child: FittedBox(fit: BoxFit.cover, child: custom),
      );
    } else if (file.isImage) {
      thumbnail = SemiIconTheme(
        data: SemiIconThemeData(
          color: t.colorUploadFileCardPreviewPlaceholderText,
        ),
        child: const SemiIcon(SemiIcons.image, size: SemiIconSize.extraLarge),
      );
    } else {
      thumbnail = SemiIconTheme(
        data: SemiIconThemeData(
          color: t.colorUploadFileCardPreviewPlaceholderText,
        ),
        child: const SemiIcon(SemiIcons.file, size: SemiIconSize.large),
      );
    }
    thumbnail = SizedBox(
      // `img { width: $width-upload_picture_file_card_img; height: 同值 }`。
      width: t.widthUploadPictureFileCardImg,
      height: t.widthUploadPictureFileCardImg,
      child: Center(child: thumbnail),
    );

    final children = <Widget>[
      thumbnail,
      if (overlayVisible)
        Positioned.fill(
          child: IgnorePointer(
            child: ColoredBox(color: t.colorUploadPictureFileCardHoverBg),
          ),
        ),
      if (uploading)
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: Center(
            child: SemiProgress(
              type: SemiProgressType.circle,
              percent: file.percent,
              showInfo: false,
              size: SemiProgressSize.small,
              orbitStroke: t.colorUploadFileCardPreviewPlaceholderText,
            ),
          ),
        ),
      if (showRetry)
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onRetry,
                child: Container(
                  width: t.widthUploadFileCardRetry,
                  height: t.widthUploadFileCardRetry,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: t.colorUploadFileCardRetryBg,
                    borderRadius: BorderRadius.circular(
                      t.radiusUploadFileCardRetry,
                    ),
                  ),
                  child: SemiIconTheme(
                    data: SemiIconThemeData(
                      color: t.colorUploadFileCardRetryText,
                    ),
                    child: Transform.scale(
                      scaleX: -1,
                      child: SemiIcon(
                        SemiIcons.refresh,
                        customSize: t.widthUploadFileCardRetryIcon,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      if (showReplace)
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onReplace,
                child: _UploadTooltip(
                  message: _UploadMetrics.localeReplace,
                  position: SemiTooltipPosition.top,
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: t.colorUploadReplaceText),
                    child: const SemiIcon(
                      SemiIcons.folderOpen,
                      size: SemiIconSize.large,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      if (showPreview && !showReplace)
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: Center(
            child: IgnorePointer(
              child: SemiIconTheme(
                data: SemiIconThemeData(
                  color: t.colorUploadPictureFileCardCloseIcon,
                ),
                child: const SemiIcon(
                  SemiIcons.eyeOpened,
                  size: SemiIconSize.large,
                ),
              ),
            ),
          ),
        ),
      if (file.validateMessage != null)
        PositionedDirectional(
          end: t.spacingUploadPictureFileCardLoadingErrorRight,
          bottom: t.spacingUploadPictureFileCardLoadingErrorBottom,
          child: failed
              ? Transform.translate(
                  // `-icon-error { top: -1px }`（spacingUploadPictureFileCardIconErrorTop）。
                  offset: Offset(0, t.spacingUploadPictureFileCardIconErrorTop),
                  child: SemiIcon(
                    SemiIcons.alertCircle,
                    customSize: t.widthUploadPictureFileCardLoadingIcon,
                    color: t.colorUploadPictureFileCardLoadingErrorIcon,
                  ),
                )
              : SizedBox(
                  width: t.widthUploadPictureFileCardLoadingIcon,
                  height: t.widthUploadPictureFileCardLoadingIcon,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SemiSpinTheme(
                      data: SemiSpinThemeData(
                        color: t.colorUploadPictureFileCardLoadingErrorIcon,
                      ),
                      child: const SemiSpin(size: SemiSpinSize.small),
                    ),
                  ),
                ),
        ),
      if (widget.showPicInfo && success)
        PositionedDirectional(
          start: 0,
          end: 0,
          bottom: 0,
          child: Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: AlignmentDirectional.centerStart,
            // `linear-gradient(0deg, rgba(22, 22, 26, 0.3) 0%, rgba(22, 22, 26, 0) 77.08%)`.
            decoration: BoxDecoration(
              color: t.colorUploadPictureFileCardHoverBg,
              backgroundBlendMode: BlendMode.srcOver,
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: t.fontUploadPictureFileCardPicInfoFontSize,
                fontWeight: t.fontUploadPictureFileCardPicInfoFontWeight,
                color: t.colorUploadPictureFileCardPicInfoText,
              ),
              child: Text('${widget.index + 1}'),
            ),
          ),
        ),
      if (!widget.disabled)
        PositionedDirectional(
          end: t.spacingUploadPictureFileCardCloseRight,
          top: t.spacingUploadPictureFileCardCloseTop,
          child: Visibility(
            visible: _hover,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onRemove,
                child: Container(
                  width: t.widthUploadPictureFileCardClose,
                  height: t.widthUploadPictureFileCardClose,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      t.radiusUploadPictureFileCardClose,
                    ),
                  ),
                  child: SemiIcon(
                    SemiIcons.clear,
                    customSize: t.widthUploadPictureFileCardClose,
                    color: t.colorUploadPictureFileCardCloseIcon,
                  ),
                ),
              ),
            ),
          ),
        ),
    ];

    return MouseRegion(
      cursor: widget.onPreview == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPreview,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              t.radiusUploadPictureFileCardImg,
            ),
            border: failed
                ? Border.all(
                    width: 1,
                    color: t.colorUploadPictureFileCardErrorBorder,
                  )
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(child: thumbnail),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// HARDCODES（另列）上游片段逐字留档（生成器 assertIn 锚点）。
abstract final class _UploadMetrics {
  /// utils.ts:1 `byteKB = 1024`（尺寸校验单位）。
  static const int byteKB = 1024;

  /// constants.ts:24 `PROGRESS_COEFFICIENT: 0.95`（浏览器 XHR 进度的 95% 截断；
  /// 自定义请求进度由应用给 0–100——note-only）。
  // ignore: unused_field
  static const double progressCoefficient = 0.95;

  /// zh_CN.ts:139 `mainText: '点击上传文件或拖拽文件到这里'`。
  static const String localeMainText = '点击上传文件或拖拽文件到这里';

  /// zh_CN.ts:140 `illegalTips: '不支持此类型文件'`。
  static const String localeIllegalTips = '不支持此类型文件';

  /// zh_CN.ts:141 `legalTips: '松手开始上传'`。
  static const String localeLegalTips = '松手开始上传';

  /// zh_CN.ts:142 `retry: '重试'`。
  static const String localeRetry = '重试';

  /// zh_CN.ts:143 `replace: '替换文件'`。
  static const String localeReplace = '替换文件';

  /// zh_CN.ts:144 `clear: '清空'`。
  static const String localeClear = '清空';

  /// zh_CN.ts:146 `selectedFiles: '已选择文件'`。
  static const String localeSelectedFiles = '已选择文件';

  /// zh_CN.ts:147 `illegalSize: '文件尺寸不合法'`。
  static const String localeIllegalSize = '文件尺寸不合法';

  /// zh_CN.ts:148 `fail: '上传失败'`。
  static const String localeFail = '上传失败';

  /// `@include font-size-regular` / `small`。
  static const double fontSizeRegular = 14;
  static const double fontSizeSmall = 12;

  /// 图片扩展名（constants.ts `imageTypes`）。
  static const List<String> imageExtensions = [
    'image',
    'webp',
    'png',
    'svg',
    'gif',
    'jpg',
    'jpeg',
    'bmp',
    'dpg',
  ];

  // note-only 上游片段（生成器锚点逐字留档）：
  // fileCard 关闭按钮用 `IconClose`；图片墙关闭用 `IconClear`；上传图标
  // `IconUpload size="extra-large"`；列表 aria `aria-label="picture list"` /
  // `aria-label="file list"`；`PROMPT_POSITION: ['left', 'right', 'bottom']`；
  // `getUuidv4()` 自动补 uid；文件尺寸 `toFixed(2)`（<1KB）/`toFixed(1)`
  // （KB/MB）格式化（utils.ts:6-16）；图片墙 hover 遮罩
  // `linear-gradient(0deg, rgba(22, 22, 26, 0.3) 0%, rgba(22, 22, 26, 0) 77.08%)`
  // 以 overlay-bg 近似；★`rgba(var(--semi-grey-3), 1)` / `rgba(var(--semi-white), 1)`
  // 白色/灰色写法 quirk；隐藏 input（`hidden-input`）由 onPickFiles 取代。
}

String _formatFileSize(num size) {
  // utils.ts:6-16 `getFileSize`（<1KB 两位小数、KB/MB 一位小数）。
  const kb = _UploadMetrics.byteKB;
  const mb = 1048576;
  if (size < kb) {
    return '${(size / kb).toStringAsFixed(2)}KB';
  } else if (size < mb) {
    return '${(size / kb).toStringAsFixed(1)}KB';
  }
  return '${(size / mb).toStringAsFixed(1)}MB';
}

class _UploadTooltip extends StatelessWidget {
  const _UploadTooltip({
    required this.message,
    this.position = SemiTooltipPosition.top,
    required this.child,
  });

  final String message;
  final SemiTooltipPosition position;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SemiTooltip(
      trigger: SemiTooltipTrigger.hover,
      position: position,
      showArrow: false,
      mouseEnterDelay: const Duration(milliseconds: 50),
      mouseLeaveDelay: const Duration(milliseconds: 100),
      content: Text(message),
      child: child,
    );
  }
}
