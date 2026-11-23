// 1:1 port parity tests for batch 13:
//   editor/contrib/inlineCompletions/browser/view/inlineEdits/utils/towersLayout.ts
//   editor/browser/viewParts/minimap/minimapCharSheet.ts
//   editor/browser/config/tabFocus.ts
//   platform/notification/common/notificationMessage.ts
//   editor/browser/widget/multiDiffEditor/utils.ts
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/contrib/inlineCompletions/browser/view/inlineEdits/utils/towersLayout.dart'
    as towers;
import 'package:semi_design_flutter/src/monaco/editor/browser/viewParts/minimap/minimapCharSheet.dart'
    as sheet;
import 'package:semi_design_flutter/src/monaco/editor/browser/config/tabFocus.dart'
    as tab;
import 'package:semi_design_flutter/src/monaco/platform/notification/common/notificationMessage.dart'
    as nm;
import 'package:semi_design_flutter/src/monaco/editor/browser/widget/multiDiffEditor/utils.dart'
    as mdu;
import 'package:semi_design_flutter/src/monaco/editor/common/core/2d/size.dart'
    as size;
import 'package:semi_design_flutter/src/monaco/editor/common/core/ranges/offsetRange.dart'
    as range;
import 'package:semi_design_flutter/src/monaco/base/common/actions.dart'
    as actions;
import 'package:semi_design_flutter/src/monaco/base/common/linkedText.dart'
    as linked;

/// Local mirror of `stripIcons` (iconLabels.dart is not yet ported): drops
/// `$(iconId)` markers, keeping the surrounding text.
String _stripIcons(String text) => text.replaceAll(RegExp(r'\$\([^)]*\)'), '');

/// Normalize a LinkedTextNode list to a comparable form so a `Link`/ILink node
/// is compared by label/href/title (the TS tests use deepStrictEqual on the
/// object literals `{ label, href, title? }`).
List<String> _nodes(List<linked.LinkedTextNode> nodes) => nodes
    .map((linked.LinkedTextNode n) => n is String
        ? 'S:$n'
        : 'L:${(n as linked.ILink).label}|${n.href}|${n.title}')
    .toList();

