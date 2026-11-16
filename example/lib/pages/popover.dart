import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class PopoverPage extends StatefulWidget {
  const PopoverPage({super.key});

  @override
  State<PopoverPage> createState() => _PopoverPageState();
}

class _PopoverPageState extends State<PopoverPage> {
  bool _visible = false;
  String _status = 'Hover（默认）/ 点击触发物弹出气泡卡片。';

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  Widget _action(String key, String label, VoidCallback onTap) => SemiText(
    label,
    key: ValueKey(key),
    link: SemiTextLink(onTap: onTap),
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

  Widget _content(String text) =>
      Padding(padding: const EdgeInsets.all(12), child: SemiText(text));

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('基础用法', [
            const SemiText(
              'Hover 触发（上游默认 trigger: hover、position: bottom），气泡卡片无箭头时内容自带间距。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            SemiPopover(
              content: _content('Hi Bytedancer, this is a popover.'),
              onVisibleChange: (v) =>
                  setState(() => _status = '基础用法 onVisibleChange: $v'),
              child: _target('basic-target', 'Hover 我'),
            ),
          ]),
          const SizedBox(height: 40),
          _section('点击与受控', [
            const SemiText(
              'trigger: click 弹出；visible 非空即受控，只回调请求。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                SemiPopover(
                  trigger: SemiTooltipTrigger.click,
                  content: _content('点击触发的气泡卡片。'),
                  onVisibleChange: (v) =>
                      setState(() => _status = '点击用法 onVisibleChange: $v'),
                  child: _target('click-target', '点击我'),
                ),
                SemiPopover(
                  trigger: SemiTooltipTrigger.click,
                  visible: _visible,
                  content: _content('受控气泡：开关在使用方手里。'),
                  onVisibleChange: (v) =>
                      setState(() => _status = '受控 onVisibleChange: $v（只回调）'),
                  child: _target('controlled-target', '受控气泡'),
                ),
                _action(
                  'toggle-visible',
                  '切换受控显隐',
                  () => setState(() => _visible = !_visible),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('带箭头', [
            const SemiText(
              'showArrow 画 popover 双路径箭头（bg-3 翼形 + color-border 描边）；'
              'arrowStyle 覆写两路径着色。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                SemiPopover(
                  trigger: SemiTooltipTrigger.click,
                  showArrow: true,
                  content: _content('带箭头的气泡卡片（外层 12px 内边距）。'),
                  onVisibleChange: (v) =>
                      setState(() => _status = '带箭头 onVisibleChange: $v'),
                  child: _target('arrow-target', '默认箭头'),
                ),
                SemiPopover(
                  trigger: SemiTooltipTrigger.click,
                  showArrow: true,
                  arrowStyle: const SemiPopoverArrowStyle(
                    borderColor: Color(0xff324350),
                    backgroundColor: Color(0xff4cc3fa),
                    borderOpacity: 1,
                  ),
                  content: _content('arrowStyle 自定义着色。'),
                  onVisibleChange: (v) => setState(
                    () => _status = 'arrowStyle onVisibleChange: $v',
                  ),
                  child: _target('arrow-style-target', '自定义箭头'),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('定位', [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final position in const [
                  SemiTooltipPosition.top,
                  SemiTooltipPosition.bottom,
                  SemiTooltipPosition.left,
                  SemiTooltipPosition.right,
                  SemiTooltipPosition.topLeft,
                  SemiTooltipPosition.bottomRight,
                ])
                  SemiPopover(
                    trigger: SemiTooltipTrigger.click,
                    position: position,
                    showArrow: true,
                    content: _content('position: ${position.name}'),
                    onVisibleChange: (v) => setState(
                      () => _status = '${position.name} onVisibleChange: $v',
                    ),
                    child: _target('pos-${position.name}', position.name),
                  ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          SemiText(
            _status,
            key: const ValueKey('popover-status'),
            type: SemiTextType.secondary,
          ),
        ],
      ),
    );
  }
}
