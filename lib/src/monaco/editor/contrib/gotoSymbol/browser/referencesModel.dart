// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/gotoSymbol/browser/referencesModel.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Carriers:
//   - `Location` / `LocationLink` (from languages.ts) -> file-local carriers.
//   - `ITextEditorModel` / `IReference` / `ITextModelService` -> narrow carriers.
//   - `IMatch` -> [ReferenceMatch] carrier.
//   - `ResourceMap`, `Emitter`, `extUri`, `Range`/`Position` are reused.
// ---------------------------------------------------------------------------

import '../../../../base/common/errors.dart' show onUnexpectedError;
import '../../../../base/common/event.dart' show Emitter, Event;
import '../../../../base/common/idGenerator.dart' show defaultGenerator;
import '../../../../base/common/lifecycle.dart' show IDisposable, IReference;
import '../../../../base/common/lifecycle.dart' as lifecycle show dispose;
import '../../../../base/common/map.dart' show ResourceMap;
import '../../../../base/common/resources.dart'
    show basename, extUri;
import '../../../../base/common/strings.dart' show commonPrefixLength;
import '../../../../base/common/uint.dart' show Constants;
import '../../../../base/common/uri.dart' show URI;
import '../../../common/core/position.dart' show Position;
import '../../../common/core/range.dart' show IRange, Range;

/// 1:1: `Location` / `LocationLink` carrier (merged: range + optional target).
class ReferenceLocation {
  ReferenceLocation(this.uri, this.range, [this.targetSelectionRange]);
  final URI uri;
  final IRange range;
  final IRange? targetSelectionRange;
}

/// 1:1: `IMatch` carrier.
class ReferenceMatch {
  ReferenceMatch(this.start, this.end);
  final int start;
  final int end;
}

/// 1:1: `ITextEditorModel` narrow carrier (for FilePreview).
abstract class IReferenceTextEditorModel {
  Object? get textEditorModel;

  /// ITextModel subset used by preview.
  Object? getWordUntilPosition(Position position);

  String getValueInRange(IRange range);
}

/// 1:1: `ITextModelService.createModelReference` narrow carrier.
abstract class IReferenceModelService {
  Future<IReference<Object>> createModelReference(URI resource);
}

/// 1:1: `export class OneReference`.
class OneReference {
  OneReference(
    this.isProviderFirst,
    this.parent,
    this.link,
    this._rangeCallback,
  ) : id = defaultGenerator.nextId();

  final String id;
  final bool isProviderFirst;
  final FileReferences parent;
  final ReferenceLocation link;
  final void Function(OneReference) _rangeCallback;

  IRange? _range;

  URI get uri => link.uri;

  IRange get range => _range ?? link.targetSelectionRange ?? link.range;

  set range(IRange value) {
    _range = value;
    _rangeCallback(this);
  }

  /// Simplified ariaMessage (localize carrier: direct templates).
  String get ariaMessage {
    final FilePreview? preview = parent.getPreview(this);
    if (preview == null) {
      return 'in ${basename(uri)} on line ${range.startLineNumber} at column ${range.startColumn}';
    }
    final ReferencePreview? p = preview.preview(range);
    if (p == null) {
      return 'in ${basename(uri)} on line ${range.startLineNumber} at column ${range.startColumn}';
    }
    return '${p.value} in ${basename(uri)} on line ${range.startLineNumber} at column ${range.startColumn}';
  }
}

/// 1:1: preview result `{ value, highlight }`.
class ReferencePreview {
  ReferencePreview(this.value, this.highlight);
  final String value;
  final ReferenceMatch highlight;
}

/// 1:1: `export class FilePreview implements IDisposable`.
class FilePreview implements IDisposable {
  FilePreview(this._modelReference);

  final IReference<Object> _modelReference;

  @override
  void dispose() => _modelReference.dispose();

  /// 1:1: `preview(range, n=8)`.
  ReferencePreview? preview(IRange range, [int n = 8]) {
    final dynamic model = _modelReference.object;
    if (model == null) return null;
    final IReferenceTextEditorModel m = model as IReferenceTextEditorModel;

    final int startLineNumber = range.startLineNumber;
    final int startColumn = range.startColumn;
    final int endLineNumber = range.endLineNumber;
    final int endColumn = range.endColumn;
    final Object word =
        m.getWordUntilPosition(Position(startLineNumber, startColumn - n))!;
    final int wordStartColumn = (word as dynamic).startColumn as int;
    final IRange beforeRange =
        Range(startLineNumber, wordStartColumn, startLineNumber, startColumn);
    final IRange afterRange = Range(
        endLineNumber, endColumn, endLineNumber, Constants.MAX_SAFE_SMALL_INTEGER);

    final String before = m.getValueInRange(beforeRange).replaceFirst(RegExp(r'^\s+'), '');
    final String inside = m.getValueInRange(range);
    final String after = m.getValueInRange(afterRange).replaceFirst(RegExp(r'\s+$'), '');

    return ReferencePreview(before + inside + after,
        ReferenceMatch(before.length, before.length + inside.length));
  }
}

/// 1:1: `export class FileReferences implements IDisposable`.
class FileReferences implements IDisposable {
  FileReferences(this.parent, this.uri);

  final ReferencesModel parent;
  final URI uri;
  final List<OneReference> children = <OneReference>[];
  final ResourceMap<FilePreview> _previews = ResourceMap<FilePreview>();

  @override
  void dispose() {
    lifecycle.dispose(_previews.values().toList());
    _previews.clear();
  }

  FilePreview? getPreview(OneReference child) => _previews.get(child.uri);

