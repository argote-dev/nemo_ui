import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../foundation/nemo_motion.dart';
import '../foundation/nemo_surface_contract.dart';
import '../foundation/nemo_theme.dart';
import '../foundation/nemo_theme_data.dart';

export '../foundation/nemo_surface_contract.dart';

/// A non-interactive, token-driven neumorphic visual surface.
///
/// It deliberately adds no semantics, gestures, focus handling, or layout
/// constraints. Compose those concerns around it or inside [child].
class NemoSurface extends StatelessWidget {
  /// Creates a Nemo surface.
  const NemoSurface({
    required this.child,
    this.depth = NemoSurfaceDepth.raised,
    this.tone = NemoSurfaceTone.surface,
    this.shape = NemoSurfaceShape.roundedMedium,
    this.padding,
    this.clipBehavior = Clip.none,
    super.key,
  });

  /// The content displayed on the surface.
  final Widget child;

  /// The visual relief relative to the immediate visual background.
  final NemoSurfaceDepth depth;

  /// The semantic base tone.
  final NemoSurfaceTone tone;

  /// The tokenized corner shape.
  final NemoSurfaceShape shape;

  /// Internal content padding, or the theme's `space16` when null.
  final EdgeInsetsGeometry? padding;

  /// Whether the child is clipped to the surface shape.
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    final NemoMotionTokens motion = theme.motion.resolveFor(context);
    final _SurfaceVisual visual = _SurfaceVisual.fromTheme(
      theme: theme,
      depth: depth,
      tone: tone,
      shape: shape,
    );
    final _SurfaceVisual flatVisual = _SurfaceVisual.fromTheme(
      theme: theme,
      depth: NemoSurfaceDepth.flat,
      tone: tone,
      shape: shape,
    );
    final EdgeInsetsGeometry resolvedPadding =
        padding ?? EdgeInsets.all(theme.foundation.space16);

    return TweenAnimationBuilder<_SurfaceVisual>(
      tween: _SurfaceVisualTween(end: visual, flat: flatVisual),
      duration: motion.standard,
      curve: motion.standardCurve,
      child: Padding(padding: resolvedPadding, child: child),
      builder:
          (BuildContext context, _SurfaceVisual current, Widget? paddedChild) {
            final Widget content = clipBehavior == Clip.none
                ? paddedChild!
                : ClipRRect(
                    borderRadius: BorderRadius.circular(current.radius),
                    clipBehavior: clipBehavior,
                    child: paddedChild,
                  );
            return CustomPaint(
              painter: _NemoSurfacePainter(visual: current),
              child: content,
            );
          },
    );
  }
}

@immutable
final class _SurfaceVisual {
  const _SurfaceVisual({
    required this.baseColor,
    required this.overlayColor,
    required this.outlineColor,
    required this.highlightShadow,
    required this.lowlightShadow,
    required this.radius,
    required this.outlineWidth,
    required this.blur,
    required this.offset,
    required this.intensity,
    required this.tonalOverlayOpacity,
    required this.outlineOpacity,
    required this.shadowOpacity,
  });

  factory _SurfaceVisual.fromTheme({
    required NemoThemeData theme,
    required NemoSurfaceDepth depth,
    required NemoSurfaceTone tone,
    required NemoSurfaceShape shape,
  }) {
    final NemoSurfaceDepthStyle style = theme.components.surface.styleFor(
      depth,
    );
    final double radius = switch (shape) {
      NemoSurfaceShape.roundedSmall => theme.foundation.radiusSmall,
      NemoSurfaceShape.roundedMedium => theme.foundation.radiusMedium,
      NemoSurfaceShape.roundedLarge => theme.foundation.radiusLarge,
    };
    return _SurfaceVisual(
      baseColor: switch (tone) {
        NemoSurfaceTone.surface => theme.semantic.surface,
        NemoSurfaceTone.surfaceVariant => theme.semantic.surfaceVariant,
      },
      overlayColor: _overlayColor(theme.semantic, style.tonalColor),
      outlineColor: theme.semantic.outline,
      highlightShadow: theme.semantic.highlightShadow,
      lowlightShadow: theme.semantic.lowlightShadow,
      radius: radius,
      outlineWidth: theme.components.outlineWidth,
      blur: theme.foundation.shadowBlur * style.blurMultiplier,
      offset: theme.foundation.shadowOffset * style.offsetMultiplier,
      intensity: style.intensity,
      tonalOverlayOpacity: style.tonalOverlayOpacity,
      outlineOpacity: style.outlineOpacity,
      shadowOpacity: style.shadowOpacity,
    );
  }

  static Color _overlayColor(
    NemoSemanticTokens semantic,
    NemoSurfaceTonalColor tonalColor,
  ) => switch (tonalColor) {
    NemoSurfaceTonalColor.highlightShadow => semantic.highlightShadow,
    NemoSurfaceTonalColor.lowlightShadow => semantic.lowlightShadow,
    NemoSurfaceTonalColor.foreground => semantic.foreground,
    NemoSurfaceTonalColor.outline => semantic.outline,
    NemoSurfaceTonalColor.surfaceVariant => semantic.surfaceVariant,
  };

