import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nemo_ui/nemo_ui.dart';

void main() {
  test('rejects non-positive or non-finite content widths', () {
    expect(
      () => NemoPage(maxContentWidth: 0, child: const SizedBox()),
      throwsAssertionError,
    );
    expect(
      () => NemoPage(maxContentWidth: double.infinity, child: const SizedBox()),
      throwsAssertionError,
    );
  });

  testWidgets('owns the semantic surface canvas and composes a top bar', (
    tester,
  ) async {
    final NemoThemeData theme = NemoThemeData.light();
    await tester.pumpWidget(
      _host(
        const NemoPage(
          topBar: NemoTopBar(title: Text('Dashboard')),
          child: Text('Page content'),
        ),
        theme: theme,
      ),
    );

    expect(find.byType(NemoPage), findsOneWidget);
    expect(find.byType(NemoTopBar), findsOneWidget);
    expect(find.text('Page content'), findsOneWidget);
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      theme.semantic.surface,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('consumes the top safe inset exactly once with a NemoTopBar', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(top: 24)),
          child: const NemoPage(
            topBar: NemoTopBar(title: Text('Dashboard')),
            child: SizedBox(key: ValueKey<String>('content'), height: 1),
          ),
        ),
      ),
    );
    final RenderBox toolbar = tester.renderObject(
      find.byType(NavigationToolbar),
    );
    expect(toolbar.localToGlobal(Offset.zero).dy, 24);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('content'))).dy,
      NemoTopBar.toolbarHeight + 24 + 24,
    );
  });

  testWidgets('protects the top safe inset when no top bar is supplied', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(top: 24)),
          child: const NemoPage(
            child: SizedBox(key: ValueKey<String>('content'), height: 1),
          ),
        ),
      ),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('content'))).dy,
      48,
    );
  });

  testWidgets('resolves asymmetric directional insets in LTR and RTL', (
    tester,
  ) async {
    for (final ({TextDirection direction, double expectedX}) entry
        in <({TextDirection direction, double expectedX})>[
          (direction: TextDirection.ltr, expectedX: 10),
          (direction: TextDirection.rtl, expectedX: 30),
        ]) {
      await tester.pumpWidget(
        _host(
          Directionality(
            textDirection: entry.direction,
            child: const NemoPage(
              padding: EdgeInsetsDirectional.only(start: 10, end: 30),
              child: SizedBox(
                key: ValueKey<String>('directional'),
                width: double.infinity,
                height: 1,
              ),
            ),
          ),
        ),
      );
      expect(
        tester.getTopLeft(find.byKey(const ValueKey<String>('directional'))).dx,
        entry.expectedX,
      );
    }
  });

  testWidgets('constrains wide content and reflows on narrow layouts', (
    tester,
  ) async {
    Widget page(double width) => Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: width,
        child: const NemoPage(
          maxContentWidth: 200,
          child: SizedBox(
            key: ValueKey<String>('region'),
            width: double.infinity,
            height: 10,
          ),
        ),
      ),
    );

    await tester.pumpWidget(_host(page(300)));
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('region'))).width,
      152,
    );

    await tester.pumpWidget(_host(page(140)));
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('region'))).width,
      92,
    );
    expect(tester.takeException(), isNull);
  });

  for (final ({
        String name,
        NemoThemeData theme,
        TextDirection direction,
        bool reducedMotion,
      })
      host
      in <
        ({
          String name,
          NemoThemeData theme,
          TextDirection direction,
          bool reducedMotion,
        })
      >[
        (
          name: 'light narrow',
          theme: NemoThemeData.light(),
          direction: TextDirection.ltr,
          reducedMotion: false,
        ),
        (
          name: 'dark wide RTL',
          theme: NemoThemeData.dark(),
          direction: TextDirection.rtl,
          reducedMotion: false,
        ),
        (
          name: 'high contrast reduced motion',
          theme: NemoThemeData.highContrast(),
          direction: TextDirection.ltr,
          reducedMotion: true,
        ),
      ]) {
    testWidgets('composes an adaptive public surface in ${host.name}', (
      tester,
    ) async {
      final double width = host.name.contains('wide') ? 300 : 180;
      await tester.pumpWidget(
        _host(
          Directionality(
            textDirection: host.direction,
            child: SizedBox(
              width: width,
              child: MediaQuery(
                data: MediaQueryData(
                  textScaler: const TextScaler.linear(2),
                  disableAnimations: host.reducedMotion,
                ),
                child: NemoPage(
                  child: ListView(
                    children: <Widget>[
                      NemoSection(
                        heading: const Text('Adaptive composition heading'),
                        description: const Text(
                          'Supporting content reflows in every host.',
                        ),
                        child: const NemoSurface(child: SizedBox(height: 56)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          theme: host.theme,
        ),
      );
      expect(find.byType(NemoSurface), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('requires a Nemo theme', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: NemoPage(child: Text('Content'))),
    );
    expect(tester.takeException(), isA<FlutterError>());
  });
}

Widget _host(Widget child, {NemoThemeData? theme}) => MaterialApp(
  theme: ThemeData(
    extensions: <ThemeExtension<dynamic>>[theme ?? NemoThemeData.light()],
  ),
  home: child,
);
