// 1:1 port of vs/base/browser/ui/animations/animations.ts
//
// This module is DOM-side visual effects. Flutter has no Web Animations API,
// so the browser boundaries (element.animate, getBoundingClientRect, closest,
// window.setTimeout, style mutation, Math.random) are surfaced as injectable
// providers. The animation/keyframe computation itself is ported 1:1.
import 'dart:math' as math;

import '../../dom.dart' as dom;
import '../../../common/themables.dart' as themables;

/// 1:1: `enum ClickAnimation`
class ClickAnimation {
  static const int confetti = 1;
  static const int floatingIcons = 2;
  static const int pulseWave = 3;
  static const int radiantLines = 4;
}

/// 1:1: `IConfettiAnimationRange`
class IConfettiAnimationRange {
  const IConfettiAnimationRange(this.min, this.max);

  final num min;
  final num max;
}

/// 1:1: `IConfettiAnimationOptions`
class IConfettiAnimationOptions {
  const IConfettiAnimationOptions({
    this.launchDuration,
    this.fallDuration,
    this.fallDistance,
  });

  final IConfettiAnimationRange? launchDuration;
  final IConfettiAnimationRange? fallDuration;
  final IConfettiAnimationRange? fallDistance;
}

/// 1:1: `IAnimationTarget`
class IAnimationTarget {
  IAnimationTarget({required this.element, required this.rect, required this.container});

  final Object element;
  final dom.DomRect rect;
  final Object container;
}

/// A single Web Animations keyframe: an arbitrary property bag.
typedef Keyframe = Map<String, Object?>;

/// Web Animations effect options.
typedef AnimationOptions = Map<String, Object?>;

/// 1:1: DOM boundary — `element.animate(frames, options)`.
void Function(Object element, List<Keyframe> frames, AnimationOptions options)
    animateProvider = (Object element, List<Keyframe> frames, AnimationOptions options) {};

/// 1:1: DOM boundary — `element.closest(selector)`.
Object? Function(Object element, String selector) closestProvider =
    (Object element, String selector) => null;

/// 1:1: DOM boundary — `dom.getWindow(node).setTimeout(fn, ms)`.
Object Function(Object node, void Function() fn, int ms) setTimeoutProvider =
    (Object node, void Function() fn, int ms) => 0;

/// 1:1: DOM boundary — `element.remove()`.
void Function(Object element) removeProvider = (Object element) {};

/// 1:1: DOM boundary — `Math.random()`.
double Function() randomProvider = () => 0.5;

/// 1:1: DOM boundary — creates an element from a description (`dom.$`).
Object Function(String description) elementCreateProvider =
    (String description) => dom.$(description);

/// 1:1: DOM boundary — sets a style property on an element.
void Function(Object element, String name, String value) setStyleProvider =
    (Object element, String name, String value) {
  (element as dom.DomElement).style[name] = value;
};

/// 1:1: DOM boundary — appends a child to an element.
void Function(Object parent, Object child) appendChildProvider =
    (Object parent, Object child) =>
        (parent as dom.DomElement).appendChild(child as dom.DomNode);

/// 1:1: DOM boundary — adds class tokens to an element.
void Function(Object element, List<String> classes) addClassesProvider =
    (Object element, List<String> classes) {
  final dom.DomElement e = element as dom.DomElement;
  for (final String c in classes) {
    e.classList.add(c);
  }
};

/// 1:1: DOM boundary — `element.getBoundingClientRect()`.
dom.DomRect Function(Object element) getBoundingClientRectProvider =
    (Object element) => (element as dom.DomElement).getBoundingClientRect();

/// 1:1: DOM boundary — `dom.getWindow(element).document.body`.
Object Function(Object element) windowBodyProvider = (Object element) =>
    dom.getActiveDocument().body;

/// 1:1: DOM boundary — `dom.isHTMLElement(target)`.
bool Function(Object target) isHTMLElementProvider = (Object target) {
  if (target is dom.DomElement) {
    return target.namespaceURI == dom.Namespace.HTML;
  }
  return false;
};

/// 1:1: `captureAnimationTarget`
IAnimationTarget captureAnimationTarget(Object element) => IAnimationTarget(
      element: element,
      rect: getBoundingClientRectProvider(element),
      container: closestProvider(element, '.monaco-workbench') ??
          windowBodyProvider(element),
    );

