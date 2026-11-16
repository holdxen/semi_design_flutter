import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class PaginationPage extends StatefulWidget {
  const PaginationPage({super.key});

  @override
  State<PaginationPage> createState() => _PaginationPageState();
}

class _PaginationPageState extends State<PaginationPage> {
  String _status = '点击页码/切换容量/快速跳转，事件写入此行。';
  final List<String> _events = [];

  // 受控 currentPage（外部按钮改值，组件渲染跟随 props）。
  int _controlledPage = 3;

  void _push(String event) {
    _events.add(event);
    if (_events.length > 6) _events.removeRange(0, _events.length - 6);
    setState(() => _status = _events.join('；'));
  }

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
          // ★定高日志行：事件追加变高会把下方内容下推（指针静止但控件移走
          // 会触发 hover 区 exit 抖动）。
          SizedBox(
            height: 60,
            child: SingleChildScrollView(
              child: SemiText(
                _status,
                key: const ValueKey('pagination-status'),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _section('基础', [
            _demo(
              'total: 100 + pageSize: 10（10 页）— 总页数 ≤ PAGE_SHOW_MAX 全量；'
              '超过 7 页按当前页截断为「1 + ... + 尾页」7 格，省略号 hover 出 '
              'rest 列表弹层；onPageChange 先、onChange 后',
              SemiPagination(
                key: const ValueKey('pagination-basic'),
                total: 100,
                pageSize: 10,
                onPageChange: (page) => _push('onPageChange $page'),
                onChange: (page, size) => _push('onChange $page/$size'),
              ),
            ),
            _demo(
              '10 页截断矩阵：currentPage 3 中部双省略号、当前页 6 双侧 rest、'
              '当前页 9 左侧长省略号（倒 5 页）',
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SemiPagination(
                    key: ValueKey('pagination-truncate-3'),
                    total: 100,
                    pageSize: 10,
                    currentPage: 3,
                  ),
                  SizedBox(height: 8),
                  SemiPagination(
                    key: ValueKey('pagination-truncate-6'),
                    total: 100,
                    pageSize: 10,
                    currentPage: 6,
                  ),
                  SizedBox(height: 8),
                  SemiPagination(
                    key: ValueKey('pagination-truncate-9'),
                    total: 100,
                    pageSize: 10,
                    currentPage: 9,
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 32),
          _section('总页数 / 容量切换 / 快速跳转', [
            _demo(
              'showTotal + showSizeChanger + showQuickJumper — 总页数文本 '
              '「总页数：N」；容量切换保留当前页首条所在页（onPageSizeChange → '
              'onPageChange → onChange）；跳转 Enter/blur 提交、夹在 [1, 总页数]',
              SemiPagination(
                key: const ValueKey('pagination-features'),
                total: 300,
                pageSize: 10,
                defaultCurrentPage: 4,
                showTotal: true,
                showSizeChanger: true,
                showQuickJumper: true,
                onPageChange: (page) => _push('onPageChange $page'),
                onPageSizeChange: (size) => _push('onPageSizeChange $size'),
                onChange: (page, size) => _push('onChange $page/$size'),
              ),
            ),
            _demo(
              'preventPageChangeOnPageSizeChange: true — 容量切换不重算当前页',
              SemiPagination(
                key: const ValueKey('pagination-prevent-page'),
                total: 300,
                pageSize: 10,
                defaultCurrentPage: 4,
                showSizeChanger: true,
                preventPageChangeOnPageSizeChange: true,
                onPageSizeChange: (size) => _push('onPageSizeChange $size'),
                onChange: (page, size) => _push('onChange $page/$size'),
              ),
            ),
          ]),
          const SizedBox(height: 32),
          _section('small 尺寸', [
            _demo(
              'size: small — current/total 摘要盒（min-width 44、margin 归零）；'
              'hoverShowPageSelect 时摘要盒 hover 出全页码弹层',
              SemiPagination(
                key: const ValueKey('pagination-small'),
                total: 100,
                defaultCurrentPage: 3,
                size: SemiPaginationSize.small,
                hoverShowPageSelect: true,
                showQuickJumper: true,
                onPageChange: (page) => _push('onPageChange $page'),
              ),
            ),
            _demo(
              'size: small 不带 hoverShowPageSelect — 仅 prev / 摘要 / next',
              const SemiPagination(
                key: ValueKey('pagination-small-plain'),
                total: 100,
                defaultCurrentPage: 3,
                size: SemiPaginationSize.small,
              ),
            ),
          ]),
          const SizedBox(height: 32),
          _section('受控 currentPage', [
            _demo(
              'currentPage 受控 — 点击页码只发 onPageChange/onChange，渲染跟随 '
              'props；外部按钮改值才换页',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SemiButton(
                        '跳到第 1 页',
                        onPressed: () => setState(() => _controlledPage = 1),
                      ),
                      const SizedBox(width: 8),
                      SemiButton(
                        '跳到第 8 页',
                        onPressed: () => setState(() => _controlledPage = 8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SemiPagination(
                    key: const ValueKey('pagination-controlled'),
                    total: 100,
                    pageSize: 10,
                    currentPage: _controlledPage,
                    onPageChange: (page) => _push('onPageChange $page（受控）'),
                    onChange: (page, size) => _push('onChange $page/$size（受控）'),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 32),
          _section('禁用', [
            _demo(
              'disabled — 页码全禁用（选中项底色 disabled-fill）、prev/next/'
              '容量切换/跳转全禁用；点击/输入均不回调',
              SemiPagination(
                key: const ValueKey('pagination-disabled'),
                total: 100,
                defaultCurrentPage: 3,
                showSizeChanger: true,
                showQuickJumper: true,
                disabled: true,
                onPageChange: (page) => _push('onPageChange $page'),
              ),
            ),
          ]),
          const SizedBox(height: 32),
          _section('单页隐藏', [
            _demo(
              'hideOnSinglePage: true + total: 10（1 页）— 整块隐藏；'
              '★与 showSizeChanger 同开时上游 warning 且该开关失效（仍渲染）',
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SemiPagination(
                    key: ValueKey('pagination-hide-single'),
                    total: 10,
                    hideOnSinglePage: true,
                  ),
                  SizedBox(height: 8),
                  SemiPagination(
                    key: ValueKey('pagination-hide-single-with-size'),
                    total: 10,
                    hideOnSinglePage: true,
                    showSizeChanger: true,
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 32),
          _section('自定义 prevText / nextText 与 RTL', [
            _demo(
              'prevText/nextText 字符串替换缺省 chevron（String 原样渲染）',
              const SemiPagination(
                key: ValueKey('pagination-custom-prev-next'),
                total: 100,
                prevText: '上一页',
                nextText: '下一页',
              ),
            ),
            _demo(
              'Directionality.rtl — 两侧 margin 镜像、prev/next chevron '
              'scaleX(-1)；容量切换弹层缺省 bottomRight',
              const Directionality(
                textDirection: TextDirection.rtl,
                child: SemiPagination(
                  key: ValueKey('pagination-rtl'),
                  total: 100,
                  defaultCurrentPage: 5,
                  showSizeChanger: true,
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
