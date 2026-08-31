import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nemo_ui/nemo_ui.dart';

import '../support/golden_test_harness.dart';

void main() {
  testWidgets(
    'renders every surface depth, tone, and shape in every foundation theme',
    (WidgetTester tester) async {
      configureGoldenTest(tester, physicalSize: const Size(720, 900));

      await tester.pumpWidget(
        goldenTestApp(scaffold: false, child: _SurfaceGoldenCatalog()),
      );

      expect(find.byType(NemoSurface), findsNWidgets(90));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/nemo_surface.png'),
      );
    },
  );
}

class _SurfaceGoldenCatalog extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      _themeCatalog(NemoThemeData.light()),
      const SizedBox(height: 12),
      _themeCatalog(NemoThemeData.dark()),
      const SizedBox(height: 12),
      _themeCatalog(NemoThemeData.highContrast()),
    ],
  );

  Widget _themeCatalog(NemoThemeData theme) {
    final NemoSurfaceTokens surfaceTokens = theme.components.surface;
    final NemoThemeData stableTheme = theme.copyWith(
      components: theme.components.copyWith(
        // Blurred shadows rasterize differently across Skia hosts. The golden
        // retains the real tone, outline, depth category, and shape contract.
        surface: surfaceTokens.copyWith(
          deeplySunken: surfaceTokens.deeplySunken.copyWith(shadowOpacity: 0),
          sunken: surfaceTokens.sunken.copyWith(shadowOpacity: 0),
          flat: surfaceTokens.flat.copyWith(shadowOpacity: 0),
          raised: surfaceTokens.raised.copyWith(shadowOpacity: 0),
          elevated: surfaceTokens.elevated.copyWith(shadowOpacity: 0),
        ),
      ),
    );
    return Theme(
      data: goldenThemeData(stableTheme),
      child: ColoredBox(
        color: stableTheme.semantic.surface,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final NemoSurfaceDepth depth in NemoSurfaceDepth.values)
                for (final NemoSurfaceTone tone in NemoSurfaceTone.values)
                  for (final NemoSurfaceShape shape in NemoSurfaceShape.values)
                    SizedBox(
                      width: 104,
                      height: 48,
                      child: NemoSurface(
                        depth: depth,
                        tone: tone,
                        shape: shape,
                        padding: EdgeInsets.zero,
                        child: const SizedBox.expand(),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
