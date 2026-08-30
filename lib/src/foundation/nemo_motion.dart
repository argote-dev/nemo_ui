import 'package:flutter/widgets.dart';

/// Semantic timings and curves used by Nemo interactions.
@immutable
final class NemoMotionTokens {
  /// Creates a semantic motion scale.
  const NemoMotionTokens({
    required this.instant,
    required this.quick,
    required this.standard,
    required this.emphasized,
    required this.standardCurve,
    required this.decelerateCurve,
    required this.accelerateCurve,
  });

  /// A duration for feedback that should be perceived as immediate.
  final Duration instant;

  /// A duration for hover, focus, and press feedback.
  final Duration quick;

  /// A duration for ordinary state changes.
  final Duration standard;

  /// A duration for important but restrained state changes.
  final Duration emphasized;

  /// The default curve for state changes.
  final Curve standardCurve;

  /// The curve used while a value settles into view.
  final Curve decelerateCurve;

  /// The curve used while a value leaves its resting state.
  final Curve accelerateCurve;

  /// The standard tactile motion scale.
  static const NemoMotionTokens standardTokens = NemoMotionTokens(
    instant: Duration(milliseconds: 80),
    quick: Duration(milliseconds: 140),
    standard: Duration(milliseconds: 220),
    emphasized: Duration(milliseconds: 320),
    standardCurve: Curves.easeOutCubic,
    decelerateCurve: Curves.easeOut,
    accelerateCurve: Curves.easeIn,
  );

  /// A motion scale that preserves final states without spatial animation.
  static const NemoMotionTokens reduced = NemoMotionTokens(
    instant: Duration.zero,
    quick: Duration.zero,
    standard: Duration.zero,
    emphasized: Duration.zero,
    standardCurve: Curves.linear,
    decelerateCurve: Curves.linear,
    accelerateCurve: Curves.linear,
  );

  /// Returns [reduced] when the host has requested reduced motion.
  NemoMotionTokens resolve({required bool disableAnimations}) {
    return disableAnimations ? reduced : this;
  }

  /// Returns the motion scale adapted to the nearest [MediaQuery].
  NemoMotionTokens resolveFor(BuildContext context) {
    return resolve(
      disableAnimations:
          MediaQuery.maybeOf(context)?.disableAnimations ?? false,
    );
  }

  /// Creates a copy with selectively replaced values.
  NemoMotionTokens copyWith({
    Duration? instant,
    Duration? quick,
    Duration? standard,
    Duration? emphasized,
    Curve? standardCurve,
    Curve? decelerateCurve,
    Curve? accelerateCurve,
  }) {
    return NemoMotionTokens(
      instant: instant ?? this.instant,
      quick: quick ?? this.quick,
      standard: standard ?? this.standard,
      emphasized: emphasized ?? this.emphasized,
      standardCurve: standardCurve ?? this.standardCurve,
      decelerateCurve: decelerateCurve ?? this.decelerateCurve,
      accelerateCurve: accelerateCurve ?? this.accelerateCurve,
    );
  }

  /// Interpolates two motion scales.
  static NemoMotionTokens lerp(
    NemoMotionTokens a,
    NemoMotionTokens b,
    double t,
  ) {
    return NemoMotionTokens(
      instant: _lerpDuration(a.instant, b.instant, t),
      quick: _lerpDuration(a.quick, b.quick, t),
      standard: _lerpDuration(a.standard, b.standard, t),
      emphasized: _lerpDuration(a.emphasized, b.emphasized, t),
      standardCurve: t < 0.5 ? a.standardCurve : b.standardCurve,
      decelerateCurve: t < 0.5 ? a.decelerateCurve : b.decelerateCurve,
      accelerateCurve: t < 0.5 ? a.accelerateCurve : b.accelerateCurve,
    );
  }
}

Duration _lerpDuration(Duration a, Duration b, double t) {
  return Duration(
    microseconds: (a.inMicroseconds + (b.inMicroseconds - a.inMicroseconds) * t)
        .round(),
  );
}
