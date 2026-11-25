// 1:1 port of
// vscode/src/vs/editor/browser/view/viewPart.ts
// @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
//
// Adaptations:
//   - `ViewPart` keeps `abstract` (prepareRender / render are abstract in the
//     source).
//   - `Element | FastDomNode<HTMLElement>` is bridged structurally: both
//     expose `setAttribute`/`getAttribute`, so `write`/`read` use that surface.
//   - `parseInt(r, 10)` is JS semantics (leading whitespace/sign/digits); a
//     non-numeric attribute yields `NaN` in JS, which the editor never
//     produces, so this port returns 0 for that case.
//   - `Uint8Array` -> `Uint8List` from `dart:typed_data`.

import 'dart:typed_data' show Uint8List;

import '../../common/viewEventHandler.dart' show ViewEventHandler;
import '../../common/viewLayout/viewLinesViewportData.dart' show ViewportData;
import '../../common/viewModel/viewContext.dart' show ViewContext;
import 'renderingContext.dart'
    show RenderingContext, RestrictedRenderingContext;

/// 1:1: `export abstract class ViewPart extends ViewEventHandler`.
abstract class ViewPart extends ViewEventHandler {
  ViewPart(ViewContext context) {
    _context = context;
    _context.addEventHandler(this);
  }

  late final ViewContext _context;

  @override
  void dispose() {
    _context.removeEventHandler(this);
    super.dispose();
  }

  void onBeforeRender(ViewportData viewportData) {}

  void prepareRender(RenderingContext ctx);

  void render(RestrictedRenderingContext ctx);
}

/// 1:1: `export const enum PartFingerprint`.
class PartFingerprint {
  static const int None = 0;
  static const int ContentWidgets = 1;
  static const int OverflowingContentWidgets = 2;
  static const int OverflowGuard = 3;
  static const int OverlayWidgets = 4;
  static const int OverflowingOverlayWidgets = 5;
  static const int ScrollableElement = 6;
  static const int TextArea = 7;
  static const int ViewLines = 8;
  static const int Minimap = 9;
  static const int ViewLinesGpu = 10;

  const PartFingerprint._();
}

final RegExp _leadingInt = RegExp(r'^\s*([+-]?\d+)');

/// JS `parseInt(value, 10)` for the attribute strings the editor writes.
int _jsParseInt(String value) {
  final RegExpMatch? match = _leadingInt.firstMatch(value);
  if (match == null) {
    // JS would return NaN here; no editor part ever writes a non-numeric id.
    return 0;
  }
  return int.tryParse(match.group(1)!) ?? 0;
}

/// 1:1: `export class PartFingerprints`.
class PartFingerprints {
  static const String _attribute = 'data-mprt';

  static void write(Object target, int partId) {
    (target as dynamic).setAttribute(_attribute, '$partId');
  }

  static int read(Object target) {
    final Object? r = (target as dynamic).getAttribute(_attribute);
    if (r == null) {
      return PartFingerprint.None;
    }
    return _jsParseInt(r as String);
  }

  static Uint8List collect(Object? child, Object stopAt) {
    final List<int> result = <int>[];
    int resultLen = 0;

    while (child != null) {
      final dynamic current = child;
      if (identical(current, current.ownerDocument.body)) {
        break;
      }
      if (identical(current, stopAt)) {
        break;
      }
      if (current.nodeType == current.ELEMENT_NODE) {
        result.add(read(current));
        resultLen++;
      }
      child = current.parentElement as Object?;
    }

    final Uint8List r = Uint8List(resultLen);
    for (int i = 0; i < resultLen; i++) {
      r[i] = result[resultLen - i - 1];
    }
    return r;
  }
}
