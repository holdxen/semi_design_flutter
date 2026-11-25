# SemiDataGrid × Glide Data Grid：功能对照与缺口报告

**核对日期**：2026-11-25。**对照基线**：本地 Glide Data Grid `6.0.4-alpha25`（`0875d78c`）与 `semi_design_flutter`（`b18255a0`），两侧被比较的组件源码均无工作区改动。主对照是 Glide 包公开的 `DataEditor`（`DataEditorAll`） ↔ Flutter `SemiDataEditor`；底层 `DataGrid` ↔ `SemiDataGrid` 单独核对。Glide 的底层 `DataGrid` 未从 core 包入口导出，因此底层差异是实现层对照，不一律算作高层公开 API 缺口。Glide 官方 `cells` / `source` 扩展包另计，不混入 core。以该版本源码为准，不把旧文档里已经移除的 API 算成缺口。

**验证口径**：对照公开类型、入口接线、实际消费点与测试。**已覆盖**表示主路径有对应实现，不表示所有边界或像素完全一致；**部分**表示有对应入口或实现但行为不完整；**缺失**表示调用方没有可用的对应能力；**平台差异**表示无需照搬 Web 机制。证据中 `G:` 相对 Glide 仓库的 `packages/core/src/`，`F:` 相对 Flutter 仓库的 `lib/src/semi_data_grid/`；测试路径相对 Flutter 仓库根目录。

## 1. 结论

SemiDataGrid 已具备电子表格的主体：视口按需绘制、冻结列/尾行、选区、键盘移动、单元格编辑、填充、分组、列宽拖动和查找。**当前主要差距不是再增加几个控件，而是让已暴露的能力真正生效，并补齐调用方控制表格的 API。**

| 优先级 | 最值得先补的差异 | 对用户的影响 |
| --- | --- | --- |
| P1 · 正确性 | 剪切不清源；行标记开启后粘贴取值坐标错位；鼠标事件丢失修饰键 | 数据未按预期更新，或选错范围；粘贴到最后一列还可能越界 |
| P1 · 可见反馈 | 图片缩略图、拖列预览、列宽指示线、搜索命中高亮和 `damage()` 刷新 | 功能有回调或 API，但最终画面不对或没有变化 |
| P1 · 可集成性 | `gridSelection` 受控输入、编辑校验和公开控制器 | 业务无法可靠回写选区、拒绝无效编辑、主动定位或刷新单元格 |
| P2 · 完整度 | 原生滚动与触摸、异步批量取数、富剪贴板、追加行列异步语义、无障碍细节 | 影响移动端、远程大表和交互复杂的业务；移动端是目标时，触摸滚动升为 P1 |
| P3 · 扩展 | `cells` 的 13 个 renderer、`source` 的 5 个数据适配器 | 不阻塞 core 达到可用对等，但要覆盖 Glide 全生态需另排期 |

## 2. Core 功能矩阵

