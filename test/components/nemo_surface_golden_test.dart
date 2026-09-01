import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nemo_ui/nemo_ui.dart';

import '../support/golden_test_harness.dart';

void main() {
  testWidgets('renders composed light, dark, and high-contrast depth scenes', (
    WidgetTester tester,
  ) async {
    configureGoldenTest(tester, physicalSize: const Size(720, 900));

    await tester.pumpWidget(
      goldenTestApp(scaffold: false, child: const _SurfaceDepthScenes()),
    );

    expect(find.byType(NemoSurface), findsNWidgets(15));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/nemo_surface.png'),
    );
  });
}

class _SurfaceDepthScenes extends StatelessWidget {
  const _SurfaceDepthScenes();

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      _DepthScene(theme: _stableTheme(NemoThemeData.light())),
      _DepthScene(theme: _stableTheme(NemoThemeData.dark())),
      _DepthScene(theme: _stableTheme(NemoThemeData.highContrast())),
    ],
  );
}

NemoThemeData _stableTheme(NemoThemeData theme) {
  final NemoSurfaceTokens surface = theme.components.surface;
  return theme.copyWith(
    components: theme.components.copyWith(
      // Blurred shadows rasterize differently across Skia hosts. Token tests
      // cover their ordered values; this golden keeps depth tone and outline
      // evidence deterministic across local and CI platforms.
      surface: surface.copyWith(
        deeplySunken: surface.deeplySunken.copyWith(shadowOpacity: 0),
        sunken: surface.sunken.copyWith(shadowOpacity: 0),
        flat: surface.flat.copyWith(shadowOpacity: 0),
        raised: surface.raised.copyWith(shadowOpacity: 0),
        elevated: surface.elevated.copyWith(shadowOpacity: 0),
      ),
    ),
  );
}

class _DepthScene extends StatelessWidget {
  const _DepthScene({required this.theme});

  final NemoThemeData theme;

  @override
  Widget build(BuildContext context) => Theme(
    data: goldenThemeData(theme),
    child: ColoredBox(
      color: theme.semantic.surface,
      child: SizedBox(
        height: 300,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: NemoSurface(
            depth: NemoSurfaceDepth.flat,
            shape: NemoSurfaceShape.roundedLarge,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: <Widget>[
                _DepthTile(
                  depth: NemoSurfaceDepth.deeplySunken,
                  child: const _WellContent(),
                ),
                const SizedBox(width: 16),
                _DepthTile(
                  depth: NemoSurfaceDepth.sunken,
                  child: const _FieldContent(),
                ),
                const SizedBox(width: 16),
                _DepthTile(
                  depth: NemoSurfaceDepth.raised,
                  child: const _PanelContent(),
                ),
                const SizedBox(width: 16),
                _DepthTile(
                  depth: NemoSurfaceDepth.elevated,
                  child: const _ActionContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _DepthTile extends StatelessWidget {
  const _DepthTile({required this.depth, required this.child});

  final NemoSurfaceDepth depth;
  final Widget child;

  @override
  Widget build(BuildContext context) => Expanded(
    child: NemoSurface(
      depth: depth,
      shape: NemoSurfaceShape.roundedMedium,
      padding: const EdgeInsets.all(12),
      child: child,
    ),
  );
}

class _WellContent extends StatelessWidget {
  const _WellContent();

  @override
  Widget build(BuildContext context) => const Align(
    alignment: Alignment.bottomCenter,
    child: _ContentBlock(height: 56),
  );
}

class _FieldContent extends StatelessWidget {
  const _FieldContent();

  @override
  Widget build(BuildContext context) => const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      _ContentBlock(height: 12),
      SizedBox(height: 8),
      _ContentBlock(height: 28),
    ],
  );
}

class _PanelContent extends StatelessWidget {
  const _PanelContent();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      _ContentBlock(widthFactor: 0.42, height: 12),
      SizedBox(height: 10),
      _ContentBlock(height: 20),
    ],
  );
}

class _ActionContent extends StatelessWidget {
  const _ActionContent();

  @override
  Widget build(BuildContext context) =>
      const Center(child: _ContentBlock(widthFactor: 0.58, height: 48));
}

class _ContentBlock extends StatelessWidget {
  const _ContentBlock({required this.height, this.widthFactor = 1});

  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    widthFactor: widthFactor,
    child: SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: NemoTheme.of(context).semantic.mutedForeground
              .withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ),
  );
}
