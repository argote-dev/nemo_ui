import 'package:flutter/material.dart';
import 'package:nemo_ui/nemo_ui.dart';

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
    return Scaffold(
      key: const ValueKey<String>('NemoSurfaceScreen'),
      appBar: AppBar(title: const Text('NemoSurface')),
      body: LayoutBuilder(
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
                  for (final NemoSurfaceDepth depth in NemoSurfaceDepth.values)
                    for (final NemoSurfaceTone tone in NemoSurfaceTone.values)
                      for (final NemoSurfaceShape shape
                          in NemoSurfaceShape.values)
                        _SurfaceCard(
                          width: cardWidth,
                          depth: depth,
                          tone: tone,
                          shape: shape,
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
    required this.depth,
    required this.tone,
    required this.shape,
    required this.theme,
    required this.brandMark,
  });

  final double width;
  final NemoSurfaceDepth depth;
  final NemoSurfaceTone tone;
  final NemoSurfaceShape shape;
  final NemoThemeData theme;
  final Widget? brandMark;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 180),
      child: NemoSurface(
        key: ValueKey<String>(
          'surface-card-${depth.name}-${tone.name}-${shape.name}',
        ),
        depth: depth,
        tone: tone,
        shape: shape,
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
              _titleFor(depth),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              '${tone.name} · ${_shapeLabel(shape)}',
              style: TextStyle(color: theme.semantic.mutedForeground),
            ),
          ],
        ),
      ),
    ),
  );

  String _titleFor(NemoSurfaceDepth value) => switch (value) {
    NemoSurfaceDepth.deeplySunken => 'Deeply sunken',
    NemoSurfaceDepth.sunken => 'Sunken',
    NemoSurfaceDepth.flat => 'Flat',
    NemoSurfaceDepth.raised => 'Raised by default',
    NemoSurfaceDepth.elevated => 'Elevated',
  };

  String _shapeLabel(NemoSurfaceShape value) => switch (value) {
    NemoSurfaceShape.roundedSmall => 'rounded small',
    NemoSurfaceShape.roundedMedium => 'rounded medium',
    NemoSurfaceShape.roundedLarge => 'rounded large',
  };
}
