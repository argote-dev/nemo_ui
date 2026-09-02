import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nemo_ui/nemo_ui.dart';
import 'package:nemo_ui/src/components/nemo_surface_renderer.dart';

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

  testWidgets(
    'Canvas fallback selection retains public layout and named descendant semantics',
    (tester) async {
      final List<SurfaceRendererInput> selections = <SurfaceRendererInput>[];
      final List<SurfaceRenderer> fallbacks = <SurfaceRenderer>[];
      debugSurfaceRendererSelectionOverride = (input, fallback) {
        selections.add(input);
        fallbacks.add(fallback);
        return SurfaceRenderer.canvas;
      };
      addTearDown(() => debugSurfaceRendererSelectionOverride = null);
      await tester.pumpWidget(
        _host(
          NemoThemeData.light(),
          Wrap(
            children: <Widget>[
              _rendererFallbackSurface(
                // The internal selection seam represents either an unavailable
                // backend or the null result after a program-load failure.
                label: 'Unavailable renderer content',
                material: NemoMaterial.floating,
                enableProgressiveRendering: true,
              ),
              _rendererFallbackSurface(
                label: 'Unsupported dense content',
                material: NemoMaterial.raised,
                size: const Size(96, 48),
                enableProgressiveRendering: true,
              ),
              _rendererFallbackSurface(
                label: 'Opt-out content',
                material: NemoMaterial.floating,
              ),
            ],
          ),
        ),
      );
      for (final String label in <String>[
        'Unavailable renderer content',
        'Unsupported dense content',
        'Opt-out content',
      ]) {
        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is Semantics && widget.properties.label == label,
          ),
          findsOneWidget,
        );
      }
      expect(
        tester.getSize(find.byType(NemoSurface).first),
        const Size(360, 240),
      );
      expect(selections, hasLength(3));
      expect(fallbacks, everyElement(SurfaceRenderer.canvas));
      expect(selections[1].size, const Size(96, 48));
      expect(selections.last.isEnabled, isFalse);
    },
  );

  testWidgets('high contrast retains Canvas layout and descendant semantics', (
    tester,
  ) async {
    debugSurfaceRendererSelectionOverride = (_, _) => SurfaceRenderer.canvas;
    addTearDown(() => debugSurfaceRendererSelectionOverride = null);
    await tester.pumpWidget(
      _host(
        NemoThemeData.highContrast(),
        _rendererFallbackSurface(
          label: 'High contrast content',
          material: NemoMaterial.floating,
          enableProgressiveRendering: true,
        ),
      ),
    );
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Semantics &&
            widget.properties.label == 'High contrast content',
      ),
      findsOneWidget,
    );
    expect(tester.getSize(find.byType(NemoSurface)), const Size(360, 240));
  });

  testWidgets('theme transitions keep the experimental finish on Canvas', (
    tester,
  ) async {
    final List<SurfaceRendererInput> selections = <SurfaceRendererInput>[];
    debugSurfaceRendererSelectionOverride = (input, fallback) {
      selections.add(input);
      return SurfaceRenderer.canvas;
    };
    addTearDown(() => debugSurfaceRendererSelectionOverride = null);
    const Key surfaceKey = ValueKey<String>('theme-transition-surface');

    await tester.pumpWidget(
      _host(
        NemoThemeData.light(),
        SizedBox(
          width: 360,
          height: 240,
          child: NemoSurface(
            key: surfaceKey,
            material: NemoMaterial.floating,
            enableProgressiveRendering: true,
            child: Semantics(label: 'Theme transition content'),
          ),
        ),
      ),
    );
    await tester.pumpWidget(
      _host(
        NemoThemeData.dark(),
        SizedBox(
          width: 360,
          height: 240,
          child: NemoSurface(
            key: surfaceKey,
            material: NemoMaterial.floating,
            enableProgressiveRendering: true,
            child: Semantics(label: 'Theme transition content'),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1));

    expect(selections.last.isEnabled, isFalse);
    expect(find.bySemanticsLabel('Theme transition content'), findsOneWidget);
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

// Renderer selection remains an internal test seam; consumers only observe the
// stable NemoSurface layout and descendant semantics.

Widget _rendererFallbackSurface({
  required String label,
  required NemoMaterial material,
  bool enableProgressiveRendering = false,
  Size size = const Size(360, 240),
}) => SizedBox(
  width: size.width,
  height: size.height,
  child: NemoSurface(
    material: material,
    enableProgressiveRendering: enableProgressiveRendering,
    child: Semantics(container: true, label: label, child: Text(label)),
  ),
);
