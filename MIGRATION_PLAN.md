# Semi Design Flutter 移植计划

## 1. 目标与现状

在当前 `semi_design_flutter` package 中，实现遵循 Semi Design 视觉规范与主要交互语义的 Flutter 组件库。采用 Flutter 原生布局、绘制、输入、焦点和无障碍体系，不嵌入 React/WebView，也不追求 React API 逐参数兼容。

调研基线：2026-11-10，本地 React 源码 `/Users/zhouguiqing/Documents/Code/Html/semi-design`。各 Semi package manifest 当前版本为 **2.104.0**，后续应另行记录源码提交号或快照摘要；不要使用根工程的 `0.0.1` 或目录中的旧 tgz 作为版本基线。

当前 Flutter 项目仅有 Calculator 模板与计数器 example；主题、组件及测试体系尚未建立。example 尚需添加父 package 的 path 依赖。现有 Dart `^3.13.5` 与 Flutter `>=1.17.0` 声明需根据实际 SDK 和所用 API 重新对齐，不能视为已经验证的兼容范围。

### 默认范围

- 优先验证 Web、macOS 桌面场景；保留 Android/iOS 适配设计，其余桌面平台后续逐项验证。
- 首期支持亮色、暗色、自定义主色及中英文基础文案。
- 第一阶段目标是可供应用试用的基础组件集，而不是一次性覆盖整个 React 库。
- 公共类名采用 `Semi` 前缀，例如 `SemiButton`、`SemiTheme`，避免与 Flutter 原生控件重名。

以上是实施建议，尚不代表平台兼容承诺。

## 2. 复用原则

| React 资产 | Flutter 处理方式 |
|---|---|
| 色板、语义色、尺寸、间距、圆角、字重、动效规范 | 提取并转换为类型化 Dart token |
| SVG 图标与插画 | 核验许可及渲染兼容性后转为 Flutter 资产 |
| foundation 中的纯算法和状态规则 | 迁移为 Dart，并迁移测试场景 |
| React adapter、JSX、DOM/composition 事件 | 使用 Flutter 原生机制重写 |
| SCSS、CSS 布局、Portal、z-index | 重建为 Widget、Decoration、Overlay 与层级管理 |
| React 文档、Storybook、测试 | 转化为组件规格、gallery 场景和验收矩阵 |
| npm 依赖 | 按 Flutter 需求重新选型，不直接运行 JS 内核 |

注意：`semi-foundation` 并非完全平台无关，其中包含 SCSS、DOM 类型及浏览器事件假设。只在交互复杂度确有必要时拆出 Dart foundation/controller，不强制每个简单组件套用相同分层。

## 3. 工程与架构

首期维持单 package，避免过早建立多包发布链。内部模块保持边界，未来图标或高级组件确有独立发布需求时再拆包。

```text
lib/
  semi_design_flutter.dart       # 稳定公开导出
  src/
    tokens/                     # 基础、语义、组件 token
    theme/                      # SemiThemeData、主题注入、插值
    icons/                      # 图标入口与资产映射
    foundation/                 # 必要的纯 Dart 状态规则/算法
    components/                 # 每个组件独立目录
    overlay/                    # 定位、层级、关闭与焦点恢复
    localization/               # 内建文案与 locale
    utils/                      # 少量内部通用工具
assets/
  icons/
example/
  lib/                          # gallery、主题切换、状态示例
test/                           # 单测、Widget 测试和 Golden
```

测试目录按 `test/foundation/`、`test/components/`、`test/goldens/` 组织；需要时增加 `example/integration_test/`。以上为建议结构，不要求创建占位文件。

### 核心约定

1. **主题**：基础 token → 语义 token → 组件 token。提供不可变 `SemiThemeData`、`copyWith`、`lerp` 与基于 InheritedWidget 的主题访问；与 Material 应用可共存，但视觉不依赖 Material 默认皮肤。
2. **状态**：明确受控值和非受控默认值的边界；输入组件支持原生 controller/focusNode，并规定互斥参数和资源所有权。
3. **交互**：统一 hover、pressed、focused、disabled、loading、error 状态和鼠标指针、快捷键、焦点样式。
4. **输入**：保留 TextEditingValue 的 selection/composing，不用简单字符串回写破坏中文输入法。
5. **浮层**：集中处理锚点定位、边界翻转、滚动跟随、点击外部关闭、Esc、焦点恢复、多浮层优先级与清理。
6. **可访问性**：提供 Semantics、键盘操作和文本缩放；视觉密度与触控命中区域分离。24/32/40 logical pixel 可作为视觉尺寸起点，不直接等同移动端可触达区域。
7. **依赖**：优先 Flutter SDK；SVG、国际化、日期、虚拟化等按需评估，记录许可、体积、维护状态及平台限制。不默认引入全局状态管理框架。

