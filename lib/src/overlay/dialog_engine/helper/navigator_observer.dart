import 'dart:async';

import 'package:semi_design_flutter/src/overlay/dialog_engine/data/smart_tag.dart';
import 'package:semi_design_flutter/src/overlay/dialog_engine/helper/route_record.dart';
import 'package:flutter/widgets.dart';

import '../config/enum_config.dart';
import '../data/dialog_info.dart';
import '../smart_dialog.dart';
import '../kit/view_utils.dart';
import 'dialog_proxy.dart';

class SmartNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    RouteRecord.curRoute = route;
    RouteRecord.instance.push(route, previousRoute);
    navigateChange();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    RouteRecord.curRoute = newRoute;
    RouteRecord.instance.replace(newRoute: newRoute, oldRoute: oldRoute);
    _removeDialog(oldRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    RouteRecord.instance.remove(route);
    _removeDialog(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) async {
    RouteRecord.curRoute = previousRoute;
    RouteRecord.instance.pop(route, previousRoute);
    _removeDialog(route);
  }

  void navigateChange() {
    final nav = navigator;
    if (nav == null) return;
    DialogProxy.contextNavigator = nav.context;
    // Ambient binding (vendored adaptation): the engine inserts into the
    // navigator's own overlay — the same layer SemiTooltip/SemiDropdown use.
    // The initial route's didPush fires while the navigator subtree is still
    // building (its Overlay is not attached yet), so bind post-frame — the
    // same addSafeUse dance upstream used to capture the navigator context.
    ViewUtils.addSafeUse(() {
      final overlay = nav.overlay;
      if (overlay != null) {
        DialogProxy.instance.bind(overlay, navigatorContext: nav.context);
      }
    });
  }

  void _removeDialog(Route<dynamic>? route) {
    navigateChange();
    if (route == null) {
      return;
    }

    var checkDialog = SmartDialog.checkExist(
      dialogTypes: {
        SmartAllDialogType.custom,
        SmartAllDialogType.attach,
        SmartAllDialogType.loading,
      },
    );
    if (!checkDialog || route.settings.name == SmartTag.systemDialog) {
      return;
    }

    if (SmartDialog.config.loading.isExist) {
      unawaited(
        DialogProxy.instance.dismiss<void>(
          status: SmartStatus.loading,
          closeType: CloseType.route,
        ),
      );
    }

    //smart close dialog
    var removeList = <DialogInfo>[];
    for (var item in DialogProxy.instance.dialogQueue) {
      if (item.route == route && item.bindPage && item.route is! PopupRoute) {
        removeList.add(item);
      }
    }
    for (var i = removeList.length; i > 0; i--) {
      unawaited(
        DialogProxy.instance.dismiss<void>(
          status: SmartStatus.dialog,
          closeType: CloseType.route,
          tag: removeList[i - 1].tag,
        ),
      );
    }
  }
}