const List<String> confettiColors = <String>[
  'var(--vscode-confetti-color1)',
  'var(--vscode-confetti-color2)',
  'var(--vscode-confetti-color3)',
  'var(--vscode-confetti-color4)',
  'var(--vscode-confetti-color5)',
  'var(--vscode-confetti-color6)',
];

const IConfettiAnimationRange defaultConfettiLaunchDuration =
    IConfettiAnimationRange(210, 290);
const IConfettiAnimationRange defaultConfettiFallDuration =
    IConfettiAnimationRange(940, 1220);
const IConfettiAnimationRange defaultConfettiFallDistance =
    IConfettiAnimationRange(48, 72);

/// 1:1: `randomInRange`
num randomInRange(IConfettiAnimationRange range) =>
    range.min + randomProvider() * (range.max - range.min);

/// Internal capture returned by `createOverlay`.
class _OverlayInfo {
  _OverlayInfo({
    required this.overlay,
    required this.cx,
    required this.cy,
    required this.element,
    required this.rect,
  });

  final Object overlay;
  final double cx;
  final double cy;
  final Object element;
  final dom.DomRect rect;
}

/// 1:1: `createOverlay`
_OverlayInfo _createOverlay(Object target) {
  final IAnimationTarget resolved = isHTMLElementProvider(target)
      ? captureAnimationTarget(target)
      : target as IAnimationTarget;

  final Object overlay = elementCreateProvider('.animation-overlay');
  setStyleProvider(overlay, 'position', 'fixed');
  setStyleProvider(overlay, 'left', '${resolved.rect.left}px');
  setStyleProvider(overlay, 'top', '${resolved.rect.top}px');
  setStyleProvider(overlay, 'width', '${resolved.rect.width}px');
  setStyleProvider(overlay, 'height', '${resolved.rect.height}px');
  setStyleProvider(overlay, 'pointerEvents', 'none');
  setStyleProvider(overlay, 'overflow', 'visible');
  setStyleProvider(overlay, 'zIndex', '10000');
  appendChildProvider(resolved.container, overlay);

  return _OverlayInfo(
    overlay: overlay,
    cx: resolved.rect.width / 2,
    cy: resolved.rect.height / 2,
    element: resolved.element,
    rect: resolved.rect,
  );
}

/// 1:1: `cleanupOverlay`
void cleanupOverlay(Object overlay, int duration) {
  setTimeoutProvider(overlay, () => removeProvider(overlay), duration);
}

/// 1:1: `bounceElement`
void bounceElement(
  Object element, {
  List<num>? scale,
  List<num>? rotate,
  List<num>? translateY,
  int? duration,
}) {
  final List<Keyframe> frames = <Keyframe>[];

  final int steps = math.max(math.max(scale?.length ?? 0, rotate?.length ?? 0),
      translateY?.length ?? 0);
  if (steps == 0) {
    return;
  }

  for (int i = 0; i < steps; i++) {
    final num offset = steps == 1 ? 1 : i / (steps - 1);
    final Keyframe frame = <String, Object?>{'offset': offset};
    String transformParts = '';

    final num? s = (scale != null && i < scale.length) ? scale[i] : null;
    if (s != null) {
      transformParts += 'scale($s)';
    }

    final num? r = (rotate != null && i < rotate.length) ? rotate[i] : null;
    if (r != null) {
      transformParts += ' rotate(${r}deg)';
    }

    final num? ty = (translateY != null && i < translateY.length)
        ? translateY[i]
        : null;
    if (ty != null) {
      transformParts += ' translateY(${ty}px)';
    }

    if (transformParts.isNotEmpty) {
      frame['transform'] = transformParts.trim();
    }
    frames.add(frame);
  }

  animateProvider(element, frames, <String, Object?>{
    'duration': duration ?? 350,
    'easing': 'cubic-bezier(0.4, 0, 0.2, 1)',
    'fill': 'forwards',
  });
}

class _Particle {
  _Particle({
    required this.launchTime,
    required this.fallTime,
    required this.duration,
    required this.peakX,
    required this.peakY,
    required this.fallDistance,
    required this.driftX,
    required this.flutterPhase,
    required this.revealTime,
  }) : keyframes = <Keyframe>[];

  final num launchTime;
  final num fallTime;
  final num duration;
  final num peakX;
  final num peakY;
  final num fallDistance;
  final num driftX;
  final num flutterPhase;
  final num revealTime;
  final List<Keyframe> keyframes;
}

