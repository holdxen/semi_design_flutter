// 1:1 port of vscode/src/vs/editor/browser/config/migrateOptions.ts
//
// A registry of option migrations applied to the raw editor options before
// validation. Registration happens at module load in TS; the port registers
// through lazy top-level `final`s (see [editorSettingMigrations]).
//
// Adaptation (documented inline):
//  * TS treats the options object as `Record<string, unknown>` and walks dotted
//    keys. In this port the raw options are carried as
//    `Map<String, Object?>` (the shape produced by `objects.deepClone`), so
//    every read/write goes through the same dotted-key walk on maps.
//  * `typeof value === 'undefined'` -> `value == null` (Dart has no
//    `undefined`; absent keys and explicit nulls are indistinguishable, which
//    matches the migration predicates that only test for absence).
//  * `typeof x === 'boolean' | 'number'` -> `x is bool` / `x is num`;
//    `value && typeof value === 'object'` -> `value is Map`.

/// 1:1: `export interface ISettingsReader`.
typedef ISettingsReader = Object? Function(String key);

/// 1:1: `export interface ISettingsWriter`.
typedef ISettingsWriter = void Function(String key, Object? value);

/// 1:1: `export class EditorSettingMigration`.
class EditorSettingMigration {
  EditorSettingMigration(this.key, this.migrate);

  static final List<EditorSettingMigration> items = <EditorSettingMigration>[];

  final String key;
  final void Function(Object? value, ISettingsReader read, ISettingsWriter write)
      migrate;

  void apply(Map<String, Object?> options) {
    final Object? value = EditorSettingMigration._read(options, key);
    Object? read(String key) => EditorSettingMigration._read(options, key);
    void write(String key, Object? value) =>
        EditorSettingMigration._write(options, key, value);
    migrate(value, read, write);
  }

  static Object? _read(Object? source, String key) {
    if (source == null) {
      return null;
    }

    final int firstDotIndex = key.indexOf('.');
    if (firstDotIndex >= 0) {
      final String firstSegment = key.substring(0, firstDotIndex);
      final Object? next = source is Map ? source[firstSegment] : null;
      return _read(next, key.substring(firstDotIndex + 1));
    }
    // JS `(source as Record<string, unknown>)[key]`.
    return source is Map ? source[key] : null;
  }

  static void _write(Object? target, String key, Object? value) {
    if (target is! Map) {
      return; // TS would throw on a non-object target; unreachable here.
    }
    final int firstDotIndex = key.indexOf('.');
    if (firstDotIndex >= 0) {
      final String firstSegment = key.substring(0, firstDotIndex);
      // `target[firstSegment] = target[firstSegment] || {}`
      Object? child = target[firstSegment];
      if (child == null || child == false) {
        child = <String, Object?>{};
        target[firstSegment] = child;
      }
      _write(child, key.substring(firstDotIndex + 1), value);
      return;
    }
    target[key] = value;
  }
}

void _registerEditorSettingMigration(
  String key,
  void Function(Object? value, ISettingsReader read, ISettingsWriter write)
      migrate,
) {
  EditorSettingMigration.items.add(EditorSettingMigration(key, migrate));
}

void registerSimpleEditorSettingMigration(
    String key, List<List<Object?>> values) {
  _registerEditorSettingMigration(key, (Object? value, ISettingsReader read,
      ISettingsWriter write) {
    if (value != null) {
      for (final List<Object?> pair in values) {
        if (value == pair[0]) {
          write(key, pair[1]);
          return;
        }
      }
    }
  });
}

/// Compatibility with old options.
void migrateOptions(Map<String, Object?> options) {
  for (final EditorSettingMigration migration
      in EditorSettingMigration.items) {
    migration.apply(options);
  }
}

