import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/browser/fastDomNode.dart'
    show DomElement, DomTokenList, FastDomNode;
import '../lib/src/monaco/base/common/event.dart' show Event;
import '../lib/src/monaco/editor/browser/controller/editContext/editContext.dart'
    show AbstractEditContext;
import '../lib/src/monaco/editor/browser/view/renderingContext.dart'
    show RenderingContext, RestrictedRenderingContext;
import '../lib/src/monaco/editor/common/core/position.dart' show Position;
import '../lib/src/monaco/editor/common/viewEventHandler.dart'
    show ViewEventHandler;
import '../lib/src/monaco/editor/common/viewModel/viewContext.dart'
    show
        IEditorConfigurationForViewContext,
        IViewModelForViewContext,
        IViewLayoutForViewContext,
        ViewContext;
import '../lib/src/monaco/platform/theme/common/themeService.dart'
    show IColorTheme;

class _VM implements IViewModelForViewContext {
  int added = 0;
  int removed = 0;
  ViewEventHandler? handler;

  @override
  IViewLayoutForViewContext get viewLayout => _Layout();

  @override
  void addViewEventHandler(ViewEventHandler eventHandler) {
    added++;
    handler = eventHandler;
  }

  @override
  void removeViewEventHandler(ViewEventHandler eventHandler) {
    removed++;
  }
}

class _Layout implements IViewLayoutForViewContext {}

class _Conf implements IEditorConfigurationForViewContext {}

class _Theme implements IColorTheme {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _El implements DomElement {
  @override
  final Map<String, String> style = <String, String>{};

  @override
  String className = '';

  @override
  final DomTokenList classList = _Tokens();

  @override
  void focus() {}

  @override
  void setAttribute(String name, String value) {}

  @override
  void removeAttribute(String name) {}

  @override
  void appendChild(DomElement child) {}

  @override
  void removeChild(DomElement child) {}
}

class _Tokens implements DomTokenList {
  @override
  void toggle(String token, [bool? force]) {}
}

class _Impl extends AbstractEditContext {
  _Impl(super.context);

  final List<String> calls = <String>[];

  @override
  FastDomNode<DomElement> get domNode => FastDomNode<DomElement>(_El());

  @override
  void focus() => calls.add('focus');

  @override
  bool isFocused() => false;

  @override
  void refreshFocusState() => calls.add('refresh');

  @override
  void setAriaOptions(Object options) {
    calls.add('aria:${(options as Map<String, Object?>)['ariaLabel'] ?? ''}');
  }

  @override
  Position? getLastRenderData() => null;

  @override
  void writeScreenReaderContent(String reason) => calls.add('sr:$reason');

  @override
  void prepareRender(RenderingContext ctx) {}

  @override
  void render(RestrictedRenderingContext ctx) {}
}

void main() {
  test(
    'AbstractEditContext wires streams, registers and forwards abstracts',
    () {
      final vm = _VM();
      final context = ViewContext(_Conf(), _Theme(), vm);
      final impl = _Impl(context);

      expect(vm.added, 1);

      final List<String> log = <String>[];
      final subscriptions = <Object>[
        impl.onWillCopy((Object e) => log.add('copy:${(e as Map)['type']}')),
        impl.onWillCut((Object e) => log.add('cut:${(e as Map)['type']}')),
        impl.onWillPaste((Object e) => log.add('paste:${(e as Map)['type']}')),
      ];
      expect(subscriptions.length, 3);
      expect(impl.onWillCopy, isA<Event<Object>>());
      expect(identical(impl.onWillCopy, impl.onWillCut), isFalse);
      expect(identical(impl.onWillCut, impl.onWillPaste), isFalse);

      impl.focus();
      impl.refreshFocusState();
      impl.setAriaOptions(<String, Object?>{'ariaLabel': 'label'});
      impl.writeScreenReaderContent('reason');

      expect(impl.calls, <String>[
        'focus',
        'refresh',
        'aria:label',
        'sr:reason',
      ]);
      expect(impl.getLastRenderData(), isNull);
      expect(impl.isFocused(), isFalse);

      impl.dispose();
      expect(vm.removed, 1);
    },
  );
}
