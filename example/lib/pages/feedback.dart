import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  String _status = '点击按钮查看交互。';
  bool _emojiVisible = false;
  bool _textVisible = false;
  bool _radioVisible = false;
  bool _checkboxVisible = false;
  bool _customVisible = false;
  bool _modalVisible = false;
  bool _promiseVisible = false;

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

  SemiButton _btn(String label, VoidCallback onPressed) =>
      SemiButton(label, type: SemiButtonType.primary, onPressed: onPressed);

  void _log(String message) => setState(() => _status = message);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SemiText(_status, key: const ValueKey('feedback-status')),
          const SizedBox(height: 16),
          _section('表情（emoji，缺省类型）', [
            _row([_btn('打开反馈弹层', () => setState(() => _emojiVisible = true))]),
            SemiFeedback(
              visible: _emojiVisible,
              title: '为什么给出这个评分？',
              onValueChange: (v) => _log('value: $v'),
              onCancel: () => setState(() => _emojiVisible = false),
              onOk: () => setState(() {
                _emojiVisible = false;
                _status = '感谢您的反馈！';
              }),
            ),
          ]),
          const SizedBox(height: 40),
          _section('文本（text）', [
            _row([_btn('打开文本反馈', () => setState(() => _textVisible = true))]),
            SemiFeedback(
              visible: _textVisible,
              type: SemiFeedbackType.text,
              title: '请描述你遇到的问题',
              onCancel: () => setState(() => _textVisible = false),
              onOk: () => setState(() {
                _textVisible = false;
                _status = '已提交文本反馈。';
              }),
            ),
          ]),
          const SizedBox(height: 40),
          _section('单选（radio）', [
            _row([_btn('打开单选反馈', () => setState(() => _radioVisible = true))]),
            SemiFeedback(
              visible: _radioVisible,
              type: SemiFeedbackType.radio,
              title: '你对本次更新满意吗？',
              radioGroupProps: const SemiFeedbackRadioGroupProps(
                options: [
                  SemiRadioOption(label: '满意', value: 'satisfied'),
                  SemiRadioOption(label: '一般', value: 'neutral'),
                  SemiRadioOption(label: '不满意', value: 'unsatisfied'),
                ],
              ),
              onValueChange: (v) => _log('value: $v'),
              onCancel: () => setState(() => _radioVisible = false),
              onOk: () => setState(() {
                _radioVisible = false;
                _status = '已提交单选反馈。';
              }),
            ),
          ]),
          const SizedBox(height: 40),
          _section('多选（checkbox）', [
            _row([
              _btn('打开多选反馈', () => setState(() => _checkboxVisible = true)),
            ]),
            SemiFeedback(
              visible: _checkboxVisible,
              type: SemiFeedbackType.checkbox,
              title: '哪些地方需要改进？',
              checkboxGroupProps: const SemiFeedbackCheckboxGroupProps(
                options: [
                  SemiCheckboxOption(label: '加载速度', value: 'speed'),
                  SemiCheckboxOption(label: '交互体验', value: 'ux'),
                  SemiCheckboxOption(label: '视觉设计', value: 'visual'),
                ],
              ),
              onValueChange: (v) => _log('value: $v'),
              onCancel: () => setState(() => _checkboxVisible = false),
              onOk: () => setState(() {
                _checkboxVisible = false;
                _status = '已提交多选反馈。';
              }),
            ),
          ]),
          const SizedBox(height: 40),
          _section('自定义内容（custom）', [
            _row([
              _btn('打开自定义反馈', () => setState(() => _customVisible = true)),
            ]),
            SemiFeedback(
              visible: _customVisible,
              type: SemiFeedbackType.custom,
              title: '自定义反馈内容',
              content: const SemiText('这里可以放任意反馈表单。'),
              // custom 无内部值来源 → 显式放开提交门槛（`okDisabled: false`）。
              okDisabled: false,
              onCancel: () => setState(() => _customVisible = false),
              onOk: () => setState(() {
                _customVisible = false;
                _status = '已提交自定义反馈。';
              }),
            ),
          ]),
          const SizedBox(height: 40),
          _section('Modal 模式', [
            _row([
              _btn('打开 Modal 反馈', () => setState(() => _modalVisible = true)),
            ]),
            SemiFeedback(
              visible: _modalVisible,
              mode: SemiFeedbackMode.modal,
              type: SemiFeedbackType.emoji,
              title: '为什么给出这个评分？',
              onValueChange: (v) => _log('value: $v'),
              onCancel: () => setState(() => _modalVisible = false),
              onOk: () => setState(() {
                _modalVisible = false;
                _status = '感谢您的反馈！';
              }),
            ),
          ]),
          const SizedBox(height: 40),
          _section('异步提交（onOk 返回 Future）', [
            _row([
              _btn('打开异步反馈', () => setState(() => _promiseVisible = true)),
            ]),
            SemiFeedback(
              visible: _promiseVisible,
              title: '提交需要一点时间…',
              onCancel: () => setState(() => _promiseVisible = false),
              onOk: () async {
                await Future<void>.delayed(const Duration(seconds: 1));
                if (mounted) {
                  setState(() {
                    _promiseVisible = false;
                    _status = '异步提交完成。';
                  });
                }
              },
            ),
          ]),
        ],
      ),
    );
  }
}
