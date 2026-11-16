import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class BannerPage extends StatelessWidget {
  const BannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SemiTitle('四种类型', heading: 3),
          SemiBanner(
            type: SemiBannerType.info,
            title: '信息提示的文案信息',
            description: '信息提示的辅助文案信息',
          ),
          SizedBox(height: 12),
          SemiBanner(
            type: SemiBannerType.warning,
            title: '警告提示的文案信息',
            description: '警告提示的辅助文案信息',
          ),
          SizedBox(height: 12),
          SemiBanner(
            type: SemiBannerType.success,
            title: '成功提示的文案信息',
            description: '成功提示的辅助文案信息',
          ),
          SizedBox(height: 12),
          SemiBanner(
            type: SemiBannerType.danger,
            title: '危险提示的文案信息',
            description: '危险提示的辅助文案信息',
          ),
          SizedBox(height: 40),
          SemiTitle('非全屏模式（in-container）', heading: 3),
          SemiBanner(
            fullMode: false,
            title: '新版本已发布',
            description: '本次更新优化了若干体验问题，推荐升级。',
          ),
          SizedBox(height: 12),
          SemiBanner(
            fullMode: false,
            bordered: true,
            type: SemiBannerType.warning,
            title: '即将到期',
            description: '当前配置的有效期仅剩 3 天。',
          ),
          SizedBox(height: 40),
          SemiTitle('仅标题 / 仅描述', heading: 3),
          SemiBanner(type: SemiBannerType.success, title: '部署完成'),
          SizedBox(height: 12),
          SemiBanner(type: SemiBannerType.info, description: '这是一条只有描述的横幅。'),
          SizedBox(height: 40),
          SemiTitle('自定义图标与关闭', heading: 3),
          SemiBanner(
            type: SemiBannerType.danger,
            icon: SemiIcon(SemiIcons.close, color: Color(0xffd5272b)),
            title: '自定义图标',
            description: 'icon 参数替换类型默认图标。',
          ),
          SizedBox(height: 12),
          SemiBanner(
            type: SemiBannerType.info,
            title: '不可关闭',
            closable: false,
            description: 'closable: false 隐藏关闭按钮。',
          ),
          SizedBox(height: 40),
          SemiTitle('额外内容', heading: 3),
          SemiBanner(
            fullMode: false,
            type: SemiBannerType.warning,
            title: '发现新版本 v2.0',
            description: '更新后需要重启应用。',
            extra: Row(
              children: [
                SemiButton('立即更新', type: SemiButtonType.primary),
                SizedBox(width: 8),
                SemiButton('稍后提醒', variant: SemiButtonVariant.borderless),
              ],
            ),
          ),
          SizedBox(height: 40),
          SemiTitle('数字 0 内容渲染', heading: 3),
          SemiBanner(type: SemiBannerType.info, title: 0, description: 0),
        ],
      ),
    );
  }
}
