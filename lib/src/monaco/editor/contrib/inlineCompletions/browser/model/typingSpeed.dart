// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/inlineCompletions/browser/model/
//   typingSpeed.ts
// Translated 1:1 from TypeScript.
//
// `Date.now()` is behind an injectable clock so the state machine can be
// replayed deterministically. `ITextModel` / content-change events are erased
// carriers.
// ---------------------------------------------------------------------------

import '../../../../../base/common/arrays.dart' show sum;
import '../../../../../base/common/lifecycle.dart' show Disposable, IDisposable;

/// 1:1: `TypingSession`.
class TypingSession {
  int startTime;
  int endTime;
  int characterCount;

  TypingSession(this.startTime, this.endTime, this.characterCount);

  TypingSession copy() => TypingSession(startTime, endTime, characterCount);
}

/// 1:1: `TypingIntervalResult`.
class TypingIntervalResult {
  final num averageInterval;
  final int characterCount;

  TypingIntervalResult(this.averageInterval, this.characterCount);
}

/// 1:1: content-change event carrier.
abstract class ITypingContentChangedEvent {
  List<Object> get changes;
  List<Object>? get detailedReasons;
}

/// 1:1: `ITextModel` surface used here (opaque carrier).
abstract class ITypingTextModel {
  Object get onDidChangeContent;
}

/// Tracks typing speed as average milliseconds between keystrokes.
class TypingInterval extends Disposable {
  final List<TypingSession> _typingSessions = <TypingSession>[];
  TypingSession? _currentSession;
  int _lastChangeTime = 0;
  TypingIntervalResult? _cachedTypingIntervalResult;
  bool _cacheInvalidated = true;

  /// Injectable clock (defaults to wall-clock ms).
  final int Function() now;

  static const int MAX_SESSION_GAP_MS = 3000;
  static const int MIN_SESSION_DURATION_MS = 1000;
  static const int SESSION_HISTORY_LIMIT = 50;
  static const int TYPING_SPEED_WINDOW_MS = 300000;
  static const int MIN_CHARS_FOR_RELIABLE_SPEED = 20;

  TypingInterval(ITypingTextModel textModel, [int Function()? now])
      : now = now ?? (() => DateTime.now().millisecondsSinceEpoch) {
    final dynamic event = textModel.onDidChangeContent;
    register(event((Object e) => _updateTypingSpeed(e as ITypingContentChangedEvent))
        as IDisposable);
  }

  /// 1:1: `getTypingInterval`.
  TypingIntervalResult getTypingInterval() {
    if (_cacheInvalidated || _cachedTypingIntervalResult == null) {
      _cachedTypingIntervalResult = _calculateTypingInterval();
      _cacheInvalidated = false;
    }
    return _cachedTypingIntervalResult!;
  }

  void _updateTypingSpeed(ITypingContentChangedEvent change) {
    final int currentNow = now();
    if (!_isUserTyping(change)) {
      _finalizeCurrentSession();
      return;
    }
    if (_currentSession != null &&
        (currentNow - _lastChangeTime) > MAX_SESSION_GAP_MS) {
      _finalizeCurrentSession();
    }
    if (_currentSession == null) {
      _currentSession = TypingSession(currentNow, currentNow, 0);
    }
    _currentSession!.endTime = currentNow;
    _currentSession!.characterCount += _getActualCharacterCount(change);
    _lastChangeTime = currentNow;
    _cacheInvalidated = true;
  }

  int _getActualCharacterCount(ITypingContentChangedEvent change) {
    int totalChars = 0;
    for (final Object c in change.changes) {
      final int textLen = c is Map
          ? (c['text'] as String).length
          : (c as dynamic).text.length as int;
      final int rangeLen = c is Map
          ? c['rangeLength'] as int
          : (c as dynamic).rangeLength as int;
      totalChars += textLen > rangeLen ? textLen : rangeLen;
    }
    return totalChars;
  }

  bool _isUserTyping(ITypingContentChangedEvent change) {
    final List<Object>? reasons = change.detailedReasons;
    if (reasons == null || reasons.isEmpty) return false;
    for (final Object reason in reasons) {
      if (_isUserTypingReason(reason)) return true;
    }
    return false;
  }

  bool _isUserTypingReason(Object reason) {
    final dynamic metadata = (reason as dynamic).metadata;
    if (metadata.isUndoing == true || metadata.isRedoing == true) return false;
    final Object? source = metadata.source;
    switch (source) {
      case 'cursor':
        final Object? kind = metadata.kind;
        return kind == 'type' ||
            kind == 'compositionType' ||
            kind == 'compositionEnd';
      default:
        return false;
    }
  }

  void _finalizeCurrentSession() {
    final TypingSession? session = _currentSession;
    if (session == null) return;
    final int duration = session.endTime - session.startTime;
    if (duration >= MIN_SESSION_DURATION_MS && session.characterCount > 0) {
      _typingSessions.add(session);
      if (_typingSessions.length > SESSION_HISTORY_LIMIT) {
        _typingSessions.removeAt(0);
      }
    }
    _currentSession = null;
  }

  TypingIntervalResult _calculateTypingInterval() {
    final TypingSession? session = _currentSession;
    if (session != null) {
      final TypingSession tmp = session.copy();
      final int duration = tmp.endTime - tmp.startTime;
      if (duration >= MIN_SESSION_DURATION_MS && tmp.characterCount > 0) {
        return _calculateSpeedFromSessions(<TypingSession>[
          ..._typingSessions,
          tmp,
        ]);
      }
    }
    return _calculateSpeedFromSessions(_typingSessions);
  }

  TypingIntervalResult _calculateSpeedFromSessions(
    List<TypingSession> sessions,
  ) {
    if (sessions.isEmpty) {
      return TypingIntervalResult(0, 0);
    }
    final List<TypingSession> sorted = List<TypingSession>.from(sessions)
      ..sort((TypingSession a, TypingSession b) => b.endTime - a.endTime);

    final int cutoffTime = now() - TYPING_SPEED_WINDOW_MS;
    final List<TypingSession> recent = <TypingSession>[];
    final List<TypingSession> older = <TypingSession>[];
    for (final TypingSession s in sorted) {
      if (s.endTime > cutoffTime) {
        recent.add(s);
      } else {
        older.add(s);
      }
    }

    num totalChars = sum(recent.map((TypingSession s) => s.characterCount).toList());
    for (int i = 0;
        i < older.length && totalChars < MIN_CHARS_FOR_RELIABLE_SPEED;
        i++) {
      recent.add(older[i]);
      totalChars += older[i].characterCount;
    }

    final num totalTime = sum(
      recent.map((TypingSession s) => s.endTime - s.startTime).toList(),
    );
    if (totalTime == 0 || totalChars <= 1) {
      return TypingIntervalResult(0, totalChars.toInt());
    }
    final num keystrokeIntervals =
        totalChars - 1 > 1 ? totalChars - 1 : 1;
    final num avg = totalTime / keystrokeIntervals;
    return TypingIntervalResult(avg.round(), totalChars.toInt());
  }

  /// 1:1: `reset`.
  void reset() {
    _typingSessions.clear();
    _currentSession = null;
    _lastChangeTime = 0;
    _cachedTypingIntervalResult = null;
    _cacheInvalidated = true;
  }

  @override
  void dispose() {
    _finalizeCurrentSession();
    super.dispose();
  }
}
