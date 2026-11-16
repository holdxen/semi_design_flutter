import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../helper/dialog_proxy.dart';

class ViewUtils {
  static void addSafeUse(VoidCallback callback) {
    var schedulerPhase = schedulerBinding.schedulerPhase;
    if (schedulerPhase == SchedulerPhase.persistentCallbacks) {
      widgetsBinding.addPostFrameCallback((timeStamp) => callback());
    } else {
      callback();
    }
  }

  static Future<void> awaitSafeUse({VoidCallback? onPostFrame}) async {
    final completer = Completer<void>();
    var schedulerPhase = schedulerBinding.schedulerPhase;
    if (schedulerPhase == SchedulerPhase.persistentCallbacks) {
      widgetsBinding.addPostFrameCallback((timeStamp) {
        onPostFrame?.call();
        if (!completer.isCompleted) completer.complete();
      });
    } else {
      onPostFrame?.call();
      if (!completer.isCompleted) completer.complete();
    }

    await completer.future;
  }

  static Future<void> awaitPostFrame({VoidCallback? onPostFrame}) async {
    final completer = Completer<void>();
    widgetsBinding.addPostFrameCallback((timeStamp) {
      onPostFrame?.call();
      if (!completer.isCompleted) completer.complete();
    });
    await completer.future;
  }

  static bool isDarkModel() {
    if (DialogProxy.contextNavigator == null) {
      return false;
    }

    var brightness = MediaQuery.platformBrightnessOf(
      DialogProxy.contextNavigator!,
    );
    return brightness == Brightness.dark;
  }

  static RenderBox? findRenderBox(BuildContext? context) {
    if (context == null) return null;
    try {
      final renderObject = context.findRenderObject();
      if (renderObject is RenderBox &&
          renderObject.attached &&
          renderObject.hasSize) {
        return renderObject;
      }
    } catch (_) {}
    return null;
  }

  static void insertOverlayEntry(OverlayEntry entry, {OverlayEntry? below}) {
    final overlayState = DialogProxy.instance.overlay;
    try {
      overlayState.insert(entry, below: below);
    } catch (_) {
      overlayState.insert(entry);
    }
  }
}

WidgetsBinding get widgetsBinding => WidgetsBinding.instance;

SchedulerBinding get schedulerBinding => SchedulerBinding.instance;

OverlayState overlay(BuildContext context) => Overlay.of(context);
