import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class DescriptionsPage extends StatelessWidget {
  const DescriptionsPage({super.key});

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
    const items = [
      SemiDescriptionsItemData(label: '实际用户数量', value: '1,480,000'),
      SemiDescriptionsItemData(label: '7 天留存', value: '98%'),
      SemiDescriptionsItemData(label: '安全等级', value: '3 级'),
      SemiDescriptionsItemData(label: '垂类标签', value: '电商'),
      SemiDescriptionsItemData(label: '认证状态', value: '未认证'),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('基础用法', [
            const SemiDescriptions(
              key: ValueKey('basic-descriptions'),
              semanticsLabel: '用户资料',
              items: items,
            ),
          ]),
          const SizedBox(height: 40),
          _section('对齐方式', [
            for (final align in SemiDescriptionsAlign.values) ...[
              SemiText(align.name, type: SemiTextType.secondary),
              SemiDescriptions(
                key: ValueKey('align-${align.name}'),
                align: align,
                items: const [
                  SemiDescriptionsItemData(label: '名称', value: 'Semi Design'),
                  SemiDescriptionsItemData(label: '版本', value: '2.104.0'),
                  SemiDescriptionsItemData(label: '许可', value: 'MIT'),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ]),
          const SizedBox(height: 40),
          _section('水平布局', [
            const SemiText(
              'column: 3，span: 2 跨两列，末行自动补满。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            const SemiDescriptions(
              key: ValueKey('horizontal-descriptions'),
              layout: SemiDescriptionsLayout.horizontal,
              column: 3,
              items: [
                SemiDescriptionsItemData(label: '名称', value: 'Semi Design'),
                SemiDescriptionsItemData(label: '版本', value: '2.104.0'),
                SemiDescriptionsItemData(label: '许可', value: 'MIT'),
                SemiDescriptionsItemData(
                  label: '描述',
                  value: '企业级设计系统',
                  span: 2,
                ),
                SemiDescriptionsItemData(label: '维护', value: '字节跳动'),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('双行模式', [
            const SemiText(
              'row: true 时 label 在上、value 加粗在下，size 控制字号与右间距。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            for (final size in SemiDescriptionsSize.values) ...[
              SemiText(size.name, type: SemiTextType.secondary),
              SemiDescriptions(
                key: ValueKey('row-${size.name}'),
                row: true,
                size: size,
                items: const [
                  SemiDescriptionsItemData(label: '实际用户数量', value: '1,480,000'),
                  SemiDescriptionsItemData(label: '7 天留存', value: '98%'),
                  SemiDescriptionsItemData(label: '安全等级', value: '3 级'),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ]),
          const SizedBox(height: 40),
          _section('自定义项', [
            const SemiDescriptions(
              key: ValueKey('custom-descriptions'),
              items: [
                SemiDescriptionsItemData(
                  label: '自定义样式',
                  value: 'label 紫色、固定宽 96',
                  keyStyle: TextStyle(color: Color(0xff7b61ff)),
                  keyWidth: 96,
                ),
                SemiDescriptionsItemData(
                  label: 'Widget 值',
                  value: SemiText('带图标', link: SemiTextLink(onTap: _noop)),
                ),
                SemiDescriptionsItemData(
                  label: '惰性求值',
                  valueBuilder: _buildLazyValue,
                ),
                SemiDescriptionsItemData(
                  label: '隐藏项',
                  value: '不渲染也不进语义',
                  hidden: true,
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('局部主题', [
            const SemiText(
              'label 紫色、value 绿色加粗、label 右间距 40。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            const SemiDescriptionsTheme(
              data: SemiDescriptionsThemeData(
                colorDescriptionsKeyTextDefault: Color(0xff7b61ff),
                colorDescriptionsValueTextDefault: Color(0xff0a7a2f),
                fontDescriptionsValueFontWeight: FontWeight.w800,
                spacingDescriptionsThPaddingRight: 40,
              ),
              child: SemiDescriptions(
                key: ValueKey('theme-descriptions'),
                items: [
                  SemiDescriptionsItemData(label: '主题字段一', value: '定制颜色'),
                  SemiDescriptionsItemData(label: '主题字段二', value: '定制字重'),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }

  static void _noop() {}

  static Widget _buildLazyValue() => const SemiText('渲染时才构建');
}