void _registerAllMigrations() {
  // Simple value migrations, in TS registration order.
registerSimpleEditorSettingMigration('wordWrap', <List<Object?>>[<Object?>[true, 'on'], <Object?>[false, 'off']]);
registerSimpleEditorSettingMigration('lineNumbers', <List<Object?>>[<Object?>[true, 'on'], <Object?>[false, 'off']]);
registerSimpleEditorSettingMigration('cursorBlinking', <List<Object?>>[<Object?>['visible', 'solid']]);
registerSimpleEditorSettingMigration('renderWhitespace', <List<Object?>>[<Object?>[true, 'boundary'], <Object?>[false, 'none']]);
registerSimpleEditorSettingMigration('renderLineHighlight', <List<Object?>>[<Object?>[true, 'line'], <Object?>[false, 'none']]);
registerSimpleEditorSettingMigration('acceptSuggestionOnEnter', <List<Object?>>[<Object?>[true, 'on'], <Object?>[false, 'off']]);
registerSimpleEditorSettingMigration('tabCompletion', <List<Object?>>[<Object?>[false, 'off'], <Object?>[true, 'onlySnippets']]);
registerSimpleEditorSettingMigration('hover', <List<Object?>>[<Object?>[true, <String, Object?>{'enabled': true}], <Object?>[false, <String, Object?>{'enabled': false}]]);
registerSimpleEditorSettingMigration('parameterHints', <List<Object?>>[<Object?>[true, <String, Object?>{'enabled': true}], <Object?>[false, <String, Object?>{'enabled': false}]]);
registerSimpleEditorSettingMigration('autoIndent', <List<Object?>>[<Object?>[false, 'advanced'], <Object?>[true, 'full']]);
registerSimpleEditorSettingMigration('matchBrackets', <List<Object?>>[<Object?>[true, 'always'], <Object?>[false, 'never']]);
registerSimpleEditorSettingMigration('renderFinalNewline', <List<Object?>>[<Object?>[true, 'on'], <Object?>[false, 'off']]);
registerSimpleEditorSettingMigration('cursorSmoothCaretAnimation', <List<Object?>>[<Object?>[true, 'on'], <Object?>[false, 'off']]);
registerSimpleEditorSettingMigration('occurrencesHighlight', <List<Object?>>[<Object?>[true, 'singleFile'], <Object?>[false, 'off']]);
registerSimpleEditorSettingMigration('wordBasedSuggestions', <List<Object?>>[<Object?>[true, 'matchingDocuments'], <Object?>[false, 'off']]);
registerSimpleEditorSettingMigration('defaultColorDecorators', <List<Object?>>[<Object?>[true, 'auto'], <Object?>[false, 'never']]);
registerSimpleEditorSettingMigration('minimap.autohide', <List<Object?>>[<Object?>[true, 'mouseover'], <Object?>[false, 'none']]);

  _registerEditorSettingMigration('autoClosingBrackets',
      (Object? value, ISettingsReader read, ISettingsWriter write) {
    if (value == false) {
      write('autoClosingBrackets', 'never');
      if (read('autoClosingQuotes') == null) {
        write('autoClosingQuotes', 'never');
      }
      if (read('autoSurround') == null) {
        write('autoSurround', 'never');
      }
    }
  });

  _registerEditorSettingMigration('renderIndentGuides',
      (Object? value, ISettingsReader read, ISettingsWriter write) {
    if (value != null) {
      write('renderIndentGuides', null);
      if (read('guides.indentation') == null) {
        write('guides.indentation', _jsBool(value));
      }
    }
  });

  _registerEditorSettingMigration('highlightActiveIndentGuide',
      (Object? value, ISettingsReader read, ISettingsWriter write) {
    if (value != null) {
      write('highlightActiveIndentGuide', null);
      if (read('guides.highlightActiveIndentation') == null) {
        write('guides.highlightActiveIndentation', _jsBool(value));
      }
    }
  });

  _registerEditorSettingMigration('suggest.filteredTypes',
      (Object? value, ISettingsReader read, ISettingsWriter write) {
    if (value is Map) {
      for (final MapEntry<String, String> entry
          in _suggestFilteredTypesMapping.entries) {
        final Object? v = value[entry.key];
        if (v == false) {
          if (read('suggest.${entry.value}') == null) {
            write('suggest.${entry.value}', false);
          }
        }
      }
      write('suggest.filteredTypes', null);
    }
  });

  _registerEditorSettingMigration('quickSuggestions',
      (Object? input, ISettingsReader read, ISettingsWriter write) {
    if (input is bool) {
      final String value = input ? 'on' : 'off';
      final Map<String, Object?> newValue = <String, Object?>{
        'comments': value,
        'strings': value,
        'other': value,
      };
      write('quickSuggestions', newValue);
    }
  });

  // Sticky Scroll
  _registerEditorSettingMigration('experimental.stickyScroll.enabled',
      (Object? value, ISettingsReader read, ISettingsWriter write) {
    if (value is bool) {
      write('experimental.stickyScroll.enabled', null);
      if (read('stickyScroll.enabled') == null) {
        write('stickyScroll.enabled', value);
      }
    }
  });

  _registerEditorSettingMigration('experimental.stickyScroll.maxLineCount',
      (Object? value, ISettingsReader read, ISettingsWriter write) {
    if (value is num) {
      write('experimental.stickyScroll.maxLineCount', null);
      if (read('stickyScroll.maxLineCount') == null) {
        write('stickyScroll.maxLineCount', value);
      }
    }
  });

  // Edit Context
  _registerEditorSettingMigration('editor.experimentalEditContextEnabled',
      (Object? value, ISettingsReader read, ISettingsWriter write) {
    if (value is bool) {
      write('editor.experimentalEditContextEnabled', null);
      if (read('editor.editContext') == null) {
        write('editor.editContext', value);
      }
    }
  });

  // Code Actions on Save
  _registerEditorSettingMigration('codeActionsOnSave',
      (Object? value, ISettingsReader read, ISettingsWriter write) {
    if (value is Map) {
      bool toBeModified = false;
      final Map<String, Object?> newValue = <String, Object?>{};
      for (final MapEntry<Object?, Object?> entry in value.entries) {
        final String key = entry.key.toString();
        final Object? entryValue = entry.value;
        if (entryValue is bool) {
          toBeModified = true;
          newValue[key] = entryValue ? 'explicit' : 'never';
        } else {
          newValue[key] = entryValue;
        }
      }
      if (toBeModified) {
        write('codeActionsOnSave', newValue);
      }
    }
  });

  // Migrate Quick Fix Settings
  _registerEditorSettingMigration(
      'codeActionWidget.includeNearbyQuickfixes',
      (Object? value, ISettingsReader read, ISettingsWriter write) {
    if (value is bool) {
      write('codeActionWidget.includeNearbyQuickfixes', null);
      if (read('codeActionWidget.includeNearbyQuickFixes') == null) {
        write('codeActionWidget.includeNearbyQuickFixes', value);
      }
    }
  });

  // Migrate the lightbulb settings
  _registerEditorSettingMigration('lightbulb.enabled',
      (Object? value, ISettingsReader read, ISettingsWriter write) {
    if (value is bool) {
      write('lightbulb.enabled', value ? null : 'off');
    }
  });

  // NES Code Shifting
  _registerEditorSettingMigration('inlineSuggest.edits.codeShifting',
      (Object? value, ISettingsReader read, ISettingsWriter write) {
    if (value is bool) {
      write('inlineSuggest.edits.codeShifting', null);
      write('inlineSuggest.edits.allowCodeShifting',
          value ? 'always' : 'never');
    }
  });

  // Migrate Hover
  _registerEditorSettingMigration('hover.enabled',
      (Object? value, ISettingsReader read, ISettingsWriter write) {
    if (value is bool) {
      write('hover.enabled', value ? 'on' : 'off');
    }
  });
}

