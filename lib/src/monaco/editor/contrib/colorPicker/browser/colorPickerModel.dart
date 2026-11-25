// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/colorPicker/browser/colorPickerModel.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// TS `IColorPresentation` is an erased interface; only `label` is read by this
// class, so a minimal carrier is kept here for Dart type-checking + replay.
// ---------------------------------------------------------------------------

import '../../../../base/common/color.dart';
import '../../../../base/common/event.dart';
import '../../../../base/common/lifecycle.dart';

/// Minimal carrier for the erased TS `IColorPresentation` (only `label` is
/// read by ColorPickerModel).
class IColorPresentation {
  final String label;
  IColorPresentation(this.label);
}

/// 1:1: `export class ColorPickerModel extends Disposable`
class ColorPickerModel extends Disposable {
  final Color originalColor;
  Color _color;

  /// 1:1: `get color(): Color`
  Color get color => _color;

  /// 1:1: `set color(color: Color)`
  set color(Color color) {
    if (_color.equals(color)) {
      return;
    }
    _color = color;
    _onDidChangeColor.fire(color);
  }

  /// 1:1: `get presentation(): IColorPresentation`
  IColorPresentation get presentation => colorPresentations[presentationIndex];

  List<IColorPresentation> _colorPresentations;

  /// 1:1: `get colorPresentations(): IColorPresentation[]`
  List<IColorPresentation> get colorPresentations => _colorPresentations;

  /// 1:1: `set colorPresentations(...)`
  set colorPresentations(List<IColorPresentation> colorPresentations) {
    _colorPresentations = colorPresentations;
    if (presentationIndex > colorPresentations.length - 1) {
      presentationIndex = 0;
    }
    _onDidChangePresentation.fire(presentation);
  }

  late final Emitter<Color> _onColorFlushed;
  late final Event<Color> onColorFlushed;
  late final Emitter<Color> _onDidChangeColor;
  late final Event<Color> onDidChangeColor;
  late final Emitter<IColorPresentation> _onDidChangePresentation;
  late final Event<IColorPresentation> onDidChangePresentation;

  /// 1:1: TS `private presentationIndex` constructor parameter property.
  /// Kept package-visible so replay can read the current index.
  int presentationIndex;

  ColorPickerModel(Color color,
      List<IColorPresentation> availableColorPresentations, this.presentationIndex)
      : originalColor = color,
        _color = color,
        _colorPresentations = availableColorPresentations {
    _onColorFlushed = register(Emitter<Color>());
    onColorFlushed = _onColorFlushed.event;
    _onDidChangeColor = register(Emitter<Color>());
    onDidChangeColor = _onDidChangeColor.event;
    _onDidChangePresentation = register(Emitter<IColorPresentation>());
    onDidChangePresentation = _onDidChangePresentation.event;
  }

  /// 1:1: `selectNextColorPresentation()`
  void selectNextColorPresentation() {
    presentationIndex = (presentationIndex + 1) % colorPresentations.length;
    flushColor();
    _onDidChangePresentation.fire(presentation);
  }

  /// 1:1: `guessColorPresentation(color, originalText)`
  void guessColorPresentation(Color color, String originalText) {
    int idx = -1;
    for (int i = 0; i < colorPresentations.length; i++) {
      if (originalText.toLowerCase() == colorPresentations[i].label) {
        idx = i;
        break;
      }
    }
    if (idx == -1) {
      final String originalTextPrefix = originalText.split('(')[0].toLowerCase();
      for (int i = 0; i < colorPresentations.length; i++) {
        if (colorPresentations[i].label.toLowerCase().startsWith(originalTextPrefix)) {
          idx = i;
          break;
        }
      }
    }
    if (idx != -1 && idx != presentationIndex) {
      presentationIndex = idx;
      _onDidChangePresentation.fire(presentation);
    }
  }

  /// 1:1: `flushColor()`
  void flushColor() {
    _onColorFlushed.fire(_color);
  }
}
