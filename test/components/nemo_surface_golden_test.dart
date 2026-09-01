import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nemo_ui/nemo_ui.dart';

import '../support/golden_test_harness.dart';

void main() {
  testWidgets(
    'renders composed light, dark, and high-contrast material scenes',
    (WidgetTester tester) async {
      configureGoldenTest(tester, physicalSize: const Size(720, 900));

      await tester.pumpWidget(
        goldenTestApp(scaffold: false, child: const _SurfaceMaterialScenes()),
      );

      expect(find.byType(NemoSurface), findsNWidgets(15));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/nemo_surface.png'),
      );
    },
  );
}

class _SurfaceMaterialScenes extends StatelessWidget {
  const _SurfaceMaterialScenes();

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      _MaterialScene(theme: NemoThemeData.light()),
      _MaterialScene(theme: NemoThemeData.dark()),
      // High contrast is a separately visible, shadow-free scene.
      _MaterialScene(theme: NemoThemeData.highContrast()),
    ],
  );
}

class _MaterialScene extends StatelessWidget {
  const _MaterialScene({required this.theme});

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
            material: NemoMaterial.base,
            cornerRole: NemoCornerRole.panel,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: <Widget>[
                _MaterialTile(
                  material: NemoMaterial.recessed,
                  child: const _WellContent(),
                ),
                const SizedBox(width: 16),
                _MaterialTile(
                  material: NemoMaterial.recessed,
                  child: const _FieldContent(),
                ),
                const SizedBox(width: 16),
                _MaterialTile(
                  material: NemoMaterial.raised,
                  child: const _PanelContent(),
                ),
                const SizedBox(width: 16),
                _MaterialTile(
                  material: NemoMaterial.floating,
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

class _MaterialTile extends StatelessWidget {
  const _MaterialTile({required this.material, required this.child});

  final NemoMaterial material;
  final Widget child;

  @override
  Widget build(BuildContext context) => Expanded(
    child: NemoSurface(
      material: material,
      cornerRole: NemoCornerRole.panel,
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
