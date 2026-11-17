// SemiCropper — 上游 packages/semi-ui/cropper/index.tsx 与
// packages/semi-foundation/cropper/{cropper.scss,variables.scss,foundation.ts,
// constants.ts,utils.ts} 的移植。
//
// 主题对账 **5 = 5 FIELDS + 0 MOTION + 0 INTERNAL**（variables.scss 5 声明：
// color 3、width 2；无 animation.scss；`$module` 胶水与 cropper.scss 局部
// `$half_corner_width: calc($width-cropper_box_corner / 2)` 不计，banner
// `22 = 22 + 0 + 0`、carousel `40 = 34 + 6 + 0` 先例）。0 死变量。
//
// HARDCODES（另列，生成器锚点逐字留档）：
// - constants.ts：moduleName = `${BASE_CLASS_PREFIX}-cropper`；
//   strings.shape: ['rect', 'round', 'roundRect']；
//   strings.corner: ['tl', 'tm', 'tr', 'ml', 'mr', 'bl', 'bm', 'br']；
//   strings.roundCorner: ['tm', 'ml', 'mr', 'bm']（round 仅四边中点柄）
// - index.tsx defaultProps：shape: 'rect' / defaultAspectRatio: 1 /
//   showResizeBox: true / fill: 'rgba(0, 0, 0, 0)' / maxZoom: 3 /
//   minZoom: 0.1 / zoomStep: 0.1
// - index.tsx img：crossOrigin='anonymous'、alt=""、
//   transformOrigin: 'center'（顶点平移 + 绕自身中心旋转）
// - cropper.scss：img 规则 tailwindCSS 防污 max-width: none；
//   `-img`/`-view-img` user-select: none；`-mask` 规则 cursor: move;; 双分号；
//   `tl`/`br` 光标 cursor: nwse-resize（br 行缺分号，照抄）、`tr`/`bl`
//   nesw-resize、`tm`/`bm` ns-resize、`ml`/`mr` ew-resize；
//   `$half_corner_width: calc($width-cropper_box_corner / 2)` 角柄半宽外偏
//   （`margin-left: -$half_corner_width` 等；`-bm` 行尾空格，照抄）；
//   `-view-img` 残留注释 `// position: absolute;`；
//   `-view-box-round` border-radius: 50%（round/roundRect 椭圆裁切，
//   round 外框 outline 同形）
// - index.tsx wheel 注册 `{ passive: false }`（e.preventDefault() 防双手
//   缩放放大页面）；foundation.ts handleWheel 步进
//   `(currZoom + zoomStep).toFixed(2)`、指针定点缩放；受控同步
//   getDerivedStateFromProps 注释 `centerPoint 的 y 坐标与实际的坐标系方向
//   相反`（y 翻转公式）
// - index.tsx viewIMGDragStart 拖影抑制；foundation.ts
//   handleCropperBoxMouseDown 的 `target.dataset.dir` 角柄命中不移动；
//   ResizeObserver ObserverProperty.Width 仅宽向；utils.ts getAspectHW /
//   getMiddle；changeDir 越界翻柄
// - foundation.ts getCropperCanvas 裁切输出：越界补
//   fillRect(0, 0, relativeWidth, relativeHeight)、
//   getImageData(realLeft, realTop, realWidth, realHeight)、
//   relativeCropLeft < 0 ? - relativeCropLeft : 0 修正贴图偏移
//
// PORT 适配（差异清单同步）：
// - 角柄光标 kind：cropper.scss 全双向（nwse/nesw/ns/ew-resize）→
//   resizeUpLeftDownRight / resizeUpRightDownLeft / resizeUpDown /
//   resizeLeftRight；macOS 桌面引擎 cursor 表无对角线光标（NSCursor 公共
//   API 缺失，flutter/flutter#138887 → #89351 跟踪；WebKit 走私有
//   CoreCursor），四个对角角柄（tl/tr/bl/br）改为隐藏系统光标 + 自绘双向
//   对角箭头（`_DiagonalResizeCursorPainter`），边中点（tm/bm/ml/mr）仍用
//   系统双向箭头；Web/Windows/Linux 全部走系统对角线光标。
// - 平移光标 kind（`-mask`/`-view-box` `cursor: move`）：macOS 引擎
//   cursor 表无 `move`（WebKit 走私有 CoreCursor `kCoreCursorWindowMove`），
//   改为隐藏系统光标 + 组件内自绘四向箭头（`_MoveCursorPainter`，容器坐标
//   跟随、出界停绘）；Web/Windows/Linux 走系统 move。
// - 角柄钳回容器：RenderBox.hitTest 不收自身边界外的点，贴边裁切框
//   （初始态）的 $half_corner_width 外悬半格落在容器外成死区（拖不动、
//   光标不切换；上游 DOM 命中不受父盒边界限制），柄位钳回
//   [0, 容器 - 柄] 整只可命中（不贴边时与上游同形）。
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../theme/semi_cropper_theme.dart';
import '../theme/semi_cropper_theme_data.dart';

/// 裁切框形状（上游 `strings.shape`，缺省 `rect`）。
enum SemiCropperShape {
  /// 矩形框（8 角柄）。
  rect,

  /// 圆形框（4 边中点柄，外框与视口同形）。
  round,

  /// 圆角矩形（8 角柄，视口 `border-radius: 50%`）。
  roundRect,
}

/// 裁切控制器（上游 ref 方法 `getCropperCanvas`）。
class SemiCropperController {
  _SemiCropperState? _state;

  void _attach(_SemiCropperState state) => _state = state;
  void _detach(_SemiCropperState state) {
    if (_state == state) _state = null;
  }

  bool get isAttached => _state != null;

  /// 裁切结果（上游 `getCropperCanvas()`：原图分辨率、旋转外接矩形内裁出）。
  ///
  /// 未 attach 或图片未加载完成时抛 [StateError]。
  Future<ui.Image> getCropperImage() {
    final state = _state;
    if (state == null) {
      throw StateError(
        'SemiCropperController is not attached to a SemiCropper',
      );
    }
    return state._getCropperImage();
  }
}

/// 图片裁切（Semi Cropper）。
///
/// 拖动遮罩平移图片、滚轮/触控板定点缩放、拖动裁切框、拖动角柄缩放裁切框
/// （[aspectRatio] 非空时定比）；[zoom] / [rotate] 受控（非 null 即受控，
/// 同上游 `getDerivedStateFromProps` 语义）；[previewBuilder] 实时预览；
/// [SemiCropperController.getCropperImage] 输出裁切结果。
///
/// 尺寸：上游容器 `style` 定宽高，Flutter 需父级给出有界宽高（如 [SizedBox]）。
class SemiCropper extends StatefulWidget {
  const SemiCropper({
    super.key,
    required this.image,
    this.shape = SemiCropperShape.rect,
    this.aspectRatio,
    this.defaultAspectRatio = 1,
    this.zoom,
    this.onZoomChange,
    this.rotate,
    this.showResizeBox = true,
    this.fill = const Color(0x00000000),
    this.maxZoom = 3,
    this.minZoom = 0.1,
    this.zoomStep = 0.1,
    this.previewBuilder,
    this.controller,
  });

