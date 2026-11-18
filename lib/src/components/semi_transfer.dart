// SemiTransfer — 穿梭框（Semi Design 组件移植）。
//
// 上游：packages/semi-foundation/transfer/{variables.scss, animation.scss,
// transfer.scss, rtl.scss, foundation.ts, transferUtils.ts, constants.ts}、
// packages/semi-ui/transfer/index.tsx、locale/source/zh_CN.ts:161-171。主题对账
// 50 = 47 FIELDS + 3 MOTION + 0 INTERNAL（tool/generate_transfer.py）——2 条死
// FIELDS（上游未消费）本文件不得出现其字段名（test_generate_transfer.py 断言）；
// 2 条拖拽字段「本移植未消费（draggable 延期）」；3 条 MOTION 是活字段（★与
// timePicker 死 animation.scss 相反——transfer.scss:1 `@import "./animation.scss"`
// + :81 消费，0ms/ease-in/0ms 视觉无动画）。
//
// HARDCODES（另列）上游片段以注释逐字留档在 `_TransferMetrics` / 调用点，
// 生成器 HARDCODES 锚点断言这些片段出现在本文件。
import 'package:flutter/rendering.dart' show OverflowBoxFit;
import 'package:flutter/widgets.dart';

import '../theme/semi_button_theme.dart';
import '../theme/semi_button_theme_data.dart';
import '../theme/semi_transfer_theme.dart';
import '../theme/semi_transfer_theme_data.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icons.dart';
import 'semi_button.dart';
import 'semi_checkbox.dart';
import 'semi_input.dart';
import 'semi_spin.dart';

/// 穿梭框条目（上游 `DataItem`）。
///
/// ★key/value 双轨 quirk（transferUtils.ts:61-64 `_generateSelectedItems`）：
/// 内部选中集按 [key] 建 Map、按 `option.value === val` 匹配 [value]；对外
/// `onChanged` 的 values 走 [value] 轨（foundation.ts:246 `values.push(obj.value)`）。
/// ★缺 [value] 的条目匹配不到 `defaultValue`/`value`，且会以 `null` 条目出现在
/// `onChanged` 的 values 里（JS `undefined` → Dart `null`，照搬）。
class SemiTransferItem {
  const SemiTransferItem({
    required this.key,
    this.value,
    this.label,
    this.disabled = false,
  });

  /// 唯一标识（String | int）。
  final Object key;

  /// 对外值轨（onChanged values / value/defaultValue 匹配）；★list 不回退 key
  ///（transferUtils.ts:61-64 只按 `option.value === val` 匹配，quirk 照搬）。
  final Object? value;

  /// String 或 Widget。
  final Object? label;

  final bool disabled;
}

/// `groupList` 模式的分组（上游 `GroupItem`）。
class SemiTransferGroup {
  const SemiTransferGroup({this.title, this.children = const []});

  final String? title;
  final List<SemiTransferItem> children;
}

/// 面板形态：平铺列表 / 分组列表 / 树形列表。
enum SemiTransferType { list, groupList, treeList }

/// `onChanged(values, items)`：values 走 value 轨（缺 value 的条目出 `null`），
/// items 为选中条目（groupList 时无内部 `_parent` 字段——本移植模型天然不含）。
typedef SemiTransferChanged = void Function(
  List<Object?> values,
  List<SemiTransferItem> items,
);

/// `renderSourceHeader` 入参（上游 `SourceHeaderProps` 的 list/groupList 子集；
/// `leafOnlyNum` 为 treeList 专用随 treeList 延期）。
class SemiTransferHeaderProps {
  const SemiTransferHeaderProps({
    required this.num,
    required this.showButton,
    required this.allChecked,
    required this.onAllClick,
  });

  /// 「总个数：${total}」的 `showNumber`（搜索态 = 命中数，否则全量）。
  final int num;

  /// 全选按钮显隐（全部过滤项 disabled 时隐藏）。
  final bool showButton;

  /// 过滤结果中不存在未选非 disabled 项。
  final bool allChecked;

  final VoidCallback onAllClick;
}

/// `renderSelectedHeader` 入参（上游 `SelectedHeaderProps`；`onSortEnd` 随
/// draggable 延期）。
class SemiTransferSelectedHeaderProps {
  const SemiTransferSelectedHeaderProps({
    required this.num,
    required this.showButton,
    required this.onClear,
  });

  final int num;

  /// 清空按钮显隐（有选中且含非 disabled 项）。
  final bool showButton;

  final VoidCallback onClear;
}

/// `renderSourcePanel` 入参（上游 `SourcePanelProps` 的 list/groupList 子集：
/// `propsDataSource`/`onSelect`（treeList）随 treeList 延期）。
class SemiTransferSourcePanelProps {
  const SemiTransferSourcePanelProps({
    required this.value,
    required this.loading,
    required this.noMatch,
    required this.filterData,
    required this.sourceData,
    required this.allChecked,
    required this.showNumber,
    required this.inputValue,
    required this.onSearch,
    required this.onAllClick,
    required this.onSelectOrRemove,
    required this.selectedItems,
  });

  /// 选中 values（value 轨）。
  final List<Object?> value;
  final bool loading;

  /// 搜索无命中（搜索态且 searchResult 为空）。
  final bool noMatch;

  /// 命中搜索的条目（非搜索态 = 全量）。
  final List<SemiTransferItem> filterData;

  /// 全量条目。
  final List<SemiTransferItem> sourceData;
  final bool allChecked;
  final int showNumber;
  final String inputValue;
  final ValueChanged<String> onSearch;
  final VoidCallback onAllClick;
  final ValueChanged<SemiTransferItem> onSelectOrRemove;

  /// 内部选中集（key → item，插入序 = 选中序）。
  final Map<Object, SemiTransferItem> selectedItems;

  /// treeList 的原始数据源。
  final List<Object>? propsDataSource;

  /// treeList 批量选择回调。
  final ValueChanged<List<Object>>? onSelect;
}

