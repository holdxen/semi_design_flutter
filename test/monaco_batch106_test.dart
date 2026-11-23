// Data-driven port test for batch106: editor/browser/config/elementSizeObserver.ts.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart' hide Dimension;
import 'package:semi_design_flutter/src/monaco/base/browser/window.dart'
    show mainWindow;
import 'package:semi_design_flutter/src/monaco/editor/browser/config/elementSizeObserver.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/2d/dimension.dart'
    show Dimension;

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch106_truth.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  setUp(() => windowCarrier(mainWindow).flushAnimationFrame());
  tearDown(() => windowCarrier(mainWindow).flushAnimationFrame());

  test('exports and dimension-based construction', () {
    expect(truth['exports'], <dynamic>['ElementSizeObserver']);
    final DomElement el = DomElement('DIV')
      ..clientWidth = 1
      ..clientHeight = 100;
    final ElementSizeObserver observer =
        ElementSizeObserver(el, Dimension(10, 20));
    final Map<String, dynamic> t = truth['initial'] as Map<String, dynamic>;
    expect(observer.getWidth(), t['width']);
    expect(observer.getHeight(), t['height']);

    int fires = 0;
    final dynamic sub = observer.onDidChange((_) => fires++);
    observer.observe(Dimension(30, 40));
    expect(observer.getWidth(), truth['observeExplicit']['width']);
    expect(observer.getHeight(), truth['observeExplicit']['height']);
    expect(fires, truth['observeExplicit']['fires']);
    observer.observe(Dimension(30, 40));
    expect(fires, truth['observeSame']['fires']);
    (sub as dynamic).dispose();
    observer.dispose();
  });

  test('element dimensions clamp to 5 and no event in constructor', () {
    final DomElement el = DomElement('DIV')
      ..clientWidth = 1
      ..clientHeight = 100;
    final ElementSizeObserver observer = ElementSizeObserver(el, null);
    expect(observer.getWidth(), truth['noDimension']['width']);
    expect(observer.getHeight(), truth['noDimension']['height']);
    observer.dispose();
  });

  test('resize observer coalesces deliveries to one per frame', () {
    final DomElement el = DomElement('DIV')
      ..clientWidth = 1
      ..clientHeight = 100;
    final ElementSizeObserver observer = ElementSizeObserver(el, null);
    int fires = 0;
    final dynamic sub = observer.onDidChange((_) => fires++);

    observer.startObserving();
    final DomResizeObserver? ro = observer.resizeObserver;
    expect(ro, isNotNull);
    expect(ro!.observed, [el]);
    expect(fires, truth['startObserving']['fires']);

    ro.deliver(<DomResizeObserverEntry>[
      DomResizeObserverEntry(el, DomRect(width: 50, height: 60)),
    ]);
    expect(observer.getWidth(), truth['firstDelivery']['width']);
    expect(observer.getHeight(), truth['firstDelivery']['height']);
    expect(fires, truth['firstDelivery']['fires']);
    expect(windowCarrier(mainWindow).rafCount,
        truth['firstDelivery']['rafCount']);

    ro.deliver(<DomResizeObserverEntry>[
      DomResizeObserverEntry(el, DomRect(width: 70, height: 80)),
    ]);
    expect(observer.getWidth(), truth['secondDeliverySameFrame']['width']);
    expect(observer.getHeight(), truth['secondDeliverySameFrame']['height']);
    expect(fires, truth['secondDeliverySameFrame']['fires']);
    expect(windowCarrier(mainWindow).rafCount,
        truth['secondDeliverySameFrame']['rafCount']);

    windowCarrier(mainWindow).flushAnimationFrame();
    expect(observer.getWidth(), truth['afterFrame']['width']);
    expect(observer.getHeight(), truth['afterFrame']['height']);
    expect(fires, truth['afterFrame']['fires']);
    expect(windowCarrier(mainWindow).rafCount, truth['afterFrame']['rafCount']);

    observer.stopObserving();
    expect(observer.resizeObserver, isNull);
    expect(ro.observed, isEmpty);
    ro.deliver(<DomResizeObserverEntry>[
      DomResizeObserverEntry(el, DomRect(width: 90, height: 99)),
    ]);
    expect(observer.getWidth(), truth['afterStopDelivery']['width']);
    expect(observer.getHeight(), truth['afterStopDelivery']['height']);
    expect(fires, truth['afterStopDelivery']['fires']);

    (sub as dynamic).dispose();
    observer.dispose();
  });
}
