import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'nemo_motion.dart';

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
  });

  /// The minimum interactive control height.
  final double controlMinHeight;

  /// The horizontal padding for interactive controls.
  final double controlHorizontalPadding;

  /// The width of the visible focus ring.
  final double focusRingWidth;

  /// The default tonal outline width.
  final double outlineWidth;

  /// The standard component contract.
  static const NemoComponentTokens standard = NemoComponentTokens(
    controlMinHeight: 48,
    controlHorizontalPadding: 16,
    focusRingWidth: 3,
    outlineWidth: 1,
  );

  /// The high-contrast component contract.
  static const NemoComponentTokens highContrast = NemoComponentTokens(
    controlMinHeight: 48,
    controlHorizontalPadding: 16,
    focusRingWidth: 3,
    outlineWidth: 2,
  );

  /// Creates a copy with selectively replaced component values.
  NemoComponentTokens copyWith({
    double? controlMinHeight,
    double? controlHorizontalPadding,
    double? focusRingWidth,
    double? outlineWidth,
  }) {
    return NemoComponentTokens(
      controlMinHeight: controlMinHeight ?? this.controlMinHeight,
      controlHorizontalPadding:
          controlHorizontalPadding ?? this.controlHorizontalPadding,
      focusRingWidth: focusRingWidth ?? this.focusRingWidth,
      outlineWidth: outlineWidth ?? this.outlineWidth,
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
    );
  }
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