/// `renderSelectedPanel` 入参（上游 `SelectedPanelProps`；`onSortEnd` 随
/// draggable 延期）。
class SemiTransferSelectedPanelProps {
  const SemiTransferSelectedPanelProps({
    required this.length,
    required this.selectedData,
    required this.onClear,
    required this.onRemove,
  });

  final int length;
  final List<SemiTransferItem> selectedData;
  final VoidCallback onClear;
  final ValueChanged<SemiTransferItem> onRemove;
}

/// Imperative handle（上游 ref 方法 `search`；semi_date_picker.dart:84-117
/// attach/detach 先例）——脱离后 no-op。
class SemiTransferController {
  _SemiTransferState? _state;

  /// 设置搜索词并重算过滤，★不触发 [SemiTransfer.onSearch]
  /// （index.tsx:375-379：手动调用第二个参数传 false 的 quirk 照搬）。
  void search(String value) {
    _state?._controllerSearch(value);
  }

  void _attach(_SemiTransferState state) {
    _state = state;
  }

  void _detach(_SemiTransferState state) {
    if (identical(_state, state)) _state = null;
  }
}

/// 穿梭框。
///
/// 值语义（foundation.ts / transferUtils.ts / index.tsx）：内部 `Map<key, item>`，
/// 对外 values = `[item.value...]`；★缺 value 的条目匹配不到 [defaultValue]、
/// `onChanged` 出 `null` 条目（照搬，docs 注明）；[defaultValue] 未匹配到的值静默
/// 忽略（transferUtils.ts:62 `if (index !== -1)` quirk）。★**勾选即穿梭**（无箭头
/// 钮）：左栏勾选进右栏、右栏 close/取消勾选出（foundation.ts:174-192）。★受控惯例
/// `value != null` 即受控（★上游 `'value' in props` 连 `undefined` 都算受控——差异
/// 注明）；点击只发事件不落状态，释放控制保留最后值。[defaultValue] 仅初值语义。
class SemiTransfer extends StatefulWidget {
  const SemiTransfer({
    super.key,
    this.dataSource = const [],
    this.type = SemiTransferType.list,
    this.value,
    this.defaultValue,
    this.filter = true,
    this.filterFn,
    this.onSearch,
    this.onSelect,
    this.onDeselect,
    this.onChanged,
    this.disabled = false,
    this.loading = false,
    this.emptyLeft,
    this.emptyRight,
    this.emptySearch,
    this.renderSourceItem,
    this.renderSelectedItem,
    this.renderSourceHeader,
    this.renderSelectedHeader,
    this.renderSourcePanel,
    this.renderSelectedPanel,
    this.controller,
    this.treeProps,
    this.showPath = false,
  });

  static const Key rootKey = Key('SemiTransfer.root');
  static const Key leftPanelKey = Key('SemiTransfer.leftPanel');
  static const Key rightPanelKey = Key('SemiTransfer.rightPanel');
  static const Key searchKey = Key('SemiTransfer.search');
  static const Key leftListKey = Key('SemiTransfer.leftList');
  static const Key rightListKey = Key('SemiTransfer.rightList');
  static const Key selectAllKey = Key('SemiTransfer.selectAll');
  static const Key clearKey = Key('SemiTransfer.clear');

  /// 条目行 key（左右栏同 key，不同 parent 不冲突）。
  static Key itemKey(Object key) => Key('SemiTransfer.item.$key');

  /// [SemiTransferType.list] 时 `List<SemiTransferItem>`、
  /// [SemiTransferType.groupList] 时 `List<SemiTransferGroup>`。
  final List<Object> dataSource;
  final SemiTransferType type;

  /// 当前选中 values；非空即受控（★上游 `'value' in props` 连 undefined 都算
  /// 受控——差异注明）。
  final List<Object?>? value;

  /// 非受控初值（★仅初值语义——引用变化不重置已选值）。
  final List<Object?>? defaultValue;

  /// 显隐搜索框（★上游 `filter` union 拆分为 bool + [filterFn]，差异注明）。
  final bool filter;

  /// 自定义过滤谓词；缺省 `label 包含 input`（foundation.ts:100-102）。
  final bool Function(String input, SemiTransferItem item)? filterFn;

  /// 搜索输入回调（随输入触发；★`controller.search` 不触发——index.tsx:375-379）。
  final ValueChanged<String>? onSearch;

  /// 勾选/取消勾选单条目（含右栏 close）。
  final ValueChanged<SemiTransferItem>? onSelect;
  final ValueChanged<SemiTransferItem>? onDeselect;

  /// 变更回传（values 走 value 轨）。
  final SemiTransferChanged? onChanged;

  final bool disabled;
  final bool loading;

  /// 空态文案（缺省 zh 硬编码）：左栏空 / 右栏空 / 搜索无结果。
  final Widget? emptyLeft;
  final Widget? emptyRight;
  final Widget? emptySearch;

  /// 左栏条目渲染槽（整行替换）。
  final Widget Function(
    BuildContext context,
    SemiTransferItem item,
    bool checked,
    VoidCallback onToggle,
  )?
  renderSourceItem;

  /// 右栏条目渲染槽（整行替换）。
  final Widget Function(
    BuildContext context,
    SemiTransferItem item,
    VoidCallback onRemove,
  )?
  renderSelectedItem;

  final Widget Function(BuildContext context, SemiTransferHeaderProps)?
  renderSourceHeader;
  final Widget Function(BuildContext context, SemiTransferSelectedHeaderProps)?
  renderSelectedHeader;

  /// 整面板渲染槽（替换对应面板）。
  final Widget Function(BuildContext context, SemiTransferSourcePanelProps)?
  renderSourcePanel;
  final Widget Function(BuildContext context, SemiTransferSelectedPanelProps)?
  renderSelectedPanel;

  final SemiTransferController? controller;

  /// treeList 配置。
  final SemiTransferTreeProps? treeProps;