## 4. 分阶段路线

以下工期按一名熟悉 Flutter 的开发者、全职投入、基础设计支持估算；阶段内含测试与文档。它是预算区间，不是未经验证的交付承诺。

### M0：基线与技术验证（约 1 周）

- 记录上游版本、提交或快照，建立组件/API 对照清单。
- 检查本机 Flutter/Dart，确定真实最低版本及目标平台矩阵。
- 整理上游 MIT 及包含的第三方声明，替换当前 LICENSE 占位并建立第三方声明文件；字体/图标资源单独核验。
- 配置 lint、格式检查、analyze、单测与 CI。
- 验证主题提取、代表性 SVG、中文输入、锚点浮层四项高风险技术点。
- 为 example 添加本地依赖，搭建 gallery 外壳。

**验收**：基线可追溯；基础 CI 可运行；风险验证有记录；不存在对全部平台已支持的未验证宣称。

### M1：设计系统与首个纵切（约 2–3 周）

- 提取色板、亮暗语义色、字体、行高、间距、圆角、阴影及动画参数。
- 先检查 `static/designToken.json` 与生成脚本、SCSS 的覆盖和解析规则，再决定数据源；不假定 JSON 完整。
- 建立主题覆盖与局部主题能力，以及最小图标集。
- 实现 Typography、Button/IconButton、Space、Divider。
- 用 Button 贯通规格 → token → 实现 → gallery → widget/golden 测试。

**验收**：Button 的类型、尺寸、状态及亮暗主题有完整矩阵；自定义主题可工作；键盘与语义测试通过。React 浏览器与 Flutter 截图使用同一场景规格做人工对照，不要求跨渲染引擎像素完全相同。

### M2：基础展示与输入（约 3–4 周）

- 展示：Tag、Badge、Avatar、Card、Spin、Progress、Skeleton、Empty。
- 输入：Input/TextArea、Checkbox、Radio、Switch、InputNumber。
- 建立通用焦点、校验状态、禁用状态与 controller 约定。
- 补充输入法、光标、选区、粘贴、清除、密码显示等回归场景。

**验收**：受控/非受控行为明确；主题和状态矩阵完整；外部 controller/focusNode 不被组件错误释放；大字号和中英文不出现明显布局损坏。

### M3：浮层与常用组合组件（约 3–4 周）

- 先完成 overlay 基座，再实现 Tooltip、Popover、Dropdown、Modal、SideSheet、Toast、Notification。
- 在基座稳定后实现 Select 的单选/多选、过滤和空态。
- 为连续弹出、嵌套弹层、滚动、窗口缩放、Esc 与焦点恢复建立测试。

**验收**：浮层无残留、不错误截获输入、边缘定位可用；Modal 具备模态语义和焦点约束；Select 的键盘导航与中文搜索场景经过验证。

### M4：常用业务组件与表单（约 4–6 周）

- 导航：Tabs、Breadcrumb、Pagination、Steps，按需要增加 Navigation。
- 展示：Collapse、List、Descriptions、Timeline。
- 表单：Form/FormField、同步和异步校验、重置、提交、错误展示。
- 日期：先 TimePicker 和基础 DatePicker，再范围选择与禁用规则。
- 树：先基础 Tree，再按应用需求扩展 Cascader/TreeSelect。

**验收**：组合组件在真实业务表单中使用；异步校验不会因旧结果覆盖新值；明确日期、时区、locale 和值类型契约；具备长文案和大数据边界测试。

### M5：高级能力（另行评估，按需排期）

不纳入首期完整承诺：

- Table：先基础渲染、排序、选择、分页，再固定列、复杂表头与虚拟滚动。
- 大树、Transfer、Upload、拖拽、Resizable。
- Calendar、Carousel、Image 预览、ColorPicker。
- Markdown、代码高亮、JSON Viewer、富文本、AI Chat 输入、音视频及 Lottie。

