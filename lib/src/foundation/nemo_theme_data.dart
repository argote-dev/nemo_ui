import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'nemo_motion.dart';
import 'nemo_surface_contract.dart';

/// Foundational, semantic, and component-ready design tokens for Nemo.
@immutable
final class NemoThemeData extends ThemeExtension<NemoThemeData> {
  /// Creates an immutable Nemo theme from token groups.
  const NemoThemeData({
    required this.foundation,
    required this.semantic,
    required this.components,
    required this.motion,
  });

  /// Spacing, radius, and depth values shared by the system.
  final NemoFoundationTokens foundation;

  /// Colors and visual treatment with semantic meaning.
  final NemoSemanticTokens semantic;

  /// Tokens reserved for component-level contracts.
  final NemoComponentTokens components;

  /// Semantic timing and curves for tactile interactions.
  final NemoMotionTokens motion;

  /// Creates Nemo's soft light theme from a [seedColor].
  factory NemoThemeData.light({
    Color seedColor = const Color(0xFF4F6EF7),
    NemoThemeOverrides overrides = const NemoThemeOverrides(),
  }) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );
    final Color surface = const Color(0xFFF1F4F9);
    final NemoThemeData base = NemoThemeData(
      foundation: NemoFoundationTokens.standard,
      semantic: NemoSemanticTokens(
        surface: surface,
        surfaceVariant: scheme.surfaceContainerHighest,
        foreground: scheme.onSurface,
        mutedForeground: scheme.onSurfaceVariant,
        primary: scheme.primary,
        onPrimary: scheme.onPrimary,
        success: const Color(0xFF147A4A),
        error: scheme.error,
        onError: scheme.onError,
        focusRing: scheme.primary,
        outline: scheme.outlineVariant,
        highlightShadow: Colors.white.withValues(alpha: 0.92),
        lowlightShadow: const Color(0xFFB8C1D0),
      ),
      components: NemoComponentTokens.standard,
      motion: NemoMotionTokens.standardTokens,
    );
    return overrides.applyTo(base);
  }

  /// Creates Nemo's soft dark theme from a [seedColor].
  factory NemoThemeData.dark({
    Color seedColor = const Color(0xFF9DB0FF),
    NemoThemeOverrides overrides = const NemoThemeOverrides(),
  }) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );
    final Color surface = const Color(0xFF1B202A);
    final NemoThemeData base = NemoThemeData(
      foundation: NemoFoundationTokens.standard,
      semantic: NemoSemanticTokens(
        surface: surface,
        surfaceVariant: scheme.surfaceContainerHighest,
        foreground: scheme.onSurface,
        mutedForeground: scheme.onSurfaceVariant,
        primary: scheme.primary,
        onPrimary: scheme.onPrimary,
        success: const Color(0xFF6ED6A3),
        error: scheme.error,
        onError: scheme.onError,
        focusRing: scheme.primary,
        outline: scheme.outline,
        highlightShadow: const Color(0xFF303847),
        lowlightShadow: Colors.black.withValues(alpha: 0.72),
      ),
      components: NemoComponentTokens.standard,
      motion: NemoMotionTokens.standardTokens,
    );
    return overrides.applyTo(base);
  }

  /// Creates a high-contrast theme from a [seedColor].
  factory NemoThemeData.highContrast({
    Color seedColor = const Color(0xFF003DCC),
    Brightness brightness = Brightness.light,
    NemoThemeOverrides overrides = const NemoThemeOverrides(),
  }) {
    final bool isDark = brightness == Brightness.dark;
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      contrastLevel: 1,
    );
    final NemoThemeData base = NemoThemeData(
      foundation: NemoFoundationTokens.standard,
      semantic: NemoSemanticTokens(
        surface: isDark ? Colors.black : Colors.white,
        surfaceVariant: isDark
            ? const Color(0xFF181818)
            : const Color(0xFFF5F5F5),
        foreground: isDark ? Colors.white : Colors.black,
        mutedForeground: isDark
            ? const Color(0xFFE0E0E0)
            : const Color(0xFF353535),
        primary: scheme.primary,
        onPrimary: scheme.onPrimary,
        success: isDark ? const Color(0xFF75F5AF) : const Color(0xFF006B35),
        error: scheme.error,
        onError: scheme.onError,
        focusRing: isDark ? Colors.white : Colors.black,
        outline: isDark ? Colors.white : Colors.black,
        highlightShadow: Colors.transparent,
        lowlightShadow: Colors.transparent,
      ),
      components: NemoComponentTokens.highContrast,
      motion: NemoMotionTokens.standardTokens,
    );
    return overrides.applyTo(base);
  }

  @override
  NemoThemeData copyWith({
    NemoFoundationTokens? foundation,
    NemoSemanticTokens? semantic,
    NemoComponentTokens? components,
    NemoMotionTokens? motion,
  }) {
    return NemoThemeData(
      foundation: foundation ?? this.foundation,
      semantic: semantic ?? this.semantic,
      components: components ?? this.components,
      motion: motion ?? this.motion,
    );
  }

  @override
  NemoThemeData lerp(covariant NemoThemeData? other, double t) {
    if (other == null) {
      return this;
    }
    return NemoThemeData(
      foundation: NemoFoundationTokens.lerp(foundation, other.foundation, t),
      semantic: NemoSemanticTokens.lerp(semantic, other.semantic, t),
      components: NemoComponentTokens.lerp(components, other.components, t),
      motion: NemoMotionTokens.lerp(motion, other.motion, t),
    );
  }
}

/// Foundational spacing, radius, and visual-depth tokens.
@immutable
final class NemoFoundationTokens {
  /// Creates foundational tokens.
  const NemoFoundationTokens({
    required this.space2,
    required this.space4,
    required this.space8,
    required this.space12,
    required this.space16,
    required this.space24,
    required this.radiusSmall,
    required this.radiusMedium,
    required this.radiusLarge,
    required this.shadowBlur,
    required this.shadowOffset,
  });

  /// The smallest spacing increment.
  final double space2;

  /// A compact spacing increment.
  final double space4;

  /// The default compact gap.
  final double space8;

  /// A standard control gap.
  final double space12;

  /// A standard content gap.
  final double space16;

  /// A large content gap.
  final double space24;

  /// A compact corner radius.
  final double radiusSmall;

  /// The default component corner radius.
  final double radiusMedium;