  /// 是否在右侧显示树路径。
  final bool showPath;

  @override
  State<SemiTransfer> createState() => _SemiTransferState();
}

class _TransferTreeEntity {
  _TransferTreeEntity({
    required this.item,
    required this.parent,
    required this.path,
    required this.internalKey,
  });

  final SemiTransferItem item;
  final _TransferTreeEntity? parent;
  final List<SemiTransferItem> path;
  final String internalKey;
  final List<_TransferTreeEntity> children = <_TransferTreeEntity>[];
}

class _FlatEntry {
  const _FlatEntry(this.item, {this.groupTitle, this.grouped = false});

  final SemiTransferItem item;

  /// 分组标题（groupList；可为 null——上游空标题组也渲染标题行）。
  final String? groupTitle;
  final bool grouped;
}

class _SemiTransferState extends State<SemiTransfer> {
  late List<_FlatEntry> _entries;
  late Map<Object, SemiTransferItem> _selected;
  late List<SemiTransferItem> _treeItems;
  late Map<Object, _TransferTreeEntity> _treeEntities;
  late List<SemiTreeNodeData> _treeNodes;
  final SemiTreeController _treeController = SemiTreeController();
  String _inputValue = '';
  Set<Object> _searchResult = <Object>{};
  late final TextEditingController _inputController = TextEditingController();

  bool get _isControlled => widget.value != null;

  bool get _isTree => widget.type == SemiTransferType.treeList;

  List<SemiTransferItem> get _data => _isTree ? _treeItems : [
    for (final entry in _entries) entry.item,
  ];

  bool get _inSearch => _inputValue.isNotEmpty;

  bool get _noMatch => _inSearch && _searchResult.isEmpty;

  int get _showNumber => _inSearch ? _searchResult.length : _entries.length;

  List<SemiTransferItem> get _filterData => _inSearch
      ? [
          for (final e in _entries)
            if (_searchResult.contains(e.item.key)) e.item,
        ]
      : _data;