| 能力 | 对照结果 | 证据（上游 → Flutter） |
| --- | --- | --- |
| 数据入口：`columns`、`rows`、`getCellContent` | **已覆盖**。数据归调用方，按列/行坐标读取，有编辑回调但不会替调用方持久化。 | `G:data-editor/data-editor.tsx:286,318,546` → `F:data_editor/semi_data_editor.dart:47,147,1459,1480` |
| 视口虚拟化、固定/动态行高、冻结列和尾部数据行 | **已覆盖主路径**。`smoothScrollX/Y` 都支持像素级偏移；冻结尾部数据行不等于固定“新增行”，后者有缺口。 | `G:internal/scrolling-data-grid/scrolling-data-grid.tsx:121` → `F:internal/scrolling_data_grid/semi_scrolling_data_grid.dart:69`、`F:internal/data_grid/render/semi_render_walk.dart:28` |
| 默认尺寸与列分组 | **部分**。Glide 默认行高 34，分组头高度跟随普通头，检测到列 `group` 就启用分组；Flutter 默认行高 32、分组头固定默认 36，必须显式传 `enableGroups: true`。 | `G:data-editor/data-editor.tsx:897,1131` → `F:data_editor/semi_data_editor.dart:57,2964` |
| 列宽、自动测宽、`grow`、拖动和双击边线重测 | **部分**。覆盖自动测宽、拖动事件、双击边线；拖动指示线未接线，缺公开批量重测；调用方写回列宽应替换列表，原地修改会保留旧列宽。 | `G:data-editor/use-column-sizer.ts:27,78`、`G:data-editor/data-editor.tsx:751` → `F:data_editor/semi_column_sizer.dart:99`、`F:data_editor/semi_data_editor.dart:1894,2607`、`test/semi_data_grid_resize_repaint_test.dart:106` |
| 表头、列组动作、图标、菜单、指示器、逐行/列/单元格样式、自绘与高亮区域 | **渲染主路径已覆盖，交互部分**。有分组表头、SVG sprite、自绘与主题叠加；普通表头点击、组动作的可见反馈与重命名契约仍有缺口，见下节。`fixedShadowX/Y` 仅底层可配置；`GridColumn.menuIcon` 上游可用字符串图标，Flutter 限三角/点状枚举。 | `G:data-editor/data-editor.tsx:229–264,473,4230`、`G:internal/data-grid/data-grid-types.ts:148–166` → `F:data_editor/semi_data_editor.dart:249–297,384–401`、`F:internal/data_grid/semi_types.dart:1050`、`F:internal/data_grid/semi_data_grid.dart:150` |
| 行分组、折叠与数据索引 | **部分**。已有嵌套分组、折叠状态、导航/跨组选区策略，并公开了路径查询、更新与行索引映射；缺少 Glide `useRowGrouping` 一次包装数据回调和路径更新的入口，也未移植数字简写组。两端均需业务写回折叠状态。不要与 `source` 包的**列组**折叠混淆。 | `G:data-editor/row-grouping-api.ts:17–73`、`G:docs/examples/row-grouping.stories.tsx:75–115` → `F:semi_data_grid.dart:25`、`F:data_editor/semi_row_grouping.dart:12–62,265,319–410,452–487` |
| 行标记、行/列/矩形/多范围选区、span、混合策略 | **部分**。数据结构和选区逻辑具备，有变更回调，但 `SemiDataEditorProps` 缺 `gridSelection` 受控输入；鼠标事件把 Shift/Ctrl/Meta 写死为 `false`，影响 Shift+点击扩选、Ctrl/Cmd+点击多选等依赖修饰键的路径。键盘事件单独读了修饰键。 | `G:data-editor/data-editor.tsx:368–409,494–510`、`G:internal/data-grid/data-grid.tsx:1076–1092` → `F:data_editor/semi_data_editor.dart:511–519,1507–1529`、`F:data_editor/semi_handle_select.dart:154,289,360`、`F:internal/data_grid/semi_data_grid.dart:1084–1185,1304–1316` |
| 键盘导航、编辑激活、焦点样式 | **部分**。方向键、Tab/Enter、Esc、键入编辑、快捷键配置、激活回调已有。缺 `trapFocus` 与 `drawFocusRing: 'no-editor'`；浮层虽然有 `activation` 入参，高层给键盘/指针两支都传了 `null`，自定义编辑器拿不到激活来源。 | `G:data-editor/data-editor.tsx:575–581,676–693,3447` → `F:data_editor/semi_key_handler.dart`、`F:data_editor/semi_data_editor.dart:53–86,3249–3266` |
| 单格/批量编辑、删除、填充 | **已覆盖主路径**。有 `onCellEdited`/`onCellsEdited`、删除拦截、向下/向右填充、填充柄与方向配置；可取消填充。剪切的清源不是 Delete 键那条路径，单独计缺口。 | `G:data-editor/data-editor.tsx:205–217,247–256,668–670` → `F:data_editor/semi_data_editor.dart:1480,2133,2671`、`F:data_editor/semi_key_handler.dart:844`、`test/semi_data_grid_test.dart:2164–2377` |
| 编辑校验、覆写浮层编辑器 | **缺失于高层**。上游 `validateCell` 可拒绝或改写值；`provideEditor` 可覆写编辑器。Flutter 低层浮层已经有这两个入口，高层未暴露/未接入；当前可通过 renderer 自带的 `provideEditor` 定制特定类型，但不是全局高层钩子。 | `G:data-editor/data-editor.tsx:277–281,478,4321–4327` → `F:internal/data_grid_overlay_editor/semi_data_grid_overlay_editor.dart:43–86,120–159,204–219`、`F:data_editor/semi_data_editor.dart:3249–3266` |
| 编辑浮层容器与点击外部 | **部分/平台差异**。已有 Flutter 内部浮层、位置限制与提交/取消；没有 `isOutsideClick` 自定义判定或跨容器 portal 等价物。无需复制 DOM ref，可按需提供 Flutter overlay 宿主/豁免区。 | `G:data-editor/data-editor.tsx:660–665,698,4325` → `F:data_editor/semi_data_editor.dart:3063–3099,3249`、`F:internal/data_grid_overlay_editor/semi_data_grid_overlay_editor.dart` |
| 批量取数 `getCellsForSelection` | **部分**。Flutter 高层只接同步回调；没有上游 `true` 自动逐格读取，或异步 thunk + `AbortSignal`。代码中存在 `SemiGetCellsThunk` 类型，但高层没有消费它，选区扩展、复制、搜索和测宽不能直接走异步数据。 | `G:data-editor/data-editor.tsx:583–604`、`G:data-editor/use-cells-for-selection.ts:7` → `F:data_editor/semi_data_editor_fns.dart:11`、`F:data_editor/semi_data_editor.dart:1367`、`F:internal/data_grid/semi_types.dart:981–990` |
| 搜索：内置扫描、受控值/结果、导航与预亮 | **部分**。内部搜索、进度/取消和结果跳转有实现，但结果没传给底层 `prelightCells`；受控结果入口也没有按外部结果初始化/同步 `_searchStatus`，而上一项/下一项依赖该状态。需要同时补查找高亮、受控数量与导航，以及行标记坐标。 | `G:internal/data-grid-search/data-grid-search.tsx:131–161,183–199,321–348,491` → `F:data_editor/semi_data_editor.dart:598–675,702–721,2955–3035`、`F:internal/data_grid/semi_data_grid.dart:1392–1393` |
| 复制/粘贴格式与配置 | **部分**。有 TSV、带表头复制、HTML 编解码与系统读取尝试，但系统写入只写 `text/plain`；无布尔 `onPaste` 简写（回调返回布尔可达成配置）。高层 `_paste()` 还额外要求 `getCellsForSelection`；上游粘贴可按单格回调读取，不需要批取回调。 | `G:data-editor/data-editor.tsx:637,3640–3705,3772–3875` → `F:data_editor/semi_clipboard.dart:19–44,123–135,239`、`F:data_editor/semi_data_editor.dart:2803–2814` |
| 剪切源清除 | **接线缺口**。Glide 在 `onDelete` 允许后会执行 `deleteRange`；Flutter 执行 `onDelete` 判定后函数结束，无默认删除、无编辑提交。注意：本次对照的 Glide 提交在不传 `onDelete` 时也会在访问 `effectiveSelection.current` 处遇到 `undefined`，不应复制这个上游边界；Flutter 应分别验收未配置、允许、拒绝与返回替代选区。 | `G:data-editor/data-editor.tsx:3879–3905` → `F:data_editor/semi_clipboard.dart:326–370`、`F:data_editor/semi_data_editor.dart:2774–2786` |
| 行标记下的粘贴 | **坐标缺口**。Flutter 把含标记列的目标传给 `widget.props.getCellContent`（外部数据坐标）。`onPaste` / 提交回调去掉了偏移，但读取被编辑单元格时没有；会取错列类型/配置，最后一列可能越界。Glide 在该位置使用 `getMangledCellContent`。 | `G:data-editor/data-editor.tsx:3695–3705,3723–3765` → `F:data_editor/semi_data_editor.dart:1459,1484–1494,2803–2814`、`F:data_editor/semi_clipboard.dart:140–162,185–215` |
| 增加行/列和尾行固定 | **部分**。有新增空白行提示、发出追加请求、行尾/列尾键盘触发、追加后选中/编辑；Glide 等待 Promise，并支持行 `top/bottom/index`、列 `left/right/index`。Flutter 行回调无返回值，列只消费同步结果；检查依赖后续帧。`trailingRowOptions.sticky` 已声明却没计入冻结尾行。 | `G:data-editor/data-editor.tsx:221–225,291–302,1687–1793,4277–4279` → `F:data_editor/semi_data_editor.dart:212–219,1121–1250,2973`、`F:internal/data_grid/semi_types.dart:994–1017` |
| 行/列内部拖动与拖动时自动滚动 | **部分**。已有确认移动/拒绝移动、行标记拖拽和边缘自动滚动；列重排预览和 resize 指示绘制未接到当前渲染参数，外部拖放是另一个能力。 | `G:internal/data-grid-dnd/data-grid-dnd.tsx:13–79,366–455` → `F:data_editor/semi_data_editor.dart:1973,2530,3023–3026`、`F:internal/data_grid/semi_data_grid.dart:1358–1402` |
| 跨组件拖放 | **缺失**。没有 Glide `isDraggable`（表头/单元格）、`onDragStart`、`onDragOverCell`、`onDragLeave`、`onDrop` 的业务等价物。内部拖列/拖行不等于可把单元格、文件或外部数据拖进拖出。 | `G:internal/data-grid/data-grid.tsx:188–211,1565–1669` → `F:data_editor/semi_data_editor.dart:47–143`、`F:internal/data_grid/semi_data_grid.dart:1404–1446` |
| Pointer 边界与取消 | **部分**。已处理悬停、点击、右键菜单与长触碰标记；普通释放向外层固定传 `isOutside: false`，无 `onPointerCancel` 去收尾拖动/填充。需要验证移出表格释放、滚动抢占手势后恢复、非主键的区分。 | `G:internal/data-grid/data-grid.tsx:1138–1186` → `F:internal/data_grid/semi_data_grid.dart:1084–1109,1154–1204,1415–1422` |
| 触屏、系统滚动条与滚动宿主 | **部分**。Flutter 用轮滚信号和内部偏移，支持键盘/自动滚动但无 `Scrollable` / `Scrollbar` 路径、手指拖动和惯性、按需方向锁；`rightElement`/`rightElementProps`（可滚到末尾、贴边或填充）及 `initialSize` 无高层对应。 | `G:internal/scrolling-data-grid/scrolling-data-grid.tsx:35–67`、`G:internal/scrolling-data-grid/infinite-scroller.tsx:204–285,329–372` → `F:data_editor/semi_data_editor.dart:2876–2934,3060–3069` |
| 无障碍 | **部分**。Flutter 有可见单元格标签、选中/聚焦状态与激活动作，不能说没有无障碍。当前语义树收到完整的映射列而不是画笔的有效可见列，列节点没有对应实际格子的尺寸，独立冻结尾行也不在普通可见行遍历里；外部异步更新的语义刷新缺高层入口。真实读屏体验未验证。 | `G:internal/data-grid/data-grid.tsx:1737–1856` → `F:internal/data_grid/semi_data_grid.dart:928–1061,1353–1356,1440`、`test/semi_data_grid_test.dart:4024–4180` |
| 渲染缓存、局部刷新与大表性能 | **部分**。Flutter 有 `shouldRepaint`、`RepaintBoundary`、文本缓存与视口绘制；滚动仍会重画可见区域，没有 Glide 的滚动 blit、独立表头画布、单双缓冲切换等同款实现。公开 `damage` 未接画笔；动态行高滚动时总高度还会逐行累加。不要以缺少 Web 算法直接推断 Flutter 性能差多少，需用同数据 profile。 | `G:internal/data-grid/data-grid.tsx:934–950`、`G:internal/data-grid/render/data-grid-render.ts:170–238` → `F:internal/data_grid/semi_data_grid.dart:225–239,1434–1439`、`F:internal/data_grid/render/semi_data_grid_painter.dart:34–76,1384–1427`、`F:data_editor/semi_data_editor.dart:2835–2850,3067` |

