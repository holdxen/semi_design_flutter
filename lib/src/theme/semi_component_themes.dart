import 'package:flutter/foundation.dart';

import 'semi_tag_theme_data.dart';
import 'semi_divider_theme_data.dart';
import 'semi_progress_theme_data.dart';
import 'semi_spin_theme_data.dart';
import 'semi_highlight_theme_data.dart';
import 'semi_empty_theme_data.dart';
import 'semi_timeline_theme_data.dart';
import 'semi_descriptions_theme_data.dart';
import 'semi_tooltip_theme_data.dart';
import 'semi_collapse_theme_data.dart';
import 'semi_collapsible_theme_data.dart';
import 'semi_dropdown_theme_data.dart';
import 'semi_context_menu_theme_data.dart';
import 'semi_button_theme_data.dart';
import 'semi_card_theme_data.dart';
import 'semi_typography_theme_data.dart';
import 'semi_checkbox_theme_data.dart';
import 'semi_input_theme_data.dart';
import 'semi_input_number_theme_data.dart';
import 'semi_pincode_theme_data.dart';
import 'semi_autocomplete_theme_data.dart';
import 'semi_radio_theme_data.dart';
import 'semi_rating_theme_data.dart';
import 'semi_select_theme_data.dart';
import 'semi_slider_theme_data.dart';
import 'semi_switch_theme_data.dart';
import 'semi_tag_input_theme_data.dart';
import 'semi_date_picker_theme_data.dart';
import 'semi_color_picker_theme_data.dart';
import 'semi_time_picker_theme_data.dart';
import 'semi_transfer_theme_data.dart';
import 'semi_anchor_theme_data.dart';
import 'semi_backtop_theme_data.dart';
import 'semi_breadcrumb_theme_data.dart';
import 'semi_navigation_theme_data.dart';
import 'semi_pagination_theme_data.dart';
import 'semi_tree_theme_data.dart';
import 'semi_tree_select_theme_data.dart';
import 'semi_cascader_theme_data.dart';
import 'semi_form_theme_data.dart';
import 'semi_steps_theme_data.dart';
import 'semi_upload_theme_data.dart';
import 'semi_skeleton_theme_data.dart';
import 'semi_tabs_theme_data.dart';
import 'semi_chrome_tab_theme_data.dart';
import 'semi_carousel_theme_data.dart';
import 'semi_modal_theme_data.dart';
import 'semi_popover_theme_data.dart';
import 'semi_popconfirm_theme_data.dart';
import 'semi_banner_theme_data.dart';
import 'semi_notification_theme_data.dart';
import 'semi_badge_theme_data.dart';
import 'semi_avatar_theme_data.dart';
import 'semi_cropper_theme_data.dart';
import 'semi_side_sheet_theme_data.dart';
import 'semi_scroll_list_theme_data.dart';
import 'semi_scroll_bar_theme_data.dart';
import 'semi_float_button_theme_data.dart';
import 'semi_image_theme_data.dart';
import 'semi_toast_theme_data.dart';
import 'semi_feedback_theme_data.dart';
import 'semi_user_guide_theme_data.dart';

