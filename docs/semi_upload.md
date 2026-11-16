# SemiUpload

上传（上游 Semi Upload 全件移植的 UI/生命周期核心）：触发区（自定义 children / 拖拽区域）+ 文件列表（`list` 行卡 / `picture` 图片墙）+ 全生命周期——accept 过滤、尺寸校验（KB）、`limit`（含 `limit === 1` 用最后文件替换整表 quirk）、`beforeUpload` 三态（bool / 对象 / Future，含 `autoRemove`）、自定义请求进度/成功/失败、重试、替换、移除、清空、`onChange` 受控/非受控。★Flutter 差异：浏览器 `input[type=file]` / OS 文件拖拽 / 粘贴上传不可用——文件获取收敛为 `onPickFiles`（应用自行打开 picker 并返回 `SemiUploadFile`）；拖拽区域 UI 保留，可用 `dragAreaStatus` 驱动合法/非法提示；默认 XHR `action` 收敛为 `onRequest` 自定义请求。主题对账 **85 = 85 FIELDS + 0 MOTION + 0 INTERNAL**（variables.scss 85 声明；本模块无 animation.scss；`$module: #{$prefix}-upload` 类名胶水不计，datePicker `223 = 220 + 3 + 0`、timePicker `20 = 14 + 6 + 0`、transfer `50 = 47 + 3 + 0`、anchor `30 = 26 + 4 + 0`、breadcrumb `20 = 16 + 4 + 0`、pagination `48 = 41 + 7 + 0`、tree `33 = 29 + 4 + 0`、steps `104 = 94 + 10 + 0` 先例）；★**3 死变量**（`$color-upload_pic_remove-bg`、`$height-upload_file_card_retry-icon` 真死零引用；`$width-upload_file_card_info_name` 唯一出现是注释掉的 `// width:`——事实死），留档不消费，docs 行标注「（上游未消费）」。

## API

`SemiUpload({children, action: '', accept, multiple: false, limit, maxSize, minSize, fileList, defaultFileList: const [], disabled: false, dragArea: false, dragIcon, dragMainText, dragSubText, dragAreaStatus: defaultStatus, listType: list, hotSpotLocation: end, prompt, promptPosition: right, showUploadList: true, showClear: true, showReplace: false, showRetry: true, showPicInfo: false, picWidth, picHeight, validateMessage, validateStatus: defaultStatus, fileListTitle, onPickFiles, onOpenFileDialog, beforeUpload, afterUpload, onRequest, onChange, onProgress, onSuccess, onError, onAcceptInvalid, onExceed, onSizeError, onRemove, beforeRemove, onClear, beforeClear, onRetry, onPreviewClick, renderFileItem, renderThumbnail, itemStyle, semanticsLabel})`。

children `Widget?`（触发内容；与 `dragArea: true` 二选一；两者皆空不渲染触发）。accept `String?`（逗号分隔；`.png` 后缀或 `image/*` 类别）。multiple `false`（选择器语义提示——由 picker 决定）。limit `int?`（★`limit == 1` 时新文件替换整表 quirk）。maxSize/minSize `double?`（KB）。fileList `List<SemiUploadFile>?`（非 null 即受控：交互只回调）。defaultFileList `const []`。disabled `false`。dragArea `false`（拖拽区域 UI；OS 拖拽未移植）。dragIcon/dragMainText/dragSubText `Object?`（Widget | String；缺省 upload 图标 / locale 主文案）。dragAreaStatus（default/legal/illegal——合法/非法提示由使用方驱动）。listType `list`（| picture）。hotSpotLocation `end`（图片墙 add 位）。prompt `Object?` + promptPosition `right`（left/right/bottom）。showUploadList `true`、showClear `true`、showReplace `false`、showRetry `true`、showPicInfo `false`。picWidth/picHeight（图片墙 96 缺省）。validateMessage `Object?` + validateStatus（根级校验，列表下方红字）。fileListTitle `Object?`（String | Widget | `(fileList, onClear, clearText) => Widget`）。onPickFiles `Future<List<SemiUploadFile>> Function()?`。onOpenFileDialog `VoidCallback?`。beforeUpload `(file, fileList) => bool | SemiUploadBeforeResult | Future`。afterUpload `(response, file, fileList) => Object?`（返回 false 不改成功态）。onRequest `void Function(SemiUploadRequestArgs)`（file/action/onProgress/onSuccess/onError）。onChange `ValueChanged<SemiUploadChangeInfo>`（fileList + currentFile）、onProgress、onSuccess、onError、onAcceptInvalid、onExceed、onSizeError、onRemove、beforeRemove（false 取消）、onClear、beforeClear、onRetry、onPreviewClick。renderFileItem `Widget Function(SemiUploadItemProps)`、renderThumbnail `Widget Function(SemiUploadFile)`、itemStyle（列表项外层）。semanticsLabel。

