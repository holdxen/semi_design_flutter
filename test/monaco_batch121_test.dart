import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart' as dom;
import 'package:semi_design_flutter/src/monaco/base/browser/domSanitize.dart' as ds;
import 'package:semi_design_flutter/src/monaco/base/browser/trustedTypes.dart'
    as trustedTypes;

final Map<String, dynamic> _truth =
    jsonDecode(File('tool/ts2dart/batch121_truth.json').readAsStringSync())
        as Map<String, dynamic>;

Map<String, dynamic> _section(String name) =>
    (_truth[name] as Map).cast<String, dynamic>();

/// Recording DOMPurify carrier. Keeps hook functions even after
/// `removeAllHooks` (the `finally` in doSanitizeHtml clears the live set).
class _RecordingPurify {
  final List<String> addHookCalls = <String>[];
  final Map<String, ds.DomPurifyHook> liveHooks = <String, ds.DomPurifyHook>{};
  final Map<String, ds.DomPurifyHook> allHooks = <String, ds.DomPurifyHook>{};
  final List<Map<String, Object?>> sanitizeCalls =
      <Map<String, Object?>>[];
  int removeAllHooksCount = 0;
  Object Function(String html, Map<String, Object?> config)? sanitizeOverride;

  late final ds.DomPurifyApi api = ds.DomPurifyApi(
    addHook: (String name, ds.DomPurifyHook hook) {
      addHookCalls.add(name);
      liveHooks[name] = hook;
      allHooks[name] = hook;
    },
    removeAllHooks: () {
      removeAllHooksCount++;
      liveHooks.clear();
    },
    sanitize: (String html, Map<String, Object?> config) {
      sanitizeCalls.add(<String, Object?>{'html': html, 'cfg': config});
      final Object Function(String, Map<String, Object?>)? o = sanitizeOverride;
      if (o != null) return o(html, config);
      return 'SANITIZED:$html';
    },
  );

  void reset() {
    addHookCalls.clear();
    liveHooks.clear();
    allHooks.clear();
    sanitizeCalls.clear();
    removeAllHooksCount = 0;
    sanitizeOverride = null;
  }

  Map<String, Object?> lastConfig() =>
      (sanitizeCalls.last['cfg'] as Map).cast<String, Object?>();
}

final _RecordingPurify _purify = _RecordingPurify();

class _DomComment extends dom.DomNode {
  _DomComment(this.data) : super(8);
  final String data;
  String get textContent => data;
  @override
  String toString() => data;
}

Map<String, Object?> _cfgSnapshot(Map<String, Object?> cfg) {
  final Object? tags = cfg['ALLOWED_TAGS'];
  final Object? attrs = cfg['ALLOWED_ATTR'];
  return <String, Object?>{
    'ALLOWED_TAGS': tags == null ? null : List<Object?>.from(tags as List),
    'ALLOWED_ATTR': attrs == null ? null : List<Object?>.from(attrs as List),
    'ALLOW_UNKNOWN_PROTOCOLS': cfg['ALLOW_UNKNOWN_PROTOCOLS'],
    'RETURN_DOM_FRAGMENT': cfg['RETURN_DOM_FRAGMENT'] ?? false,
    'RETURN_TRUSTED_TYPE': cfg['RETURN_TRUSTED_TYPE'] ?? false,
    'TRUSTED_TYPES_POLICY': cfg['TRUSTED_TYPES_POLICY'] != null ? 'present' : null,
  };
}

void _expectMap(Object? actual, Object? expected, String label) {
  if (expected is Map) {
    expect(actual, isA<Map>(), reason: label);
    final Map act = actual as Map;
    for (final key in expected.keys) {
      _expectMap(act[key], expected[key], '$label.$key');
    }
  } else if (expected is List) {
    expect(actual, isA<List>(), reason: label);
    final List act = actual as List;
    expect(act.length, expected.length, reason: '$label.length');
    for (int i = 0; i < act.length; i++) {
      _expectMap(act[i], expected[i], '$label[$i]');
    }
  } else {
    expect(actual, expected, reason: label);
  }
}

