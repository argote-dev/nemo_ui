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
    testWidgets('dashboard ${scene.name} canonical scene', (tester) async {
      configureGoldenTest(tester, physicalSize: const Size(800, 600));
      await tester.pumpWidget(
        goldenTestApp(
          theme: scene.theme,
          child: const _CompositionScene(title: 'Dashboard'),
        ),
      );
      await expectLater(
        find.byType(_CompositionScene),
        matchesGoldenFile('goldens/nemo_page_dashboard_${scene.name}.png'),
      );
    });

    testWidgets('settings ${scene.name} canonical scene', (tester) async {
      configureGoldenTest(tester, physicalSize: const Size(800, 600));
      await tester.pumpWidget(
        goldenTestApp(
          theme: scene.theme,
          child: const _CompositionScene(title: 'Settings'),
        ),
      );
      await expectLater(
        find.byType(_CompositionScene),
        matchesGoldenFile('goldens/nemo_page_settings_${scene.name}.png'),
      );
    });
  }
}

class _CompositionScene extends StatelessWidget {
  const _CompositionScene({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final bool dashboard = title == 'Dashboard';
    final NemoThemeData theme = NemoTheme.of(context);
    return NemoPage(
      topBar: NemoTopBar(
        title: _block(
          label: title,
          width: dashboard ? 120 : 84,
          color: theme.semantic.primary,
        ),
      ),
      child: ListView(
        children: <Widget>[
          NemoSection(
            heading: _block(
              label: '$title heading',
              width: 96,
              height: 20,
              color: theme.semantic.foreground,
            ),
            description: _block(
              label: '$title description',
              width: 160,
              height: 12,
              color: theme.semantic.mutedForeground,
            ),
            child: dashboard
                ? _Dashboard(theme: theme)
                : _Settings(theme: theme),
          ),
        ],
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.theme});
  final NemoThemeData theme;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 16,
    runSpacing: 16,
    children: <Widget>[
      SizedBox(
        width: 180,
        child: NemoSurface(
          material: NemoMaterial.raised,
          child: _block(
            label: 'Summary card',
            width: 132,
            height: 92,
            color: theme.semantic.primary,
          ),
        ),
      ),
      SizedBox(
        width: 140,
        child: NemoSurface(
          material: NemoMaterial.recessed,
          child: _block(
            label: 'Activity card',
            width: 92,
            height: 92,
            color: theme.semantic.surfaceVariant,
          ),
        ),
      ),
    ],
  );
}

class _Settings extends StatelessWidget {
  const _Settings({required this.theme});
  final NemoThemeData theme;

  @override
  Widget build(BuildContext context) => NemoSurface(
    material: NemoMaterial.raised,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        NemoSurface(
          material: NemoMaterial.recessed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _block(
                label: 'Daily brief setting',
                width: 108,
                height: 18,
                color: theme.semantic.primary,
              ),
              _block(
                label: 'Daily brief enabled',
                width: 28,
                height: 18,
                color: theme.semantic.foreground,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        NemoButton(
          onPressed: () {},
          semanticLabel: 'Save settings',
          child: _block(
            label: 'Save settings control',
            width: 84,
            height: 18,
            color: theme.semantic.onPrimary,
          ),
        ),
      ],
    ),
  );
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