`SemiUploadFile({uid, required name, size: 0, status: wait, percent: 0, url, thumbnail, isImage: false, validateMessage, response, shouldUpload: true})` + `copyWith`。`SemiUploadBeforeResult({shouldUpload: true, status, validateMessage, autoRemove: false})`。

## 行为

### 选择与校验

触发点击（或替换）→ `onOpenFileDialog` → `onPickFiles` 取文件。`handleChange`（foundation.ts:315-367）：accept 过滤（非法 → `onAcceptInvalid`；空则中止）→ 补 uid → 尺寸校验（KB；`size > maxSize*1024 || size < minSize*1024` → status `validateFail` + `onSizeError`，`validateMessage` 缺省「文件尺寸不合法」）→ 超限（`onExceed`；★`limit === 1` 用最后一个文件替换整表；否则截断到剩余名额）→ 入表（wait）+ 逐文件 `onChange`（currentFile）→ 自动上传（尺寸非法跳过）。

### 上传与状态

`beforeUpload`（foundation.ts:574-630）：未配置 → 直接请求；`true/false`；对象/Future 结果取 `shouldUpload/status/validateMessage/autoRemove`（autoRemove 直接移除；否则更新状态后按 shouldUpload 决定是否请求；其他类型不发请求——上游 default 空分支）。请求走 `onRequest`：`onProgress(0–100)` 更新进度（不改列表回调）、`onSuccess(response)` → status success + percent 100（`afterUpload` 返回 false 时不改成功态）+ onChange/onSuccess、`onError(error, message?)` → status uploadFail + validateMessage 缺省「上传失败」+ onChange/onError。无 `onRequest` 时停在 uploading（浏览器 XHR 路径未移植——docs 注明）。重试：status 回 wait → 重新 beforeUpload/请求；替换：新文件替换该位并上传；移除/清空：`beforeRemove/beforeClear` 守卫 → 列表更新 + onRemove/onClear/onChange。

### 视觉

列表卡（250×52）：预览 36×36（图片走缩略图；图片缺缩略图用 preview-icon 色图标；普通文件灰底白图标占位）+ 名称（regular 14 / 600，ellipsis）+ 尺寸（small 12）+ 进度条（上传中）+ 校验信息（错误图标/校验中 Spin + 文案，失败色 danger）+ 重试（上传失败，primary）+ 关闭按钮；失败卡底色 danger-light-default（hover hover）；卡片 hover fill-1。图片墙 96×96：缩略图/图标、上传中圆形进度（orbit 白）、失败红框 + 右下错误/加载图标、hover 遮罩 + 删除（top-right 8）/替换/预览/重试、`showPicInfo` 底部序号条（overlay 近似 gradient 遮罩）；add 卡虚线边框 2 + 图标 tertiary（hover fill-1 / active fill-2），`hotSpotLocation` 控制位置。拖拽区域：虚线边框 2、底色 tertiary-light-default、hover primary-light-default + primary 边框；上传图标 primary、主文案 regular、副文案 small、tips 600（legal 提示 primary；disabled 文案 disabled-text）。RTL：边距/定位全部 EdgeInsetsDirectional/PositionedDirectional。

## 主题（85 对账）

来源 packages/semi-foundation/upload/variables.scss（85 声明行——color 38、width 13、height 4、spacing 18、radius 7、font 5；**无 animation.scss**）。对账 **85 = 85 FIELDS + 0 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表）。★**3 死变量**。全局 token 解析：`var(--semi-color-*)` → `theme.colors.*`（text-0/2、border、fill-0/1/2、danger-light-hover/default、primary、primary-light-default、disabled-text、tertiary-light-default、danger、tertiary、white、overlay-bg）、`rgba(var(--semi-grey-3), 1)` → `theme.palette.grey3.toColor(1)`、`rgba(var(--semi-white), 1)` → `theme.colors.colorWhite`；引用 token：`$spacing-super-tight` → 2、`$spacing-extra-tight` → 4、`$spacing-tight` → 8、`$spacing-base-tight` → 12、`$spacing-base` → 16、`$font-weight-bold/regular` → `theme.typography.fontWeightBold/Regular`、`var(--semi-border-radius-small/medium/circle)` → `theme.radius.borderRadiusSmall/Medium/Circle.value`（circle = 50 百分比值）；字面 600 → `FontWeight.w600`（progress/select 先例）。类型覆盖：**38 Color + 43 double + 4 FontWeight = 85**。解析列即 `SemiUploadThemeData.resolve` 默认表达式。

