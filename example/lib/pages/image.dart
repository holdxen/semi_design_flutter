import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

/// Image gallery：上游 Semi Image 演示的 Flutter 对照页。
///
/// 图片源默认 assets/images/avatar.png；测试可注入同步 ImageProvider
/// （fake async 内无 codec，见 image_page_test.dart）。
class ImagePage extends StatefulWidget {
  const ImagePage({super.key, this.image, this.images});

  /// 单图源（占位/失败/预览演示复用）。
  final ImageProvider? image;

  /// 图库源（缺省 3 项，同图不同 id）。
  final List<ImageProvider>? images;

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  int _downloads = 0;

  ImageProvider get _image =>
      widget.image ?? const AssetImage('assets/images/avatar.png');

  List<ImageProvider> get _images => widget.images ?? [_image, _image, _image];

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  Widget _demo(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiText(label),
      const SizedBox(height: 6),
      child,
      const SizedBox(height: 12),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('基础用法', [
            _demo(
              '默认加载占位（Skeleton.Image）与自定义 placeholder',
              Wrap(
                key: const ValueKey('image-basic'),
                spacing: 24,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 90,
                    child: SemiImage(image: _image),
                  ),
                  SizedBox(
                    width: 120,
                    height: 90,
                    child: SemiImage(
                      image: const AssetImage('assets/images/missing.png'),
                      placeholder: const Center(child: SemiSpin()),
                    ),
                  ),
                ],
              ),
            ),
            _demo(
              '加载失败（opacity: 0）与 fallback 回退',
              Wrap(
                key: const ValueKey('image-fallback'),
                spacing: 24,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 90,
                    child: SemiImage(
                      image: const AssetImage('assets/images/missing.png'),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    height: 90,
                    child: SemiImage(
                      image: const AssetImage('assets/images/missing.png'),
                      fallback: const Center(child: SemiText('加载失败')),
                    ),
                  ),
                ],
              ),
            ),
          ]),
          _section('预览', [
            _demo(
              '点击开预览（缩放/旋转/下载；操作栏 10s 自动隐藏）',
              Wrap(
                key: const ValueKey('image-preview'),
                spacing: 24,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 160,
                    height: 120,
                    child: SemiImage(
                      image: _image,
                      previewProps: SemiImagePreviewProps(
                        src: [_image],
                        showTooltip: true,
                        infinite: true,
                        onDownload: (src, index) =>
                            setState(() => _downloads++),
                      ),
                    ),
                  ),
                  SemiText(_downloads == 0 ? '未下载' : '已下载 $_downloads 次'),
                ],
              ),
            ),
          ]),
          _section('图库分组', [
            _demo(
              'SemiImagePreview 组（点第 N 张开第 N 张，titles[currentIndex] 覆盖）',
              Wrap(
                key: const ValueKey('image-gallery'),
                spacing: 24,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 620,
                    height: 140,
                    child: SemiImagePreview(
                      props: SemiImagePreviewProps(
                        showTooltip: true,
                        infinite: true,
                        previewTitle: const SemiText('图库'),
                      ),
                      children: [
                        for (var i = 0; i < _images.length; i++)
                          SizedBox(
                            width: 120,
                            height: 90,
                            child: SemiImage(
                              image: _images[i],
                              previewProps: SemiImagePreviewProps(
                                previewTitle: SemiText('图${i + 1}'),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]),
          _section('缩放档位', [
            _demo(
              'zoomStep/minZoom/maxZoom/initialZoom 自定义',
              Wrap(
                key: const ValueKey('image-zoom'),
                spacing: 24,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 160,
                    height: 120,
                    child: SemiImage(
                      image: _image,
                      previewProps: const SemiImagePreviewProps(
                        zoomStep: 0.2,
                        minZoom: 0.5,
                        maxZoom: 3,
                        initialZoom: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