  @override
  void initState() {
    super.initState();
    _entries = _flatten();
    _rebuildTree();
    // 上游 constructor：`defaultValue` 建初始选中；gDSFP 在首帧前用 `value`
    // 覆盖（受控优先）。
    _selected = _generateSelectedItems(
      widget.value ?? widget.defaultValue ?? const [],
      _data,
    );
    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(SemiTransfer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
    final oldEntries = _entries;
    _entries = _flatten();
    _rebuildTree();
    // 上游 getDerivedStateFromProps：受控（value 非空）时每次渲染重derive选中
    //（数据变化时未匹配项被静默丢弃）；非受控保留内部状态（defaultValue 引用
    // 变化不重置——SemiTransferItem 列表字面量 churn 回归）。
    if (widget.value != null) {
      _selected = _generateSelectedItems(widget.value!, _data);
    }
    // ★数据变化且搜索词非空时重算搜索结果（gDSFP :310-319 quirk）。
    if (_inputValue.isNotEmpty && !_sameEntries(oldEntries, _entries)) {
      _searchResult = _filterKeys(_inputValue);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _inputController.dispose();
    super.dispose();
  }

  List<_FlatEntry> _flatten() {
    if (_isTree) {
      return [
        for (final item in _flattenTreeItems(_treeSource())) _FlatEntry(item),
      ];
    }
    if (widget.type == SemiTransferType.groupList) {
      final entries = <_FlatEntry>[];
      for (final object in widget.dataSource) {
        final group = object as SemiTransferGroup;
        for (final item in group.children) {
          entries.add(_FlatEntry(item, groupTitle: group.title, grouped: true));
        }
      }
      return entries;
    }
    return [
      for (final object in widget.dataSource)
        _FlatEntry(object as SemiTransferItem),
    ];
  }

  bool _sameEntries(List<_FlatEntry> a, List<_FlatEntry> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].item.key != b[i].item.key ||
          a[i].item.value != b[i].item.value ||
          a[i].item.label != b[i].item.label ||
          a[i].item.disabled != b[i].item.disabled ||
          a[i].groupTitle != b[i].groupTitle) {
        return false;
      }
    }
    return true;
  }

  /// transferUtils.ts:58-68 `_generateSelectedItems`：按 `option.value === val`
  /// 匹配、按 key 建 Map；★缺 value 的条目匹配不到（`o.value != null` 门），未匹配
  /// 的 val 静默忽略（`if (index !== -1)` quirk）。
  Map<Object, SemiTransferItem> _generateSelectedItems(
    List<Object?> values,
    List<SemiTransferItem> data,
  ) {
    final selected = <Object, SemiTransferItem>{};
    for (final val in values) {
      final index = data.indexWhere((o) => o.value != null && o.value == val);
      if (index != -1) {
        final option = data[index];
        selected[option.key] = option;
      }
    }
    return selected;
  }

  Set<Object> _filterKeys(String input) {
    final result = <Object>{};
    for (final entry in _entries) {
      final item = entry.item;
      final matched = widget.filterFn != null
          ? widget.filterFn!(input, item)
          : item.label is String && (item.label! as String).contains(input);
      if (matched) result.add(item.key);
    }
    return result;
  }

  // -- events ---------------------------------------------------------------

  void _handleInputChanged(String input) => _applySearch(input, notify: true);

  void _controllerSearch(String value) => _applySearch(value, notify: false);

  void _applySearch(String input, {required bool notify}) {
    final result = _filterKeys(input);
    if (notify) widget.onSearch?.call(input);
    setState(() {
      _inputValue = input;
      _searchResult = result;
      // 手动 search() 路径同步输入框文本；用户输入路径文本已一致。
      if (_inputController.text != input) {
        _inputController.text = input;
      }
    });
  }

  void _toggle(SemiTransferItem item) {
    if (widget.disabled || item.disabled) return;
    final next = Map<Object, SemiTransferItem>.of(_selected);
    if (next.containsKey(item.key)) {
      next.remove(item.key);
      widget.onDeselect?.call(item);
    } else {
      next[item.key] = item;
      widget.onSelect?.call(item);
    }
    _commit(next);
  }

  /// 全选/取消全选（foundation.ts:111-153 `handleAll`）：搜索态只作用过滤结果；
  /// disabled 项跳过保留；全部 disabled 时按钮不显示（filterDataAllDisabled）。
  void _handleAll(bool wantAllChecked) {
    if (widget.disabled) return;
    final operate = _filterData;
    final next = Map<Object, SemiTransferItem>.of(_selected);
    if (wantAllChecked) {
      for (final item in operate) {
        if (item.disabled) {
          // The disabled item, judge whether it is selected, if it is selected,
          // still need to add the selection（foundation.ts:136-141）。
          if (next.containsKey(item.key)) next[item.key] = item;
          continue;
        }
        next[item.key] = item;
      }
    } else {
      for (final item in operate) {
        // If the item is disabled, keep it（foundation.ts:127-130）。
        if (!item.disabled) next.remove(item.key);
      }
    }
    _commit(next);
  }

  /// 清空（foundation.ts:155-172 `handleClear`）：删所有**非 disabled** 选中项、
  /// disabled 保留。
  void _handleClear() {
    if (widget.disabled) return;
    final next = Map<Object, SemiTransferItem>.of(_selected);
    next.removeWhere((_, item) => !item.disabled);
    _commit(next);
  }

  void _commit(Map<Object, SemiTransferItem> next) {
    // ★受控（value != null）：点击只发事件不落状态（transfer.test.js:351-370）。
    if (!_isControlled) {
      setState(() => _selected = next);
    }
    _notifyChange(next);
  }

  void _notifyChange(Map<Object, SemiTransferItem> next) {
    // foundation.ts:237-249 `getValuesAndItemsFromMap`：values.push(obj.value)。
    widget.onChanged?.call([
      for (final item in next.values) item.value,
    ], next.values.toList());
  }

  // -- build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final t = SemiTransferTheme.resolve(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final customPanels =
        widget.renderSourcePanel != null && widget.renderSelectedPanel != null;
    Widget body = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // `$width-transfer_left: 50%` / `$width-transfer_right: 50%` →
        // `Expanded(flex: 1)` 语义（50/50 等比）。
        Expanded(flex: t.widthTransferLeft.round(), child: _buildLeft(t, rtl)),
        Expanded(flex: t.widthTransferRight.round(), child: _buildRight(t)),
      ],
    );
    body = DecoratedBox(
      // `&-custom-panel`（transfer.scss:41-45）双自定义面板时 `border: none`、
      // `min-width: inherit; height: inherit`——去掉 402/400 约束与描边。
      decoration: BoxDecoration(
        color: t.colorTransferBg,
        border: customPanels
            ? null
            : Border.all(
                width: t.widthTransferBorder,
                color: t.colorTransferBorder,
              ),
        borderRadius: BorderRadius.circular(t.radiusTransfer),
      ),
      child: body,
    );
    body = ConstrainedBox(
      constraints: customPanels
          ? const BoxConstraints()
          : BoxConstraints(
              minWidth: t.widthTransferMinWidth,
              minHeight: t.heightTransfer,
              maxHeight: t.heightTransfer,
            ),
      child: body,
    );
    return KeyedSubtree(
      key: SemiTransfer.rootKey,
      child: Semantics(container: true, enabled: !widget.disabled, child: body),
    );
  }

  // -- left panel -----------------------------------------------------------

  Widget _buildLeft(SemiResolvedTransferThemeData t, bool rtl) {
    if (widget.renderSourcePanel != null) {
      return KeyedSubtree(
        key: SemiTransfer.leftPanelKey,
        child: widget.renderSourcePanel!(context, _sourcePanelProps()),
      );
    }
    final filterData = _filterData;
    // index.tsx:490-513：过滤结果是否全部 disabled + 是否存在未选非 disabled 项。
    var filterDataAllDisabled = true;
    var leftContainsNotInSelected = false;
    for (final item in filterData) {
      if (item.disabled) continue;
      filterDataAllDisabled = false;
      if (!_selected.containsKey(item.key)) {
        leftContainsNotInSelected = true;
        break;
      }
    }
    final children = <Widget>[if (widget.filter) _buildFilter(t)];
    if (widget.loading) {
      // `>.#{$prefix}-spin {` 覆写（transfer.scss:134-137 `width: 100%;
      // flex-grow: 1`）——loading 时 Spin 覆盖左栏内容（index.tsx:538-541）。
      children.add(const Expanded(child: SemiSpin()));
    } else if (_noMatch) {
      children.add(
        _buildEmpty(
          t,
          height: t.heightTransferLeftEmpty,
          child:
              widget.emptySearch ??
              _defaultEmptyText(t, _TransferMetrics.emptySearch),
        ),
      );
    } else if (_entries.isEmpty) {
      children.add(
        _buildEmpty(
          t,
          height: t.heightTransferLeftEmpty,
          child:
              widget.emptyLeft ??
              _defaultEmptyText(t, _TransferMetrics.emptyLeft),
        ),
      );
    } else {
      children
        ..add(
          _buildHeader(
            t,
            totalText: _totalText(_TransferMetrics.totalTemplate, _showNumber),
            buttonLabel: leftContainsNotInSelected
                ? _TransferMetrics.selectAllLabel
                : _TransferMetrics.clearSelectAllLabel,
            showButton: !filterDataAllDisabled,
            onAllClick: () => _handleAll(leftContainsNotInSelected),
            allChecked: !leftContainsNotInSelected,
          ),
        )
        ..add(Expanded(child: _buildLeftList(t)));
    }
    final panel = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
    // 中缝：`$width-transfer_left-border` × `$color-transfer-border` 右边框
    //（RTL 翻到左边，rtl.scss:21-24；semi_time_picker.dart:903-915 翻边先例）。
    final divider = BorderSide(
      width: t.widthTransferLeftBorder,
      color: t.colorTransferBorder,
    );
    return KeyedSubtree(
      key: SemiTransfer.leftPanelKey,
      child: Container(
        decoration: BoxDecoration(
          border: rtl ? Border(left: divider) : Border(right: divider),
        ),
        child: panel,
      ),
    );
  }

  Widget _buildFilter(SemiResolvedTransferThemeData t) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: t.spacingTransferFilterMarginTop,
        end: t.spacingTransferFilterMarginRight,
        bottom: t.spacingTransferFilterMarginBottom,
        start: t.spacingTransferFilterMarginLeft,
      ),
      child: KeyedSubtree(
        key: SemiTransfer.searchKey,
        child: SemiInput(
          controller: _inputController,
          size: SemiInputSize.small,
          disabled: widget.disabled,
          placeholder: _TransferMetrics.searchPlaceholder,
          prefix: const SemiIcon(SemiIcons.search, excludeFromSemantics: true),
          showClear: true,
          onChanged: widget.disabled ? null : _handleInputChanged,
          onEnterPress: widget.disabled
              ? null
              : () => _handleInputChanged(_inputController.text),
        ),
      ),
    );
  }

  Widget _buildHeader(
    SemiResolvedTransferThemeData t, {
    required String totalText,
    required String buttonLabel,
    required bool showButton,
    required VoidCallback onAllClick,
    required bool allChecked,
    bool right = false,
    VoidCallback? onClear,
  }) {
    if (!right && widget.renderSourceHeader != null) {
      return widget.renderSourceHeader!(
        context,
        SemiTransferHeaderProps(
          num: _showNumber,
          showButton: showButton,
          allChecked: allChecked,
          onAllClick: onAllClick,
        ),
      );
    }
    if (right && widget.renderSelectedHeader != null) {
      return widget.renderSelectedHeader!(
        context,
        SemiTransferSelectedHeaderProps(
          num: _selected.length,
          showButton: showButton,
          onClear: onClear ?? onAllClick,
        ),
      );
    }
    // index.tsx:506/834 replace 模式：`totalToken.replace('${total}',
    // `${showNumber}`)` / `selectedToken.replace('${total}',
    // `${selectedData.length}`)`。
    final Widget? button = !showButton
        ? null
        : Padding(
            padding: EdgeInsetsDirectional.only(
              // `$spacing-transfer_header_all-marginLeft`（RTL 翻 margin-right，
              // rtl.scss:8-13）。
              start: t.spacingTransferHeaderAllMarginLeft,
            ),
            child: SemiButtonTheme(
              // `&-header-all { font-weight: $font-transfer_header_all-fontWeight }`
              //（transfer.scss:58-61）——经按钮主题槽覆盖按钮字重（值 600）。
              data: SemiButtonThemeData(
                fontButtonSmallFontWeight: _fontWeightOf(
                  t.fontTransferHeaderAllFontWeight,
                ),
              ),
              child: SemiButton(
                buttonLabel,
                key: right ? SemiTransfer.clearKey : SemiTransfer.selectAllKey,
                type: SemiButtonType.tertiary,
                variant: SemiButtonVariant.borderless,
                size: SemiButtonSize.small,
                onPressed: widget.disabled ? null : onAllClick,
              ),
            ),
          );
    return Container(
      height: right ? t.heightTransferRightHeader : t.heightTransferHeader,
      margin: EdgeInsetsDirectional.only(
        top: right
            ? t.spacingTransferRightHeaderMarginTop
            : t.spacingTransferHeaderMarginTop,
        end: t.spacingTransferHeaderMarginRight,
        bottom: right
            ? t.spacingTransferRightHeaderMarginBottom
            : t.spacingTransferHeaderMarginBottom,
        start: t.spacingTransferHeaderMarginLeft,
      ),
      // `@include ver-center`（transfer.scss:49）。
      child: Row(
        children: [
          Text(
            totalText,
            style: TextStyle(
              // `@include font-size-small` → `$font-size-small: 12px`。
              fontSize: _TransferMetrics.fontSizeSmall,
              color: widget.disabled
                  ? t.colorTransferDisabledText
                  : t.colorTransferHeaderText,
            ),
          ),
          ?button,
        ],
      ),
    );
  }

  Widget _buildLeftList(SemiResolvedTransferThemeData t) {
    // 分组标题行：组内首条可见条目前插入（index.tsx:647-667 renderLeftList）。
    final rows = <Widget>[];
    final seenGroups = <String?>{};
    for (final entry in _entries) {
      if (!_inSearch || _searchResult.contains(entry.item.key)) {
        if (entry.grouped && seenGroups.add(entry.groupTitle)) {
          rows.add(_buildGroupTitle(t, entry.groupTitle));
        }
        rows.add(_buildSourceRow(t, entry.item));
      }
    }
    return ListView.builder(
      key: SemiTransfer.leftListKey,
      padding: EdgeInsets.zero,
      itemCount: rows.length,
      itemBuilder: (context, index) => rows[index],
    );
  }

  Widget _buildGroupTitle(SemiResolvedTransferThemeData t, String? title) {
    return Container(
      height: t.heightTransferGroupTitle,
      padding: EdgeInsetsDirectional.only(
        // `$spacing-transfer_group_title-paddingLeft`（RTL 翻 padding-right，
        // rtl.scss:26-29）。
        start: t.spacingTransferGroupTitlePaddingLeft,
      ),
      // `@include ver-center`（transfer.scss:223）。
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        title ?? '',
        style: TextStyle(
          // `@include font-size-small` → `$font-size-small: 12px`。
          fontSize: _TransferMetrics.fontSizeSmall,
          color: t.colorTransferGroupTitleText,
        ),
      ),
    );
  }

  Widget _buildSourceRow(
    SemiResolvedTransferThemeData t,
    SemiTransferItem item,
  ) {
    final checked = _selected.containsKey(item.key);
    if (widget.renderSourceItem != null) {
      return KeyedSubtree(
        key: SemiTransfer.itemKey(item.key),
        child: widget.renderSourceItem!(
          context,
          item,
          checked,
          () => _toggle(item),
        ),
      );
    }
    return _TransferSourceRow(
      key: SemiTransfer.itemKey(item.key),
      item: item,
      checked: checked,
      disabled: widget.disabled || item.disabled,
      theme: t,
      onToggle: () => _toggle(item),
    );
  }

  // -- right panel ----------------------------------------------------------

  Widget _buildRight(SemiResolvedTransferThemeData t) {
    if (widget.renderSelectedPanel != null) {
      return KeyedSubtree(
        key: SemiTransfer.rightPanelKey,
        child: widget.renderSelectedPanel!(context, _selectedPanelProps()),
      );
    }
    final selectedData = _selected.values.toList();
    final hasValidSelected = selectedData.any((item) => !item.disabled);
    final header = _buildHeader(
      t,
      right: true,
      totalText: _totalText(
        _TransferMetrics.selectedTemplate,
        selectedData.length,
      ),
      buttonLabel: _TransferMetrics.clearLabel,
      // index.tsx:835-841：showButton = 有选中 && 含非 disabled。
      showButton: selectedData.isNotEmpty && hasValidSelected,
      onAllClick: _handleClear,
      allChecked: false,
      onClear: _handleClear,
    );
    final children = <Widget>[header];
    if (selectedData.isNotEmpty) {
      children.add(Expanded(child: _buildRightList(t, selectedData)));
    }
    return KeyedSubtree(
      key: SemiTransfer.rightPanelKey,
      // `&-right { position: relative }`（transfer.scss:144）——空态 absolute。
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
          if (selectedData.isEmpty)
            _buildRightEmpty(
              t,
              widget.emptyRight ??
                  _defaultEmptyText(t, _TransferMetrics.emptyRight),
            ),
        ],
      ),
    );
  }

  Widget _buildRightList(
    SemiResolvedTransferThemeData t,
    List<SemiTransferItem> selectedData,
  ) {
    return ListView.builder(
      key: SemiTransfer.rightListKey,
      padding: EdgeInsets.zero,
      itemCount: selectedData.length,
      itemBuilder: (context, index) =>
          _buildSelectedRow(t, selectedData[index]),
    );
  }

  Widget _buildSelectedRow(
    SemiResolvedTransferThemeData t,
    SemiTransferItem item,
  ) {
    if (widget.renderSelectedItem != null) {
      return KeyedSubtree(
        key: SemiTransfer.itemKey(item.key),
        child: widget.renderSelectedItem!(context, item, () => _toggle(item)),
      );
    }
    return _TransferSelectedRow(
      key: SemiTransfer.itemKey(item.key),
      item: item,
      disabled: widget.disabled || item.disabled,
      theme: t,
      onRemove: () => _toggle(item),
    );
  }

  // -- empty states ---------------------------------------------------------

  /// `&-empty`（transfer.scss:204-209）：`width: $width-transfer_empty`（100%）+
  /// `@include all-center` + `@include font-size-small` +
  /// `$color-transfer_empty-text`；`&-left-empty`（:131-133）高
  /// `$height-transfer_left_empty`。
  Widget _buildEmpty(
    SemiResolvedTransferThemeData t, {
    required double height,
    required Widget child,
  }) {
    return SizedBox(
      height: height,
      child: FractionallySizedBox(
        // `$width-transfer_empty: 100%` → 填充语义。
        widthFactor: t.widthTransferEmpty / 100,
        // `@include all-center`（transfer.scss:206）。
        child: Center(child: child),
      ),
    );
  }

  /// `&-right-empty`（transfer.scss:198-201）：`position: absolute` +
  /// `height: $height-transfer_right_empty`（100%）——绝对定位填充整面板
  /// （flex 静态位 = 面板起点），文本全中。
  Widget _buildRightEmpty(SemiResolvedTransferThemeData t, Widget child) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: FractionallySizedBox(
        // `$width-transfer_empty: 100%` → 填充语义。
        widthFactor: t.widthTransferEmpty / 100,
        child: SizedBox(
          // `$height-transfer_right_empty: 100%` → 填充语义（面板高 = 根高）。
          height: t.heightTransfer * t.heightTransferRightEmpty / 100,
          child: Center(child: child),
        ),
      ),
    );
  }

  /// 缺省空态文案（`&-empty`：`@include font-size-small` +
  /// `$color-transfer_empty-text`）。
  Widget _defaultEmptyText(SemiResolvedTransferThemeData t, String text) {
    return Text(
      text,
      style: TextStyle(
        // `@include font-size-small` → `$font-size-small: 12px`。
        fontSize: _TransferMetrics.fontSizeSmall,
        color: t.colorTransferEmptyText,
      ),
    );
  }

  // -- props bundles --------------------------------------------------------

  SemiTransferSourcePanelProps _sourcePanelProps() =>
      SemiTransferSourcePanelProps(
        value: [for (final item in _selected.values) item.value],
        loading: widget.loading,
        noMatch: _noMatch,
        filterData: _filterData,
        sourceData: _data,
        allChecked: !_filterData.any(
          (item) => !item.disabled && !_selected.containsKey(item.key),
        ),
        showNumber: _showNumber,
        inputValue: _inputValue,
        onSearch: _handleInputChanged,
        onAllClick: () => _handleAll(
          _filterData.any(
            (item) => !item.disabled && !_selected.containsKey(item.key),
          ),
        ),
        onSelectOrRemove: _toggle,
        selectedItems: Map<Object, SemiTransferItem>.of(_selected),
      );

  SemiTransferSelectedPanelProps _selectedPanelProps() =>
      SemiTransferSelectedPanelProps(
        length: _selected.length,
        selectedData: _selected.values.toList(),
        onClear: _handleClear,
        onRemove: _toggle,
      );
}

