// 1:1 replay of `editor/common/languages.ts` (2718 lines).
//
// `languages.ts` has no official unit test, so `tool/ts2dart/_batch245_truth.cjs`
// executes the real TypeScript source and records the runtime surface:
//  - the 26 enums,
//  - `CompletionItemKinds` (toIcon / toLabel for every kind + unknowns,
//    fromString for the aliases and both fallback modes),
//  - `SymbolKinds` (toIcon / toCompletionKind for every kind + unknown),
//    `symbolKindNames` and `getAriaLabelForSymbol`,
//  - `Token` / `TokenizationResult` / `EncodedTokenizationResult`,
//    `SelectedSuggestionInfo.equals`, `ProviderId`, `VersionedExtensionId`,
//  - `isLocation` / `isLocationLink` over the JS-shaped input matrix,
//  - `TextEdit.asEditOperation` / `isTextEdit` (including the real implementation
//    throwing on `null`),
//  - `FoldingRangeKind`, `Command.is`, `LazyTokenizationSupport`
//    (one creation, shared promise, dispose after resolve) and the
//    `TokenizationRegistry` singleton.
//
// Adaptations replayed: plain JS object literals are `Map`s, erased interfaces
// (`IState`, `IFontToken`, `ITokenizationSupport`) are `Object`, and
// `Command.is` is `Command.isCommand` (Dart keyword).
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/uri.dart' show URI;
import '../lib/src/monaco/editor/common/core/range.dart';
import '../lib/src/monaco/editor/common/languages.dart' as languages;
import '../lib/src/monaco/editor/common/tokenizationRegistry.dart'
    as registry;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch245_truth.json').readAsStringSync()));

/// `[name, value]` pairs from the truth become a `Map<String, T>`.
Map<String, T> _pairs<T>(Object? truthList) => <String, T>{
      for (final entry in (truthList as List))
        (entry as List)[0] as String: entry[1] as T,
    };

class _FakeTextEdit implements languages.TextEdit {
  _FakeTextEdit(this.range, this.text);

  @override
  final IRange range;

  @override
  final String text;

  @override
  int? get eol => null;
}

