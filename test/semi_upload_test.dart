// Behavior matrix for SemiUpload plus coverage for the 85 Sass declarations
// (85 FIELDS + 0 MOTION + 0 INTERNAL) — the 20 HARDCODES provenance anchors
// live in the widget's `_UploadMetrics` / call sites. ★3 死变量
// (`$color-upload_pic_remove-bg`、`$height-upload_file_card_retry-icon` 真死；
// `$width-upload_file_card_info_name` 注释消费事实死) → word-boundary
// assertNotIn + docs （上游未消费） marks.
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

final _hostBody = ValueNotifier<Widget>(const SizedBox.shrink());

Widget host(Widget child, {TextDirection direction = TextDirection.ltr}) {
  _hostBody.value = KeyedSubtree(key: UniqueKey(), child: child);
  return SemiTheme(
    data: const SemiThemeData.light(),
    child: Directionality(
      textDirection: direction,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(1200, 900)),
        child: Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => ValueListenableBuilder<Widget>(
                valueListenable: _hostBody,
                builder: (context, child, _) => Center(
                  child: SizedBox(width: 900, height: 700, child: child),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> pumpHost(
  WidgetTester tester,
  Widget child, {
  TextDirection direction = TextDirection.ltr,
}) async {
  await tester.binding.setSurfaceSize(const Size(1200, 1200));
  await tester.pumpWidget(host(child, direction: direction));
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 30));
  }
}

SemiUpload pickable(
  List<SemiUploadFile> files, {
  ValueChanged<SemiUploadRequestArgs>? onRequest,
  ValueChanged<SemiUploadChangeInfo>? onChange,
  SemiUploadBeforeUpload? beforeUpload,
  List<SemiUploadFile> defaultFileList = const <SemiUploadFile>[],
  List<SemiUploadFile>? fileList,
  String? accept,
  int? limit,
  double? maxSize,
  SemiUploadListType listType = SemiUploadListType.list,
  bool dragArea = false,
  SemiUploadDragAreaStatus dragAreaStatus =
      SemiUploadDragAreaStatus.defaultStatus,
  SemiUploadPromptPosition promptPosition = SemiUploadPromptPosition.right,
  Object? prompt,
  Widget Function(SemiUploadItemProps)? renderFileItem,
  void Function(List<SemiUploadFile> files)? onExceed,
  void Function(List<SemiUploadFile> files)? onAcceptInvalid,
  void Function(SemiUploadFile file, List<SemiUploadFile> list)? onSizeError,
  void Function(SemiUploadFile file, List<SemiUploadFile> list)? onRemove,
  void Function(List<SemiUploadFile> files)? onClear,
  ValueChanged<SemiUploadFile>? onRetry,
  void Function(
    Object? response,
    SemiUploadFile file,
    List<SemiUploadFile> list,
  )?
  onSuccess,
  void Function(Object? error, SemiUploadFile file, List<SemiUploadFile> list)?
  onError,
  bool showPicInfo = false,
  bool showReplace = false,
}) => SemiUpload(
  accept: accept,
  limit: limit,
  maxSize: maxSize,
  defaultFileList: defaultFileList,
  fileList: fileList,
  listType: listType,
  dragArea: dragArea,
  dragAreaStatus: dragAreaStatus,
  prompt: prompt,
  promptPosition: promptPosition,
  showPicInfo: showPicInfo,
  showReplace: showReplace,
  renderFileItem: renderFileItem,
  onExceed: onExceed,
  onAcceptInvalid: onAcceptInvalid,
  onSizeError: onSizeError,
  onRemove: onRemove,
  onClear: onClear,
  onRetry: onRetry,
  onSuccess: onSuccess,
  onError: onError,
  onChange: onChange,
  onPickFiles: () async => files,
  onRequest: onRequest ?? (_) {},
  beforeUpload: beforeUpload,
  children: const Text('trigger'),
);

// -- theme field table -------------------------------------------------------

typedef _Patch = SemiUploadThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedUploadThemeData data);
typedef _Default = Object? Function(SemiThemeData theme);

const _c = Color(0xFF010203);

