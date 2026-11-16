import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class BadgePage extends StatelessWidget {
  const BadgePage({super.key});

  /// Avatar 立牌替身（Avatar 未移植）：42x42 灰底圆角块。
  Widget _box(String label) => Builder(
    builder: (context) => Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: SemiTheme.of(context).colors.colorFill0,
        borderRadius: BorderRadius.circular(4),
      ),
      child: SemiText(label),
    ),
  );

  Widget _caption(String text) => SemiText(text, type: SemiTextType.secondary);

  Widget _demo(Widget badge, String caption) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [badge, const SizedBox(height: 8), _caption(caption)],
  );

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      Wrap(spacing: 32, runSpacing: 24, children: children),
      const SizedBox(height: 40),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('基本用法', [
            _demo(SemiBadge(count: 5, child: _box('')), '数字'),
            _demo(SemiBadge(count: 99, child: _box('')), '多位数字'),
            _demo(SemiBadge(count: '新', child: _box('')), '文本'),
            _demo(SemiBadge(dot: true, child: _box('')), '红点'),
            _demo(
              SemiBadge(dot: true, type: SemiBadgeType.danger, child: _box('')),
              '红点 + 类型',
            ),
          ]),
          _section('独立展示（无 child）', [
            _demo(const SemiBadge(count: 12), '数字'),
            _demo(const SemiBadge(count: '99+'), '文本'),
            _demo(const SemiBadge(dot: true, type: SemiBadgeType.danger), '红点'),
          ]),
          _section('数字溢出（overflowCount）', [
            _demo(
              SemiBadge(count: 120, overflowCount: 99, child: _box('')),
              '120 → 99+',
            ),
            _demo(
              SemiBadge(count: 5, overflowCount: 99, child: _box('')),
              '5（未超限）',
            ),
            _demo(
              const SemiBadge(count: 0, child: SizedBox(width: 42, height: 42)),
              '0 照常显示',
            ),
          ]),
          _section('六种类型（solid）', [
            for (final type in SemiBadgeType.values)
              _demo(
                SemiBadge(count: 8, type: type, child: _box('')),
                type.name,
              ),
          ]),
          _section('三种填充（variant，上游 theme）', [
            for (final variant in SemiBadgeVariant.values)
              _demo(
                SemiBadge(
                  count: 8,
                  type: SemiBadgeType.danger,
                  variant: variant,
                  child: _box(''),
                ),
                variant.name,
              ),
          ]),
          _section('四角锚定（position）', [
            for (final position in SemiBadgePosition.values)
              _demo(
                SemiBadge(
                  dot: true,
                  type: SemiBadgeType.primary,
                  position: position,
                  child: _box(''),
                ),
                position.name,
              ),
          ]),
          _section('自定义内容（custom，自带样式）', [
            _demo(
              SemiBadge(
                count: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff00b21e),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Text(
                    '促',
                    style: TextStyle(color: Color(0xffffffff), fontSize: 12),
                  ),
                ),
                child: _box(''),
              ),
              'Widget count',
            ),
            _demo(
              SemiBadge(
                count: const Text('VIP'),
                type: SemiBadgeType.danger,
                child: _box(''),
              ),
              'custom 不吃 type/variant 色',
            ),
          ]),
        ],
      ),
    );
  }
}