  /// 被裁切图片（上游 `src`）。
  final ImageProvider image;

  /// 裁切框形状（上游 `shape`）。
  final SemiCropperShape shape;

  /// 受控裁切框宽高比；非空时角柄拖动定比缩放。
  final double? aspectRatio;

  /// 初始裁切框宽高比（仅首次生效，拖动后随拖动变化）。
  final double defaultAspectRatio;

  /// 受控缩放（非 null 即受控）；拖轮改变后经 [onZoomChange] 回调。
  final double? zoom;

  /// 缩放回调（上游 `onZoomChange`）。
  final ValueChanged<double>? onZoomChange;

  /// 受控旋转角度（度，顺时针）。
  final double? rotate;

  /// 显示角柄调整块（上游 `showResizeBox`）。
  final bool showResizeBox;

  /// 裁切结果中非图片部分的填充色（上游 `fill`）。
  final Color fill;

  /// 最大缩放倍数。
  final double maxZoom;

  /// 最小缩放倍数。
  final double minZoom;

  /// 缩放步长（滚轮每格）。
  final double zoomStep;

  /// 实时预览布局（上游 `preview: () => HTMLElement` 容器制）。
  ///
  /// 返回同时放置 [cropper] 与 [cropView] 的子树；`cropView` 为裁切区域
  /// 视图，在给定约束内按上游 `updatePreview` 适配数学自缩放。
  final Widget Function(BuildContext context, Widget cropper, Widget cropView)?
  previewBuilder;

  /// 裁切输出控制器。
  final SemiCropperController? controller;

  static const maskKey = ValueKey<String>('semi-cropper-mask');
  static const boxKey = ValueKey<String>('semi-cropper-box');
  static const viewBoxKey = ValueKey<String>('semi-cropper-view-box');
  static const imageKey = ValueKey<String>('semi-cropper-image');
  static const cropViewKey = ValueKey<String>('semi-cropper-crop-view');

  /// macOS 自绘的平移光标（系统光标表无 move）。
  static const moveCursorKey = ValueKey<String>('semi-cropper-move-cursor');

  /// 角柄自绘的对角光标（macOS 系统光标表无对角线 resize）。
  static Key resizeCursorKey(String dir) =>
      ValueKey<String>('semi-cropper-resize-cursor-$dir');
  static Key cornerKey(String dir) =>
      ValueKey<String>('semi-cropper-corner-$dir');

  @override
  State<SemiCropper> createState() => _SemiCropperState();
}

/// 上游 `ImageDataState` / `CropperBox`（width/height/centerPoint）。
class _CropRect {
  const _CropRect(this.width, this.height, this.center);
  final double width;
  final double height;
  final Offset center;
  double get left => center.dx - width / 2;
  double get top => center.dy - height / 2;
}

/// 上游 utils.ts `getMiddle`：钳值入 `[min, max]`。
double _getMiddle(double value, (double, double) range) =>
    value.clamp(range.$1, range.$2).toDouble();

/// 上游 utils.ts `getAspectHW`：等比内收 (width, height)。
(double, double) _getAspectHW(double width, double height, double aspect) {
  if (width / height > aspect) {
    width = height * aspect;
  } else {
    height = width / aspect;
  }
  return (width, height);
}

/// 平移光标（`-mask` / `-view-box` 的 `cursor: move`）：macOS 引擎 cursor
/// 表无 `move`（WebKit 走私有 CoreCursor），隐藏系统光标改由组件内自绘四向
/// 箭头（_MoveCursorPainter）；Web/Windows/Linux 走系统 move。
MouseCursor _moveCursor() {
  if (_usesDrawnCursor) return SystemMouseCursors.none;
  return SystemMouseCursors.move;
}

/// macOS 桌面：系统光标表无 `move` 与对角线 resize，组件内自绘这两个字形；
/// 边中点仍用系统双向箭头，其余平台全走系统光标。
bool get _usesDrawnCursor =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

/// 角柄光标（cropper.scss 全双向）：tl/br nwse-resize、tr/bl nesw-resize、
/// tm/bm ns-resize、ml/mr ew-resize。
MouseCursor _cornerCursor(String dir) {
  const cursors = <String, MouseCursor>{
    'tl': SystemMouseCursors.resizeUpLeftDownRight,
    'tm': SystemMouseCursors.resizeUpDown,
    'tr': SystemMouseCursors.resizeUpRightDownLeft,
    'ml': SystemMouseCursors.resizeLeftRight,
    'mr': SystemMouseCursors.resizeLeftRight,
    'bl': SystemMouseCursors.resizeUpRightDownLeft,
    'bm': SystemMouseCursors.resizeUpDown,
    'br': SystemMouseCursors.resizeUpLeftDownRight,
  };
  // macOS 桌面引擎 cursor 表无对角线光标（NSCursor 公共 API 缺失，
  // flutter/flutter#138887 → #89351 跟踪；未映射 → 箭头），四个对角角柄
  // 改为隐藏系统光标 + 自绘（_CornerHandle / _DiagonalResizeCursorPainter）；
  // 边中点用系统双向箭头。Web 无此缺口（CSS 原生对角线），不退化。
  if (!_usesDrawnCursor) {
    return cursors[dir]!;
  }
  return switch (dir) {
    'tm' || 'bm' => SystemMouseCursors.resizeUpDown,
    'ml' || 'mr' => SystemMouseCursors.resizeLeftRight,
    _ => SystemMouseCursors.none,
  };
}

enum _DragMode { none, imgMove, boxMove, cornerResize }

class _SemiCropperState extends State<SemiCropper> {
  // foundation.ts 实例字段。
  ui.Image? _image;
  ImageStream? _stream;
  ImageStreamListener? _listener;
  double _originalWidth = 0;
  double _originalHeight = 0;
  double _scale = 1;
  Size _containerData = Size.zero;
  String _boxMoveDir = '';
  ({double x, double y}) _boxMoveParam = (x: 0, y: 0);
  Offset? _cropperBoxMoveStart;
  Offset? _imgMoveStart;
  ({double xMin, double xMax, double yMin, double yMax})? _moveRange;
  (double, double)? _rangeX;
  (double, double)? _rangeY;

  // 上游 state。
  _CropRect _imgData = const _CropRect(0, 0, Offset.zero);
  _CropRect _cropperBox = const _CropRect(0, 0, Offset.zero);
  double _zoom = 1;
  double _rotate = 0;
  bool _loaded = false;

  _DragMode _dragMode = _DragMode.none;

  /// 自绘光标的指针位置（容器坐标；容器不随角柄拖动移动）。
  final ValueNotifier<Offset?> _drawnAt = ValueNotifier<Offset?>(null);

  /// 角柄命中区（容器坐标，布局时收集）：悬停时判定落在哪个角柄。
  final Map<String, Rect> _cornerHitRects = <String, Rect>{};

  bool _isDiagonalCorner(String dir) =>
      dir == 'tl' || dir == 'tr' || dir == 'bl' || dir == 'br';

  String? _cornerDirAt(Offset at) {
    for (final entry in _cornerHitRects.entries) {
      if (entry.value.contains(at)) return entry.key;
    }
    return null;
  }

