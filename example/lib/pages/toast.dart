import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class ToastPage extends StatelessWidget {
  const ToastPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SemiTitle('四种类型 + 默认', heading: 3),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SemiButton(
                'Info',
                onPressed: () =>
                    SemiToast.info(content: '这是一条信息提示的文案'),
              ),
              SemiButton(
                'Success',
                onPressed: () => SemiToast.success(content: '保存成功'),
              ),
              SemiButton(
                'Warning',
                onPressed: () => SemiToast.warning(content: '磁盘空间不足'),
              ),
              SemiButton(
                'Error',
                onPressed: () => SemiToast.error(content: '上传失败，请重试'),
              ),
              SemiButton(
                '默认（无图标）',
                onPressed: () => SemiToast.show(content: '这是一条默认提示'),
              ),
            ],
          ),
          SizedBox(height: 40),
          SemiTitle('Light 主题', heading: 3),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SemiButton(
                'Light Warning',
                onPressed: () => SemiToast.warning(
                  content: '浅色样式的警告提示',
                  theme: SemiToastThemeMode.light,
                ),
              ),
              SemiButton(
                'Light Success',
                onPressed: () => SemiToast.success(
                  content: '浅色样式的成功提示',
                  theme: SemiToastThemeMode.light,
                ),
              ),
            ],
          ),
          SizedBox(height: 40),
          SemiTitle('自动关闭时长', heading: 3),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SemiButton(
                '默认 3 秒',
                onPressed: () => SemiToast.info(content: '3 秒后自动关闭'),
              ),
              SemiButton(
                '1 秒',
                onPressed: () =>
                    SemiToast.info(content: '1 秒后自动关闭', duration: 1),
              ),
              SemiButton(
                '不自动关闭',
                onPressed: () => SemiToast.info(
                  content: 'duration: 0，点击关闭按钮关闭',
                  duration: 0,
                ),
              ),
            ],
          ),
          SizedBox(height: 40),
          SemiTitle('堆叠与同 id 更新', heading: 3),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SemiButton(
                '连续三条',
                onPressed: () {
                  SemiToast.info(content: '第一条提示', duration: 0);
                  SemiToast.info(content: '第二条提示', duration: 0);
                  SemiToast.info(content: '第三条提示', duration: 0);
                },
              ),
              SemiButton(
                '同 id 更新',
                onPressed: () {
                  SemiToast.info(
                    id: 'demo',
                    content: '同 id 更新前的提示',
                    duration: 0,
                  );
                  SemiToast.success(
                    id: 'demo',
                    content: '同 id 更新后的提示',
                    duration: 0,
                  );
                },
              ),
              SemiButton('关闭全部', onPressed: SemiToast.destroyAll),
            ],
          ),
          SizedBox(height: 40),
          SemiTitle('卡组模式（stack）', heading: 3),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SemiButton(
                '三条叠牌',
                onPressed: () {
                  SemiToast.info(
                    content: '卡组第一条',
                    duration: 0,
                    stack: true,
                  );
                  SemiToast.info(
                    content: '卡组第二条',
                    duration: 0,
                    stack: true,
                  );
                  SemiToast.info(
                    content: '卡组第三条',
                    duration: 0,
                    stack: true,
                  );
                },
              ),
              SemiButton('关闭全部', onPressed: SemiToast.destroyAll),
            ],
          ),
          SizedBox(height: 40),
          SemiTitle('自定义与关闭行为', heading: 3),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SemiButton(
                '自定义图标',
                onPressed: () => SemiToast.info(
                  content: '自定义 icon 参数替换类型图标',
                  icon: const SemiIcon(SemiIcons.star, color: Color(0xfffaa600)),
                ),
              ),
              SemiButton(
                '无关闭按钮',
                onPressed: () => SemiToast.info(
                  content: 'showClose: false 隐藏关闭按钮',
                  showClose: false,
                  duration: 0,
                ),
              ),
              SemiButton(
                '自定义宽高与回调',
                onPressed: () => SemiToast.success(
                  content: 'textMaxWidth: 200，关闭时回调 onClose',
                  textMaxWidth: 200,
                  duration: 0,
                  onClose: () => debugPrint('toast closed'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
