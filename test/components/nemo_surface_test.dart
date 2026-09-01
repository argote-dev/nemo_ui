import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nemo_ui/nemo_ui.dart';

void main() {
  group('NemoSurface', () {
    testWidgets('uses the documented defaults and theme padding', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const NemoSurface(child: Text('content'))));

      final NemoSurface surface = tester.widget<NemoSurface>(
        find.byType(NemoSurface),
      );
      final Padding padding = tester.widget<Padding>(find.byType(Padding));

      expect(surface.depth, NemoSurfaceDepth.raised);
      expect(surface.tone, NemoSurfaceTone.surface);
      expect(surface.shape, NemoSurfaceShape.roundedMedium);
      expect(surface.clipBehavior, Clip.none);
      expect(padding.padding, const EdgeInsets.all(16));
    });

    testWidgets('keeps descendant semantics and hit testing transparent', (
      WidgetTester tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          NemoSurface(
            child: TextButton(
              onPressed: () => taps += 1,
              child: const Text('Activate'),
            ),
          ),
        ),
      );

      expect(tester.getSemantics(find.byType(NemoSurface)), isNotNull);
      expect(find.bySemanticsLabel('Activate'), findsOneWidget);
      await tester.tap(find.text('Activate'));
      expect(taps, 1);
    });

    testWidgets('clips only when explicitly requested', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const NemoSurface(
            clipBehavior: Clip.antiAlias,
            child: SizedBox(width: 40, height: 40),
          ),
        ),
      );

      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('requires a Nemo theme extension', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: NemoSurface(child: SizedBox())),
        ),
      );

      expect(tester.takeException(), isA<FlutterError>());
    });

    testWidgets('reduced motion applies depth changes immediately', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const NemoSurface(
            depth: NemoSurfaceDepth.raised,
            child: SizedBox(width: 40, height: 40),
          ),
          disableAnimations: true,
        ),
      );
      await tester.pumpWidget(
        _host(
          const NemoSurface(
            depth: NemoSurfaceDepth.sunken,
            child: SizedBox(width: 40, height: 40),
          ),
          disableAnimations: true,
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.binding.transientCallbackCount, 0);
    });

    test('standard depth tokens form a restrained five-level hierarchy in both themes', () {
      for (final NemoThemeData theme in <NemoThemeData>[
        NemoThemeData.light(),
        NemoThemeData.dark(),
      ]) {
        final NemoSurfaceTokens tokens = theme.components.surface;

        expect(
          tokens.deeplySunken.intensity,
          lessThan(tokens.sunken.intensity),
        );
        expect(tokens.sunken.intensity, lessThan(tokens.flat.intensity));
        expect(tokens.flat.intensity, lessThan(tokens.raised.intensity));
        expect(tokens.raised.intensity, lessThan(tokens.elevated.intensity));

        expect(
          tokens.deeplySunken.tonalOverlayOpacity,
          greaterThan(tokens.sunken.tonalOverlayOpacity),
        );
        expect(tokens.sunken.tonalOverlayOpacity, greaterThan(0));
        expect(tokens.raised.tonalOverlayOpacity, greaterThan(0));
        expect(
          tokens.elevated.tonalOverlayOpacity,
          greaterThan(tokens.raised.tonalOverlayOpacity),
        );
        expect(
          tokens.flat.tonalOverlayOpacity,
          lessThan(tokens.sunken.tonalOverlayOpacity),
        );
        expect(
          tokens.flat.tonalOverlayOpacity,
          lessThan(tokens.raised.tonalOverlayOpacity),
        );

        expect(
          tokens.deeplySunken.shadowOpacity,
          greaterThan(tokens.sunken.shadowOpacity),
        );
        expect(tokens.sunken.shadowOpacity, greaterThan(0));
        expect(tokens.flat.shadowOpacity, 0);
        expect(
          tokens.elevated.shadowOpacity,
          greaterThan(tokens.raised.shadowOpacity),
        );
        expect(tokens.raised.shadowOpacity, greaterThan(0));
        expect(
          tokens.deeplySunken.blurMultiplier,
          greaterThan(tokens.sunken.blurMultiplier),
        );
        expect(
          tokens.elevated.blurMultiplier,
          greaterThan(tokens.raised.blurMultiplier),
        );
        expect(
          tokens.deeplySunken.offsetMultiplier,
          greaterThan(tokens.sunken.offsetMultiplier),
        );
        expect(
          tokens.elevated.offsetMultiplier,
          greaterThan(tokens.raised.offsetMultiplier),
        );

        expect(tokens.sunken.outlineOpacity, lessThan(0.2));
        expect(tokens.raised.outlineOpacity, lessThan(0.2));
        for (final NemoSurfaceDepth depth in NemoSurfaceDepth.values) {
          final NemoSurfaceDepthStyle style = tokens.styleFor(depth);
          for (final Color baseTone in <Color>[
            theme.semantic.surface,
            theme.semantic.surfaceVariant,
          ]) {
            final Color renderedTone = _postOverlayTone(theme, style, baseTone);
            expect(
              _contrastRatio(theme.semantic.foreground, renderedTone),
              greaterThanOrEqualTo(4.5),
            );
          }
        }
      }
    });

    test(
      'high contrast collapses depth while keeping 2px explicit boundaries',
      () {
        final NemoThemeData theme = NemoThemeData.highContrast();
        final NemoSurfaceTokens tokens = theme.components.surface;

        expect(tokens.deeplySunken, tokens.sunken);
        expect(tokens.raised, tokens.elevated);
        expect(tokens.flat.intensity, 0);
        expect(theme.components.outlineWidth, 2);
        for (final NemoSurfaceDepth depth in NemoSurfaceDepth.values) {
          final NemoSurfaceDepthStyle style = tokens.styleFor(depth);
          expect(style.shadowOpacity, 0);
          expect(style.blurMultiplier, 0);
          expect(style.offsetMultiplier, 0);
          expect(style.outlineOpacity, greaterThan(0));
        }
      },
    );

    test('surface token values support copy, equality, and interpolation', () {
      final NemoSurfaceTokens base = NemoSurfaceTokens.standard;
      final NemoSurfaceTokens changed = base.copyWith(
        raised: base.raised.copyWith(shadowOpacity: 0.75),
      );

      expect(base.copyWith(), base);
      expect(changed, isNot(base));
      expect(NemoSurfaceTokens.lerp(base, changed, 1), changed);
    });
  });

  _surfaceVocabularyTests();
}