/// 左栏条目行（`&-item`，transfer.scss:67-107）：`min-height:
/// $height-transfer_item-minHeight`、四向 padding、`user-select: none`、
/// `@include font-size-regular`、`@include ver-center`、hover/active 底色 +
/// `transition: background-color` 三 MOTION 字段。
class _TransferSourceRow extends StatefulWidget {
  const _TransferSourceRow({
    super.key,
    required this.item,
    required this.checked,
    required this.disabled,
    required this.theme,
    required this.onToggle,
  });

  final SemiTransferItem item;
  final bool checked;
  final bool disabled;
  final SemiResolvedTransferThemeData theme;
  final VoidCallback onToggle;

  @override
  State<_TransferSourceRow> createState() => _TransferSourceRowState();
}

class _TransferSourceRowState extends State<_TransferSourceRow> {
  bool _hovering = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final Color bg;
    if (widget.disabled) {
      // `&-item-disabled:hover { background-color: inherit }`（:96-98）+ 整机
      // disabled 同（:28-29）——禁用行不吃 hover/active 底色。
      bg = const Color(0x00000000);
    } else if (_pressed) {
      // `&:active`：`$color-transfer_item-bg-active`。
      bg = t.colorTransferItemBgActive;
    } else if (_hovering) {
      // `&:hover`：`$color-transfer_item-bg-hover`。
      bg = t.colorTransferItemBgHover;
    } else {
      bg = const Color(0x00000000);
    }
    // label 文本走显式样式（checkbox labelStyle 会强色；上游
    // `color: $color-transfer_item-text` 继承口径）——String 转样式化 Text。
    final Object? rawLabel = widget.item.label;
    final Object? label = rawLabel is Widget
        ? rawLabel
        : rawLabel == null
        ? null
        : Text(
            '$rawLabel',
            style: TextStyle(
              // `@include font-size-regular`（transfer.scss:75）→ `$font-size-regular: 14px`。
              fontSize: _TransferMetrics.fontSizeRegular,
              color: widget.disabled
                  ? t.colorTransferDisabledText
                  : t.colorTransferItemText,
            ),
          );
    Widget row = SemiCheckbox(
      checked: widget.checked,
      disabled: widget.disabled,
      label: label,
      // 行级 GestureDetector 与 checkbox 各自的 tap 识别器竞争同一手势 arena——
      // 每次点击只有一个胜出，勾选即穿梭恰好一次（foundation.ts:174-192
      // `handleSelectOrRemove`）。
      onChanged: (_) => widget.onToggle(),
    );
    row = AnimatedContainer(
      // `transition: background-color ...`（transfer.scss:81）三条 MOTION 活
      // 字段：duration/curve 直接消费；delay 槽
      // `t.transitionDelayTransferItemBg` AnimatedContainer 无对应（0ms 视觉
      // 无动画——注释引用 + docs 注明）。
      duration: t.transitionDurationTransferItemBg,
      curve: t.transitionFunctionTransferItemBg,
      constraints: BoxConstraints(minHeight: t.heightTransferItemMinHeight),
      // `padding-top/right/bottom/left: $spacing-transfer_item-padding*`
      //（:70-73）；RTL 左右值互换（rtl.scss:16-19）→ EdgeInsetsDirectional。
      padding: EdgeInsetsDirectional.only(
        top: t.spacingTransferItemPaddingTop,
        end: t.spacingTransferItemPaddingRight,
        bottom: t.spacingTransferItemPaddingBottom,
        start: t.spacingTransferItemPaddingLeft,
      ),
      color: bg,
      child: row,
    );
    if (!widget.disabled) {
      row = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onToggle,
        child: row,
      );
    }
    row = Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: widget.disabled
          ? null
          : (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: row,
    );
    row = MouseRegion(
      // `cursor: pointer`（:80）；禁用 `cursor: not-allowed`（:26）。
      cursor: widget.disabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: row,
    );
    return Semantics(
      container: true,
      enabled: !widget.disabled,
      checked: widget.checked,
      child: row,
    );
  }
}

