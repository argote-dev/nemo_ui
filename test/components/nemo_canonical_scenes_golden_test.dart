import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nemo_ui/nemo_ui.dart';

import '../support/golden_test_harness.dart';

void main() {
  for (final ({String name, NemoThemeData theme}) scene
      in <({String name, NemoThemeData theme})>[
        (name: 'light', theme: NemoThemeData.light()),
        (name: 'dark', theme: NemoThemeData.dark()),
        (name: 'high_contrast', theme: NemoThemeData.highContrast()),
      ]) {
    testWidgets('work dashboard ${scene.name} canonical scene', (tester) async {
      configureGoldenTest(tester, physicalSize: const Size(800, 640));
      await tester.pumpWidget(
        goldenTestApp(theme: scene.theme, child: const _DashboardScene()),
      );
      await expectLater(
        find.byType(_DashboardScene),
        matchesGoldenFile('goldens/nemo_dashboard_${scene.name}.png'),
      );
    });

    testWidgets('settings ${scene.name} canonical scene', (tester) async {
      configureGoldenTest(tester, physicalSize: const Size(800, 640));
      await tester.pumpWidget(
        goldenTestApp(theme: scene.theme, child: const _SettingsScene()),
      );
      await expectLater(
        find.byType(_SettingsScene),
        matchesGoldenFile('goldens/nemo_settings_${scene.name}.png'),
      );
    });

    testWidgets('catalog inspector ${scene.name} canonical scene', (
      tester,
    ) async {
      configureGoldenTest(tester, physicalSize: const Size(900, 720));
      await tester.pumpWidget(
        goldenTestApp(
          theme: scene.theme,
          child: const _CatalogInspectorScene(),
        ),
      );
      await expectLater(
        find.byType(_CatalogInspectorScene),
        matchesGoldenFile('goldens/nemo_catalog_inspector_${scene.name}.png'),
      );
    });
  }
}