### 2.1 容易遗漏的交互和渲染差异

| 场景 | 具体差异与证据 |
| --- | --- |
| 表头点击 | 主键按下清空 `_lastMouseSelectLocation`，只在另一按钮分支赋值；释放时主键回调却要求该值匹配。普通鼠标点击触发不了 `onHeaderClicked` / `onGroupHeaderClicked`，整组选列也受影响。菜单未隔离普通按下/释放。`G:data-editor/data-editor.tsx:2049,2470–2507`、`G:internal/data-grid/data-grid.tsx:1101–1113` ↔ `F:data_editor/semi_data_editor.dart:2398–2406,2602–2648`、`F:internal/data_grid/semi_data_grid.dart:1196–1205`。 |
| 分组后的复制与选区 | Glide 整列复制使用分组后的显示行数，活动格随表尺寸收缩越界时清空选区；Flutter 复制/剪切仍传原始 `props.rows`，展开可能漏掉底部显示行，折叠后可能多请求行。折叠或删列后，还可能沿用旧活动格和复制范围。`G:data-editor/data-editor.tsx:930–936,3837–3846,3951–3958` ↔ `F:data_editor/semi_data_editor.dart:710–752,1519–1536,2774–2797`、`F:data_editor/semi_clipboard.dart:291–301`。 |
| 列分组重命名 | Glide 只给非空组加重命名动作，用展示名作为编辑初值和回调首参；Flutter 对空组也加动作，使用原始组键。业务把组键和展示名分开时，二者收到的值不同。`G:data-editor/data-editor.tsx:1401–1421,3976–3988` ↔ `F:data_editor/semi_data_editor.dart:1032–1065`。 |
| 事件契约 | hover/move、部分 click/activate、填充与列移动仍给业务含行标记的内部坐标；菜单 `screenPosition` 实际是局部坐标。`onCellClicked.preventDefault` 是空操作，主/中/右键也未完整区分。`G:data-editor/data-editor.tsx:2245–2269,2367–2398,2659–2677,2808` ↔ `F:data_editor/semi_data_editor.dart:1766–1803,2167,2436–2464,2519–2550,2982–3022`、`F:internal/data_grid/semi_data_grid.dart:1084–1098,1174–1185`。 |
| 列宽重测与 grow | 双击边线只取一列样本，却拿目标列号索引，非首列可能只测标题；启用行标记时又用内部列号索引业务列。自动宽度与 `newSizeWithGrow` 也有行标记/grow 差异。`G:data-editor/data-editor.tsx:1118–1129,2193–2227` ↔ `F:data_editor/semi_data_editor.dart:893–916,1901–1932,2063–2097`、`F:data_editor/semi_column_sizer.dart:38–48,118–146`。 |
| 拖选与配置 | 行标记拉选、避开标记列/新增行、限制鼠标拖选跨组不完整；`blockSpanning` 接到键盘但没接普通拖选。只改选择模式/混合策略时，鼠标处理对象可能沿用旧配置。`G:data-editor/data-editor.tsx:2708–2782` ↔ `F:data_editor/semi_data_editor.dart:702–746,1359–1364,1561–1563,2105–2201`。 |
| 键盘与触摸 | 缺长按菜单和滚动后抑制点击的完整行为；`touchMode` 不随设备切换。键盘不消费 `KeyRepeatEvent`，事件位置取范围左上角。浮层没有使用方向提交等快捷键配置，首次聚焦未自动选中首个可见数据格。`G:data-editor/data-editor.tsx:2437–2481,3148–3184,4158–4183`、`G:internal/data-grid/data-grid.tsx:1376–1434` ↔ `F:data_editor/semi_data_editor.dart:2582–2599,2988–2992`、`F:internal/data_grid/semi_data_grid.dart:1297–1342,1389`、`F:internal/data_grid_overlay_editor/semi_data_grid_overlay_editor.dart:171–195`。 |
| 搜索输入与粘贴键 | `searchValue` 未驱动输入框，默认只在传 `onSearchClose` 时显示关闭按钮。`_paste()` 没有检查 `keybindings.paste`。`G:internal/data-grid-search/data-grid-search.tsx:111–142,418–453`、`G:data-editor/data-editor.tsx:3583,4269–4272` ↔ `F:internal/data_grid_search/semi_data_grid_search.dart:231–239,339–369`、`F:data_editor/semi_data_editor.dart:2774–2817,3082–3097`。 |
| 滚动与定位 | 上游随视口/数据尺寸重算并去重；Flutter 重建未明确重跑 `_applyScroll()`，窗口可能滞后，滚动回调也不去重。`scrollOffsetX/Y` 只在初始化读取。空表钳制可得 `-1`；横向范围重复计入冻结列，内部 `_scrollTo` 混用用户列与行标记坐标。`G:internal/scrolling-data-grid/scrolling-data-grid.tsx:105–117,159–252`、`G:data-editor/use-initial-scroll-offset.ts:65`、`G:data-editor/data-editor.tsx:1524–1655` ↔ `F:internal/scrolling_data_grid/semi_scrolling_data_grid.dart:154–165`、`F:data_editor/semi_data_editor.dart:523–532,702–721,1842–1850,2858–2916,2943–2955`。 |
| 拖动收尾 | `onColumnProposeMove` 只在松开时使用，不能取消预览；移动完成未像上游选中目的列。拖动或填充的部分释放分支在停止自动滚动前提前返回。`G:internal/data-grid-dnd/data-grid-dnd.tsx:220–297,347–362`、`G:data-editor/data-editor.tsx:2332–2358,2659–2677` ↔ `F:data_editor/semi_data_editor.dart:2105–2168,2530–2664`。 |
| 悬停、光标与装饰 | 表头/分组表头悬停拿不到 `hoverInfo`，同格移动不保证重绘，renderer 的 hover 坐标从网格原点算起。光标主要是调整列宽/默认；RTL、冻结交界裁剪、空白区底色延伸、填充柄描边有简化。`G:internal/data-grid/data-grid.tsx:1306–1359`、`G:internal/data-grid/render/data-grid-render.header.ts:57–129,332–412`、`G:internal/data-grid/render/data-grid.render.rings.ts:33–143,194–343` ↔ `F:internal/data_grid/semi_data_grid.dart:1119–1151,1281–1294,1383–1389`、`F:internal/data_grid/render/semi_data_grid_painter.dart:401–417,655–766,1180–1377`。 |
| 无障碍节点 | 格子缺实际尺寸和逐格焦点。缓存未纳入高度、行高与标题，高层没按行标记配置 `firstColAccessible`。`IgnorePointer` 包裹后真实读屏的激活动作需实测。`G:internal/data-grid/data-grid.tsx:1676–1714,1737–1856` ↔ `F:internal/data_grid/semi_data_grid.dart:934–1061,1440`、`F:data_editor/semi_data_editor.dart:2955–3035`。 |