final List<(String, Object, _Patch, _Read, _Default)> fields = [
  (
    r'$color-upload-text: var(--semi-color-text-0)',
    _c,
    (v) => SemiUploadThemeData(colorUploadText: v as Color),
    (d) => d.colorUploadText,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-upload_assist-text: var(--semi-color-text-2)',
    _c,
    (v) => SemiUploadThemeData(colorUploadAssistText: v as Color),
    (d) => d.colorUploadAssistText,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-upload-border: var(--semi-color-border)',
    _c,
    (v) => SemiUploadThemeData(colorUploadBorder: v as Color),
    (d) => d.colorUploadBorder,
    (t) => t.colors.colorBorder,
  ),
  (
    r'$color-upload_card-bg-hover: var(--semi-color-fill-1)',
    _c,
    (v) => SemiUploadThemeData(colorUploadCardBgHover: v as Color),
    (d) => d.colorUploadCardBgHover,
    (t) => t.colors.colorFill1,
  ),
  (
    r'$color-upload_card-bg: var(--semi-color-fill-0)',
    _c,
    (v) => SemiUploadThemeData(colorUploadCardBg: v as Color),
    (d) => d.colorUploadCardBg,
    (t) => t.colors.colorFill0,
  ),
  (
    r'$color-upload_card_fail-bg-hover: var(--semi-color-danger-light-hover)',
    _c,
    (v) => SemiUploadThemeData(colorUploadCardFailBgHover: v as Color),
    (d) => d.colorUploadCardFailBgHover,
    (t) => t.colors.colorDangerLightHover,
  ),
  (
    r'$color-upload_card_fail-bg: var(--semi-color-danger-light-default)',
    _c,
    (v) => SemiUploadThemeData(colorUploadCardFailBg: v as Color),
    (d) => d.colorUploadCardFailBg,
    (t) => t.colors.colorDangerLightDefault,
  ),
  (
    r'$color-upload_clear-text: var(--semi-color-primary)',
    _c,
    (v) => SemiUploadThemeData(colorUploadClearText: v as Color),
    (d) => d.colorUploadClearText,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-upload_drag_area-bg-hover: var(--semi-color-primary-light-default)',
    _c,
    (v) => SemiUploadThemeData(colorUploadDragAreaBgHover: v as Color),
    (d) => d.colorUploadDragAreaBgHover,
    (t) => t.colors.colorPrimaryLightDefault,
  ),
  (
    r'$color-upload_drag_area-border-hover: var(--semi-color-primary)',
    _c,
    (v) => SemiUploadThemeData(colorUploadDragAreaBorderHover: v as Color),
    (d) => d.colorUploadDragAreaBorderHover,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-upload_drag_area_disabled-text: var(--semi-color-disabled-text)',
    _c,
    (v) => SemiUploadThemeData(colorUploadDragAreaDisabledText: v as Color),
    (d) => d.colorUploadDragAreaDisabledText,
    (t) => t.colors.colorDisabledText,
  ),
  (
    r'$color-upload_drag_area-bg: var(--semi-color-tertiary-light-default)',
    _c,
    (v) => SemiUploadThemeData(colorUploadDragAreaBg: v as Color),
    (d) => d.colorUploadDragAreaBg,
    (t) => t.colors.colorTertiaryLightDefault,
  ),
  (
    r'$color-upload_drag_area_icon: var(--semi-color-primary)',
    _c,
    (v) => SemiUploadThemeData(colorUploadDragAreaIcon: v as Color),
    (d) => d.colorUploadDragAreaIcon,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-upload_drag_area_tips-text: var(--semi-color-primary)',
    _c,
    (v) => SemiUploadThemeData(colorUploadDragAreaTipsText: v as Color),
    (d) => d.colorUploadDragAreaTipsText,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-upload_drag_area_main-text-default: var(--semi-color-text-0)',
    _c,
    (v) => SemiUploadThemeData(colorUploadDragAreaMainTextDefault: v as Color),
    (d) => d.colorUploadDragAreaMainTextDefault,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-upload_drag_area_main-text-hover: var(--semi-color-text-0)',
    _c,
    (v) => SemiUploadThemeData(colorUploadDragAreaMainTextHover: v as Color),
    (d) => d.colorUploadDragAreaMainTextHover,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-upload_drag_area_main-text-active: var(--semi-color-text-0)',
    _c,
    (v) => SemiUploadThemeData(colorUploadDragAreaMainTextActive: v as Color),
    (d) => d.colorUploadDragAreaMainTextActive,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-upload_drag_area_sub-text-default: var(--semi-color-text-0)',
    _c,
    (v) => SemiUploadThemeData(colorUploadDragAreaSubTextDefault: v as Color),
    (d) => d.colorUploadDragAreaSubTextDefault,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-upload_drag_area_sub-text-hover: var(--semi-color-text-0)',
    _c,
    (v) => SemiUploadThemeData(colorUploadDragAreaSubTextHover: v as Color),
    (d) => d.colorUploadDragAreaSubTextHover,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-upload_drag_area_sub-text-active: var(--semi-color-text-0)',
    _c,
    (v) => SemiUploadThemeData(colorUploadDragAreaSubTextActive: v as Color),
    (d) => d.colorUploadDragAreaSubTextActive,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-upload_file_card_fail_info-text: var(--semi-color-danger)',
    _c,
    (v) => SemiUploadThemeData(colorUploadFileCardFailInfoText: v as Color),
    (d) => d.colorUploadFileCardFailInfoText,
    (t) => t.colors.colorDanger,
  ),
  (
    r'$color-upload_file_card_preview_placeholder-bg: rgba(var(--semi-grey-3), 1)',
    _c,
    (v) => SemiUploadThemeData(
      colorUploadFileCardPreviewPlaceholderBg: v as Color,
    ),
    (d) => d.colorUploadFileCardPreviewPlaceholderBg,
    (t) => t.palette.grey3.toColor(1),
  ),
  (
    r'$color-upload_file_card_preview_placeholder-text: rgba(var(--semi-white), 1)',
    _c,
    (v) => SemiUploadThemeData(
      colorUploadFileCardPreviewPlaceholderText: v as Color,
    ),
    (d) => d.colorUploadFileCardPreviewPlaceholderText,
    (t) => t.colors.colorWhite,
  ),
  (
    r'$color-upload_file_card_retry-bg: var(--semi-color-white)',
    _c,
    (v) => SemiUploadThemeData(colorUploadFileCardRetryBg: v as Color),
    (d) => d.colorUploadFileCardRetryBg,
    (t) => t.colors.colorWhite,
  ),
  (
    r'$color-upload_file_card_retry-text: var(--semi-color-primary)',
    _c,
    (v) => SemiUploadThemeData(colorUploadFileCardRetryText: v as Color),
    (d) => d.colorUploadFileCardRetryText,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-upload-icon: var(--semi-color-tertiary)',
    _c,
    (v) => SemiUploadThemeData(colorUploadIcon: v as Color),
    (d) => d.colorUploadIcon,
    (t) => t.colors.colorTertiary,
  ),
  (
    r'$color-upload_pic_add-bg-active: var(--semi-color-fill-2)',
    _c,
    (v) => SemiUploadThemeData(colorUploadPicAddBgActive: v as Color),
    (d) => d.colorUploadPicAddBgActive,
    (t) => t.colors.colorFill2,
  ),
  (
    r'$color-upload_pic_add-bg-hover: var(--semi-color-fill-1)',
    _c,
    (v) => SemiUploadThemeData(colorUploadPicAddBgHover: v as Color),
    (d) => d.colorUploadPicAddBgHover,
    (t) => t.colors.colorFill1,
  ),
  (
    r'$color-upload_pic_add-bg: var(--semi-color-fill-0)',
    _c,
    (v) => SemiUploadThemeData(colorUploadPicAddBg: v as Color),
    (d) => d.colorUploadPicAddBg,
    (t) => t.colors.colorFill0,
  ),
  (
    r'$color-upload_pic_remove-bg: var(--semi-color-overlay-bg)',
    _c,
    (v) => SemiUploadThemeData(colorUploadPicRemoveBg: v as Color),
    (d) => d.colorUploadPicRemoveBg,
    (t) => t.colors.colorOverlayBg,
  ),
  (
    r'$color-upload_picture_file_card_loading_error-icon: var(--semi-color-danger)',
    _c,
    (v) => SemiUploadThemeData(
      colorUploadPictureFileCardLoadingErrorIcon: v as Color,
    ),
    (d) => d.colorUploadPictureFileCardLoadingErrorIcon,
    (t) => t.colors.colorDanger,
  ),
  (
    r'$color-upload_picture_file_card_error-border: var(--semi-color-danger)',
    _c,
    (v) =>
        SemiUploadThemeData(colorUploadPictureFileCardErrorBorder: v as Color),
    (d) => d.colorUploadPictureFileCardErrorBorder,
    (t) => t.colors.colorDanger,
  ),
  (
    r'$color-upload_picture_file_card_pic_info-text: var(--semi-color-white)',
    _c,
    (v) =>
        SemiUploadThemeData(colorUploadPictureFileCardPicInfoText: v as Color),
    (d) => d.colorUploadPictureFileCardPicInfoText,
    (t) => t.colors.colorWhite,
  ),
  (
    r'$color-upload_picture_file_card_close-icon: var(--semi-color-white)',
    _c,
    (v) => SemiUploadThemeData(colorUploadPictureFileCardCloseIcon: v as Color),
    (d) => d.colorUploadPictureFileCardCloseIcon,
    (t) => t.colors.colorWhite,
  ),
  (
    r'$color-upload_picture_file_card_hover-bg: var(--semi-color-overlay-bg)',
    _c,
    (v) => SemiUploadThemeData(colorUploadPictureFileCardHoverBg: v as Color),
    (d) => d.colorUploadPictureFileCardHoverBg,
    (t) => t.colors.colorOverlayBg,
  ),
  (
    r'$color-upload_preview-icon: var(--semi-color-text-2)',
    _c,
    (v) => SemiUploadThemeData(colorUploadPreviewIcon: v as Color),
    (d) => d.colorUploadPreviewIcon,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-upload_retry-text: var(--semi-color-primary)',
    _c,
    (v) => SemiUploadThemeData(colorUploadRetryText: v as Color),
    (d) => d.colorUploadRetryText,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-upload_replace-text: var(--semi-color-white)',
    _c,
    (v) => SemiUploadThemeData(colorUploadReplaceText: v as Color),
    (d) => d.colorUploadReplaceText,
    (t) => t.colors.colorWhite,
  ),
  (
    r'$height-upload_file_card: 52px',
    52.0,
    (v) => SemiUploadThemeData(heightUploadFileCard: v as double),
    (d) => d.heightUploadFileCard,
    (t) => 52,
  ),
  (
    r'$width-upload_file_card: 250px',
    250.0,
    (v) => SemiUploadThemeData(widthUploadFileCard: v as double),
    (d) => d.widthUploadFileCard,
    (t) => 250,
  ),
  (
    r'$height-upload_file_pic_card: 96px',
    96.0,
    (v) => SemiUploadThemeData(heightUploadFilePicCard: v as double),
    (d) => d.heightUploadFilePicCard,
    (t) => 96,
  ),
  (
    r'$width-upload_file_pic_card: 96px',
    96.0,
    (v) => SemiUploadThemeData(widthUploadFilePicCard: v as double),
    (d) => d.widthUploadFilePicCard,
    (t) => 96,
  ),
  (
    r'$width-upload_file_card_preview: 36px',
    36.0,
    (v) => SemiUploadThemeData(widthUploadFileCardPreview: v as double),
    (d) => d.widthUploadFileCardPreview,
    (t) => 36,
  ),
  (
    r'$height-upload_file_card_preview: 36px',
    36.0,
    (v) => SemiUploadThemeData(heightUploadFileCardPreview: v as double),
    (d) => d.heightUploadFileCardPreview,
    (t) => 36,
  ),
  (
    r'$width-upload_file_card_preview_img: 36px',
    36.0,
    (v) => SemiUploadThemeData(widthUploadFileCardPreviewImg: v as double),
    (d) => d.widthUploadFileCardPreviewImg,
    (t) => 36,
  ),
  (
    r'$width-upload_file_card_info_name: 106px',
    106.0,
    (v) => SemiUploadThemeData(widthUploadFileCardInfoName: v as double),
    (d) => d.widthUploadFileCardInfoName,
    (t) => 106,
  ),
  (
    r'$width-upload_file_card-icon: 11px',
    11.0,
    (v) => SemiUploadThemeData(widthUploadFileCardIcon: v as double),
    (d) => d.widthUploadFileCardIcon,
    (t) => 11,
  ),
  (
    r'$width-upload_picture_add-border: 2px',
    2.0,
    (v) => SemiUploadThemeData(widthUploadPictureAddBorder: v as double),
    (d) => d.widthUploadPictureAddBorder,
    (t) => 2,
  ),
  (
    r'$width-upload_picture_file_card_img: 96px',
    96.0,
    (v) => SemiUploadThemeData(widthUploadPictureFileCardImg: v as double),
    (d) => d.widthUploadPictureFileCardImg,
    (t) => 96,
  ),
  (
    r'$width-upload_picture_file_card_close: 16px',
    16.0,
    (v) => SemiUploadThemeData(widthUploadPictureFileCardClose: v as double),
    (d) => d.widthUploadPictureFileCardClose,
    (t) => 16,
  ),
  (
    r'$width-upload_file_card_retry: 24px',
    24.0,
    (v) => SemiUploadThemeData(widthUploadFileCardRetry: v as double),
    (d) => d.widthUploadFileCardRetry,
    (t) => 24,
  ),
  (
    r'$width-upload_file_card_retry-icon: 13px',
    13.0,
    (v) => SemiUploadThemeData(widthUploadFileCardRetryIcon: v as double),
    (d) => d.widthUploadFileCardRetryIcon,
    (t) => 13,
  ),
  (
    r'$height-upload_file_card_retry-icon: 14px',
    14.0,
    (v) => SemiUploadThemeData(heightUploadFileCardRetryIcon: v as double),
    (d) => d.heightUploadFileCardRetryIcon,
    (t) => 14,
  ),
  (
    r'$width-upload_picture_file_card_loading-icon: 14px',
    14.0,
    (v) =>
        SemiUploadThemeData(widthUploadPictureFileCardLoadingIcon: v as double),
    (d) => d.widthUploadPictureFileCardLoadingIcon,
    (t) => 14,
  ),
  (
    r'$width-upload_drag_area-border: 2px',
    2.0,
    (v) => SemiUploadThemeData(widthUploadDragAreaBorder: v as double),
    (d) => d.widthUploadDragAreaBorder,
    (t) => 2,
  ),
  (
    r'$spacing-upload_title_choosen-marginRight: $spacing-tight',
    8.0,
    (v) =>
        SemiUploadThemeData(spacingUploadTitleChoosenMarginRight: v as double),
    (d) => d.spacingUploadTitleChoosenMarginRight,
    (t) => 8,
  ),
  (
    r'$spacing-upload_title-marginBottom: $spacing-extra-tight',
    4.0,
    (v) => SemiUploadThemeData(spacingUploadTitleMarginBottom: v as double),
    (d) => d.spacingUploadTitleMarginBottom,
    (t) => 4,
  ),
  (
    r'$spacing-upload_file_card_preview-margin: $spacing-tight',
    8.0,
    (v) => SemiUploadThemeData(spacingUploadFileCardPreviewMargin: v as double),
    (d) => d.spacingUploadFileCardPreviewMargin,
    (t) => 8,
  ),
  (
    r'$spacing-upload_file_card_info_size-marginLeft: $spacing-tight',
    8.0,
    (v) => SemiUploadThemeData(
      spacingUploadFileCardInfoSizeMarginLeft: v as double,
    ),
    (d) => d.spacingUploadFileCardInfoSizeMarginLeft,
    (t) => 8,
  ),
  (
    r'$spacing-upload_file_card_info_retry-marginLeft: $spacing-tight',
    8.0,
    (v) => SemiUploadThemeData(
      spacingUploadFileCardInfoRetryMarginLeft: v as double,
    ),
    (d) => d.spacingUploadFileCardInfoRetryMarginLeft,
    (t) => 8,
  ),
  (
    r'$spacing-upload_file_card_info_progress-marginTop: 4px',
    4.0,
    (v) => SemiUploadThemeData(
      spacingUploadFileCardInfoProgressMarginTop: v as double,
    ),
    (d) => d.spacingUploadFileCardInfoProgressMarginTop,
    (t) => 4,
  ),
  (
    r'$spacing-upload_file_card_close-marginLeft: $spacing-tight',
    8.0,
    (v) =>
        SemiUploadThemeData(spacingUploadFileCardCloseMarginLeft: v as double),
    (d) => d.spacingUploadFileCardCloseMarginLeft,
    (t) => 8,
  ),
  (
    r'$spacing-upload_file_card_close-marginRight: $spacing-tight',
    8.0,
    (v) =>
        SemiUploadThemeData(spacingUploadFileCardCloseMarginRight: v as double),
    (d) => d.spacingUploadFileCardCloseMarginRight,
    (t) => 8,
  ),
  (
    r'$spacing-upload_file_card_icon-marginRight: $spacing-super-tight',
    2.0,
    (v) =>
        SemiUploadThemeData(spacingUploadFileCardIconMarginRight: v as double),
    (d) => d.spacingUploadFileCardIconMarginRight,
    (t) => 2,
  ),
  (
    r'$spacing-upload_picture_file_card-gap: $spacing-tight',
    8.0,
    (v) => SemiUploadThemeData(spacingUploadPictureFileCardGap: v as double),
    (d) => d.spacingUploadPictureFileCardGap,
    (t) => 8,
  ),
  (
    r'$spacing-upload_picture_file_card-marginBottom: $spacing-tight',
    8.0,
    (v) => SemiUploadThemeData(
      spacingUploadPictureFileCardMarginBottom: v as double,
    ),
    (d) => d.spacingUploadPictureFileCardMarginBottom,
    (t) => 8,
  ),
  (
    r'$spacing-upload_picture_file_card_close-top: 8px',
    8.0,
    (v) =>
        SemiUploadThemeData(spacingUploadPictureFileCardCloseTop: v as double),
    (d) => d.spacingUploadPictureFileCardCloseTop,
    (t) => 8,
  ),
  (
    r'$spacing-upload_picture_file_card_close-right: 8px',
    8.0,
    (v) => SemiUploadThemeData(
      spacingUploadPictureFileCardCloseRight: v as double,
    ),
    (d) => d.spacingUploadPictureFileCardCloseRight,
    (t) => 8,
  ),
  (
    r'$spacing-upload_picture_file_card_loading_error-bottom: 6px',
    6.0,
    (v) => SemiUploadThemeData(
      spacingUploadPictureFileCardLoadingErrorBottom: v as double,
    ),
    (d) => d.spacingUploadPictureFileCardLoadingErrorBottom,
    (t) => 6,
  ),
  (
    r'$spacing-upload_picture_file_card_loading_error-right: 6px',
    6.0,
    (v) => SemiUploadThemeData(
      spacingUploadPictureFileCardLoadingErrorRight: v as double,
    ),
    (d) => d.spacingUploadPictureFileCardLoadingErrorRight,
    (t) => 6,
  ),
  (
    r'$spacing-upload_picture_file_card_icon_error-top: -1px',
    -1.0,
    (v) => SemiUploadThemeData(
      spacingUploadPictureFileCardIconErrorTop: v as double,
    ),
    (d) => d.spacingUploadPictureFileCardIconErrorTop,
    (t) => -1,
  ),
  (
    r'$spacing-upload_drag_area-padding: $spacing-base-tight',
    12.0,
    (v) => SemiUploadThemeData(spacingUploadDragAreaPadding: v as double),
    (d) => d.spacingUploadDragAreaPadding,
    (t) => 12,
  ),
  (
    r'$spacing-upload_drag_area_main_text-marginBottom: $spacing-extra-tight',
    4.0,
    (v) => SemiUploadThemeData(
      spacingUploadDragAreaMainTextMarginBottom: v as double,
    ),
    (d) => d.spacingUploadDragAreaMainTextMarginBottom,
    (t) => 4,
  ),
  (
    r'$radius-upload_file_card: var(--semi-border-radius-medium)',
    101.0,
    (v) => SemiUploadThemeData(radiusUploadFileCard: v as double),
    (d) => d.radiusUploadFileCard,
    (t) => t.radius.borderRadiusMedium.value,
  ),
  (
    r'$radius-upload_file_card_preview: var(--semi-border-radius-small)',
    101.0,
    (v) => SemiUploadThemeData(radiusUploadFileCardPreview: v as double),
    (d) => d.radiusUploadFileCardPreview,
    (t) => t.radius.borderRadiusSmall.value,
  ),
  (
    r'$radius-upload_picture_add: var(--semi-border-radius-small)',
    101.0,
    (v) => SemiUploadThemeData(radiusUploadPictureAdd: v as double),
    (d) => d.radiusUploadPictureAdd,
    (t) => t.radius.borderRadiusSmall.value,
  ),
  (
    r'$radius-upload_picture_file_card_img: var(--semi-border-radius-small)',
    101.0,
    (v) => SemiUploadThemeData(radiusUploadPictureFileCardImg: v as double),
    (d) => d.radiusUploadPictureFileCardImg,
    (t) => t.radius.borderRadiusSmall.value,
  ),
  (
    r'$radius-upload_picture_file_card_close: var(--semi-border-radius-circle)',
    101.0,
    (v) => SemiUploadThemeData(radiusUploadPictureFileCardClose: v as double),
    (d) => d.radiusUploadPictureFileCardClose,
    (t) => t.radius.borderRadiusCircle.value,
  ),
  (
    r'$radius-upload_file_card_retry: var(--semi-border-radius-circle)',
    101.0,
    (v) => SemiUploadThemeData(radiusUploadFileCardRetry: v as double),
    (d) => d.radiusUploadFileCardRetry,
    (t) => t.radius.borderRadiusCircle.value,
  ),
  (
    r'$radius-upload_drag_area: var(--semi-border-radius-small)',
    101.0,
    (v) => SemiUploadThemeData(radiusUploadDragArea: v as double),
    (d) => d.radiusUploadDragArea,
    (t) => t.radius.borderRadiusSmall.value,
  ),
  (
    r'$font-upload_file_card_info_name-fontWeight: $font-weight-bold',
    FontWeight.w300,
    (v) => SemiUploadThemeData(
      fontUploadFileCardInfoNameFontWeight: v as FontWeight,
    ),
    (d) => d.fontUploadFileCardInfoNameFontWeight,
    (t) => t.typography.fontWeightBold,
  ),
  (
    r'$font-upload_file_card_info_size-fontWeight: $font-weight-regular',
    FontWeight.w300,
    (v) => SemiUploadThemeData(
      fontUploadFileCardInfoSizeFontWeight: v as FontWeight,
    ),
    (d) => d.fontUploadFileCardInfoSizeFontWeight,
    (t) => t.typography.fontWeightRegular,
  ),
  (
    r'$font-upload_drag_area_tips-fontWeight: 600',
    FontWeight.w300,
    (v) =>
        SemiUploadThemeData(fontUploadDragAreaTipsFontWeight: v as FontWeight),
    (d) => d.fontUploadDragAreaTipsFontWeight,
    (t) => FontWeight.w600,
  ),
  (
    r'$font-upload_picture_file_card_pic_info-fontSize: 12px',
    12.0,
    (v) => SemiUploadThemeData(
      fontUploadPictureFileCardPicInfoFontSize: v as double,
    ),
    (d) => d.fontUploadPictureFileCardPicInfoFontSize,
    (t) => 12,
  ),
  (
    r'$font-upload_picture_file_card_pic_info-fontWeight: 600',
    FontWeight.w300,
    (v) => SemiUploadThemeData(
      fontUploadPictureFileCardPicInfoFontWeight: v as FontWeight,
    ),
    (d) => d.fontUploadPictureFileCardPicInfoFontWeight,
    (t) => FontWeight.w600,
  ),
];

