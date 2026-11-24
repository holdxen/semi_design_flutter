"""Generator for the `IEditorOptions` region of the editorOptions.ts port.

Re-parses `IEditorOptions` (source lines 53-888) from the pinned vscode
checkout and emits the Dart class deterministically; asserts full 1:1 field
coverage (count + uniqueness) before writing. Output replaces the
`//#region IEditorOptions` block inside
`lib/src/monaco/editor/common/config/editorOptions.dart`; the field
inventory lands in `tool/ts2dart/editor_options_fields.json` for tests.

Same precedent as the `themes.dart` / `keyCodes.dart` table generators.
"""
import json
import re

SRC = '/Users/zhouguiqing/Documents/Code/Html/vscode/src/vs/editor/common/config/editorOptions.ts'
OUT_FIELDS_JSON = 'tool/ts2dart/editor_options_fields.json'
OUT_DART = '/tmp/ieditor_options.dart'


def generate():
    src_lines = open(SRC).read().split('\n')
    body = src_lines[52:888]
    field_line_count = sum(
        1 for l in body if re.match(r'^\t[a-zA-Z][a-zA-Z0-9]*\??: .+;$', l.rstrip()))

    fields, doc = [], []
    for line in body:
        s = line.strip()
        if s.startswith('/**') or s.startswith('*') or s.startswith('*/'):
            doc.append(s)
            continue
        m = re.match(r'^([a-zA-Z][a-zA-Z0-9]*)\??: (.+);$', s)
        if m:
            fields.append({'name': m.group(1), 'type': m.group(2), 'doc': list(doc)})
            doc = []
            continue
        if s and not s.startswith('export') and s != '}':
            doc = []

    assert field_line_count == len(fields), (field_line_count, len(fields))
    names = [f['name'] for f in fields]
    assert len(names) == len(set(names)), 'duplicate field'
    assert len(fields) == 173, len(fields)

    RESERVED = {'default', 'const', 'in', 'is', 'new', 'this', 'super',
                'class', 'enum', 'with', 'switch', 'return', 'var', 'final',
                'static', 'dynamic', 'void'}

    def dart_type(ts):
        t = ts.strip()
        if t == 'boolean':
            return 'bool?', False
        if t == 'string':
            return 'String?', False
        if t == 'number':
            return 'num?', False
        if re.fullmatch(r"'[a-zA-Z0-9-]+'(\s*\|\s*'[a-zA-Z0-9-]+')+", t):
            return 'String?', False
        if re.fullmatch(r"'[a-zA-Z0-9-]+'(\s*\|\s*'[a-zA-Z0-9-]+')+\[\]", t):
            return 'List<String?>?', False
        return None, True

    out = []
    out.append('')
    out.append('//#region IEditorOptions')
    out.append('')
    out.append('/// Configuration options for the editor.')
    out.append('///')
    out.append('/// 1:1: `export interface IEditorOptions` — generated from the source')
    out.append('/// table by `tool/ts2dart/_gen_editor_options.py` (same precedent as')
    out.append('/// `themes.dart` / `keyCodes.dart`): field names, optionality, doc')
    out.append('/// comments and order are 1:1 (the generator asserts full coverage).')
    out.append('/// Type mapping: `boolean`/`string`/`number` and pure string-literal')
    out.append('/// unions map to `bool?`/`String?`/`num?`/`List<String?>?`; every other')
    out.append('/// type (nested option interfaces, function types, imported types, mixed')
    out.append('/// unions) is carried as `Object?` with the original type in a `// TS:`')
    out.append('/// comment - these fields are structural user input, and the option')
    out.append('/// classes in the following segments validate them with fully typed')
    out.append('/// carriers.')
    out.append('class IEditorOptions {')
    out.append('  IEditorOptions();')
    out.append('')
    emitted = []
    for f in fields:
        dt, carrier = dart_type(f['type'])
        dart_name = f['name'] + 'X' if f['name'] in RESERVED else f['name']
        emitted.append(dart_name)
        for d in f['doc']:
            content = d.lstrip('/*').strip()
            if content.startswith('*'):
                content = content[1:].strip()
            if content:
                out.append('  /// ' + content)
        if carrier:
            out.append('  // TS: ' + f['type'])
            out.append('  Object? ' + dart_name + ';')
        else:
            out.append('  ' + dt + ' ' + dart_name + ';')
        out.append('')
    out.append('}')
    out.append('')
    out.append('//#endregion')
    out.append('')

    open(OUT_DART, 'w').write('\n'.join(out))
    json.dump({'sourceFields': len(fields), 'fields': emitted},
              open(OUT_FIELDS_JSON, 'w'))
    return len(emitted)


if __name__ == '__main__':
    print('generated', generate(), 'fields')
