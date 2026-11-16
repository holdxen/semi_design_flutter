import 'dart:async';
import 'dart:collection';

import 'package:semi_design_flutter/src/overlay/dialog_engine/custom/custom_dialog.dart';
import 'package:semi_design_flutter/src/overlay/dialog_engine/custom/custom_loading.dart';
import 'package:semi_design_flutter/src/overlay/dialog_engine/custom/custom_notify.dart';
import 'package:semi_design_flutter/src/overlay/dialog_engine/custom/toast/custom_toast.dart';
import 'package:semi_design_flutter/src/overlay/dialog_engine/data/dialog_info.dart';
import 'package:semi_design_flutter/src/overlay/dialog_engine/data/loading_info.dart';
import 'package:semi_design_flutter/src/overlay/dialog_engine/data/notify_style.dart';
import 'package:semi_design_flutter/src/overlay/dialog_engine/data/show_param.dart';
import 'package:semi_design_flutter/src/overlay/dialog_engine/widget/helper/toast_helper.dart';
import 'package:flutter/widgets.dart';

import '../config/enum_config.dart';
import '../config/smart_config.dart';
import '../data/notify_info.dart';
import '../kit/typedef.dart';
import '../kit/view_utils.dart';
import '../widget/helper/smart_overlay_entry.dart';
import 'pop_monitor/monitor_pop_route.dart';

enum CloseType {
  // back event
  back,

  // route pop
  route,

  // mask event
  mask,

  // normal dismiss
  normal,
}

enum DialogType {
  dialog,
  custom,
  attach,
  notify,
  allDialog,
  allCustom,
  allAttach,
  allNotify,
}

class DialogProxy {
  late SmartConfig config;

  /// Persistent loading carrier (upstream sat in the host overlay's
  /// initialEntries); created by [initialize] and nullable until then.
  SmartOverlayEntry? entryLoading;
  late Queue<DialogInfo> dialogQueue;
  late Queue<NotifyInfo> notifyQueue;
  late LoadingInfo loadingInfo = LoadingInfo();

  bool _loadingInitialized = false;

  static DialogProxy? _instance;

  static DialogProxy get instance => _instance ??= DialogProxy._internal();

  static BuildContext? contextNavigator;

  /// Ambient overlay the engine inserts into.
  ///
  /// Upstream hosted its own `Overlay` above the app via the app-level
  /// `FlutterSmartDialog.init()` builder; the vendored engine instead inserts
  /// into the navigator's ambient overlay (the same one SemiTooltip /
  /// SemiDropdown use), so dialogs stack with the rest of the library's
  /// popups by insertion order and no app-level init is required.
  OverlayState? _overlay;

  bool _bound = false;

  ///set default loading widget
  FlutterSmartLoadingBuilder loadingBuilder;

  ///set default toast widget
  FlutterSmartToastBuilder toastBuilder;

  ///set default toast widget
  FlutterSmartNotifyStyle notifyStyle;

  DialogProxy._internal()
    : loadingBuilder = _neutralBuilder,
      toastBuilder = _neutralBuilder,
      notifyStyle = FlutterSmartNotifyStyle(
        successBuilder: _neutralBuilder,
        failureBuilder: _neutralBuilder,
        warningBuilder: _neutralBuilder,
        alertBuilder: _neutralBuilder,
        errorBuilder: _neutralBuilder,
      ) {
    config = SmartConfig();
    dialogQueue = ListQueue();
    notifyQueue = ListQueue();
  }

  /// Neutral stand-in for the deleted upstream default visuals (Material-styled
  /// ToastWidget/LoadingWidget/Notify*); the Semi Toast/Notification ports will
  /// supply real builders later.
  static Widget _neutralBuilder(String msg) => Text(msg);

  /// The bound ambient overlay; asserts a clear message when unbound.
  OverlayState get overlay {
    final overlay = _overlay;
    assert(
      overlay != null,
      'Dialog engine is not bound to any overlay. Either use SemiApp '
      '(it installs SmartNavigatorObserver automatically) or call '
      'DialogProxy.instance.bind(...) before showing dialogs.',
    );
    return overlay!;
  }

  /// Binds the engine to the ambient [overlay] (idempotent).
  ///
  /// [navigatorContext] powers `Navigator.pop`/push system dialogs and dark
  /// detection; it is normally the navigator's own context, tracked by
  /// [SmartNavigatorObserver].
  void bind(OverlayState overlay, {BuildContext? navigatorContext}) {
    if (navigatorContext != null) {
      contextNavigator = navigatorContext;
    }
    _overlay = overlay;
    // Lazy singleton: registers the Android back-button handler (upstream
    // touched it in `FlutterSmartDialog.init()`).
    // ignore: unnecessary_statements
    MonitorPopRoute.instance;
    if (_bound) return;
    _bound = true;
    initialize(const {
      SmartInitType.custom,
      SmartInitType.attach,
      SmartInitType.loading,
      SmartInitType.toast,
      SmartInitType.notify,
    });
    // The persistent loading entry (upstream sat in the host overlay's
    // initialEntries) joins the ambient overlay lazily via addSafeUse.
    ViewUtils.addSafeUse(() {
      try {
        overlay.insert(entryLoading!);
      } catch (_) {}
    });
  }

  void initialize(Set<SmartInitType> initType) {
    if (initType.contains(SmartInitType.loading)) {
      entryLoading = SmartOverlayEntry(
        builder: (_) {
          return loadingInfo.loadingWidget.getWidget();
        },
      );
      loadingInfo.loadingWidget = CustomLoading(overlayEntry: entryLoading!);
      _loadingInitialized = true;
    }
  }

