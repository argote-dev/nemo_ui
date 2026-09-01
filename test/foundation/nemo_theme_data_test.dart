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
        expect(NemoButtonTokens.lerp(base, changed, 1), changed);
        expect(NemoButtonTokens.highContrast.pressed.shadowOpacity, 0);
      },
    );

    test('switch tokens support copy, equality, and interpolation', () {
      final NemoSwitchTokens base = NemoSwitchTokens.standard;
      final NemoSwitchTokens changed = base.copyWith(
        trackWidth: 56,
        on: base.on.copyWith(thumbPrimaryBlend: .4),
      );

      expect(base.copyWith(), base);
      expect(changed, isNot(base));
      expect(changed.on.thumbPrimaryBlend, .4);
      expect(NemoSwitchTokens.lerp(base, changed, 1), changed);
      expect(NemoSwitchTokens.highContrast.trackOutlineOpacity, 1);
      expect(NemoSwitchTokens.standard.off.trackShadowOpacity, greaterThan(0));
      expect(NemoSwitchTokens.standard.on.thumbShadowOpacity, greaterThan(0));
      expect(NemoSwitchTokens.highContrast.off.trackShadowOpacity, 0);
      expect(NemoSwitchTokens.highContrast.on.thumbShadowOpacity, 0);
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
