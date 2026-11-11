import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class DropdownPage extends StatefulWidget {
  const DropdownPage({super.key});

  @override
  State<DropdownPage> createState() => _DropdownPageState();
}

class _DropdownPageState extends State<DropdownPage> {
  String _status = '点击或悬停触发物展开菜单。';

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

  SemiDropdownItemData _item(
    String name, {
    SemiDropdownItemType? type,
    bool active = false,
    bool disabled = false,
    Widget? icon,
    bool? showTick,
  }) => SemiDropdownItemData(
    name: name,
    type: type,
    active: active,
    disabled: disabled,
    icon: icon,
    showTick: showTick,
    onTap: () => setState(() => _status = '点击了「$name」。'),
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('基础用法', [
            const SemiText(
              '悬停展开，菜单包含分组标题、菜单项和分隔线。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            SemiDropdown(
              trigger: SemiTooltipTrigger.hover,
              showTick: true,
              menu: [
                const SemiDropdownTitleData('分组一'),
                _item('操作一'),
                _item('操作二', active: true),
                const SemiDropdownDividerData(),
                const SemiDropdownTitleData('分组二'),
                _item('操作三'),
              ],
              child: _target('basic-target', '悬停我'),
            ),
          ]),
          const SizedBox(height: 40),
          _section('触发方式', [
            SemiText(_status, key: const ValueKey('dropdown-status')),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                SemiDropdown(
                  trigger: SemiTooltipTrigger.click,
                  menu: [_item('点击项一'), _item('点击项二')],
                  child: _target('click-target', 'click'),
                ),
                SemiDropdown(
                  trigger: SemiTooltipTrigger.hover,
                  menu: [_item('悬停项一'), _item('悬停项二')],
                  child: _target('hover-target', 'hover'),
                ),
                SemiDropdown(
                  trigger: SemiTooltipTrigger.contextMenu,
                  menu: [_item('右键项一'), _item('右键项二')],
                  child: _target('context-target', 'contextMenu'),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('类型与状态', [
            SemiDropdown(
              key: const ValueKey('types-target-dropdown'),
              trigger: SemiTooltipTrigger.click,
              menu: [
                _item('primary', type: SemiDropdownItemType.primary),
                _item('secondary', type: SemiDropdownItemType.secondary),
                _item('tertiary', type: SemiDropdownItemType.tertiary),
                _item('warning', type: SemiDropdownItemType.warning),
                _item('danger', type: SemiDropdownItemType.danger),
                const SemiDropdownDividerData(),
                _item('禁用项', disabled: true),
                _item('带图标', icon: const SemiIcon(SemiIcons.star)),
              ],
              child: _target('types-target', '点击查看类型'),
            ),
          ]),
          const SizedBox(height: 40),
          _section('选中对勾', [
            const SemiText(
              'showTick：选中项显示对勾，未选中显示透明占位保持对齐。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            SemiDropdown(
              trigger: SemiTooltipTrigger.click,
              showTick: true,
              menu: [
                _item('未选中项'),
                _item('选中项', active: true),
                _item('另一未选中项'),
              ],
              child: _target('tick-target', '点击查看对勾'),
            ),
          ]),
          const SizedBox(height: 40),
          _section('自定义弹层与嵌套', [
            const SemiText(
              'content 自定义弹层；菜单项内可嵌套子菜单（spacing: 2）。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            SemiDropdown(
              trigger: SemiTooltipTrigger.click,
              content: Container(
                width: 200,
                padding: const EdgeInsets.all(12),
                child: const SemiText('这是完全自定义的弹层内容。'),
              ),
              child: _target('content-target', '自定义弹层'),
            ),
            const SizedBox(height: 12),
            SemiDropdown(
              key: const ValueKey('nested-dropdown'),
              trigger: SemiTooltipTrigger.click,
              menu: [
                _item('普通项'),
                SemiDropdownItemData(
                  name: SemiDropdown(
                    trigger: SemiTooltipTrigger.hover,
                    position: SemiTooltipPosition.rightTop,
                    spacing: 2,
                    menu: [_item('子菜单项一'), _item('子菜单项二')],
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SemiText('更多操作'),
                        SizedBox(width: 4),
                        SemiIcon(SemiIcons.chevronRight),
                      ],
                    ),
                  ),
                ),
              ],
              child: _target('nested-target', '嵌套子菜单'),
            ),
          ]),
          const SizedBox(height: 40),
          _section('局部主题', [
            const SemiText(
              '菜单背景紫色调、悬停浅紫、圆角 12、宽 240。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            SemiDropdownTheme(
              data: const SemiDropdownThemeData(
                colorDropdownBgDefault: Color(0xff2b2340),
                colorDropdownItemBgHover: Color(0xff453a63),
                colorDropdownItemTextDefault: Color(0xffe6e0f5),
                radiusDropdown: 12,
                widthDropdown: 240,
              ),
              child: SemiDropdown(
                trigger: SemiTooltipTrigger.click,
                menu: [_item('主题项一'), _item('主题项二')],
                child: _target('theme-target', '点击查看主题'),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
