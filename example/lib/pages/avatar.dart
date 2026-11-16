import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

/// Avatar gallery：上游 Semi Avatar 演示的 Flutter 对照页。
///
/// 图片源默认 assets/images/avatar.png（上游 theme demo images）；测试可注入
/// 同步 ImageProvider（fake async 内无 codec，见 avatar_page_test.dart）。
class AvatarPage extends StatefulWidget {
  const AvatarPage({super.key, this.avatarImage});

  final ImageProvider? avatarImage;

  @override
  State<AvatarPage> createState() => _AvatarPageState();
}

class _AvatarPageState extends State<AvatarPage> {
  int _taps = 0;
  SemiAvatarOverlapFrom _overlapFrom = SemiAvatarOverlapFrom.start;

  ImageProvider get _image =>
      widget.avatarImage ?? const AssetImage('assets/images/avatar.png');

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('基础用法', [
            _demo(
              '文字头像（gap 自动缩放）与自定义内容',
              const Wrap(
                spacing: 24,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SemiAvatar(text: 'AB'),
                  SemiAvatar(text: '知'),
                  SemiAvatar(text: 'ABCDEFGH'),
                  SemiAvatar(
                    color: SemiAvatarColor.blue,
                    child: SemiIcon(SemiIcons.user, customSize: 24),
                  ),
                ],
              ),
            ),
            _demo(
              '图片头像（object-fit: cover；加载失败回落文字）',
              Row(
                children: [
                  SemiAvatar(src: _image, alt: '演示头像', text: 'AB'),
                  const SizedBox(width: 24),
                  SemiAvatar(
                    src: _image,
                    size: SemiAvatarSize.large,
                    shape: SemiAvatarShape.square,
                    text: 'AB',
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _section('尺寸与形状', [
            _demo(
              'extraExtraSmall / extraSmall / small / normal / medium / '
              'large / extraLarge + square',
              Wrap(
                key: const ValueKey('avatar-sizes'),
                spacing: 24,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: const [
                  SemiAvatar(size: SemiAvatarSize.extraExtraSmall, text: 'A'),
                  SemiAvatar(size: SemiAvatarSize.extraSmall, text: 'AB'),
                  SemiAvatar(size: SemiAvatarSize.small, text: 'AB'),
                  SemiAvatar(size: SemiAvatarSize.normal, text: 'AB'),
                  SemiAvatar(size: SemiAvatarSize.medium, text: 'AB'),
                  SemiAvatar(size: SemiAvatarSize.large, text: 'AB'),
                  SemiAvatar(size: SemiAvatarSize.extraLarge, text: 'AB'),
                  SemiAvatar(
                    size: SemiAvatarSize.large,
                    shape: SemiAvatarShape.square,
                    text: 'AB',
                  ),
                ],
              ),
            ),
            _demo(
              'customSize 自由尺寸（无尺寸类：square 圆角 0）',
              const Wrap(
                spacing: 24,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SemiAvatar(customSize: 64, text: 'AB'),
                  SemiAvatar(
                    customSize: 64,
                    shape: SemiAvatarShape.square,
                    text: 'AB',
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _section('颜色', [
            _demo(
              '16 色（palette level-3 背景 + 白字）与 white（无样式 quirk）',
              Wrap(
                key: const ValueKey('avatar-colors'),
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final color in SemiAvatarColor.values)
                    SemiAvatar(color: color, text: 'A'),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _section('交互', [
            _demo(
              '可点击（Enter 触发、Escape 失焦、focus 轮廓）',
              Row(
                children: [
                  SemiAvatar(
                    key: const ValueKey('avatar-tap'),
                    text: 'AB',
                    onTap: () => setState(() => _taps++),
                  ),
                  const SizedBox(width: 16),
                  SemiText('点击次数：$_taps', key: const ValueKey('avatar-tap-count')),
                ],
              ),
            ),
            _demo(
              'hoverMask（鼠标悬浮显示遮罩）',
              SemiAvatar(
                text: 'AB',
                size: SemiAvatarSize.large,
                hoverMask: const DecoratedBox(
                  decoration: BoxDecoration(color: Color(0x80000000)),
                  child: Center(
                    child: SemiText('查看', style: TextStyle(color: Color(0xffffffff))),
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _section('描边环与动效', [
            _demo(
              'border 额外描边环（motion 呼吸环 800ms）',
              const Wrap(
                spacing: 32,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SemiAvatar(text: 'AB', border: SemiAvatarBorder()),
                  SemiAvatar(
                    text: 'AB',
                    border: SemiAvatarBorder(motion: true),
                  ),
                ],
              ),
            ),
            _demo(
              'contentMotion 内容脉冲（1000ms scale 1→0.9→1）',
              const SemiAvatar(text: 'AB', contentMotion: true),
            ),
          ]),
          const SizedBox(height: 24),
          _section('Slot', [
            _demo(
              'topSlot 盾形角标（仅 circle、非 extra-extra-small）',
              const Wrap(
                spacing: 32,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SemiAvatar(
                    text: 'AB',
                    topSlot: SemiAvatarTopSlot(text: Text('新')),
                  ),
                  SemiAvatar(
                    size: SemiAvatarSize.large,
                    topSlot: SemiAvatarTopSlot(text: Text('NEW')),
                  ),
                ],
              ),
            ),
            _demo(
              'bottomSlot（circle / square，骑底边）',
              const Wrap(
                spacing: 32,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SemiAvatar(
                    text: 'AB',
                    bottomSlot: SemiAvatarBottomSlot(text: Text('9')),
                  ),
                  SemiAvatar(
                    size: SemiAvatarSize.large,
                    bottomSlot: SemiAvatarBottomSlot(
                      shape: SemiAvatarShape.square,
                      text: Text('VIP'),
                    ),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _section('头像组', [
            SemiButton(
              '叠压方向：${_overlapFrom == SemiAvatarOverlapFrom.start ? 'start（首项在上）' : 'end（末项在上）'}',
              key: const ValueKey('avatar-group-toggle'),
              onPressed: () => setState(
                () => _overlapFrom = _overlapFrom == SemiAvatarOverlapFrom.start
                    ? SemiAvatarOverlapFrom.end
                    : SemiAvatarOverlapFrom.start,
              ),
            ),
            const SizedBox(height: 12),
            _demo(
              '叠压（组内 size/shape 由组统一决定）',
              SemiAvatarGroup(
                key: const ValueKey('avatar-group'),
                overlapFrom: _overlapFrom,
                children: const [
                  SemiAvatar(text: 'A', color: SemiAvatarColor.blue),
                  SemiAvatar(text: 'B', color: SemiAvatarColor.green),
                  SemiAvatar(text: 'C', color: SemiAvatarColor.orange),
                  SemiAvatar(text: 'D', color: SemiAvatarColor.purple),
                ],
              ),
            ),
            _demo(
              'maxCount 折叠 +N',
              const SemiAvatarGroup(
                maxCount: 2,
                children: [
                  SemiAvatar(text: 'A'),
                  SemiAvatar(text: 'B'),
                  SemiAvatar(text: 'C'),
                  SemiAvatar(text: 'D'),
                ],
              ),
            ),
            _demo(
              'renderMore 自定义折叠',
              SemiAvatarGroup(
                maxCount: 1,
                renderMore: (restNumber, rest) => SemiAvatar(
                  text: '更多 $restNumber',
                  backgroundColor: const Color(0xffcccccc),
                ),
                children: const [
                  SemiAvatar(text: 'A'),
                  SemiAvatar(text: 'B'),
                  SemiAvatar(text: 'C'),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
