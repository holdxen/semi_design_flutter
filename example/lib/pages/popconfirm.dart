import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class PopconfirmPage extends StatefulWidget {
  const PopconfirmPage({super.key});

  @override
  State<PopconfirmPage> createState() => _PopconfirmPageState();
}

class _PopconfirmPageState extends State<PopconfirmPage> {
  bool _visible = false;
  String _status = '点击触发物弹出气泡确认框。';
  int _deleted = 0;

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
            const SemiText(
              '点击触发物弹出确认气泡，点「确认」执行并关闭。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            SemiPopconfirm(
              title: const Text('删除任务'),
              content: const Text('确定删除该任务吗？删除后不可恢复。'),
              onConfirm: () => setState(() => _deleted++),
              onVisibleChange: (v) => setState(
                () => _status = '基础用法 onVisibleChange: $v',
              ),
              child: _target('basic-target', '删除任务（$_deleted）'),
            ),
          ]),
          const SizedBox(height: 40),
          _section('按钮与回调', [
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                SemiPopconfirm(
                  title: const Text('自定义文案'),
                  content: const Text('按钮文案与类型可定制。'),
                  okText: '通过',
                  cancelText: '拒绝',
                  okType: SemiButtonType.secondary,
                  cancelType: SemiButtonType.tertiary,
                  onConfirm: () => setState(() => _status = '点击了「通过」'),
                  onCancel: () => setState(() => _status = '点击了「拒绝」'),
                  child: _target('text-target', '自定义按钮'),
                ),
                SemiPopconfirm(
                  title: const Text('异步确认'),
                  content: const Text('onConfirm 返回 Future 时按钮 loading，完成后自动关闭。'),
                  onConfirm: () async {
                    await Future<void>.delayed(const Duration(seconds: 1));
                    setState(() => _status = '异步确认完成');
                  },
                  child: _target('async-target', '异步确认'),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('图标与关闭按钮', [
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                SemiPopconfirm(
                  title: const Text('危险操作'),
                  content: const Text('自定义图标（warning 着色为默认）。'),
                  icon: const SemiIcon(SemiIcons.delete, size: SemiIconSize.extraLarge),
                  okType: SemiButtonType.danger,
                  onConfirm: () => setState(() => _status = '已执行危险操作'),
                  child: _target('icon-target', '自定义图标'),
                ),
                SemiPopconfirm(
                  title: const Text('无图标'),
                  content: const Text('icon: null 隐藏图标槽。'),
                  icon: null,
                  onConfirm: () => setState(() => _status = '无图标确认'),
                  child: _target('no-icon-target', '隐藏图标'),
                ),
                SemiPopconfirm(
                  title: const Text('无关闭按钮'),
                  content: const Text('showCloseIcon: false。'),
                  showCloseIcon: false,
                  onConfirm: () => setState(() => _status = '无关闭按钮确认'),
                  child: _target('no-close-target', '隐藏关闭按钮'),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('定位与箭头', [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final position in const [
                  SemiTooltipPosition.top,
                  SemiTooltipPosition.left,
                  SemiTooltipPosition.right,
                  SemiTooltipPosition.bottom,
                ])
                  SemiPopconfirm(
                    title: Text(position.name),
                    content: const Text('空间不足时自动翻转。'),
                    position: position,
                    child: _target('position-${position.name}', position.name),
                  ),
                SemiPopconfirm(
                  title: const Text('带箭头'),
                  content: const Text('showArrow: true，内边距切换为 12/8。'),
                  showArrow: true,
                  onConfirm: () => setState(() => _status = '带箭头确认'),
                  child: _target('arrow-target', 'showArrow'),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('受控显隐', [
            SemiText(_status, key: const ValueKey('popconfirm-status')),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                SemiPopconfirm(
                  title: const Text('受控气泡'),
                  content: const Text('显隐由父级 visible 决定。'),
                  visible: _visible,
                  onVisibleChange: (v) =>
                      setState(() => _status = 'onVisibleChange: $v'),
                  onConfirm: () => setState(() => _status = '受控确认（保持打开）'),
                  child: _target('controlled-target', '受控触发物'),
                ),
                _action(
                  'toggle-visible',
                  _visible ? '关闭气泡' : '打开气泡',
                  () => setState(() {
                    _visible = !_visible;
                    _status = _visible ? '已请求打开。' : '已请求关闭。';
                  }),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('局部主题', [
            SemiPopconfirmTheme(
              data: const SemiPopconfirmThemeData(
                widthPopconfirmMaxWidth: 240,
                spacingPopconfirmFooterMarginTop: 12,
                radiusPopconfirmPopover: 12,
              ),
              child: SemiPopconfirm(
                title: const Text('局部主题'),
                content: const Text('maxWidth 240 / footer 顶距 12 / 圆角 12。'),
                onConfirm: () => setState(() => _status = '局部主题确认'),
                child: _target('theme-target', '局部主题'),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
