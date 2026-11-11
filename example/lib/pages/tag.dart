import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class TagPage extends StatefulWidget {
  const TagPage({super.key});

  @override
  State<TagPage> createState() => _TagPageState();
}

class _TagPageState extends State<TagPage> {
  SemiTagType _type = SemiTagType.light;
  SemiTagSize _size = SemiTagSize.normal;
  SemiTagShape _shape = SemiTagShape.square;
  bool _controlledVisible = true;
  int _closedCount = 0;
  String _status = '点击下方标签或关闭按钮查看交互。';

  Widget _action(String key, String label, VoidCallback onTap) => SemiText(
    label,
    key: ValueKey(key),
    link: SemiTextLink(onTap: onTap),
  );

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  Widget _avatar(SemiTagColor color) => Builder(
    builder: (context) {
      final palette = SemiTheme.of(context).palette;
      final channels = switch (color) {
        SemiTagColor.amber => palette.amber5,
        SemiTagColor.blue => palette.blue5,
        SemiTagColor.cyan => palette.cyan5,
        SemiTagColor.green => palette.green5,
        SemiTagColor.grey => palette.grey5,
        SemiTagColor.indigo => palette.indigo5,
        SemiTagColor.lightBlue => palette.lightBlue5,
        SemiTagColor.lightGreen => palette.lightGreen5,
        SemiTagColor.lime => palette.lime5,
        SemiTagColor.orange => palette.orange5,
        SemiTagColor.pink => palette.pink5,
        SemiTagColor.purple => palette.purple5,
        SemiTagColor.red => palette.red5,
        SemiTagColor.teal => palette.teal5,
        SemiTagColor.violet => palette.violet5,
        SemiTagColor.yellow => palette.yellow5,
        SemiTagColor.white => palette.grey5,
      };
      return Container(
        width: 20,
        height: 20,
        color: channels.toColor(),
        alignment: Alignment.center,
        child: SemiText('S', size: SemiTextSize.small),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('颜色', [
            SemiText(
              '当前类型：${_type.name}，点击切换类型后所有色板同步变化。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final type in SemiTagType.values)
                  _action(
                    'toggle-type-${type.name}',
                    type.name,
                    () => setState(() => _type = type),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final color in SemiTagColor.values)
                  SemiTag(
                    color.name,
                    key: ValueKey('palette-${color.name}'),
                    color: color,
                    type: _type,
                  ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('尺寸与形状', [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final size in SemiTagSize.values)
                  _action(
                    'toggle-size-${size.name}',
                    size.name,
                    () => setState(() => _size = size),
                  ),
                for (final shape in SemiTagShape.values)
                  _action(
                    'toggle-shape-${shape.name}',
                    shape.name,
                    () => setState(() => _shape = shape),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SemiTag(
                  '标签内容',
                  key: const ValueKey('shape-demo'),
                  size: _size,
                  shape: _shape,
                  type: _type,
                  color: SemiTagColor.blue,
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('可关闭', [
            SemiText(_status, key: const ValueKey('close-status')),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SemiTag(
                  '默认关闭',
                  key: const ValueKey('closable-default'),
                  closable: true,
                  onClose: (_) =>
                      setState(() => _status = '默认关闭已触发，共关闭 $_closedCount 次。'),
                ),
                SemiTag(
                  '受控标签',
                  key: const ValueKey('closable-controlled'),
                  closable: true,
                  visible: _controlledVisible,
                  tagKey: 'controlled',
                  onClose: (event) => setState(() {
                    _controlledVisible = false;
                    _status = '受控标签已隐藏，由父组件控制 visible。';
                  }),
                ),
                SemiTag(
                  '阻止关闭',
                  key: const ValueKey('closable-prevented'),
                  closable: true,
                  onClose: (event) => setState(() {
                    event.preventDefault();
                    _status = '已调用 preventDefault()，标签保持可见。';
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _action(
                  'reset-controlled',
                  '恢复受控标签',
                  () => setState(() {
                    _controlledVisible = true;
                    _status = '受控标签已恢复。';
                  }),
                ),
                _action(
                  'add-close-count',
                  '模拟计数 +1',
                  () => setState(() {
                    _closedCount++;
                    _status = '计数已增加到 $_closedCount。';
                  }),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('图标与头像', [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                const SemiTag(
                  '带前缀图标',
                  key: ValueKey('prefix-icon'),
                  prefixIcon: SemiIcon(SemiIcons.search),
                ),
                const SemiTag(
                  '带后缀图标',
                  key: ValueKey('suffix-icon'),
                  suffixIcon: SemiIcon(SemiIcons.chevronRight),
                ),
                const SemiTag(
                  '前后图标',
                  key: ValueKey('both-icons'),
                  prefixIcon: SemiIcon(SemiIcons.star),
                  suffixIcon: SemiIcon(SemiIcons.close),
                ),
                SemiTag(
                  '方形头像',
                  key: const ValueKey('avatar-square'),
                  avatar: _avatar(SemiTagColor.purple),
                  avatarShape: SemiTagShape.square,
                ),
                SemiTag(
                  '圆形头像',
                  key: const ValueKey('avatar-circle'),
                  avatar: _avatar(SemiTagColor.teal),
                  avatarShape: SemiTagShape.circle,
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('AI 色彩', [
            const SemiText(
              'colorful 使用 AI 紫色，gradient 启用渐变背景与文字。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final type in SemiTagType.values)
                  SemiTag(
                    '${type.name} · colorful',
                    key: ValueKey('colorful-${type.name}'),
                    type: type,
                    colorful: true,
                  ),
                for (final type in SemiTagType.values)
                  SemiTag(
                    '${type.name} · gradient',
                    key: ValueKey('gradient-${type.name}'),
                    type: type,
                    colorful: true,
                    gradient: true,
                  ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('局部主题', [
            const SemiText('圆角 6、内边距 12、高度 28。', type: SemiTextType.secondary),
            const SizedBox(height: 12),
            SemiTagTheme(
              data: const SemiTagThemeData(
                radiusTag: 6,
                heightTagSmall: 28,
                heightTagLarge: 28,
                spacingTagSmallPaddingX: 12,
                spacingTagLargePaddingX: 12,
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  const SemiTag(
                    '局部主题标签',
                    key: ValueKey('theme-tag'),
                    size: SemiTagSize.large,
                    color: SemiTagColor.green,
                  ),
                  const SemiTag(
                    '局部主题 · solid',
                    key: ValueKey('theme-tag-solid'),
                    size: SemiTagSize.large,
                    color: SemiTagColor.green,
                    type: SemiTagType.solid,
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