### A. Sass 声明映射（85 FIELDS）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-upload-text: var(--semi-color-text-0)` | `colorUploadText` | `theme.colors.colorText0` |
| `$color-upload_assist-text: var(--semi-color-text-2)` | `colorUploadAssistText` | `theme.colors.colorText2` |
| `$color-upload-border: var(--semi-color-border)` | `colorUploadBorder` | `theme.colors.colorBorder` |
| `$color-upload_card-bg-hover: var(--semi-color-fill-1)` | `colorUploadCardBgHover` | `theme.colors.colorFill1` |
| `$color-upload_card-bg: var(--semi-color-fill-0)` | `colorUploadCardBg` | `theme.colors.colorFill0` |
| `$color-upload_card_fail-bg-hover: var(--semi-color-danger-light-hover)` | `colorUploadCardFailBgHover` | `theme.colors.colorDangerLightHover` |
| `$color-upload_card_fail-bg: var(--semi-color-danger-light-default)` | `colorUploadCardFailBg` | `theme.colors.colorDangerLightDefault` |
| `$color-upload_clear-text: var(--semi-color-primary)` | `colorUploadClearText` | `theme.colors.colorPrimary` |
| `$color-upload_drag_area-bg-hover: var(--semi-color-primary-light-default)` | `colorUploadDragAreaBgHover` | `theme.colors.colorPrimaryLightDefault` |
| `$color-upload_drag_area-border-hover: var(--semi-color-primary)` | `colorUploadDragAreaBorderHover` | `theme.colors.colorPrimary` |
| `$color-upload_drag_area_disabled-text: var(--semi-color-disabled-text)` | `colorUploadDragAreaDisabledText` | `theme.colors.colorDisabledText` |
| `$color-upload_drag_area-bg: var(--semi-color-tertiary-light-default)` | `colorUploadDragAreaBg` | `theme.colors.colorTertiaryLightDefault` |
| `$color-upload_drag_area_icon: var(--semi-color-primary)` | `colorUploadDragAreaIcon` | `theme.colors.colorPrimary` |
| `$color-upload_drag_area_tips-text: var(--semi-color-primary)` | `colorUploadDragAreaTipsText` | `theme.colors.colorPrimary` |
| `$color-upload_drag_area_main-text-default: var(--semi-color-text-0)` | `colorUploadDragAreaMainTextDefault` | `theme.colors.colorText0` |
| `$color-upload_drag_area_main-text-hover: var(--semi-color-text-0)` | `colorUploadDragAreaMainTextHover` | `theme.colors.colorText0` |
| `$color-upload_drag_area_main-text-active: var(--semi-color-text-0)` | `colorUploadDragAreaMainTextActive` | `theme.colors.colorText0` |
| `$color-upload_drag_area_sub-text-default: var(--semi-color-text-0)` | `colorUploadDragAreaSubTextDefault` | `theme.colors.colorText0` |
| `$color-upload_drag_area_sub-text-hover: var(--semi-color-text-0)` | `colorUploadDragAreaSubTextHover` | `theme.colors.colorText0` |
| `$color-upload_drag_area_sub-text-active: var(--semi-color-text-0)` | `colorUploadDragAreaSubTextActive` | `theme.colors.colorText0` |
| `$color-upload_file_card_fail_info-text: var(--semi-color-danger)` | `colorUploadFileCardFailInfoText` | `theme.colors.colorDanger` |
| `$color-upload_file_card_preview_placeholder-bg: rgba(var(--semi-grey-3), 1)` | `colorUploadFileCardPreviewPlaceholderBg` | `theme.palette.grey3.toColor(1)` |
| `$color-upload_file_card_preview_placeholder-text: rgba(var(--semi-white), 1)` | `colorUploadFileCardPreviewPlaceholderText` | `theme.colors.colorWhite` |
| `$color-upload_file_card_retry-bg: var(--semi-color-white)` | `colorUploadFileCardRetryBg` | `theme.colors.colorWhite` |
| `$color-upload_file_card_retry-text: var(--semi-color-primary)` | `colorUploadFileCardRetryText` | `theme.colors.colorPrimary` |
| `$color-upload-icon: var(--semi-color-tertiary)` | `colorUploadIcon` | `theme.colors.colorTertiary` |
| `$color-upload_pic_add-bg-active: var(--semi-color-fill-2)` | `colorUploadPicAddBgActive` | `theme.colors.colorFill2` |
| `$color-upload_pic_add-bg-hover: var(--semi-color-fill-1)` | `colorUploadPicAddBgHover` | `theme.colors.colorFill1` |
| `$color-upload_pic_add-bg: var(--semi-color-fill-0)` | `colorUploadPicAddBg` | `theme.colors.colorFill0` |
| `$color-upload_pic_remove-bg: var(--semi-color-overlay-bg)` | `colorUploadPicRemoveBg` | `theme.colors.colorOverlayBg（**上游未消费**）` |
| `$color-upload_picture_file_card_loading_error-icon: var(--semi-color-danger)` | `colorUploadPictureFileCardLoadingErrorIcon` | `theme.colors.colorDanger` |
| `$color-upload_picture_file_card_error-border: var(--semi-color-danger)` | `colorUploadPictureFileCardErrorBorder` | `theme.colors.colorDanger` |
| `$color-upload_picture_file_card_pic_info-text: var(--semi-color-white)` | `colorUploadPictureFileCardPicInfoText` | `theme.colors.colorWhite` |
| `$color-upload_picture_file_card_close-icon: var(--semi-color-white)` | `colorUploadPictureFileCardCloseIcon` | `theme.colors.colorWhite` |
| `$color-upload_picture_file_card_hover-bg: var(--semi-color-overlay-bg)` | `colorUploadPictureFileCardHoverBg` | `theme.colors.colorOverlayBg` |
| `$color-upload_preview-icon: var(--semi-color-text-2)` | `colorUploadPreviewIcon` | `theme.colors.colorText2` |
| `$color-upload_retry-text: var(--semi-color-primary)` | `colorUploadRetryText` | `theme.colors.colorPrimary` |
| `$color-upload_replace-text: var(--semi-color-white)` | `colorUploadReplaceText` | `theme.colors.colorWhite` |
| `$height-upload_file_card: 52px` | `heightUploadFileCard` | `52` |
| `$width-upload_file_card: 250px` | `widthUploadFileCard` | `250` |
| `$height-upload_file_pic_card: 96px` | `heightUploadFilePicCard` | `96` |
| `$width-upload_file_pic_card: 96px` | `widthUploadFilePicCard` | `96` |
| `$width-upload_file_card_preview: 36px` | `widthUploadFileCardPreview` | `36` |
| `$height-upload_file_card_preview: 36px` | `heightUploadFileCardPreview` | `36` |
| `$width-upload_file_card_preview_img: 36px` | `widthUploadFileCardPreviewImg` | `36` |
| `$width-upload_file_card_info_name: 106px` | `widthUploadFileCardInfoName` | `106（**上游未消费**）` |
| `$width-upload_file_card-icon: 11px` | `widthUploadFileCardIcon` | `11` |
| `$width-upload_picture_add-border: 2px` | `widthUploadPictureAddBorder` | `2` |
| `$width-upload_picture_file_card_img: 96px` | `widthUploadPictureFileCardImg` | `96` |
| `$width-upload_picture_file_card_close: 16px` | `widthUploadPictureFileCardClose` | `16` |
| `$width-upload_file_card_retry: 24px` | `widthUploadFileCardRetry` | `24` |
| `$width-upload_file_card_retry-icon: 13px` | `widthUploadFileCardRetryIcon` | `13` |
| `$height-upload_file_card_retry-icon: 14px` | `heightUploadFileCardRetryIcon` | `14（**上游未消费**）` |
| `$width-upload_picture_file_card_loading-icon: 14px` | `widthUploadPictureFileCardLoadingIcon` | `14` |
| `$width-upload_drag_area-border: 2px` | `widthUploadDragAreaBorder` | `2` |
| `$spacing-upload_title_choosen-marginRight: $spacing-tight` | `spacingUploadTitleChoosenMarginRight` | `8` |
| `$spacing-upload_title-marginBottom: $spacing-extra-tight` | `spacingUploadTitleMarginBottom` | `4` |
| `$spacing-upload_file_card_preview-margin: $spacing-tight` | `spacingUploadFileCardPreviewMargin` | `8` |
| `$spacing-upload_file_card_info_size-marginLeft: $spacing-tight` | `spacingUploadFileCardInfoSizeMarginLeft` | `8` |
| `$spacing-upload_file_card_info_retry-marginLeft: $spacing-tight` | `spacingUploadFileCardInfoRetryMarginLeft` | `8` |
| `$spacing-upload_file_card_info_progress-marginTop: 4px` | `spacingUploadFileCardInfoProgressMarginTop` | `4` |
| `$spacing-upload_file_card_close-marginLeft: $spacing-tight` | `spacingUploadFileCardCloseMarginLeft` | `8` |
| `$spacing-upload_file_card_close-marginRight: $spacing-tight` | `spacingUploadFileCardCloseMarginRight` | `8` |
| `$spacing-upload_file_card_icon-marginRight: $spacing-super-tight` | `spacingUploadFileCardIconMarginRight` | `2` |
| `$spacing-upload_picture_file_card-gap: $spacing-tight` | `spacingUploadPictureFileCardGap` | `8` |
| `$spacing-upload_picture_file_card-marginBottom: $spacing-tight` | `spacingUploadPictureFileCardMarginBottom` | `8` |
| `$spacing-upload_picture_file_card_close-top: 8px` | `spacingUploadPictureFileCardCloseTop` | `8` |
| `$spacing-upload_picture_file_card_close-right: 8px` | `spacingUploadPictureFileCardCloseRight` | `8` |
| `$spacing-upload_picture_file_card_loading_error-bottom: 6px` | `spacingUploadPictureFileCardLoadingErrorBottom` | `6` |
| `$spacing-upload_picture_file_card_loading_error-right: 6px` | `spacingUploadPictureFileCardLoadingErrorRight` | `6` |
| `$spacing-upload_picture_file_card_icon_error-top: -1px` | `spacingUploadPictureFileCardIconErrorTop` | `-1` |
| `$spacing-upload_drag_area-padding: $spacing-base-tight` | `spacingUploadDragAreaPadding` | `12` |
| `$spacing-upload_drag_area_main_text-marginBottom: $spacing-extra-tight` | `spacingUploadDragAreaMainTextMarginBottom` | `4` |
| `$radius-upload_file_card: var(--semi-border-radius-medium)` | `radiusUploadFileCard` | `theme.radius.borderRadiusMedium.value` |
| `$radius-upload_file_card_preview: var(--semi-border-radius-small)` | `radiusUploadFileCardPreview` | `theme.radius.borderRadiusSmall.value` |
| `$radius-upload_picture_add: var(--semi-border-radius-small)` | `radiusUploadPictureAdd` | `theme.radius.borderRadiusSmall.value` |
| `$radius-upload_picture_file_card_img: var(--semi-border-radius-small)` | `radiusUploadPictureFileCardImg` | `theme.radius.borderRadiusSmall.value` |
| `$radius-upload_picture_file_card_close: var(--semi-border-radius-circle)` | `radiusUploadPictureFileCardClose` | `theme.radius.borderRadiusCircle.value` |
| `$radius-upload_file_card_retry: var(--semi-border-radius-circle)` | `radiusUploadFileCardRetry` | `theme.radius.borderRadiusCircle.value` |
| `$radius-upload_drag_area: var(--semi-border-radius-small)` | `radiusUploadDragArea` | `theme.radius.borderRadiusSmall.value` |
| `$font-upload_file_card_info_name-fontWeight: $font-weight-bold` | `fontUploadFileCardInfoNameFontWeight` | `theme.typography.fontWeightBold` |
| `$font-upload_file_card_info_size-fontWeight: $font-weight-regular` | `fontUploadFileCardInfoSizeFontWeight` | `theme.typography.fontWeightRegular` |
| `$font-upload_drag_area_tips-fontWeight: 600` | `fontUploadDragAreaTipsFontWeight` | `FontWeight.w600` |
| `$font-upload_picture_file_card_pic_info-fontSize: 12px` | `fontUploadPictureFileCardPicInfoFontSize` | `12` |
| `$font-upload_picture_file_card_pic_info-fontWeight: 600` | `fontUploadPictureFileCardPicInfoFontWeight` | `FontWeight.w600` |

