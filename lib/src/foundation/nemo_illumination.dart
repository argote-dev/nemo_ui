// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'nemo_material.dart';
import 'nemo_theme_data.dart';

/// Internal shared physical renderer. All Nemo relief uses this fixed top-left light.
final class NemoIllumination {
  const NemoIllumination._();
  static void paint(
    Canvas canvas,
    Size size, {
    required NemoThemeData theme,
    required NemoMaterialRecipe recipe,
    required Color baseColor,
    required double radius,
    bool focused = false,
    double? outlineOpacity,
  }) {
    final RRect shape = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final double blur = theme.foundation.shadowBlur * recipe.blurMultiplier;
    final Offset d = Offset(
      theme.foundation.shadowOffset * recipe.offsetMultiplier,
      theme.foundation.shadowOffset * recipe.offsetMultiplier,
    );
    if (recipe.polarity == NemoIlluminationPolarity.raised &&
        recipe.shadowOpacity > 0) {
      _outer(
        canvas,
        shape,
        -d,
        theme.semantic.highlightShadow,
        blur,
        recipe.shadowOpacity,
      );
      _outer(
        canvas,
        shape,
        d,
        theme.semantic.lowlightShadow,
        blur,
        recipe.shadowOpacity,
      );
    }
    canvas.drawRRect(shape, Paint()..color = baseColor);
    if (recipe.tonalOverlayOpacity > 0) {
      canvas.drawRRect(
        shape,
        Paint()
          ..color =
              (recipe.polarity == NemoIlluminationPolarity.inset
                      ? theme.semantic.lowlightShadow
                      : theme.semantic.highlightShadow)
                  .withValues(alpha: recipe.tonalOverlayOpacity),
      );
    }
    if (recipe.polarity == NemoIlluminationPolarity.inset &&
        recipe.shadowOpacity > 0) {
      // Inset reverses the edges: dark at the physical top-left, light at bottom-right.
      _inner(
        canvas,
        shape,
        -d,
        theme.semantic.lowlightShadow,
        blur,
        recipe.shadowOpacity,
      );
      _inner(
        canvas,
        shape,
        d,
        theme.semantic.highlightShadow,
        blur,
        recipe.shadowOpacity,
      );
    }
    final double outline = focused
        ? theme.components.focusRingWidth
        : theme.components.outlineWidth;
    canvas.drawRRect(
      shape.deflate(outline / 2),
      Paint()
        ..color = (focused ? theme.semantic.focusRing : theme.semantic.outline)
            .withValues(
              alpha: focused ? 1 : (outlineOpacity ?? recipe.outlineOpacity),
            )
        ..style = PaintingStyle.stroke
        ..strokeWidth = outline,
    );
  }

  static void _outer(
    Canvas c,
    RRect s,
    Offset o,
    Color color,
    double blur,
    double opacity,
  ) => c.drawRRect(
    s.shift(o),
    Paint()
      ..color = color.withValues(alpha: color.a * opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
  );
  static void _inner(
    Canvas c,
    RRect s,
    Offset o,
    Color color,
    double blur,
    double opacity,
  ) {
    c.save();
    c.clipRRect(s);
    c.drawShadow(
      Path()..addRRect(s.shift(o)),
      color.withValues(alpha: color.a * opacity),
      blur / 2,
      false,
    );
    c.restore();
  }
}