  /// A large container corner radius.
  final double radiusLarge;

  /// The blur applied to tactile shadows.
  final double shadowBlur;

  /// The offset applied to tactile shadows.
  final double shadowOffset;

  /// The default foundational scale.
  static const NemoFoundationTokens standard = NemoFoundationTokens(
    space2: 2,
    space4: 4,
    space8: 8,
    space12: 12,
    space16: 16,
    space24: 24,
    radiusSmall: 10,
    radiusMedium: 16,
    radiusLarge: 24,
    shadowBlur: 18,
    shadowOffset: 8,
  );

  /// Creates a copy with selectively replaced foundational values.
  NemoFoundationTokens copyWith({
    double? space2,
    double? space4,
    double? space8,
    double? space12,
    double? space16,
    double? space24,
    double? radiusSmall,
    double? radiusMedium,
    double? radiusLarge,
    double? shadowBlur,
    double? shadowOffset,
  }) {
    return NemoFoundationTokens(
      space2: space2 ?? this.space2,
      space4: space4 ?? this.space4,
      space8: space8 ?? this.space8,
      space12: space12 ?? this.space12,
      space16: space16 ?? this.space16,
      space24: space24 ?? this.space24,
      radiusSmall: radiusSmall ?? this.radiusSmall,
      radiusMedium: radiusMedium ?? this.radiusMedium,
      radiusLarge: radiusLarge ?? this.radiusLarge,
      shadowBlur: shadowBlur ?? this.shadowBlur,
      shadowOffset: shadowOffset ?? this.shadowOffset,
    );
  }

  /// Interpolates foundational tokens.
  static NemoFoundationTokens lerp(
    NemoFoundationTokens a,
    NemoFoundationTokens b,
    double t,
  ) {
    return NemoFoundationTokens(
      space2: lerpDouble(a.space2, b.space2, t)!,
      space4: lerpDouble(a.space4, b.space4, t)!,
      space8: lerpDouble(a.space8, b.space8, t)!,
      space12: lerpDouble(a.space12, b.space12, t)!,
      space16: lerpDouble(a.space16, b.space16, t)!,
      space24: lerpDouble(a.space24, b.space24, t)!,
      radiusSmall: lerpDouble(a.radiusSmall, b.radiusSmall, t)!,
      radiusMedium: lerpDouble(a.radiusMedium, b.radiusMedium, t)!,
      radiusLarge: lerpDouble(a.radiusLarge, b.radiusLarge, t)!,
      shadowBlur: lerpDouble(a.shadowBlur, b.shadowBlur, t)!,
      shadowOffset: lerpDouble(a.shadowOffset, b.shadowOffset, t)!,
    );
  }
}

/// Semantic color and depth tokens.
@immutable
final class NemoSemanticTokens {
  /// Creates semantic tokens.
  const NemoSemanticTokens({
    required this.surface,
    required this.surfaceVariant,
    required this.foreground,
    required this.mutedForeground,
    required this.primary,
    required this.onPrimary,
    required this.success,
    required this.error,
    required this.onError,
    required this.focusRing,
    required this.outline,
    required this.highlightShadow,
    required this.lowlightShadow,
  });

  /// The primary canvas color.
  final Color surface;

  /// A differentiated, still-soft surface color.
  final Color surfaceVariant;

  /// The default foreground color.
  final Color foreground;

  /// A lower-emphasis foreground color.
  final Color mutedForeground;

  /// The primary action color.
  final Color primary;

  /// The foreground color on [primary].
  final Color onPrimary;

  /// The positive-state color.
  final Color success;

  /// The error-state color.
  final Color error;

  /// The foreground color on [error].
  final Color onError;

  /// The visible keyboard focus indicator.
  final Color focusRing;

  /// A thin tonal or high-contrast boundary.
  final Color outline;

  /// The light-facing tactile shadow.
  final Color highlightShadow;

  /// The dark-facing tactile shadow.
  final Color lowlightShadow;

  /// Creates a copy with selectively replaced semantic values.
  NemoSemanticTokens copyWith({
    Color? surface,
    Color? surfaceVariant,
    Color? foreground,
    Color? mutedForeground,
    Color? primary,
    Color? onPrimary,
    Color? success,
    Color? error,
    Color? onError,
    Color? focusRing,
    Color? outline,
    Color? highlightShadow,
    Color? lowlightShadow,
  }) {
    return NemoSemanticTokens(
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      foreground: foreground ?? this.foreground,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      success: success ?? this.success,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      focusRing: focusRing ?? this.focusRing,
      outline: outline ?? this.outline,
      highlightShadow: highlightShadow ?? this.highlightShadow,
      lowlightShadow: lowlightShadow ?? this.lowlightShadow,
    );
  }

  /// Interpolates semantic tokens.
  static NemoSemanticTokens lerp(
    NemoSemanticTokens a,
    NemoSemanticTokens b,
    double t,
  ) {
    return NemoSemanticTokens(
      surface: Color.lerp(a.surface, b.surface, t)!,
      surfaceVariant: Color.lerp(a.surfaceVariant, b.surfaceVariant, t)!,
      foreground: Color.lerp(a.foreground, b.foreground, t)!,
      mutedForeground: Color.lerp(a.mutedForeground, b.mutedForeground, t)!,
      primary: Color.lerp(a.primary, b.primary, t)!,
      onPrimary: Color.lerp(a.onPrimary, b.onPrimary, t)!,
      success: Color.lerp(a.success, b.success, t)!,
      error: Color.lerp(a.error, b.error, t)!,
      onError: Color.lerp(a.onError, b.onError, t)!,
      focusRing: Color.lerp(a.focusRing, b.focusRing, t)!,
      outline: Color.lerp(a.outline, b.outline, t)!,
      highlightShadow: Color.lerp(a.highlightShadow, b.highlightShadow, t)!,
      lowlightShadow: Color.lerp(a.lowlightShadow, b.lowlightShadow, t)!,
    );
  }
}

/// Tokens intended for reusable component contracts.
@immutable
final class NemoComponentTokens {
  /// Creates component-ready tokens.
  const NemoComponentTokens({
    required this.controlMinHeight,
    required this.controlHorizontalPadding,
    required this.focusRingWidth,
    required this.outlineWidth,
    required this.surface,
    required this.button,
    required this.switchControl,
  });