/// 1:1: `triggerConfettiAnimation`
void triggerConfettiAnimation(Object target, [IConfettiAnimationOptions options = const IConfettiAnimationOptions()]) {
  final _OverlayInfo info = _createOverlay(target);
  final Object overlay = info.overlay;
  final num cx = info.cx;
  final num cy = info.cy;
  final Object element = info.element;
  final dom.DomRect rect = info.rect;
  final IConfettiAnimationRange launchDuration =
      options.launchDuration ?? defaultConfettiLaunchDuration;
  final IConfettiAnimationRange fallDuration =
      options.fallDuration ?? defaultConfettiFallDuration;
  final IConfettiAnimationRange fallDistance =
      options.fallDistance ?? defaultConfettiFallDistance;
  const int pixelSize = 4;
  const int frameDuration = 40;
  const int particleCount = 24;

  final List<_Particle> particles = <_Particle>[];
  for (int i = 0; i < particleCount; i++) {
    final num launchTime = randomInRange(launchDuration);
    final num fallTime = randomInRange(fallDuration);
    final num angle = (-150 + randomProvider() * 120) * math.pi / 180;
    final num distance = 24 + randomProvider() * 20;
    particles.add(_Particle(
      launchTime: launchTime,
      fallTime: fallTime,
      duration: launchTime + fallTime,
      peakX: math.cos(angle) * distance,
      peakY: math.sin(angle) * distance * 1.5,
      fallDistance: randomInRange(fallDistance),
      driftX: (randomProvider() - 0.5) * 16,
      flutterPhase: randomProvider() * math.pi * 2,
      revealTime: 20 + randomProvider() * 140,
    ));
  }

  num duration = 0;
  for (final _Particle particle in particles) {
    if (particle.duration > duration) duration = particle.duration;
  }
  final int frameCount = (duration / frameDuration).ceil();
  for (int frame = 0; frame <= frameCount; frame++) {
    final num time = math.min(frame * frameDuration, duration);
    final Set<String> occupiedPixels = <String>{};
    for (final _Particle particle in particles) {
      final num launchProgress = math.min(1, time / particle.launchTime);
      final num rise = 1 - math.pow(1 - launchProgress, 2);
      final num horizontalProgress = (1 - math.exp(-2 * time / particle.launchTime)) /
          (1 - math.exp(-2));
      final num fallProgress = math.min(
          1, math.max(0, (time - particle.launchTime) / particle.fallTime));
      final num flutter = math.sin(fallProgress * math.pi * 4 + particle.flutterPhase) *
          pixelSize *
          fallProgress;
      num x = (((particle.peakX * horizontalProgress +
                      particle.driftX * fallProgress +
                      flutter) /
                  pixelSize).round() *
              pixelSize) as num;
      final num y = (((particle.peakY * rise +
                      particle.fallDistance * math.pow(fallProgress, 1.5)) /
                  pixelSize).round() *
              pixelSize) as num;
      final num opacity = time < particle.revealTime ? 0 : 1 - fallProgress;
      if (opacity > 0) {
        while (occupiedPixels.contains('$x,$y')) {
          x += particle.peakX < 0 ? -pixelSize : pixelSize;
        }
        occupiedPixels.add('$x,$y');
      }
      particle.keyframes.add(<String, Object?>{
        'opacity': opacity,
        'transform': 'translate(${x}px, ${y}px)',
        'offset': time / duration,
        'easing': 'steps(1, end)',
      });
    }
  }

  // Element bounce
  bounceElement(element,
      scale: <num>[1, 1.3, 1], rotate: <num>[0, -10, 10, 0], duration: 350);

  // Confetti particles
  for (int i = 0; i < particleCount; i++) {
    final Object part = elementCreateProvider(
        '.animation-particle.animation-confetti-particle');
    setStyleProvider(part, 'position', 'absolute');
    setStyleProvider(part, 'width', '${pixelSize}px');
    setStyleProvider(part, 'height', '${pixelSize}px');
    setStyleProvider(part, 'backgroundColor',
        confettiColors[i % confettiColors.length]);
    setStyleProvider(
        part,
        'left',
        '${((rect.left + cx) / pixelSize).round() * pixelSize - rect.left}px');
    setStyleProvider(
        part,
        'top',
        '${((rect.top + cy) / pixelSize).round() * pixelSize - rect.top}px');
    appendChildProvider(overlay, part);
    animateProvider(part, particles[i].keyframes, <String, Object?>{
      'duration': duration,
      'fill': 'both',
    });
  }

  cleanupOverlay(
      overlay, (launchDuration.max + fallDuration.max + 200) as int);
}