@immutable
class SemiComponentThemes {
  const SemiComponentThemes({
    this.tag = const SemiTagThemeData(),
    this.typography = const SemiTypographyThemeData(),
    this.divider = const SemiDividerThemeData(),
    this.progress = const SemiProgressThemeData(),
    this.spin = const SemiSpinThemeData(),
    this.highlight = const SemiHighlightThemeData(),
    this.empty = const SemiEmptyThemeData(),
    this.timeline = const SemiTimelineThemeData(),
    this.descriptions = const SemiDescriptionsThemeData(),
    this.tooltip = const SemiTooltipThemeData(),
    this.collapse = const SemiCollapseThemeData(),
    this.collapsible = const SemiCollapsibleThemeData(),
    this.dropdown = const SemiDropdownThemeData(),
    this.contextMenu = const SemiContextMenuThemeData(),
    this.button = const SemiButtonThemeData(),
    this.card = const SemiCardThemeData(),
    this.checkbox = const SemiCheckboxThemeData(),
    this.input = const SemiInputThemeData(),
    this.inputNumber = const SemiInputNumberThemeData(),
    this.pinCode = const SemiPinCodeThemeData(),
    this.autocomplete = const SemiAutoCompleteThemeData(),
    this.radio = const SemiRadioThemeData(),
    this.rating = const SemiRatingThemeData(),
    this.select = const SemiSelectThemeData(),
    this.slider = const SemiSliderThemeData(),
    this.switcher = const SemiSwitchThemeData(),
    this.tagInput = const SemiTagInputThemeData(),
    this.datePicker = const SemiDatePickerThemeData(),
    this.colorPicker = const SemiColorPickerThemeData(),
    this.timePicker = const SemiTimePickerThemeData(),
    this.transfer = const SemiTransferThemeData(),
    this.anchor = const SemiAnchorThemeData(),
    this.backTop = const SemiBackTopThemeData(),
    this.breadcrumb = const SemiBreadcrumbThemeData(),
    this.navigation = const SemiNavigationThemeData(),
    this.pagination = const SemiPaginationThemeData(),
    this.tree = const SemiTreeThemeData(),
    this.treeSelect = const SemiTreeSelectThemeData(),
    this.cascader = const SemiCascaderThemeData(),
    this.form = const SemiFormThemeData(),
    this.steps = const SemiStepsThemeData(),
    this.upload = const SemiUploadThemeData(),
    this.skeleton = const SemiSkeletonThemeData(),
    this.tabs = const SemiTabsThemeData(),
    this.chromeTab = const SemiChromeTabThemeData(),
    this.carousel = const SemiCarouselThemeData(),
    this.modal = const SemiModalThemeData(),
    this.popover = const SemiPopoverThemeData(),
    this.popconfirm = const SemiPopconfirmThemeData(),
    this.banner = const SemiBannerThemeData(),
    this.notification = const SemiNotificationThemeData(),
    this.badge = const SemiBadgeThemeData(),
    this.avatar = const SemiAvatarThemeData(),
    this.cropper = const SemiCropperThemeData(),
    this.sideSheet = const SemiSideSheetThemeData(),
    this.scrollList = const SemiScrollListThemeData(),
    this.scrollBar = const SemiScrollBarThemeData(),
    this.floatButton = const SemiFloatButtonThemeData(),
    this.image = const SemiImageThemeData(),
    this.toast = const SemiToastThemeData(),
    this.feedback = const SemiFeedbackThemeData(),
    this.userGuide = const SemiUserGuideThemeData(),
  });
  final SemiTagThemeData tag;
  final SemiTypographyThemeData typography;
  final SemiDividerThemeData divider;
  final SemiProgressThemeData progress;
  final SemiSpinThemeData spin;
  final SemiHighlightThemeData highlight;
  final SemiEmptyThemeData empty;
  final SemiTimelineThemeData timeline;
  final SemiDescriptionsThemeData descriptions;
  final SemiTooltipThemeData tooltip;
  final SemiCollapseThemeData collapse;
  final SemiCollapsibleThemeData collapsible;
  final SemiDropdownThemeData dropdown;
  final SemiContextMenuThemeData contextMenu;
  final SemiButtonThemeData button;
  final SemiCardThemeData card;
  final SemiCheckboxThemeData checkbox;
  final SemiInputThemeData input;
  final SemiInputNumberThemeData inputNumber;
  final SemiPinCodeThemeData pinCode;
  final SemiAutoCompleteThemeData autocomplete;
  final SemiRadioThemeData radio;
  final SemiRatingThemeData rating;
  final SemiSelectThemeData select;
  final SemiSliderThemeData slider;