  /// The minimum interactive control height.
  final double controlMinHeight;

  /// The horizontal padding for interactive controls.
  final double controlHorizontalPadding;

  /// The width of the visible focus ring.
  final double focusRingWidth;

  /// The default tonal outline width.
  final double outlineWidth;

  /// Visual contract for [NemoSurface].
  final NemoSurfaceTokens surface;

  /// Visual contract for [NemoButton].
  final NemoButtonTokens button;

  /// Visual contract for [NemoSwitch].
  final NemoSwitchTokens switchControl;

  /// The standard component contract.
  static const NemoComponentTokens standard = NemoComponentTokens(
    controlMinHeight: 48,
    controlHorizontalPadding: 16,
    focusRingWidth: 3,
    outlineWidth: 1,
    surface: NemoSurfaceTokens.standard,
    button: NemoButtonTokens.standard,
    switchControl: NemoSwitchTokens.standard,
  );

  /// The high-contrast component contract.
  static const NemoComponentTokens highContrast = NemoComponentTokens(
    controlMinHeight: 48,
    controlHorizontalPadding: 16,
    focusRingWidth: 3,
    outlineWidth: 2,
    surface: NemoSurfaceTokens.highContrast,
    button: NemoButtonTokens.highContrast,
    switchControl: NemoSwitchTokens.highContrast,
  );

  /// Creates a copy with selectively replaced component values.
  NemoComponentTokens copyWith({
    double? controlMinHeight,
    double? controlHorizontalPadding,
    double? focusRingWidth,
    double? outlineWidth,
    NemoSurfaceTokens? surface,
    NemoButtonTokens? button,
    NemoSwitchTokens? switchControl,
  }) {
    return NemoComponentTokens(
      controlMinHeight: controlMinHeight ?? this.controlMinHeight,
      controlHorizontalPadding:
          controlHorizontalPadding ?? this.controlHorizontalPadding,
      focusRingWidth: focusRingWidth ?? this.focusRingWidth,
      outlineWidth: outlineWidth ?? this.outlineWidth,
      surface: surface ?? this.surface,
      button: button ?? this.button,
      switchControl: switchControl ?? this.switchControl,
    );
  }

  /// Interpolates component tokens.
  static NemoComponentTokens lerp(
    NemoComponentTokens a,
    NemoComponentTokens b,
    double t,
  ) {
    return NemoComponentTokens(
      controlMinHeight: lerpDouble(a.controlMinHeight, b.controlMinHeight, t)!,
      controlHorizontalPadding: lerpDouble(
        a.controlHorizontalPadding,
        b.controlHorizontalPadding,
        t,
      )!,
      focusRingWidth: lerpDouble(a.focusRingWidth, b.focusRingWidth, t)!,
      outlineWidth: lerpDouble(a.outlineWidth, b.outlineWidth, t)!,
      surface: NemoSurfaceTokens.lerp(a.surface, b.surface, t),
      button: NemoButtonTokens.lerp(a.button, b.button, t),
      switchControl: NemoSwitchTokens.lerp(a.switchControl, b.switchControl, t),
    );
  }
}

/// Visual values for the controlled [NemoSwitch] component.
@immutable
final class NemoSwitchTokens {
  /// Creates switch visual tokens.
  const NemoSwitchTokens({
    required this.trackWidth,
    required this.trackHeight,
    required this.thumbDiameter,
    required this.trackOutlineOpacity,
    required this.disabledOpacity,
    required this.off,
    required this.on,
  });

  /// The horizontal track extent.
  final double trackWidth;

  /// The vertical track extent.
  final double trackHeight;

  /// The thumb diameter.
  final double thumbDiameter;

  /// Opacity applied to the explicit track boundary.
  final double trackOutlineOpacity;

  /// Opacity applied while unavailable.
  final double disabledOpacity;

  /// The tactile treatment for the off state.
  final NemoSwitchStateStyle off;

  /// The tactile treatment for the on state.
  final NemoSwitchStateStyle on;

  /// Default soft-neumorphic switch values.
  static const NemoSwitchTokens standard = NemoSwitchTokens(
    trackWidth: 52,
    trackHeight: 32,
    thumbDiameter: 24,
    trackOutlineOpacity: .72,
    disabledOpacity: .5,
    off: NemoSwitchStateStyle(
      trackPrimaryBlend: .035,
      thumbPrimaryBlend: .08,
      trackShadowOpacity: .42,
      trackShadowBlurMultiplier: .45,
      trackShadowOffsetMultiplier: .38,
      thumbShadowOpacity: .48,
      thumbShadowBlurMultiplier: .42,
      thumbShadowOffsetMultiplier: .38,
    ),
    on: NemoSwitchStateStyle(
      trackPrimaryBlend: .18,
      thumbPrimaryBlend: .32,
      trackShadowOpacity: .42,
      trackShadowBlurMultiplier: .45,
      trackShadowOffsetMultiplier: .38,
      thumbShadowOpacity: .5,
      thumbShadowBlurMultiplier: .42,
      thumbShadowOffsetMultiplier: .38,
    ),
  );

  /// High-contrast switch values preserve the explicit boundary.
  static const NemoSwitchTokens highContrast = NemoSwitchTokens(
    trackWidth: 52,
    trackHeight: 32,
    thumbDiameter: 24,
    trackOutlineOpacity: 1,
    disabledOpacity: .62,
    off: NemoSwitchStateStyle(
      trackPrimaryBlend: 0,
      thumbPrimaryBlend: 0,
      trackShadowOpacity: 0,
      trackShadowBlurMultiplier: 0,
      trackShadowOffsetMultiplier: 0,
      thumbShadowOpacity: 0,
      thumbShadowBlurMultiplier: 0,
      thumbShadowOffsetMultiplier: 0,
    ),
    on: NemoSwitchStateStyle(
      trackPrimaryBlend: .22,
      thumbPrimaryBlend: .42,
      trackShadowOpacity: 0,
      trackShadowBlurMultiplier: 0,
      trackShadowOffsetMultiplier: 0,
      thumbShadowOpacity: 0,
      thumbShadowBlurMultiplier: 0,
      thumbShadowOffsetMultiplier: 0,
    ),
  );

