/// A configurable overlay dialog toolkit for custom dialogs, attached
/// popovers, loading indicators, notifications, and toast messages.
///
/// Vendored from `flutter_smart_dialog` 5.3.1 (MIT) — see PROVENANCE.md for
/// the exact adaptations (de-Material'd, ambient-overlay binding, default
/// visuals removed). This library is the substrate for the Semi Modal port;
/// it is not exported from the package's public barrel yet.
library;

/// config
export 'config/enum_config.dart';
export 'config/smart_config_attach.dart';
export 'config/smart_config_custom.dart';
export 'config/smart_config_loading.dart';
export 'config/smart_config_notify.dart';
export 'config/smart_config_toast.dart';
export 'data/animation_param.dart' show AnimationParam;

/// model
export 'data/attach_model.dart';
export 'data/notify_style.dart';

/// dialog
export 'helper/navigator_observer.dart' show SmartNavigatorObserver;
export 'kit/typedef.dart'
    show FlutterSmartToastBuilder, FlutterSmartLoadingBuilder;
export 'smart_dialog.dart';
export 'widget/helper/dialog_scope.dart' show SmartDialogController;