### 2.2 公开属性缺口索引

上游直接字段与继承链排除规则见 `G:data-editor/data-editor.tsx:113–164,205–699`。

| 上游入口 | Flutter 对应 |
| --- | --- |
| `gridSelection`、`validateCell`、`provideEditor`、`trapFocus` | 高层缺失。低层选区输入、浮层校验/编辑器、键盘 `trapFocus` 未贯通现成 Editor（`F:data_editor/semi_data_editor.dart:47–143,1547–1607,3249–3266`）。 |
| `imageEditorOverride`、`markdownDivCreateNode`、`isOutsideClick`、`portalElementRef` | 无专用入口。前两项可替换 renderer/editor，后两项需 Flutter 浮层宿主与点击判定（`F:cells/semi_cell_registry.dart:122–137,193–211`、`F:data_editor/semi_data_editor.dart:3063–3074`）。 |
| `renderers`、`customRenderers`、`columnSelectionMode` | 有替代：`rendererLookup` 支持默认覆盖和自定义类型，`columnSelectionModeMulti` 对应模式选择（`F:cells/semi_cell_types.dart:414–431`、`F:data_editor/semi_data_editor.dart:202,382,1398–1404`）。 |
| `rowMarkerWidth`、`rowMarkerStartIndex`、`rowMarkerTheme` | 废弃别名由 `SemiRowMarkerOptions.width/startIndex/theme` 代替（`F:internal/data_grid/semi_types.dart:903–929`）。 |
| `imageWindowLoader`、`fixedShadowX/Y` | 仅低层可配；阴影接到画笔，图片加载器未接（`G:data-editor-all.tsx:8–31`、`G:internal/data-grid/data-grid.tsx:80–89,157` ↔ `F:internal/data_grid/semi_data_grid.dart:92–98,384–455,1358–1402`）。 |
| `isDraggable`、`onDragStart`、`onDragOverCell`、`onDragLeave`、`onDrop` | 外部拖放缺失。上游 Editor 类型排除了 `onDragEnd`（`G:internal/data-grid/data-grid.tsx:188–211`、`G:data-editor/data-editor.tsx:148` ↔ `F:data_editor/semi_data_editor.dart:47–143`）。 |
| `initialSize`、`preventDiagonalScrolling`、`rightElement`、`rightElementProps` | 无直接对应。父布局能提供尺寸，旁置组件不具备末端滚入、贴边或填充语义（`G:internal/scrolling-data-grid/scrolling-data-grid.tsx:35–67` ↔ `F:data_editor/semi_data_editor.dart:2919–2957,3060–3100`）。 |
| `experimental` | `strict` 有高层开关；`disableAccessibilityTree`、`disableMinimumCellWidth` 的对应或近似入口在低层。`hyperWrapping` 传到 Flutter 绘制函数但不生效，见下一节。`paddingRight/Bottom`、`isSubGrid`、`renderStrategy` 无直接入口，浏览器 rescaling、滚动条宽度和 DOM event target 属平台适配（`G:internal/data-grid/data-grid.tsx:246–265` ↔ `F:data_editor/semi_data_editor.dart:198–201,3033`、`F:internal/data_grid/semi_data_grid.dart:83–98`）。 |
| `width`、`height`、`className` | Flutter 由父布局控制尺寸，无 Glide 按数据计算理想默认尺寸的行为；CSS class 无需移植（`G:data-editor/data-editor.tsx:351–362,4189–4224` ↔ `F:data_editor/semi_data_editor.dart:2939–2957`）。 |
| `onPaste`、`getCellsForSelection`、`drawFocusRing`、`verticalBorder`、`onCellsEdited` | 同名但契约更窄，见主表。`verticalBorder` 只接回调且原样传底层，`onCellsEdited` 要求 `bool`，上游可不返回（`G:data-editor/data-editor.tsx:217,604,619,637,693,3967–3973` ↔ `F:data_editor/semi_data_editor.dart:159,172,2981`）。 |