class _DashboardScene extends StatelessWidget {
  const _DashboardScene();

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    return NemoPage(
      topBar: NemoTopBar(
        title: _block(
          label: 'Work dashboard',
          width: 148,
          color: theme.semantic.primary,
        ),
      ),
      child: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              NemoSection(
                heading: _block(
                  label: 'Today heading',
                  width: 110,
                  height: 20,
                  color: theme.semantic.foreground,
                ),
                description: _block(
                  label: 'Today description',
                  width: 220,
                  height: 12,
                  color: theme.semantic.mutedForeground,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: NemoSurface(
                        material: NemoMaterial.recessed,
                        child: _block(
                          label: 'Receiving inbox',
                          width: 160,
                          height: 88,
                          color: theme.semantic.surfaceVariant,
                        ),
                      ),
                    ),
                    SizedBox(width: theme.foundation.space16),
                    Expanded(
                      child: NemoSurface(
                        material: NemoMaterial.raised,
                        child: NemoButton(
                          onPressed: () {},
                          semanticLabel: 'Capture task',
                          child: _block(
                            label: 'Capture task',
                            width: 96,
                            height: 18,
                            color: theme.semantic.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: NemoSurface(
              material: NemoMaterial.floating,
              cornerRole: NemoCornerRole.floating,
              child: _block(
                label: 'Transient confirmation',
                width: 200,
                height: 18,
                color: theme.semantic.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsScene extends StatelessWidget {
  const _SettingsScene();

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    return NemoPage(
      topBar: NemoTopBar(
        title: _block(
          label: 'Settings',
          width: 84,
          color: theme.semantic.primary,
        ),
      ),
      child: ListView(
        children: <Widget>[
          NemoSection(
            heading: _block(
              label: 'Identity heading',
              width: 132,
              height: 20,
              color: theme.semantic.foreground,
            ),
            description: _block(
              label: 'Identity description',
              width: 200,
              height: 12,
              color: theme.semantic.mutedForeground,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                NemoSurface(
                  material: NemoMaterial.recessed,
                  child: _block(
                    label: 'Display name field',
                    width: 180,
                    height: 28,
                    color: theme.semantic.foreground,
                  ),
                ),
                SizedBox(height: theme.foundation.space16),
                NemoSwitch(
                  value: true,
                  onChanged: (_) {},
                  semanticLabel: 'Daily brief',
                  child: _block(
                    label: 'Daily brief',
                    width: 96,
                    height: 16,
                    color: theme.semantic.foreground,
                  ),
                ),
                SizedBox(height: theme.foundation.space12),
                _block(
                  label: 'Unsaved status',
                  width: 120,
                  height: 12,
                  color: theme.semantic.mutedForeground,
                ),
              ],
            ),
          ),
          SizedBox(height: theme.foundation.space24),
          NemoSurface(
            material: NemoMaterial.raised,
            child: NemoButton(
              onPressed: () {},
              semanticLabel: 'Save preferences',
              child: _block(
                label: 'Save preferences',
                width: 108,
                height: 18,
                color: theme.semantic.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogInspectorScene extends StatelessWidget {
  const _CatalogInspectorScene();

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    return Stack(
      children: <Widget>[
        NemoPage(
          topBar: NemoTopBar(
            title: _block(
              label: 'Catalog inspector',
              width: 160,
              color: theme.semantic.primary,
            ),
          ),
          child: ListView(
            children: <Widget>[
              NemoSection(
                heading: _block(
                  label: 'States heading',
                  width: 120,
                  height: 20,
                  color: theme.semantic.foreground,
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: <Widget>[
                    NemoButton(
                      onPressed: () {},
                      semanticLabel: 'Resting action',
                      child: _block(
                        label: 'Resting action',
                        width: 88,
                        height: 16,
                        color: theme.semantic.onPrimary,
                      ),
                    ),
                    const NemoButton(
                      onPressed: null,
                      semanticLabel: 'Unavailable',
                      child: SizedBox(width: 72, height: 16),
                    ),
                    NemoSwitch(
                      value: true,
                      onChanged: (_) {},
                      semanticLabel: 'Selected',
                      child: _block(
                        label: 'Selected',
                        width: 64,
                        height: 16,
                        color: theme.semantic.foreground,
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: NemoSurface(
                        material: NemoMaterial.recessed,
                        child: _block(
                          label: 'Field specimen',
                          width: 140,
                          height: 24,
                          color: theme.semantic.foreground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: theme.foundation.space16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: NemoSurface(
                      material: NemoMaterial.raised,
                      child: _block(
                        label: 'Canvas baseline',
                        width: 96,
                        height: 48,
                        color: theme.semantic.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: theme.foundation.space12),
                  Expanded(
                    child: NemoSurface(
                      material: NemoMaterial.raised,
                      child: _block(
                        label: 'Fragment experimental stays Canvas',
                        width: 96,
                        height: 48,
                        color: theme.semantic.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: theme.foundation.space12),
                  Expanded(
                    child: NemoSurface(
                      material: NemoMaterial.raised,
                      child: _block(
                        label: 'Glass overlay only',
                        width: 96,
                        height: 48,
                        color: theme.semantic.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: NemoSurface(
              material: NemoMaterial.floating,
              finish: NemoSurfaceFinish.tactileGlass,
              cornerRole: NemoCornerRole.floating,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _block(
                    label: 'Inspector heading',
                    width: 140,
                    height: 18,
                    color: theme.semantic.foreground,
                  ),
                  SizedBox(height: theme.foundation.space12),
                  NemoButton(
                    onPressed: () {},
                    semanticLabel: 'Dismiss inspector',
                    child: _block(
                      label: 'Dismiss',
                      width: 72,
                      height: 16,
                      color: theme.semantic.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _block({
  required String label,
  required double width,
  required Color color,
  double height = 18,
}) => Semantics(
  label: label,
  child: SizedBox(
    width: width,
    height: height,
    child: ColoredBox(color: color),
  ),
);
