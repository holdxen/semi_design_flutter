// Truth-driven tests for batch139:
// base/common/themables.ts + base/common/codiconsUtil.ts
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/codiconsUtil.dart'
    as util;
import 'package:semi_design_flutter/src/monaco/base/common/themables.dart'
    as themables;

final Map<String, Object?> _truth =
    jsonDecode(File('tool/ts2dart/batch139_truth.json').readAsStringSync())
        as Map<String, Object?>;

Map<String, Object?> _obj(Object? value) =>
    (value as Map).cast<String, Object?>();

List<Object?> _list(Object? value) => (value as List).cast<Object?>();

Object? _id(Object? value) {
  if (value == null) return null;
  if (value is themables.ThemeIcon) return value.id;
  if (value is themables.ThemeColor) return value.id;
  if (value is Map) return value['id'];
  return null;
}

Object? _truthId(Object? value) => value == null ? null : _obj(value)['id'];

void main() {
  test('ThemeColor', () {
    final Map<String, Object?> e = _obj(_truth['color']);
    expect(themables.ThemeColor.isThemeColor(<String, Object?>{'id': 'x'}),
        e['isA']);
    expect(themables.ThemeColor.isThemeColor(<String, Object?>{'id': 1}),
        e['isB']);
    expect(themables.ThemeColor.isThemeColor(null), e['isC']);
    expect(_id(themables.themeColorFromId('red')), _truthId(e['fromId']));
  });

  test('ThemeIcon constants', () {
    final Map<String, Object?> e = _obj(_truth['constants']);
    expect(themables.ThemeIcon.iconNameSegment, e['segment']);
    expect(themables.ThemeIcon.iconNameExpression, e['name']);
    expect(themables.ThemeIcon.iconModifierExpression, e['modifier']);
    expect(themables.ThemeIcon.iconNameCharacter, e['character']);
  });

  test('class name helpers', () {
    final Map<String, Object?> e = _obj(_truth['classNames']);
    final themables.ThemeIcon icon = themables.ThemeIcon('check~spin');
    expect(themables.ThemeIcon.asClassNameArray(icon), _list(e['valid']));
    expect(themables.ThemeIcon.asClassName(icon), e['asClassName']);
    expect(themables.ThemeIcon.asCSSSelector(icon), e['asCSSSelector']);
    expect(themables.ThemeIcon.asClassNameArray(themables.ThemeIcon('not valid!')),
        _list(e['invalid']));
  });

  test('isThemeIcon', () {
    expect(
      <Object?>[
        themables.ThemeIcon.isThemeIcon(<String, Object?>{'id': 'x'}),
        themables.ThemeIcon.isThemeIcon(<String, Object?>{
          'id': 'x',
          'color': <String, Object?>{'id': 'red'},
        }),
        themables.ThemeIcon.isThemeIcon(<String, Object?>{'id': 'x', 'color': 1}),
        themables.ThemeIcon.isThemeIcon(null),
      ],
      _list(_truth['isThemeIcon']),
    );
  });

  test('fromString / fromId', () {
    final List<Object?> rows = _list(_truth['fromString']);
    expect(_id(themables.ThemeIcon.fromString(r'$(check)')), _truthId(rows[0]));
    expect(_id(themables.ThemeIcon.fromString(r'$(check~spin)')),
        _truthId(rows[1]));
    expect(themables.ThemeIcon.fromString('check'), rows[2]);
    expect(_id(themables.ThemeIcon.fromId('x')), _truthId(_truth['fromId']));
  });

  test('modify and getModifier', () {
    final List<Object?> modified = _list(_truth['modify']);
    expect(
      <Object?>[
        _id(themables.ThemeIcon.modify(themables.ThemeIcon('check'), 'spin')),
        _id(themables.ThemeIcon.modify(
            themables.ThemeIcon('check~spin'), 'disabled')),
        _id(themables.ThemeIcon.modify(
            themables.ThemeIcon('check~spin'), null)),
      ],
      modified.map(_truthId).toList(),
    );
    expect(
      <Object?>[
        themables.ThemeIcon.getModifier(themables.ThemeIcon('check~spin')),
        themables.ThemeIcon.getModifier(themables.ThemeIcon('check')),
      ],
      _list(_truth['modifier']),
    );
  });

  test('isEqual / isFile / isFolder', () {
    expect(
      <Object?>[
        themables.ThemeIcon.isEqual(
            themables.ThemeIcon('x'), themables.ThemeIcon('x')),
        themables.ThemeIcon.isEqual(themables.ThemeIcon('x'),
            themables.ThemeIcon('x', themables.ThemeColor('red'))),
        themables.ThemeIcon.isEqual(
            themables.ThemeIcon('x', themables.ThemeColor('red')),
            themables.ThemeIcon('x', themables.ThemeColor('red'))),
      ],
      _list(_truth['equal']),
    );
    expect(
      <Object?>[
        themables.ThemeIcon.isFile(themables.ThemeIcon('file')),
        themables.ThemeIcon.isFile(themables.ThemeIcon('folder')),
        themables.ThemeIcon.isFolder(themables.ThemeIcon('folder')),
        themables.ThemeIcon.isFolder(null),
      ],
      _list(_truth['fileFolder']),
    );
  });

  test('codiconsUtil register', () {
    final Map<String, Object?> e = _obj(_truth['register']);
    final List<Object?> rows = _list(e['rows']);
    expect(_id(util.register('a', 10)), _truthId(rows[0]));
    expect(_id(util.register('b', 'a')), _truthId(rows[1]));
    String? message;
    try {
      util.register('c', 'missing');
    } catch (err) {
      message = err.toString().replaceFirst('Bad state: ', '');
    }
    expect(message, e['error']);
    expect(util.getCodiconFontCharacters(), _obj(e['chars']));
  });
}