### B. HARDCODES 另列（`_UploadMetrics` / 调用点，widget 源内含原始片段）

| 上游片段 | 落点 |
|---|---|
| `byteKB = 1024` | 尺寸校验单位（utils.ts:1） |
| `PROGRESS_COEFFICIENT: 0.95` | note-only——浏览器 XHR 进度 95% 截断（自定义进度 0–100） |
| `'点击上传文件或拖拽文件到这里'` | locale mainText（zh_CN.ts:139） |
| `'松手开始上传'` / `'不支持此类型文件'` | locale legalTips/illegalTips（dragAreaStatus 驱动） |
| `'重试'` / `'替换文件'` / `'清空'` / `'已选择文件'` / `'文件尺寸不合法'` / `'上传失败'` | locale 六串 |
| `IconUpload size="extra-large"` | 拖拽区域缺省图标（24） |
| `aria-label="picture list"` / `aria-label="file list"` | 列表语义 |
| `PROMPT_POSITION: ['left', 'right', 'bottom']` | promptPosition |
| `linear-gradient(0deg, rgba(22, 22, 26, 0.3) 0%, rgba(22, 22, 26, 0) 77.08%)` | 图片信息遮罩（overlay-bg 近似） |
| `toFixed(2)` | 文件尺寸格式化（utils.ts:6-16） |
| `rgba(var(--semi-white), 1)` / `rgba(var(--semi-grey-3), 1)` | 颜色写法 quirk |
| `getUuidv4()` | 自动补 uid |

