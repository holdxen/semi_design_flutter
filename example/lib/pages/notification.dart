import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _seq = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SemiTitle('四种类型', heading: 3),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SemiButton(
                '通知',
                onPressed: () => SemiNotification.open(
                  title: '这是一条通知标题',
                  content: '这是一条通知的文案内容。',
                ),
              ),
              SemiButton(
                '信息',
                onPressed: () => SemiNotification.info(
                  title: '这是一条信息通知的标题',
                  content: '信息通知的辅助文案信息。',
                ),
              ),
              SemiButton(
                '成功',
                onPressed: () =>
                    SemiNotification.success(title: '保存成功', content: '设置已更新。'),
              ),
              SemiButton(
                '警告',
                onPressed: () =>
                    SemiNotification.warning(title: '警告', content: '磁盘空间即将不足。'),
              ),
              SemiButton(
                '错误',
                onPressed: () => SemiNotification.error(
                  title: '上传失败',
                  content: '请检查网络连接后重试。',
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const SemiTitle('位置（六向 placement）', heading: 3),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final position in SemiNotificationPosition.values)
                SemiButton(
                  position.name,
                  onPressed: () => SemiNotification.info(
                    title: '${position.name} 位置',
                    content: '按 placement 锚定的通知列表。',
                    position: position,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 40),
          const SemiTitle('light 主题', heading: 3),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final (label, type) in [
                ('信息', SemiNotificationType.info),
                ('成功', SemiNotificationType.success),
                ('警告', SemiNotificationType.warning),
                ('错误', SemiNotificationType.error),
              ])
                SemiButton(
                  label,
                  onPressed: () => switch (type) {
                    SemiNotificationType.info => SemiNotification.info(
                      title: '信息通知',
                      content: 'light 语义色浅底 + 描边。',
                      variant: SemiNotificationVariant.light,
                    ),
                    SemiNotificationType.success => SemiNotification.success(
                      title: '成功通知',
                      content: 'light 语义色浅底 + 描边。',
                      variant: SemiNotificationVariant.light,
                    ),
                    SemiNotificationType.warning => SemiNotification.warning(
                      title: '警告通知',
                      content: 'light 语义色浅底 + 描边。',
                      variant: SemiNotificationVariant.light,
                    ),
                    SemiNotificationType.error => SemiNotification.error(
                      title: '错误通知',
                      content: 'light 语义色浅底 + 描边。',
                      variant: SemiNotificationVariant.light,
                    ),
                    SemiNotificationType.normal => SemiNotification.open(
                      title: '普通通知',
                      variant: SemiNotificationVariant.light,
                    ),
                  },
                ),
            ],
          ),
          const SizedBox(height: 40),
          const SemiTitle('时长 / 悬停 / 更新 / 关闭', heading: 3),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SemiButton(
                '8 秒后自动关闭（悬停暂停）',
                onPressed: () => SemiNotification.info(
                  title: '自动关闭',
                  content: '悬停卡片暂停计时，移出恢复。',
                  duration: const Duration(seconds: 8),
                ),
              ),
              SemiButton(
                '不自动关闭',
                onPressed: () => SemiNotification.info(
                  title: '固定通知',
                  content: 'duration 为零——仅手动关闭。',
                  duration: Duration.zero,
                ),
              ),
              SemiButton(
                '同 id 更新',
                onPressed: () {
                  _seq += 1;
                  SemiNotification.info(
                    id: 'demo-update',
                    title: '第 $_seq 次更新',
                    content: '同 id 再入即就地更新并重启计时。',
                    duration: const Duration(seconds: 5),
                  );
                },
              ),
              SemiButton(
                '关闭同 id 通知',
                variant: SemiButtonVariant.borderless,
                onPressed: () => SemiNotification.close('demo-update'),
              ),
              SemiButton(
                'destroyAll',
                variant: SemiButtonVariant.borderless,
                onPressed: () => SemiNotification.destroyAll(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
