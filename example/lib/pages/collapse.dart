import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class CollapsePage extends StatefulWidget {
  const CollapsePage({super.key});

  @override
  State<CollapsePage> createState() => _CollapsePageState();
}

class _CollapsePageState extends State<CollapsePage> {
  Set<String> _activeKeys = {'1'};
  List<String> _lastChanged = const [];

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  Widget _content(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: SemiText(text),
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('基础用法', [
            SemiCollapse(
              key: const ValueKey('basic-collapse'),
              defaultActiveKeys: const {'1'},
              children: [
                SemiCollapsePanel(
                  itemKey: '1',
                  header: 'This is panel header 1',
                  child: _content('Hi, bytedance dance dance.'),
                ),
                SemiCollapsePanel(
                  itemKey: '2',
                  header: 'This is panel header 2',
                  extra: const SemiText('extra'),
                  child: _content('第二个面板的内容，可同时展开多个面板。'),
                ),
                SemiCollapsePanel(
                  itemKey: '3',
                  header: const Text('Widget 标题'),
                  showArrow: false,
                  child: _content('header 可以是任意 Widget。'),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('手风琴', [
            const SemiText(
              '同时只展开一个；点击已展开的面板会全部收起。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            SemiCollapse(
              key: const ValueKey('accordion-collapse'),
              accordion: true,
              children: [
                SemiCollapsePanel(
                  itemKey: 'a',
                  header: '手风琴面板 A',
                  child: _content('内容 A'),
                ),
                SemiCollapsePanel(
                  itemKey: 'b',
                  header: '手风琴面板 B',
                  child: _content('内容 B'),
                ),
                SemiCollapsePanel(
                  itemKey: 'c',
                  header: '手风琴面板 C',
                  child: _content('内容 C'),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('受控模式', [
            SemiText(
              '当前展开：${_activeKeys.isEmpty ? '（无）' : _activeKeys.join('、')}'
              '　最近回调：${_lastChanged.isEmpty ? '（无）' : _lastChanged.join('、')}',
              key: const ValueKey('collapse-status'),
            ),
            const SizedBox(height: 12),
            SemiCollapse(
              key: const ValueKey('controlled-collapse'),
              activeKeys: _activeKeys,
              onActiveKeysChanged: (keys) => setState(() {
                _activeKeys = keys.toSet();
                _lastChanged = keys;
              }),
              children: [
                SemiCollapsePanel(
                  itemKey: '1',
                  header: '受控面板一',
                  child: _content('展开状态由父级维护。'),
                ),
                SemiCollapsePanel(
                  itemKey: '2',
                  header: '受控面板二',
                  child: _content('点击头部分区切换。'),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('生命周期', [
            const SemiText(
              'keepDOM 收起后保留内容状态；lazyRender 首次展开才构建。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            SemiCollapse(
              key: const ValueKey('keep-collapse'),
              keepDOM: true,
              children: [
                SemiCollapsePanel(
                  itemKey: 'keep',
                  header: 'keepDOM: true',
                  child: _content('收起后内容仍保持挂载（状态不丢失）。'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SemiCollapse(
              key: const ValueKey('lazy-collapse'),
              lazyRender: true,
              children: [
                SemiCollapsePanel(
                  itemKey: 'lazy',
                  header: 'lazyRender: true',
                  child: _content('首次展开时才构建此内容。'),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('自定义与禁用', [
            SemiCollapse(
              key: const ValueKey('custom-collapse'),
              expandIconPosition: SemiCollapseIconPosition.left,
              expandIcon: const SemiIcon(SemiIcons.chevronRight),
              collapseIcon: const SemiIcon(SemiIcons.chevronDown),
              clickHeaderToExpand: false,
              children: [
                SemiCollapsePanel(
                  itemKey: 'custom',
                  header: '箭头在左侧、点击头部不展开',
                  extra: const SemiText('仅点箭头'),
                  child: _content('clickHeaderToExpand: false'),
                ),
                const SemiCollapsePanel(
                  itemKey: 'disabled',
                  header: '禁用面板',
                  disabled: true,
                  child: Text('不可交互'),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('局部主题', [
            const SemiText(
              '标题紫色、内容绿色、分割线橙色、圆角 8。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            const SemiCollapseTheme(
              data: SemiCollapseThemeData(
                colorCollapseHeaderTextDefault: Color(0xff7b61ff),
                colorCollapseContentTextDefault: Color(0xff0a7a2f),
                colorCollapseItemBorderDefault: Color(0xffff8c00),
                radiusCollapseHeader: 8,
              ),
              child: SemiCollapse(
                key: ValueKey('theme-collapse'),
                defaultActiveKeys: {'theme'},
                children: [
                  SemiCollapsePanel(
                    itemKey: 'theme',
                    header: '局部主题面板',
                    child: Text('主题定制后的内容颜色。'),
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
