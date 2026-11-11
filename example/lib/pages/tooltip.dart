import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class TooltipPage extends StatefulWidget {
  const TooltipPage({super.key});

  @override
  State<TooltipPage> createState() => _TooltipPageState();
}

class _TooltipPageState extends State<TooltipPage> {
  bool _visible = false;
  String _status = '点击或悬停触发物查看提示。';

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  Widget _target(String key, String label) => Container(
    key: ValueKey(key),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xffc6cacd)),
      borderRadius: BorderRadius.circular(4),
    ),
    child: SemiText(label),
  );

  Widget _action(String key, String label, VoidCallback onTap) => SemiText(
    label,
    key: ValueKey(key),
    link: SemiTextLink(onTap: onTap),
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('基础用法', [
            const SemiText('悬停下方按钮，50ms 后显示提示。', type: SemiTextType.secondary),
            const SizedBox(height: 12),
            SemiTooltip(
              content: const Text('这是一个悬停提示'),
              child: _target('basic-target', '悬停我'),
            ),
          ]),
          const SizedBox(height: 40),
          _section('定位', [
            const SemiText('共 12 种位置，空间不足时自动翻转。', type: SemiTextType.secondary),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final position in SemiTooltipPosition.values)
                  SemiTooltip(
                    content: Text(position.name),
                    position: position,
                    child: _target('position-${position.name}', position.name),
                  ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('触发方式', [
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                SemiTooltip(
                  content: const Text('点击显示，再点外部关闭'),
                  trigger: SemiTooltipTrigger.click,
                  child: _target('click-target', 'click'),
                ),
                SemiTooltip(
                  content: const Text('聚焦显示，失焦关闭'),
                  trigger: SemiTooltipTrigger.focus,
                  child: _target('focus-target', 'focus'),
                ),
                SemiTooltip(
                  content: const Text('右键显示'),
                  trigger: SemiTooltipTrigger.contextMenu,
                  child: _target('context-target', 'contextMenu'),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('显隐控制', [
            SemiText(_status, key: const ValueKey('tooltip-status')),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                SemiTooltip(
                  content: const Text('受控提示：显隐由父级决定'),
                  trigger: SemiTooltipTrigger.custom,
                  visible: _visible,
                  onVisibleChange: (visible) =>
                      setState(() => _status = 'onVisibleChange: $visible'),
                  child: _target('custom-target', '受控触发物'),
                ),
                _action(
                  'toggle-visible',
                  _visible ? '隐藏提示' : '显示提示',
                  () => setState(() {
                    _visible = !_visible;
                    _status = _visible ? '已请求显示提示。' : '已请求隐藏提示。';
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SemiTooltip(
              content: const Text('点击提示内部会关闭（clickToHide）'),
              trigger: SemiTooltipTrigger.click,
              clickToHide: true,
              child: _target('click-to-hide-target', 'clickToHide'),
            ),
            const SizedBox(height: 12),
            SemiTooltip(
              content: const Text('按 Escape 可关闭（closeOnEsc）'),
              trigger: SemiTooltipTrigger.click,
              closeOnEsc: true,
              child: _target('esc-target', 'closeOnEsc'),
            ),
          ]),
          const SizedBox(height: 40),
          _section('局部主题', [
            const SemiText(
              '紫色背景、圆角 12、内边距 16、最大宽 180。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            SemiTooltipTheme(
              data: const SemiTooltipThemeData(
                colorTooltipBgDefault: Color(0xff7b61ff),
                radiusTooltip: 12,
                spacingTooltipContentPaddingTop: 16,
                spacingTooltipContentPaddingBottom: 16,
                spacingTooltipContentPaddingLeft: 16,
                spacingTooltipContentPaddingRight: 16,
                widthTooltip: 180,
              ),
              child: SemiTooltip(
                key: const ValueKey('theme-tooltip'),
                content: const Text('局部主题定制的提示'),
                child: _target('theme-target', '悬停查看主题'),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