/// 1:1: `triggerFloatingIconsAnimation`
void triggerFloatingIconsAnimation(Object target, themables.ThemeIcon icon) {
  final _OverlayInfo info = _createOverlay(target);
  final Object overlay = info.overlay;
  final num cx = info.cx;
  final num cy = info.cy;
  final Object element = info.element;

  bounceElement(element, translateY: <num>[0, -6, 0], duration: 350);

  const int iconCount = 6;
  for (int i = 0; i < iconCount; i++) {
    final int size = 12 + (i % 3) * 2;
    final Object iconEl = elementCreateProvider('.animation-particle');
    setStyleProvider(iconEl, 'position', 'absolute');
    setStyleProvider(iconEl, 'left', '${cx}px');
    setStyleProvider(iconEl, 'top', '${cy}px');
    setStyleProvider(iconEl, 'fontSize', '${size}px');
    setStyleProvider(iconEl, 'lineHeight', '1');
    setStyleProvider(iconEl, 'color', 'var(--vscode-focusBorder, #007acc)');
    addClassesProvider(iconEl, themables.ThemeIcon.asClassNameArray(icon));
    appendChildProvider(overlay, iconEl);

    final num driftX = (randomProvider() - 0.5) * 50;
    final num floatY = -50 - (i % 3) * 10;
    final num rotate1 = (randomProvider() - 0.5) * 20;
    final num rotate2 = (randomProvider() - 0.5) * 40;

    animateProvider(
      iconEl,
      <Keyframe>[
        <String, Object?>{
          'opacity': 0,
          'transform': 'translate(-50%, -50%) scale(0) rotate(${rotate1}deg)'
        },
        <String, Object?>{
          'opacity': 1,
          'transform':
              'translate(calc(-50% + ${driftX * 0.3}px), calc(-50% + ${floatY * 0.3}px)) scale(1) rotate(${(rotate1 + rotate2) * 0.3}deg)',
          'offset': 0.3
        },
        <String, Object?>{
          'opacity': 1,
          'transform':
              'translate(calc(-50% + ${driftX * 0.7}px), calc(-50% + ${floatY * 0.7}px)) scale(1) rotate(${(rotate1 + rotate2) * 0.7}deg)',
          'offset': 0.7
        },
        <String, Object?>{
          'opacity': 0,
          'transform':
              'translate(calc(-50% + ${driftX}px), calc(-50% + ${floatY}px)) scale(0.8) rotate(${rotate2}deg)'
        },
      ],
      <String, Object?>{
        'duration': 800 + (i % 3) * 200,
        'delay': i * 80,
        'easing': 'cubic-bezier(0.4, 0, 0.2, 1)',
        'fill': 'forwards',
      },
    );
  }

  final Object ring = elementCreateProvider('.animation-particle');
  setStyleProvider(ring, 'position', 'absolute');
  setStyleProvider(ring, 'left', '0');
  setStyleProvider(ring, 'top', '0');
  setStyleProvider(ring, 'width', '${info.rect.width}px');
  setStyleProvider(ring, 'height', '${info.rect.height}px');
  setStyleProvider(ring, 'borderRadius', '50%');
  setStyleProvider(ring, 'border', '2px solid var(--vscode-focusBorder, #007acc)');
  setStyleProvider(ring, 'boxSizing', 'border-box');
  appendChildProvider(overlay, ring);
  animateProvider(
    ring,
    <Keyframe>[
      <String, Object?>{'transform': 'scale(1)', 'opacity': 1},
      <String, Object?>{'transform': 'scale(2)', 'opacity': 0},
    ],
    <String, Object?>{
      'duration': 500,
      'easing': 'cubic-bezier(0.4, 0, 0.2, 1)',
      'fill': 'forwards',
    },
  );

  cleanupOverlay(overlay, 2000);
}

