import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  String _status = '在输入框内键入内容或按 Enter 查看事件。';

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  Widget _row(List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final child in children) ...[child, const SizedBox(height: 12)],
    ],
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('基础用法', [
            SemiText(_status, key: const ValueKey('input-status')),
            const SizedBox(height: 12),
            SemiInput(
              key: const ValueKey('basic-input'),
              placeholder: '请输入内容',
              onChanged: (text) => setState(() => _status = '输入了「$text」。'),
              onEnterPress: () => setState(() => _status = '按下了 Enter。'),
            ),
          ]),
          const SizedBox(height: 40),
          _section('三档尺寸', [
            _row([
              const SemiInput(
                key: ValueKey('small-input'),
                size: SemiInputSize.small,
                placeholder: 'small（24 高）',
              ),
              const SemiInput(
                key: ValueKey('normal-input'),
                size: SemiInputSize.normal,
                placeholder: 'normal（32 高）',
              ),
              const SemiInput(
                key: ValueKey('large-input'),
                size: SemiInputSize.large,
                placeholder: 'large（40 高）',
              ),
            ]),
          ]),
          const SizedBox(height: 40),
          _section('前后缀与附加块', [
            const SemiInput(
              key: ValueKey('prefix-suffix-input'),
              placeholder: '金额',
              prefix: '价格',
              suffix: '元',
            ),
            const SizedBox(height: 12),
            const SemiInput(
              key: ValueKey('inset-label-input'),
              insetLabel: '名称',
              placeholder: '内嵌标签在前缀槽加粗显示',
            ),
            const SizedBox(height: 12),
            const SemiInput(
              key: ValueKey('addon-input'),
              placeholder: '带前后置块',
              addonBefore: Text('https://'),
              addonAfter: Text('.com'),
            ),
          ]),
          const SizedBox(height: 40),
          _section('状态', [
            _row([
              const SemiInput(
                key: ValueKey('disabled-input'),
                disabled: true,
                placeholder: '禁用',
              ),
              const SemiInput(
                key: ValueKey('readonly-input'),
                readonly: true,
                initialValue: '只读内容',
              ),
              const SemiInput(
                key: ValueKey('borderless-input'),
                borderless: true,
                placeholder: '无边框',
              ),
              const SemiInput(
                key: ValueKey('error-input'),
                validateStatus: SemiInputStatus.error,
                initialValue: '校验失败',
              ),
              const SemiInput(
                key: ValueKey('warning-input'),
                validateStatus: SemiInputStatus.warning,
                initialValue: '校验警告',
              ),
              const SemiInput(
                key: ValueKey('success-input'),
                validateStatus: SemiInputStatus.success,
                initialValue: '校验通过（无专属视觉）',
              ),
            ]),
          ]),
          const SizedBox(height: 40),
          _section('清除与密码', [
            _row([
              const SemiInput(
                key: ValueKey('clearable-input'),
                placeholder: '悬停或聚焦显示清除按钮',
                showClear: true,
              ),
              const SemiInput(
                key: ValueKey('password-input'),
                mode: SemiInputMode.password,
                initialValue: 'password',
                showClear: true,
                placeholder: '密码（点击眼睛切换显隐）',
              ),
            ]),
          ]),
          const SizedBox(height: 40),
          _section('多行', [
            const SemiInput(
              key: ValueKey('controlled-input'),
              value: '受控内容，父级同步',
              placeholder: '受控输入框',
            ),
            const SizedBox(height: 12),
            const SemiTextArea(
              key: ValueKey('textarea'),
              rows: 3,
              autosize: SemiTextAreaAutosize(minRows: 2, maxRows: 5),
              maxCount: 120,
              showCounter: true,
              showClear: true,
              disabledEnterStartNewLine: true,
              placeholder: '自动增高的多行输入；Enter 提交，Shift+Enter 换行',
            ),
          ]),
          const SizedBox(height: 40),
          _section('局部主题', [
            const SemiText(
              '背景浅紫、文字紫色、高度 44、圆角 12。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            const SemiInputTheme(
              data: SemiInputThemeData(
                colorInputDefaultBgDefault: Color(0xfff3effc),
                colorInputDefaultTextDefault: Color(0xff7b61ff),
                heightInputWrapperDefault: 44,
                radiusInputWrapper: 12,
              ),
              child: SemiInput(
                key: ValueKey('theme-input'),
                placeholder: '局部主题输入框',
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
