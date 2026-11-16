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
import 'semi_dropdown_theme_data.dart';
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
import 'semi_breadcrumb_theme_data.dart';
import 'semi_navigation_theme_data.dart';
import 'semi_pagination_theme_data.dart';
import 'semi_tree_theme_data.dart';
import 'semi_steps_theme_data.dart';
import 'semi_upload_theme_data.dart';
import 'semi_skeleton_theme_data.dart';

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
    this.dropdown = const SemiDropdownThemeData(),
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
    this.breadcrumb = const SemiBreadcrumbThemeData(),
    this.navigation = const SemiNavigationThemeData(),
    this.pagination = const SemiPaginationThemeData(),
    this.tree = const SemiTreeThemeData(),
    this.steps = const SemiStepsThemeData(),
    this.upload = const SemiUploadThemeData(),
    this.skeleton = const SemiSkeletonThemeData(),
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
  final SemiDropdownThemeData dropdown;
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
  final SemiBreadcrumbThemeData breadcrumb;
  final SemiNavigationThemeData navigation;
  final SemiPaginationThemeData pagination;
  final SemiTreeThemeData tree;
  final SemiStepsThemeData steps;
  final SemiUploadThemeData upload;
  final SemiSkeletonThemeData skeleton;
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
    SemiDropdownThemeData? dropdown,
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
    SemiBreadcrumbThemeData? breadcrumb,
    SemiNavigationThemeData? navigation,
    SemiPaginationThemeData? pagination,
    SemiTreeThemeData? tree,
    SemiStepsThemeData? steps,
    SemiUploadThemeData? upload,
    SemiSkeletonThemeData? skeleton,
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
    dropdown: dropdown ?? this.dropdown,
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
    breadcrumb: breadcrumb ?? this.breadcrumb,
    navigation: navigation ?? this.navigation,
    pagination: pagination ?? this.pagination,
    tree: tree ?? this.tree,
    steps: steps ?? this.steps,
    upload: upload ?? this.upload,
    skeleton: skeleton ?? this.skeleton,
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
          dropdown == other.dropdown &&
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
          breadcrumb == other.breadcrumb &&
          navigation == other.navigation &&
          pagination == other.pagination &&
          tree == other.tree &&
          steps == other.steps &&
          upload == other.upload &&
          skeleton == other.skeleton;
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
    dropdown,
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
    breadcrumb,
    navigation,
    pagination,
    tree,
    steps,
    upload,
    skeleton,
  ]);
}