void main() {
  group('theme fields (85 = 85 FIELDS + 0 MOTION + 0 INTERNAL)', () {
    test('85 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(85));
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(const SemiUploadThemeData().merge(patch), patch, reason: sass);
        expect(patch.copyWith(), patch, reason: sass);
        expect(patch.copyWith().hashCode, patch.hashCode, reason: sass);
        expect(patch.merge(null), patch, reason: sass);
        expect(
          read(patch.resolve(const SemiThemeData.dark())),
          value,
          reason: sass,
        );
        final light = const SemiThemeData.light();
        expect(
          read(const SemiUploadThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiUploadThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_upload_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(85));
      expect(source, contains('rgba(var(--semi-grey-3), 1)'));
      expect(source, contains('rgba(var(--semi-white), 1)'));
      expect(
        source,
        contains('packages/semi-foundation/upload/variables.scss'),
      );
      expect(source, contains('Generated by tool/generate_upload.py'));
      expect(source, contains('# dead variable (上游未消费)'));
    });

    test('the 20 HARDCODES anchors live in the widget source', () {
      final widgetSource = File('lib/src/components/semi_upload.dart')
          .readAsStringSync();
      const anchors = <String>[
        'byteKB = 1024',
        'PROGRESS_COEFFICIENT: 0.95',
        "'点击上传文件或拖拽文件到这里'",
        "'松手开始上传'",
        "'不支持此类型文件'",
        "'重试'",
        "'替换文件'",
        "'清空'",
        "'已选择文件'",
        "'文件尺寸不合法'",
        "'上传失败'",
        'IconUpload size="extra-large"',
        'aria-label="picture list"',
        'aria-label="file list"',
        "PROMPT_POSITION: ['left', 'right', 'bottom']",
        'linear-gradient(0deg, rgba(22, 22, 26, 0.3) 0%, rgba(22, 22, 26, 0) 77.08%)',
        'toFixed(2)',
        'rgba(var(--semi-white), 1)',
        'rgba(var(--semi-grey-3), 1)',
        'getUuidv4()',
      ];
      expect(anchors, hasLength(20));
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test('type coverage: 38 Color + 43 double + 4 FontWeight = 85', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        counts.update(
          value.runtimeType.toString(),
          (n) => n + 1,
          ifAbsent: () => 1,
        );
      }
      expect(counts['Color'], 38);
      expect(counts['double'], 43);
      expect(counts['FontWeight'], 4);
    });

    test('3 dead variables: word-boundary assertNotIn + docs marks', () {
      const deadFields = [
        'colorUploadPicRemoveBg',
        'heightUploadFileCardRetryIcon',
        'widthUploadFileCardInfoName',
      ];
      final widgetSource = File('lib/src/components/semi_upload.dart')
          .readAsStringSync();
      for (final name in deadFields) {
        final match = RegExp('(?<![A-Za-z])$name(?![A-Za-z])')
            .firstMatch(widgetSource);
        expect(match, isNull, reason: name);
      }
      final docs = File('docs/semi_upload.md').readAsStringSync();
      expect(docs, contains('85 = 85 FIELDS + 0 MOTION + 0 INTERNAL'));
      expect(docs, contains('3 死变量'));
      expect(docs, contains('（上游未消费）'));
    });

    test('SemiComponentThemes wiring', () {
      const themes = SemiComponentThemes();
      expect(themes.upload, const SemiUploadThemeData());
      expect(
        themes.copyWith(
          upload: const SemiUploadThemeData(widthUploadFileCard: 260),
        ),
        const SemiComponentThemes(
          upload: SemiUploadThemeData(widthUploadFileCard: 260),
        ),
      );
    });
  });

  group('behavior', () {
    testWidgets('picking files runs the lifecycle: add(wait) → request → '
        'progress → success', (tester) async {
      final changes = <SemiUploadChangeInfo>[];
      SemiUploadRequestArgs? request;
      Object? successResponse;
      await pumpHost(
        tester,
        pickable(
          const [
            SemiUploadFile(uid: 'u1', name: 'a.png', size: 1024, isImage: true),
          ],
          onChange: changes.add,
          onRequest: (args) => request = args,
          onSuccess: (response, file, list) => successResponse = response,
        ),
      );
      await tester.tap(find.text('trigger'));
      await settle(tester);
      expect(find.text('a.png'), findsOneWidget);
      expect(changes, isNotEmpty);
      expect(changes.last.currentFile!.name, 'a.png');
      expect(request, isNotNull);
      // 失败文件才出现重试；当前正在 uploading。
      expect(find.text('重试'), findsNothing);
      request!.onProgress(40);
      await settle(tester);
      expect(find.byType(SemiProgress), findsOneWidget);
      request!.onSuccess({'ok': 1});
      await settle(tester);
      expect(successResponse, isNotNull);
      expect(changes.last.currentFile!.status, SemiUploadFileStatus.success);
      expect(tester.takeException(), isNull);
    });

    testWidgets('limit === 1 replaces the whole list with the last file', (
      tester,
    ) async {
      final exceeded = <List<SemiUploadFile>>[];
      final changes = <SemiUploadChangeInfo>[];
      await pumpHost(
        tester,
        pickable(
          const [
            SemiUploadFile(uid: 'x', name: 'x.png', size: 10),
            SemiUploadFile(uid: 'y', name: 'y.png', size: 10),
          ],
          defaultFileList: const [
            SemiUploadFile(uid: 'old', name: 'old.png', size: 10),
          ],
          limit: 1,
          onExceed: exceeded.add,
          onChange: changes.add,
        ),
      );
      await tester.tap(find.text('trigger'));
      await settle(tester);
      expect(find.text('y.png'), findsOneWidget);
      expect(find.text('x.png'), findsNothing);
      expect(find.text('old.png'), findsNothing);
      expect(exceeded, hasLength(1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('accept/size validation and beforeUpload results', (
      tester,
    ) async {
      final invalid = <List<SemiUploadFile>>[];
      final sizeErrors = <String>[];
      await pumpHost(
        tester,
        pickable(
          const [SemiUploadFile(uid: 't', name: 'a.txt', size: 10)],
          accept: '.png',
          onAcceptInvalid: invalid.add,
        ),
      );
      await tester.tap(find.text('trigger'));
      await settle(tester);
      expect(invalid, hasLength(1));
      expect(find.text('a.txt'), findsNothing);

      final requests = <String>[];
      await pumpHost(
        tester,
        pickable(
          const [SemiUploadFile(uid: 'big', name: 'big.png', size: 4096)],
          maxSize: 1,
          onSizeError: (file, list) => sizeErrors.add(file.name),
          onRequest: (args) => requests.add(args.file.name),
        ),
      );
      await tester.tap(find.text('trigger'));
      await settle(tester);
      expect(sizeErrors, ['big.png']);
      expect(find.text('文件尺寸不合法'), findsOneWidget);
      expect(requests, isEmpty);

      final rejectedRequests = <String>[];
      await pumpHost(
        tester,
        pickable(
          const [SemiUploadFile(uid: 'r', name: 'r.png', size: 10)],
          beforeUpload: (file, list) => false,
          onRequest: (args) => rejectedRequests.add(args.file.name),
        ),
      );
      await tester.tap(find.text('trigger'));
      await settle(tester);
      expect(rejectedRequests, isEmpty);
      // 文件仍在列表中（validateFail），但不发请求。
      expect(find.text('r.png'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('upload failure shows retry and retrying re-requests', (
      tester,
    ) async {
      final requests = <SemiUploadRequestArgs>[];
      final retries = <String>[];
      final errors = <Object?>[];
      await pumpHost(
        tester,
        pickable(
          const [SemiUploadFile(uid: 'e', name: 'e.png', size: 10)],
          onRequest: requests.add,
          onRetry: (file) => retries.add(file.name),
          onError: (error, file, list) => errors.add(error),
        ),
      );
      await tester.tap(find.text('trigger'));
      await settle(tester);
      requests.single.onError('boom', '网络错误');
      await settle(tester);
      expect(find.text('网络错误'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);
      await tester.tap(find.text('重试'));
      await settle(tester);
      expect(retries, ['e.png']);
      expect(requests, hasLength(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('remove (close) and clear update the list', (tester) async {
      final removed = <String>[];
      final cleared = <List<SemiUploadFile>>[];
      await pumpHost(
        tester,
        pickable(
          const [],
          defaultFileList: const [
            SemiUploadFile(uid: 'r1', name: 'one.png', size: 10),
            SemiUploadFile(uid: 'r2', name: 'two.png', size: 10),
          ],
          onRemove: (file, list) => removed.add(file.name),
          onClear: cleared.add,
        ),
      );
      await tester.tap(find.byKey(const ValueKey('SemiUpload.remove.r1')));
      await settle(tester);
      expect(removed, ['one.png']);
      expect(find.text('one.png'), findsNothing);
      expect(find.text('two.png'), findsOneWidget);
      await tester.tap(find.text('清空'));
      await settle(tester);
      expect(cleared, hasLength(1));
      expect(find.text('two.png'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('picture list renders cards + add trigger and appends picked', (
      tester,
    ) async {
      await pumpHost(
        tester,
        pickable(
          const [
            SemiUploadFile(
              uid: 'p2',
              name: 'b.png',
              size: 10,
              status: SemiUploadFileStatus.success,
            ),
          ],
          listType: SemiUploadListType.picture,
          showPicInfo: true,
          defaultFileList: const [
            SemiUploadFile(
              uid: 'p1',
              name: 'a.png',
              size: 10,
              status: SemiUploadFileStatus.success,
            ),
          ],
        ),
      );
      expect(find.byKey(SemiUpload.listKey), findsOneWidget);
      expect(find.text('b.png'), findsNothing);
      await tester.tap(find.byKey(SemiUpload.triggerKey));
      await settle(tester);
      // 图片墙卡片为缩略图/序号，不渲染文件名文本。
      expect(find.text('b.png'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('drag area renders texts, tips and disables cleanly', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiUpload(
          dragArea: true,
          onPickFiles: () async => const [],
          onRequest: (_) {},
        ),
      );
      expect(find.text('点击上传文件或拖拽文件到这里'), findsOneWidget);
      await pumpHost(
        tester,
        SemiUpload(
          dragArea: true,
          dragAreaStatus: SemiUploadDragAreaStatus.legal,
          onPickFiles: () async => const [],
          onRequest: (_) {},
        ),
      );
      expect(find.text('松手开始上传'), findsOneWidget);
      await pumpHost(
        tester,
        SemiUpload(
          disabled: true,
          dragArea: true,
          defaultFileList: const [
            SemiUploadFile(uid: 'd', name: 'dis.png', size: 10),
          ],
          children: const Text('trigger'),
        ),
      );
      await settle(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('controlled fileList only reports callbacks', (tester) async {
      final changes = <SemiUploadChangeInfo>[];
      await pumpHost(
        tester,
        pickable(
          const [SemiUploadFile(uid: 'n', name: 'new.png', size: 10)],
          fileList: const [
            SemiUploadFile(uid: 'c', name: 'fixed.png', size: 10),
          ],
          onChange: changes.add,
        ),
      );
      expect(find.text('fixed.png'), findsOneWidget);
      await tester.tap(find.text('trigger'));
      await settle(tester);
      expect(changes, isNotEmpty);
      expect(find.text('fixed.png'), findsOneWidget);
      expect(find.text('new.png'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('prompt positions and renderFileItem override', (tester) async {
      await pumpHost(tester, pickable(const [], prompt: '提示文案'));
      expect(find.text('提示文案'), findsOneWidget);
      await pumpHost(
        tester,
        pickable(
          const [],
          defaultFileList: const [
            SemiUploadFile(uid: 'i', name: 'item.png', size: 10),
          ],
          renderFileItem: (props) => Text('custom-${props.file.name}'),
        ),
      );
      expect(find.text('custom-item.png'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('RTL renders list and picture without layout errors', (
      tester,
    ) async {
      await pumpHost(
        tester,
        pickable(
          const [],
          defaultFileList: const [
            SemiUploadFile(uid: 'r', name: 'rtl.png', size: 10),
          ],
        ),
        direction: TextDirection.rtl,
      );
      expect(find.text('rtl.png'), findsOneWidget);
      await pumpHost(
        tester,
        pickable(const [], listType: SemiUploadListType.picture),
        direction: TextDirection.rtl,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
