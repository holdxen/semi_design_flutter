import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class BackTopPage extends StatefulWidget {
  const BackTopPage({super.key});

  @override
  State<BackTopPage> createState() => _BackTopPageState();
}

class _BackTopPageState extends State<BackTopPage> {
  String _status = '滚动内容区，超过阈值后右下角出现按钮；点击滚回顶部。';

  // 事件回传顺序记录（onClick，slider 的 events demo 模式）。
  final List<String> _events = [];

  // 各演示独立滚动容器（可见性/点击滚动各自联动）。
  final ScrollController _basicController = ScrollController();
  final ScrollController _customController = ScrollController();
  final ScrollController _thresholdController = ScrollController();
  final ScrollController _rtlController = ScrollController();

  @override
  void dispose() {
    _basicController.dispose();
    _customController.dispose();
    _thresholdController.dispose();
    _rtlController.dispose();
    super.dispose();
  }

  void _push(String event) {
    _events.add(event);
    if (_events.length > 6) _events.removeRange(0, _events.length - 6);
    _status = _events.join('；');
  }

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  /// 演示区限高 320（内容区内滚；BackTop 固定在演示盒右下角——★上游视口固定
  /// 的 Stack 宿主口径，见 docs 差异清单）。
  Widget _demo(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiText(label),
      const SizedBox(height: 6),
      SizedBox(height: 320, child: child),
      const SizedBox(height: 12),
    ],
  );

  /// 可滚长内容（各 section 高 300，滚过阈值即现按钮）。
  Widget _content({double height = 300, int sections = 6}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 1; i <= sections; i++)
        SizedBox(
          height: height,
          child: SemiText('内容段 $i —— 向下滚动试试，再点右下角按钮回来。'),
        ),
    ],
  );

  /// 滚动区 + BackTop（Stack 宿主：SemiBackTop 是 PositionedDirectional，
  /// 需挂在 Stack 直接子节点位）。[key] 供 example/test 度量锚点。
  Widget _stack({
    required Key key,
    required ScrollController controller,
    required SemiBackTop backTop,
  }) => Stack(
    key: key,
    children: [
      SingleChildScrollView(controller: controller, child: _content()),
      backTop,
    ],
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SemiText(_status, key: const ValueKey('backtop-status')),
          const SizedBox(height: 16),
          _section('基本用法', [
            _demo(
              '预设按钮（IconButton theme="light" + IconChevronUp）；'
              'visibilityHeight 400 / duration 450ms 缺省。',
              _stack(
                key: const ValueKey('backtop-basic'),
                controller: _basicController,
                backTop: SemiBackTop(
                  scrollController: _basicController,
                  onClick: () => setState(() => _push('onClick 基本用法')),
                ),
              ),
            ),
          ]),
          _section('自定义内容与主题偏移', [
            _demo(
              'children 自定义按钮 + SemiBackTopTheme 改 '
              'spacingBacktopRight/Bottom（32）。',
              SemiBackTopTheme(
                data: const SemiBackTopThemeData(
                  spacingBacktopRight: 32,
                  spacingBacktopBottom: 32,
                ),
                child: _stack(
                  key: const ValueKey('backtop-custom'),
                  controller: _customController,
                  backTop: SemiBackTop(
                    scrollController: _customController,
                    onClick: () => setState(() => _push('onClick 自定义')),
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xff0077fa),
                        shape: BoxShape.circle,
                      ),
                      child: const SemiIcon(
                        SemiIcons.arrowUp,
                        color: Color(0xffffffff),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),
          _section('阈值与动画时长', [
            _demo(
              'visibilityHeight 100（早现）+ duration 1000ms（慢滚回）。',
              _stack(
                key: const ValueKey('backtop-threshold'),
                controller: _thresholdController,
                backTop: SemiBackTop(
                  scrollController: _thresholdController,
                  visibilityHeight: 100,
                  duration: const Duration(milliseconds: 1000),
                  onClick: () => setState(() => _push('onClick 慢滚回')),
                ),
              ),
            ),
          ]),
          _section('RTL', [
            _demo(
              'Directionality.rtl——rtl.scss:7-8 `right: auto; left: '
              r'$spacing-backtop-right` → 按钮翻到左下角。',
              Directionality(
                textDirection: TextDirection.rtl,
                child: _stack(
                  key: const ValueKey('backtop-rtl'),
                  controller: _rtlController,
                  backTop: SemiBackTop(
                    scrollController: _rtlController,
                    onClick: () => setState(() => _push('onClick RTL')),
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