`setScrollDir` 虽出现在上游继承链，实际 Editor 传的是自有 setter（`G:internal/data-grid-dnd/data-grid-dnd.tsx:79`、`G:data-editor/data-editor.tsx:4314`）。`prelightCells`、`lockColumns`、`onCellFocused` 也不是此版本 Glide Editor 的可配置项。浏览器超高容器分段和 Canvas 缓冲属于实现选择，Flutter 应以可滚动范围与实际帧开销验收，而非复制机制。

### 2.3 底层 `DataGrid` ↔ `SemiDataGrid` 独立对照

Glide 的 core 包对外导出的是 `DataEditor` / `DataEditorCore`，两层不要混比；Flutter 还直接导出了 `SemiDataGrid`、`SemiDataGridProps` 和 `SemiDataGridController`。下列问题因此也会影响绕过 Editor 直接用 Flutter 网格的调用方（`G:index.ts:45–54`、`G:internal/data-grid/data-grid.tsx:63–75,319–328` ↔ `F:semi_data_grid.dart:28–38`）。

| 底层能力 | 对照结果与证据 |
| --- | --- |
| 像素偏移、冻结分界阴影 | **已覆盖主路径 / 平台差异**。Flutter 画笔绘制冻结阴影；低层 `smoothScrollX/Y` 不参与绘制，高层滚动处理才读这些开关。Glide 低层还用它们决定阴影 CSS 过渡，不应把该过渡等同于支持像素滚动。`G:internal/data-grid/data-grid.tsx:1878–1919` ↔ `F:internal/data_grid/semi_data_grid.dart:81–82,207–208`、`F:internal/data_grid/render/semi_data_grid_painter.dart:95–154`、`F:data_editor/semi_data_editor.dart:2889–2890`。 |
| 跨列 `span` 与冻结区 | **部分**。两边的底层画笔都能按冻结区分片绘制 span；业务层启用行标记时，Glide 平移所有带 span 的格，Flutter 只平移 `SemiTextCell`，但数字等类型也支持声明 span。`G:internal/data-grid/render/data-grid-render.cells.ts:218–265`、`G:data-editor/data-editor.tsx:1373–1379` ↔ `F:internal/data_grid/render/semi_data_grid_painter.dart:258–321`、`F:data_editor/semi_data_editor.dart:1453–1474`、`F:internal/data_grid/semi_types.dart:446–462`。 |
| 自绘表头与列组动作 | **部分**。Glide 自绘表头可访问 sprite 管理器，列组动作收到完整鼠标事件；Flutter 自绘参数未提供该管理器，组动作只给边界，组图标采用 `IconData`。当前低层能命中组动作，但只将正文悬停位置传给画笔，而组动作只在组头悬停时绘制，存在能点却看不见的热区。`G:internal/data-grid/data-grid-types.ts:41–58`、`G:internal/data-grid/data-grid.tsx:1184–1192` ↔ `F:cells/semi_cell_types.dart:104–153`、`F:internal/data_grid/render/semi_draw_grid_arg.dart:25–49`、`F:internal/data_grid/semi_data_grid.dart:1187–1193,1383–1387`、`F:internal/data_grid/render/semi_data_grid_painter.dart:978–989,1023–1053`。 |
| 图片窗口与异步重绘 | **部分**。Glide 更新窗口时包含实际绘制范围和冻结尾行；Flutter 给加载器的冻结尾行列表为空，且没把加载器传给画笔。图片完成回调只 `setState`，参数不变时可能被 `shouldRepaint` 跳过；修复需要同时接线、按实际视口维护窗口，并显式使画笔失效。`G:internal/data-grid/render/data-grid-render.ts:756–778` ↔ `F:internal/data_grid/semi_data_grid.dart:384–455,1358–1402`、`F:internal/data_grid/render/semi_data_grid_painter.dart:487–502,1384–1427`。 |
| 低层控制器 | **部分**。Glide 低层 `getBounds()` 默认取 `(0,-1)` 的表头格，返回浏览器视口坐标；Flutter 需传两个可空参数，空列代入 `-1`，返回网格局部矩形。Flutter `focus()` 聚焦网格，未像 Glide 优先恢复逐格语义焦点；`damage(cells)` 不消费格坐标，也没使画笔刷新。`G:internal/data-grid/data-grid.tsx:459–497,934–950,1676–1729` ↔ `F:internal/data_grid/semi_data_grid.dart:225–239,511–547,1434–1439`。 |
| 列拖动、列宽提示和填充光标 | **接线缺口**。Glide 把拖动/调整状态交给低层渲染；Flutter 高层已传 `isResizing`、`resizeColumn`、`resizeIndicator` 和 `dragAndDropState`，低层组装画笔参数时未传，直接使用 `SemiDataGrid` 也不显示对应预览。`isFilling` 也未驱动 Glide 式填充十字光标。`G:internal/data-grid/data-grid.tsx:810–849,973–983` ↔ `F:data_editor/semi_data_editor.dart:2997–3003,3023–3026`、`F:internal/data_grid/semi_data_grid.dart:1358–1402`、`F:internal/data_grid/render/semi_data_grid_painter.dart:41–48,91–93,1114–1160`。 |
| 最小格宽与增强换行 | **部分**。最小格宽跳过绘制的阈值有对应；Glide 的 `hyperWrapping` 参与 `splitText`，Flutter 只透传到文本绘制入口，函数体不读该参数，仍是普通 `TextPainter` 换行。`G:internal/data-grid/render/data-grid-render.cells.ts:394`、`G:internal/data-grid/render/data-grid-lib.ts:510–525,584–596` ↔ `F:internal/data_grid/render/semi_data_grid_painter.dart:401`、`F:cells/semi_text_cell.dart:24–30`、`F:internal/data_grid/render/semi_draw_text.dart:36–95`。 |
| 填充柄样式与命中 | **部分**。两端都支持形状、尺寸和偏移；Glide 的 `outline` 影响实心填充柄描边，Flutter 不读取 `outline`，用固定线宽；Flutter 关闭焦点环后也关闭填充柄绘制与命中。`G:internal/data-grid/render/data-grid.render.rings.ts:194–201,269–320` ↔ `F:internal/data_grid/semi_types.dart:1141–1154`、`F:internal/data_grid/render/semi_data_grid_painter.dart:1348–1377`、`F:internal/data_grid/semi_data_grid.dart:863–891`。 |