  /// Creates a copy with selectively replaced values.
  NemoSwitchTokens copyWith({
    double? trackWidth,
    double? trackHeight,
    double? thumbDiameter,
    double? trackOutlineOpacity,
    double? disabledOpacity,
    NemoSwitchStateStyle? off,
    NemoSwitchStateStyle? on,
  }) => NemoSwitchTokens(
    trackWidth: trackWidth ?? this.trackWidth,
    trackHeight: trackHeight ?? this.trackHeight,
    thumbDiameter: thumbDiameter ?? this.thumbDiameter,
    trackOutlineOpacity: trackOutlineOpacity ?? this.trackOutlineOpacity,
    disabledOpacity: disabledOpacity ?? this.disabledOpacity,
    off: off ?? this.off,
    on: on ?? this.on,
  );

  /// Interpolates switch tokens.
  static NemoSwitchTokens lerp(
    NemoSwitchTokens a,
    NemoSwitchTokens b,
    double t,
  ) => NemoSwitchTokens(
    trackWidth: lerpDouble(a.trackWidth, b.trackWidth, t)!,
    trackHeight: lerpDouble(a.trackHeight, b.trackHeight, t)!,
    thumbDiameter: lerpDouble(a.thumbDiameter, b.thumbDiameter, t)!,
    trackOutlineOpacity: lerpDouble(
      a.trackOutlineOpacity,
      b.trackOutlineOpacity,
      t,
    )!,
    disabledOpacity: lerpDouble(a.disabledOpacity, b.disabledOpacity, t)!,
    off: NemoSwitchStateStyle.lerp(a.off, b.off, t),
    on: NemoSwitchStateStyle.lerp(a.on, b.on, t),
  );

  @override
  bool operator ==(Object other) =>
      other is NemoSwitchTokens &&
      trackWidth == other.trackWidth &&
      trackHeight == other.trackHeight &&
      thumbDiameter == other.thumbDiameter &&
      trackOutlineOpacity == other.trackOutlineOpacity &&
      disabledOpacity == other.disabledOpacity &&
      off == other.off &&
      on == other.on;

  @override
  int get hashCode => Object.hash(
    trackWidth,
    trackHeight,
    thumbDiameter,
    trackOutlineOpacity,
    disabledOpacity,
    off,
    on,
  );
}

/// State-specific relief and tonal values for [NemoSwitch].
@immutable
final class NemoSwitchStateStyle {
  /// Creates a switch state treatment.
  const NemoSwitchStateStyle({
    required this.trackPrimaryBlend,
    required this.thumbPrimaryBlend,
    required this.trackShadowOpacity,
    required this.trackShadowBlurMultiplier,
    required this.trackShadowOffsetMultiplier,
    required this.thumbShadowOpacity,
    required this.thumbShadowBlurMultiplier,
    required this.thumbShadowOffsetMultiplier,
  });

  /// Primary blend applied to the sunken track.
  final double trackPrimaryBlend;

  /// Primary blend applied to the raised thumb.
  final double thumbPrimaryBlend;

  /// Opacity of the track's paired inset shadows.
  final double trackShadowOpacity;

  /// Foundation blur multiplier for the track's inset shadows.
  final double trackShadowBlurMultiplier;

  /// Foundation offset multiplier for the track's inset shadows.
  final double trackShadowOffsetMultiplier;

  /// Opacity of the thumb's paired outer shadows.
  final double thumbShadowOpacity;

  /// Foundation blur multiplier for the thumb's outer shadows.
  final double thumbShadowBlurMultiplier;

  /// Foundation offset multiplier for the thumb's outer shadows.
  final double thumbShadowOffsetMultiplier;

  /// Creates a copy with selectively replaced values.
  NemoSwitchStateStyle copyWith({
    double? trackPrimaryBlend,
    double? thumbPrimaryBlend,
    double? trackShadowOpacity,
    double? trackShadowBlurMultiplier,
    double? trackShadowOffsetMultiplier,
    double? thumbShadowOpacity,
    double? thumbShadowBlurMultiplier,
    double? thumbShadowOffsetMultiplier,
  }) => NemoSwitchStateStyle(
    trackPrimaryBlend: trackPrimaryBlend ?? this.trackPrimaryBlend,
    thumbPrimaryBlend: thumbPrimaryBlend ?? this.thumbPrimaryBlend,
    trackShadowOpacity: trackShadowOpacity ?? this.trackShadowOpacity,
    trackShadowBlurMultiplier:
        trackShadowBlurMultiplier ?? this.trackShadowBlurMultiplier,
    trackShadowOffsetMultiplier:
        trackShadowOffsetMultiplier ?? this.trackShadowOffsetMultiplier,
    thumbShadowOpacity: thumbShadowOpacity ?? this.thumbShadowOpacity,
    thumbShadowBlurMultiplier:
        thumbShadowBlurMultiplier ?? this.thumbShadowBlurMultiplier,
    thumbShadowOffsetMultiplier:
        thumbShadowOffsetMultiplier ?? this.thumbShadowOffsetMultiplier,
  );

  /// Interpolates between two state treatments.
  static NemoSwitchStateStyle lerp(
    NemoSwitchStateStyle a,
    NemoSwitchStateStyle b,
    double t,
  ) => NemoSwitchStateStyle(
    trackPrimaryBlend: lerpDouble(a.trackPrimaryBlend, b.trackPrimaryBlend, t)!,
    thumbPrimaryBlend: lerpDouble(a.thumbPrimaryBlend, b.thumbPrimaryBlend, t)!,
    trackShadowOpacity: lerpDouble(
      a.trackShadowOpacity,
      b.trackShadowOpacity,
      t,
    )!,
    trackShadowBlurMultiplier: lerpDouble(
      a.trackShadowBlurMultiplier,
      b.trackShadowBlurMultiplier,
      t,
    )!,
    trackShadowOffsetMultiplier: lerpDouble(
      a.trackShadowOffsetMultiplier,
      b.trackShadowOffsetMultiplier,
      t,
    )!,
    thumbShadowOpacity: lerpDouble(
      a.thumbShadowOpacity,
      b.thumbShadowOpacity,
      t,
    )!,
    thumbShadowBlurMultiplier: lerpDouble(
      a.thumbShadowBlurMultiplier,
      b.thumbShadowBlurMultiplier,
      t,
    )!,
    thumbShadowOffsetMultiplier: lerpDouble(
      a.thumbShadowOffsetMultiplier,
      b.thumbShadowOffsetMultiplier,
      t,
    )!,
  );

