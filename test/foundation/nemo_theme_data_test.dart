import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nemo_ui/nemo_ui.dart';

void main() {
  group('NemoThemeData', () {
    test('light factory derives colors from the provided seed', () {
      final NemoThemeData blue = NemoThemeData.light(
        seedColor: const Color(0xFF0000FF),
      );
      final NemoThemeData green = NemoThemeData.light(
        seedColor: const Color(0xFF00AA55),
      );

      expect(blue.semantic.primary, isNot(green.semantic.primary));
      expect(blue.components.controlMinHeight, 48);
    });

    test('factory accepts group-level token overrides', () {
      const NemoMotionTokens motion = NemoMotionTokens.reduced;
      final NemoThemeData theme = NemoThemeData.dark(
        overrides: const NemoThemeOverrides(motion: motion),
      );

      expect(theme.motion.standard, Duration.zero);
    });

    test(
      'high contrast removes depth-only shadows and strengthens outlines',
      () {
        final NemoThemeData theme = NemoThemeData.highContrast();

        expect(theme.semantic.highlightShadow, Colors.transparent);
        expect(theme.semantic.lowlightShadow, Colors.transparent);
        expect(theme.components.outlineWidth, 2);
      },
    );

    test('token groups support individual overrides', () {
      final NemoFoundationTokens foundation = NemoFoundationTokens.standard
          .copyWith(radiusLarge: 32);
      final NemoSemanticTokens semantic = NemoThemeData.light().semantic
          .copyWith(focusRing: Colors.orange);
      final NemoComponentTokens components = NemoComponentTokens.standard
          .copyWith(controlMinHeight: 52);

      expect(foundation.radiusLarge, 32);
      expect(foundation.space16, NemoFoundationTokens.standard.space16);
      expect(semantic.focusRing, Colors.orange);
      expect(semantic.primary, NemoThemeData.light().semantic.primary);
      expect(components.controlMinHeight, 52);
      expect(
        components.outlineWidth,
        NemoComponentTokens.standard.outlineWidth,
      );
      expect(components.button, NemoButtonTokens.standard);
    });

    test(
      'button tokens support copy, equality, state lookup, and interpolation',
      () {
        final NemoButtonTokens base = NemoButtonTokens.standard;
        final NemoButtonTokens changed = base.copyWith(
          pressed: base.pressed.copyWith(foregroundBlend: .2),
        );

        expect(base.copyWith(), base);
        expect(changed, isNot(base));
        expect(changed.styleFor(NemoButtonState.pressed).foregroundBlend, .2);
        expect(base.resting.accentOpacity, greaterThan(0));
        expect(base.pressed.insetShadowOpacity, greaterThan(0));
        expect(base.resting.insetShadowOpacity, 0);
        expect(NemoButtonTokens.lerp(base, changed, 1), changed);
        expect(NemoButtonTokens.highContrast.pressed.shadowOpacity, 0);
        expect(NemoButtonTokens.highContrast.pressed.insetShadowOpacity, 0);
      },
    );

    test(
      'button content and progress meet contrast on rendered state bodies',
      () {
        for (final NemoThemeData theme in <NemoThemeData>[
          NemoThemeData.light(),
          NemoThemeData.dark(),
          NemoThemeData.highContrast(),
        ]) {
          for (final NemoButtonState state in NemoButtonState.values) {
            final NemoButtonStateStyle style = theme.components.button.styleFor(
              state,
            );
            final bool inactive =
                state == NemoButtonState.disabled ||
                state == NemoButtonState.loading;
            Color body = inactive
                ? theme.semantic.surfaceVariant
                : Color.lerp(
                    theme.semantic.surface,
                    theme.semantic.surfaceVariant,
                    style.surfaceVariantBlend,
                  )!;
            if (!inactive) {
              body = Color.lerp(
                body,
                theme.semantic.foreground,
                style.foregroundBlend,
              )!;
              body = Color.lerp(
                body,
                theme.semantic.primary,
                style.accentOpacity,
              )!;
            }
            final Color content = state == NemoButtonState.disabled
                ? theme.semantic.mutedForeground
                : theme.semantic.primary;

            expect(
              _contrastRatio(content, body),
              greaterThanOrEqualTo(4.5),
              reason: '${theme.semantic.surface.toARGB32()} ${state.name}',
            );
          }
        }
      },
    );

    test('switch tokens support copy, equality, and interpolation', () {
      final NemoSwitchTokens base = NemoSwitchTokens.standard;
      final NemoSwitchTokens changed = base.copyWith(trackWidth: 56);

      expect(base.copyWith(), base);
      expect(changed, isNot(base));
      expect(NemoSwitchTokens.lerp(base, changed, 1), changed);
      expect(NemoSwitchTokens.highContrast.trackOutlineOpacity, 1);
      expect(NemoComponentTokens.standard.switchControl, base);
    });

    test('lerp interpolates token values', () {
      final NemoThemeData light = NemoThemeData.light();
      final NemoThemeData dark = NemoThemeData.dark();

      final NemoThemeData halfway = light.lerp(dark, 0.5);

      expect(halfway.foundation.shadowOffset, 8);
      expect(halfway.semantic.surface, isNot(light.semantic.surface));
      expect(halfway.semantic.surface, isNot(dark.semantic.surface));
    });
  });
}

double _contrastRatio(Color a, Color b) {
  final double lighter = a.computeLuminance() > b.computeLuminance()
      ? a.computeLuminance()
      : b.computeLuminance();
  final double darker = a.computeLuminance() > b.computeLuminance()
      ? b.computeLuminance()
      : a.computeLuminance();
  return (lighter + .05) / (darker + .05);
}