/// 右栏条目行（`&-item &-right-item`，transfer.scss:160-196）：文字
/// `$color-transfer_selected_item-text` + `word-break: break-all`、`cursor: auto`、
/// hover 显 close 图标（`visibility: hidden` → `visibility: visible`，disabled
/// 永隐）。
class _TransferSelectedRow extends StatefulWidget {
  const _TransferSelectedRow({
    super.key,
    required this.item,
    required this.disabled,
    required this.theme,
    required this.onRemove,
  });

  final SemiTransferItem item;
  final bool disabled;
  final SemiResolvedTransferThemeData theme;
  final VoidCallback onRemove;

  @override
  State<_TransferSelectedRow> createState() => _TransferSelectedRowState();
}

class _TransferSelectedRowState extends State<_TransferSelectedRow> {
  bool _hovering = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final disabled = widget.disabled;
    final Color bg;
    if (disabled) {
      bg = const Color(0x00000000);
    } else if (_pressed) {
      bg = t.colorTransferItemBgActive;
    } else if (_hovering) {
      bg = t.colorTransferItemBgHover;
    } else {
      bg = const Color(0x00000000);
    }
    Widget label;
    if (widget.item.label is Widget) {
      label = widget.item.label! as Widget;
    } else if (widget.item.label != null) {
      label = Text(
        '${widget.item.label}',
        style: TextStyle(
          // `@include font-size-regular`（transfer.scss:75）。
          fontSize: _TransferMetrics.fontSizeRegular,
          color: disabled
              ? t.colorTransferDisabledText
              : t.colorTransferSelectedItemText,
        ),
      );
    } else {
      label = const SizedBox.shrink();
    }
    // ★ CSS 文本行盒可溢出内容盒进 padding（word-break: break-all，:176）——
    // OverflowBox 放开纵向约束（semi_tag.dart:350-363 先例）。
    label = OverflowBox(
      fit: OverflowBoxFit.deferToChild,
      minHeight: 0,
      maxHeight: double.infinity,
      child: label,
    );
    // close 图标：`font-size: $width-transfer_item_close-icon`（★当字号用，
    // :102）+ `visibility: hidden`（:104）hover 显 `visibility: visible`（:167）、
    // disabled `visibility: hidden` 永隐（:170-171）+ 整机 disabled 同（:31）。
    final showClose = _hovering && !disabled;
    final close = Visibility(
      visible: showClose,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: disabled ? null : widget.onRemove,
          child: SemiIcon(
            SemiIcons.close,
            customSize: t.widthTransferItemCloseIcon,
            color: t.colorTransferCloseIconIcon,
            excludeFromSemantics: true,
          ),
        ),
      ),
    );
    Widget row = Row(
      // `justify-content: space-between; flex-wrap: nowrap`（:77-78）。
      children: [
        // `&-right-item-text { flex: 1 }`（:174-177）。
        Expanded(child: label),
        close,
      ],
    );
    row = AnimatedContainer(
      // `transition: background-color ...`（transfer.scss:81；MOTION 活字段）。
      duration: t.transitionDurationTransferItemBg,
      curve: t.transitionFunctionTransferItemBg,
      constraints: BoxConstraints(minHeight: t.heightTransferItemMinHeight),
      padding: EdgeInsetsDirectional.only(
        top: t.spacingTransferItemPaddingTop,
        end: t.spacingTransferItemPaddingRight,
        bottom: t.spacingTransferItemPaddingBottom,
        start: t.spacingTransferItemPaddingLeft,
      ),
      color: bg,
      child: row,
    );
    row = Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: disabled ? null : (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: row,
    );
    row = MouseRegion(
      // `cursor: auto`（:162）——右栏文字不给 click 光标；close 自己 click。
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: row,
    );
    return Semantics(container: true, enabled: !disabled, child: row);
  }
}

