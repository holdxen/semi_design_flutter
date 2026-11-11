import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  String _status = '点击可交互的节点查看事件。';

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
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
            const SemiTimeline(
              key: ValueKey('basic-timeline'),
              semanticsLabel: '发布流程',
              items: [
                SemiTimelineItemData(
                  content: '创建发布单',
                  time: '2026-11-11 09:00',
                  type: SemiTimelineItemType.ongoing,
                ),
                SemiTimelineItemData(
                  content: '构建镜像',
                  extra: '耗时 12 分钟',
                  time: '2026-11-11 09:30',
                  type: SemiTimelineItemType.success,
                ),
                SemiTimelineItemData(
                  content: '灰度验证',
                  time: '2026-11-11 10:00',
                  type: SemiTimelineItemType.warning,
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('布局模式', [
            const SemiText('right', type: SemiTextType.secondary),
            const SemiTimeline(
              key: ValueKey('right-timeline'),
              mode: SemiTimelineMode.right,
              items: [
                SemiTimelineItemData(content: '右侧节点一', time: '09:00'),
                SemiTimelineItemData(content: '右侧节点二', time: '10:00'),
              ],
            ),
            const SizedBox(height: 24),
            const SemiText('center', type: SemiTextType.secondary),
            const SemiTimeline(
              key: ValueKey('center-timeline'),
              mode: SemiTimelineMode.center,
              items: [
                SemiTimelineItemData(content: '居中节点一', time: '09:00'),
                SemiTimelineItemData(content: '居中节点二', time: '10:00'),
                SemiTimelineItemData(content: '居中节点三', time: '11:00'),
              ],
            ),
            const SizedBox(height: 24),
            const SemiText('alternate', type: SemiTextType.secondary),
            const SemiTimeline(
              key: ValueKey('alternate-timeline'),
              mode: SemiTimelineMode.alternate,
              items: [
                SemiTimelineItemData(content: '交替节点一（左）', time: '09:00'),
                SemiTimelineItemData(content: '交替节点二（右）', time: '10:00'),
                SemiTimelineItemData(content: '交替节点三（左）', time: '11:00'),
                SemiTimelineItemData(
                  content: '显式 position 覆盖（右）',
                  position: SemiTimelinePosition.right,
                  time: '12:00',
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('节点类型', [
            const SemiTimeline(
              key: ValueKey('types-timeline'),
              items: [
                SemiTimelineItemData(
                  content: 'normal 默认',
                  type: SemiTimelineItemType.normal,
                ),
                SemiTimelineItemData(
                  content: 'ongoing 进行中',
                  type: SemiTimelineItemType.ongoing,
                ),
                SemiTimelineItemData(
                  content: 'success 成功',
                  type: SemiTimelineItemType.success,
                ),
                SemiTimelineItemData(
                  content: 'warning 警告',
                  type: SemiTimelineItemType.warning,
                ),
                SemiTimelineItemData(
                  content: 'error 错误',
                  type: SemiTimelineItemType.error,
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('自定义节点', [
            const SemiTimeline(
              key: ValueKey('custom-timeline'),
              items: [
                SemiTimelineItemData(
                  content: '自定义图标节点',
                  time: '09:00',
                  dot: SemiIcon(SemiIcons.star),
                ),
                SemiTimelineItemData(
                  content: '自定义颜色节点',
                  time: '10:00',
                  color: Color(0xFFFFB4B4),
                ),
                SemiTimelineItemData(
                  content: 'color 覆盖 dot 背景（上游怪癖）',
                  time: '11:00',
                  color: Color(0xFFB4D8FF),
                  dot: SemiIcon(SemiIcons.checkCircleStroked),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('交互与元数据', [
            SemiText(_status, key: const ValueKey('timeline-status')),
            const SizedBox(height: 12),
            SemiTimeline(
              key: const ValueKey('interactive-timeline'),
              items: [
                SemiTimelineItemData(
                  content: '点击我',
                  time: 0,
                  onTap: () =>
                      setState(() => _status = '点击了「点击我」，time: 0 仍会渲染。'),
                ),
                SemiTimelineItemData(
                  content: '也可以点击',
                  time: '09:00',
                  extra: 'extra 元数据',
                  onTap: () => setState(() => _status = '点击了「也可以点击」。'),
                ),
                const SemiTimelineItemData(
                  content: 'time 为 false 不渲染',
                  time: false,
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('局部主题', [
            const SemiText(
              '进行中节点紫色、内容间距 32、节点间距 32。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            const SemiTimelineTheme(
              data: SemiTimelineThemeData(
                colorTimelineDotDefaultBgDefault: Color(0xff7b61ff),
                spacingTimelineContentMarginLeft: 32,
                spacingTimelineItemPaddingBottom: 32,
              ),
              child: SemiTimeline(
                key: ValueKey('theme-timeline'),
                items: [
                  SemiTimelineItemData(
                    content: '主题定制节点一',
                    time: '09:00',
                    type: SemiTimelineItemType.ongoing,
                  ),
                  SemiTimelineItemData(content: '主题定制节点二', time: '10:00'),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