/// JS `!!value` for the truthiness of a migration input.
bool _jsBool(Object? value) {
  if (value == null || value == false) return false;
  if (value is num) return value != 0 && !value.isNaN;
  if (value is String) return value.isNotEmpty;
  return true;
}

/// 1:1: the `suggestFilteredTypesMapping` table (insertion order matters).
const Map<String, String> _suggestFilteredTypesMapping = <String, String>{
  'method': 'showMethods',
  'function': 'showFunctions',
  'constructor': 'showConstructors',
  'deprecated': 'showDeprecated',
  'field': 'showFields',
  'variable': 'showVariables',
  'class': 'showClasses',
  'struct': 'showStructs',
  'interface': 'showInterfaces',
  'module': 'showModules',
  'property': 'showProperties',
  'event': 'showEvents',
  'operator': 'showOperators',
  'unit': 'showUnits',
  'value': 'showValues',
  'constant': 'showConstants',
  'enum': 'showEnums',
  'enumMember': 'showEnumMembers',
  'keyword': 'showKeywords',
  'text': 'showWords',
  'color': 'showColors',
  'file': 'showFiles',
  'reference': 'showReferences',
  'folder': 'showFolders',
  'typeParameter': 'showTypeParameters',
  'snippet': 'showSnippets',
};

/// 1:1 module-load side effect: every `register...` call in the TS file.
/// Dart top-level statements are lazy, so touching this final performs the
/// registration once (same convention as `quickAccessRegistryRegistration`).
final List<EditorSettingMigration> editorSettingMigrations = () {
  _registerAllMigrations();
  return EditorSettingMigration.items;
}();