  /// 当前应绘制的光标（macOS）：对角角柄 → 对角箭头；edge 角柄走系统光标；
  /// 其余（含平移拖动）→ 四向移动箭头。
  ///
  /// 指针出界即不绘制：组件外的光标归宿主所有，避免"系统箭头 + 自绘光标"
  /// 两个光标同时出现。
  ({Key key, CustomPainter painter})? _drawnGlyph(Offset? at) {
    if (!_usesDrawnCursor || at == null) return null;
    if (!(Offset.zero & _containerData).contains(at)) return null;
    if (_dragMode == _DragMode.cornerResize) {
      if (!_isDiagonalCorner(_boxMoveDir)) return null;
      return (
        key: SemiCropper.resizeCursorKey(_boxMoveDir),
        painter: _DiagonalResizeCursorPainter(
          hotspot: at,
          nwse: _boxMoveDir == 'tl' || _boxMoveDir == 'br',
        ),
      );
    }
    final dir = _cornerDirAt(at);
    if (dir != null) {
      if (!_isDiagonalCorner(dir)) return null;
      return (
        key: SemiCropper.resizeCursorKey(dir),
        painter: _DiagonalResizeCursorPainter(
          hotspot: at,
          nwse: dir == 'tl' || dir == 'br',
        ),
      );
    }
    return (key: SemiCropper.moveCursorKey, painter: _MoveCursorPainter(at));
  }

