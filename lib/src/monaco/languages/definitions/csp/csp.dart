// 1:1 translation of monaco-editor/src/languages/definitions/csp/csp.ts
// Monarch language definition data, evaluated from the TS source via
// the TypeScript compiler (computed template/const values resolved).
// TS object literals -> Dart data; typed rule/action/bracket carriers
// mirror the ported monarchCompile. Regex flags preserved in RegExp.

import 'package:semi_design_flutter/src/monaco/editor/standalone/common/monarch/monarchTypes.dart';

/// 1:1: `export const conf: languages.LanguageConfiguration = {...}`
final Map<String, Object?> conf = <String, Object?>{
  'autoClosingPairs': <Object?>[],
  'brackets': <Object?>[],
  'surroundingPairs': <Object?>[],
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('child-src'),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('connect-src'),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('default-src'),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('font-src'),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('frame-src'),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('img-src'),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('manifest-src'),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('media-src'),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('object-src'),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('script-src'),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('style-src'),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('worker-src'),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('base-uri'),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('plugin-types'),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('sandbox'),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('disown-opener'),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('form-action'),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('frame-ancestors'),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('report-uri'),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('report-to'),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('upgrade-insecure-requests'),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('block-all-mixed-content'),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('require-sri-for'),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('reflected-xss'),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('referrer'),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('policy-uri'),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'self\''),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'unsafe-inline\''),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'unsafe-eval\''),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'strict-dynamic\''),
        IShortActionCarrier('string.quote'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'unsafe-hashed-attributes\''),
        IShortActionCarrier('string.quote'),
      ),
      ],
  },
  tokenPostfix: '.csp',
  extra: <String, Object?>{
      'escapes': RegExp('\\\\(?:[abfnrtv\\\\"\']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})'),
      'keywords': <Object?>[],
      'operators': <Object?>[],
      'symbols': RegExp('[=><!~?:&|+\\-*\\/\\^%]+'),
      'typeKeywords': <Object?>[],
    },
);
