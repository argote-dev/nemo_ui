import 'package:flutter/widgets.dart';

export '../l10n/generated/nemo_localizations.dart';

/// Locale-resolution helpers for hosts that want Nemo's English fallback.
abstract final class NemoLocales {
  /// Resolves [locale] against [supportedLocales], preferring English when no
  /// exact or language-only match is available.
  static Locale resolve(Locale? locale, Iterable<Locale> supportedLocales) {
    final List<Locale> supported = supportedLocales.toList(growable: false);
    if (locale != null) {
      for (final Locale supportedLocale in supported) {
        if (supportedLocale.languageCode == locale.languageCode &&
            supportedLocale.countryCode == locale.countryCode) {
          return supportedLocale;
        }
      }
      for (final Locale supportedLocale in supported) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return supportedLocale;
        }
      }
    }
    return supported.firstWhere(
      (Locale supportedLocale) => supportedLocale.languageCode == 'en',
      orElse: () => supported.first,
    );
  }
}
