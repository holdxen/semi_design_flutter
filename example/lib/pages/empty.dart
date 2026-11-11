import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});

  Widget _illustration(
    SemiIllustrationDescriptor light,
    SemiIllustrationDescriptor dark,
  ) => SemiIllustration(light, dark: dark, size: 120);

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  @override
  Widget build(BuildContext context) {
    final dark = const SemiThemeData.dark();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('基础用法', [
            const SemiEmpty(
              key: ValueKey('basic-empty'),
              image: SemiIllustration(
                SemiIllustrations.noContent,
                dark: SemiIllustrations.noContentDark,
              ),
              title: '暂无内容',
              description: '换个关键词试试',
            ),
          ]),
          const SizedBox(height: 40),
          _section('布局方向', [
            const SemiEmpty(
              key: ValueKey('horizontal-empty'),
              layout: SemiEmptyLayout.horizontal,
              image: SemiIllustration(
                SemiIllustrations.noResult,
                dark: SemiIllustrations.noResultDark,
                size: 120,
              ),
              title: '没有找到结果',
              description: '请调整筛选条件后重试',
            ),
          ]),
          const SizedBox(height: 40),
          _section('标题排版', [
            const SemiText(
              '有插图时标题为 h4/600；无插图时为 h6/400。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            const SemiEmpty(
              key: ValueKey('title-with-image'),
              image: SemiIllustration(
                SemiIllustrations.idle,
                dark: SemiIllustrations.idleDark,
                size: 120,
              ),
              title: '有插图的标题',
              description: '标题字号更大、字重更粗',
            ),
            const SizedBox(height: 24),
            const SemiEmpty(
              key: ValueKey('title-without-image'),
              title: '无插图的标题',
              description: '标题更小、字重 400',
            ),
          ]),
          const SizedBox(height: 40),
          _section('插图风格', [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final item in [
                  (
                    '无内容',
                    SemiIllustrations.noContent,
                    SemiIllustrations.noContentDark,
                  ),
                  (
                    '无结果',
                    SemiIllustrations.noResult,
                    SemiIllustrations.noResultDark,
                  ),
                  (
                    '未找到',
                    SemiIllustrations.notFound,
                    SemiIllustrations.notFoundDark,
                  ),
                  (
                    '加载失败',
                    SemiIllustrations.failure,
                    SemiIllustrations.failureDark,
                  ),
                  (
                    '无权限',
                    SemiIllustrations.noAccess,
                    SemiIllustrations.noAccessDark,
                  ),
                  (
                    '建设中',
                    SemiIllustrations.construction,
                    SemiIllustrations.constructionDark,
                  ),
                  ('空闲', SemiIllustrations.idle, SemiIllustrations.idleDark),
                  (
                    '成功',
                    SemiIllustrations.success,
                    SemiIllustrations.successDark,
                  ),
                ])
                  SizedBox(
                    width: 120,
                    child: Column(
                      children: [
                        _illustration(item.$2, item.$3),
                        SemiText(item.$1),
                      ],
                    ),
                  ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('暗色主题', [
            const SemiText(
              '外层主题切换为暗色时自动使用 darkModeImage。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            ColoredBox(
              color: dark.colors.colorBg0,
              child: SizedBox(
                width: double.infinity,
                child: SemiTheme(
                  data: dark,
                  child: const SemiEmpty(
                    key: ValueKey('dark-empty'),
                    image: SemiIllustration(
                      SemiIllustrations.notFound,
                      dark: SemiIllustrations.notFoundDark,
                      size: 120,
                    ),
                    title: '暗色占位',
                    description: '插图与文字颜色随主题变化',
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('自定义内容与局部主题', [
            const SemiEmpty(
              key: ValueKey('footer-empty'),
              image: SemiIllustration(
                SemiIllustrations.failure,
                dark: SemiIllustrations.failureDark,
                size: 120,
              ),
              title: '出错了',
              description: '请检查网络后重试',
              footer: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SemiText(
                    '重新加载',
                    key: ValueKey('reload-link'),
                    link: SemiTextLink(onTap: _noop),
                  ),
                  SizedBox(width: 16),
                  SemiText('查看详情', link: SemiTextLink(onTap: _noop)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SemiEmptyTheme(
              data: SemiEmptyThemeData(
                spacingEmptyContentVerticalMarginTop: 8,
                spacingEmptyTitleMarginTop: 4,
                spacingEmptyFooterMarginTop: 8,
                fontEmptyTitleFontWeight: FontWeight.w400,
                colorEmptyDescriptionTextDefault: Color(0xff7b61ff),
              ),
              child: SemiEmpty(
                key: ValueKey('theme-empty'),
                image: SemiIllustration(
                  SemiIllustrations.success,
                  dark: SemiIllustrations.successDark,
                  size: 120,
                ),
                title: '紧凑间距主题',
                description: '描述文字使用自定义紫色',
              ),
            ),
          ]),
        ],
      ),
    );
  }

  static void _noop() {}
}
