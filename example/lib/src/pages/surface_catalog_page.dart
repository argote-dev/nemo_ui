import 'package:flutter/material.dart';
import 'package:nemo_ui/nemo_ui.dart';

import '../nemo_page_shell.dart';

/// Demonstrates each Nemo surface treatment in a spacious responsive grid.
class SurfaceCatalogPage extends StatelessWidget {
  /// Creates the surface catalog page.
  const SurfaceCatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    final NemoLocalizations strings = NemoLocalizations.of(context);
    final Widget? brandMark = NemoAssetScope.of(context)
        .widgetFor(NemoAsset.brandMark, context);
    return NemoPageShell(
      key: const ValueKey<String>('NemoSurfaceScreen'),
      title: 'NemoSurface',
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double gap = theme.foundation.space24;
          final double available = constraints.maxWidth - (gap * 2);
          final int columns = available >= 760
              ? 3
              : available >= 500
              ? 2
              : 1;
          final double cardWidth = (available - gap * (columns - 1)) / columns;
          return ListView(
            padding: EdgeInsets.all(gap),
            children: <Widget>[
              Text(
                'Tactile surfaces',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: theme.foundation.space8),
              Text(
                '${strings.loading} · ${strings.retry} · ${strings.error}',
                style: TextStyle(color: theme.semantic.mutedForeground),
              ),
              SizedBox(height: gap),
              Wrap(
                spacing: gap,
                runSpacing: gap,
                children: <Widget>[
                  for (final NemoMaterial material in NemoMaterial.values)
                    for (final NemoSurfaceTone tone in NemoSurfaceTone.values)
                      for (final NemoCornerRole cornerRole
                          in NemoCornerRole.values)
                        _SurfaceCard(
                          width: cardWidth,
                          material: material,
                          tone: tone,
                          cornerRole: cornerRole,
                          theme: theme,
                          brandMark: brandMark,
                        ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.width,
    required this.material,
    required this.tone,
    required this.cornerRole,
    required this.theme,
    required this.brandMark,
  });

  final double width;
  final NemoMaterial material;
  final NemoSurfaceTone tone;
  final NemoCornerRole cornerRole;
  final NemoThemeData theme;
  final Widget? brandMark;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 180),
      child: NemoSurface(
        key: ValueKey<String>(
          'surface-card-${material.name}-${tone.name}-${cornerRole.name}',
        ),
        material: material,
        tone: tone,
        cornerRole: cornerRole,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if (brandMark case final Widget asset)
              IconTheme(
                data: IconThemeData(color: theme.semantic.primary),
                child: asset,
              ),
            Text(
              _titleFor(material),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              '${tone.name} · ${_cornerLabel(cornerRole)}',
              style: TextStyle(color: theme.semantic.mutedForeground),
            ),
          ],
        ),
      ),
    ),
  );

  String _titleFor(NemoMaterial value) => switch (value) {
    NemoMaterial.recessed => 'Recessed receiving area',
    NemoMaterial.base => 'Base canvas',
    NemoMaterial.raised => 'Raised action island',
    NemoMaterial.floating => 'Floating transient plane',
  };

  String _cornerLabel(NemoCornerRole value) => switch (value) {
    NemoCornerRole.control => 'control corners',
    NemoCornerRole.panel => 'panel corners',
    NemoCornerRole.floating => 'floating corners',
  };
}
