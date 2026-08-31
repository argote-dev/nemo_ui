import 'package:flutter/material.dart';
import 'package:nemo_ui/nemo_ui.dart';

import 'catalog_theme.dart';
import 'pages/catalog_home_page.dart';

/// Holds catalog-wide configuration above every component route.
class CatalogApp extends StatefulWidget {
  /// Creates the root catalog application.
  const CatalogApp({super.key});

  @override
  State<CatalogApp> createState() => _CatalogAppState();
}

class _CatalogAppState extends State<CatalogApp> {
  CatalogSettings _settings = const CatalogSettings();

  void _updateSettings(CatalogSettings settings) {
    setState(() => _settings = settings);
  }

  @override
  Widget build(BuildContext context) {
    final NemoThemeData nemoTheme = _settings.nemoTheme;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nemo component catalog',
      theme: catalogMaterialTheme(nemoTheme, _settings.brightness),
      locale: Locale(_settings.spanish ? 'es' : 'en'),
      supportedLocales: NemoLocalizations.supportedLocales,
      localeResolutionCallback: NemoLocales.resolve,
      localizationsDelegates: NemoLocalizations.localizationsDelegates,
      builder: (BuildContext context, Widget? child) {
        final MediaQueryData mediaQuery = MediaQuery.of(context);
        return NemoAssetScope(
          resolver: const CatalogAssetResolver(),
          child: MediaQuery(
            data: mediaQuery.copyWith(
              disableAnimations: _settings.reducedMotion,
              textScaler: TextScaler.linear(_settings.textScale),
            ),
            child: child!,
          ),
        );
      },
      home: CatalogHomePage(
        settings: _settings,
        onSettingsChanged: _updateSettings,
      ),
    );
  }
}

/// The configuration shared by all catalog pages.
@immutable
class CatalogSettings {
  /// Creates global catalog settings.
  const CatalogSettings({
    this.brightness = Brightness.light,
    this.highContrast = false,
    this.spanish = false,
    this.reducedMotion = false,
    this.textScale = 1,
    this.seed = const Color(0xFF4F6EF7),
  });

  /// The selected color-scheme brightness.
  final Brightness brightness;

  /// Whether the high-contrast theme variant is active.
  final bool highContrast;

  /// Whether Nemo localization should use Spanish.
  final bool spanish;

  /// Whether motion should be disabled for the preview.
  final bool reducedMotion;

  /// The host text scale used by the preview.
  final double textScale;

  /// The seed used to derive the active color theme.
  final Color seed;

  /// Resolves the Nemo tokens for these settings.
  NemoThemeData get nemoTheme => highContrast
      ? NemoThemeData.highContrast(seedColor: seed, brightness: brightness)
      : brightness == Brightness.dark
      ? NemoThemeData.dark(seedColor: seed)
      : NemoThemeData.light(seedColor: seed);

  /// Returns these settings with selected values replaced.
  CatalogSettings copyWith({
    Brightness? brightness,
    bool? highContrast,
    bool? spanish,
    bool? reducedMotion,
    double? textScale,
    Color? seed,
  }) => CatalogSettings(
    brightness: brightness ?? this.brightness,
    highContrast: highContrast ?? this.highContrast,
    spanish: spanish ?? this.spanish,
    reducedMotion: reducedMotion ?? this.reducedMotion,
    textScale: textScale ?? this.textScale,
    seed: seed ?? this.seed,
  );
}

/// Supplies the catalog-only brand mark without coupling the package to assets.
class CatalogAssetResolver implements NemoAssetResolver {
  /// Creates the catalog asset resolver.
  const CatalogAssetResolver();

  @override
  ImageProvider<Object>? imageFor(NemoAsset asset, BuildContext context) =>
      null;

  @override
  Widget? widgetFor(NemoAsset asset, BuildContext context) => switch (asset) {
    NemoAsset.brandMark => const Icon(Icons.auto_awesome_rounded, size: 36),
    NemoAsset.emptyStateIllustration => null,
  };
}