## 3. Glide 的 9 个 DataEditorRef 方法逐一对照

签名见 `G:data-editor/data-editor.tsx:701–760`，实现见 `:1524–1793,3996–4121`。`SemiDataEditor` 只接 `key`/`props`（`F:data_editor/semi_data_editor.dart:405–416`），**9 项均无高层公开入口**，其中部分逻辑已存在。

| Glide 方法 | Flutter 已有实现 | 仍需补齐 |
| --- | --- | --- |
| `appendRow` | 私有 `_appendRow`（`F:data_editor/semi_data_editor.dart:1124`）。 | 对外调用、等待完成和新增位置。Glide 类型有 `behavior`，但此版本 ref 包装只转发前两个参数（`G:data-editor/data-editor.tsx:3999`）。 |
| `appendColumn` | 私有 `_appendColumn`（同文件 `:1202,1736`）。 | 对外调用、等待完成和异步 `left/right/index`。 |
| `updateCells` | 底层 `damage` 只通知（`F:internal/data_grid/semi_data_grid.dart:236–239`）。 | 主动刷新画布及相关语义，局部重绘另做性能验证。 |
| `getBounds` | 底层返回画布局部边界（同文件 `:231–234`）。 | 用户列坐标、全局格子/视口边界、省略参数时的行为。 |
| `focus` | 底层 `FocusNode`（同文件 `:225–229`）。 | 向高层公开，处理选中格和读屏焦点。 |
| `emit` | 有内部命令（`F:data_editor/semi_data_editor.dart:2746–2814`）。 | 主动触发 `copy`、`paste`、`delete`、`fill-right`、`fill-down`。 |
| `scrollTo` | 私有格子/轴向定位（同文件 `:1842–1887`）。 | 用户坐标、格子或像素目标、padding、对齐和滚动行为。 |
| `remeasureColumns` | 双击边线时重测（同文件 `:2607–2611`）。 | 按列选区批量重测，发出可回写宽度。 |
| `getMouseArgsForPosition` | 底层私有命中测试（`F:internal/data_grid/semi_data_grid.dart:1089,1122`）。 | 公开坐标转换及命中结果。 |

## 4. 内置单元格：13 种均已有 renderer，但不等于行为一致

Glide core 有 **11 个公开类型 + 2 个内部类型**；`Custom` 是扩展入口，不计为第 14 种 renderer。清单：`G:cells/index.ts:17–31`、`G:internal/data-grid/data-grid-types.ts:278–289`；Flutter 注册表：`F:cells/semi_cell_registry.dart:173–210`。