/// 600 → `FontWeight.w600`（`$font-transfer_header_all-fontWeight: 600` 的
/// double → FontWeight 映射）。
FontWeight _fontWeightOf(double value) {
  final weight = (value / 100).round().clamp(1, 9);
  return FontWeight.values[weight - 1];
}

String _totalText(String template, int n) =>
    template.replaceFirst(r'${total}', '$n');

/// Widget-internal metrics and provenance anchors (upstream values kept out of
/// the theme). See tool/generate_transfer.py for the 50 = 47 FIELDS + 3 MOTION
/// + 0 INTERNAL accounting — the HARDCODES (另列) snippets below are checked to
/// appear in this file.
abstract final class _TransferMetrics {
  /// zh 文案硬编码（locale/source/zh_CN.ts:161-171，逐字留档）：
  /// ```dart
  ///     Transfer: {
  ///         emptyLeft: '暂无数据',
  ///         emptySearch: '无搜索结果',
  ///         emptyRight: '暂无内容，可从左侧勾选',
  ///         placeholder: '搜索',
  ///         clear: '清空',
  ///         selectAll: '全选',
  ///         clearSelectAll: '取消全选',
  ///         total: '总个数：${total}',
  ///         selected: '已选个数：${total}',
  ///     },
  /// ```
  static const String emptyLeft = '暂无数据';
  static const String emptySearch = '无搜索结果';
  static const String emptyRight = '暂无内容，可从左侧勾选';
  static const String searchPlaceholder = '搜索';
  static const String clearLabel = '清空';
  static const String selectAllLabel = '全选';
  static const String clearSelectAllLabel = '取消全选';
  static const String totalTemplate = '总个数：\${total}';
  static const String selectedTemplate = '已选个数：\${total}';