void main() {
  final truth = _truth();

  group('enums', () {
    test('match the real TypeScript values', () {
      expect(<String, Map<String, int>>{
        'HoverVerbosityAction': <String, int>{
          'Increase': languages.HoverVerbosityAction.Increase,
          'Decrease': languages.HoverVerbosityAction.Decrease,
        },
        'CompletionItemKind': <String, int>{
          'Method': languages.CompletionItemKind.Method,
          'Function': languages.CompletionItemKind.Function,
          'Constructor': languages.CompletionItemKind.Constructor,
          'Field': languages.CompletionItemKind.Field,
          'Variable': languages.CompletionItemKind.Variable,
          'Class': languages.CompletionItemKind.Class,
          'Struct': languages.CompletionItemKind.Struct,
          'Interface': languages.CompletionItemKind.Interface,
          'Module': languages.CompletionItemKind.Module,
          'Property': languages.CompletionItemKind.Property,
          'Event': languages.CompletionItemKind.Event,
          'Operator': languages.CompletionItemKind.Operator,
          'Unit': languages.CompletionItemKind.Unit,
          'Value': languages.CompletionItemKind.Value,
          'Constant': languages.CompletionItemKind.Constant,
          'Enum': languages.CompletionItemKind.Enum,
          'EnumMember': languages.CompletionItemKind.EnumMember,
          'Keyword': languages.CompletionItemKind.Keyword,
          'Text': languages.CompletionItemKind.Text,
          'Color': languages.CompletionItemKind.Color,
          'File': languages.CompletionItemKind.File,
          'Reference': languages.CompletionItemKind.Reference,
          'Customcolor': languages.CompletionItemKind.Customcolor,
          'Folder': languages.CompletionItemKind.Folder,
          'TypeParameter': languages.CompletionItemKind.TypeParameter,
          'User': languages.CompletionItemKind.User,
          'Issue': languages.CompletionItemKind.Issue,
          'Tool': languages.CompletionItemKind.Tool,
          'Snippet': languages.CompletionItemKind.Snippet,
        },
        'CompletionItemTag': <String, int>{
          'Deprecated': languages.CompletionItemTag.Deprecated,
        },
        'CompletionItemInsertTextRule': <String, int>{
          'None': languages.CompletionItemInsertTextRule.None,
          'KeepWhitespace':
              languages.CompletionItemInsertTextRule.KeepWhitespace,
          'InsertAsSnippet':
              languages.CompletionItemInsertTextRule.InsertAsSnippet,
        },
        'PartialAcceptTriggerKind': <String, int>{
          'Word': languages.PartialAcceptTriggerKind.Word,
          'Line': languages.PartialAcceptTriggerKind.Line,
          'Suggest': languages.PartialAcceptTriggerKind.Suggest,
        },
        'CompletionTriggerKind': <String, int>{
          'Invoke': languages.CompletionTriggerKind.Invoke,
          'TriggerCharacter': languages.CompletionTriggerKind.TriggerCharacter,
          'TriggerForIncompleteCompletions':
              languages.CompletionTriggerKind.TriggerForIncompleteCompletions,
        },
        'InlineCompletionTriggerKind': <String, int>{
          'Automatic': languages.InlineCompletionTriggerKind.Automatic,
          'Explicit': languages.InlineCompletionTriggerKind.Explicit,
        },
        'InlineCompletionHintStyle': <String, int>{
          'Code': languages.InlineCompletionHintStyle.Code,
          'Label': languages.InlineCompletionHintStyle.Label,
        },
        'InlineCompletionEndOfLifeReasonKind': <String, int>{
          'Accepted': languages.InlineCompletionEndOfLifeReasonKind.Accepted,
          'Rejected': languages.InlineCompletionEndOfLifeReasonKind.Rejected,
          'Ignored': languages.InlineCompletionEndOfLifeReasonKind.Ignored,
        },
        'CodeActionTriggerType': <String, int>{
          'Invoke': languages.CodeActionTriggerType.Invoke,
          'Auto': languages.CodeActionTriggerType.Auto,
        },
        'DocumentPasteTriggerKind': <String, int>{
          'Automatic': languages.DocumentPasteTriggerKind.Automatic,
          'PasteAs': languages.DocumentPasteTriggerKind.PasteAs,
        },
        'SignatureHelpTriggerKind': <String, int>{
          'Invoke': languages.SignatureHelpTriggerKind.Invoke,
          'TriggerCharacter': languages.SignatureHelpTriggerKind.TriggerCharacter,
          'ContentChange': languages.SignatureHelpTriggerKind.ContentChange,
        },
        'DocumentHighlightKind': <String, int>{
          'Text': languages.DocumentHighlightKind.Text,
          'Read': languages.DocumentHighlightKind.Read,
          'Write': languages.DocumentHighlightKind.Write,
        },
        'SymbolKind': <String, int>{
          'File': languages.SymbolKind.File,
          'Module': languages.SymbolKind.Module,
          'Namespace': languages.SymbolKind.Namespace,
          'Package': languages.SymbolKind.Package,
          'Class': languages.SymbolKind.Class,
          'Method': languages.SymbolKind.Method,
          'Property': languages.SymbolKind.Property,
          'Field': languages.SymbolKind.Field,
          'Constructor': languages.SymbolKind.Constructor,
          'Enum': languages.SymbolKind.Enum,
          'Interface': languages.SymbolKind.Interface,
          'Function': languages.SymbolKind.Function,
          'Variable': languages.SymbolKind.Variable,
          'Constant': languages.SymbolKind.Constant,
          'String': languages.SymbolKind.String,
          'Number': languages.SymbolKind.Number,
          'Boolean': languages.SymbolKind.Boolean,
          'Array': languages.SymbolKind.Array,
          'Object': languages.SymbolKind.Object,
          'Key': languages.SymbolKind.Key,
          'Null': languages.SymbolKind.Null,
          'EnumMember': languages.SymbolKind.EnumMember,
          'Struct': languages.SymbolKind.Struct,
          'Event': languages.SymbolKind.Event,
          'Operator': languages.SymbolKind.Operator,
          'TypeParameter': languages.SymbolKind.TypeParameter,
        },
        'SymbolTag': <String, int>{
          'Deprecated': languages.SymbolTag.Deprecated,
        },
        'StructuralDiffClassification': <String, int>{
          'Declaration': languages.StructuralDiffClassification.Declaration,
          'Header': languages.StructuralDiffClassification.Header,
          'Implementation':
              languages.StructuralDiffClassification.Implementation,
          'Dependency': languages.StructuralDiffClassification.Dependency,
          'Other': languages.StructuralDiffClassification.Other,
        },
        'StructuralDiffTag': <String, int>{
          'Test': languages.StructuralDiffTag.Test,
        },
        'NewSymbolNameTag': <String, int>{
          'AIGenerated': languages.NewSymbolNameTag.AIGenerated,
        },
        'NewSymbolNameTriggerKind': <String, int>{
          'Invoke': languages.NewSymbolNameTriggerKind.Invoke,
          'Automatic': languages.NewSymbolNameTriggerKind.Automatic,
        },
        'CommentThreadCollapsibleState': <String, int>{
          'Collapsed': languages.CommentThreadCollapsibleState.Collapsed,
          'Expanded': languages.CommentThreadCollapsibleState.Expanded,
        },
        'CommentThreadState': <String, int>{
          'Unresolved': languages.CommentThreadState.Unresolved,
          'Resolved': languages.CommentThreadState.Resolved,
        },
        'CommentThreadApplicability': <String, int>{
          'Current': languages.CommentThreadApplicability.Current,
          'Outdated': languages.CommentThreadApplicability.Outdated,
        },
        'CommentMode': <String, int>{
          'Editing': languages.CommentMode.Editing,
          'Preview': languages.CommentMode.Preview,
        },
        'CommentState': <String, int>{
          'Published': languages.CommentState.Published,
          'Draft': languages.CommentState.Draft,
        },
        'InlayHintKind': <String, int>{
          'Type': languages.InlayHintKind.Type,
          'Parameter': languages.InlayHintKind.Parameter,
        },
        'ExternalUriOpenerPriority': <String, int>{
          'None': languages.ExternalUriOpenerPriority.None,
          'Option': languages.ExternalUriOpenerPriority.Option,
          'Default': languages.ExternalUriOpenerPriority.Default,
          'Preferred': languages.ExternalUriOpenerPriority.Preferred,
        },
      }, _map(truth['enums']));
    });
  });

  group('CompletionItemKinds', () {
    final kindValues = <String, int>{
      'Method': languages.CompletionItemKind.Method,
      'Function': languages.CompletionItemKind.Function,
      'Constructor': languages.CompletionItemKind.Constructor,
      'Field': languages.CompletionItemKind.Field,
      'Variable': languages.CompletionItemKind.Variable,
      'Class': languages.CompletionItemKind.Class,
      'Struct': languages.CompletionItemKind.Struct,
      'Interface': languages.CompletionItemKind.Interface,
      'Module': languages.CompletionItemKind.Module,
      'Property': languages.CompletionItemKind.Property,
      'Event': languages.CompletionItemKind.Event,
      'Operator': languages.CompletionItemKind.Operator,
      'Unit': languages.CompletionItemKind.Unit,
      'Value': languages.CompletionItemKind.Value,
      'Constant': languages.CompletionItemKind.Constant,
      'Enum': languages.CompletionItemKind.Enum,
      'EnumMember': languages.CompletionItemKind.EnumMember,
      'Keyword': languages.CompletionItemKind.Keyword,
      'Text': languages.CompletionItemKind.Text,
      'Color': languages.CompletionItemKind.Color,
      'File': languages.CompletionItemKind.File,
      'Reference': languages.CompletionItemKind.Reference,
      'Customcolor': languages.CompletionItemKind.Customcolor,
      'Folder': languages.CompletionItemKind.Folder,
      'TypeParameter': languages.CompletionItemKind.TypeParameter,
      'User': languages.CompletionItemKind.User,
      'Issue': languages.CompletionItemKind.Issue,
      'Tool': languages.CompletionItemKind.Tool,
      'Snippet': languages.CompletionItemKind.Snippet,
    };

    test('toIcon maps every kind to its codicon id', () {
      final truthIcons = _map(truth['completionItemKinds']['toIcon']);
      for (final entry in kindValues.entries) {
        expect(languages.CompletionItemKinds.toIcon(entry.value).id,
            truthIcons[entry.key],
            reason: entry.key);
      }
      expect(languages.CompletionItemKinds.toIcon(999).id,
          truth['completionItemKinds']['toIconUnknown']);
    });

    test('toLabel localizes every kind and defaults to empty', () {
      final truthLabels = _map(truth['completionItemKinds']['toLabel']);
      for (final entry in kindValues.entries) {
        expect(languages.CompletionItemKinds.toLabel(entry.value),
            truthLabels[entry.key],
            reason: entry.key);
      }
      expect(languages.CompletionItemKinds.toLabel(999),
          truth['completionItemKinds']['toLabelUnknown']);
    });

    test('fromString applies the Property fallback unless strict', () {
      final expected = _map(truth['completionItemKinds']['fromString']);
      const samples = <String>[
        'method',
        'enum-member',
        'enumMember',
        'type-parameter',
        'typeParameter',
        'account',
        'issue',
        'tool',
        'customcolor',
      ];
      for (final sample in samples) {
        expect(languages.CompletionItemKinds.fromString(sample),
            expected[sample],
            reason: sample);
      }
      expect(languages.CompletionItemKinds.fromString('nope'),
          expected['unknownLoose']);
      expect(languages.CompletionItemKinds.tryFromString('nope'),
          expected['unknownStrict']);
    });
  });

  group('SymbolKinds', () {
    test('toIcon / toCompletionKind cover every kind and the fallbacks', () {
      final icons = _map(truth['symbolKinds']['toIcon']);
      final completionKinds = _map(truth['symbolKinds']['toCompletionKind']);
      final kinds = <String, int>{
        'File': languages.SymbolKind.File,
        'Module': languages.SymbolKind.Module,
        'Namespace': languages.SymbolKind.Namespace,
        'Package': languages.SymbolKind.Package,
        'Class': languages.SymbolKind.Class,
        'Method': languages.SymbolKind.Method,
        'Property': languages.SymbolKind.Property,
        'Field': languages.SymbolKind.Field,
        'Constructor': languages.SymbolKind.Constructor,
        'Enum': languages.SymbolKind.Enum,
        'Interface': languages.SymbolKind.Interface,
        'Function': languages.SymbolKind.Function,
        'Variable': languages.SymbolKind.Variable,
        'Constant': languages.SymbolKind.Constant,
        'String': languages.SymbolKind.String,
        'Number': languages.SymbolKind.Number,
        'Boolean': languages.SymbolKind.Boolean,
        'Array': languages.SymbolKind.Array,
        'Object': languages.SymbolKind.Object,
        'Key': languages.SymbolKind.Key,
        'Null': languages.SymbolKind.Null,
        'EnumMember': languages.SymbolKind.EnumMember,
        'Struct': languages.SymbolKind.Struct,
        'Event': languages.SymbolKind.Event,
        'Operator': languages.SymbolKind.Operator,
        'TypeParameter': languages.SymbolKind.TypeParameter,
      };
      for (final entry in kinds.entries) {
        expect(languages.SymbolKinds.toIcon(entry.value).id, icons[entry.key],
            reason: 'icon ${entry.key}');
        expect(languages.SymbolKinds.toCompletionKind(entry.value),
            completionKinds[entry.key],
            reason: 'completion ${entry.key}');
      }
      expect(languages.SymbolKinds.toIcon(999).id,
          truth['symbolKinds']['toIconUnknown']);
      expect(languages.SymbolKinds.toCompletionKind(999),
          truth['symbolKinds']['toCompletionKindUnknown']);
    });

    test('symbolKindNames and getAriaLabelForSymbol', () {
      final names = _map(truth['symbolKindNames']);
      final kinds = <String, int>{
        'File': languages.SymbolKind.File,
        'Module': languages.SymbolKind.Module,
        'Namespace': languages.SymbolKind.Namespace,
        'Package': languages.SymbolKind.Package,
        'Class': languages.SymbolKind.Class,
        'Method': languages.SymbolKind.Method,
        'Property': languages.SymbolKind.Property,
        'Field': languages.SymbolKind.Field,
        'Constructor': languages.SymbolKind.Constructor,
        'Enum': languages.SymbolKind.Enum,
        'Interface': languages.SymbolKind.Interface,
        'Function': languages.SymbolKind.Function,
        'Variable': languages.SymbolKind.Variable,
        'Constant': languages.SymbolKind.Constant,
        'String': languages.SymbolKind.String,
        'Number': languages.SymbolKind.Number,
        'Boolean': languages.SymbolKind.Boolean,
        'Array': languages.SymbolKind.Array,
        'Object': languages.SymbolKind.Object,
        'Key': languages.SymbolKind.Key,
        'Null': languages.SymbolKind.Null,
        'EnumMember': languages.SymbolKind.EnumMember,
        'Struct': languages.SymbolKind.Struct,
        'Event': languages.SymbolKind.Event,
        'Operator': languages.SymbolKind.Operator,
        'TypeParameter': languages.SymbolKind.TypeParameter,
      };
      for (final entry in kinds.entries) {
        expect(languages.symbolKindNames[entry.value], names[entry.key],
            reason: entry.key);
      }
      expect(languages.getAriaLabelForSymbol('foo', languages.SymbolKind.Class),
          truth['ariaLabel']);
      expect(languages.getAriaLabelForSymbol('foo', 999),
          truth['ariaLabelUnknown']);
    });
  });

  group('tokenization value objects', () {
    test('Token keeps offset / type / language and stringifies', () {
      final token = languages.Token(3, 'keyword', 'typescript');
      final expected = _map(truth['token']);
      expect(token.offset, expected['offset']);
      expect(token.type, expected['type']);
      expect(token.language, expected['language']);
      expect(token.toString(), expected['toString']);
    });

    test('TokenizationResult keeps tokens and end state identity', () {
      final token = languages.Token(3, 'keyword', 'typescript');
      final state = <String, Object?>{'kind': 'state'};
      final result = languages.TokenizationResult(<languages.Token>[token], state);
      final expected = _map(truth['tokenizationResult']);
      expect(result.tokens.map((t) => t.toString()).toList(),
          expected['tokens']);
      expect(identical(result.endState, state),
          expected['endStateIsSame']);
    });

    test('EncodedTokenizationResult keeps the binary payload', () {
      final state = <String, Object?>{'kind': 'state'};
      final result = languages.EncodedTokenizationResult(
          Uint32List.fromList(<int>[0, 1, 2, 3]), <Object?>[], state);
      final expected = _map(truth['encodedTokenizationResult']);
      expect(result.tokens.toList(), expected['tokens']);
      expect(result.fontInfo, expected['fontInfo']);
      expect(identical(result.endState, state), expected['endStateIsSame']);
    });
  });

  group('SelectedSuggestionInfo', () {
    test('equals compares lifted ranges and every field', () {
      final range = Range(1, 2, 1, 5);
      final info = languages.SelectedSuggestionInfo(
          range, 'text', languages.CompletionItemKind.Method, true);
      final expected = _map(truth['selectedSuggestionInfo']);
      expect(<String, Object?>{
        'range': _rangeOf(info.range),
        'text': info.text,
        'completionKind': info.completionKind,
        'isSnippetText': info.isSnippetText,
        'equalsSame': info.equals(languages.SelectedSuggestionInfo(
            Range(1, 2, 1, 5), 'text', languages.CompletionItemKind.Method, true)),
        'equalsOtherRange': info.equals(languages.SelectedSuggestionInfo(
            Range(1, 2, 1, 6), 'text', languages.CompletionItemKind.Method, true)),
        'equalsOtherText': info.equals(languages.SelectedSuggestionInfo(
            range, 'other', languages.CompletionItemKind.Method, true)),
        'equalsOtherKind': info.equals(languages.SelectedSuggestionInfo(
            range, 'text', languages.CompletionItemKind.Field, true)),
        'equalsOtherSnippet': info.equals(languages.SelectedSuggestionInfo(
            range, 'text', languages.CompletionItemKind.Method, false)),
      }, expected);
    });
  });

  group('ProviderId / VersionedExtensionId', () {
    test('toString variants mirror the JS concatenation', () {
      const rows = <List<String?>>[
        <String?>[null, null, null],
        <String?>['ext', null, null],
        <String?>['ext', '1.2.3', null],
        <String?>['ext', '1.2.3', 'prov'],
        <String?>[null, null, 'prov'],
      ];
      final expected = truth['providerId'] as List;
      for (var i = 0; i < rows.length; i++) {
        final row = rows[i];
        final id = languages.ProviderId(row[0], row[1], row[2]);
        final exp = _map(expected[i]);
        expect(id.toString(), exp['toString'], reason: 'toString #$i');
        expect(id.toStringWithoutVersion(), exp['toStringWithoutVersion'],
            reason: 'toStringWithoutVersion #$i');
      }
      expect(languages.ProviderId.fromExtensionId('ext').toString(),
          truth['providerIdFromExtension']);
      expect(languages.ProviderId.fromExtensionId(null).toString(),
          truth['providerIdFromExtensionUndefined']);
    });

    test('VersionedExtensionId.tryCreate requires both parts', () {
      final expected = _pairs<String?>(truth['versionedExtensionId']);
      expect(languages.VersionedExtensionId.tryCreate('ext', '1.0')?.toString(),
          expected['both']);
      expect(languages.VersionedExtensionId.tryCreate('ext', null),
          isNull);
      expect(languages.VersionedExtensionId.tryCreate(null, '1.0'), isNull);
      expect(languages.VersionedExtensionId.tryCreate('', '1.0'), isNull);
      expect(expected['noVersion'], isNull);
      expect(expected['noExt'], isNull);
      expect(expected['emptyExt'], isNull);
    });
  });

  group('location predicates', () {
    test('isLocation over the JS input matrix', () {
      final expected = _pairs<bool>(truth['isLocation']);
      final range = Range(1, 1, 1, 2);
      expect(languages.isLocation(null), expected['null']);
      expect(languages.isLocation(<String, Object?>{}), expected['emptyObject']);
      expect(languages.isLocation(<String, Object?>{'uri': URI.parse('file:///a')}),
          expected['uriOnly']);
      expect(languages.isLocation(<String, Object?>{'range': range}),
          expected['rangeOnly']);
      expect(
          languages.isLocation(<String, Object?>{
            'uri': URI.parse('file:///a'),
            'range': range,
          }),
          expected['both']);
      expect(
          languages.isLocation(<String, Object?>{
            'uri': 'file:///a',
            'range': range,
          }),
          expected['uriString']);
    });

    test('isLocationLink over the JS input matrix', () {
      final expected = _pairs<bool>(truth['isLocationLink']);
      final uri = URI.parse('file:///a');
      final range = Range(1, 1, 1, 2);
      final other = Range(2, 2, 2, 3);
      expect(languages.isLocationLink(null), expected['null']);
      expect(languages.isLocationLink(<String, Object?>{}),
          expected['emptyObject']);
      expect(languages.isLocationLink(<String, Object?>{'uri': uri, 'range': range}),
          expected['uriRangeOnly']);
      expect(
          languages.isLocationLink(<String, Object?>{
            'uri': uri,
            'range': range,
            'originSelectionRange': other,
          }),
          expected['withOrigin']);
      expect(
          languages.isLocationLink(<String, Object?>{
            'uri': uri,
            'range': range,
            'targetSelectionRange': other,
          }),
          expected['withTarget']);
      expect(
          languages.isLocationLink(<String, Object?>{
            'uri': uri,
            'range': range,
            'originSelectionRange': other,
            'targetSelectionRange': other,
          }),
          expected['withBoth']);
      expect(
          languages.isLocationLink(<String, Object?>{
            'uri': uri,
            'range': 'nope',
            'originSelectionRange': other,
          }),
          expected['badRange']);
    });
  });

  group('TextEdit', () {
    test('asEditOperation turns empty ranges into inserts', () {
      final expected = _map(truth['textEdit']);
      final insert = languages.TextEdit.asEditOperation(
          _FakeTextEdit(Range(2, 3, 2, 3), 'abc'));
      final replace = languages.TextEdit.asEditOperation(
          _FakeTextEdit(Range(2, 1, 2, 5), 'abc'));
      // `ISingleEditOperation` carries only range/text/forceMoveMarkers; the
      // truth's extra keys are `undefined` in JS and stay erased here.
      expect(<String, Object?>{
        'range': _rangeOf(insert.range),
        'text': insert.text,
        'forceMoveMarkers': insert.forceMoveMarkers,
      }, _pick(expected['insert'], const <String>[
        'range', 'text', 'forceMoveMarkers',
      ]));
      expect(<String, Object?>{
        'range': _rangeOf(replace.range),
        'text': replace.text,
        'forceMoveMarkers': replace.forceMoveMarkers,
      }, _pick(expected['replace'], const <String>[
        'range', 'text', 'forceMoveMarkers',
      ]));
      expect(_pick(expected['withEol'], const <String>[
        'range', 'text', 'forceMoveMarkers',
      ]), _pick(expected['replace'], const <String>[
        'range', 'text', 'forceMoveMarkers',
      ]));
    });

    test('isTextEdit mirrors the real matrix (throws on null)', () {
      final expected = _pairs<Object?>(truth['textEdit']['isTextEdit']);
      final range = Range(1, 1, 1, 2);
      expect(expected['null'], 'throws');
      expect(() => languages.TextEdit.isTextEdit(null), throwsA(anything));
      expect(languages.TextEdit.isTextEdit(<String, Object?>{}),
          expected['emptyObject']);
      expect(languages.TextEdit.isTextEdit(<String, Object?>{'text': 'a'}),
          expected['textOnly']);
      expect(languages.TextEdit.isTextEdit(<String, Object?>{'range': range}),
          expected['rangeOnly']);
      expect(
          languages.TextEdit.isTextEdit(
              <String, Object?>{'range': range, 'text': 'a'}),
          expected['both']);
      expect(
          languages.TextEdit.isTextEdit(
              <String, Object?>{'range': range, 'text': 1}),
          expected['textNumber']);
    });
  });

  group('FoldingRangeKind', () {
    test('static kinds, identity in fromValue and fresh unknown values', () {
      final expected = _map(truth['foldingRangeKind']);
      expect(languages.FoldingRangeKind.Comment.value, expected['comment']);
      expect(languages.FoldingRangeKind.Imports.value, expected['imports']);
      expect(languages.FoldingRangeKind.Region.value, expected['region']);
      expect(
          identical(languages.FoldingRangeKind.fromValue('comment'),
              languages.FoldingRangeKind.Comment),
          expected['fromComment']);
      expect(
          identical(languages.FoldingRangeKind.fromValue('imports'),
              languages.FoldingRangeKind.Imports),
          expected['fromImports']);
      expect(
          identical(languages.FoldingRangeKind.fromValue('region'),
              languages.FoldingRangeKind.Region),
          expected['fromRegion']);
      expect(languages.FoldingRangeKind.fromValue('custom').value,
          expected['fromUnknownValue']);
      expect(
          !identical(languages.FoldingRangeKind.fromValue('custom'),
              languages.FoldingRangeKind.fromValue('custom')),
          expected['fromUnknownIsNew']);
    });
  });

  group('Command', () {
    test('isCommand matches id + title strings', () {
      final expected = _pairs<bool>(truth['commandIs']);
      expect(languages.Command.isCommand(null), expected['null']);
      expect(languages.Command.isCommand(<String, Object?>{}),
          expected['emptyObject']);
      expect(languages.Command.isCommand(<String, Object?>{'id': 'a'}),
          expected['idOnly']);
      expect(
          languages.Command.isCommand(<String, Object?>{'id': 'a', 'title': 'A'}),
          expected['idTitle']);
      expect(
          languages.Command.isCommand(<String, Object?>{'id': 1, 'title': 'A'}),
          expected['idNumber']);
    });
  });

  group('LazyTokenizationSupport', () {
    test('creates once, shares the promise and disposes after resolve',
        () async {
      final created = <int>[];
      Completer<Object?>? completer;
      final lazy = languages.LazyTokenizationSupport<Object>(() {
        created.add(1);
        completer = Completer<Object?>();
        return completer!.future;
      });
      final first = lazy.tokenizationSupport;
      final second = lazy.tokenizationSupport;
      final expected = _map(truth['lazyTokenization']);
      expect(created.length, expected['createdOnce']);
      expect(identical(first, second), expected['promiseShared']);

      final fake = _DisposableSupport();
      completer!.complete(fake);
      final resolved = await first;
      expect(identical(resolved, fake), expected['resolvedIsSupport']);

      lazy.dispose();
      await Future<void>.delayed(Duration.zero);
      expect(fake.disposed, expected['disposed']);
    });
  });

  group('TokenizationRegistry singleton', () {
    test('is a live TokenizationRegistry with the full API', () {
      final expected = _map(truth['tokenizationRegistry']);
      final registryActual = languages.TokenizationRegistry;
      expect(registryActual, isA<registry.TokenizationRegistry<Object>>());
      expect(registryActual.runtimeType.toString().split('<').first,
          expected['ctorName']);
      expect(registryActual.get('no-such-language'), expected['getUnknown']);
      expect(registryActual.isResolved('no-such-language'),
          expected['isResolvedUnknown']);
      expect(registryActual.getColorMap(), expected['colorMapInitially']);
      expect(registryActual.getDefaultBackground(),
          expected['defaultBackgroundInitially']);
    });
  });
}

/// Picks `keys` out of a JSON map so erased fields don't need to be compared.
Map<String, Object?> _pick(Object? value, List<String> keys) {
  final Map<String, dynamic> source = _map(value);
  return <String, Object?>{
    for (final key in keys) key: source[key],
  };
}

List<int> _rangeOf(IRange range) => <int>[
      range.startLineNumber,
      range.startColumn,
      range.endLineNumber,
      range.endColumn,
    ];

/// TS `TSupport & IDisposable` stand-in.
class _DisposableSupport {
  int disposed = 0;

  void dispose() => disposed += 1;
}