// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/date.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. JS `Intl.*` has no Dart equivalent:
// minimal carrier classes keep the source API shape (`Collator.compare`,
// `Locale.baseName`) and the try/catch fallback control flow is identical.
// `Date` -> `DateTime`; `Date.now()` -> `DateTime.now().millisecondsSinceEpoch`.
// ---------------------------------------------------------------------------

import '../../nls.dart';
import './lazy.dart';
import './platform.dart';

const int minute = 60;
const int hour = minute * 60;
const int day = hour * 24;
const int week = day * 7;
const int month = day * 30;
const int year = day * 365;

int _now() => DateTime.now().millisecondsSinceEpoch;

/// Returns the absolute expiration time for a relative lifetime in seconds.
num? getExpirationTime(num? expiresIn, [num? now]) {
  final num n = now ?? _now();
  return expiresIn == null ? null : n + expiresIn * 1000;
}

/// Returns whether a known expiration time has passed.
bool isExpired(num? expiresAt, [num? now]) {
  final num n = now ?? _now();
  return expiresAt != null && expiresAt <= n;
}

/// Returns the positive number of whole seconds until `expiresAt`, rounded up.
num? getRemainingTimeInSeconds(num? expiresAt, [num? now]) {
  final num n = now ?? _now();
  if (expiresAt == null) {
    return null;
  }
  final num remaining = ((expiresAt - n) / 1000).ceil();
  return remaining > 0 ? remaining : null;
}

