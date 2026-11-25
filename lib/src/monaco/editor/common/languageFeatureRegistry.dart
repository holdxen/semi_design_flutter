// 1:1 port of vs/editor/common/languageFeatureRegistry.ts
// Adaptations:
//   - `ITextModel` is an opaque carrier exposing only the members consumed
//     here; `shouldSynchronizeModel` is reproduced locally.
//   - `LanguageSelector` selectors are `Object?` (String / LanguageFilter /
//     Map literal / List) exactly as in languageSelector.dart.
//   - TS `Object.freeze`/readonly fields are Dart final fields.
// Runtime truth: tool/ts2dart/_batch264_truth.cjs (recursive TS transpile+vm).

import '../../base/common/event.dart' show Emitter, Event;
import '../../base/common/lifecycle.dart' show IDisposable, toDisposable;
import '../../base/common/uri.dart' show URI;
import './languageSelector.dart'
    show LanguageFilter, LanguageSelector, score, selectLanguageIds;

/// 1:1: `NotebookInfo`
class NotebookInfo {
  final URI uri;
  final String type;

  const NotebookInfo(this.uri, this.type);
}

/// 1:1: `NotebookInfoResolver`
typedef NotebookInfoResolver = NotebookInfo? Function(URI uri);

/// 1:1: erased `ITextModel` members consumed by this registry.
abstract class ILanguageFeatureModel {
  URI get uri;
  String getLanguageId();
  bool isTooLargeForSyncing();
  bool get isForSimpleWidget;
}

/// 1:1: `shouldSynchronizeModel(model)` from model.ts (pending)
bool _shouldSynchronizeModel(ILanguageFeatureModel model) =>
    !model.isTooLargeForSyncing() && !model.isForSimpleWidget;

class _Entry<T> {
  final LanguageSelector selector;
  final T provider;
  int _score;
  final int _time;

  _Entry(this.selector, this.provider, this._score, this._time);
}

class _MatchCandidate {
  final URI uri;
  final String languageId;
  final URI? notebookUri;
  final String? notebookType;
  final bool recursive;

  const _MatchCandidate(
    this.uri,
    this.languageId,
    this.notebookUri,
    this.notebookType,
    this.recursive,
  );

  bool equals(_MatchCandidate other) =>
      notebookType == other.notebookType &&
      languageId == other.languageId &&
      uri.toString() == other.uri.toString() &&
      notebookUri?.toString() == other.notebookUri?.toString() &&
      recursive == other.recursive;
}

bool? _filterFlag(Object? filter, String name) {
  if (filter is LanguageFilter) {
    return name == 'exclusive' ? filter.exclusive : filter.isBuiltin;
  }
  if (filter is Map) {
    return filter[name] as bool?;
  }
  return null;
}

/// 1:1: `isExclusive(selector)`
bool _isExclusive(LanguageSelector selector) {
  if (selector is String) {
    return false;
  } else if (selector is List) {
    return selector.every(_isExclusive);
  }
  return _filterFlag(selector, 'exclusive') ?? false;
}

/// 1:1: `isBuiltinSelector(selector)`
bool _isBuiltinSelector(LanguageSelector selector) {
  if (selector is String) {
    return false;
  }
  if (selector is List) {
    return selector.any(_isBuiltinSelector);
  }
  return _filterFlag(selector, 'isBuiltin') ?? false;
}

/// 1:1: `LanguageFeatureRegistry<T>`
class LanguageFeatureRegistry<T> {
  int _clock = 0;
  final List<_Entry<T>> _entries = <_Entry<T>>[];
  final NotebookInfoResolver? _notebookInfoResolver;

  final Emitter<int> _onDidChange = Emitter<int>();
  late final Event<int> onDidChange = _onDidChange.event;

  LanguageFeatureRegistry([this._notebookInfoResolver]);

  /// 1:1: `register(selector, provider)`
  IDisposable register(LanguageSelector selector, T provider) {
    final _Entry<T> created = _Entry<T>(selector, provider, -1, _clock++);
    _Entry<T>? entry = created;
    _entries.add(created);
    _lastCandidate = null;
    _onDidChange.fire(_entries.length);

    return toDisposable(() {
      if (entry != null) {
        final int idx = _entries.indexOf(entry!);
        if (idx >= 0) {
          _entries.removeAt(idx);
          _lastCandidate = null;
          _onDidChange.fire(_entries.length);
          entry = null;
        }
      }
    });
  }

