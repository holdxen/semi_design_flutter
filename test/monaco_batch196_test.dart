// Truth replay for batch196:
//   platform/quickinput/browser/pickerQuickAccess.ts
//
// Expectations come from `tool/ts2dart/batch196_truth.json`, produced by
// `tool/ts2dart/_batch196_truth.cjs` (real transpiled TypeScript + the real
// async/cancellation/lifecycle/types/event modules). The picker itself is a
// deterministic fake whose events are real Emitters, so every state transition
// is observable.
//
// NOTE: `pickerQuickAccess.ts` has no official test of its own; truth comes
// from executing the real source.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/cancellation.dart'
    show CancellationToken, CancellationTokenSource;
import '../lib/src/monaco/base/common/event.dart' as event;
import '../lib/src/monaco/platform/quickinput/browser/pickerQuickAccess.dart'
    as pickerAccess;
import '../lib/src/monaco/platform/quickinput/common/quickAccess.dart'
    as quickAccess;
import '../lib/src/monaco/platform/quickinput/common/quickInput.dart'
    as quickInput;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

List<dynamic> _list(dynamic value) => value as List<dynamic>;

Matcher _exp(dynamic value) => value == null ? isNull : equals(value);

Map<String, dynamic> _truth() =>
    _map(jsonDecode(File('tool/ts2dart/batch196_truth.json').readAsStringSync()));

/// `IQuickPick` fake: only the members the provider touches are explicit, the
/// rest live in a property map through `noSuchMethod` (the TS picker is a
/// plain mutable object).
class _FakePicker implements quickInput.IQuickPick<quickInput.IQuickPickItem> {
  final Map<String, Object?> props = <String, Object?>{};

  final event.Emitter<String> _onDidChangeValue = event.Emitter<String>();
  final event.Emitter<quickInput.IQuickPickDidAcceptEvent> _onDidAccept =
      event.Emitter<quickInput.IQuickPickDidAcceptEvent>();
  final event.Emitter<quickInput.IQuickPickItemButtonEvent<quickInput.IQuickPickItem>>
      _onDidTriggerItemButton =
      event.Emitter<quickInput.IQuickPickItemButtonEvent<quickInput.IQuickPickItem>>();
  final event.Emitter<quickInput.IQuickPickSeparatorButtonEvent>
      _onDidTriggerSeparatorButton =
      event.Emitter<quickInput.IQuickPickSeparatorButtonEvent>();

  int hides = 0;

  @override
  event.Event<String> get onDidChangeValue => _onDidChangeValue.event;
  @override
  event.Event<quickInput.IQuickPickDidAcceptEvent> get onDidAccept =>
      _onDidAccept.event;
  @override
  event.Event<quickInput.IQuickPickItemButtonEvent<quickInput.IQuickPickItem>>
      get onDidTriggerItemButton => _onDidTriggerItemButton.event;
  @override
  event.Event<quickInput.IQuickPickSeparatorButtonEvent>
      get onDidTriggerSeparatorButton => _onDidTriggerSeparatorButton.event;

  @override
  void hide() => hides++;

