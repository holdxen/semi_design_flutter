import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class PinCodePage extends StatefulWidget {
  const PinCodePage({super.key});

  @override
  State<PinCodePage> createState() => _PinCodePageState();
}

class _PinCodePageState extends State<PinCodePage> {
  String _status = '在格子内输入字符查看 onChange / onComplete 事件。';

  // 受控演示（官网：value + onChange 同步 + 按钮随机设值）。
  String _controlled = '69af41';
  final Random _random = Random();

  // 手动聚焦/失焦演示（官网 ref.focus/blur）。
  final SemiPinCodeController _manual = SemiPinCodeController();

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  /// PinCode cells are fixed-width tokens; let each demo scroll sideways
  /// instead of overflowing on narrow screens.
  Widget _demo(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiText(label),
      const SizedBox(height: 6),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: child),
      const SizedBox(height: 12),
    ],
  );

  String _randomMixed() {
    const chars =
        '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return List.generate(6, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('基本使用', [
            SemiText(_status, key: const ValueKey('pincode-status')),
            const SizedBox(height: 12),
            _demo(
              'small',
              SemiPinCode(
                key: const ValueKey('pincode-small'),
                size: SemiInputSize.small,
                initialValue: '123456',
              ),
            ),
            _demo(
              'default（事件演示）',
              SemiPinCode(
                key: const ValueKey('pincode-default'),
                initialValue: '123456',
                onChanged: (value) => setState(() => _status = '值：「$value」'),
                onComplete: (value) => setState(() => _status = '完成：「$value」'),
              ),
            ),
            _demo(
              'large',
              SemiPinCode(
                key: const ValueKey('pincode-large'),
                size: SemiInputSize.large,
                initialValue: '123456',
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('受控', [
            _demo(
              'format=mixed，value 受控；点按钮随机设值',
              Row(
                children: [
                  SemiPinCode(
                    key: const ValueKey('pincode-controlled'),
                    format: SemiPinCodeFormat.mixed,
                    value: _controlled,
                    onChanged: (value) => setState(() {
                      _controlled = value;
                      _status = '受控值：「$value」';
                    }),
                    onComplete: (value) =>
                        setState(() => _status = '受控完成：「$value」'),
                  ),
                  const SizedBox(width: 12),
                  SemiButton(
                    const Text('随机设值'),
                    key: const ValueKey('pincode-random'),
                    onPressed: () => setState(() {
                      _controlled = _randomMixed();
                      _status = '随机设值：「$_controlled」';
                    }),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('设置位数', [
            _demo(
              'count=4',
              SemiPinCode(
                key: const ValueKey('pincode-count4'),
                count: 4,
                onChanged: (value) => setState(() => _status = '四位值：「$value」'),
                onComplete: (value) =>
                    setState(() => _status = '四位完成：「$value」'),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('设置字符范围', [
            _demo(
              "format='number'（默认，仅数字）",
              SemiPinCode(
                key: const ValueKey('pincode-fmt-number'),
                format: SemiPinCodeFormat.number,
              ),
            ),
            _demo(
              "format='mixed'（数字 + 字母）",
              SemiPinCode(
                key: const ValueKey('pincode-fmt-mixed'),
                format: SemiPinCodeFormat.mixed,
              ),
            ),
            _demo(
              'format=RegExp（仅大写字母）',
              SemiPinCode(
                key: const ValueKey('pincode-fmt-regex'),
                format: RegExp(r'[A-Z]'),
              ),
            ),
            _demo(
              'format=函数（仅小写字母）',
              SemiPinCode(
                key: const ValueKey('pincode-fmt-func'),
                format: (char) => RegExp(r'[a-z]').hasMatch(char),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('手动聚焦失焦', [
            _demo(
              '通过 controller.focus(2) / blur(2) 手动控制第三位',
              Row(
                children: [
                  SemiPinCode(
                    key: const ValueKey('pincode-manual'),
                    controller: _manual,
                    autoFocus: false,
                  ),
                  const SizedBox(width: 12),
                  SemiButton(
                    const Text('聚焦第 3 位'),
                    key: const ValueKey('pincode-focus3'),
                    onPressed: () => _manual.focus(2),
                  ),
                  const SizedBox(width: 8),
                  SemiButton(
                    const Text('失焦第 3 位'),
                    key: const ValueKey('pincode-blur'),
                    onPressed: () => _manual.blur(2),
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
