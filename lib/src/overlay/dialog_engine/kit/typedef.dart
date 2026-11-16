import 'dart:async';

import 'package:flutter/widgets.dart';

import '../data/attach_model.dart';

typedef FutureVoidCallback = Future<void> Function();

typedef SmartOnBack = FutureOr<bool> Function();

typedef HighlightBuilder = Positioned Function(
  Offset targetOffset,
  Size targetSize,
);

typedef TargetBuilder = Offset Function(Offset targetOffset, Size targetSize);

typedef AdjustBuilder = AttachAdjustParam Function(AttachParam attachParam);

typedef ScalePointBuilder = Offset Function(Size selfSize);

/// Upstream init_dialog.dart typedefs (the Material-era `FlutterSmartStyleBuilder`
/// is dropped in the vendoring — no Material wrapper in this engine).
typedef FlutterSmartToastBuilder = Widget Function(String msg);

typedef FlutterSmartLoadingBuilder = Widget Function(String msg);