void main() {
  group('towersLayout - getMaxTowerHeightInAvailableArea', () {
    test('tower fits within single available area', () {
      expect(
          towers.getMaxTowerHeightInAvailableArea(
              range.OffsetRange(5, 15), <size.Size2D>[size.Size2D(50, 30)]),
          30);
    });

    test('max height available in area', () {
      expect(
          towers.getMaxTowerHeightInAvailableArea(
              range.OffsetRange(5, 15), <size.Size2D>[size.Size2D(50, 30)]),
          30);
    });

    test('tower extends beyond available width', () {
      expect(
          towers.getMaxTowerHeightInAvailableArea(
              range.OffsetRange(0, 60), <size.Size2D>[size.Size2D(50, 30)]),
          0);
    });

    test('tower fits across multiple available areas', () {
      expect(
          towers.getMaxTowerHeightInAvailableArea(range.OffsetRange(10, 40), <
              size.Size2D>[
        size.Size2D(20, 30),
        size.Size2D(20, 25),
        size.Size2D(20, 30)
      ]),
          25);
    });

    test('min height across overlapping areas', () {
      expect(
          towers.getMaxTowerHeightInAvailableArea(range.OffsetRange(10, 40), <
              size.Size2D>[
        size.Size2D(20, 30),
        size.Size2D(20, 15),
        size.Size2D(20, 30)
      ]),
          15);
    });

    test('tower at left edge of available areas', () {
      expect(
          towers.getMaxTowerHeightInAvailableArea(
              range.OffsetRange(0, 10), <size.Size2D>[size.Size2D(50, 30)]),
          30);
    });

    test('tower at right edge of available areas', () {
      expect(
          towers.getMaxTowerHeightInAvailableArea(
              range.OffsetRange(40, 50), <size.Size2D>[size.Size2D(50, 30)]),
          30);
    });

    test('tower exactly matches available area', () {
      expect(
          towers.getMaxTowerHeightInAvailableArea(
              range.OffsetRange(0, 50), <size.Size2D>[size.Size2D(50, 30)]),
          30);
    });

    test('empty available areas', () {
      expect(
          towers.getMaxTowerHeightInAvailableArea(
              range.OffsetRange(0, 10), <size.Size2D>[]),
          0);
    });

    test('tower spans exactly two available areas', () {
      expect(
          towers.getMaxTowerHeightInAvailableArea(range.OffsetRange(10, 50), <
              size.Size2D>[
        size.Size2D(30, 25),
        size.Size2D(30, 25)
      ]),
          25);
    });

    test('tower starts at boundary between two areas', () {
      expect(
          towers.getMaxTowerHeightInAvailableArea(range.OffsetRange(30, 50), <
              size.Size2D>[
        size.Size2D(30, 25),
        size.Size2D(30, 25)
      ]),
          25);
    });

    test('tower with varying height available areas', () {
      expect(
          towers.getMaxTowerHeightInAvailableArea(range.OffsetRange(0, 50), <
              size.Size2D>[
        size.Size2D(10, 30),
        size.Size2D(10, 15),
        size.Size2D(10, 25),
        size.Size2D(10, 30),
        size.Size2D(10, 40)
      ]),
          15);
    });

    test('tower beyond all available areas to the right', () {
      expect(
          towers.getMaxTowerHeightInAvailableArea(
              range.OffsetRange(100, 110), <size.Size2D>[size.Size2D(50, 30)]),
          0);
    });
  });

  group('minimapCharSheet', () {
    test('Constants match TS values', () {
      expect(sheet.Constants.START_CH_CODE, 32);
      expect(sheet.Constants.END_CH_CODE, 126);
      expect(sheet.Constants.UNKNOWN_CODE, 65533);
      expect(sheet.Constants.CHAR_COUNT, 96);
      expect(sheet.Constants.SAMPLED_CHAR_HEIGHT, 16);
      expect(sheet.Constants.SAMPLED_CHAR_WIDTH, 10);
      expect(sheet.Constants.BASE_CHAR_HEIGHT, 2);
      expect(sheet.Constants.BASE_CHAR_WIDTH, 1);
      expect(sheet.Constants.RGBA_CHANNELS_CNT, 4);
      expect(sheet.Constants.RGBA_SAMPLED_ROW_WIDTH, 4 * 96 * 10);
    });

    test('allCharCodes is 32..126 plus unknown', () {
      expect(sheet.allCharCodes.length, 96);
      expect(sheet.allCharCodes.first, 32);
      expect(sheet.allCharCodes[94], 126);
      expect(sheet.allCharCodes.last, 65533);
    });

    test('getCharIndex in range returns offset from start', () {
      // 'a' = 97 -> 97 - 32 = 65
      expect(sheet.getCharIndex('a'.codeUnitAt(0), 1), 65);
      // '~' = 126 -> 94
      expect(sheet.getCharIndex('~'.codeUnitAt(0), 1), 94);
      // ' ' = 32 -> 0
      expect(sheet.getCharIndex(32, 1), 0);
    });

    test('getCharIndex out of range, small font scale wraps', () {
      // chCode = 0 -> -32; (-32 + 96) % 96 = 64
      expect(sheet.getCharIndex(0, 1), 64);
      expect(sheet.getCharIndex(0, 2), 64);
    });

    test('getCharIndex out of range, large font scale uses unknown symbol', () {
      // CHAR_COUNT - 1 = 95
      expect(sheet.getCharIndex(0, 3), 95);
      expect(sheet.getCharIndex(65533, 3), 95);
    });
  });

  group('tabFocus', () {
    tearDown(() => tab.TabFocus.setTabFocusMode(false));

    test('default is false', () {
      tab.TabFocus.setTabFocusMode(false);
      expect(tab.TabFocus.getTabFocusMode(), isFalse);
    });

    test('set fires event and updates mode', () {
      final List<bool> seen = <bool>[];
      tab.TabFocus.onDidChangeTabFocus((dynamic v) => seen.add(v as bool));
      tab.TabFocus.setTabFocusMode(true);
      expect(tab.TabFocus.getTabFocusMode(), isTrue);
      expect(seen, <bool>[true]);
    });
  });

  group('NotificationText', () {
    test('formats literal arguments and explicit links without interpreting markup', () {
      const String filename = 'README.md [Open](command:unexpected "Open README")';
      final nm.NotificationText link = nm.NotificationText.link(
          '[Show logs](command:unexpected)',
          'command:showLogs?%5B%22file%22%5D');
      final nm.NotificationText result = nm.NotificationText.format(
          'Failed to open {0}. {1}', <Object>[filename, link]);
      expect(_nodes(result.nodes), <String>[
        'S:Failed to open ',
        'S:$filename',
        'S:. ',
        'L:[Show logs](command:unexpected)|command:showLogs?%5B%22file%22%5D|null',
      ]);
    });

    test('formats reordered, repeated and missing placeholders', () {
      final nm.NotificationText link =
          nm.NotificationText.link('Details', 'https://example.com');
      final nm.NotificationText result = nm.NotificationText.format(
          '{1}: {0}, {1}, {2}', <Object>['{1}', link]);
      expect(_nodes(result.nodes), <String>[
        'L:Details|https://example.com|null',
        'S:: ',
        'S:{1}',
        'S:, ',
        'L:Details|https://example.com|null',
        'S:, ',
        'S:{2}',
      ]);
    });

    test('formats empty and literal templates', () {
      expect(_nodes(nm.NotificationText.format('', <Object>[]).nodes),
          <String>[]);
      expect(
          _nodes(nm.NotificationText
              .format('[Open](command:unexpected)', <Object>[]).nodes),
          <String>['S:[Open](command:unexpected)']);
    });

    test('composes rich fragments and preserves link targets when transforming display text', () {
      final nm.NotificationText message = nm.NotificationText.concat(<Object>[
        '\$(sync) Working. ',
        nm.NotificationText.link('\$(info) [Logs](command:unexpected)',
            'command:showLogs?%5B%22file%22%5D', 'Show Logs'),
      ]);
      final nm.NotificationText mapped = message.mapText(_stripIcons);
      expect(message.toString(),
          '\$(sync) Working. \$(info) [Logs](command:unexpected)');
      expect(_nodes(mapped.nodes), <String>[
        'S: Working. ',
        'L: [Logs](command:unexpected)|command:showLogs?%5B%22file%22%5D|Show Logs',
      ]);
      expect(mapped.toString(), ' Working.  [Logs](command:unexpected)');
    });

    test('link/concat/toString basics', () {
      final nm.NotificationText msg = nm.NotificationText.concat(<Object>[
        'Open ',
        nm.NotificationText.link('Details', 'command:showDetails'),
      ]);
      expect(msg.toString(), 'Open Details');
      expect(msg.nodes.length, 2);
    });
  });

  group('ActionRunnerWithContext', () {
    test('injects context from callback into runAction', () async {
      Object? captured;
      final actions.Action action = actions.Action(
        'id',
        '',
        '',
        true,
        (Object? event) async {
          captured = event;
        },
      );
      final mdu.ActionRunnerWithContext runner =
          mdu.ActionRunnerWithContext(() => 'ctx-value');
      await runner.run(action, 'ignored-context');
      expect(captured, 'ctx-value');
    });
  });
}
