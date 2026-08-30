import 'package:flutter/material.dart';

import 'nemo_theme_data.dart';

/// Retrieves Nemo theme tokens from the nearest [Theme].
abstract final class NemoTheme {
  /// Returns the nearest [NemoThemeData].
  ///
  /// Throws a descriptive error when the host has not installed the extension
  /// in its [ThemeData.extensions].
  static NemoThemeData of(BuildContext context) {
    return maybeOf(context) ??
        (throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('No NemoThemeData found in the widget tree.'),
          ErrorDescription(
            'Add a NemoThemeData instance to ThemeData.extensions before using '
            'Nemo components.',
          ),
        ]));
  }

  /// Returns the nearest [NemoThemeData], or null when none is installed.
  static NemoThemeData? maybeOf(BuildContext context) {
    return Theme.of(context).extension<NemoThemeData>();
  }
}