  @override
  bool operator ==(Object other) =>
      other is NemoSwitchStateStyle &&
      trackPrimaryBlend == other.trackPrimaryBlend &&
      thumbPrimaryBlend == other.thumbPrimaryBlend &&
      trackShadowOpacity == other.trackShadowOpacity &&
      trackShadowBlurMultiplier == other.trackShadowBlurMultiplier &&
      trackShadowOffsetMultiplier == other.trackShadowOffsetMultiplier &&
      thumbShadowOpacity == other.thumbShadowOpacity &&
      thumbShadowBlurMultiplier == other.thumbShadowBlurMultiplier &&
      thumbShadowOffsetMultiplier == other.thumbShadowOffsetMultiplier;

  @override
  int get hashCode => Object.hash(
    trackPrimaryBlend,
    thumbPrimaryBlend,
    trackShadowOpacity,
    trackShadowBlurMultiplier,
    trackShadowOffsetMultiplier,
    thumbShadowOpacity,
    thumbShadowBlurMultiplier,
    thumbShadowOffsetMultiplier,
  );
}

/// The component-level visual values for a Nemo primary button.
@immutable
final class NemoButtonTokens {
  /// Creates visual values for each [NemoButton] state.
  const NemoButtonTokens({
    required this.resting,
    required this.hovered,
    required this.focused,
    required this.pressed,
    required this.disabled,
    required this.loading,
    required this.progressIndicatorSize,
    required this.progressIndicatorStrokeWidth,
  });

  /// The default active visual treatment.
  final NemoButtonStateStyle resting;

  /// The mouse-hover visual treatment.
  final NemoButtonStateStyle hovered;

  /// The keyboard-focus visual treatment.
  final NemoButtonStateStyle focused;

  /// The active press visual treatment.
  final NemoButtonStateStyle pressed;

  /// The unavailable visual treatment.
  final NemoButtonStateStyle disabled;

  /// The system-owned loading visual treatment.
  final NemoButtonStateStyle loading;

  /// The progress affordance's square size.
  final double progressIndicatorSize;

  /// The stroke width for the animated progress affordance.
  final double progressIndicatorStrokeWidth;

  /// Default soft-neumorphic button values.
  static const NemoButtonTokens standard = NemoButtonTokens(
    resting: NemoButtonStateStyle(
      foregroundBlend: 0,
      shadowOffsetMultiplier: 1,
      shadowBlurMultiplier: 1,
      shadowOpacity: .5,
      outlineOpacity: .55,
      accentOpacity: .02,
    ),
    hovered: NemoButtonStateStyle(
      foregroundBlend: .024,
      shadowOffsetMultiplier: .94,
      shadowBlurMultiplier: .94,
      shadowOpacity: .55,
      outlineOpacity: .6,
      surfaceVariantBlend: .024,
      accentOpacity: .024,
    ),
    focused: NemoButtonStateStyle(
      foregroundBlend: .036,
      shadowOffsetMultiplier: .9,
      shadowBlurMultiplier: .9,
      shadowOpacity: .55,
      outlineOpacity: .65,
      surfaceVariantBlend: .036,
      accentOpacity: .0242,
    ),
    pressed: NemoButtonStateStyle(
      foregroundBlend: .06,
      shadowOffsetMultiplier: .28,
      shadowBlurMultiplier: .45,
      shadowOpacity: 0,
      outlineOpacity: .7,
      surfaceVariantBlend: .08,
      accentOpacity: .0244,
      insetShadowOpacity: .5,
    ),
    disabled: NemoButtonStateStyle(
      foregroundBlend: 0,
      shadowOffsetMultiplier: 0,
      shadowBlurMultiplier: 0,
      shadowOpacity: 0,
      outlineOpacity: .8,
    ),
    loading: NemoButtonStateStyle(
      foregroundBlend: 0,
      shadowOffsetMultiplier: 0,
      shadowBlurMultiplier: 0,
      shadowOpacity: 0,
      outlineOpacity: .8,
    ),
    progressIndicatorSize: 18,
    progressIndicatorStrokeWidth: 2,
  );

  /// High-contrast values remove decorative shadows while retaining boundaries.
  static const NemoButtonTokens highContrast = NemoButtonTokens(
    resting: NemoButtonStateStyle(
      foregroundBlend: 0,
      shadowOffsetMultiplier: 0,
      shadowBlurMultiplier: 0,
      shadowOpacity: 0,
      outlineOpacity: 1,
      accentOpacity: .02,
    ),
    hovered: NemoButtonStateStyle(
      foregroundBlend: .08,
      shadowOffsetMultiplier: 0,
      shadowBlurMultiplier: 0,
      shadowOpacity: 0,
      outlineOpacity: 1,
      surfaceVariantBlend: .08,
      accentOpacity: .024,
    ),
    focused: NemoButtonStateStyle(
      foregroundBlend: .1,
      shadowOffsetMultiplier: 0,
      shadowBlurMultiplier: 0,
      shadowOpacity: 0,
      outlineOpacity: 1,
      surfaceVariantBlend: .1,
      accentOpacity: .0242,
    ),
    pressed: NemoButtonStateStyle(
      foregroundBlend: .08,
      shadowOffsetMultiplier: 0,
      shadowBlurMultiplier: 0,
      shadowOpacity: 0,
      outlineOpacity: 1,
      surfaceVariantBlend: .16,
      accentOpacity: .0244,
    ),
    disabled: NemoButtonStateStyle(
      foregroundBlend: 0,
      shadowOffsetMultiplier: 0,
      shadowBlurMultiplier: 0,
      shadowOpacity: 0,
      outlineOpacity: 1,
    ),
    loading: NemoButtonStateStyle(
      foregroundBlend: 0,
      shadowOffsetMultiplier: 0,
      shadowBlurMultiplier: 0,
      shadowOpacity: 0,
      outlineOpacity: 1,
    ),
    progressIndicatorSize: 18,
    progressIndicatorStrokeWidth: 2,
  );

  /// Returns the styling for a supported [NemoButtonState].
  NemoButtonStateStyle styleFor(NemoButtonState state) => switch (state) {
    NemoButtonState.resting => resting,
    NemoButtonState.hovered => hovered,
    NemoButtonState.focused => focused,
    NemoButtonState.pressed => pressed,
    NemoButtonState.disabled => disabled,
    NemoButtonState.loading => loading,
  };

