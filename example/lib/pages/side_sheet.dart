import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class SideSheetPage extends StatefulWidget {
  const SideSheetPage({super.key});

  @override
  State<SideSheetPage> createState() => _SideSheetPageState();
}

class _SideSheetPageState extends State<SideSheetPage> {
  String _status = '点击按钮查看交互。';
  bool _visible = false;
  bool _placementVisible = false;
  bool _sizeVisible = false;
  bool _customVisible = false;
  bool _fixedVisible = false;
  bool _escVisible = false;
  SemiSideSheetPlacement _placement = SemiSideSheetPlacement.right;
  SemiSideSheetSize _size = SemiSideSheetSize.small;

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  Widget _row(List<Widget> children) => Wrap(
    spacing: 12,
    runSpacing: 12,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: children,
  );

  SemiButton _btn(String label, VoidCallback onPressed) => SemiButton(
    label,
    type: SemiButtonType.primary,
    onPressed: onPressed,
  );

  void _log(String message) => setState(() => _status = message);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SemiText(_status, key: const ValueKey('side-sheet-status')),
          const SizedBox(height: 16),
          _section('基础用法（声明式 visible，right）', [
            _row([
              _btn('打开侧边栏', () => setState(() => _visible = true)),
              _btn('关闭侧边栏', () => setState(() => _visible = false)),
            ]),
            SemiSideSheet(
              visible: _visible,
              title: '标题',
              content: const Text('这是一段侧边栏内容。'),
              footer: _row([
                SemiButton(
                  '确定',
                  type: SemiButtonType.primary,
                  onPressed: () {
                    setState(() => _visible = false);
                    _log('点击了确定。');
                  },
                ),
              ]),
              onCancel: () {
                setState(() => _visible = false);
                _log('点击了取消/关闭。');
              },
            ),
          ]),
          const SizedBox(height: 24),
          _section('四向滑出（placement）', [
            _row([
              for (final placement in SemiSideSheetPlacement.values)
                SemiButton(
                  placement.name,
                  type: _placement == placement
                      ? SemiButtonType.primary
                      : SemiButtonType.secondary,
                  onPressed: () {
                    setState(() {
                      _placement = placement;
                      _placementVisible = true;
                    });
                    _log('placement: ${placement.name}。');
                  },
                ),
            ]),
            SemiSideSheet(
              visible: _placementVisible,
              placement: _placement,
              title: '标题',
              content: Text('这是一段 placement: ${_placement.name} 的内容。'),
              onCancel: () => setState(() => _placementVisible = false),
            ),
          ]),
          const SizedBox(height: 24),
          _section('尺寸（small 448 / medium 684 / large 920）', [
            _row([
              for (final size in SemiSideSheetSize.values)
                SemiButton(
                  size.name,
                  type: _size == size
                      ? SemiButtonType.primary
                      : SemiButtonType.secondary,
                  onPressed: () {
                    setState(() {
                      _size = size;
                      _placement = SemiSideSheetPlacement.right;
                      _sizeVisible = true;
                    });
                    _log('size: ${size.name}。');
                  },
                ),
              _btn('自定义 height（bottom 300）', () {
                setState(() {
                  _placement = SemiSideSheetPlacement.bottom;
                  _sizeVisible = true;
                });
                _log('bottom + height: 300（width 仅 left/right 生效）。');
              }),
            ]),
            SemiSideSheet(
              visible: _sizeVisible,
              placement: _placement,
              size: _size,
              height: 300,
              title: '尺寸 ${_size.name}',
              content: const Text('size 档 / height 数值覆盖。'),
              onCancel: () => setState(() => _sizeVisible = false),
            ),
          ]),
          const SizedBox(height: 24),
          _section('自定义 title/footer / 无蒙层 fixed', [
            _row([
              _btn('自定义 title/footer', () {
                setState(() => _customVisible = true);
              }),
              _btn('无蒙层 fixed（mask: false）', () {
                setState(() => _fixedVisible = true);
              }),
            ]),
            SemiSideSheet(
              visible: _customVisible,
              title: const SemiTitle('自定义 title', heading: 5),
              content: const Text('title 整体替换。'),
              footer: _row([
                SemiButton(
                  '知道了',
                  type: SemiButtonType.primary,
                  onPressed: () {
                    setState(() => _customVisible = false);
                    _log('自定义 footer 点击。');
                  },
                ),
              ]),
              onCancel: () => setState(() => _customVisible = false),
            ),
            SemiSideSheet(
              visible: _fixedVisible,
              mask: false,
              title: 'fixed 模式',
              content: const Text('无蒙层：投影 + 点击穿透。'),
              onCancel: () => setState(() => _fixedVisible = false),
            ),
          ]),
          const SizedBox(height: 24),
          _section('closeOnEsc / afterVisibleChange', [
            _row([
              _btn('closeOnEsc（Esc 关闭）', () {
                setState(() => _escVisible = true);
                _log('按 Esc 通知 onCancel（closeOnEsc: true）。');
              }),
            ]),
            SemiSideSheet(
              visible: _escVisible,
              closeOnEsc: true,
              title: 'closeOnEsc',
              content: const Text('Esc 触发 onCancel（声明式不自关）。'),
              afterVisibleChange: (isVisible) =>
                  _log('afterVisibleChange: $isVisible。'),
              onCancel: () {
                setState(() => _escVisible = false);
                _log('Esc/关闭触发 onCancel。');
              },
            ),
          ]),
        ],
      ),
    );
  }
}
