import 'package:flutter/material.dart';
import 'package:nemo_ui/nemo_ui.dart';

import '../catalog_app.dart';
import 'button_catalog_page.dart';
import 'composed_catalog_page.dart';
import 'field_catalog_page.dart';
import 'surface_catalog_page.dart';
import 'switch_catalog_page.dart';

/// The catalog landing page: global settings and Nemo-owned destinations.
class CatalogHomePage extends StatelessWidget {
  /// Creates the catalog home page.
  const CatalogHomePage({
    required this.settings,
    required this.onSettingsChanged,
    super.key,
  });

  /// The currently active global settings.
  final CatalogSettings settings;

  /// Called when global settings change.
  final ValueChanged<CatalogSettings> onSettingsChanged;

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    final Widget configuration = _CatalogSection(
      title: 'Global configuration',
      description: 'Preview every foundation setting with Nemo controls.',
      child: _GlobalConfiguration(
        settings: settings,
        onChanged: onSettingsChanged,
      ),
    );
    final Widget menu = _CatalogSection(
      title: 'Explore Nemo',
      description: 'Open focused component references or a composed workflow.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const <Widget>[
          _ComponentDestination(
            title: 'NemoSurface',
            subtitle: 'Depth, tone, and shape',
            page: SurfaceCatalogPage(),
          ),
          _ComponentDestination(
            title: 'NemoButton',
            subtitle: 'Action states and loading feedback',
            page: ButtonCatalogPage(),
          ),
          _ComponentDestination(
            title: 'NemoSwitch',
            subtitle: 'Binary selection states',
            page: SwitchCatalogPage(),
          ),
          _ComponentDestination(
            title: 'NemoField',
            subtitle: 'Accessible recessed text entry',
            page: FieldCatalogPage(),
          ),
          _ComponentDestination(
            title: 'Composed workspace',
            subtitle: 'A shared surface, action, and preference flow',
            page: ComposedCatalogPage(),
          ),
        ],
      ),
    );

    return NemoPage(
      topBar: const NemoTopBar(title: Text('Nemo component catalog')),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            if (constraints.maxWidth >= 650)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: configuration),
                  SizedBox(width: theme.foundation.space24),
                  Expanded(child: menu),
                ],
              )
            else ...<Widget>[
              configuration,
              SizedBox(height: theme.foundation.space24),
              menu,
            ],
          ],
        ),
      ),
    );
  }
}

class _CatalogSection extends StatelessWidget {
  const _CatalogSection({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NemoSection(
      heading: Text(title, style: Theme.of(context).textTheme.headlineSmall),
      description: Text(description),
      child: child,
    );
  }
}

class _GlobalConfiguration extends StatelessWidget {
  const _GlobalConfiguration({required this.settings, required this.onChanged});

  final CatalogSettings settings;
  final ValueChanged<CatalogSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Semantics(header: true, child: const Text('Appearance')),
        SizedBox(height: theme.foundation.space8),
        Wrap(
          spacing: theme.foundation.space8,
          runSpacing: theme.foundation.space8,
          children: <Widget>[
            _settingButton(
              label: 'Light',
              selected: settings.brightness == Brightness.light,
              onPressed: () =>
                  onChanged(settings.copyWith(brightness: Brightness.light)),
            ),
            _settingButton(
              label: 'Dark',
              selected: settings.brightness == Brightness.dark,
              onPressed: () =>
                  onChanged(settings.copyWith(brightness: Brightness.dark)),
            ),
          ],
        ),
        SizedBox(height: theme.foundation.space16),
        NemoSwitch(
          value: settings.highContrast,
          semanticLabel: 'High contrast',
          onChanged: (bool value) =>
              onChanged(settings.copyWith(highContrast: value)),
          child: const Text('High contrast'),
        ),
        NemoSwitch(
          value: settings.spanish,
          semanticLabel: 'Español',
          onChanged: (bool value) =>
              onChanged(settings.copyWith(spanish: value)),
          child: const Text('Español'),
        ),
        NemoSwitch(
          value: settings.reducedMotion,
          semanticLabel: 'Reduced motion',
          onChanged: (bool value) =>
              onChanged(settings.copyWith(reducedMotion: value)),
          child: const Text('Reduced motion'),
        ),
        SizedBox(height: theme.foundation.space16),
        Semantics(
          header: true,
          child: Text('Text scale: ${settings.textScale.toStringAsFixed(1)}×'),
        ),
        SizedBox(height: theme.foundation.space8),
        Wrap(
          spacing: theme.foundation.space8,
          runSpacing: theme.foundation.space8,
          children: <Widget>[
            for (final double scale in textScaleOptions)
              _settingButton(
                label: '${scale.toStringAsFixed(1)}×',
                selected: settings.textScale == scale,
                onPressed: () => onChanged(settings.copyWith(textScale: scale)),
              ),
          ],
        ),
        SizedBox(height: theme.foundation.space16),
        Semantics(header: true, child: const Text('Color seed')),
        SizedBox(height: theme.foundation.space8),
        Wrap(
          spacing: theme.foundation.space8,
          runSpacing: theme.foundation.space8,
          children: <Widget>[
            for (int index = 0; index < seedOptions.length; index++)
              _settingButton(
                label: seedLabels[index],
                selected: settings.seed == seedOptions[index],
                onPressed: () =>
                    onChanged(settings.copyWith(seed: seedOptions[index])),
              ),
          ],
        ),
      ],
    );
  }

  Widget _settingButton({
    required String label,
    required bool selected,
    required VoidCallback onPressed,
  }) => NemoButton(
    semanticLabel: selected ? '$label selected' : label,
    onPressed: onPressed,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(selected ? Icons.check_circle_outline : Icons.circle_outlined),
        const SizedBox(width: 8),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    ),
  );
}

class _ComponentDestination extends StatelessWidget {
  const _ComponentDestination({
    required this.title,
    required this.subtitle,
    required this.page,
  });

  final String title;
  final String subtitle;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: theme.foundation.space12),
      child: NemoButton(
        semanticLabel: 'Open $title',
        onPressed: () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(builder: (BuildContext context) => page),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.arrow_forward),
            SizedBox(width: theme.foundation.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title),
                  Text(
                    subtitle,
                    style: TextStyle(color: theme.semantic.mutedForeground),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Seed colors available to the catalog preview.
const List<Color> seedOptions = <Color>[
  Color(0xFF4F6EF7),
  Color(0xFF008A70),
  Color(0xFFB0376A),
];

/// Explicit names ensure every seed is discoverable beyond color alone.
const List<String> seedLabels = <String>[
  'Blue seed',
  'Teal seed',
  'Berry seed',
];

/// Text-scale presets supported by the catalog preview.
const List<double> textScaleOptions = <double>[.8, 1, 1.2, 1.4, 1.6, 1.8, 2];