  /// Creates a copy with selectively replaced values.
  NemoButtonTokens copyWith({
    NemoButtonStateStyle? resting,
    NemoButtonStateStyle? hovered,
    NemoButtonStateStyle? focused,
    NemoButtonStateStyle? pressed,
    NemoButtonStateStyle? disabled,
    NemoButtonStateStyle? loading,
    double? progressIndicatorSize,
    double? progressIndicatorStrokeWidth,
  }) => NemoButtonTokens(
    resting: resting ?? this.resting,
    hovered: hovered ?? this.hovered,
    focused: focused ?? this.focused,
    pressed: pressed ?? this.pressed,
    disabled: disabled ?? this.disabled,
    loading: loading ?? this.loading,
    progressIndicatorSize: progressIndicatorSize ?? this.progressIndicatorSize,
    progressIndicatorStrokeWidth:
        progressIndicatorStrokeWidth ?? this.progressIndicatorStrokeWidth,
  );

  /// Interpolates button tokens.
  static NemoButtonTokens lerp(
    NemoButtonTokens a,
    NemoButtonTokens b,
    double t,
  ) => NemoButtonTokens(
    resting: NemoButtonStateStyle.lerp(a.resting, b.resting, t),
    hovered: NemoButtonStateStyle.lerp(a.hovered, b.hovered, t),
    focused: NemoButtonStateStyle.lerp(a.focused, b.focused, t),
    pressed: NemoButtonStateStyle.lerp(a.pressed, b.pressed, t),
    disabled: NemoButtonStateStyle.lerp(a.disabled, b.disabled, t),
    loading: NemoButtonStateStyle.lerp(a.loading, b.loading, t),
    progressIndicatorSize: lerpDouble(
      a.progressIndicatorSize,
      b.progressIndicatorSize,
      t,
    )!,
    progressIndicatorStrokeWidth: lerpDouble(
      a.progressIndicatorStrokeWidth,
      b.progressIndicatorStrokeWidth,
      t,
    )!,
  );

  @override
  bool operator ==(Object other) =>
      other is NemoButtonTokens &&
      resting == other.resting &&
      hovered == other.hovered &&
      focused == other.focused &&
      pressed == other.pressed &&
      disabled == other.disabled &&
      loading == other.loading &&
      progressIndicatorSize == other.progressIndicatorSize &&
      progressIndicatorStrokeWidth == other.progressIndicatorStrokeWidth;

  @override
  int get hashCode => Object.hash(
    resting,
    hovered,
    focused,
    pressed,
    disabled,
    loading,
    progressIndicatorSize,
    progressIndicatorStrokeWidth,
  );
}

/// The finite interaction states rendered by [NemoButton].
enum NemoButtonState {
  /// The enabled default state.
  resting,

  /// The enabled state while a mouse pointer hovers the button.
  hovered,

  /// The enabled state while the button has keyboard focus.
  focused,

  /// The enabled state during a pointer or keyboard press.
  pressed,

  /// The unavailable state when [NemoButton.onPressed] is null.
  disabled,

  /// The system-owned state while [NemoButton.isLoading] is true.
  loading,
}

/// Paint-only treatment for one Nemo button state.
@immutable
final class NemoButtonStateStyle {
  /// Creates a button state treatment.
  const NemoButtonStateStyle({
    required this.foregroundBlend,
    required this.shadowOffsetMultiplier,
    required this.shadowBlurMultiplier,
    required this.shadowOpacity,
    required this.outlineOpacity,
    this.surfaceVariantBlend = 0,
    this.accentOpacity = 0,
    this.insetShadowOpacity = 0,
  });

  /// Blend the surface body toward semantic foreground for tonal feedback.
  final double foregroundBlend;

  /// Multiplier for the foundation shadow offset.
  final double shadowOffsetMultiplier;

  /// Multiplier for the foundation shadow blur.
  final double shadowBlurMultiplier;

  /// Opacity applied to semantic tactile shadows.
  final double shadowOpacity;

  /// Opacity applied to the semantic outline.
  final double outlineOpacity;

  /// Blend from the shared surface toward its local variant.
  final double surfaceVariantBlend;

  /// Restrained primary-color tint applied to primary-emphasis bodies.
  final double accentOpacity;

  /// Opacity of paired clipped inset shadows for recessed states.
  final double insetShadowOpacity;

  /// Creates a copy with selectively replaced values.
  NemoButtonStateStyle copyWith({
    double? foregroundBlend,
    double? shadowOffsetMultiplier,
    double? shadowBlurMultiplier,
    double? shadowOpacity,
    double? outlineOpacity,
    double? surfaceVariantBlend,
    double? accentOpacity,
    double? insetShadowOpacity,
  }) => NemoButtonStateStyle(
    foregroundBlend: foregroundBlend ?? this.foregroundBlend,
    shadowOffsetMultiplier:
        shadowOffsetMultiplier ?? this.shadowOffsetMultiplier,
    shadowBlurMultiplier: shadowBlurMultiplier ?? this.shadowBlurMultiplier,
    shadowOpacity: shadowOpacity ?? this.shadowOpacity,
    outlineOpacity: outlineOpacity ?? this.outlineOpacity,
    surfaceVariantBlend: surfaceVariantBlend ?? this.surfaceVariantBlend,
    accentOpacity: accentOpacity ?? this.accentOpacity,
    insetShadowOpacity: insetShadowOpacity ?? this.insetShadowOpacity,
  );

  /// Interpolates two state treatments.
  static NemoButtonStateStyle lerp(
    NemoButtonStateStyle a,
    NemoButtonStateStyle b,
    double t,
  ) => NemoButtonStateStyle(
    foregroundBlend: lerpDouble(a.foregroundBlend, b.foregroundBlend, t)!,
    shadowOffsetMultiplier: lerpDouble(
      a.shadowOffsetMultiplier,
      b.shadowOffsetMultiplier,
      t,
    )!,
    shadowBlurMultiplier: lerpDouble(
      a.shadowBlurMultiplier,
      b.shadowBlurMultiplier,
      t,
    )!,
    shadowOpacity: lerpDouble(a.shadowOpacity, b.shadowOpacity, t)!,
    outlineOpacity: lerpDouble(a.outlineOpacity, b.outlineOpacity, t)!,
    surfaceVariantBlend: lerpDouble(
      a.surfaceVariantBlend,
      b.surfaceVariantBlend,
      t,
    )!,
    accentOpacity: lerpDouble(a.accentOpacity, b.accentOpacity, t)!,
    insetShadowOpacity: lerpDouble(
      a.insetShadowOpacity,
      b.insetShadowOpacity,
      t,
    )!,
  );

