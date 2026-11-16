import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class CarouselPage extends StatefulWidget {
  const CarouselPage({super.key});

  @override
  State<CarouselPage> createState() => _CarouselPageState();
}

class _CarouselPageState extends State<CarouselPage> {
  final SemiCarouselController _controller = SemiCarouselController();
  final List<String> _events = [];
  String _status = '点击箭头 / 指示器 / 控制器按钮，事件写入此行。';

  void _push(String event) {
    _events.add(event);
    if (_events.length > 6) _events.removeRange(0, _events.length - 6);
    setState(() => _status = _events.join('；'));
  }

  static const List<Color> _palette = [
    Color(0xFF6A5ACD),
    Color(0xFF20B2AA),
    Color(0xFFCD5C5C),
  ];

  static List<Widget> _slides([List<String> labels = const ['1', '2', '3']]) =>
      [
        for (var i = 0; i < labels.length; i++)
          ColoredBox(
            color: _palette[i % _palette.length],
            child: Center(
              child: SemiText(
                '第 ${labels[i]} 屏',
                style: const TextStyle(fontSize: 22, color: Color(0xFFFFFFFF)),
              ),
            ),
          ),
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
      SizedBox(width: 640, height: 200, child: child),
      const SizedBox(height: 16),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SemiText(_status, key: const ValueKey('carousel-status')),
          const SizedBox(height: 24),
          _section('基础（slide + 自动播放）', [
            _demo(
              '2s 间隔自动播放，hover 400ms 暂停',
              SemiCarousel(
                key: const ValueKey('carousel-basic'),
                children: _slides(),
                onChange: (index, previous) =>
                    _push('basic $previous -> $index'),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _section('切换动画（fade）', [
            _demo(
              'fade + 自定义箭头图标',
              SemiCarousel(
                key: const ValueKey('carousel-fade'),
                autoPlay: false,
                animation: SemiCarouselAnimation.fade,
                nextArrowIcon: const SemiIcon(
                  SemiIcons.arrowRight,
                  customSize: 20,
                ),
                prevArrowIcon: const SemiIcon(
                  SemiIcons.arrowLeft,
                  customSize: 20,
                ),
                children: _slides(),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _section('指示器类型', [
            for (final type in SemiCarouselIndicatorType.values)
              _demo(
                '${type.name}（small / medium）',
                Column(
                  children: [
                    for (final size in SemiCarouselSize.values)
                      Expanded(
                        child: SemiCarousel(
                          key: ValueKey('carousel-${type.name}-${size.name}'),
                          autoPlay: false,
                          indicatorType: type,
                          indicatorSize: size,
                          children: _slides(),
                        ),
                      ),
                  ],
                ),
              ),
          ]),
          const SizedBox(height: 24),
          _section('指示器位置与主题色', [
            _demo(
              'left / center / right × dark / primary / light',
              Column(
                children: [
                  for (final position in SemiCarouselIndicatorPosition.values)
                    Expanded(
                      child: SemiCarousel(
                        key: ValueKey('carousel-position-${position.name}'),
                        autoPlay: false,
                        indicatorPosition: position,
                        theme: SemiCarouselThemeColor.primary,
                        children: _slides(),
                      ),
                    ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _section('箭头', [
            _demo(
              'arrowType: hover（指针进入才显示）',
              SemiCarousel(
                key: const ValueKey('carousel-arrows'),
                autoPlay: false,
                arrowType: SemiCarouselArrowType.hover,
                theme: SemiCarouselThemeColor.dark,
                children: _slides(),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _section('控制器', [
            Row(
              children: [
                SemiButton(
                  '上一张',
                  key: const ValueKey('carousel-prev'),
                  onPressed: _controller.prev,
                ),
                const SizedBox(width: 8),
                SemiButton(
                  '下一张',
                  key: const ValueKey('carousel-next'),
                  onPressed: _controller.next,
                ),
                const SizedBox(width: 8),
                SemiButton(
                  '跳到第 3 屏',
                  key: const ValueKey('carousel-goto'),
                  onPressed: () => _controller.goTo(2),
                ),
                const SizedBox(width: 8),
                SemiButton(
                  '停止自动播放',
                  key: const ValueKey('carousel-stop'),
                  onPressed: _controller.stop,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _demo(
              'SemiCarouselController：next / prev / goTo / stop',
              SemiCarousel(
                key: const ValueKey('carousel-controller'),
                autoPlay: false,
                controller: _controller,
                indicatorType: SemiCarouselIndicatorType.columnar,
                children: _slides(),
                onChange: (index, previous) =>
                    _push('controller $previous -> $index'),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _section('RTL', [
            _demo(
              'RTL：箭头左右对调并翻转图标',
              Directionality(
                textDirection: TextDirection.rtl,
                child: SemiCarousel(
                  key: const ValueKey('carousel-rtl'),
                  autoPlay: false,
                  children: _slides(),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