## 差异清单

★照搬留档（quirk 原样）：

1. **limit === 1 替换整表**：超出时用最后一个文件替换列表（foundation.ts:349-359）。
2. **beforeUpload 其他类型不发请求**：上游 default 空分支（返回字符串等意外值即静默）。
3. **尺寸非法仍入表**：status `validateFail` + 尺寸消息，但不发起请求；可通过重试再校验。
4. **图片墙关闭/替换/重试默认 hover 可见**：CSS visibility 规则。
5. **`PROGRESS_COEFFICIENT` 95% 截断**：浏览器 XHR 路径；自定义请求进度按应用给值。
6. **重名/uid**：空 uid 自动补齐；同名文件按 uid 区分（上游同）。

偏差/裁剪：

7. **文件选择抽象**：`input[type=file]` 不移植——`onPickFiles` 由应用打开 picker（file_selector/file_picker 等）并返回 `SemiUploadFile`；`multiple/accept/capture/directory` 为 picker 语义提示。
8. **OS 拖拽/粘贴不移植**：`draggable` 的 drag 事件与 `pasteUpload` 无 Flutter core 支持——拖拽区域 UI 保留，`dragAreaStatus` 供应用驱动提示；`onDrop` 不移植。
9. **默认 XHR 上传不移植**：`action` 仅元数据；请求必须经 `onRequest`（无 onRequest 时停在 uploading）。
10. **裁剪（crop）/预览弹层不移植**：`previewFile`/`onPreviewClick` 保留回调，预览 UI 由应用实现。
11. **手动上传（uploadTrigger: custom）不移植**：仅自动触发；`insert/upload/openFileDialog` 命令式 API 无落点。
12. **图片信息条**：`showPicInfo` 渲染序号；`renderPicInfo/renderPicClose/renderPicPreviewIcon/renderFileOperation` 等细粒度 builder 不移植（用 `renderFileItem`/`renderThumbnail` 覆盖）。
13. **原生 title/文件名 tooltip 不移植**：列表名 ellipsis 无悬停 tooltip（note-only）。
14. **className/style/getDataAttr/prefixCls 裁剪**：Flutter 无 CSS 类；`validateStatus` 仅语义保留。

## 用法

```dart
SemiUpload(
  action: '/api/upload',
  onPickFiles: () async {
    // 应用自行打开 picker（file_selector / file_picker）
    return [SemiUploadFile(name: 'a.png', size: 120 * 1024, isImage: true)];
  },
  onRequest: (args) {
    // 自定义请求：进度/成功/失败
    args.onProgress(40);
    args.onSuccess({'url': '/files/a.png'});
  },
  onChange: (info) {},
)

// 拖拽区域 + 校验
SemiUpload(
  dragArea: true,
  accept: '.png,.jpg',
  maxSize: 2048, // KB
  limit: 3,
  onPickFiles: picker,
  beforeUpload: (file, list) => file.name.endsWith('.png'),
  onRequest: request,
)

// 图片墙
SemiUpload(
  listType: SemiUploadListType.picture,
  showPicInfo: true,
  showReplace: true,
  onPreviewClick: (file) {},
  onPickFiles: picker,
  onRequest: request,
)
```
