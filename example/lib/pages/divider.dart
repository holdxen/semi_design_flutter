import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class DividerPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SemiTitle('水平实线', heading: 3),
          SemiText('Semi Design 是一个设计系统。'),
          SemiDivider(margin: 12),
          SemiText('它定义了一套中后台设计与前端基础组件。'),
          SizedBox(height: 40),
          SemiTitle('水平虚线', heading: 3),
          SemiText('Semi Design 是一个设计系统。'),
          SemiDivider(dashed: true, margin: 12),
          SemiText('它定义了一套中后台设计与前端基础组件。'),
          SizedBox(height: 40),
          SemiTitle('垂直实线', heading: 3),
          Row(
            children: [
              SemiText('左'),
              SemiDivider(layout: SemiDividerLayout.vertical, margin: 12),
              SemiText('中'),
              SemiDivider(layout: SemiDividerLayout.vertical, margin: 12),
              SemiText('右'),
            ],
          ),
          SizedBox(height: 40),
          SemiTitle('垂直虚线', heading: 3),
          Row(
            children: [
              SemiText('左'),
              SemiDivider(
                layout: SemiDividerLayout.vertical,
                dashed: true,
                margin: 12,
              ),
              SemiText('中'),
              SemiDivider(
                layout: SemiDividerLayout.vertical,
                dashed: true,
                margin: 12,
              ),
              SemiText('右'),
            ],
          ),
          SizedBox(height: 40),
          SemiDivider(margin: 12, align: SemiDividerAlign.left, text: '这是居左文字'),
          SemiDivider(
            margin: 12,
            align: SemiDividerAlign.center,
            text: '这是居中文字',
          ),
          SemiDivider(
            margin: 12,
            align: SemiDividerAlign.right,
            text: '这是居右文字',
          ),
          SemiDivider(margin: 12, child: SemiIcon(SemiIcons.semiLogo)),
        ],
      ),
    );
  }
}
