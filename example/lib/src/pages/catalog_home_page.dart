import 'package:flutter/material.dart';
import 'package:nemo_ui/nemo_ui.dart';

import '../catalog_app.dart';
import 'button_catalog_page.dart';
import 'surface_catalog_page.dart';
import 'switch_catalog_page.dart';

/// The catalog landing page: global settings and links only.
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
    final double gap = theme.foundation.space16;
    final Widget configuration = _CatalogSection(
      title: 'Global configuration',
      child: _GlobalConfiguration(
        settings: settings,
        onChanged: onSettingsChanged,
      ),
    );
    final Widget menu = _CatalogSection(
      title: 'Components',
      child: Column(
        children: const <Widget>[
          _ComponentDestination(
            title: 'NemoSurface',
            subtitle: 'Depth, tone, and shape',
            icon: Icons.layers_outlined,
            page: SurfaceCatalogPage(),
          ),
          _ComponentDestination(
            title: 'NemoButton',
            subtitle: 'Action states and loading feedback',
            icon: Icons.smart_button_outlined,
            page: ButtonCatalogPage(),
          ),
          _ComponentDestination(
            title: 'NemoSwitch',
            subtitle: 'Binary selection states',
            icon: Icons.toggle_on_outlined,
            page: SwitchCatalogPage(),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Nemo component catalog')),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => ListView(
          padding: EdgeInsets.all(gap),
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
  const _CatalogSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        SizedBox(height: theme.foundation.space16),
        child,
      ],
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
    return NemoSurface(
      tone: NemoSurfaceTone.surfaceVariant,
      child: Column(
        children: <Widget>[
          SegmentedButton<Brightness>(
            segments: const <ButtonSegment<Brightness>>[
              ButtonSegment(value: Brightness.light, label: Text('Light')),
              ButtonSegment(value: Brightness.dark, label: Text('Dark')),
            ],
            selected: <Brightness>{settings.brightness},
            onSelectionChanged: (Set<Brightness> value) =>
                onChanged(settings.copyWith(brightness: value.single)),
          ),
          SizedBox(height: theme.foundation.space8),
          SwitchListTile(
            value: settings.highContrast,
            onChanged: (bool value) =>
                onChanged(settings.copyWith(highContrast: value)),
            title: const Text('High contrast'),
          ),
          SwitchListTile(
            value: settings.spanish,
            onChanged: (bool value) =>
                onChanged(settings.copyWith(spanish: value)),
            title: const Text('Español'),
          ),
          SwitchListTile(
            value: settings.reducedMotion,
            onChanged: (bool value) =>
                onChanged(settings.copyWith(reducedMotion: value)),
            title: const Text('Reduced motion'),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Text scale: ${settings.textScale.toStringAsFixed(1)}×',
            ),
          ),
          Slider(
            value: settings.textScale,
            min: .8,
            max: 2,
            divisions: 6,
            label: settings.textScale.toStringAsFixed(1),
            onChanged: (double value) =>
                onChanged(settings.copyWith(textScale: value)),
          ),
          Wrap(
            spacing: theme.foundation.space8,
            children: <Widget>[
              for (final Color color in seedOptions)
                ChoiceChip(
                  label: const Text(''),
                  avatar: CircleAvatar(backgroundColor: color),
                  selected: settings.seed == color,
                  onSelected: (_) => onChanged(settings.copyWith(seed: color)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComponentDestination extends StatelessWidget {
  const _ComponentDestination({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.page,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget page;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (BuildContext context) => page),
    ),
  );
}

/// Seed colors available to the catalog preview.
const List<Color> seedOptions = <Color>[
  Color(0xFF4F6EF7),
  Color(0xFF008A70),
  Color(0xFFB0376A),
];
