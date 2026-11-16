import 'package:semi_design_flutter/src/overlay/dialog_engine/kit/view_utils.dart';
import 'package:flutter/widgets.dart';

class SmartOverlayEntry extends OverlayEntry {
  SmartOverlayEntry({
    required super.builder,
    super.opaque,
    super.maintainState,
  });

  bool _disposedByOwner = false;

  @override
  void markNeedsBuild() {
    ViewUtils.addSafeUse(() {
      if (_disposedByOwner || !mounted) {
        return;
      }
      super.markNeedsBuild();
    });
  }

  @override
  void remove() {
    if (_disposedByOwner || !mounted) {
      return;
    }
    _disposedByOwner = true;
    super.remove();
    super.dispose();
  }
}