  /// Maps to the Switch component — the field is named `switcher` because
  /// `switch` is a Dart reserved word and cannot be an identifier.
  final SemiSwitchThemeData switcher;
  final SemiTagInputThemeData tagInput;
  final SemiDatePickerThemeData datePicker;
  final SemiColorPickerThemeData colorPicker;
  final SemiTimePickerThemeData timePicker;
  final SemiTransferThemeData transfer;
  final SemiAnchorThemeData anchor;
  final SemiBackTopThemeData backTop;
  final SemiBreadcrumbThemeData breadcrumb;
  final SemiNavigationThemeData navigation;
  final SemiPaginationThemeData pagination;
  final SemiTreeThemeData tree;
  final SemiTreeSelectThemeData treeSelect;
  final SemiCascaderThemeData cascader;
  final SemiFormThemeData form;
  final SemiStepsThemeData steps;
  final SemiUploadThemeData upload;
  final SemiSkeletonThemeData skeleton;
  final SemiTabsThemeData tabs;
  final SemiChromeTabThemeData chromeTab;
  final SemiCarouselThemeData carousel;
  final SemiModalThemeData modal;
  final SemiPopoverThemeData popover;
  final SemiPopconfirmThemeData popconfirm;
  final SemiBannerThemeData banner;
  final SemiNotificationThemeData notification;
  final SemiBadgeThemeData badge;
  final SemiAvatarThemeData avatar;
  final SemiCropperThemeData cropper;
  final SemiSideSheetThemeData sideSheet;
  final SemiScrollListThemeData scrollList;
  final SemiScrollBarThemeData scrollBar;
  final SemiFloatButtonThemeData floatButton;
  final SemiImageThemeData image;
  final SemiToastThemeData toast;
  final SemiFeedbackThemeData feedback;
  final SemiUserGuideThemeData userGuide;
  SemiComponentThemes copyWith({
    SemiTagThemeData? tag,
    SemiTypographyThemeData? typography,
    SemiDividerThemeData? divider,
    SemiProgressThemeData? progress,
    SemiSpinThemeData? spin,
    SemiHighlightThemeData? highlight,
    SemiEmptyThemeData? empty,
    SemiTimelineThemeData? timeline,
    SemiDescriptionsThemeData? descriptions,
    SemiTooltipThemeData? tooltip,
    SemiCollapseThemeData? collapse,
    SemiCollapsibleThemeData? collapsible,
    SemiDropdownThemeData? dropdown,
    SemiContextMenuThemeData? contextMenu,
    SemiButtonThemeData? button,
    SemiCardThemeData? card,
    SemiCheckboxThemeData? checkbox,
    SemiInputThemeData? input,
    SemiInputNumberThemeData? inputNumber,
    SemiPinCodeThemeData? pinCode,
    SemiAutoCompleteThemeData? autocomplete,
    SemiRadioThemeData? radio,
    SemiRatingThemeData? rating,
    SemiSelectThemeData? select,
    SemiSliderThemeData? slider,
    SemiSwitchThemeData? switcher,
    SemiTagInputThemeData? tagInput,
    SemiDatePickerThemeData? datePicker,
    SemiColorPickerThemeData? colorPicker,
    SemiTimePickerThemeData? timePicker,
    SemiTransferThemeData? transfer,
    SemiAnchorThemeData? anchor,
    SemiBackTopThemeData? backTop,
    SemiBreadcrumbThemeData? breadcrumb,
    SemiNavigationThemeData? navigation,
    SemiPaginationThemeData? pagination,
    SemiTreeThemeData? tree,
    SemiTreeSelectThemeData? treeSelect,
    SemiCascaderThemeData? cascader,
    SemiFormThemeData? form,
    SemiStepsThemeData? steps,
    SemiUploadThemeData? upload,
    SemiSkeletonThemeData? skeleton,
    SemiTabsThemeData? tabs,
    SemiChromeTabThemeData? chromeTab,
    SemiCarouselThemeData? carousel,
    SemiModalThemeData? modal,
    SemiPopoverThemeData? popover,
    SemiPopconfirmThemeData? popconfirm,
    SemiBannerThemeData? banner,
    SemiNotificationThemeData? notification,
    SemiBadgeThemeData? badge,
    SemiAvatarThemeData? avatar,
    SemiCropperThemeData? cropper,
    SemiSideSheetThemeData? sideSheet,
    SemiScrollListThemeData? scrollList,
    SemiScrollBarThemeData? scrollBar,
    SemiFloatButtonThemeData? floatButton,
    SemiImageThemeData? image,
    SemiToastThemeData? toast,
    SemiFeedbackThemeData? feedback,
    SemiUserGuideThemeData? userGuide,
  }) => SemiComponentThemes(
    tag: tag ?? this.tag,
    typography: typography ?? this.typography,
    divider: divider ?? this.divider,
    progress: progress ?? this.progress,
    spin: spin ?? this.spin,
    highlight: highlight ?? this.highlight,
    empty: empty ?? this.empty,
    timeline: timeline ?? this.timeline,
    descriptions: descriptions ?? this.descriptions,
    tooltip: tooltip ?? this.tooltip,
    collapse: collapse ?? this.collapse,
    collapsible: collapsible ?? this.collapsible,
    dropdown: dropdown ?? this.dropdown,
    contextMenu: contextMenu ?? this.contextMenu,
    button: button ?? this.button,
    card: card ?? this.card,
    checkbox: checkbox ?? this.checkbox,
    input: input ?? this.input,
    inputNumber: inputNumber ?? this.inputNumber,
    pinCode: pinCode ?? this.pinCode,
    autocomplete: autocomplete ?? this.autocomplete,
    radio: radio ?? this.radio,
    rating: rating ?? this.rating,
    select: select ?? this.select,
    slider: slider ?? this.slider,
    switcher: switcher ?? this.switcher,
    tagInput: tagInput ?? this.tagInput,
    datePicker: datePicker ?? this.datePicker,
    colorPicker: colorPicker ?? this.colorPicker,
    timePicker: timePicker ?? this.timePicker,
    transfer: transfer ?? this.transfer,
    anchor: anchor ?? this.anchor,
    backTop: backTop ?? this.backTop,
    breadcrumb: breadcrumb ?? this.breadcrumb,
    navigation: navigation ?? this.navigation,
    pagination: pagination ?? this.pagination,
    tree: tree ?? this.tree,
    treeSelect: treeSelect ?? this.treeSelect,
    cascader: cascader ?? this.cascader,
    form: form ?? this.form,
    steps: steps ?? this.steps,
    upload: upload ?? this.upload,
    skeleton: skeleton ?? this.skeleton,
    tabs: tabs ?? this.tabs,
    chromeTab: chromeTab ?? this.chromeTab,
    carousel: carousel ?? this.carousel,
    modal: modal ?? this.modal,
    popover: popover ?? this.popover,
    popconfirm: popconfirm ?? this.popconfirm,
    banner: banner ?? this.banner,
    notification: notification ?? this.notification,
    badge: badge ?? this.badge,
    avatar: avatar ?? this.avatar,
    cropper: cropper ?? this.cropper,
    sideSheet: sideSheet ?? this.sideSheet,
    scrollList: scrollList ?? this.scrollList,
    scrollBar: scrollBar ?? this.scrollBar,
    floatButton: floatButton ?? this.floatButton,
    image: image ?? this.image,
    toast: toast ?? this.toast,
    feedback: feedback ?? this.feedback,
    userGuide: userGuide ?? this.userGuide,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiComponentThemes &&
          tag == other.tag &&
          typography == other.typography &&
          divider == other.divider &&
          progress == other.progress &&
          spin == other.spin &&
          highlight == other.highlight &&
          empty == other.empty &&
          timeline == other.timeline &&
          descriptions == other.descriptions &&
          tooltip == other.tooltip &&
          collapse == other.collapse &&
          collapsible == other.collapsible &&
          dropdown == other.dropdown &&
          contextMenu == other.contextMenu &&
          button == other.button &&
          card == other.card &&
          checkbox == other.checkbox &&
          input == other.input &&
          inputNumber == other.inputNumber &&
          pinCode == other.pinCode &&
          autocomplete == other.autocomplete &&
          radio == other.radio &&
          rating == other.rating &&
          select == other.select &&
          slider == other.slider &&
          switcher == other.switcher &&
          tagInput == other.tagInput &&
          datePicker == other.datePicker &&
          colorPicker == other.colorPicker &&
          timePicker == other.timePicker &&
          transfer == other.transfer &&
          anchor == other.anchor &&
          backTop == other.backTop &&
          breadcrumb == other.breadcrumb &&
          navigation == other.navigation &&
          pagination == other.pagination &&
          tree == other.tree &&
          treeSelect == other.treeSelect &&
          cascader == other.cascader &&
          form == other.form &&
          steps == other.steps &&
          upload == other.upload &&
          skeleton == other.skeleton &&
          tabs == other.tabs &&
          chromeTab == other.chromeTab &&
          carousel == other.carousel &&
          modal == other.modal &&
          popover == other.popover &&
          popconfirm == other.popconfirm &&
          banner == other.banner &&
          notification == other.notification &&
          badge == other.badge &&
          avatar == other.avatar &&
          cropper == other.cropper &&
          sideSheet == other.sideSheet &&
          scrollList == other.scrollList &&
          scrollBar == other.scrollBar &&
          floatButton == other.floatButton &&
          image == other.image &&
          toast == other.toast &&
          feedback == other.feedback &&
          userGuide == other.userGuide;
  @override
  int get hashCode => Object.hashAll([
    tag,
    typography,
    divider,
    spin,
    progress,
    highlight,
    empty,
    timeline,
    descriptions,
    tooltip,
    collapse,
    collapsible,
    dropdown,
    contextMenu,
    button,
    card,
    checkbox,
    input,
    inputNumber,
    pinCode,
    autocomplete,
    radio,
    rating,
    select,
    slider,
    switcher,
    tagInput,
    datePicker,
    colorPicker,
    timePicker,
    transfer,
    anchor,
    backTop,
    breadcrumb,
    navigation,
    pagination,
    tree,
    treeSelect,
    cascader,
    form,
    steps,
    upload,
    skeleton,
    tabs,
    chromeTab,
    carousel,
    modal,
    popover,
    popconfirm,
    banner,
    notification,
    badge,
    avatar,
    cropper,
    sideSheet,
    scrollList,
    scrollBar,
    floatButton,
    image,
    toast,
    feedback,
    userGuide,
  ]);
}