  void fireChangeValue() => _onDidChangeValue.fire('');
  void fireAccept(bool inBackground) =>
      _onDidAccept.fire(quickInput.IQuickPickDidAcceptEvent(
          inBackground: inBackground));
  void fireItemButton(
          quickInput.IQuickInputButton button, quickInput.IQuickPickItem item) =>
      _onDidTriggerItemButton.fire(
          quickInput.IQuickPickItemButtonEvent<quickInput.IQuickPickItem>(
              button: button, item: item));
  void fireSeparatorButton(quickInput.IQuickInputButton button,
          quickInput.IQuickPickSeparator separator) =>
      _onDidTriggerSeparatorButton
          .fire(quickInput.IQuickPickSeparatorButtonEvent(
              button: button, separator: separator));

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final String name = _name(invocation);
    if (invocation.isGetter) {
      return props[name];
    }
    if (invocation.isSetter) {
      props[name] = invocation.positionalArguments.isEmpty
          ? null
          : invocation.positionalArguments.first;
      return null;
    }
    return null;
  }

  static String _name(Invocation invocation) {
    final String raw = invocation.memberName.toString();
    final int start = raw.indexOf('"') + 1;
    final int end = raw.lastIndexOf('"');
    return raw.substring(start, end).replaceAll('=', '');
  }

  // Carrier `IQuickPick.items` is `List<Object>` (T or separators).
  List<Object> get items =>
      (props['items'] as List<Object>?) ?? <Object>[];
  set items(List<Object> value) => props['items'] = value;
  List<quickInput.IQuickPickItem> get activeItems =>
      (props['activeItems'] as List<quickInput.IQuickPickItem>?) ??
      <quickInput.IQuickPickItem>[];
  set activeItems(List<quickInput.IQuickPickItem> value) =>
      props['activeItems'] = value;
  String get value => (props['value'] as String?) ?? '';
  set value(String v) => props['value'] = v;
  bool get busy => (props['busy'] as bool?) ?? false;
  set busy(bool v) => props['busy'] = v;
  bool get hideInput => (props['hideInput'] as bool?) ?? false;
  set hideInput(bool v) => props['hideInput'] = v;
  bool get keepScrollPosition =>
      (props['keepScrollPosition'] as bool?) ?? false;
  set keepScrollPosition(bool v) => props['keepScrollPosition'] = v;
  quickInput.IKeyMods get keyMods =>
      (props['keyMods'] as quickInput.IKeyMods?) ?? quickInput.NO_KEY_MODS;
  set keyMods(quickInput.IKeyMods v) => props['keyMods'] = v;
  List<quickInput.IQuickPickItem> get selectedItems =>
      (props['selectedItems'] as List<quickInput.IQuickPickItem>?) ??
      <quickInput.IQuickPickItem>[];
  set selectedItems(List<quickInput.IQuickPickItem> v) =>
      props['selectedItems'] = v;
}

class _Provider extends pickerAccess.PickerQuickAccessProvider {
  _Provider(
    String prefix,
    pickerAccess.IPickerQuickAccessProviderOptions? options,
    this.shape,
    this.requested,
  ) : super(prefix, options);

  final Object? Function(String filter) shape;
  final List<String> requested;

  @override
  Object? getPicks(
    String filter,
    dynamic disposables,
    CancellationToken token, [
    quickAccess.IQuickAccessProviderRunOptions? runOptions,
  ]) {
    requested.add(filter);
    return shape(filter);
  }
}

List<String> _labels(List<Object?> items) => items
    .map((Object? item) => (item is quickInput.IQuickPickItem)
        ? item.label
        : (item is quickInput.IQuickPickSeparator ? 'sep' : '?'))
    .toList();

