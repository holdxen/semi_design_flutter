import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class ContextMenuPage extends StatefulWidget {
  const ContextMenuPage({super.key});

  @override
  State<ContextMenuPage> createState() => _ContextMenuPageState();
}

class _ContextMenuPageState extends State<ContextMenuPage> {
  String _status = '在触发区右键（触屏长按 700ms）展开菜单。';
  bool _showGrid = true;
  bool _snap = false;
  String _export = 'png';

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  Widget _target(String key, String label, {double height = 120}) => Container(
    key: ValueKey(key),
    width: double.infinity,
    height: height,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xffc6cacd)),
      borderRadius: BorderRadius.circular(4),
    ),
    child: SemiText(label),
  );

  SemiDropdownItemData _item(
    String name, {
    SemiDropdownItemType? type,
    bool disabled = false,
  }) => SemiDropdownItemData(
    name: name,
    type: type,
    disabled: disabled,
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
              '右键触发区在指针位置展开；触摸/手写笔长按 700ms 同样展开。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            SemiContextMenu(
              nodes: [
                _item('复制'),
                _item('粘贴'),
                const SemiDropdownDividerData(),
                _item('重命名'),
              ],
              child: _target('basic-target', '右键/长按我'),
            ),
          ]),
          const SizedBox(height: 40),
          _section('标题、危险项与禁用', [
            SemiText(_status, key: const ValueKey('context-menu-status')),
            const SizedBox(height: 12),
            SemiContextMenu(
              nodes: [
                const SemiDropdownTitleData('文件操作'),
                _item('打开'),
                _item('另存为…'),
                _item('上传中', disabled: true),
                const SemiDropdownDividerData(),
                _item('删除', type: SemiDropdownItemType.danger),
              ],
              child: _target('tier-target', '右键/长按我'),
            ),
          ]),
          const SizedBox(height: 40),
          _section('勾选与单选', [
            const SemiText(
              '勾选行切换后关闭；单选行上报选中值。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            SemiContextMenu(
              nodes: [
                SemiDropdownCheckboxItemData(
                  name: '显示网格',
                  checked: _showGrid,
                  onCheckedChange: (v) => setState(() {
                    _showGrid = v;
                    _status = '显示网格 → $v';
                  }),
                ),
                SemiDropdownCheckboxItemData(
                  name: '对齐到网格',
                  checked: _snap,
                  onCheckedChange: (v) => setState(() {
                    _snap = v;
                    _status = '对齐到网格 → $v';
                  }),
                ),
                const SemiDropdownDividerData(),
                SemiDropdownRadioGroupData(
                  value: _export,
                  onValueChange: (v) => setState(() {
                    _export = v;
                    _status = '导出格式 → $v';
                  }),
                  children: const [
                    SemiDropdownRadioItemData(value: 'png', name: 'PNG'),
                    SemiDropdownRadioItemData(value: 'svg', name: 'SVG'),
                    SemiDropdownRadioItemData(value: 'pdf', name: 'PDF'),
                  ],
                ),
              ],
              child: _target('check-target', '右键/长按我'),
            ),
          ]),
          const SizedBox(height: 40),
          _section('子菜单与键盘', [
            const SemiText(
              '悬停「导出为」100ms 展开子菜单；↑↓/Home/End 移动高亮，'
              'Enter/Space 激活，→/← 开合子菜单，Esc 关闭，首字母跳转。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            SemiContextMenu(
              nodes: [
                _item('复制'),
                SemiDropdownSubmenuItemData(
                  name: '导出为',
                  children: [
                    _item('PNG 图片'),
                    _item('SVG 矢量'),
                    const SemiDropdownDividerData(),
                    _item('PDF 文档'),
                  ],
                ),
                SemiDropdownSubmenuItemData(
                  name: '分享',
                  children: [
                    _item('复制链接'),
                    SemiDropdownSubmenuItemData(
                      name: '发送到',
                      children: [_item('邮件'), _item('即时消息')],
                    ),
                  ],
                ),
                const SemiDropdownDividerData(),
                _item('删除', type: SemiDropdownItemType.danger),
              ],
              child: _target('submenu-target', '右键/长按我'),
            ),
          ]),
        ],
      ),
    );
  }
}