/// Create a localized difference of the time between now and the specified date.
String fromNow(Object? date, [bool? appendAgoLabel, bool? useFullTimeWords, bool? disallowNow]) {
  if (date == null) {
    return localize('date.fromNow.unknown', 'unknown');
  }

  num dateMs;
  if (date is num) {
    dateMs = date;
  } else {
    dateMs = (date as DateTime).millisecondsSinceEpoch;
  }

  final num seconds = ((_now() - dateMs) / 1000).round();
  if (seconds < -30) {
    return localize('date.fromNow.in', 'in {0}', <Object?>[fromNow(_now() + seconds * 1000, false, useFullTimeWords, disallowNow)]);
  }

  if (disallowNow != true && seconds < 30) {
    return localize('date.fromNow.now', 'now');
  }

  late final num value;
  if (seconds < minute) {
    value = seconds;

    if (appendAgoLabel == true) {
      if (value == 1) {
        return useFullTimeWords == true
            ? localize('date.fromNow.seconds.singular.ago.fullWord', '{0} second ago', <Object?>[value])
            : localize('date.fromNow.seconds.singular.ago', '{0} sec ago', <Object?>[value]);
      } else {
        return useFullTimeWords == true
            ? localize('date.fromNow.seconds.plural.ago.fullWord', '{0} seconds ago', <Object?>[value])
            : localize('date.fromNow.seconds.plural.ago', '{0} secs ago', <Object?>[value]);
      }
    } else {
      if (value == 1) {
        return useFullTimeWords == true
            ? localize('date.fromNow.seconds.singular.fullWord', '{0} second', <Object?>[value])
            : localize('date.fromNow.seconds.singular', '{0} sec', <Object?>[value]);
      } else {
        return useFullTimeWords == true
            ? localize('date.fromNow.seconds.plural.fullWord', '{0} seconds', <Object?>[value])
            : localize('date.fromNow.seconds.plural', '{0} secs', <Object?>[value]);
      }
    }
  }

  if (seconds < hour) {
    value = (seconds / minute).round();
    if (appendAgoLabel == true) {
      if (value == 1) {
        return useFullTimeWords == true
            ? localize('date.fromNow.minutes.singular.ago.fullWord', '{0} minute ago', <Object?>[value])
            : localize('date.fromNow.minutes.singular.ago', '{0} min ago', <Object?>[value]);
      } else {
        return useFullTimeWords == true
            ? localize('date.fromNow.minutes.plural.ago.fullWord', '{0} minutes ago', <Object?>[value])
            : localize('date.fromNow.minutes.plural.ago', '{0} mins ago', <Object?>[value]);
      }
    } else {
      if (value == 1) {
        return useFullTimeWords == true
            ? localize('date.fromNow.minutes.singular.fullWord', '{0} minute', <Object?>[value])
            : localize('date.fromNow.minutes.singular', '{0} min', <Object?>[value]);
      } else {
        return useFullTimeWords == true
            ? localize('date.fromNow.minutes.plural.fullWord', '{0} minutes', <Object?>[value])
            : localize('date.fromNow.minutes.plural', '{0} mins', <Object?>[value]);
      }
    }
  }

  if (seconds < day) {
    value = (seconds / hour).round();
    if (appendAgoLabel == true) {
      if (value == 1) {
        return useFullTimeWords == true
            ? localize('date.fromNow.hours.singular.ago.fullWord', '{0} hour ago', <Object?>[value])
            : localize('date.fromNow.hours.singular.ago', '{0} hr ago', <Object?>[value]);
      } else {
        return useFullTimeWords == true
            ? localize('date.fromNow.hours.plural.ago.fullWord', '{0} hours ago', <Object?>[value])
            : localize('date.fromNow.hours.plural.ago', '{0} hrs ago', <Object?>[value]);
      }
    } else {
      if (value == 1) {
        return useFullTimeWords == true
            ? localize('date.fromNow.hours.singular.fullWord', '{0} hour', <Object?>[value])
            : localize('date.fromNow.hours.singular', '{0} hr', <Object?>[value]);
      } else {
        return useFullTimeWords == true
            ? localize('date.fromNow.hours.plural.fullWord', '{0} hours', <Object?>[value])
            : localize('date.fromNow.hours.plural', '{0} hrs', <Object?>[value]);
      }
    }
  }

  if (seconds < week) {
    value = (seconds / day).round();
    if (appendAgoLabel == true) {
      return value == 1
          ? localize('date.fromNow.days.singular.ago', '{0} day ago', <Object?>[value])
          : localize('date.fromNow.days.plural.ago', '{0} days ago', <Object?>[value]);
    } else {
      return value == 1
          ? localize('date.fromNow.days.singular', '{0} day', <Object?>[value])
          : localize('date.fromNow.days.plural', '{0} days', <Object?>[value]);
    }
  }

  if (seconds < month) {
    value = (seconds / week).round();
    if (appendAgoLabel == true) {
      if (value == 1) {
        return useFullTimeWords == true
            ? localize('date.fromNow.weeks.singular.ago.fullWord', '{0} week ago', <Object?>[value])
            : localize('date.fromNow.weeks.singular.ago', '{0} wk ago', <Object?>[value]);
      } else {
        return useFullTimeWords == true
            ? localize('date.fromNow.weeks.plural.ago.fullWord', '{0} weeks ago', <Object?>[value])
            : localize('date.fromNow.weeks.plural.ago', '{0} wks ago', <Object?>[value]);
      }
    } else {
      if (value == 1) {
        return useFullTimeWords == true
            ? localize('date.fromNow.weeks.singular.fullWord', '{0} week', <Object?>[value])
            : localize('date.fromNow.weeks.singular', '{0} wk', <Object?>[value]);
      } else {
        return useFullTimeWords == true
            ? localize('date.fromNow.weeks.plural.fullWord', '{0} weeks', <Object?>[value])
            : localize('date.fromNow.weeks.plural', '{0} wks', <Object?>[value]);
      }
    }
  }

  if (seconds < year) {
    value = (seconds / month).round();
    if (appendAgoLabel == true) {
      if (value == 1) {
        return useFullTimeWords == true
            ? localize('date.fromNow.months.singular.ago.fullWord', '{0} month ago', <Object?>[value])
            : localize('date.fromNow.months.singular.ago', '{0} mo ago', <Object?>[value]);
      } else {
        return useFullTimeWords == true
            ? localize('date.fromNow.months.plural.ago.fullWord', '{0} months ago', <Object?>[value])
            : localize('date.fromNow.months.plural.ago', '{0} mos ago', <Object?>[value]);
      }
    } else {
      if (value == 1) {
        return useFullTimeWords == true
            ? localize('date.fromNow.months.singular.fullWord', '{0} month', <Object?>[value])
            : localize('date.fromNow.months.singular', '{0} mo', <Object?>[value]);
      } else {
        return useFullTimeWords == true
            ? localize('date.fromNow.months.plural.fullWord', '{0} months', <Object?>[value])
            : localize('date.fromNow.months.plural', '{0} mos', <Object?>[value]);
      }
    }
  }

  value = (seconds / year).round();
  if (appendAgoLabel == true) {
    if (value == 1) {
      return useFullTimeWords == true
          ? localize('date.fromNow.years.singular.ago.fullWord', '{0} year ago', <Object?>[value])
          : localize('date.fromNow.years.singular.ago', '{0} yr ago', <Object?>[value]);
    } else {
      return useFullTimeWords == true
          ? localize('date.fromNow.years.plural.ago.fullWord', '{0} years ago', <Object?>[value])
          : localize('date.fromNow.years.plural.ago', '{0} yrs ago', <Object?>[value]);
    }
  } else {
    if (value == 1) {
      return useFullTimeWords == true
          ? localize('date.fromNow.years.singular.fullWord', '{0} year', <Object?>[value])
          : localize('date.fromNow.years.singular', '{0} yr', <Object?>[value]);
    } else {
      return useFullTimeWords == true
          ? localize('date.fromNow.years.plural.fullWord', '{0} years', <Object?>[value])
          : localize('date.fromNow.years.plural', '{0} yrs', <Object?>[value]);
    }
  }
}