| 单元格 | 已有能力 / 差异 | 双方锚点 |
| --- | --- | --- |
| Text | 有绘制、换行、测宽、编辑、删除、粘贴。Flutter 编辑和删除同步改 `displayData`，Glide 只改 `data`。编辑浮层没透传 validated selection；hover 区域和文本光标有差异。 | `G:cells/text-cell.tsx:9–63`、`G:internal/data-grid/render/draw-edit-hover-indicator.ts:17–59` ↔ `F:cells/semi_text_cell.dart:14–87`、`F:internal/data_grid/render/semi_draw_text.dart:139–168` |
| Number | 有绘制、数字编辑和粘贴；千分位只支持布尔开关，不支持自定义字符串。**删除会保留旧值**：`copyWith(data: null)` 用 `??`，无法把数字清空。 | `G:cells/number-cell.tsx:12–63`、`G:internal/data-grid/data-grid-types.ts:353–364` ↔ `F:cells/semi_number_cell.dart:41–90`、`F:internal/data_grid/semi_types.dart:468–512` |
| Boolean | 接近：复选框命中切换、删除和粘贴一致，无编辑浮层。以枚举表达空/不确定值，透明度用 Flutter 图层实现，不按像素完全复刻。 | `G:cells/boolean-cell.tsx:15–135` ↔ `F:cells/semi_boolean_cell.dart:9–188`、`F:internal/data_grid/semi_types.dart:274` |
| Bubble | 接近：胶囊显示、选中底色、测宽、只读浮层，不能直接写入/粘贴。Glide 无障碍文案约 10,000 字符封顶，Flutter 直接全部拼接。Bubble 不是 TagsCell 的替代品。 | `G:cells/bubble-cell.tsx:9–67`、`G:common/utils.tsx:259–274` ↔ `F:cells/semi_misc_cells.dart:25–127`、`F:internal/data_grid_overlay_editor/private/semi_bubbles_overlay_editor.dart:8–39` |
| Drilldown | 有胶囊、测宽和只读浮层。**图片只出现在浮层**；Glide 还绘制缩略图、计入图片宽度并给边框加阴影。 | `G:cells/drilldown-cell.tsx:14–37,93–116,129–158,207–242` ↔ `F:cells/semi_misc_cells.dart:459–554`、`F:internal/data_grid_overlay_editor/private/semi_drilldown_overlay_editor.dart:40–59` |
| Image | 有多图加载、圆角、对齐、测宽、删除、粘贴和查看浮层。浮层用 `PageView`，没有默认 carousel 箭头/循环，也没有 `renderImage` 或专用 image editor hook；**表格缩略图因图片加载器未接画笔而不会画**。 | `G:cells/image-cell.tsx:8–64,69–116`、`G:internal/data-grid-overlay-editor/private/image-overlay-editor.tsx:7–49` ↔ `F:cells/semi_cell_registry.dart:20–170`、`F:internal/data_grid_overlay_editor/private/semi_image_overlay_editor.dart:28–64` |
| Loading | 有 skeleton 宽高和波动、固定测宽。默认宽度时 Glide 画 skeleton，Flutter 同样处理；颜色与随机序列不逐位对齐。 | `G:cells/loading-cell.tsx:7–53` ↔ `F:cells/semi_misc_cells.dart:133–191` |
| Markdown | 有原文绘制、原文编辑、删除和粘贴。**浮层预览也显示原文（最多 4 行），不是 Glide 的 Markdown 渲染预览**，也没有 `markdownDivCreateNode`。 | `G:cells/markdown-cell.tsx:8–43`、`G:internal/data-grid-overlay-editor/private/markdown-overlay-editor.tsx:32–61` ↔ `F:cells/semi_misc_cells.dart:308–356`、`F:internal/data_grid_overlay_editor/private/semi_markdown_overlay_editor.dart:46–94` |
| Protected | 有不可编辑的遮罩。Glide 绘制 12 个星号且固定测宽 108；Flutter 画斜线底纹加一个星形，不走该固定宽度。 | `G:cells/protected-cell.tsx:5–41` ↔ `F:cells/semi_misc_cells.dart:198–240` |
| RowID | 有显示、测宽、只读浮层和无障碍文本。颜色、对齐、validated selection 有差异。 | `G:cells/row-id-cell.tsx:7–35` ↔ `F:cells/semi_misc_cells.dart:246–301`、`F:internal/data_grid/semi_types.dart:668–690` |
| URI | 有绘制、测宽、预览/编辑、删除、粘贴。`onClickUri` 虽有声明，内置 renderer 没有执行它；Glide 会按链接文字命中后调用回调并给出链接光标。 | `G:cells/uri-cell.tsx:41–154` ↔ `F:cells/semi_misc_cells.dart:363–453`、`F:internal/data_grid/semi_types.dart:748–770` |
| Marker（内部） | 有行号/复选框、选行与拖动入口。`both`、拖柄、固定测宽、行号无障碍与 renderer 命中有差异，行拖动的本地坐标计算还要验证。 | `G:cells/marker-cell.tsx:6–30,51–109` ↔ `F:cells/semi_misc_cells.dart:561–619`、`F:data_editor/semi_handle_select.dart:174–253`、`F:internal/data_grid/semi_data_grid.dart:855` |
| NewRow（内部） | 尾行提示、禁用、目标列和追加回调已接。Glide 支持自定义图标、hover、加号动画和固定测宽；Flutter 虽接收 `addIcon`，当前仍固定画 `+`。 | `G:cells/new-row-cell.tsx:5–58`、`G:data-editor/data-editor.tsx:1687–1741` ↔ `F:cells/semi_misc_cells.dart:681–711`、`F:data_editor/semi_data_editor.dart:1089–1176` |

renderer 未提供测量时，Flutter 列宽系统回退到 **150**，所以缺失测宽不等于不测量，但结果不是 Glide 单元格自己的值（`F:data_editor/semi_column_sizer.dart:10–22`）。

### 4.1 自定义单元格契约

Flutter 有 `SemiCustomCell<T>`、`SemiCustomRenderer<T>.isMatch/onPasteData`、绘制/测宽、`onSelect/onClick`、编辑浮层、删除和粘贴。`SemiDefaultRendererLookup` 可以替换内置 renderer 或加入自定义 renderer；Glide 的 `customRenderers` 对应这个入口。`drawCell` / `drawHeader` 是另一套覆盖绘制的回调，不是插件注册。

仍不完全相同：自定义 `drawCell` 拿不到图片加载器；renderer 接口缺 Glide 的 `drawPrep/deprep`、每格 `drawState`、`overrideCursor`；动画排帧丢掉传入状态。高层没暴露 `provideEditor` / `validateCell`，浮层 activation 参数为空，自定义粘贴重建单元格时还会丢失部分字段。`G:cells/cell-types.ts:16–124`、`G:data-editor/data-editor.tsx:651,1098–1115`、`G:internal/data-grid-overlay-editor/data-grid-overlay-editor.tsx:164–205` ↔ `F:cells/semi_cell_types.dart:176–255,414–431`、`F:data_editor/semi_data_editor.dart:1391–1404,3249–3266`、`F:internal/data_grid_overlay_editor/semi_data_grid_overlay_editor.dart:197–335`。

## 5. Glide 的 `cells` 包：13 项均没有 Flutter 表格插件

这 13 项不在 Glide core 的 `AllCellRenderers` 中，而是可选的 `@glideapps/glide-data-grid-cells`（`G:../cells/src/index.ts:16–46`）。当前 Flutter 没有对应的自定义 renderer 注册；仓库里的 `SemiTag`、`SemiAvatar` 等是普通控件，能做浮层编辑器基础，不能直接在 grid canvas 中按 Glide 的点击、测宽、粘贴契约工作。

