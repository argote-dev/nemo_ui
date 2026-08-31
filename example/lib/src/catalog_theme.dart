import 'package:flutter/material.dart';
import 'package:nemo_ui/nemo_ui.dart';

/// Maps Nemo semantic tokens into the Material widgets used by the catalog.
ThemeData catalogMaterialTheme(NemoThemeData nemo, Brightness brightness) {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: nemo.semantic.primary,
    brightness: brightness,
    primary: nemo.semantic.primary,
    onPrimary: nemo.semantic.onPrimary,
    surface: nemo.semantic.surface,
    onSurface: nemo.semantic.foreground,
    surfaceContainerHighest: nemo.semantic.surfaceVariant,
    onSurfaceVariant: nemo.semantic.mutedForeground,
    error: nemo.semantic.error,
    onError: nemo.semantic.onError,
    outline: nemo.semantic.outline,
  );
  final BorderRadius radius = BorderRadius.circular(
    nemo.foundation.radiusMedium,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: nemo.semantic.surface,
    extensions: <ThemeExtension<dynamic>>[nemo],
    appBarTheme: AppBarTheme(
      backgroundColor: nemo.semantic.surface,
      foregroundColor: nemo.semantic.foreground,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    textTheme: Typography.material2021().black.apply(
      bodyColor: nemo.semantic.foreground,
      displayColor: nemo.semantic.foreground,
    ),
    dividerTheme: DividerThemeData(color: nemo.semantic.outline),
    sliderTheme: SliderThemeData(
      activeTrackColor: nemo.semantic.primary,
      inactiveTrackColor: nemo.semantic.surfaceVariant,
      thumbColor: nemo.semantic.primary,
      overlayColor: nemo.semantic.primary.withValues(alpha: .12),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(nemo.semantic.foreground),
        side: WidgetStatePropertyAll(BorderSide(color: nemo.semantic.outline)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: nemo.semantic.primary,
      textColor: nemo.semantic.foreground,
      shape: RoundedRectangleBorder(borderRadius: radius),
    ),
  );
}