  String get ariaMessage {
    final int len = children.length;
    if (len == 1) {
      return '1 symbol in ${basename(uri)}, full path ${uri.fsPath}';
    }
    return '$len symbols in ${basename(uri)}, full path ${uri.fsPath}';
  }

  /// 1:1: `resolve(textModelResolverService)`.
  Future<FileReferences> resolve(IReferenceModelService service) async {
    if (_previews.size != 0) return this;
    for (final OneReference child in children) {
      if (_previews.has(child.uri)) continue;
      try {
        final IReference<Object> ref =
            await service.createModelReference(child.uri);
        _previews.set(child.uri, FilePreview(ref));
      } catch (err) {
        onUnexpectedError(err);
      }
    }
    return this;
  }
}

/// 1:1: `export class ReferencesModel implements IDisposable`.
class ReferencesModel implements IDisposable {
  ReferencesModel(List<ReferenceLocation> links, this._title)
      : _links = links {
    // grouping and sorting
    // TS `const [providersFirst] = links` yields undefined for an empty list.
    final ReferenceLocation? providersFirst =
        links.isNotEmpty ? links[0] : null;
    links.sort(_compareReferences);

    FileReferences? current;
    for (final ReferenceLocation link in links) {
      if (current == null || !extUri.isEqual(current.uri, link.uri, true)) {
        current = FileReferences(this, link.uri);
        groups.add(current);
      }
      if (current.children.isEmpty ||
          _compareReferences(link, current.children.last.link) != 0) {
        final OneReference oneRef = OneReference(
          identical(providersFirst, link),
          current,
          link,
          (ref) => _onDidChangeReferenceRange.fire(ref),
        );
        references.add(oneRef);
        current.children.add(oneRef);
      }
    }
  }

  final List<ReferenceLocation> _links;
  final String _title;
  final List<FileReferences> groups = <FileReferences>[];
  final List<OneReference> references = <OneReference>[];

  final Emitter<OneReference> _onDidChangeReferenceRange =
      Emitter<OneReference>();
  late final Event<OneReference> onDidChangeReferenceRange =
      _onDidChangeReferenceRange.event;

  @override
  void dispose() {
    lifecycle.dispose(groups);
    _onDidChangeReferenceRange.dispose();
    groups.clear();
  }

  ReferencesModel clone() => ReferencesModel(_links, _title);

  String get title => _title;

  bool get isEmpty => groups.isEmpty;

  String get ariaMessage {
    if (isEmpty) return 'No results found';
    if (references.length == 1) {
      return 'Found 1 symbol in ${references[0].uri.fsPath}';
    }
    if (groups.length == 1) {
      return 'Found ${references.length} symbols in ${groups[0].uri.fsPath}';
    }
    return 'Found ${references.length} symbols in ${groups.length} files';
  }

  /// 1:1: `nextOrPreviousReference(reference, next)`.
  OneReference nextOrPreviousReference(OneReference reference, bool next) {
    final FileReferences parent = reference.parent;
    int idx = parent.children.indexOf(reference);
    final int childCount = parent.children.length;
    final int groupCount = parent.parent.groups.length;

    if (groupCount == 1 ||
        (next && idx + 1 < childCount) ||
        (!next && idx > 0)) {
      if (next) {
        idx = (idx + 1) % childCount;
      } else {
        idx = (idx + childCount - 1) % childCount;
      }
      return parent.children[idx];
    }

    idx = parent.parent.groups.indexOf(parent);
    if (next) {
      idx = (idx + 1) % groupCount;
      return parent.parent.groups[idx].children[0];
    } else {
      idx = (idx + groupCount - 1) % groupCount;
      final List<OneReference> children = parent.parent.groups[idx].children;
      return children[children.length - 1];
    }
  }

  /// 1:1: `nearestReference(resource, position)`.
  OneReference? nearestReference(URI resource, Position position) {
    final List<Map<String, Object?>> scored = references.asMap().entries.map((e) {
      final int idx = e.key;
      final OneReference ref = e.value;
      return <String, Object?>{
        'idx': idx,
        'prefixLen': commonPrefixLength(ref.uri.toString(), resource.toString()),
        'offsetDist': (ref.range.startLineNumber - position.lineNumber).abs() * 100 +
            (ref.range.startColumn - position.column).abs(),
      };
    }).toList();
    scored.sort((a, b) {
      final int pa = a['prefixLen'] as int;
      final int pb = b['prefixLen'] as int;
      final int da = a['offsetDist'] as int;
      final int db = b['offsetDist'] as int;
      if (pa > pb) return -1;
      if (pa < pb) return 1;
      if (da < db) return -1;
      if (da > db) return 1;
      return 0;
    });
    if (scored.isNotEmpty) {
      return references[scored[0]['idx'] as int];
    }
    return null;
  }

  /// 1:1: `referenceAt(resource, position)`.
  OneReference? referenceAt(URI resource, Position position) {
    for (final OneReference ref in references) {
      if (ref.uri.toString() == resource.toString()) {
        if (Range.containsPositionStatic(ref.range, position)) {
          return ref;
        }
      }
    }
    return null;
  }

  /// 1:1: `firstReference()`.
  OneReference? firstReference() {
    for (final OneReference ref in references) {
      if (ref.isProviderFirst) return ref;
    }
    return references.isNotEmpty ? references[0] : null;
  }

  /// 1:1: `static _compareReferences(a, b)`.
  static int _compareReferences(ReferenceLocation a, ReferenceLocation b) =>
      extUri.compare(a.uri, b.uri) == 0
          ? Range.compareRangesUsingStarts(a.range, b.range)
          : extUri.compare(a.uri, b.uri);
}