  @override
  bool operator ==(Object other) =>
      other is NemoButtonStateStyle &&
      foregroundBlend == other.foregroundBlend &&
      shadowOffsetMultiplier == other.shadowOffsetMultiplier &&
      shadowBlurMultiplier == other.shadowBlurMultiplier &&
      shadowOpacity == other.shadowOpacity &&
      outlineOpacity == other.outlineOpacity &&
      surfaceVariantBlend == other.surfaceVariantBlend &&
      accentOpacity == other.accentOpacity &&
      insetShadowOpacity == other.insetShadowOpacity;

  @override
  int get hashCode => Object.hash(
    foregroundBlend,
    shadowOffsetMultiplier,
    shadowBlurMultiplier,
    shadowOpacity,
    outlineOpacity,
    surfaceVariantBlend,
    accentOpacity,
    insetShadowOpacity,
  );
}

/// The component-level visual values for a Nemo surface.
@immutable
final class NemoSurfaceTokens {
  /// Creates visual values for every supported depth.
  const NemoSurfaceTokens({
    required this.deeplySunken,
    required this.sunken,
    required this.flat,
    required this.raised,
    required this.elevated,
  });

  /// The deepest inset treatment.
  final NemoSurfaceDepthStyle deeplySunken;

  /// The standard inset treatment.
  final NemoSurfaceDepthStyle sunken;

  /// The neutral treatment.
  final NemoSurfaceDepthStyle flat;

  /// The standard raised treatment.
  final NemoSurfaceDepthStyle raised;

  /// The strongest raised treatment.
  final NemoSurfaceDepthStyle elevated;

  /// The default soft-neumorphic surface treatments.
  static const NemoSurfaceTokens standard = NemoSurfaceTokens(
    deeplySunken: NemoSurfaceDepthStyle(
      intensity: -2,
      tonalOverlayOpacity: 0.13,
      outlineOpacity: 0.16,
      shadowOpacity: 0.62,
      blurMultiplier: 1,
      offsetMultiplier: 1,
      tonalColor: NemoSurfaceTonalColor.lowlightShadow,
    ),
    sunken: NemoSurfaceDepthStyle(
      intensity: -1,
      tonalOverlayOpacity: 0.075,
      outlineOpacity: 0.12,
      shadowOpacity: 0.42,
      blurMultiplier: 0.65,
      offsetMultiplier: 0.65,
      tonalColor: NemoSurfaceTonalColor.lowlightShadow,
    ),
    flat: NemoSurfaceDepthStyle(
      intensity: 0,
      tonalOverlayOpacity: 0.012,
      outlineOpacity: 0.14,
      shadowOpacity: 0,
      blurMultiplier: 0,
      offsetMultiplier: 0,
      tonalColor: NemoSurfaceTonalColor.outline,
    ),
    raised: NemoSurfaceDepthStyle(
      intensity: 1,
      tonalOverlayOpacity: 0.018,
      outlineOpacity: 0.12,
      shadowOpacity: 0.42,
      blurMultiplier: 0.65,
      offsetMultiplier: 0.65,
      tonalColor: NemoSurfaceTonalColor.highlightShadow,
    ),
    elevated: NemoSurfaceDepthStyle(
      intensity: 2,
      tonalOverlayOpacity: 0.055,
      outlineOpacity: 0.16,
      shadowOpacity: 0.62,
      blurMultiplier: 1,
      offsetMultiplier: 1,
      tonalColor: NemoSurfaceTonalColor.highlightShadow,
    ),
  );

  /// High contrast keeps direction but intentionally collapses magnitude.
  static const NemoSurfaceTokens highContrast = NemoSurfaceTokens(
    deeplySunken: NemoSurfaceDepthStyle(
      intensity: -1,
      tonalOverlayOpacity: 0.14,
      outlineOpacity: 0.85,
      shadowOpacity: 0,
      blurMultiplier: 0,
      offsetMultiplier: 0,
      tonalColor: NemoSurfaceTonalColor.foreground,
    ),
    sunken: NemoSurfaceDepthStyle(
      intensity: -1,
      tonalOverlayOpacity: 0.14,
      outlineOpacity: 0.85,
      shadowOpacity: 0,
      blurMultiplier: 0,
      offsetMultiplier: 0,
      tonalColor: NemoSurfaceTonalColor.foreground,
    ),
    flat: NemoSurfaceDepthStyle(
      intensity: 0,
      tonalOverlayOpacity: 0.05,
      outlineOpacity: 0.45,
      shadowOpacity: 0,
      blurMultiplier: 0,
      offsetMultiplier: 0,
      tonalColor: NemoSurfaceTonalColor.surfaceVariant,
    ),
    raised: NemoSurfaceDepthStyle(
      intensity: 1,
      tonalOverlayOpacity: 0.8,
      outlineOpacity: 1,
      shadowOpacity: 0,
      blurMultiplier: 0,
      offsetMultiplier: 0,
      tonalColor: NemoSurfaceTonalColor.surfaceVariant,
    ),
    elevated: NemoSurfaceDepthStyle(
      intensity: 1,
      tonalOverlayOpacity: 0.8,
      outlineOpacity: 1,
      shadowOpacity: 0,
      blurMultiplier: 0,
      offsetMultiplier: 0,
      tonalColor: NemoSurfaceTonalColor.surfaceVariant,
    ),
  );

  /// Returns the style associated with [depth].
  NemoSurfaceDepthStyle styleFor(NemoSurfaceDepth depth) => switch (depth) {
    NemoSurfaceDepth.deeplySunken => deeplySunken,
    NemoSurfaceDepth.sunken => sunken,
    NemoSurfaceDepth.flat => flat,
    NemoSurfaceDepth.raised => raised,
    NemoSurfaceDepth.elevated => elevated,
  };