  /// 1:1: `has(model)`
  bool has(ILanguageFeatureModel? model) => all(model).isNotEmpty;

  /// 1:1: `hasForResource(uri, languageId)`
  bool hasForResource(URI uri, String languageId) {
    final NotebookInfo? notebook = _notebookInfoResolver?.call(uri);
    return _entries.any((_Entry<T> entry) =>
        score(entry.selector, uri, languageId, true,
            notebook?.uri, notebook?.type) >
        0);
  }

  /// 1:1: `all(model)`
  List<T> all(ILanguageFeatureModel? model) {
    if (model == null) {
      return <T>[];
    }
    _updateScores(model, false);
    final List<T> result = <T>[];
    for (final _Entry<T> entry in _entries) {
      if (entry._score > 0) {
        result.add(entry.provider);
      }
    }
    return result;
  }

  /// 1:1: `allNoModel()`
  List<T> allNoModel() => _entries.map((e) => e.provider).toList();

  /// 1:1: `registeredLanguageIds`
  Set<String> get registeredLanguageIds {
    final Set<String> result = <String>{};
    for (final _Entry<T> entry in _entries) {
      selectLanguageIds(entry.selector, result);
    }
    return result;
  }

  /// 1:1: `ordered(model, recursive = false)`
  List<T> ordered(ILanguageFeatureModel model, [bool recursive = false]) {
    final List<T> result = <T>[];
    _orderedForEach(model, recursive, (entry) => result.add(entry.provider));
    return result;
  }

  /// 1:1: `orderedGroups(model)`
  List<List<T>> orderedGroups(ILanguageFeatureModel model) {
    final List<List<T>> result = <List<T>>[];
    List<T>? lastBucket;
    int? lastBucketScore;

    _orderedForEach(model, false, (_Entry<T> entry) {
      if (lastBucket != null && lastBucketScore == entry._score) {
        lastBucket!.add(entry.provider);
      } else {
        lastBucketScore = entry._score;
        lastBucket = <T>[entry.provider];
        result.add(lastBucket!);
      }
    });

    return result;
  }

  void _orderedForEach(ILanguageFeatureModel model, bool recursive,
      void Function(_Entry<T> entry) callback) {
    _updateScores(model, recursive);
    for (final _Entry<T> entry in _entries) {
      if (entry._score > 0) {
        callback(entry);
      }
    }
  }

  _MatchCandidate? _lastCandidate;

  void _updateScores(ILanguageFeatureModel model, bool recursive) {
    final NotebookInfo? notebookInfo = _notebookInfoResolver?.call(model.uri);
    final _MatchCandidate candidate = notebookInfo != null
        ? _MatchCandidate(model.uri, model.getLanguageId(), notebookInfo.uri,
            notebookInfo.type, recursive)
        : _MatchCandidate(
            model.uri, model.getLanguageId(), null, null, recursive);

    if (_lastCandidate?.equals(candidate) ?? false) {
      return;
    }
    _lastCandidate = candidate;

    outer: for (final _Entry<T> entry in _entries) {
      entry._score = score(
        entry.selector,
        candidate.uri,
        candidate.languageId,
        _shouldSynchronizeModel(model),
        candidate.notebookUri,
        candidate.notebookType,
      );

      if (_isExclusive(entry.selector) && entry._score > 0) {
        if (recursive) {
          entry._score = 0;
        } else {
          for (final _Entry<T> other in _entries) {
            other._score = 0;
          }
          entry._score = 1000;
          break outer;
        }
      }
    }

    _entries.sort(_compareByScoreAndTime);
  }

  static int _compareByScoreAndTime(_Entry<Object?> a, _Entry<Object?> b) {
    if (a._score < b._score) {
      return 1;
    } else if (a._score > b._score) {
      return -1;
    }

    if (_isBuiltinSelector(a.selector) && !_isBuiltinSelector(b.selector)) {
      return 1;
    } else if (!_isBuiltinSelector(a.selector) &&
        _isBuiltinSelector(b.selector)) {
      return -1;
    }

    if (a._time < b._time) {
      return 1;
    } else if (a._time > b._time) {
      return -1;
    }
    return 0;
  }
}
