import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class ModalPage extends StatefulWidget {
  const ModalPage({super.key});

  @override
  State<ModalPage> createState() => _ModalPageState();
}

class _ModalPageState extends State<ModalPage> {
  String _status = '点击按钮查看交互。';
  bool _visible = false;
  bool _fullVisible = false;
  bool _customVisible = false;
  SemiModalSize _size = SemiModalSize.small;


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
          SemiText(_status, key: const ValueKey('modal-status')),
          const SizedBox(height: 16),
          _section('基础用法（声明式 visible）', [
            _row([
              _btn('打开对话框', () => setState(() => _visible = true)),
              _btn('关闭对话框', () => setState(() => _visible = false)),
            ]),
            SemiModal(
              visible: _visible,
              title: '标题',
              content: const Text('这是一段对话框内容。'),
              onOk: () {
                setState(() => _visible = false);
                _log('点击了确定。');
              },
              onCancel: () {
                setState(() => _visible = false);
                _log('点击了取消/关闭。');
              },
            ),
          ]),
          const SizedBox(height: 24),
          _section('命令式（confirm 族）', [
            _row([
              _btn('confirm', () {
                SemiModal.confirm(
                  context: context,
                  title: '确认',
                  content: const Text('确定执行该操作吗？'),
                  onOk: () => _log('confirm 确定。'),
                  onCancel: () => _log('confirm 取消。'),
                );
              }),
              _btn('info', () {
                SemiModal.info(
                  context: context,
                  title: '提示',
                  content: const Text('这是一条消息提示。'),
                  hasCancel: false,
                );
              }),
              _btn('success', () {
                SemiModal.success(
                  context: context,
                  title: '成功',
                  content: const Text('操作已完成。'),
                  hasCancel: false,
                );
              }),
              _btn('warning', () {
                SemiModal.warning(
                  context: context,
                  title: '警告',
                  content: const Text('需要注意的风险。'),
                );
              }),
              _btn('error', () {
                SemiModal.error(
                  context: context,
                  title: '错误',
                  content: const Text('操作失败，请重试。'),
                );
              }),
            ]),
          ]),
          const SizedBox(height: 24),
          _section('尺寸（small 448 / medium 684 / large 920 / fullWidth）', [
            _row([
              for (final size in SemiModalSize.values)
                SemiButton(
                  size.name,
                  type: _size == size
                      ? SemiButtonType.primary
                      : SemiButtonType.secondary,
                  onPressed: () {
                    setState(() => _size = size);
                    SemiModal.info(
                      context: context,
                      size: size,
                      hasCancel: false,
                      title: '尺寸 ${size.name}',
                      content: Text('width-modal_${size.name}。'),
                    );
                  },
                ),
            ]),
          ]),
          const SizedBox(height: 24),
          _section('居中 / 全屏 / 自定义', [
            _row([
              _btn('居中 centered', () {
                SemiModal.info(
                  context: context,
                  centered: true,
                  hasCancel: false,
                  title: '居中',
                  content: const Text('margin: auto 语义。'),
                );
              }),
              _btn('全屏 fullScreen', () {
                setState(() => _fullVisible = true);
              }),
              SemiModal(
                visible: _fullVisible,
                fullScreen: true,
                hasCancel: false,
                title: '全屏',
                content: const Text('radius 0、无描边、铺满。'),
                onOk: () => setState(() => _fullVisible = false),
                onCancel: () => setState(() => _fullVisible = false),
              ),
              _btn('自定义 header/footer', () {
                setState(() => _customVisible = true);
              }),
              SemiModal(
                visible: _customVisible,
                header: const SemiTitle('自定义 header', heading: 5),
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
                content: const Text('header/footer 整体替换。'),
                onCancel: () => setState(() => _customVisible = false),
                onOk: () => setState(() => _customVisible = false),
              ),
              _btn('无取消 hasCancel: false', () {
                SemiModal.info(
                  context: context,
                  hasCancel: false,
                  title: '仅确定',
                  content: const Text('footer 只渲染确定按钮。'),
                );
              }),
            ]),
          ]),
          const SizedBox(height: 24),
          _section('异步确定（按钮 loading 至 Future 完成）', [
            _row([
              _btn('异步 confirm', () {
                SemiModal.confirm(
                  context: context,
                  title: '提交',
                  content: const Text('点击确定将提交（500ms）。'),
                  onOk: () async {
                    await Future<void>.delayed(
                      const Duration(milliseconds: 500),
                    );
                    _log('异步提交完成。');
                  },
                );
              }),
            ]),
          ]),
        ],
      ),
    );
  }
}