void main() {
  setUp(() {
    _purify.reset();
    ds.dompurifyProvider = _purify.api;
    ds.resetProvider = null;
    trustedTypes.createTrustedTypesPolicyProvider = null;
  });
  tearDown(() {
    ds.dompurifyProvider = null;
    ds.resetProvider = null;
    trustedTypes.createTrustedTypesPolicyProvider = null;
  });

  test('constants: tag/attr lists are exact and frozen', () {
    final expected = _section('constants');
    expect(ds.basicMarkupHtmlTags, expected['basicMarkupHtmlTags']);
    expect(ds.defaultAllowedAttrs, expected['defaultAllowedAttrs']);
    bool frozen(List<String> list) {
      try {
        // ignore: invalid_use_of_unsupported_member
        (list as dynamic).add('probe');
        return false;
      } catch (_) {
        return true;
      }
    }

    expect(frozen(ds.basicMarkupHtmlTags) && frozen(ds.defaultAllowedAttrs),
        expected['frozen']);
  });

  test('sanitizeHtml default config + hooks + finally cleanup', () {
    final expected = (_section('defaultSanitize')['config'] as Map)
        .cast<String, Object?>();
    ds.sanitizeHtml('<div>hi</div>');
    _expectMap(_cfgSnapshot(_purify.lastConfig()), expected, 'config');
    expect(_purify.addHookCalls, _section('defaultSanitize')['hooks']);
    expect(_purify.removeAllHooksCount,
        _section('defaultSanitize')['removeAllHooks']);
  });

  test('config override/augment, case-insensitive attrs + predicates', () {
    final section = _section('configResolution');
    bool predicate(dom.DomElement node, Map<String, Object?> data) =>
        data['attrValue'] == 'keep';
    // Return a String for non-'keep' to match the truth's `rewritten`.
    Object predicate2(dom.DomElement node, Map<String, Object?> data) =>
        data['attrValue'] == 'keep' ? true : 'rewritten';

    ds.sanitizeHtml('<x>hi</x>', ds.DomSanitizerConfig(
      allowedTags: <String, Object?>{
        'override': <String>['custom'],
        'augment': <String>['extra'],
      },
      allowedAttributes: <String, Object?>{
        'override': <Object>[
          'HREF',
          ds.SanitizeAttributeRule(
              attributeName: 'DATA-X', shouldKeep: predicate2),
        ],
        'augment': <Object>['title'],
      },
    ));
    _expectMap(_cfgSnapshot(_purify.lastConfig()), section['config'], 'config');
    expect(_purify.addHookCalls, section['hooks']);

    final hook = _purify.allHooks['uponSanitizeAttribute']!;
    Map<String, Object?> probe(String attrName, String attrValue) {
      final Map<String, Object?> e = <String, Object?>{
        'attrName': attrName,
        'attrValue': attrValue,
      };
      hook(<Object?>[dom.document.createElement('x'), e]);
      return e;
    }
    final probes = (section['probes'] as Map).cast<String, dynamic>();
    _expectMap(probe('href', 'x'), probes['hrefLower'], 'hrefLower');
    _expectMap(probe('data-x', 'keep'), probes['dataXKeep'], 'dataXKeep');
    _expectMap(probe('data-x', 'other'), probes['dataXOther'], 'dataXOther');
    _expectMap(probe('style', 'x'), probes['unknown'], 'unknown');
    // silence unused analyzer hint for the bool predicate carrier
    expect(predicate, isNotNull);
  });

  dom.DomElement _fakeNode(String nodeName, Map<String, String> attrs) {
    final dom.DomElement el = dom.document.createElement(nodeName);
    attrs.forEach(el.setAttribute);
    return el;
  }

  String _probeLink(ds.DomSanitizerConfig? config, String nodeName,
      String attr, String value) {
    _purify.reset();
    ds.sanitizeHtml('<x></x>', config);
    final hook = _purify.allHooks['afterSanitizeAttributes']!;
    final dom.DomElement node = _fakeNode(nodeName, <String, String>{attr: value});
    hook(<Object?>[node]);
    return node.hasAttribute(attr) ? node.getAttribute(attr)! : 'REMOVED';
  }

  test('link/media protocol validation from truth', () {
    final links = (_section('linkValidation') as Map).cast<String, dynamic>();
    expect(_probeLink(null, 'a', 'href', '#section'), links['aHrefFragment']);
    expect(_probeLink(null, 'a', 'href', 'https://example.com'), links['aHrefHttp']);
    expect(_probeLink(null, 'a', 'href', 'ftp://example.com'), links['aHrefFtp']);
    expect(_probeLink(null, 'a', 'href', 'foo/bar'), links['aHrefRelativeDefault']);
    expect(
        _probeLink(ds.DomSanitizerConfig(allowRelativeLinkPaths: true), 'a', 'href', 'foo/bar'),
        links['aHrefRelativeAllowed']);
    expect(
        _probeLink(ds.DomSanitizerConfig(allowRelativeLinkPaths: true), 'a', 'href',
            'vscode-relative-path:foo'),
        links['aHrefRelativeAllowedWithProtocolPrefix']);
    expect(_probeLink(null, 'svg', 'href', 'ftp://example.com'), links['svgHrefFtp']);
    expect(_probeLink(null, 'img', 'src', 'http://example.com/x.png'), links['imgSrcHttp']);
    expect(_probeLink(null, 'img', 'src', 'data:image/png;base64,AAA'), links['imgSrcDataDefault']);
    expect(
        _probeLink(
            ds.DomSanitizerConfig(allowedMediaProtocols: <String, Object?>{
              'override': <String>['data', 'http', 'https']
            }),
            'img',
            'src',
            'data:image/png;base64,AAA'),
        links['imgSrcDataAllowed']);
    expect(
        _probeLink(ds.DomSanitizerConfig(allowRelativeMediaPaths: true), 'img', 'src',
            'img/foo.png'),
        links['imgSrcRelativeAllowed']);
    expect(_probeLink(null, 'video', 'poster', 'ftp://example.com/p.png'),
        links['videoPosterFtp']);
  });

  test('mediaSourceIsAllowed with/without plaintext replacement', () {
    _purify.reset();
    ds.sanitizeHtml('<img>', ds.DomSanitizerConfig(
      mediaSourceIsAllowed: (src) => src.contains('allowed'),
    ));
    final hook = _purify.allHooks['afterSanitizeAttributes']!;
    final node = _fakeNode('img', <String, String>{
      'src': 'http://example.com/blocked.png'
    });
    hook(<Object?>[node]);
    expect(node.hasAttribute('src') ? 'KEPT' : 'REMOVED',
        _truth['mediaValidationWithoutReplacement']);

    _purify.reset();
    ds.sanitizeHtml('<img>', ds.DomSanitizerConfig(
      mediaSourceIsAllowed: (src) => src.contains('allowed'),
      replaceWithPlaintext: true,
    ));
    final hook2 = _purify.allHooks['afterSanitizeAttributes']!;
    final node2 = _fakeNode('img', <String, String>{
      'src': 'http://example.com/blocked.png'
    });
    hook2(<Object?>[node2]);
    expect(node2.hasAttribute('src') ? 'KEPT' : 'REMOVED',
        _truth['mediaValidationWithReplacementNoParent']);
  });

  List<Map<String, Object?>> _childSnapshot(dom.DomNode parent) => parent.childNodes
      .map<Map<String, Object?>>((dom.DomNode c) {
        if (c is dom.DomTextNode) {
          return <String, Object?>{'type': 'text', 'text': c.textContent};
        }
        if (c is dom.DomElement) {
          return <String, Object?>{'type': 'element', 'tag': c.localName};
        }
        if (c is _DomComment) {
          return <String, Object?>{'type': 'comment', 'text': c.textContent};
        }
        return <String, Object?>{'type': 'other'};
      })
      .toList();

  Map<String, Object?> _plaintextProbe(
      String tagName, Map<String, String> attrs, List<String> allowedTags) {
    _purify.reset();
    ds.sanitizeHtml('<x></x>', ds.DomSanitizerConfig(
      replaceWithPlaintext: true,
      allowedTags: <String, Object?>{'override': allowedTags},
    ));
    final hook = _purify.allHooks['uponSanitizeElement']!;
    final dom.DomElement parent = dom.document.createElement('div');
    final dom.DomElement node = dom.document.createElement(tagName);
    attrs.forEach(node.setAttribute);
    parent.appendChild(node);
    final Map<String, Object?> data = <String, Object?>{
      'tagName': tagName,
      'allowedTags': <String, Object?>{
        for (final String t in allowedTags) t: true,
      },
    };
    hook(<Object?>[node, data, <String, Object?>{}]);
    return <String, Object?>{'childNodes': _childSnapshot(parent)};
  }

  test('replaceWithPlaintext: unsupported/self-closing/attrs/empty/custom', () {
    final plaintext = (_section('plaintext') as Map).cast<String, dynamic>();
    _expectMap(_plaintextProbe('bad', <String, String>{}, <String>['div']),
        plaintext['unsupportedTag'], 'unsupportedTag');
    _expectMap(
        _plaintextProbe('img', <String, String>{'src': 'x'}, <String>['div']),
        plaintext['selfClosing'], 'selfClosing');
    _expectMap(
        _plaintextProbe('bad', <String, String>{'title': 'hello', 'data-x': 'y'},
            <String>['div']),
        plaintext['withAttributes'], 'withAttributes');
    _expectMap(_plaintextProbe('bad', <String, String>{}, <String>['div']),
        plaintext['emptyTag'], 'emptyTag');
    _expectMap(_plaintextProbe('custom', <String, String>{}, <String>['custom']),
        plaintext['customAllowed'], 'customAllowed');
  });

  test('replaceWithPlaintext: comment inserts text before comment', () {
    _purify.reset();
    ds.sanitizeHtml('<x></x>', ds.DomSanitizerConfig(
      replaceWithPlaintext: true,
      allowedTags: <String, Object?>{'override': <String>['div']},
    ));
    final hook = _purify.allHooks['uponSanitizeElement']!;
    final dom.DomElement parent = dom.document.createElement('div');
    final _DomComment comment = _DomComment('secret');
    parent.appendChild(comment);
    hook(<Object?>[
      comment,
      <String, Object?>{'tagName': '#comment', 'allowedTags': <String, Object?>{}},
      <String, Object?>{},
    ]);
    _expectMap(<String, Object?>{'childNodes': _childSnapshot(parent)},
        _section('plaintextComment'), 'plaintextComment');
  });

  test('convertTagToPlaintext: element with attrs + orphan', () {
    final dom.DomElement node = dom.document.createElement('bad');
    node.setAttribute('title', 'hello');
    node.appendChild(dom.document.createTextNode('inner'));
    final dom.DomNode? frag = ds.convertTagToPlaintext(node);
    expect(frag, isNotNull);
    _expectMap(
        <String, Object?>{'children': _childSnapshot(frag!)},
        _section('convertTag'), 'convertTag');
    expect(ds.convertTagToPlaintext(Object()) == null ? 'undefined' : 'fragment',
        _truth['convertTagOrphan']);
  });

  test('sanitizeSurvivingStalePolicy: retry with replacement policy', () {
    final section = _section('stalePolicy');
    final List<Map<String, Object?>> ttCalls = <Map<String, Object?>>[];
    trustedTypes.createTrustedTypesPolicyProvider =
        (String name, Object? options) {
      ttCalls.add(<String, Object?>{
        'name': name,
        'options': <String, Object?>{},
      });
      return <String, Object?>{'name': 'replacement'};
    };

    _purify.reset();
    int attempt = 0;
    Object sanitize(String html, Map<String, Object?> cfg) {
      attempt++;
      if (attempt == 1) throw StateError('This Trusted Type Policy is no longer runnable');
      _purify.sanitizeCalls
          .add(<String, Object?>{'html': html, 'cfg': cfg});
      return 'RETRIED:$html';
    }

    final Object result = ds.sanitizeSurvivingStalePolicy(
      '<div>safe</div>',
      <String, Object?>{'ALLOWED_TAGS': <String>['div']},
      sanitize,
    );
    expect(result, section['result']);
    _expectMap(ttCalls, section['ttCalls'], 'ttCalls');
    _expectMap(_cfgSnapshot(_purify.lastConfig()), section['retryConfig'],
        'retryConfig');
  });

  test('sanitizeSurvivingStalePolicy: non-stale error rethrown', () {
    Object bad(String html, Map<String, Object?> cfg) =>
        throw StateError('Some other sanitizer failure');
    expect(
        () => ds.sanitizeSurvivingStalePolicy(
            '<div>x</div>', <String, Object?>{}, bad),
        throwsA(isA<StateError>()),
        reason: 'non-stale error must be rethrown');
  });

  test('safeSetInnerHtml: dom output type + reset', () {
    final section = _section('safeSetInnerHtml');
    final List<Map<String, Object?>> resets = <Map<String, Object?>>[];
    ds.resetProvider = (dom.DomElement parent, List<Object> children) {
      resets.add(<String, Object?>{
        'tag': parent.localName,
        'fragChildren': children.length == 1 && children.first is dom.DomNode
            ? (children.first as dom.DomNode).childNodes.length
            : 0,
      });
    };
    _purify.sanitizeOverride = (String html, Map<String, Object?> cfg) {
      final dom.DomNode frag =
          dom.DomNode(dom.DomNode.DOCUMENT_FRAGMENT_NODE)
            ..appendChild(dom.document.createTextNode('SANITIZED:$html'));
      return frag;
    };
    final dom.DomElement node = dom.document.createElement('div');
    ds.safeSetInnerHtml(node, '<b>hi</b>');
    _expectMap(_cfgSnapshot(_purify.lastConfig()), section['config'], 'config');
    _expectMap(resets, section['resetCalls'], 'resetCalls');
  });
}