  /// Creates a copy with selectively replaced depth styles.
  NemoSurfaceTokens copyWith({
    NemoSurfaceDepthStyle? deeplySunken,
    NemoSurfaceDepthStyle? sunken,
    NemoSurfaceDepthStyle? flat,
    NemoSurfaceDepthStyle? raised,
    NemoSurfaceDepthStyle? elevated,
  }) => NemoSurfaceTokens(
    deeplySunken: deeplySunken ?? this.deeplySunken,
    sunken: sunken ?? this.sunken,
    flat: flat ?? this.flat,
    raised: raised ?? this.raised,
    elevated: elevated ?? this.elevated,
  );

  /// Interpolates component surface tokens.
  static NemoSurfaceTokens lerp(
    NemoSurfaceTokens a,
    NemoSurfaceTokens b,
    double t,
  ) => NemoSurfaceTokens(
    deeplySunken: NemoSurfaceDepthStyle.lerp(a.deeplySunken, b.deeplySunken, t),
    sunken: NemoSurfaceDepthStyle.lerp(a.sunken, b.sunken, t),
    flat: NemoSurfaceDepthStyle.lerp(a.flat, b.flat, t),
    raised: NemoSurfaceDepthStyle.lerp(a.raised, b.raised, t),
    elevated: NemoSurfaceDepthStyle.lerp(a.elevated, b.elevated, t),
  );

  @override
  bool operator ==(Object other) =>
      other is NemoSurfaceTokens &&
      deeplySunken == other.deeplySunken &&
      sunken == other.sunken &&
      flat == other.flat &&
      raised == other.raised &&
      elevated == other.elevated;

  @override
  int get hashCode => Object.hash(deeplySunken, sunken, flat, raised, elevated);
}

/// Explicit visual values for one surface depth.
@immutable
final class NemoSurfaceDepthStyle {
  /// Creates one depth's visual values.
  const NemoSurfaceDepthStyle({
    required this.intensity,
    required this.tonalOverlayOpacity,
    required this.outlineOpacity,
    required this.shadowOpacity,
    required this.blurMultiplier,
    required this.offsetMultiplier,
    required this.tonalColor,
  });

  /// Signed relief used to route outer versus inset shadows.
  final double intensity;

  /// Opacity applied to the semantic base tone.
  final double tonalOverlayOpacity;

  /// Opacity of the semantic outline.
  final double outlineOpacity;

  /// Opacity multiplier for tactile shadows.
  final double shadowOpacity;

  /// Explicit multiplier for the foundation shadow blur.
  final double blurMultiplier;

  /// Explicit multiplier for the foundation shadow offset.
  final double offsetMultiplier;

  /// The semantic color used for the tonal contrast adjustment.
  final NemoSurfaceTonalColor tonalColor;

  /// Creates a copy with selectively replaced values.
  NemoSurfaceDepthStyle copyWith({
    double? intensity,
    double? tonalOverlayOpacity,
    double? outlineOpacity,
    double? shadowOpacity,
    double? blurMultiplier,
    double? offsetMultiplier,
    NemoSurfaceTonalColor? tonalColor,
  }) => NemoSurfaceDepthStyle(
    intensity: intensity ?? this.intensity,
    tonalOverlayOpacity: tonalOverlayOpacity ?? this.tonalOverlayOpacity,
    outlineOpacity: outlineOpacity ?? this.outlineOpacity,
    shadowOpacity: shadowOpacity ?? this.shadowOpacity,
    blurMultiplier: blurMultiplier ?? this.blurMultiplier,
    offsetMultiplier: offsetMultiplier ?? this.offsetMultiplier,
    tonalColor: tonalColor ?? this.tonalColor,
  );

  /// Interpolates two depth styles.
  static NemoSurfaceDepthStyle lerp(
    NemoSurfaceDepthStyle a,
    NemoSurfaceDepthStyle b,
    double t,
  ) => NemoSurfaceDepthStyle(
    intensity: lerpDouble(a.intensity, b.intensity, t)!,
    tonalOverlayOpacity: lerpDouble(
      a.tonalOverlayOpacity,
      b.tonalOverlayOpacity,
      t,
    )!,
    outlineOpacity: lerpDouble(a.outlineOpacity, b.outlineOpacity, t)!,
    shadowOpacity: lerpDouble(a.shadowOpacity, b.shadowOpacity, t)!,
    blurMultiplier: lerpDouble(a.blurMultiplier, b.blurMultiplier, t)!,
    offsetMultiplier: lerpDouble(a.offsetMultiplier, b.offsetMultiplier, t)!,
    tonalColor: t < 0.5 ? a.tonalColor : b.tonalColor,
  );

  @override
  bool operator ==(Object other) =>
      other is NemoSurfaceDepthStyle &&
      intensity == other.intensity &&
      tonalOverlayOpacity == other.tonalOverlayOpacity &&
      outlineOpacity == other.outlineOpacity &&
      shadowOpacity == other.shadowOpacity &&
      blurMultiplier == other.blurMultiplier &&
      offsetMultiplier == other.offsetMultiplier &&
      tonalColor == other.tonalColor;

  @override
  int get hashCode => Object.hash(
    intensity,
    tonalOverlayOpacity,
    outlineOpacity,
    shadowOpacity,
    blurMultiplier,
    offsetMultiplier,
    tonalColor,
  );
}

/// Semantic color source for a Surface depth's tonal adjustment.
enum NemoSurfaceTonalColor {
  /// Uses the theme highlight shadow color.
  highlightShadow,

  /// Uses the theme lowlight shadow color.
  lowlightShadow,

  /// Uses the theme foreground color.
  foreground,

  /// Uses the semantic outline color.
  outline,

  /// Uses the alternate semantic surface color.
  surfaceVariant,
}

/// Optional group-level overrides applied by theme factories.
@immutable
final class NemoThemeOverrides {
  /// Creates a group-level override set.
  const NemoThemeOverrides({
    this.foundation,
    this.semantic,
    this.components,
    this.motion,
  });

  /// Replaces foundational tokens when non-null.
  final NemoFoundationTokens? foundation;

  /// Replaces semantic tokens when non-null.
  final NemoSemanticTokens? semantic;

  /// Replaces component-ready tokens when non-null.
  final NemoComponentTokens? components;

  /// Replaces motion tokens when non-null.
  final NemoMotionTokens? motion;

  /// Applies the configured overrides to [base].
  NemoThemeData applyTo(NemoThemeData base) {
    return base.copyWith(
      foundation: foundation,
      semantic: semantic,
      components: components,
      motion: motion,
    );
  }
}