  /// 拖动结束/指针离开后，按当前指针位置修剪自绘光标。
  void _pruneDrawnAt() {
    final at = _drawnAt.value;
    if (at != null && !(Offset.zero & _containerData).contains(at)) {
      _drawnAt.value = null;
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    _resolveImage();
  }

  @override
  void didUpdateWidget(SemiCropper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
    if (oldWidget.image != widget.image) {
      _resolveImage();
    }
    // aspectRatio 变化：上游 componentDidUpdate 仅 unBindResizeEvent
    // （清残留拖动监听），几何不变，后续拖动按新比例走。
  }

  @override
  void dispose() {
    _drawnAt.dispose();
    if (_listener != null) _stream?.removeListener(_listener!);
    widget.controller?._detach(this);
    super.dispose();
  }

  void _resolveImage() {
    if (_listener != null) _stream?.removeListener(_listener!);
    final stream = widget.image.resolve(ImageConfiguration.empty);
    _listener = ImageStreamListener(_onImage, onError: (error, stack) {});
    stream.addListener(_listener!);
    _stream = stream;
  }

  void _onImage(ImageInfo info, bool synchronousCall) {
    // 同步回调（缓存命中，initState/didUpdateWidget 期间）不能 setState。
    void apply() {
      _image = info.image;
      _handleImageLoad(
        info.image.width.toDouble(),
        info.image.height.toDouble(),
      );
    }

    if (synchronousCall) {
      apply();
    } else {
      setState(apply);
    }
  }

  /// 上游 foundation.ts handleImageLoad：适配容器的初始显示尺寸 + 初始裁切框。
  void _handleImageLoad(double naturalWidth, double naturalHeight) {
    final containerWidth = _containerData.width;
    final containerHeight = _containerData.height;
    if (containerWidth == 0 || containerHeight == 0) return;
    _originalWidth = naturalWidth;
    _originalHeight = naturalHeight;
    double scale;
    late double width, height;
    if (naturalWidth / containerWidth > naturalHeight / containerHeight) {
      scale = containerWidth / naturalWidth;
      width = containerWidth;
      height = naturalHeight * scale;
    } else {
      scale = containerHeight / naturalHeight;
      width = naturalWidth * scale;
      height = containerHeight;
    }
    _scale = scale;
    width *= _zoom;
    height *= _zoom;
    final imgCenter = Offset(containerWidth / 2, containerHeight / 2);
    // 计算裁切框大小
    final calcAspect = widget.aspectRatio ?? widget.defaultAspectRatio;
    late double boxWidth, boxHeight;
    if (containerWidth / containerHeight > calcAspect) {
      boxWidth = containerHeight * calcAspect;
      boxHeight = containerHeight;
    } else {
      boxWidth = containerWidth;
      boxHeight = containerWidth / calcAspect;
    }
    _imgData = _CropRect(width, height, imgCenter);
    _cropperBox = _CropRect(boxWidth, boxHeight, imgCenter);
    _loaded = true;
  }

  /// 上游 ResizeObserver（ObserverProperty.Width）handleResize：仅宽向变化
  /// 触发，按宽比缩放图片与裁切框。LayoutBuilder 首帧记录尺寸（上游 init +
  /// ResizeObserver 立即回调的 `initial` 跳过并入首帧，行为等价）。
  void _handleLayout(Size size) {
    if (_containerData == Size.zero) {
      _containerData = size;
      if (_image != null && !_loaded) {
        _handleImageLoad(_image!.width.toDouble(), _image!.height.toDouble());
      }
      return;
    }
    if (size.width == _containerData.width) {
      _containerData = size;
      return;
    }
    if (!_loaded) {
      _containerData = size;
      return;
    }
    final ratio = size.width / _containerData.width;
    final newImgData = _CropRect(
      _imgData.width * ratio,
      _imgData.height * ratio,
      _imgData.center * ratio,
    );
    _scale *= ratio;
    final newCropperBox = _getCropperBoxWhenResize(ratio, size);
    _containerData = size;
    _imgData = newImgData;
    _cropperBox = newCropperBox;
  }

  /// 上游 getCropperBoxWhenResize：比例缩放后钳回新容器（定比时保 aspect）。
  _CropRect _getCropperBoxWhenResize(double ratio, Size newContainerData) {
    final box = _cropperBox;
    final aspectRatio = widget.aspectRatio;
    final temp = _CropRect(
      box.width * ratio,
      box.height * ratio,
      box.center * ratio,
    );
    var xMin = temp.left;
    var xMax = temp.left + temp.width;
    var yMin = temp.top;
    var yMax = temp.top + temp.height;
    if (aspectRatio != null) {
      if (xMax > newContainerData.width) {
        xMax = newContainerData.width;
        xMin = temp.width > newContainerData.width
            ? 0
            : newContainerData.width - temp.width;
        final width = xMax - xMin;
        final height = width / aspectRatio;
        yMax = yMin + height;
        return _CropRect(
          width,
          height,
          Offset((xMax + xMin) / 2, (yMax + yMin) / 2),
        );
      }
      if (yMax > newContainerData.height) {
        yMax = newContainerData.height;
        yMin = temp.height > newContainerData.height
            ? 0
            : newContainerData.height - temp.height;
        final height = yMax - yMin;
        final width = height * aspectRatio;
        xMax = xMin + width;
        return _CropRect(
          width,
          height,
          Offset((xMax + xMin) / 2, (yMax + yMin) / 2),
        );
      }
    } else {
      if (xMax > newContainerData.width) {
        xMax = newContainerData.width;
        xMin = temp.width > newContainerData.width
            ? 0
            : newContainerData.width - temp.width;
      }
      if (yMax > newContainerData.height) {
        yMax = newContainerData.height;
        yMin = temp.height > newContainerData.height
            ? 0
            : newContainerData.height - temp.height;
      }
    }
    return _CropRect(
      xMax - xMin,
      yMax - yMin,
      Offset((xMax + xMin) / 2, (yMax + yMin) / 2),
    );
  }

  /// 上游 getDerivedStateFromProps（受控 rotate/zoom 同步；未加载不动）。
  ///
  /// 因为以裁切框的左上方顶点作为原点，所以centerPoint 的 y 坐标与实际的坐标系方向相反，
  /// 因此 y 方向需要先做变换，再使用旋转变换公式计算中心点坐标。
  /// （build 顶部执行：React 每次 render 前派生状态的等价位置。）
  void _syncControlledProps() {
    if (!_loaded) return;
    var width = _imgData.width;
    var height = _imgData.height;
    var center = _imgData.center;
    var changed = false;
    final newRotate = widget.rotate;
    if (newRotate != null && newRotate != _rotate) {
      final oldRotate = _rotate;
      _rotate = newRotate;
      changed = true;
      // 同上（y 翻转）
      final rotateCenter = Offset(
        _cropperBox.center.dx,
        -_cropperBox.center.dy,
      );
      final imgCenter = Offset(center.dx, -center.dy);
      final angle = (newRotate - oldRotate) * math.pi / 180;
      center = Offset(
        (imgCenter.dx - rotateCenter.dx) * math.cos(angle) +
            (imgCenter.dy - rotateCenter.dy) * math.sin(angle) +
            rotateCenter.dx,
        -(-(imgCenter.dx - rotateCenter.dx) * math.sin(angle) +
            (imgCenter.dy - rotateCenter.dy) * math.cos(angle) +
            rotateCenter.dy),
      );
    }
    final newZoom = widget.zoom;
    if (newZoom != null && newZoom != _zoom) {
      final oldZoom = _zoom;
      _zoom = newZoom;
      changed = true;
      // 同上（y 翻转）
      final scaleCenter = Offset(_cropperBox.center.dx, -_cropperBox.center.dy);
      final currentImgCenter = Offset(center.dx, -center.dy);
      width = width / oldZoom * newZoom;
      height = height / oldZoom * newZoom;
      center = Offset(
        (currentImgCenter.dx - scaleCenter.dx) / oldZoom * newZoom +
            scaleCenter.dx,
        -((currentImgCenter.dy - scaleCenter.dy) / oldZoom * newZoom +
            scaleCenter.dy),
      );
    }
    if (changed) {
      _imgData = _CropRect(width, height, center);
    }
  }

  /// 上游 handleWheel：定点缩放（步进取两位小数、min/max 钳制）。
  void _handleWheel(PointerScrollEvent event) {
    final scrollDown = event.scrollDelta.dy > 0;
    final scrollUp = event.scrollDelta.dy < 0;
    double? next;
    if (scrollUp) {
      // zoom in
      final value = double.parse((_zoom + widget.zoomStep).toStringAsFixed(2));
      if (value <= widget.maxZoom) next = value;
    } else if (scrollDown) {
      // zoom out
      final value = double.parse((_zoom - widget.zoomStep).toStringAsFixed(2));
      if (value >= widget.minZoom) next = value;
    }
    if (next == null) return;
    final zoom = next;
    final offset = event.localPosition;
    final scaleCenter = Offset(offset.dx, -offset.dy);
    // 计算新的中心点位置（y 翻转）
    final currentPoint = Offset(_imgData.center.dx, -_imgData.center.dy);
    final newCenterPoint = Offset(
      (currentPoint.dx - scaleCenter.dx) / _zoom * zoom + scaleCenter.dx,
      -((currentPoint.dy - scaleCenter.dy) / _zoom * zoom + scaleCenter.dy),
    );
    setState(() {
      _imgData = _CropRect(
        _imgData.width / _zoom * zoom,
        _imgData.height / _zoom * zoom,
        newCenterPoint,
      );
      _zoom = zoom;
    });
    widget.onZoomChange?.call(zoom);
  }

  /// 上游 getMoveParamByDir。
  ({double x, double y}) _getMoveParamByDir(String dir) {
    switch (dir) {
      case 'tl':
        return (x: -1, y: -1);
      case 'tm':
        return (x: 0, y: -1);
      case 'tr':
        return (x: 1, y: -1);
      case 'ml':
        return (x: -1, y: 0);
      case 'mr':
        return (x: 1, y: 0);
      case 'bl':
        return (x: -1, y: 1);
      case 'bm':
        return (x: 0, y: 1);
      case 'br':
        return (x: 1, y: 1);
    }
    return (x: 0, y: 0);
  }

  /// 上游 getRangeForAspectChange：定比拖动的各向活动范围。
  void _getRangeForAspectChange() {
    final box = _cropperBox;
    final aspectRatio = widget.aspectRatio!;
    final containerWidth = _containerData.width;
    final containerHeight = _containerData.height;
    // 可能的最大宽高
    double height, width;
    // 裁剪框当前的位置
    final xMin = box.left;
    final xMax = box.left + box.width;
    final yMin = box.top;
    final yMax = box.top + box.height;
    switch (_boxMoveDir) {
      case 'tl':
        height = yMax;
        width = xMax;
        (width, height) = _getAspectHW(width, height, aspectRatio);
        _rangeX = (xMax - width, xMax);
        _rangeY = (yMax - height, yMax);
        break;
      case 'tm':
        height = yMax;
        final leftHalfWidth = box.center.dx;
        final rightHalfWidth = containerWidth - box.center.dx;
        width =
            2 *
            (leftHalfWidth < rightHalfWidth ? leftHalfWidth : rightHalfWidth);
        (width, height) = _getAspectHW(width, height, aspectRatio);
        _rangeX = (box.center.dx - width / 2, box.center.dx + width / 2);
        _rangeY = (yMax - height, yMax);
        break;
      case 'tr':
        height = yMax;
        width = containerWidth - xMin;
        (width, height) = _getAspectHW(width, height, aspectRatio);
        _rangeX = (xMin, xMin + width);
        _rangeY = (yMax - height, yMax);
        break;
      case 'ml':
        width = xMax;
        final topHalfHeight = box.center.dy;
        final bottomHalfHeight = containerHeight - box.center.dy;
        height =
            2 *
            (topHalfHeight < bottomHalfHeight
                ? topHalfHeight
                : bottomHalfHeight);
        (width, height) = _getAspectHW(width, height, aspectRatio);
        _rangeX = (xMax - width, xMax);
        _rangeY = (box.center.dy - height / 2, box.center.dy + height / 2);
        break;
      case 'mr':
        width = containerWidth - xMin;
        final topHalfHeight2 = box.center.dy;
        final bottomHalfHeight2 = containerHeight - box.center.dy;
        height =
            2 *
            (topHalfHeight2 < bottomHalfHeight2
                ? topHalfHeight2
                : bottomHalfHeight2);
        (width, height) = _getAspectHW(width, height, aspectRatio);
        _rangeX = (xMin, xMin + width);
        _rangeY = (box.center.dy - height / 2, box.center.dy + height / 2);
        break;
      case 'bl':
        height = containerHeight - yMin;
        width = xMax;
        (width, height) = _getAspectHW(width, height, aspectRatio);
        _rangeX = (xMax - width, xMax);
        _rangeY = (yMin, yMin + height);
        break;
      case 'bm':
        height = containerHeight - yMin;
        final leftHalfWidth2 = box.center.dx;
        final rightHalfWidth2 = containerWidth - box.center.dx;
        width =
            2 *
            (leftHalfWidth2 < rightHalfWidth2
                ? leftHalfWidth2
                : rightHalfWidth2);
        (width, height) = _getAspectHW(width, height, aspectRatio);
        _rangeX = (box.center.dx - width / 2, box.center.dx + width / 2);
        _rangeY = (yMin, yMin + height);
        break;
      case 'br':
        height = containerHeight - yMin;
        width = containerWidth - xMin;
        (width, height) = _getAspectHW(width, height, aspectRatio);
        _rangeX = (xMin, xMin + width);
        _rangeY = (yMin, yMin + height);
        break;
    }
  }

  /// 上游 changeDir：拖过零点翻柄。
  void _changeDir() {
    var dir = _boxMoveDir;
    if (dir.contains('t')) {
      dir = dir.replaceFirst('t', 'b');
    } else if (dir.contains('b')) {
      dir = dir.replaceFirst('b', 't');
    }
    if (dir.contains('l')) {
      dir = dir.replaceFirst('l', 'r');
    } else if (dir.contains('r')) {
      dir = dir.replaceFirst('r', 'l');
    }
    _boxMoveDir = dir;
  }

  void _handleCornerDown(String dir) {
    _boxMoveDir = dir;
    _boxMoveParam = _getMoveParamByDir(dir);
    if (widget.aspectRatio != null) {
      _getRangeForAspectChange();
    } else {
      _rangeX = (0, _containerData.width);
      _rangeY = (0, _containerData.height);
    }
  }

  /// 上游 handleCornerAspectMouseMove：定比角柄拖动。
  void _handleCornerAspectMove(Offset local) {
    final box = _cropperBox;
    final aspectRatio = widget.aspectRatio!;
    late double offsetX, offsetY;
    if (_boxMoveDir == 'ml' || _boxMoveDir == 'mr') {
      offsetX = _getMiddle(local.dx, _rangeX!);
    } else {
      offsetY = _getMiddle(local.dy, _rangeY!);
    }
    double width = box.width, height = box.height;
    var center = box.center;
    switch (_boxMoveDir) {
      case 'tl':
        height = _rangeY!.$2 - offsetY;
        width = height * aspectRatio;
        center = Offset(_rangeX!.$2 - width / 2, _rangeY!.$2 - height / 2);
        break;
      case 'tm':
        height = _rangeY!.$2 - offsetY;
        width = height * aspectRatio;
        center = Offset(box.center.dx, _rangeY!.$2 - height / 2);
        break;
      case 'tr':
        height = _rangeY!.$2 - offsetY;
        width = height * aspectRatio;
        center = Offset(_rangeX!.$1 + width / 2, _rangeY!.$2 - height / 2);
        break;
      case 'ml':
        width = _rangeX!.$2 - offsetX;
        height = width / aspectRatio;
        center = Offset(_rangeX!.$2 - width / 2, box.center.dy);
        break;
      case 'mr':
        width = offsetX - _rangeX!.$1;
        height = width / aspectRatio;
        center = Offset(_rangeX!.$1 + width / 2, box.center.dy);
        break;
      case 'bl':
        height = offsetY - _rangeY!.$1;
        width = height * aspectRatio;
        center = Offset(_rangeX!.$2 - width / 2, _rangeY!.$1 + height / 2);
        break;
      case 'bm':
        height = offsetY - _rangeY!.$1;
        width = height * aspectRatio;
        center = Offset(box.center.dx, _rangeY!.$1 + height / 2);
        break;
      case 'br':
        height = offsetY - _rangeY!.$1;
        width = height * aspectRatio;
        center = Offset(_rangeX!.$1 + width / 2, _rangeY!.$1 + height / 2);
        break;
    }
    if (height == 0 && width == 0) {
      _changeDir();
      _getRangeForAspectChange();
    }
    setState(() => _cropperBox = _CropRect(width, height, center));
  }

  /// 上游 handleCornerMouseMove：自由角柄拖动（过零点翻柄）。
  void _handleCornerMove(Offset local) {
    if (widget.aspectRatio != null) {
      _handleCornerAspectMove(local);
      return;
    }
    final offsetX = _getMiddle(local.dx, _rangeX!);
    final offsetY = _getMiddle(local.dy, _rangeY!);
    final box = _cropperBox;
    var width = box.width;
    var height = box.height;
    var center = box.center;
    var paramX = _boxMoveParam.x;
    var paramY = _boxMoveParam.y;
    if (paramX != 0) {
      final x = box.center.dx + paramX * box.width / 2;
      width = box.width + paramX * (offsetX - x);
      if (width < 0) {
        width = -width;
        paramX = -paramX;
        _boxMoveParam = (x: paramX, y: paramY);
      }
      center = Offset(offsetX - paramX * width / 2, center.dy);
    }
    if (paramY != 0) {
      final y = box.center.dy + paramY * box.height / 2;
      height = box.height + paramY * (offsetY - y);
      if (height < 0) {
        height = -height;
        paramY = -paramY;
        _boxMoveParam = (x: paramX, y: paramY);
      }
      center = Offset(center.dx, offsetY - paramY * height / 2);
    }
    setState(() => _cropperBox = _CropRect(width, height, center));
  }

  void _handleCornerUp() {
    _boxMoveParam = (x: 0, y: 0);
  }

  /// 上游 handleCropperBoxMouseDown：移动裁切框（角柄命中不响应）。
  void _handleBoxDown(Offset local) {
    _cropperBoxMoveStart = local;
    final box = _cropperBox;
    // 计算 cropperBox 中心点移动范围
    _moveRange = (
      xMin: box.width / 2,
      xMax: _containerData.width - box.width / 2,
      yMin: box.height / 2,
      yMax: _containerData.height - box.height / 2,
    );
  }

  /// 上游 handleCropperBoxMouseMove。
  void _handleBoxMove(Offset local) {
    final start = _cropperBoxMoveStart;
    if (start == null) return;
    final box = _cropperBox;
    final offsetX = local.dx - start.dx;
    final offsetY = local.dy - start.dy;
    final range = _moveRange!;
    final newCenterPointX = _getMiddle(box.center.dx + offsetX, (
      range.xMin,
      range.xMax,
    ));
    final newCenterPointY = _getMiddle(box.center.dy + offsetY, (
      range.yMin,
      range.yMax,
    ));
    _cropperBoxMoveStart = local;
    setState(() {
      _cropperBox = _CropRect(
        box.width,
        box.height,
        Offset(newCenterPointX, newCenterPointY),
      );
    });
  }

  void _handleBoxUp() {
    _cropperBoxMoveStart = null;
  }

  /// 上游 handleMaskMouseDown：平移图片。
  void _handleMaskDown(Offset local) {
    _imgMoveStart = local;
  }

  /// 上游 handleImgMove（图片可拖出视野，无钳制）。
  void _handleImgMoveUpdate(Offset local) {
    final start = _imgMoveStart;
    if (start == null) return;
    final imgData = _imgData;
    final offsetX = local.dx - start.dx;
    final offsetY = local.dy - start.dy;
    _imgMoveStart = local;
    setState(() {
      _imgData = _CropRect(
        imgData.width,
        imgData.height,
        imgData.center + Offset(offsetX, offsetY),
      );
    });
  }

  void _handleImgMoveUp() {
    _imgMoveStart = null;
  }

  /// 上游 getCropperCanvas：原图分辨率的旋转外接矩形内裁出裁切框区域。
  ///
  /// 越界补 fill：fillRect(0, 0, relativeWidth, relativeHeight)、
  /// getImageData(realLeft, realTop, realWidth, realHeight)、
  /// relativeCropLeft < 0 ? - relativeCropLeft : 0 修正贴图偏移。
  Future<ui.Image> _getCropperImage() async {
    final image = _image;
    if (image == null || !_loaded) {
      throw StateError('SemiCropper image is not loaded yet');
    }
    final fill = widget.fill;
    final cropperBox = _cropperBox;
    final imgData = _imgData;

    // 计算包含旋转后的图片的矩形容器的宽高
    final angle = _rotate * math.pi / 180;
    final sine = math.sin(angle).abs();
    final cosine = math.cos(angle).abs();
    final imgWidth = _originalWidth;
    final imgHeight = _originalHeight;
    final containerWidth = imgWidth * cosine + imgHeight * sine;
    final containerHeight = imgHeight * cosine + imgWidth * sine;

    // 判断裁切区域和外接矩形是否存在交集，如果不存在，则直接返回空白图片
    // 计算需要裁剪的区域实际大小和位置
    final cropperContainerWidth = containerWidth * _zoom * _scale;
    final cropperContainerHeight = containerHeight * _zoom * _scale;
    final cropperContainerTop = imgData.center.dy - cropperContainerHeight / 2;
    final cropperContainerLeft = imgData.center.dx - cropperContainerWidth / 2;
    final cropperBoxLeft = cropperBox.left;
    final cropperBoxTop = cropperBox.top;
    final realZoom = _zoom * _scale;

    final relativeCropLeft = (cropperBoxLeft - cropperContainerLeft) / realZoom;
    final relativeCropTop = (cropperBoxTop - cropperContainerTop) / realZoom;
    final relativeWidth = cropperBox.width / realZoom;
    final relativeHeight = cropperBox.height / realZoom;
    final relativeCropRight = relativeCropLeft + relativeWidth;
    final relativeCropBottom = relativeCropTop + relativeHeight;

    if (relativeCropRight < 0 ||
        relativeCropBottom < 0 ||
        relativeCropLeft > containerWidth ||
        relativeCropTop > containerHeight) {
      // 没有交集，直接返回空白图片
      return _record(relativeWidth, relativeHeight, (canvas, width, height) {
        canvas.drawRect(
          Rect.fromLTWH(0, 0, width, height),
          Paint()..color = fill,
        );
      });
    }

    final full = await _record(containerWidth, containerHeight, (
      canvas,
      width,
      height,
    ) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, width, height),
        Paint()..color = fill,
      );
      final halfWidth = width / 2;
      final halfHeight = height / 2;
      canvas.translate(halfWidth, halfHeight);
      canvas.rotate(_rotate * math.pi / 180);
      canvas.translate(-halfWidth, -halfHeight);
      final imgX = (width - imgWidth) / 2;
      final imgY = (height - imgHeight) / 2;
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, imgWidth, imgHeight),
        Rect.fromLTWH(imgX, imgY, imgWidth, imgHeight),
        Paint()..filterQuality = FilterQuality.none,
      );
    });

    // 为了避免裁剪时候，超出被裁切的画布的部分颜色不正常，需要将裁切区域限制在画布范围内。
    // 相对位置会在后续进行修正
    var realLeft = relativeCropLeft;
    var realTop = relativeCropTop;
    var realWidth = relativeWidth;
    var realHeight = relativeHeight;

    if (relativeCropLeft < 0) {
      realLeft = 0;
    }
    if (relativeCropTop < 0) {
      realTop = 0;
    }
    if (relativeCropRight > containerWidth) {
      realWidth = containerWidth - realLeft;
    } else if (relativeCropLeft < 0) {
      realWidth = relativeCropRight;
    }

    if (relativeCropBottom > containerHeight) {
      realHeight = containerHeight - realTop;
    } else if (relativeCropTop < 0) {
      realHeight = relativeCropBottom;
    }

    final result = await _record(relativeWidth, relativeHeight, (
      canvas,
      width,
      height,
    ) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, width, height),
        Paint()..color = fill,
      );
      // putImageData 的整像素替换语义（BlendMode.src 贴图）。
      canvas.drawImageRect(
        full,
        Rect.fromLTWH(realLeft, realTop, realWidth, realHeight),
        Rect.fromLTWH(
          relativeCropLeft < 0 ? -relativeCropLeft : 0,
          relativeCropTop < 0 ? -relativeCropTop : 0,
          realWidth,
          realHeight,
        ),
        Paint()
          ..blendMode = BlendMode.src
          ..filterQuality = FilterQuality.none,
      );
    });
    full.dispose();
    return result;
  }

  Future<ui.Image> _record(
    double width,
    double height,
    void Function(Canvas canvas, double width, double height) draw,
  ) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    draw(canvas, width, height);
    return recorder.endRecording().toImage(
      math.max(1, width.round()),
      math.max(1, height.round()),
    );
  }

  /// 上游 updatePreview：预览容器内按裁切框适配缩放。
  Widget _buildCropView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : 0.0;
        final containerHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : 0.0;
        final cropperBox = _cropperBox;
        if (!_loaded || cropperBox.width <= 0 || cropperBox.height <= 0) {
          return const SizedBox.shrink();
        }
        var zoom = 1.0;
        var previewWidth = containerWidth;
        var previewHeight = containerHeight;
        if (previewWidth < previewHeight) {
          zoom = containerWidth / cropperBox.width;
          final tempHeight = zoom * cropperBox.height;
          if (tempHeight > containerHeight) {
            zoom = containerHeight / cropperBox.height;
            previewWidth = zoom * cropperBox.width;
          } else {
            previewHeight = tempHeight;
          }
        } else {
          zoom = containerHeight / cropperBox.height;
          final tempWidth = zoom * cropperBox.width;
          if (tempWidth > containerWidth) {
            zoom = containerWidth / cropperBox.width;
            previewHeight = zoom * cropperBox.height;
          } else {
            previewWidth = tempWidth;
          }
        }
        final imgX = _imgData.left - cropperBox.left;
        final imgY = _imgData.top - cropperBox.top;
        return SizedBox(
          key: SemiCropper.cropViewKey,
          width: previewWidth,
          height: previewHeight,
          child: ClipRect(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: imgX * zoom,
                  top: imgY * zoom,
                  width: _imgData.width * zoom,
                  height: _imgData.height * zoom,
                  child: Transform.rotate(
                    // transformOrigin: 'center'
                    angle: _rotate * math.pi / 180,
                    child: RawImage(
                      image: _image,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.low,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 受控 zoom/rotate 同步（getDerivedStateFromProps 等价位置）。
    _syncControlledProps();
    final t = SemiCropperTheme.resolve(context);
    final content = Semantics(
      container: true,
      label: '图片裁切',
      child: MouseRegion(
        // 角柄拖动期间整个容器保持该方向的 resize 光标（指针可能离开
        // 10px 角柄或越出组件再拖回）；其余时候 macOS 隐藏系统光标，
        // 由根 Stack 自绘 move/对角字形（出界停绘，回退宿主箭头）。
        cursor: _dragMode == _DragMode.cornerResize && _boxMoveDir.isNotEmpty
            ? _cornerCursor(_boxMoveDir)
            : _moveCursor(),
        // 自绘光标位置用容器坐标（容器不随指针拖动移动，跟手不漂移）。
        onHover: (e) => _drawnAt.value = e.localPosition,
        onExit: (_) {
          if (_dragMode == _DragMode.none) _drawnAt.value = null;
        },
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (e) {
            // down 自叶向根派发：子级先定模式，这里统一以容器坐标记起点。
            switch (_dragMode) {
              case _DragMode.imgMove:
                _handleMaskDown(e.localPosition);
              case _DragMode.boxMove:
                _handleBoxDown(e.localPosition);
              case _DragMode.cornerResize:
              case _DragMode.none:
                break;
            }
          },
          onPointerMove: (e) {
            if (!e.down) return;
            // 拖动中 hover 停发，自绘光标改由 pointer move 续跟（平移/缩放）。
            _drawnAt.value = e.localPosition;
            switch (_dragMode) {
              case _DragMode.imgMove:
                _handleImgMoveUpdate(e.localPosition);
              case _DragMode.boxMove:
                _handleBoxMove(e.localPosition);
              case _DragMode.cornerResize:
                _handleCornerMove(e.localPosition);
              case _DragMode.none:
                break;
            }
          },
          onPointerUp: (_) => _endDrag(),
          onPointerCancel: (_) => _endDrag(),
          onPointerSignal: (e) {
            if (e is PointerScrollEvent) _handleWheel(e);
          },
          // 几何全部在 builder 内组装（resize 数学当帧生效）。
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (!constraints.hasBoundedWidth ||
                  !constraints.hasBoundedHeight) {
                // 上游容器 style 显式宽高；Flutter 需父级给有界约束。
                return const SizedBox.shrink();
              }
              _handleLayout(constraints.biggest);
              // 受控 zoom/rotate 在布局派生之后再同步一次（加载首帧）。
              _syncControlledProps();
              final imgX = _imgData.left;
              final imgY = _imgData.top;
              final boxX = _cropperBox.left;
              final boxY = _cropperBox.top;
              final cropperImgX = imgX - boxX;
              final cropperImgY = imgY - boxY;

              final imageLayer = Positioned(
                left: imgX,
                top: imgY,
                width: _imgData.width,
                height: _imgData.height,
                child: Transform.rotate(
                  // transformOrigin: 'center'
                  angle: _rotate * math.pi / 180,
                  child: RawImage(
                    key: SemiCropper.imageKey,
                    image: _image,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.low,
                  ),
                ),
              );

              // 遮罩层（cursor: move;; 双分号 quirk）：拖动平移图片。
              final mask = Positioned.fill(
                child: Listener(
                  key: SemiCropper.maskKey,
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (e) {
                    if (_dragMode != _DragMode.none) return;
                    _dragMode = _DragMode.imgMove;
                  },
                  child: ColoredBox(color: t.colorCropperMaskBg),
                ),
              );

              // `-view-box-round` border-radius: 50%（round/roundRect）。
              final viewClip = widget.shape == SemiCropperShape.rect
                  ? ClipRect(child: _viewBox(cropperImgX, cropperImgY))
                  : ClipOval(child: _viewBox(cropperImgX, cropperImgY));

              // `$half_corner_width`：角柄外悬半格——盒层扩一圈让角柄可命中
              //（RenderBox.hitTest 不收自身边界外的子级）。
              final pad = t.widthCropperBoxCorner / 2;
              // 角柄未渲染时清空命中区（toggle showResizeBox 后无残留）。
              _cornerHitRects.clear();

              // 裁切框（outline 外描边语义：画在盒外）。
              final box = Positioned(
                left: boxX - pad,
                top: boxY - pad,
                width: _cropperBox.width + pad * 2,
                height: _cropperBox.height + pad * 2,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: pad,
                      top: pad,
                      width: _cropperBox.width,
                      height: _cropperBox.height,
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _CropperBoxOutlinePainter(
                            color: t.colorCropperBoxOutline,
                            strokeWidth: t.widthCropperBoxOutline,
                            oval: widget.shape == SemiCropperShape.round,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: pad,
                      top: pad,
                      width: _cropperBox.width,
                      height: _cropperBox.height,
                      child: Listener(
                        key: SemiCropper.boxKey,
                        behavior: HitTestBehavior.opaque,
                        onPointerDown: (e) {
                          // 角柄命中（target.dataset.dir）不移动裁切框。
                          if (_dragMode != _DragMode.none) return;
                          _dragMode = _DragMode.boxMove;
                        },
                        child: viewClip,
                      ),
                    ),
                    if (_loaded && widget.showResizeBox)
                      ..._buildCorners(t, pad),
                  ],
                ),
              );

              return Stack(
                clipBehavior: Clip.none,
                fit: StackFit.expand,
                children: [
                  // 图片层（img-wrapper overflow: hidden）。
                  Positioned.fill(
                    child: ClipRect(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [imageLayer],
                      ),
                    ),
                  ),
                  mask,
                  box,
                  // macOS 自绘光标（move 四向箭头 / 对角 resize；容器坐标，
                  // 不随指针拖动漂移，出界停绘）。
                  if (_usesDrawnCursor)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ValueListenableBuilder<Offset?>(
                          valueListenable: _drawnAt,
                          builder: (context, at, _) {
                            final glyph = _drawnGlyph(at);
                            if (glyph == null) return const SizedBox.shrink();
                            return CustomPaint(
                              key: glyph.key,
                              painter: glyph.painter,
                            );
                          },
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
    final previewBuilder = widget.previewBuilder;
    if (previewBuilder == null) return content;
    return previewBuilder(context, content, _buildCropView());
  }

  /// 视口内同一张图按裁切框相对位移（`-view-box` + `-view-img`）。
  Widget _viewBox(double cropperImgX, double cropperImgY) {
    return SizedBox(
      width: _cropperBox.width,
      height: _cropperBox.height,
      child: Stack(
        key: SemiCropper.viewBoxKey,
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            left: cropperImgX,
            top: cropperImgY,
            width: _imgData.width,
            height: _imgData.height,
            child: Transform.rotate(
              angle: _rotate * math.pi / 180,
              child: RawImage(
                image: _image,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.low,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _endDrag() {
    final wasCorner = _dragMode == _DragMode.cornerResize;
    switch (_dragMode) {
      case _DragMode.imgMove:
        _handleImgMoveUp();
      case _DragMode.boxMove:
        _handleBoxUp();
      case _DragMode.cornerResize:
        _handleCornerUp();
      case _DragMode.none:
        break;
    }
    _dragMode = _DragMode.none;
    _pruneDrawnAt();
    // 根光标在角柄拖动期间是 resize/none，结束后恢复 move/grab。
    if (wasCorner) setState(() {});
  }

  List<Widget> _buildCorners(SemiResolvedCropperThemeData t, double pad) {
    // `$half_corner_width: calc($width-cropper_box_corner / 2)` 半宽外偏。
    final size = t.widthCropperBoxCorner;
    final half = size / 2;
    final box = _cropperBox;
    final dirs = widget.shape == SemiCropperShape.round
        ? const ['tm', 'ml', 'mr', 'bm']
        : const ['tl', 'tm', 'tr', 'ml', 'mr', 'bl', 'bm', 'br'];
    // 柄位在容器坐标系钳回 `[0, 容器 - 柄]`：贴边裁切框（初始态）的
    // `-$half_corner_width` 外悬半格落在容器外成死区（根 Stack 命中不出
    // 自身边界，拖不动且光标不切换；上游 DOM 命中不受父盒边界限制），
    // 整只内移后全格可拖可悬停（差异清单「角柄钳回容器」）。
    double handleLeft(String dir) => switch (dir) {
      'tl' || 'ml' || 'bl' => box.left - half,
      'tm' || 'bm' => box.center.dx - half,
      _ => box.left + box.width - half,
    };
    double handleTop(String dir) => switch (dir) {
      'tl' || 'tm' || 'tr' => box.top - half,
      'ml' || 'mr' => box.center.dy - half,
      _ => box.top + box.height - half,
    };
    double clampToContainer(double value, double extent) =>
        _getMiddle(value, (0, math.max(0, extent - size)));
    _cornerHitRects.clear();
    final corners = <Widget>[];
    for (final dir in dirs) {
      final left =
          clampToContainer(handleLeft(dir), _containerData.width) -
          box.left +
          pad;
      final top =
          clampToContainer(handleTop(dir), _containerData.height) -
          box.top +
          pad;
      // 命中区换算回容器坐标（盒层原点 = box.topLeft - pad）。
      _cornerHitRects[dir] = Rect.fromLTWH(
        left + box.left - pad,
        top + box.top - pad,
        size,
        size,
      );
      corners.add(
        Positioned(
          left: left,
          top: top,
          width: size,
          height: size,
          child: _CornerHandle(
            dir: dir,
            cursor: _cornerCursor(dir),
            onPointerDown: () {
              _dragMode = _DragMode.cornerResize;
              _handleCornerDown(dir);
              // 根光标切到该方向的 resize（拖动中指针可能离开角柄）。
              setState(() {});
            },
            child: ColoredBox(color: t.colorCropperBoxCornerBg),
          ),
        ),
      );
    }
    return corners;
  }
}

/// 角柄（光标由 `_cornerCursor` 决定；macOS 对角四角为 none + 根 Stack 自绘）。
class _CornerHandle extends StatelessWidget {
  const _CornerHandle({
    required this.dir,
    required this.cursor,
    required this.onPointerDown,
    required this.child,
  });

  final String dir;
  final MouseCursor cursor;
  final VoidCallback onPointerDown;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: cursor,
      child: Listener(
        key: SemiCropper.cornerKey(dir),
        behavior: HitTestBehavior.opaque,
        onPointerDown: (e) => onPointerDown(),
        child: child,
      ),
    );
  }
}

/// 对角 resize 光标字形（nwse / nesw 双向箭头，白描边黑填充，热点在中心）。
class _DiagonalResizeCursorPainter extends CustomPainter {
  const _DiagonalResizeCursorPainter({
    required this.hotspot,
    required this.nwse,
  });

  /// 热点（角柄局部坐标；绘制可越界，父 Stack 不裁剪）。
  final Offset hotspot;

  /// true = ↖↘（tl/br），false = ↗↙（tr/bl）。
  final bool nwse;

  static final Path _glyph = _buildGlyph();

  static Path _buildGlyph() {
    const double l = 7, aw = 2.8, hl = 2.8, sh = 0.9;
    return Path()
      ..moveTo(l, 0)
      ..lineTo(l - hl, -aw)
      ..lineTo(l - hl, -sh)
      ..lineTo(-(l - hl), -sh)
      ..lineTo(-(l - hl), -aw)
      ..lineTo(-l, 0)
      ..lineTo(-(l - hl), aw)
      ..lineTo(-(l - hl), sh)
      ..lineTo(l - hl, sh)
      ..lineTo(l - hl, aw)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(hotspot.dx, hotspot.dy);
    canvas.rotate(nwse ? math.pi / 4 : -math.pi / 4);
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFFFFFFFF);
    final fill = Paint()..color = const Color(0xFF000000);
    canvas.drawPath(_glyph, outline);
    canvas.drawPath(_glyph, fill);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DiagonalResizeCursorPainter oldDelegate) =>
      oldDelegate.hotspot != hotspot || oldDelegate.nwse != nwse;
}

/// 平移光标字形（四向箭头，白描边黑填充，热点在中心）。
class _MoveCursorPainter extends CustomPainter {
  const _MoveCursorPainter(this.hotspot);

  /// 热点（容器坐标）。
  final Offset hotspot;

  static final Path _glyph = _buildGlyph();

  static Path _buildGlyph() {
    // 单臂：长 7、箭头宽 2.8、头长 2.8、杆半宽 0.9。
    const double l = 7, aw = 2.8, hl = 2.8, sh = 0.9;
    final arm = Path()
      ..moveTo(0, -l)
      ..lineTo(-aw, -l + hl)
      ..lineTo(-sh, -l + hl)
      ..lineTo(-sh, 0)
      ..lineTo(sh, 0)
      ..lineTo(sh, -l + hl)
      ..lineTo(aw, -l + hl)
      ..close();
    final glyph = Path();
    for (var i = 0; i < 4; i++) {
      glyph.addPath(
        arm.transform(Matrix4.rotationZ(i * math.pi / 2).storage),
        Offset.zero,
      );
    }
    return glyph;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(hotspot.dx, hotspot.dy);
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFFFFFFFF);
    final fill = Paint()..color = const Color(0xFF000000);
    canvas.drawPath(_glyph, outline);
    canvas.drawPath(_glyph, fill);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MoveCursorPainter oldDelegate) =>
      oldDelegate.hotspot != hotspot;
}

/// 裁切框 outline 外描边（CSS `outline: w solid` 画在盒外）。
class _CropperBoxOutlinePainter extends CustomPainter {
  const _CropperBoxOutlinePainter({
    required this.color,
    required this.strokeWidth,
    required this.oval,
  });

  final Color color;
  final double strokeWidth;
  final bool oval;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color;
    final rect = Offset.zero & size;
    final outline = strokeWidth > 0 ? rect.deflate(strokeWidth / 2) : rect;
    if (oval) {
      canvas.drawOval(outline, paint);
    } else {
      canvas.drawRect(outline, paint);
    }
  }

  @override
  bool shouldRepaint(_CropperBoxOutlinePainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      oval != oldDelegate.oval;
}