/// 1:1: `triggerPulseWaveAnimation`
void triggerPulseWaveAnimation(Object target) {
  final _OverlayInfo info = _createOverlay(target);
  final Object overlay = info.overlay;
  final num cx = info.cx;
  final num cy = info.cy;
  final Object element = info.element;
  final dom.DomRect rect = info.rect;

  bounceElement(element,
      scale: <num>[1, 1.1, 1], rotate: <num>[0, -12, 0], duration: 400);

  for (int i = 0; i < 2; i++) {
    final Object ring = elementCreateProvider('.animation-particle');
    setStyleProvider(ring, 'position', 'absolute');
    setStyleProvider(ring, 'left', '0');
    setStyleProvider(ring, 'top', '0');
    setStyleProvider(ring, 'width', '${rect.width}px');
    setStyleProvider(ring, 'height', '${rect.height}px');
    setStyleProvider(ring, 'borderRadius', '50%');
    setStyleProvider(ring, 'border', '2px solid var(--vscode-focusBorder, #007acc)');
    setStyleProvider(ring, 'boxSizing', 'border-box');
    appendChildProvider(overlay, ring);
    animateProvider(
      ring,
      <Keyframe>[
        <String, Object?>{'transform': 'scale(0.8)', 'opacity': 0},
        <String, Object?>{
          'transform': 'scale(0.8)',
          'opacity': 0.6,
          'offset': 0.01
        },
        <String, Object?>{'transform': 'scale(2.5)', 'opacity': 0},
      ],
      <String, Object?>{
        'duration': 800,
        'delay': i * 150,
        'easing': 'cubic-bezier(0.4, 0, 0.2, 1)',
        'fill': 'forwards',
      },
    );
  }

  for (int i = 0; i < 6; i++) {
    final num angle = (i * 60 * math.pi) / 180;
    final int distance = 30 + (i % 2) * 10;
    const double size = 3.5;

    final Object dot = elementCreateProvider('.animation-particle');
    setStyleProvider(dot, 'position', 'absolute');
    setStyleProvider(dot, 'width', '${size}px');
    setStyleProvider(dot, 'height', '${size}px');
    setStyleProvider(dot, 'borderRadius', '50%');
    setStyleProvider(dot, 'backgroundColor', '#0098ff');
    setStyleProvider(dot, 'left', '${cx - size / 2}px');
    setStyleProvider(dot, 'top', '${cy - size / 2}px');
    appendChildProvider(overlay, dot);

    final num tx = math.cos(angle) * distance;
    final num ty = math.sin(angle) * distance;
    animateProvider(
      dot,
      <Keyframe>[
        <String, Object?>{
          'opacity': 0,
          'transform': 'scale(0) translate(0, 0)'
        },
        <String, Object?>{
          'opacity': 1,
          'transform': 'scale(1) translate(${tx}px, ${ty}px)',
          'offset': 0.5
        },
        <String, Object?>{
          'opacity': 0,
          'transform': 'scale(0) translate(${tx}px, ${ty}px)'
        },
      ],
      <String, Object?>{
        'duration': 600,
        'delay': 100 + i * 50,
        'easing': 'cubic-bezier(0.4, 0, 0.2, 1)',
        'fill': 'forwards',
      },
    );
  }

  final Object glow = elementCreateProvider('.animation-particle');
  setStyleProvider(glow, 'position', 'absolute');
  setStyleProvider(glow, 'left', '0');
  setStyleProvider(glow, 'top', '0');
  setStyleProvider(glow, 'width', '${rect.width}px');
  setStyleProvider(glow, 'height', '${rect.height}px');
  setStyleProvider(glow, 'borderRadius', '50%');
  setStyleProvider(glow, 'backgroundColor', 'var(--vscode-focusBorder, #007acc)');
  appendChildProvider(overlay, glow);
  animateProvider(
    glow,
    <Keyframe>[
      <String, Object?>{'transform': 'scale(0.9)', 'opacity': 0},
      <String, Object?>{'transform': 'scale(0.9)', 'opacity': 0.5, 'offset': 0.01},
      <String, Object?>{'transform': 'scale(1.5)', 'opacity': 0},
    ],
    <String, Object?>{
      'duration': 500,
      'easing': 'cubic-bezier(0.4, 0, 0.2, 1)',
      'fill': 'forwards',
    },
  );

  cleanupOverlay(overlay, 2000);
}

