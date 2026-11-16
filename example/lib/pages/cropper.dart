import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class CropperPage extends StatefulWidget {
  const CropperPage({super.key, this.image});

  /// 演示图片（默认 example 资源；测试可注入）。
  final ImageProvider? image;

  @override
  State<CropperPage> createState() => _CropperPageState();
}

class _CropperPageState extends State<CropperPage> {
  final SemiCropperController _controller = SemiCropperController();
  final List<String> _events = [];
  String _status = '拖动遮罩 / 裁切框 / 角柄，滚轮缩放，事件写入此行。';
  SemiCropperShape _shape = SemiCropperShape.rect;
  double _rotate = 0;
  double _zoom = 1;
  ui.Image? _cropped;

  ImageProvider get _image =>
      widget.image ?? const AssetImage('assets/images/cropper_demo.png');

  void _push(String event) {
    _events.add(event);
    if (_events.length > 6) _events.removeRange(0, _events.length - 6);
    setState(() => _status = _events.join('；'));
  }

  Future<void> _crop() async {
    final image = await _controller.getCropperImage();
    setState(() => _cropped = image);
    _push('裁切输出 ${image.width}x${image.height}');
  }

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  Widget _demo(String label, Widget child, {double height = 300}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiText(label),
      const SizedBox(height: 6),
      SizedBox(width: 766, height: height, child: child),
      const SizedBox(height: 16),
    ],
  );

  Widget _shapeButton(SemiCropperShape shape, String label) => SemiButton(
    label,
    key: ValueKey('cropper-shape-$label'),
    type: _shape == shape ? SemiButtonType.primary : SemiButtonType.tertiary,
    onPressed: () {
      setState(() => _shape = shape);
      _push('shape $label');
    },
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SemiText(_status, key: const ValueKey('cropper-status')),
          const SizedBox(height: 24),
          _section('基本用法', [
            Wrap(
              spacing: 8,
              children: [
                _shapeButton(SemiCropperShape.rect, 'rect'),
                _shapeButton(SemiCropperShape.round, 'round'),
                _shapeButton(SemiCropperShape.roundRect, 'roundRect'),
              ],
            ),
            const SizedBox(height: 8),
            _demo(
              'src 离线示例图，shape 切换裁切框形状（round 仅四边中点柄）',
              SizedBox(
                width: 550,
                height: 300,
                child: SemiCropper(
                  key: const ValueKey('cropper-basic'),
                  image: _image,
                  shape: _shape,
                  controller: _controller,
                ),
              ),
            ),
            SemiButton(
              '裁切',
              key: const ValueKey('cropper-crop'),
              onPressed: _crop,
            ),
            if (_cropped != null) ...[
              const SizedBox(height: 8),
              RawImage(
                key: const ValueKey('cropper-crop-result'),
                image: _cropped,
                height: 160,
              ),
            ],
            const SizedBox(height: 16),
          ]),
          _section('自定义裁切框比例', [
            _demo(
              'defaultAspectRatio: 1.6 — 仅初始比例，拖动后随拖动变化',
              SizedBox(
                width: 550,
                height: 300,
                child: SemiCropper(
                  key: const ValueKey('cropper-ratio-default'),
                  image: _image,
                  defaultAspectRatio: 1.6,
                ),
              ),
            ),
            _demo(
              'aspectRatio: 4/3 — 定比，角柄拖动保持比例',
              SizedBox(
                width: 550,
                height: 300,
                child: SemiCropper(
                  key: const ValueKey('cropper-ratio-fixed'),
                  image: _image,
                  aspectRatio: 4 / 3,
                ),
              ),
            ),
          ]),
          _section('受控旋转/缩放 + 实时预览', [
            _demo(
              'rotate / zoom 受控（getDerivedStateFromProps 语义），右侧实时预览',
              SemiCropper(
                key: const ValueKey('cropper-controlled'),
                image: _image,
                rotate: _rotate,
                zoom: _zoom,
                onZoomChange: (z) => setState(() => _zoom = z),
                previewBuilder: (context, cropper, cropView) => Row(
                  children: [
                    SizedBox(width: 550, height: 300, child: cropper),
                    const SizedBox(width: 16),
                    SizedBox(width: 200, height: 200, child: cropView),
                  ],
                ),
              ),
              height: 300,
            ),
            SemiText('旋转 ${_rotate.toStringAsFixed(0)}°'),
            SizedBox(
              width: 500,
              child: SemiSlider(
                key: const ValueKey('cropper-rotate'),
                value: _rotate,
                min: -180,
                max: 180,
                step: 1,
                onChanged: (v) => setState(() {
                  _rotate = (v as num).toDouble();
                  _status = '旋转 ${_rotate.toStringAsFixed(0)}°';
                }),
              ),
            ),
            SemiText('缩放 ${_zoom.toStringAsFixed(1)}'),
            SizedBox(
              width: 500,
              child: SemiSlider(
                key: const ValueKey('cropper-zoom'),
                value: _zoom,
                min: 0.1,
                max: 3,
                step: 0.1,
                onChanged: (v) => setState(() {
                  _zoom = (v as num).toDouble();
                  _status = '缩放 ${_zoom.toStringAsFixed(1)}';
                }),
              ),
            ),
            const SizedBox(height: 16),
          ]),
          _section('裁切框设置', [
            _demo(
              'showResizeBox: false + SemiCropperTheme 覆盖描边色/角柄尺寸',
              SizedBox(
                width: 550,
                height: 300,
                child: SemiCropperTheme(
                  data: const SemiCropperThemeData(
                    colorCropperBoxOutline: Color(0xFF1A1A1A),
                    widthCropperBoxCorner: 14,
                  ),
                  child: SemiCropper(
                    key: const ValueKey('cropper-box-style'),
                    image: _image,
                    showResizeBox: false,
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