  final Color baseColor;
  final Color overlayColor;
  final Color outlineColor;
  final Color highlightShadow;
  final Color lowlightShadow;
  final double radius;
  final double outlineWidth;
  final double blur;
  final double offset;
  final double intensity;
  final double tonalOverlayOpacity;
  final double outlineOpacity;
  final double shadowOpacity;

  static _SurfaceVisual lerp(_SurfaceVisual a, _SurfaceVisual b, double t) {
    return _SurfaceVisual(
      baseColor: Color.lerp(a.baseColor, b.baseColor, t)!,
      overlayColor: Color.lerp(a.overlayColor, b.overlayColor, t)!,
      outlineColor: Color.lerp(a.outlineColor, b.outlineColor, t)!,
      highlightShadow: Color.lerp(a.highlightShadow, b.highlightShadow, t)!,
      lowlightShadow: Color.lerp(a.lowlightShadow, b.lowlightShadow, t)!,
      radius: lerpDouble(a.radius, b.radius, t)!,
      outlineWidth: lerpDouble(a.outlineWidth, b.outlineWidth, t)!,
      blur: lerpDouble(a.blur, b.blur, t)!,
      offset: lerpDouble(a.offset, b.offset, t)!,
      intensity: lerpDouble(a.intensity, b.intensity, t)!,
      tonalOverlayOpacity: lerpDouble(
        a.tonalOverlayOpacity,
        b.tonalOverlayOpacity,
        t,
      )!,
      outlineOpacity: lerpDouble(a.outlineOpacity, b.outlineOpacity, t)!,
      shadowOpacity: lerpDouble(a.shadowOpacity, b.shadowOpacity, t)!,
    );
  }
}

final class _SurfaceVisualTween extends Tween<_SurfaceVisual> {
  _SurfaceVisualTween({required _SurfaceVisual end, required this.flat})
    : super(end: end);

  final _SurfaceVisual flat;

  @override
  _SurfaceVisual lerp(double t) {
    final _SurfaceVisual start = begin!;
    if (start.intensity * end!.intensity < 0) {
      return t <= 0.5
          ? _SurfaceVisual.lerp(start, flat, t * 2)
          : _SurfaceVisual.lerp(flat, end!, (t - 0.5) * 2);
    }
    return _SurfaceVisual.lerp(start, end!, t);
  }
}

final class _NemoSurfacePainter extends CustomPainter {
  const _NemoSurfacePainter({required this.visual});

  final _SurfaceVisual visual;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect shape = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(visual.radius),
    );
    final double blur = visual.blur;
    final Offset diagonal = Offset(visual.offset, visual.offset);

    if (visual.intensity > 0 && visual.shadowOpacity > 0) {
      _paintOuterShadow(canvas, shape, -diagonal, visual.highlightShadow, blur);
      _paintOuterShadow(canvas, shape, diagonal, visual.lowlightShadow, blur);
    }

    canvas.drawRRect(shape, Paint()..color = visual.baseColor);
    if (visual.tonalOverlayOpacity > 0) {
      canvas.drawRRect(
        shape,
        Paint()
          ..color = visual.overlayColor.withValues(
            alpha: visual.tonalOverlayOpacity,
          ),
      );
    }

    if (visual.intensity < 0 && visual.shadowOpacity > 0) {
      _paintInnerShadow(canvas, shape, -diagonal, visual.lowlightShadow, blur);
      _paintInnerShadow(canvas, shape, diagonal, visual.highlightShadow, blur);
    }

    canvas.drawRRect(
      shape.deflate(visual.outlineWidth / 2),
      Paint()
        ..color = visual.outlineColor.withValues(alpha: visual.outlineOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = visual.outlineWidth,
    );
  }

  void _paintOuterShadow(
    Canvas canvas,
    RRect shape,
    Offset offset,
    Color color,
    double blur,
  ) {
    canvas.drawRRect(
      shape.shift(offset),
      Paint()
        ..color = color.withValues(alpha: color.a * visual.shadowOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
    );
  }

  void _paintInnerShadow(
    Canvas canvas,
    RRect shape,
    Offset offset,
    Color color,
    double blur,
  ) {
    canvas.save();
    canvas.clipRRect(shape);
    final Path path = Path()..addRRect(shape.shift(offset));
    // drawShadow paints outside the shifted path. Clipping it to the original
    // surface retains that edge inside the surface, instead of tinting its
    // centre as a blurred filled shape would.
    canvas.drawShadow(
      path,
      color.withValues(alpha: color.a * visual.shadowOpacity),
      blur / 2,
      false,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _NemoSurfacePainter oldDelegate) =>
      oldDelegate.visual != visual;
}