  /// Resets process-wide dialog state between widget tests.
  ///
  /// This is intentionally kept under `src` and is not part of the package's
  /// public API.
  void resetForTest() {
    for (final info in dialogQueue) {
      info.displayTimer?.cancel();
      info.dialog.mainDialog.resetForTest();
      info.dialog.overlayEntry.remove();
    }
    dialogQueue.clear();

    for (final info in notifyQueue) {
      info.displayTimer?.cancel();
      info.dialog.mainDialog.resetForTest();
      info.dialog.overlayEntry.remove();
    }
    notifyQueue.clear();

    if (_loadingInitialized) {
      loadingInfo.loadingWidget.resetForTest();
    }
    loadingInfo.backType = null;
    loadingInfo.onBack = null;

    final defaults = SmartConfig();
    config
      ..custom = defaults.custom
      ..attach = defaults.attach
      ..notify = defaults.notify
      ..loading = defaults.loading
      ..toast = defaults.toast;
    contextNavigator = null;
    _overlay = null;
    _bound = false;
    entryLoading = null;
    _loadingInitialized = false;
  }

  Future<T?> show<T>({required SmartShowCustomParam param}) {
    CustomDialog? dialog;
    var entry = SmartOverlayEntry(
      builder: (BuildContext context) => dialog!.getWidget(),
    );
    dialog = CustomDialog(overlayEntry: entry);
    return dialog.show<T>(param: param);
  }

  Future<T?> showNotify<T>({required SmartShowNotifyParam param}) {
    CustomNotify? dialog;
    var entry = SmartOverlayEntry(
      builder: (BuildContext context) => dialog!.getWidget(),
    );
    dialog = CustomNotify(overlayEntry: entry);
    return dialog.showNotify<T>(param: param);
  }

  Future<T?> showAttach<T>({required SmartShowAttachParam param}) {
    CustomDialog? dialog;
    var entry = SmartOverlayEntry(
      builder: (BuildContext context) => dialog!.getWidget(),
    );
    dialog = CustomDialog(overlayEntry: entry);
    return dialog.showAttach<T>(param: param);
  }

  Future<T?> showLoading<T>({required SmartShowLoadingParam param}) {
    loadingInfo.onBack = param.onBack;
    loadingInfo.backType = param.backType;
    return loadingInfo.loadingWidget.showLoading<T>(param: param);
  }

  Future<void> showToast({required SmartShowToastParam param}) {
    CustomToast? toast;
    var entry = SmartOverlayEntry(
      builder: (BuildContext context) => toast!.getWidget(),
    );
    toast = CustomToast(overlayEntry: entry);
    return toast.showToast(
      param: param.withWidget(
        ToastHelper(consumeEvent: param.consumeEvent, child: param.widget),
      ),
    );
  }

  Future<void>? dismiss<T>({
    required SmartStatus status,
    String? tag,
    T? result,
    bool force = false,
    CloseType closeType = CloseType.normal,
  }) {
    if (status == SmartStatus.smart) {
      var loading = config.loading.isExist;

      if (loading &&
          (tag == null || (dialogQueue.isEmpty && notifyQueue.isEmpty))) {
        return loadingInfo.loadingWidget.dismiss(closeType: closeType);
      }

      if (notifyQueue.isNotEmpty) {
        bool useNotify = (tag == null);
        if (tag != null) {
          for (var element in notifyQueue) {
            if (element.tag == tag) {
              useNotify = true;
            }
          }
        }
        if (useNotify) {
          return CustomNotify.dismiss<T>(
            type: DialogType.notify,
            tag: tag,
            result: result,
            force: force,
            closeType: closeType,
          );
        }
      }

      if (dialogQueue.isNotEmpty) {
        return CustomDialog.dismiss<T>(
          type: DialogType.dialog,
          tag: tag,
          result: result,
          force: force,
          closeType: closeType,
        );
      }
    } else if (status == SmartStatus.toast) {
      return CustomToast.dismiss();
    } else if (status == SmartStatus.allToast) {
      return CustomToast.dismiss(closeAll: true);
    } else if (status == SmartStatus.loading) {
      return loadingInfo.loadingWidget.dismiss(closeType: closeType);
    } else if (status == SmartStatus.notify ||
        status == SmartStatus.allNotify) {
      return CustomNotify.dismiss<T>(
        type: _convertEnum(status)!,
        tag: tag,
        result: result,
        force: force,
        closeType: closeType,
      );
    }

    DialogType? type = _convertEnum(status);
    if (type == null) return null;
    return CustomDialog.dismiss<T>(
      type: type,
      tag: tag,
      result: result,
      force: force,
      closeType: closeType,
    );
  }

  DialogType? _convertEnum(SmartStatus status) {
    return switch (status) {
      SmartStatus.dialog => DialogType.dialog,
      SmartStatus.custom => DialogType.custom,
      SmartStatus.attach => DialogType.attach,
      SmartStatus.notify => DialogType.notify,
      SmartStatus.allDialog => DialogType.allDialog,
      SmartStatus.allCustom => DialogType.allCustom,
      SmartStatus.allAttach => DialogType.allAttach,
      SmartStatus.allNotify => DialogType.allNotify,
      SmartStatus.smart ||
      SmartStatus.toast ||
      SmartStatus.allToast ||
      SmartStatus.loading => null,
    };
  }
}
