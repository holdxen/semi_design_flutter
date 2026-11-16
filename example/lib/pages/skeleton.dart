import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class SkeletonPage extends StatefulWidget {
  const SkeletonPage({super.key});

  @override
  State<SkeletonPage> createState() => _SkeletonPageState();
}

class _SkeletonPageState extends State<SkeletonPage> {
  bool _loading = true;
  bool _active = true;

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

  Widget _card({required Widget placeholder, required String content}) =>
      SizedBox(
        width: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SemiSkeleton(
              loading: _loading,
              active: _active,
              placeholder: placeholder,
              child: Column(
                key: const ValueKey('skeleton-content'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SemiText(content, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  const SemiText('这是加载完成后的真实内容，用于对比骨架屏占位。'),
                ],
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SemiButton(
                _loading ? '切换为真实内容' : '切换为骨架屏',
                key: const ValueKey('skeleton-toggle'),
                onPressed: () => setState(() => _loading = !_loading),
              ),
              const SizedBox(width: 12),
              SemiButton(
                _active ? '关闭扫光' : '开启扫光',
                key: const ValueKey('skeleton-active-toggle'),
                onPressed: () => setState(() => _active = !_active),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _section('基础骨架屏', [
            _demo(
              '头像 + 标题 + 段落（active 扫光；按钮切换 loading/active）',
              _card(
                placeholder: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SemiSkeletonAvatar(),
                        SizedBox(width: 12),
                        Expanded(child: SemiSkeletonTitle()),
                      ],
                    ),
                    SizedBox(height: 16),
                    SemiSkeletonParagraph(),
                  ],
                ),
                content: '真实内容标题',
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _section('段落行数', [
            _demo(
              'rows: 1（单行 100%）',
              const SizedBox(
                width: 420,
                child: SemiSkeleton(
                  placeholder: SemiSkeletonParagraph(rows: 1),
                ),
              ),
            ),
            _demo(
              'rows: 2（末行 60%）',
              const SizedBox(
                width: 420,
                child: SemiSkeleton(
                  active: true,
                  placeholder: SemiSkeletonParagraph(rows: 2),
                ),
              ),
            ),
            _demo(
              'rows: 4（缺省）',
              const SizedBox(
                width: 420,
                child: SemiSkeleton(
                  active: true,
                  placeholder: SemiSkeletonParagraph(),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _section('头像尺寸与形状', [
            _demo(
              'extraExtraSmall / extraSmall / small / medium / large / '
              'extraLarge + square',
              Wrap(
                key: const ValueKey('skeleton-avatars'),
                spacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: const [
                  SemiSkeletonAvatar(
                    size: SemiSkeletonAvatarSize.extraExtraSmall,
                  ),
                  SemiSkeletonAvatar(size: SemiSkeletonAvatarSize.extraSmall),
                  SemiSkeletonAvatar(size: SemiSkeletonAvatarSize.small),
                  SemiSkeletonAvatar(size: SemiSkeletonAvatarSize.medium),
                  SemiSkeletonAvatar(size: SemiSkeletonAvatarSize.large),
                  SemiSkeletonAvatar(size: SemiSkeletonAvatarSize.extraLarge),
                  SemiSkeletonAvatar(
                    size: SemiSkeletonAvatarSize.large,
                    shape: SemiSkeletonAvatarShape.square,
                  ),
                ],
              ),
            ),
            _demo(
              '按钮占位 115 × 32',
              const Row(
                children: [
                  SemiSkeletonButton(),
                  SizedBox(width: 12),
                  SemiSkeletonButton(),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _section('图片占位', [
            _demo(
              'image：铺满 200 × 120 的父级',
              const SizedBox(
                width: 200,
                height: 120,
                child: SemiSkeleton(
                  active: true,
                  placeholder: SemiSkeletonImage(),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _section('RTL', [
            Directionality(
              textDirection: TextDirection.rtl,
              child: _demo(
                '段落 + 头像（末行靠右）',
                const SizedBox(
                  width: 420,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SemiSkeletonAvatar(
                            size: SemiSkeletonAvatarSize.large,
                          ),
                          SizedBox(width: 12),
                          Expanded(child: SemiSkeletonTitle()),
                        ],
                      ),
                      SizedBox(height: 16),
                      SemiSkeletonParagraph(rows: 3),
                    ],
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
