import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nemo_ui/nemo_ui.dart';

void main() {
  testWidgets('exposes a heading and preserves description/content order', (
    tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        const NemoSection(
          heading: Text('Preferences'),
          description: Text('Control account delivery.'),
          child: Text('Daily brief'),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.text('Preferences')),
      matchesSemantics(isHeader: true, label: 'Preferences'),
    );
    expect(
      tester.getTopLeft(find.text('Control account delivery.')).dy,
      lessThan(tester.getTopLeft(find.text('Daily brief')).dy),
    );
    handle.dispose();
  });

  testWidgets('preserves child focus traversal order', (tester) async {
    await tester.pumpWidget(
      _host(
        NemoSection(
          heading: const Text('Preferences'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              NemoButton(onPressed: () {}, child: const Text('First choice')),
              NemoButton(onPressed: () {}, child: const Text('Second choice')),
            ],
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(
      Focus.of(tester.element(find.text('First choice'))).hasFocus,
      isTrue,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(
      Focus.of(tester.element(find.text('Second choice'))).hasFocus,
      isTrue,
    );
  });

  testWidgets('reflows narrow enlarged text without overflow', (tester) async {
    await tester.pumpWidget(
      _host(
        const SingleChildScrollView(
          child: SizedBox(
            width: 180,
            child: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(2)),
              child: NemoSection(
                heading: Text(
                  'A heading that remains readable at larger text sizes',
                ),
                description: Text('Supporting text wraps instead of clipping.'),
                child: Text('Section content'),
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  for (final ({String name, NemoThemeData theme, bool reducedMotion}) host
      in <({String name, NemoThemeData theme, bool reducedMotion})>[
        (name: 'light', theme: NemoThemeData.light(), reducedMotion: false),
        (name: 'dark', theme: NemoThemeData.dark(), reducedMotion: false),
        (
          name: 'high contrast reduced motion',
          theme: NemoThemeData.highContrast(),
          reducedMotion: true,
        ),
      ]) {
    testWidgets('renders safely in ${host.name}', (tester) async {
      await tester.pumpWidget(
        _host(
          MediaQuery(
            data: MediaQueryData(disableAnimations: host.reducedMotion),
            child: const NemoSection(
              heading: Text('Appearance'),
              child: Text('Theme-hosted content'),
            ),
          ),
          theme: host.theme,
        ),
      );
      expect(find.text('Theme-hosted content'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

Widget _host(Widget child, {NemoThemeData? theme}) => MaterialApp(
  theme: ThemeData(
    extensions: <ThemeExtension<dynamic>>[theme ?? NemoThemeData.light()],
  ),
  home: Scaffold(body: child),
);
