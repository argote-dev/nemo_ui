import 'package:flutter/material.dart';
import 'package:nemo_ui/nemo_ui.dart';

void main() {
  runApp(const NemoFoundationCatalog());
}

/// A runnable catalog for Nemo's configurable foundation contracts.
class NemoFoundationCatalog extends StatefulWidget {
  /// Creates the Nemo foundation catalog.
  const NemoFoundationCatalog({super.key});

  @override
  State<NemoFoundationCatalog> createState() => _NemoFoundationCatalogState();
}

class _NemoFoundationCatalogState extends State<NemoFoundationCatalog> {
  Brightness _brightness = Brightness.light;
  bool _highContrast = false;
  bool _spanish = false;
  bool _reducedMotion = false;
  double _textScale = 1;
  Color _seed = const Color(0xFF4F6EF7);

  @override
  Widget build(BuildContext context) {
    final NemoThemeData nemoTheme = _highContrast
        ? NemoThemeData.highContrast(seedColor: _seed, brightness: _brightness)
        : _brightness == Brightness.dark
        ? NemoThemeData.dark(seedColor: _seed)
        : NemoThemeData.light(seedColor: _seed);
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: _brightness,
      contrastLevel: _highContrast ? 1 : 0,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nemo foundation catalog',
      theme: ThemeData(
        colorScheme: scheme,
        brightness: _brightness,
        extensions: <ThemeExtension<dynamic>>[nemoTheme],
      ),
      locale: Locale(_spanish ? 'es' : 'en'),
      supportedLocales: NemoLocalizations.supportedLocales,
      localeResolutionCallback: NemoLocales.resolve,
      localizationsDelegates: NemoLocalizations.localizationsDelegates,
      builder: (BuildContext context, Widget? child) {
        final MediaQueryData mediaQuery = MediaQuery.of(context);
        return NemoAssetScope(
          resolver: const _CatalogAssetResolver(),
          child: MediaQuery(
            data: mediaQuery.copyWith(
              disableAnimations: _reducedMotion,
              textScaler: TextScaler.linear(_textScale),
            ),
            child: child!,
          ),
        );
      },
      home: _FoundationPage(
        brightness: _brightness,
        highContrast: _highContrast,
        spanish: _spanish,
        reducedMotion: _reducedMotion,
        textScale: _textScale,
        seed: _seed,
        onBrightnessChanged: (Brightness brightness) {
          setState(() => _brightness = brightness);
        },
        onHighContrastChanged: (bool value) {
          setState(() => _highContrast = value);
        },
        onSpanishChanged: (bool value) {
          setState(() => _spanish = value);
        },
        onReducedMotionChanged: (bool value) {
          setState(() => _reducedMotion = value);
        },
        onTextScaleChanged: (double value) {
          setState(() => _textScale = value);
        },
        onSeedChanged: (Color color) {
          setState(() => _seed = color);
        },
      ),
    );
  }
}

class _FoundationPage extends StatelessWidget {
  const _FoundationPage({
    required this.brightness,
    required this.highContrast,
    required this.spanish,
    required this.reducedMotion,
    required this.textScale,
    required this.seed,
    required this.onBrightnessChanged,
    required this.onHighContrastChanged,
    required this.onSpanishChanged,
    required this.onReducedMotionChanged,
    required this.onTextScaleChanged,
    required this.onSeedChanged,
  });

  final Brightness brightness;
  final bool highContrast;
  final bool spanish;
  final bool reducedMotion;
  final double textScale;
  final Color seed;
  final ValueChanged<Brightness> onBrightnessChanged;
  final ValueChanged<bool> onHighContrastChanged;
  final ValueChanged<bool> onSpanishChanged;
  final ValueChanged<bool> onReducedMotionChanged;
  final ValueChanged<double> onTextScaleChanged;
  final ValueChanged<Color> onSeedChanged;

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    final NemoLocalizations strings = NemoLocalizations.of(context);
    final NemoMotionTokens motion = theme.motion.resolveFor(context);
    final Widget? asset = NemoAssetScope.of(context)
        .widgetFor(NemoAsset.brandMark, context);

    return Scaffold(
      backgroundColor: theme.semantic.surface,
      appBar: AppBar(
        backgroundColor: theme.semantic.surface,
        foregroundColor: theme.semantic.foreground,
        title: const Text('Nemo foundation catalog'),
      ),
      body: ListView(
        padding: EdgeInsets.all(theme.foundation.space16),
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.semantic.surfaceVariant,
              border: Border.all(
                color: theme.semantic.outline,
                width: theme.components.outlineWidth,
              ),
              borderRadius: BorderRadius.circular(theme.foundation.radiusLarge),
            ),
            child: Padding(
              padding: EdgeInsets.all(theme.foundation.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (asset case final Widget resolvedAsset) resolvedAsset,
                  Text(
                    'No pilot component is installed yet.',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(color: theme.semantic.foreground),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${strings.loading} · ${strings.retry} · ${strings.error}',
                    style: TextStyle(color: theme.semantic.mutedForeground),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Motion: ${motion.standard.inMilliseconds} ms',
                    style: TextStyle(color: theme.semantic.mutedForeground),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SegmentedButton<Brightness>(
            segments: const <ButtonSegment<Brightness>>[
              ButtonSegment<Brightness>(
                value: Brightness.light,
                label: Text('Light'),
              ),
              ButtonSegment<Brightness>(
                value: Brightness.dark,
                label: Text('Dark'),
              ),
            ],
            selected: <Brightness>{brightness},
            onSelectionChanged: (Set<Brightness> value) {
              onBrightnessChanged(value.single);
            },
          ),
          SwitchListTile(
            value: highContrast,
            onChanged: onHighContrastChanged,
            title: const Text('High contrast'),
          ),
          SwitchListTile(
            value: spanish,
            onChanged: onSpanishChanged,
            title: const Text('Español'),
          ),
          SwitchListTile(
            value: reducedMotion,
            onChanged: onReducedMotionChanged,
            title: const Text('Reduced motion'),
          ),
          const SizedBox(height: 8),
          Text('Text scale: ${textScale.toStringAsFixed(1)}×'),
          Slider(
            value: textScale,
            min: 0.8,
            max: 2,
            divisions: 6,
            label: textScale.toStringAsFixed(1),
            onChanged: onTextScaleChanged,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: <Widget>[
              for (final Color color in _seedOptions)
                ChoiceChip(
                  label: const Text(''),
                  avatar: CircleAvatar(backgroundColor: color),
                  selected: seed == color,
                  onSelected: (_) => onSeedChanged(color),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

const List<Color> _seedOptions = <Color>[
  Color(0xFF4F6EF7),
  Color(0xFF008A70),
  Color(0xFFB0376A),
];

class _CatalogAssetResolver implements NemoAssetResolver {
  const _CatalogAssetResolver();

  @override
  ImageProvider<Object>? imageFor(NemoAsset asset, BuildContext context) =>
      null;

  @override
  Widget? widgetFor(NemoAsset asset, BuildContext context) {
    return switch (asset) {
      NemoAsset.brandMark => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Icon(Icons.auto_awesome, size: 36),
      ),
      NemoAsset.emptyStateIllustration => null,
    };
  }
}