String fromNowByDay(Object? date, [bool? appendAgoLabel, bool? useFullTimeWords]) {
  num dateMs;
  if (date is num) {
    dateMs = date;
  } else {
    dateMs = (date as DateTime).millisecondsSinceEpoch;
  }

  final DateTime todayMidnightTime = DateTime.now();
  final DateTime today = DateTime(todayMidnightTime.year, todayMidnightTime.month, todayMidnightTime.day);
  final DateTime yesterday = today.subtract(const Duration(days: 1));

  if (dateMs > today.millisecondsSinceEpoch) {
    return localize('today', 'Today');
  }

  if (dateMs > yesterday.millisecondsSinceEpoch) {
    return localize('yesterday', 'Yesterday');
  }

  return fromNow(dateMs, appendAgoLabel, useFullTimeWords);
}

/// Gets a readable duration with intelligent/lossy precision. For example "40ms" or "3.040s")
String getDurationString(num ms, [bool? useFullTimeWords]) {
  final num seconds = (ms / 1000).abs();
  if (seconds < 1) {
    return useFullTimeWords == true
        ? localize('duration.ms.full', '{0} milliseconds', <Object?>[ms])
        : localize('duration.ms', '{0}ms', <Object?>[ms]);
  }
  if (seconds < minute) {
    return useFullTimeWords == true
        ? localize('duration.s.full', '{0} seconds', <Object?>[ms.round() / 1000])
        : localize('duration.s', '{0}s', <Object?>[ms.round() / 1000]);
  }
  if (seconds < hour) {
    return useFullTimeWords == true
        ? localize('duration.m.full', '{0} minutes', <Object?>[(ms / (1000 * minute)).round()])
        : localize('duration.m', '{0} mins', <Object?>[(ms / (1000 * minute)).round()]);
  }
  if (seconds < day) {
    return useFullTimeWords == true
        ? localize('duration.h.full', '{0} hours', <Object?>[(ms / (1000 * hour)).round()])
        : localize('duration.h', '{0} hrs', <Object?>[(ms / (1000 * hour)).round()]);
  }
  return localize('duration.d', '{0} days', <Object?>[(ms / (1000 * day)).round()]);
}

String toLocalISOString(DateTime date) {
  return '${date.year}' +
      '-' + date.month.toString().padLeft(2, '0') +
      '-' + date.day.toString().padLeft(2, '0') +
      'T' + date.hour.toString().padLeft(2, '0') +
      ':' + date.minute.toString().padLeft(2, '0') +
      ':' + date.second.toString().padLeft(2, '0') +
      '.' + (date.millisecond / 1000).toStringAsFixed(3).substring(2, 5) +
      'Z';
}

// --- Minimal Intl carriers (Dart has no `dart:js` Intl equivalents) ---------

