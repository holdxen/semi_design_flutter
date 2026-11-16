import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class OverflowListPage extends StatefulWidget {
  const OverflowListPage({super.key});

  @override
  State<OverflowListPage> createState() => _OverflowListPageState();
}

class _OverflowListPageState extends State<OverflowListPage> {
  double _width = 100;

  static const _items = [
    'alarm',
    'bookmark',
    'camera',
    'duration',
    'edit',
    'folder',
  ];

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  Widget _demo(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiText(label),
      const SizedBox(height: 6),
      child,
      const SizedBox(height: 12),
    ],
  );

  Widget _item(String text, int index) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: SemiTag(text, key: ValueKey('overflow-item-$text')),
  );

  Widget? _overflow(List<String> items) => items.isEmpty
      ? null
      : Padding(
          padding: const EdgeInsets.only(left: 8),
          child: SemiTag('+${items.length}', key: const ValueKey('overflow-n')),
        );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('折叠模式 - 默认', [
            SemiSlider(
              key: const ValueKey('overflow-width'),
              value: _width,
              min: 10,
              max: 100,
              step: 1,
              onChanged: (value) =>
                  setState(() => _width = (value! as num).toDouble()),
            ),
            const SizedBox(height: 16),
            _demo(
              '拖动滑块改变容器宽度，放不下的项折叠为 "+N"：',
              SizedBox(
                width: _width * 4,
                child: SemiOverflowList<String>(
                  key: const ValueKey('overflow-basic'),
                  items: _items,
                  overflowRenderer: _overflow,
                  visibleItemRenderer: _item,
                  onOverflow: (items) {},
                ),
              ),
            ),
          ]),
          _section('折叠模式 - 方向', [
            _demo(
              'collapseFrom: start —— 头部折叠，保留尾部项：',
              SizedBox(
                width: _width * 4,
                child: SemiOverflowList<String>(
                  key: const ValueKey('overflow-from-start'),
                  items: _items,
                  collapseFrom: SemiOverflowListCollapseFrom.start,
                  overflowRenderer: _overflow,
                  visibleItemRenderer: _item,
                ),
              ),
            ),
          ]),
          _section('折叠模式 - 最小展示的数目', [
            _demo(
              'minVisibleItems: 3 —— 至少保留 3 个可见项（超宽时整行溢出可见）：',
              SizedBox(
                width: 160,
                child: SemiOverflowList<String>(
                  key: const ValueKey('overflow-min-visible'),
                  items: _items,
                  minVisibleItems: 3,
                  overflowRenderer: _overflow,
                  visibleItemRenderer: _item,
                ),
              ),
            ),
          ]),
          _section('滚动模式', [
            _demo(
              'renderMode: scroll —— 横向滚动，视口外的项进两端指示器：',
              SizedBox(
                width: 320,
                child: SemiOverflowList<String>(
                  key: const ValueKey('overflow-scroll'),
                  items: _items,
                  renderMode: SemiOverflowListRenderMode.scroll,
                  scrollOverflowRenderer: (start, end) => [
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: SemiTag(
                        '←${start.length}',
                        key: const ValueKey('overflow-scroll-start'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: SemiTag(
                        '${end.length}→',
                        key: const ValueKey('overflow-scroll-end'),
                      ),
                    ),
                  ],
                  visibleItemRenderer: _item,
                  onVisibleStateChange: (state) {},
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