每项先做独立设计和性能验证，再给出工期。尤其不能把 Table、富文本或 Upload 作为普通皮肤组件估算；Upload 的网络传输应允许业务侧注入，不绑定特定后端。

### M6：发布与持续兼容（贯穿各阶段）

- 每个阶段维护 CHANGELOG、API 文档、gallery 和支持矩阵。
- 先通过应用 path 依赖试用，再准备预发布版本；公开发布前单独确认。
- 组件库版本独立演进，记录对应上游版本与偏差，不暗示与 React 全量功能等价。
- 生产试用暴露的兼容性问题优先于继续堆组件数量。

## 5. 首个可用版本建议

建议把 **M0–M3** 作为首个 MVP，约 **9–12 人周**；以基础展示、表单输入与浮层闭环为目标。若 Select 或跨平台问题超出预算，可将其移入下一里程碑，但需明确版本缺项。

M4 后达到较完整的常用业务组件覆盖，累计约 **13–18 人周**。全量移植应在完成首批组件后重新估算，不以本计划推导所有高级组件交付日期。

## 6. 每个组件的执行模板

1. 阅读 `semi-ui/<component>`、对应 foundation/SCSS、文档、测试和 story。
2. 写规格：API 映射、视觉 token、状态表、键盘/焦点、语义、平台差异与暂不支持项。
3. 只迁移必要纯逻辑，使用 Flutter 原生机制实现 Widget。
4. 补充 gallery：亮/暗、尺寸、状态、长文本、受控/非受控和错误边界。
5. 编写算法单测、Widget 测试和代表性 Golden。
6. 对照 React 同规格场景检查视觉和交互；登记有意偏差。
7. 更新公开导出、文档与支持清单，完成验收后标记已支持。

建议建立组件跟踪表，字段为：上游路径、优先级、负责人、API 状态、实现状态、单测、视觉验收、平台验证、已知差异。

## 7. 测试与质量门槛

- **静态检查**：格式、analyze、公共 API 注释与依赖约束。
- **逻辑单测**：选择算法、状态规则、格式化、表单校验和日期边界。
- **Widget 测试**：交互、受控更新、焦点、键盘、语义、生命周期和资源释放。
- **Golden**：固定字体、逻辑尺寸、设备像素比、平台和测试环境；覆盖代表性主题/状态，不跨机器盲目比较基线。
- **集成测试**：真实输入法、滚动和多层 overlay，以及目标平台关键链路。Widget 测试不能完全替代真实中文输入法验证。
- **性能**：复杂列表在明确设备、数据规模和交互路径下建立帧耗时与内存基线，再设回归阈值。
- **发布门槛**：声明支持的平台完成验证；关键路径无阻断缺陷；无未解释的 Golden 变化；文档与已知差异同步。

不把上游测试文件数量或单一覆盖率数字视为完成标准。React 单测中样式可被忽略，因此通过其逻辑测试不等于 Flutter 视觉已正确。

## 8. 风险与应对

| 风险 | 应对 |
|---|---|
| 机械翻译 React/DOM 导致行为异常 | 保留语义，重写平台实现；先做输入/浮层验证 |
| 文本、字体、阴影差异 | 固定基准环境，逐项校准，记录合理偏差 |
| 桌面密度影响移动触控 | 分离视觉尺寸与命中区域，补充平台验收 |
| 中文输入和受控更新冲突 | 使用原生 editing value 和 composing，保留真实设备测试 |
| 浮层反复重写或互相冲突 | 先建设统一 overlay 基座 |
| 复杂组件拖延首版 | 明确 MVP 边界，高级组件单独设计与估算 |
| 上游持续变化 | 固定基线，按版本审核同步，避免开发中追随主分支 |
| 许可或资源遗漏 | 保留上游及第三方声明，对字体和资产逐项核验 |

## 9. 实施起点

批准实施后，先完成 M0 和 Button 纵切，不同时铺开所有组件：

- 核验 Flutter/Dart 环境与平台目标。
- 建立可追溯的上游版本记录、许可说明及 CI。
- 搭建 token/主题最小体系和 gallery。
- 实现 SemiButton 并完成亮暗主题、交互、键盘、语义和视觉验收。
- 根据纵切实际耗时调整后续里程碑。

本计划仅基于只读源码调研，未运行 React/Flutter 构建或测试，也未修改现有实现。