class IntlDateTimeFormat {
  IntlDateTimeFormat(Object? locales, [Object? options]);
}

class IntlCollatorOptions {
  final bool numeric;
  IntlCollatorOptions(this.numeric);
}

class IntlCollator {
  final IntlCollatorOptions _options;
  IntlCollator(Object? locales, [Object? options])
      : _options = IntlCollatorOptions(options is Map && options['numeric'] == true);

  /// Approximates JS `Intl.Collator.compare`: code-unit ordering with an
  /// optional numeric sort (digit runs compared by value). Full ICU locale
  /// collation has no Dart-stdlib equivalent; the source's own disambiguation
  /// logic resolves the ties this leaves (foo1/foo01, case, accents).
  int compare(String a, String b) {
    if (!_options.numeric) {
      return a.compareTo(b);
    }
    final List<Object> at = _splitNumeric(a);
    final List<Object> bt = _splitNumeric(b);
    final int n = at.length < bt.length ? at.length : bt.length;
    for (int i = 0; i < n; i++) {
      final Object x = at[i];
      final Object y = bt[i];
      int c;
      if (x is int && y is int) {
        c = x.compareTo(y);
      } else {
        c = x.toString().compareTo(y.toString());
      }
      if (c != 0) {
        return c < 0 ? -1 : 1;
      }
    }
    return at.length == bt.length ? 0 : (at.length < bt.length ? -1 : 1);
  }

  static List<Object> _splitNumeric(String s) {
    final List<Object> parts = <Object>[];
    final RegExp re = RegExp(r'\d+|\D+');
    for (final RegExpMatch m in re.allMatches(s)) {
      final String token = m.group(0)!;
      final int? value = int.tryParse(token);
      parts.add(value ?? token);
    }
    return parts;
  }

  IntlCollatorOptions resolvedOptions() => _options;
}

class IntlSegmenter {
  IntlSegmenter(Object? locales, [Object? options]);
}

class IntlLocale {
  final String tag;
  IntlLocale(Object? tag, [Object? options]) : tag = _resolveTag(tag);

  /// JS `Intl.Locale` throws on tags using `_` instead of `-` (e.g. `en_IT`),
  /// which is exactly what drives `safeIntl.Locale`'s fallback in the tests.
  static String _resolveTag(Object? tag) {
    final String t = tag as String? ?? LANGUAGE_DEFAULT;
    if (t.contains('_')) {
      throw ArgumentError.value(t, 'tag', 'Invalid language tag');
    }
    return t;
  }

  String get baseName => tag;
}

class IntlNumberFormat {
  IntlNumberFormat(Object? locales, [Object? options]);
}

final safeIntl = _SafeIntl();

class _SafeIntl {
  Lazy<IntlDateTimeFormat> DateTimeFormat([Object? locales, Object? options]) {
    return Lazy<IntlDateTimeFormat>(() {
      try {
        return IntlDateTimeFormat(locales, options);
      } catch (_) {
        return IntlDateTimeFormat(null, options);
      }
    });
  }

  Lazy<IntlCollator> Collator([Object? locales, Object? options]) {
    return Lazy<IntlCollator>(() {
      try {
        return IntlCollator(locales, options);
      } catch (_) {
        return IntlCollator(null, options);
      }
    });
  }

  Lazy<IntlSegmenter> Segmenter([Object? locales, Object? options]) {
    return Lazy<IntlSegmenter>(() {
      try {
        return IntlSegmenter(locales, options);
      } catch (_) {
        return IntlSegmenter(null, options);
      }
    });
  }

  Lazy<IntlLocale> Locale(Object? tag, [Object? options]) {
    return Lazy<IntlLocale>(() {
      try {
        return IntlLocale(tag, options);
      } catch (_) {
        return IntlLocale(LANGUAGE_DEFAULT, options);
      }
    });
  }

  Lazy<IntlNumberFormat> NumberFormat([Object? locales, Object? options]) {
    return Lazy<IntlNumberFormat>(() {
      try {
        return IntlNumberFormat(locales, options);
      } catch (_) {
        return IntlNumberFormat(null, options);
      }
    });
  }
}