| Glide 插件 | 仓库内最近的可复用控件，但未接 grid |
| --- | --- |
| StarCell | `SemiRating`（`F:/../components/semi_rating.dart:27–75`） |
| SparklineCell | 无对应绘制组件 |
| TagsCell | `SemiTag` / `SemiTagGroup` / `SemiTagInput` |
| UserProfileCell | `SemiAvatar` |
| DropdownCell | `SemiSelect` 可作为编辑器；尚无网格内的单选值/选项映射和粘贴适配（`G:../cells/src/cells/dropdown-cell.tsx:27–32,212–224`）。 |
| MultiSelectCell | `SemiSelect` 可作为多选编辑器；尚无网格内的多标签绘制、创建/重复选项策略和批量值粘贴适配（`G:../cells/src/cells/multi-select-cell.tsx:23–36,437–534`）。 |
| ArticleCell | Markdown 原文浮层和 Monaco Markdown 渲染，无同一单元格适配器 |
| SpinnerCell | `SemiSpin` 是普通控件，不是单元格动画 renderer |
| RangeCell | `SemiSlider` + `SemiProgress` |
| DatePickerCell | `SemiDatePicker` / `SemiTimePicker`，未统一到单元格 |
| LinksCell | `SemiTextLink` / `SemiAnchorLink` |
| ButtonCell | `SemiButton`，缺单元格命中和选区阻止 |
| TreeViewCell | `SemiTree` / `SemiTreeSelect`，与行分组不是同一功能 |

## 6. Glide 的 `source` 包：5 项数据适配器均未实现

上游当前只导出 5 个（`G:../source/src/index.ts:1–5`）。它们是数据/列状态适配器，不是 grid 基础组件，因此不把它列为 core 表格必须达到的 1:1；业务需要完整生态时可另排期。

| Hook | Flutter 当前能力 | 缺口 |
| --- | --- | --- |
| `useCollapsingGroups` | 有可折叠**行**分组和普通 `SemiCollapse`，不是可折叠列组。 | 缺列组折叠、组内列缩窄和自动展开。 |
| `useMoveableColumns` | 有内部拖列与回调，但列顺序仍由业务列表驱动。 | 缺按稳定键保持顺序、列增删时恢复顺序和数据索引映射。上游文件名拼写是 `Moveable`。 |
| `useColumnSort` | 表头点击可把排序交给业务。 | 缺按单元格类型抽取、多列/默认/原始/智能排序和原索引映射。 |
| `useAsyncDataSource` | 有可见区通知、编辑回调、Loading cell 和底层刷新通知。 | 缺视口预取、页缓存/占位、选区异步取数并发控制、编辑回写和批量重绘组合。 |
| `useUndoRedo` | 业务可自建历史栈。 | 缺网格单元格/选区批量合并、undo/redo 回放、快捷键和 `canUndo/canRedo`。Monaco 编辑器自己的撤销服务不处理这个 grid。 |

## 7. 测试、结论与修复顺序

### 7.1 验证范围

在本次核对时重新运行了 Flutter 相关测试，**223 项全部通过**：

```sh
flutter test --reporter expanded test/semi_data_grid_test.dart test/semi_data_grid_resize_repaint_test.dart
```

这两组测试覆盖几何、滚动计算、内部编辑、选区、搜索、剪贴板与样式的一批主路径。它们没有逐项复现本报告的差异；下文的验收清单区分了待加的画面、业务回调、公开 API 与真机用例。本次未运行 Glide 的 Web 测试，也未做跨平台性能或像素对比。

### 7.2 建议的修复顺序

1. **先修数据和桌面交互的正确性**：鼠标修饰键与主/中/右键，表头/分组表头点击，剪切清源，标记列下粘贴取值，列宽重测索引，行标记下的拖选/填充边界。
2. **接着贯通已有的画笔和高阶 API**：图片加载器、拖列/resize 状态、搜索 prelight、`damage`、编辑校验/提供编辑器、受控选区，以及 9 个 `DataEditorRef` 中业务需要的子集。
3. **补齐调用方体验**：搜索受控词和结果、追加行列的异步位置、可见窗口生命周期、系统剪贴板、滚动定位、触屏滚动与手势中断。
4. **最后扩展生态**：按实际产品需要补 `cells` renderer 或 `source` 适配器；用同数据 profile 对照滚动和重绘性能，不直接复制 DOM 的 blit、padder 或 Canvas 缓冲实现。

### 7.3 建议验收标准

下列是**待补的验收用例**，不是本次已通过的测试。先测调用方收到的坐标、值和画面，不以“字段存在”或“回调触发”作为完成标准。

| 优先级 | 场景 | 通过条件 |
| --- | --- | --- |
| P1 | 剪切、粘贴、编辑正确性 | 剪切成功后提交源区域的清空编辑；`onDelete` 拒绝时不清空。分别在开启/关闭行标记时粘贴首列和末列，读取与提交的业务坐标一致，不越界、不误改相邻列。独立验收数字删除确实可清空。 |
| P1 | 桌面选区、表头和拖动 | 鼠标 Shift 扩选、Ctrl/Cmd 多选；普通表头点击只触发对应回调，菜单点击不误选；列宽拖动有可见指示线，松开后与回写列宽一致；移出或取消指针后不继续拖选/自动滚动。 |
| P1 | 图片、搜索和主动刷新 | 图片请求完成后视口内显示缩略图；传入受控搜索结果时，命中高亮、计数和上下项跳转一致；业务更新同一格数据并调用刷新 API 后，不滚动也能看到画布和对应语义更新。 |
| P1 | 受控选区、校验和主动定位 | 外部替换选区后，网格、键盘与复制使用同一选区；校验拒绝时不发出编辑提交，改写时只提交校验后的值；控制器对冻结列/行标记场景仍使用业务数据坐标。 |
| P2（移动端目标为 P1） | 触摸与无障碍 | 触屏可双轴拖滚并在手势取消后恢复正常；真机验证滚动不会误点，并检查可见格、冻结尾行能被读屏定位和激活。 |
| P2 | 异步数据和大表性能 | 视口/查询切换后过期请求不覆盖新结果；异步追加结束后定位实际新增行列；对同一数据、列数、行高和视口测滚动帧开销，不用实现差异代替性能数据。 |

报告基于本地静态源码比对；上文未标注“平台差异”的项目，都可在 Flutter 中做功能等价的替代，不要求复制 React/DOM API。涉及 `IgnorePointer`、图片、触摸、读屏和长列表性能的结论，仍需目标 Flutter 版本的 widget 测试或设备验证。

