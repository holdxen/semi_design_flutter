// batch308: contentHoverTypes.ts truth replay.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/contrib/hover/browser/contentHoverTypes.dart'
    show
      ContentHoverComputerOptions,
      ContentHoverResult,
      FilteredContentHoverResult,
      IHoverPartForContentHover;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch308_truth.json').readAsStringSync())
    as Map<String, dynamic>;

class _Part implements IHoverPartForContentHover {
  _Part(this.id, this.validFor);

  final String id;
  final List<String> validFor;

  @override
  bool isValidForHoverAnchor(Object anchor) => validFor.contains(anchor);
}

Map<String, Object?> _json(ContentHoverResult r) => <String, Object?>{
      'parts': r.hoverParts
          .map((p) => (p as _Part).id)
          .toList(),
      'isComplete': r.isComplete,
      'options': r.options.value,
      'isFiltered': r is FilteredContentHoverResult,
    };

void main() {
  final Map<String, dynamic> truth = _truth();
  final List<dynamic> cases = truth['cases'] as List<dynamic>;
  final ContentHoverComputerOptions options =
      ContentHoverComputerOptions(<String, Object?>{'target': 'main'});

  final ContentHoverResult allValid = ContentHoverResult(
    <IHoverPartForContentHover>[
      _Part('a', <String>['x', 'y']),
      _Part('b', <String>['x', 'y']),
    ],
    true,
    options,
  );
  final ContentHoverResult allValidFiltered = allValid.filter('x');
  final ContentHoverResult someInvalid = ContentHoverResult(
    <IHoverPartForContentHover>[
      _Part('a', <String>['x', 'y']),
      _Part('b', <String>['y']),
      _Part('c', <String>['x']),
    ],
    false,
    options,
  );
  final ContentHoverResult filtered = someInvalid.filter('y');
  final ContentHoverResult refiltered = filtered.filter('y');
  final ContentHoverResult otherAnchor = filtered.filter('x');

  final List<ContentHoverResult> actualResults = <ContentHoverResult>[
    allValidFiltered,
    filtered,
    refiltered,
    otherAnchor,
  ];
  final List<bool> sameInstances = <bool>[
    identical(allValidFiltered, allValid),
    identical(filtered, someInvalid),
    identical(refiltered, filtered),
    identical(otherAnchor, filtered),
  ];

  for (int i = 0; i < cases.length; i++) {
    final Map<String, dynamic> c = cases[i] as Map<String, dynamic>;
    test(c['label'] as String, () {
      expect(
        <String, Object?>{
          'result': _json(actualResults[i]),
          'sameInstance': sameInstances[i],
        },
        <String, Object?>{
          'result': c['result'],
          'sameInstance': c['sameInstance'],
        },
      );
    });
  }
}