/// 1:1: `triggerRadiantLinesAnimation`
void triggerRadiantLinesAnimation(Object target) {
  final _OverlayInfo info = _createOverlay(target);
  final Object overlay = info.overlay;
  final num cx = info.cx;
  final num cy = info.cy;
  final Object element = info.element;

  bounceElement(element, scale: <num>[1, 1.15, 1], duration: 350);

  for (int i = 0; i < 8; i++) {
    const int size = 3;
    const double dotOpacity = 0.7;
    final num angle = ((i * 45 + 22.5) * math.pi) / 180;
    const int startDistance = 14;
    const int endDistance = 30;

    final Object dot = elementCreateProvider('.animation-particle');
    setStyleProvider(dot, 'position', 'absolute');
    setStyleProvider(dot, 'width', '${size}px');
    setStyleProvider(dot, 'height', '${size}px');
    setStyleProvider(dot, 'borderRadius', '50%');
    setStyleProvider(dot, 'backgroundColor', 'var(--vscode-editor-foreground, #ffffff)');
    setStyleProvider(dot, 'left', '${cx - size / 2}px');
    setStyleProvider(dot, 'top', '${cy - size / 2}px');
    appendChildProvider(overlay, dot);

    final num startX = math.cos(angle) * startDistance;
    final num startY = math.sin(angle) * startDistance;
    final num endX = math.cos(angle) * endDistance;
    final num endY = math.sin(angle) * endDistance;

    animateProvider(
      dot,
      <Keyframe>[
        <String, Object?>{
          'opacity': 0,
          'transform': 'scale(0) translate(${startX}px, ${startY}px)'
        },
        <String, Object?>{
          'opacity': dotOpacity,
          'transform':
              'scale(1.2) translate(${(startX + endX) / 2}px, ${(startY + endY) / 2}px)',
          'offset': 0.25
        },
        <String, Object?>{
          'opacity': dotOpacity,
          'transform': 'scale(1) translate(${endX * 0.8}px, ${endY * 0.8}px)',
          'offset': 0.5
        },
        <String, Object?>{
          'opacity': dotOpacity * 0.5,
          'transform': 'scale(1) translate(${endX}px, ${endY}px)',
          'offset': 0.75
        },
        <String, Object?>{
          'opacity': 0,
          'transform': 'scale(0.5) translate(${endX}px, ${endY}px)'
        },
      ],
      <String, Object?>{
        'duration': 1100,
        'easing': 'cubic-bezier(0.4, 0, 0.2, 1)',
        'fill': 'forwards',
      },
    );
  }

  for (int i = 0; i < 8; i++) {
    final int angleDeg = i * 45;

    final Object lineWrapper = elementCreateProvider('.animation-particle');
    setStyleProvider(lineWrapper, 'position', 'absolute');
    setStyleProvider(lineWrapper, 'left', '${cx}px');
    setStyleProvider(lineWrapper, 'top', '${cy}px');
    setStyleProvider(lineWrapper, 'width', '0');
    setStyleProvider(lineWrapper, 'height', '0');
    setStyleProvider(lineWrapper, 'transform', 'rotate(${angleDeg}deg)');
    appendChildProvider(overlay, lineWrapper);

    final Object line = elementCreateProvider('.animation-particle');
    setStyleProvider(line, 'position', 'absolute');
    setStyleProvider(line, 'width', '2px');
    setStyleProvider(line, 'height', '10px');
    setStyleProvider(line, 'backgroundColor', 'var(--vscode-focusBorder, #007acc)');
    setStyleProvider(line, 'left', '-1px');
    setStyleProvider(line, 'top', '-22px');
    setStyleProvider(line, 'transformOrigin', 'bottom center');
    appendChildProvider(lineWrapper, line);

    animateProvider(
      line,
      <Keyframe>[
        <String, Object?>{'transform': 'scale(1, 0)', 'opacity': 0.6},
        <String, Object?>{'transform': 'scale(1, 1)', 'opacity': 0.6, 'offset': 0.2},
        <String, Object?>{'transform': 'scale(1, 1)', 'opacity': 0.6, 'offset': 0.6},
        <String, Object?>{'transform': 'scale(1, 1)', 'opacity': 0.6, 'offset': 0.8},
        <String, Object?>{'transform': 'scale(0, 0.3)', 'opacity': 0},
      ],
      <String, Object?>{
        'duration': 1200,
        'delay': 150,
        'easing': 'cubic-bezier(0.4, 0, 0.2, 1)',
        'fill': 'forwards',
      },
    );
  }

  cleanupOverlay(overlay, 2000);
}

/// 1:1: `triggerClickAnimation`
void triggerClickAnimation(Object target, int animation, [themables.ThemeIcon? icon]) {
  switch (animation) {
    case ClickAnimation.confetti:
      triggerConfettiAnimation(target);
      break;
    case ClickAnimation.floatingIcons:
      if (icon != null) {
        triggerFloatingIconsAnimation(target, icon);
      }
      break;
    case ClickAnimation.pulseWave:
      triggerPulseWaveAnimation(target);
      break;
    case ClickAnimation.radiantLines:
      triggerRadiantLinesAnimation(target);
      break;
  }
}
