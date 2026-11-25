// batch315: contentHoverStatusBar.ts truth replay.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    show IDisposable, toDisposable;
import 'package:semi_design_flutter/src/monaco/editor/contrib/hover/browser/contentHoverStatusBar.dart'
    show
      EditorHoverStatusBar,
      HoverBarAction,
      HoverBarActionOptions,
      HoverBarActionRenderer,
      IHoverDelegateFactoryForHoverBar,
      IHoverServiceForHoverBar,
      IKeybindingServiceForHoverBar,
      IStatusBarKeybinding,
      IStatusBarNode,
      StatusBarDomEnvironment;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch315_truth.json').readAsStringSync())
    as Map<String, dynamic>;

class _Node implements IStatusBarNode {
  _Node(this.description);

  @override
  final String description;

  @override
  int tabIndex = -1;

  @override
  final List<IStatusBarNode> children = <IStatusBarNode>[];

  @override
  IStatusBarNode appendChild(IStatusBarNode child) {
    children.add(child);
    return child;
  }
}

class _Keybinding implements IStatusBarKeybinding {
  _Keybinding(this.label);

  final String label;

  @override
  String getLabel() => label;
}

class _Keybindings implements IKeybindingServiceForHoverBar {
  @override
  IStatusBarKeybinding? lookupKeybinding(String commandId) =>
      commandId == 'with.key' ? _Keybinding('Ctrl+K') : null;
}

class _HoverService implements IHoverServiceForHoverBar {
  final List<Object?> calls;

  _HoverService(this.calls);

  @override
  IDisposable setupManagedHover(
      Object delegate, Object container, Object label) {
    calls.add(<Object?>[
      'hover',
      (delegate as Map<String, Object?>)['kind'],
      label,
    ]);
    return toDisposable(() {});
  }
}

class _DelegateFactory implements IHoverDelegateFactoryForHoverBar {
  @override
  Object getDefaultHoverDelegate(String kind) => <String, Object?>{'kind': kind};
}

void main() {
  final Map<String, dynamic> truth = _truth();
  final List<dynamic> expected = truth['results'] as List<dynamic>;
  final List<Object?> calls = <Object?>[];

  final StatusBarDomEnvironment env = StatusBarDomEnvironment(
    createNode: (String description) => _Node(description),
    append: (IStatusBarNode parent, IStatusBarNode child) =>
        parent.appendChild(child),
  );
  final HoverBarActionRenderer renderer =
      (Object parent, HoverBarActionOptions options, String? keybindingLabel) {
    calls.add(<Object?>[
      'render',
      options.label,
      options.commandId,
      keybindingLabel,
    ]);
    return HoverBarAction(
      _Node('action'),
      options.label,
      toDisposable(() {}),
    );
  };

  test('status bar truth replay', () {
  final EditorHoverStatusBar bar = EditorHoverStatusBar(
    _Keybindings(),
    _HoverService(calls),
    _DelegateFactory(),
    renderer,
    env,
  );
  final List<Map<String, Object?>> actual = <Map<String, Object?>>[];

  void snap(String label) {
    actual.add(<String, Object?>{
      'label': label,
      'hasContent': bar.hasContent,
      'hoverDescription': bar.hoverElement.description,
      'hoverTabIndex': bar.hoverElement.tabIndex,
      'children': bar.hoverElement.children
          .map((c) => (c as _Node).description)
          .toList(),
      'actions': bar.actions
          .map((a) => a.actionRenderedLabel)
          .toList(),
      'calls': List<Object?>.from(calls),
    });
  }

  snap('constructed');
  bar.addAction(HoverBarActionOptions(
    label: 'With Key',
    iconClass: 'icon',
    commandId: 'with.key',
    run: (_) {},
  ));
  snap('add-action-with-key');
  bar.addAction(HoverBarActionOptions(
    label: 'No Key',
    commandId: 'no.key',
    run: (_) {},
  ));
  snap('add-action-no-key');
  final _Node child = _Node('custom');
  final IStatusBarNode returned = bar.append(child);
  snap('append');
  actual[actual.length - 1]['returnedSame'] = identical(returned, child);

  expect(actual, expected);
  });
}
