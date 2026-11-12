import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class InputNumberPage extends StatefulWidget {
  const InputNumberPage({super.key});

  @override
  State<InputNumberPage> createState() => _InputNumberPageState();
}

class _InputNumberPageState extends State<InputNumberPage> {
  String _status = '点击步进按钮或聚焦后按 ↑/↓ 查看数值变化。';

  /// Callbacks report `num`; drop the trailing `.0` for whole values.
  String _fmt(num n) => n == n.roundToDouble() ? n.toInt().toString() : '$n';

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  /// Upstream demos stack `<label>` + control + `<br/>`.
  Widget _demo(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiText(label),
      const SizedBox(height: 6),
      child,
      const SizedBox(height: 12),
    ],
  );

  /// Thousands separator for the ￥ formatter demo (the upstream example
  /// runs `\B(?=(\d{3})+(?!\d))` over the whole string).
  String _groupDigits(String value) =>
      value.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('基本输入框', [
            SemiText(_status, key: const ValueKey('inputnumber-status')),
            const SizedBox(height: 12),
            _demo(
              '简单数字输入框',
              SizedBox(
                width: 280,
                child: SemiInputNumber(
                  key: const ValueKey('inputnumber-basic'),
                  onNumberChange: (n) =>
                      setState(() => _status = '数值：${_fmt(n)}'),
                  onUpClick: (text) => setState(() => _status = '点击了加：$text'),
                  onDownClick: (text) => setState(() => _status = '点击了减：$text'),
                ),
              ),
            ),
            _demo(
              '设置了步长 step=2',
              SizedBox(
                width: 280,
                child: SemiInputNumber(
                  key: const ValueKey('inputnumber-step2'),
                  step: 2,
                ),
              ),
            ),
            _demo(
              '设置 shiftStep=100，按住 Shift 同时点击按钮，可以一次增加/减少 100',
              SizedBox(
                width: 280,
                child: SemiInputNumber(
                  key: const ValueKey('inputnumber-shift-step'),
                  shiftStep: 100,
                ),
              ),
            ),
            _demo(
              '设置了上下界 min=1，max=10',
              SizedBox(
                width: 280,
                child: SemiInputNumber(
                  key: const ValueKey('inputnumber-bounds'),
                  min: 1,
                  max: 10,
                  initialValue: 1,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('状态与精度', [
            _demo(
              '默认值 defaultValue=5',
              SizedBox(
                width: 280,
                child: SemiInputNumber(
                  key: const ValueKey('inputnumber-seeded'),
                  initialValue: 5,
                ),
              ),
            ),
            _demo(
              '禁用',
              SizedBox(
                width: 280,
                child: SemiInputNumber(
                  key: const ValueKey('inputnumber-disabled'),
                  initialValue: 5,
                  disabled: true,
                ),
              ),
            ),
            _demo(
              '精度 precision=2（1.234 四舍五入显示 1.23）',
              SizedBox(
                width: 280,
                child: SemiInputNumber(
                  key: const ValueKey('inputnumber-precision'),
                  precision: 2,
                  initialValue: 1.234,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('隐藏步进器', [
            _demo(
              'innerButtons：聚焦/悬浮时步进器内嵌显示，否则显示后缀',
              SizedBox(
                width: 280,
                child: SemiInputNumber(
                  key: const ValueKey('inputnumber-inner'),
                  innerButtons: true,
                  suffix: '小时',
                  initialValue: 1,
                ),
              ),
            ),
            _demo(
              'hideButtons：彻底隐藏步进器',
              SizedBox(
                width: 280,
                child: SemiInputNumber(
                  key: const ValueKey('inputnumber-hidden'),
                  hideButtons: true,
                  initialValue: 1,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('尺寸', [
            _demo(
              'small',
              SizedBox(
                width: 280,
                child: SemiInputNumber(
                  key: const ValueKey('inputnumber-small'),
                  size: SemiInputSize.small,
                  initialValue: 1,
                ),
              ),
            ),
            _demo(
              'default',
              SizedBox(
                width: 280,
                child: SemiInputNumber(
                  key: const ValueKey('inputnumber-normal'),
                  size: SemiInputSize.normal,
                  initialValue: 1,
                ),
              ),
            ),
            _demo(
              'large',
              SizedBox(
                width: 280,
                child: SemiInputNumber(
                  key: const ValueKey('inputnumber-large'),
                  size: SemiInputSize.large,
                  initialValue: 1,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('自定义显示格式与解析方式', [
            _demo(
              '人民币',
              SizedBox(
                width: 280,
                child: SemiInputNumber(
                  key: const ValueKey('inputnumber-currency-format'),
                  initialValue: 1000,
                  min: 0,
                  formatter: (value) => '￥ ${_groupDigits(value)}',
                  parser: (value) => value.replaceAll(RegExp(r'￥\s?|,'), ''),
                ),
              ),
            ),
            _demo(
              '自定义串',
              SizedBox(
                width: 280,
                child: SemiInputNumber(
                  key: const ValueKey('inputnumber-dashed'),
                  initialValue: 1111,
                  formatter: (value) => value.split('').join('-'),
                  parser: (value) => value.replaceAll('-', ''),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('纯数字输入框', [
            _demo(
              'formatter 过滤非数字，min=0，仅回传合法数字',
              SizedBox(
                width: 280,
                child: SemiInputNumber(
                  key: const ValueKey('inputnumber-digits-only'),
                  min: 0,
                  max: 9007199254740991,
                  formatter: (value) => value.replaceAll(RegExp(r'\D'), ''),
                  onNumberChange: (n) =>
                      setState(() => _status = '纯数字：${_fmt(n)}'),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('科学计数法显示', [
            _demo(
              '有效数字 ≥15 位时以科学计数法显示，聚焦展开全数',
              SizedBox(
                width: 280,
                child: SemiInputNumber(
                  key: const ValueKey('inputnumber-scientific'),
                  scientificNotation: true,
                  // 17 significant digits; the double literal form keeps
                  // dart2js happy (JS cannot represent the integer exactly).
                  initialValue: 1.2345678901234568e17,
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