Widget _host(
  Widget child, {
  bool disableAnimations = false,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  final NemoThemeData theme = NemoThemeData.light();
  return MaterialApp(
    theme: ThemeData(extensions: <ThemeExtension<dynamic>>[theme]),
    home: MediaQuery(
      data: MediaQueryData(
        disableAnimations: disableAnimations,
        textScaler: textScaler,
      ),
      child: Scaffold(backgroundColor: theme.semantic.surface, body: child),
    ),
  );
}

// Contract coverage for the complete finite Surface vocabulary.
void _surfaceVocabularyTests() {
  testWidgets('supports every depth, tone, and shape', (
    WidgetTester tester,
  ) async {
    final List<NemoSurface> surfaces = <NemoSurface>[
      for (final NemoSurfaceDepth depth in NemoSurfaceDepth.values)
        for (final NemoSurfaceTone tone in NemoSurfaceTone.values)
          for (final NemoSurfaceShape shape in NemoSurfaceShape.values)
            NemoSurface(
              depth: depth,
              tone: tone,
              shape: shape,
              padding: EdgeInsets.zero,
              child: Text('${depth.name}-${tone.name}-${shape.name}'),
            ),
    ];
    await tester.pumpWidget(_host(Wrap(children: surfaces)));

    expect(find.byType(NemoSurface), findsNWidgets(30));
    for (final NemoSurfaceDepth depth in NemoSurfaceDepth.values) {
      expect(
        tester
            .widgetList<NemoSurface>(find.byType(NemoSurface))
            .where((NemoSurface surface) => surface.depth == depth),
        hasLength(6),
      );
    }
  });

  testWidgets('preserves directional padding and does not clip large text', (
    WidgetTester tester,
  ) async {
    const EdgeInsetsDirectional padding = EdgeInsetsDirectional.only(
      start: 12,
      end: 4,
    );
    await tester.pumpWidget(
      _host(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: NemoSurface(
            padding: padding,
            child: Text('Large content that must remain visible'),
          ),
        ),
        textScaler: TextScaler.linear(2),
      ),
    );

    expect(tester.widget<Padding>(find.byType(Padding)).padding, padding);
    expect(find.byType(ClipRRect), findsNothing);
    expect(find.text('Large content that must remain visible'), findsOneWidget);
  });

  test(
    'high contrast depth categories have distinct tone and outline styles',
    () {
      final NemoSurfaceTokens tokens =
          NemoThemeData.highContrast().components.surface;

      expect(tokens.sunken.tonalColor, NemoSurfaceTonalColor.foreground);
      expect(tokens.flat.tonalColor, NemoSurfaceTonalColor.surfaceVariant);
      expect(tokens.raised.tonalColor, NemoSurfaceTonalColor.surfaceVariant);
      expect(
        tokens.sunken.tonalOverlayOpacity,
        isNot(tokens.flat.tonalOverlayOpacity),
      );
      expect(tokens.flat.outlineOpacity, isNot(tokens.raised.outlineOpacity));
      expect(tokens.sunken.shadowOpacity, 0);
      expect(tokens.flat.shadowOpacity, 0);
      expect(tokens.raised.shadowOpacity, 0);
    },
  );

  test(
    'depth styles independently control blur, offset, contrast, and outline',
    () {
      final NemoSurfaceDepthStyle style = NemoSurfaceTokens.standard.elevated;
      final NemoSurfaceDepthStyle changed = style.copyWith(
        blurMultiplier: 0.25,
        offsetMultiplier: 0.5,
        tonalOverlayOpacity: 0.2,
        outlineOpacity: 0.9,
      );

      expect(changed.blurMultiplier, 0.25);
      expect(changed.offsetMultiplier, 0.5);
      expect(changed.tonalOverlayOpacity, 0.2);
      expect(changed.outlineOpacity, 0.9);
      expect(NemoSurfaceDepthStyle.lerp(style, changed, 1), changed);
    },
  );
}

Color _postOverlayTone(
  NemoThemeData theme,
  NemoSurfaceDepthStyle style,
  Color baseTone,
) {
  final Color overlay = switch (style.tonalColor) {
    NemoSurfaceTonalColor.highlightShadow => theme.semantic.highlightShadow,
    NemoSurfaceTonalColor.lowlightShadow => theme.semantic.lowlightShadow,
    NemoSurfaceTonalColor.foreground => theme.semantic.foreground,
    NemoSurfaceTonalColor.outline => theme.semantic.outline,
    NemoSurfaceTonalColor.surfaceVariant => theme.semantic.surfaceVariant,
  };
  return Color.alphaBlend(
    overlay.withValues(alpha: style.tonalOverlayOpacity),
    baseTone,
  );
}

double _contrastRatio(Color foreground, Color background) {
  final double lighter =
      foreground.computeLuminance() > background.computeLuminance()
      ? foreground.computeLuminance()
      : background.computeLuminance();
  final double darker =
      foreground.computeLuminance() > background.computeLuminance()
      ? background.computeLuminance()
      : foreground.computeLuminance();
  return (lighter + 0.05) / (darker + 0.05);
}