  /// `@include font-size-small` → `$font-size-small: 12px`
  /// （packages/semi-theme-default/scss/mixin.scss；transfer.scss:48/207/221）。
  static const double fontSizeSmall = 12;

  /// `@include font-size-regular`（transfer.scss:75 item 文字）→
  /// `$font-size-regular: 14px`（mixin.scss）。
  static const double fontSizeRegular = 14;

  /// `DEFAULT_PAGE_SIZE: 10`（transfer/constants.ts:14；分页延期——本移植未消费）。
  // ignore: unused_field
  static const int defaultPageSize = 10;

  // -- HARDCODES（另列）上游片段逐字留档（生成器 assertIn 锚点）--------------
  //
  // transfer.scss:22/26 `cursor: not-allowed`（整机/header/item disabled 光标）
  // → MouseRegion(SystemMouseCursors.forbidden)。
  //
  // transfer.scss:103-104 close-icon 默认
  //     cursor: pointer;
  //     visibility: hidden;
  // → Visibility(visible: hover && !disabled)（maintainSize 保持占位）；hover 显
  // （:166-168）
  //     flex-shrink: 0;
  //     visibility: visible;
  //     cursor: pointer;
  // （:170-171 disabled close `visibility: hidden` 永隐）。
  //
  // transfer.scss:74 `user-select: none`（item 文本不可选——GestureDetector 行
  // 手势即语义）。
  //
  // transfer.scss:176 `word-break: break-all`（右栏文字断词）。
  //
  // transfer.scss:162 `cursor: auto`（右栏行——MouseRegion 不设光标）。
  //
  // transfer.scss:81 `transition: background-color` 三字段消费见
  // `_TransferSourceRow`/`_TransferSelectedRow` 的 AnimatedContainer。
  //
  // 拖拽延期 note-only：transfer.scss:182 `flex-shrink: 0;` / :183 `cursor: move`
  // （拖拽 handler）、:193 `opacity: 0;`（sortable-item-active）、:8
  // `// max-height: 412px`（根注释）——本移植未消费（draggable 延期）。
  //
  // `>.#{$prefix}-spin {`（transfer.scss:134-137 `width: 100%; flex-grow: 1`
  // 覆写——loading Spin 覆盖左栏）。
}