void main() {
  final Map<String, dynamic> truth = _truth();

  test('batch196 provide() applies options, filter and sync picks', () async {
    final Map<String, dynamic> expected = _map(truth['provide']);
    final _FakePicker picker = _FakePicker();
    picker.value = 'pfx  my filter ';
    final List<String> requested = <String>[];
    final _Provider provider = _Provider(
      'pfx',
      pickerAccess.IPickerQuickAccessProviderOptions(
          canAcceptInBackground: true),
      (String filter) => <Object>[
        quickInput.IQuickPickItem(label: 'one'),
        quickInput.IQuickPickSeparator(),
        quickInput.IQuickPickItem(label: 'two'),
      ],
      requested,
    );

    final Object store = provider.provide(picker, CancellationTokenSource().token);
    await Future<void>.delayed(Duration.zero);

    expect(picker.props['canAcceptInBackground'], isTrue);
    expect(picker.props['matchOnLabel'], isFalse);
    expect(picker.props['matchOnDescription'], isFalse);
    expect(picker.props['matchOnDetail'], isFalse);
    expect(picker.props['sortByLabel'], isFalse);
    expect(requested, _exp(<String>['my filter']));
    expect(_labels(picker.items), _exp(_list(expected['items'])));
    expect(picker.busy, isFalse);

    // skipTrim keeps the leading/trailing spaces.
    final Map<String, dynamic> skipTrim = _map(truth['skipTrim']);
    final _FakePicker picker2 = _FakePicker();
    picker2.value = 'pfx  keep ';
    final List<String> requested2 = <String>[];
    final _Provider provider2 = _Provider(
      'pfx',
      pickerAccess.IPickerQuickAccessProviderOptions(
          shouldSkipTrimPickFilter: true),
      (String filter) => <Object>[],
      requested2,
    );
    final Object store2 =
        provider2.provide(picker2, CancellationTokenSource().token);
    await Future<void>.delayed(Duration.zero);
    expect(requested2, _exp(_list(skipTrim['requested'])));
    (store2 as dynamic).dispose();
    (store as dynamic).dispose();
  });

  test('batch196 picks with active / no results match truth', () async {
    final Map<String, dynamic> expected = _map(truth['picks']);

    Future<Map<String, Object?>> runCase(
      Object? Function(String filter) shape,
      String value,
      Map<String, dynamic> optionsMap,
    ) async {
      final _FakePicker picker = _FakePicker();
      picker.value = value;
      final List<String> requested = <String>[];
      final pickerAccess.IPickerQuickAccessProviderOptions options =
          pickerAccess.IPickerQuickAccessProviderOptions(
        noResultsPick: optionsMap['noResultsPick'],
      );
      final _Provider provider =
          _Provider('pfx', options, shape, requested);
      final Object store =
          provider.provide(picker, CancellationTokenSource().token);
      await Future<void>.delayed(Duration.zero);
      final Map<String, Object?> snapshot = <String, Object?>{
        'items': _labels(picker.items),
        'active': picker.activeItems
            .map((quickInput.IQuickPickItem i) => i.label)
            .toList(),
      };
      (store as dynamic).dispose();
      return snapshot;
    }

    final Map<String, dynamic> withActive = _map(expected['withActive']);
    expect(
      await runCase(
        (String filter) => pickerAccess.PicksWithActive<quickInput.IQuickPickItem>(
          items: <Object>[
            quickInput.IQuickPickItem(label: 'a'),
            quickInput.IQuickPickItem(label: 'b'),
          ],
          active: quickInput.IQuickPickItem(label: 'b'),
        ),
        'pfx x',
        <String, dynamic>{},
      ),
      <String, Object?>{
        'items': _exp(withActive['items']),
        'active': _exp(withActive['active']),
      },
    );

    final Map<String, dynamic> emptyWithFilter =
        _map(expected['emptyWithFilterAndNoResults']);
    expect(
      await runCase(
        (String filter) => <Object>[],
        'pfx x',
        <String, dynamic>{},
      ),
      <String, Object?>{
        'items': _exp(emptyWithFilter['items']),
        'active': _exp(emptyWithFilter['active']),
      },
    );

    // Empty picks + hideInput → the no-results entry appears.
    final Map<String, dynamic> emptyHideInput =
        _map(expected['emptyWithHideInput']);
    final _FakePicker hideInputPicker = _FakePicker();
    hideInputPicker.value = 'pfx';
    hideInputPicker.hideInput = true;
    final List<String> requested = <String>[];
    final _Provider provider = _Provider(
      'pfx',
      pickerAccess.IPickerQuickAccessProviderOptions(
          noResultsPick: quickInput.IQuickPickItem(label: 'nothing')),
      (String filter) => <Object>[],
      requested,
    );
    final Object store =
        provider.provide(hideInputPicker, CancellationTokenSource().token);
    await Future<void>.delayed(Duration.zero);
    expect(_labels(hideInputPicker.items), _exp(emptyHideInput['items']));
    (store as dynamic).dispose();
  });

  test('batch196 slow picks, busy state and cancellation match truth', () async {
    final Map<String, dynamic> expected = _map(truth['promisePicks']);
    final _FakePicker picker = _FakePicker();
    picker.value = 'pfx slow';
    final List<bool> busyLog = <bool>[];
    final _Provider provider = _Provider(
      'pfx',
      null,
      (String filter) => Future<Object>.value(
          <Object>[quickInput.IQuickPickItem(label: 'slow-one')]),
      <String>[],
    );
    final Object store =
        provider.provide(picker, CancellationTokenSource().token);
    busyLog.add(picker.busy);
    await Future<void>.delayed(Duration.zero);
    busyLog.add(picker.busy);
    expect(busyLog, _exp(expected['busyLog']));
    expect(_labels(picker.items), _exp(expected['items']));
    (store as dynamic).dispose();

    // Cancelling before the slow picks resolve leaves `busy` stuck true (the
    // source's `finally` skips resetting on cancellation).
    final Map<String, dynamic> hints = _map(expected['hints']);
    final CancellationTokenSource cts = CancellationTokenSource();
    final _FakePicker picker2 = _FakePicker();
    picker2.value = 'pfx x';
    bool resolved = false;
    final _Provider provider2 = _Provider(
      'pfx',
      null,
      (String filter) => Future<Object>.delayed(const Duration(milliseconds: 5),
          () {
        resolved = true;
        return <Object>[quickInput.IQuickPickItem(label: 'late')];
      }),
      <String>[],
    );
    final Object store2 = provider2.provide(picker2, cts.token);
    cts.cancel();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(resolved, hints['resolved']);
    expect(_labels(picker2.items), _exp(hints['items']));
    expect(picker2.busy, hints['busy']);
    (store2 as dynamic).dispose();
  });

  test('batch196 fast and slow picks match truth', () async {
    final Map<String, dynamic> expected = _map(truth['fastAndSlow']);

    Future<List<Map<String, Object?>>> runCase(int? mergeDelay) async {
      final _FakePicker picker = _FakePicker();
      picker.value = 'pfx';
      final _Provider provider = _Provider(
        'pfx',
        null,
        (String filter) => pickerAccess.FastAndSlowPicks(
          picks: <Object>[quickInput.IQuickPickItem(label: 'fast')],
          additionalPicks: Future<Object>.value(
              <Object>[quickInput.IQuickPickItem(label: 'slow')]),
          mergeDelay: mergeDelay,
        ),
        <String>[],
      );
      final Object store =
          provider.provide(picker, CancellationTokenSource().token);
      final List<Map<String, Object?>> snapshots = <Map<String, Object?>>[];
      snapshots.add(<String, Object?>{
        'at': 'sync',
        'items': _labels(picker.items),
        'busy': picker.busy,
      });
      await Future<void>.delayed(
          Duration(milliseconds: (mergeDelay ?? 0) + 10));
      snapshots.add(<String, Object?>{
        'at': 'after',
        'items': _labels(picker.items),
        'busy': picker.busy,
      });
      (store as dynamic).dispose();
      return snapshots;
    }

    expect(await runCase(null), _exp(expected['withoutDelay']));
    expect(await runCase(5), _exp(expected['withDelay']));
  });

  test('batch196 accept handling matches truth', () async {
    final Map<String, dynamic> expected = _map(truth['accept']);
    final List<List<Object?>> accepted = <List<Object?>>[];
    final _FakePicker picker = _FakePicker();
    picker.value = 'pfx';
    final _Provider provider = _Provider(
      'pfx',
      null,
      (String filter) => <Object>[
        pickerAccess.IPickerQuickAccessItem(
          label: 'item',
          accept: (quickInput.IKeyMods keyMods,
                  quickInput.IQuickPickDidAcceptEvent event) =>
              accepted.add(<Object?>[
                'accept',
                keyMods.ctrlCmd,
                event.inBackground
              ]),
          attach: (quickInput.IKeyMods keyMods,
                  quickInput.IQuickPickDidAcceptEvent event) =>
              accepted.add(<Object?>[
                'attach',
                keyMods.ctrlCmd,
                event.inBackground
              ]),
        ),
      ],
      <String>[],
    );
    final Object store =
        provider.provide(picker, CancellationTokenSource().token);
    await Future<void>.delayed(Duration.zero);
    picker.selectedItems = picker.items.cast<quickInput.IQuickPickItem>();

    picker.fireAccept(false);
    final Map<String, dynamic> afterPlainAccept =
        _map(expected['afterPlainAccept']);
    expect(accepted, _exp(afterPlainAccept['accepted']));
    expect(picker.hides, afterPlainAccept['hides']);

    picker.keyMods = const quickInput.IKeyMods(
        ctrlCmd: true, alt: false, shift: false);
    picker.fireAccept(false);
    final Map<String, dynamic> afterAttach = _map(expected['afterAttach']);
    expect(accepted, _exp(afterAttach['accepted']));
    expect(picker.hides, afterAttach['hides']);

    picker.fireAccept(true);
    final Map<String, dynamic> afterBackground =
        _map(expected['afterBackground']);
    expect(accepted, _exp(afterBackground['accepted']));
    expect(picker.hides, afterBackground['hides']);
    (store as dynamic).dispose();

    // `handleAccept` wins over `accept` and only hides when not in background.
    final Map<String, dynamic> handleAccept = _map(truth['handleAccept']);
    final List<List<Object?>> handled = <List<Object?>>[];
    final _FakePicker picker2 = _FakePicker();
    picker2.value = 'pfx';
    final _Provider provider2 = _Provider(
      'pfx',
      null,
      (String filter) => <Object>[quickInput.IQuickPickItem(label: 'a')],
      <String>[],
    );
    final Object store2 = provider2.provide(
      picker2,
      CancellationTokenSource().token,
      quickAccess.IQuickAccessProviderRunOptions(
        handleAccept: (quickInput.IQuickPickItem? item, bool inBackground) =>
            handled.add(<Object?>[item?.label, inBackground]),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    picker2.fireAccept(false);
    final Map<String, dynamic> afterForward = _map(handleAccept['afterForward']);
    expect(handled, _exp(afterForward['handled']));
    expect(picker2.hides, afterForward['hides']);
    picker2.fireAccept(true);
    final Map<String, dynamic> afterHandleBackground =
        _map(handleAccept['afterBackground']);
    expect(handled, _exp(afterHandleBackground['handled']));
    expect(picker2.hides, afterHandleBackground['hides']);
    (store2 as dynamic).dispose();
  });

  test('batch196 button trigger actions match truth', () async {
    final Map<String, dynamic> expected = _map(truth['buttonTrigger']);

    Future<Map<String, Object?>> runCase(
      int action, {
      bool promise = false,
    }) async {
      final _FakePicker picker = _FakePicker();
      picker.value = 'pfx';
      final quickInput.IQuickInputButton button =
          quickInput.IQuickInputButton(iconClass: 'b');
      final List<List<Object?>> calls = <List<Object?>>[];
      int refreshCount = 0;
      final _Provider provider = _Provider(
        'pfx',
        null,
        (String filter) {
          refreshCount++;
          return <Object>[
            pickerAccess.IPickerQuickAccessItem(
              label: 'first',
              buttons: <quickInput.IQuickInputButton>[button],
              trigger: (int index, quickInput.IKeyMods keyMods) {
                calls.add(<Object?>['trigger', index, keyMods.shift]);
                return promise ? Future<int>.value(action) : action;
              },
            ),
            quickInput.IQuickPickItem(label: 'second'),
          ];
        },
        <String>[],
      );
      final Object store =
          provider.provide(picker, CancellationTokenSource().token);
      await Future<void>.delayed(Duration.zero);
      picker.fireItemButton(
          button, picker.items[0] as quickInput.IQuickPickItem);
      await Future<void>.delayed(Duration.zero);
      final Map<String, Object?> snapshot = <String, Object?>{
        'calls': calls,
        'hides': picker.hides,
        'refreshCount': refreshCount,
        'items': _labels(picker.items),
        'active': picker.activeItems
            .map((quickInput.IQuickPickItem i) => i.label)
            .toList(),
        'keepScrollPosition': picker.keepScrollPosition,
      };
      (store as dynamic).dispose();
      return snapshot;
    }

    expect(await runCase(pickerAccess.TriggerAction.NO_ACTION),
        _exp(_map(expected['noAction'])));
    expect(await runCase(pickerAccess.TriggerAction.CLOSE_PICKER),
        _exp(_map(expected['closePicker'])));
    expect(await runCase(pickerAccess.TriggerAction.REFRESH_PICKER),
        _exp(_map(expected['refreshPicker'])));
    expect(await runCase(pickerAccess.TriggerAction.CLOSE_PICKER, promise: true),
        _exp(_map(expected['promiseAction'])));

    // REMOVE_ITEM drops the item and its active entry, restoring
    // `keepScrollPosition`.
    final Map<String, dynamic> removeItem = _map(expected['removeItem']);
    final _FakePicker removePicker = _FakePicker();
    removePicker.value = 'pfx';
    final quickInput.IQuickInputButton removeButton =
        quickInput.IQuickInputButton(iconClass: 'b');
    final _Provider removeProvider = _Provider(
      'pfx',
      null,
      (String filter) => <Object>[
        pickerAccess.IPickerQuickAccessItem(
          label: 'first',
          buttons: <quickInput.IQuickInputButton>[removeButton],
          trigger: (int index, quickInput.IKeyMods keyMods) =>
              pickerAccess.TriggerAction.REMOVE_ITEM,
        ),
        quickInput.IQuickPickItem(label: 'second'),
      ],
      <String>[],
    );
    final Object removeStore = removeProvider.provide(
        removePicker, CancellationTokenSource().token);
    await Future<void>.delayed(Duration.zero);
    removePicker.activeItems =
        removePicker.items.cast<quickInput.IQuickPickItem>();
    removePicker.fireItemButton(
        removeButton, removePicker.items[0] as quickInput.IQuickPickItem);
    await Future<void>.delayed(Duration.zero);
    expect(_labels(removePicker.items), _exp(removeItem['items']));
    expect(
        removePicker.activeItems
            .map((quickInput.IQuickPickItem i) => i.label)
            .toList(),
        _exp(removeItem['active']));
    expect(removePicker.keepScrollPosition, removeItem['keepAfter']);
    (removeStore as dynamic).dispose();

    // Unknown button does nothing.
    final Map<String, dynamic> unknownButton = _map(expected['unknownButton']);
    final _FakePicker unknownPicker = _FakePicker();
    unknownPicker.value = 'pfx';
    final List<String> unknownCalls = <String>[];
    final _Provider unknownProvider = _Provider(
      'pfx',
      null,
      (String filter) => <Object>[
        pickerAccess.IPickerQuickAccessItem(
          label: 'a',
          buttons: <quickInput.IQuickInputButton>[],
          trigger: (int index, quickInput.IKeyMods keyMods) {
            unknownCalls.add('trigger');
            return pickerAccess.TriggerAction.NO_ACTION;
          },
        ),
      ],
      <String>[],
    );
    final Object unknownStore = unknownProvider.provide(
        unknownPicker, CancellationTokenSource().token);
    await Future<void>.delayed(Duration.zero);
    unknownPicker.fireItemButton(
        quickInput.IQuickInputButton(iconClass: 'other'),
        unknownPicker.items[0] as quickInput.IQuickPickItem);
    await Future<void>.delayed(Duration.zero);
    expect(unknownCalls, _exp(unknownButton['calls']));
    expect(unknownPicker.hides, unknownButton['hides']);
    (unknownStore as dynamic).dispose();
  });

  test('batch196 TriggerAction enum values match truth', () {
    final Map<String, dynamic> expected =
        _map(_map(truth['enums'])['TriggerAction']);
    expect(pickerAccess.TriggerAction.NO_ACTION, expected['NO_ACTION']);
    expect(pickerAccess.TriggerAction.CLOSE_PICKER, expected['CLOSE_PICKER']);
    expect(pickerAccess.TriggerAction.REFRESH_PICKER, expected['REFRESH_PICKER']);
    expect(pickerAccess.TriggerAction.REMOVE_ITEM, expected['REMOVE_ITEM']);
  });
}