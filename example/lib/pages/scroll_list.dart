import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class ScrollListPage extends StatefulWidget {
  const ScrollListPage({super.key});

  @override
  State<ScrollListPage> createState() => _ScrollListPageState();
}

class _ScrollListPageState extends State<ScrollListPage> {
  // 基本用法（官方 demo：上下午 / 时 / 分）。
  int _ap = 0;
  int _hour = 1;
  int _minute = 0;

  // normal 模式。
  int _normal = 0;

  // cycled 无限循环。
  int _cycled = 0;

  // transform / 禁用。
  int _transform = 1;

  // bodyHeight。
  int _short = 0;

  List<SemiScrollItemData> _range(
    int count, {
    int? disabled,
    String prefix = '',
  }) => [
    for (var i = 0; i < count; i++)
      SemiScrollItemData(value: i, text: '$prefix$i', disabled: i == disabled),
  ];

  Widget _demo(Widget child, String caption) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // 根宽随父约束（`width: 100%`）——demo 给定宽盒。
      SizedBox(width: 320, child: child),
      const SizedBox(height: 8),
      Text(caption, style: const TextStyle(color: Color(0xff8a8f99))),
    ],
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
          _section('基本用法（wheel 滚轮）', [
            _demo(
              SemiScrollList(
                header: const SemiText('无限滚动列表'),
                footer: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SemiButton(
                      'Ok',
                      size: SemiButtonSize.small,
                      type: SemiButtonType.primary,
                      onPressed: () {},
                    ),
                  ],
                ),
                children: [
                  SemiScrollItem(
                    type: 1,
                    list: const [
                      SemiScrollItemData(value: '上午'),
                      SemiScrollItemData(value: '下午'),
                    ],
                    selectedIndex: _ap,
                    onSelect: (sel) => setState(() => _ap = sel.index),
                  ),
                  SemiScrollItem(
                    type: 2,
                    cycled: true,
                    list: [
                      for (var h = 1; h <= 12; h++)
                        SemiScrollItemData(value: h, text: '$h'),
                    ],
                    selectedIndex: _hour,
                    onSelect: (sel) => setState(() => _hour = sel.index),
                  ),
                  SemiScrollItem(
                    type: 3,
                    cycled: true,
                    list: _range(60, disabled: 13),
                    selectedIndex: _minute,
                    onSelect: (sel) => setState(() => _minute = sel.index),
                  ),
                ],
              ),
              '滚轮选择 + header/footer（分钟列 13 禁用）',
            ),
          ]),
          _section('normal 模式', [
            _demo(
              SemiScrollList(
                children: [
                  SemiScrollItem(
                    mode: SemiScrollItemMode.normal,
                    list: _range(12, prefix: '条目 '),
                    selectedIndex: _normal,
                    onSelect: (sel) => setState(() => _normal = sel.index),
                  ),
                ],
              ),
              '点选列表（选中 $_normal）',
            ),
          ]),
          _section('cycled 无限循环', [
            _demo(
              SemiScrollList(
                children: [
                  SemiScrollItem(
                    cycled: true,
                    list: _range(24, prefix: '项 '),
                    selectedIndex: _cycled,
                    onSelect: (sel) => setState(() => _cycled = sel.index),
                  ),
                ],
              ),
              '无限滚动（当前 $_cycled）',
            ),
          ]),
          _section('transform 与禁用项', [
            _demo(
              SemiScrollList(
                children: [
                  SemiScrollItem(
                    mode: SemiScrollItemMode.normal,
                    list: _range(6, disabled: 3, prefix: '行 '),
                    selectedIndex: _transform,
                    transform: (value, text) => '已选：$text',
                    onSelect: (sel) => setState(() => _transform = sel.index),
                  ),
                ],
              ),
              '选中行过 transform（第 4 项禁用）',
            ),
          ]),
          _section('bodyHeight', [
            _demo(
              SemiScrollList(
                bodyHeight: 180,
                children: [
                  SemiScrollItem(
                    mode: SemiScrollItemMode.normal,
                    list: _range(6, prefix: 'h '),
                    selectedIndex: _short,
                    onSelect: (sel) => setState(() => _short = sel.index),
                  ),
                ],
              ),
              'bodyHeight: 180（缺省 300）',
            ),
          ]),
        ],
      ),
    );
  }
}
