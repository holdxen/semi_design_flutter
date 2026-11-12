import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class RatingPage extends StatefulWidget {
  const RatingPage({super.key});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  String _status = '悬浮或点击星星查看事件。';

  // 文案展现（受控 + tooltips）。
  double _textValue = 0;
  static const List<String> _desc = [
    'terrible',
    'bad',
    'normal',
    'good',
    'wonderful',
  ];

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  /// Rating rows are fixed-width; scroll sideways on narrow screens instead
  /// of overflowing.
  Widget _demo(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiText(label),
      const SizedBox(height: 6),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: child),
      const SizedBox(height: 12),
    ],
  );

  /// Callbacks report `double`; drop the trailing `.0` for whole values.
  String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : '$v';

  void _log(double value) => setState(() => _status = '值：${_fmt(value)}');
  void _logHover(double? value) =>
      setState(() => _status = value == null ? '离开评分条' : '悬浮：${_fmt(value)}');

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('基本用法', [
            SemiText(_status, key: const ValueKey('rating-status')),
            const SizedBox(height: 12),
            _demo(
              '默认尺寸',
              SemiRating(
                key: const ValueKey('rating-basic'),
                defaultValue: 5,
                onChanged: _log,
                onHoverChange: _logHover,
              ),
            ),
            _demo(
              "size='small'",
              SemiRating(
                key: const ValueKey('rating-small'),
                size: SemiRatingSize.small,
                defaultValue: 5,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('半星', [
            _demo(
              'allowHalf，值 3.5',
              SemiRating(
                key: const ValueKey('rating-half'),
                allowHalf: true,
                defaultValue: 3.5,
                onChanged: _log,
              ),
            ),
            _demo(
              '任意小数展示（3.65 裁切 65%）',
              SemiRating(
                key: const ValueKey('rating-half-decimal'),
                allowHalf: true,
                defaultValue: 3.65,
                disabled: true,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('只读', [
            SemiRating(
              key: const ValueKey('rating-readonly'),
              defaultValue: 3,
              disabled: true,
            ),
          ]),
          const SizedBox(height: 40),
          _section('点击清除', [
            _demo(
              'allowClear=true（默认）：再次点击同值清 0',
              SemiRating(
                key: const ValueKey('rating-clear'),
                defaultValue: 3,
                onChanged: _log,
              ),
            ),
            _demo(
              'allowClear=false：再次点击同值保持',
              SemiRating(
                key: const ValueKey('rating-no-clear'),
                allowClear: false,
                defaultValue: 3,
                onChanged: _log,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('文案展现', [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SemiText(
                    _textValue == 0
                        ? 'How was the help you received: '
                        : 'How was the help you received: ${_desc[_textValue.toInt() - 1]}',
                    key: const ValueKey('rating-text-desc'),
                  ),
                  const SizedBox(width: 12),
                  SemiRating(
                    key: const ValueKey('rating-text'),
                    value: _textValue,
                    tooltips: _desc,
                    onChanged: (value) => setState(() => _textValue = value),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('自定义', [
            _demo(
              '自定义图标',
              SemiRating(
                key: const ValueKey('rating-custom-heart'),
                character: const SemiIcon(
                  SemiIcons.likeHeart,
                  color: Color(0xfffb6052),
                ),
                defaultValue: 3,
              ),
            ),
            _demo(
              '数字尺寸 + 半星',
              SemiRating(
                key: const ValueKey('rating-custom-big'),
                size: 48.0,
                allowHalf: true,
                character: const SemiIcon(
                  SemiIcons.likeHeart,
                  customSize: 48,
                  color: Color(0xfffb6052),
                ),
                defaultValue: 3.5,
              ),
            ),
            _demo(
              '自定义字符',
              SemiRating(
                key: const ValueKey('rating-custom-text'),
                size: 18.0,
                character: const Text('赞', style: TextStyle(fontSize: 18)),
                defaultValue: 3,
              ),
            ),
            _demo(
              'count=10',
              SemiRating(
                key: const ValueKey('rating-count10'),
                count: 10,
                defaultValue: 6,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
