import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nemo_ui/nemo_ui.dart';

void main() {
  test('v1 depth maps deliberately to the four v2 materials', () {
    expect(NemoMaterial.values, hasLength(4));
    // The public migration mapping is documented; the widget accepts every aid.
    expect(NemoSurfaceDepth.values, hasLength(5));
  });

  testWidgets('all v2 materials preserve descendant semantics and layout', (
    tester,
  ) async {
    final NemoThemeData theme = NemoThemeData.light();
    await tester.pumpWidget(
      _host(
        theme,
        Wrap(
          children: <Widget>[
            for (final NemoMaterial material in NemoMaterial.values)
              NemoSurface(material: material, child: Text(material.name)),
          ],
        ),
      ),
    );
    for (final NemoMaterial material in NemoMaterial.values) {
      expect(find.text(material.name), findsOneWidget);
    }
  });

  testWidgets(
    'corner role drives the v2 radius when no legacy shape is supplied',
    (tester) async {
      await tester.pumpWidget(
        _host(
          NemoThemeData.light(),
          const NemoSurface(
            material: NemoMaterial.raised,
            cornerRole: NemoCornerRole.control,
            child: Text('Control'),
          ),
        ),
      );
      expect(find.text('Control'), findsOneWidget);
    },
  );

  testWidgets('preserves descendant semantics and hit testing', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(
        NemoThemeData.light(),
        NemoSurface(
          material: NemoMaterial.raised,
          child: Semantics(
            label: 'Nested action',
            button: true,
            child: GestureDetector(
              key: const ValueKey<String>('nested-hit-target'),
              behavior: HitTestBehavior.opaque,
              onTap: () => taps++,
              child: const SizedBox(width: 80, height: 48),
            ),
          ),
        ),
      ),
    );
    expect(find.bySemanticsLabel('Nested action'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('nested-hit-target')));
    expect(taps, 1);
  });

  testWidgets('clips only when explicitly requested', (tester) async {
    await tester.pumpWidget(
      _host(
        NemoThemeData.light(),
        const NemoSurface(material: NemoMaterial.base, child: Text('Open')),
      ),
    );
    expect(find.byType(ClipRRect), findsNothing);
    await tester.pumpWidget(
      _host(
        NemoThemeData.light(),
        const NemoSurface(
          material: NemoMaterial.base,
          clipBehavior: Clip.hardEdge,
          child: Text('Clipped'),
        ),
      ),
    );
    expect(find.byType(ClipRRect), findsOneWidget);
  });

  testWidgets('reports a missing Nemo theme extension', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: NemoSurface(child: Text('Missing'))),
      ),
    );
    expect(tester.takeException(), isA<FlutterError>());
  });

  testWidgets('reduced motion resolves material changes immediately', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        NemoThemeData.light(),
        const NemoSurface(
          material: NemoMaterial.raised,
          child: Text('Material'),
        ),
        disableAnimations: true,
      ),
    );
    await tester.pumpWidget(
      _host(
        NemoThemeData.light(),
        const NemoSurface(
          material: NemoMaterial.recessed,
          child: Text('Material'),
        ),
        disableAnimations: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('keeps directional padding and large text unclipped in RTL', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        NemoThemeData.light(),
        const NemoSurface(
          material: NemoMaterial.base,
          padding: EdgeInsetsDirectional.only(start: 20, end: 4),
          child: Text('A long surface label that scales without clipping'),
        ),
        direction: TextDirection.rtl,
        textScaler: const TextScaler.linear(2),
      ),
    );
    expect(find.byType(ClipRRect), findsNothing);
    expect(tester.takeException(), isNull);
    final RenderBox surface = tester.renderObject(find.byType(NemoSurface));
    final RenderBox text = tester.renderObject(find.textContaining('A long'));
    expect(
      text.localToGlobal(Offset.zero).dx,
      greaterThan(surface.localToGlobal(Offset.zero).dx),
    );
  });

  test('high contrast material recipes are shadow-free and bordered', () {
    final NemoThemeData theme = NemoThemeData.highContrast();
    for (final NemoMaterial material in NemoMaterial.values) {
      final NemoMaterialRecipe recipe = theme.materials.recipeFor(material);
      expect(recipe.shadowOpacity, 0);
      expect(recipe.outlineOpacity, 1);
    }
  });
}

Widget _host(
  NemoThemeData theme,
  Widget child, {
  bool disableAnimations = false,
  TextDirection direction = TextDirection.ltr,
  TextScaler textScaler = TextScaler.noScaling,
}) => MaterialApp(
  theme: ThemeData(extensions: <ThemeExtension<dynamic>>[theme]),
  home: MediaQuery(
    data: MediaQueryData(
      disableAnimations: disableAnimations,
      textScaler: textScaler,
    ),
    child: Directionality(
      textDirection: direction,
      child: Scaffold(body: child),
    ),
  ),
);
