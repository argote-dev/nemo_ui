import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nemo_ui/nemo_ui.dart';

import '../support/golden_test_harness.dart';

void main() {
  group('NemoButton', () {
    testWidgets('activates through touch, Enter, and Space', (
      WidgetTester tester,
    ) async {
      var calls = 0;
      final FocusNode focusNode = FocusNode();
      await tester.pumpWidget(
        _host(
          NemoButton(
            focusNode: focusNode,
            onPressed: () => calls++,
            child: const Text('Save'),
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(calls, 1);

      focusNode.requestFocus();
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.space);
      expect(calls, 3);
    });

    testWidgets('exposes button semantics and blocks disabled activation', (
      WidgetTester tester,
    ) async {
      var calls = 0;
      await tester.pumpWidget(
        _host(
          Column(
            children: <Widget>[
              NemoButton(
                semanticLabel: 'Save changes',
                onPressed: () => calls++,
                child: const Text('Save'),
              ),
              const NemoButton(onPressed: null, child: Text('Disabled')),
            ],
          ),
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Save changes')),
        matchesSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
          label: 'Save changes',
        ),
      );
      await tester.tap(find.text('Disabled'));
      expect(calls, 0);
    });

    testWidgets('uses caller text as its accessible name', (
      WidgetTester tester,
    ) async {
      const String label = 'Save changes';
      await tester.pumpWidget(
        _host(NemoButton(onPressed: () {}, child: const Text(label))),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel(label)),
        matchesSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
          label: label,
        ),
      );
    });

    testWidgets('uses localized system loading copy and blocks activation', (
      WidgetTester tester,
    ) async {
      var calls = 0;
      await tester.pumpWidget(
        _host(
          NemoButton(
            isLoading: true,
            onPressed: () => calls++,
            child: const Text('Submit'),
          ),
          locale: const Locale('es'),
        ),
      );

      expect(find.text('Cargando'), findsOneWidget);
      expect(find.text('Submit'), findsNothing);
      await tester.tap(find.text('Cargando'));
      expect(calls, 0);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Cargando')),
        matchesSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
          isLiveRegion: true,
          label: 'Cargando',
        ),
      );
    });

    testWidgets('has a tokenized hit target and accepts text scaling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          NemoButton(
            onPressed: () {},
            child: const Text('A deliberately long button label'),
          ),
          textScaler: TextScaler.linear(2),
        ),
      );

      expect(
        tester.getSize(find.byType(NemoButton)).height,
        greaterThanOrEqualTo(48),
      );
      expect(find.text('A deliberately long button label'), findsOneWidget);
    });

    testWidgets('preserves semantics, bounds, and keyboard activation in RTL', (
      WidgetTester tester,
    ) async {
      var calls = 0;
      final FocusNode focusNode = FocusNode();
      const String label = 'حفظ التغييرات';
      await tester.pumpWidget(
        _host(
          NemoButton(
            focusNode: focusNode,
            onPressed: () => calls++,
            child: const Text(label),
          ),
          textDirection: TextDirection.rtl,
        ),
      );

      final Rect buttonBounds = tester.getRect(find.byType(NemoButton));
      expect(buttonBounds.contains(tester.getCenter(find.text(label))), isTrue);
      expect(
        tester.getSemantics(find.bySemanticsLabel(label)),
        matchesSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
          label: label,
        ),
      );

      focusNode.requestFocus();
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.space);
      expect(calls, 1);
    });

    testWidgets('reduced motion settles press feedback immediately', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          NemoButton(onPressed: () {}, child: const Text('Save')),
          disableAnimations: true,
        ),
      );
      final Offset center = tester.getCenter(find.byType(NemoButton));
      final TestGesture gesture = await tester.startGesture(center);
      await tester.pump();
      expect(tester.binding.transientCallbackCount, 0);
      await gesture.up();
    });

    testWidgets('uses a static loading affordance with reduced motion', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const NemoButton(isLoading: true, child: Text('Submit')),
          disableAnimations: true,
        ),
      );

      expect(find.byIcon(Icons.hourglass_top), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets(
      'keeps bounds fixed while pressing and advertises mouse cursor',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _host(NemoButton(onPressed: () {}, child: const Text('Save'))),
        );
        final Finder button = find.byType(NemoButton);
        final Rect before = tester.getRect(button);
        final MouseRegion mouseRegion = tester.widget<MouseRegion>(
          find.descendant(of: button, matching: find.byType(MouseRegion)),
        );
        expect(mouseRegion.cursor, SystemMouseCursors.click);

        final TestGesture mouse = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await mouse.addPointer(location: tester.getCenter(button));
        await tester.pump();
        final TestGesture touch = await tester.startGesture(
          tester.getCenter(button),
        );
        await tester.pump();
        expect(tester.getRect(button), before);
        await touch.up();
        await mouse.removePointer();
      },
    );

    testWidgets(
      'shows focus state and ignores keyboard after becoming disabled',
      (WidgetTester tester) async {
        var calls = 0;
        final FocusNode focusNode = FocusNode();
        await tester.pumpWidget(
          _host(
            NemoButton(
              focusNode: focusNode,
              onPressed: () => calls++,
              child: const Text('Save'),
            ),
          ),
        );
        focusNode.requestFocus();
        await tester.pump();
        expect(focusNode.hasFocus, isTrue);

        await tester.pumpWidget(
          _host(
            NemoButton(
              focusNode: focusNode,
              onPressed: null,
              child: const Text('Save'),
            ),
          ),
        );
        await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
        expect(calls, 0);
      },
    );

    testWidgets('requires a Nemo theme extension', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: NemoButton(child: SizedBox())),
        ),
      );
      expect(tester.takeException(), isA<FlutterError>());
    });

    testWidgets('renders deterministically in light, dark, and high contrast', (
      WidgetTester tester,
    ) async {
      configureGoldenTest(tester, physicalSize: const Size(960, 640));
      final FocusNode focusNode = FocusNode();
      await tester.pumpWidget(
        goldenTestApp(
          disableAnimations: false,
          child: Column(
            children: <Widget>[
              _themedButton(NemoThemeData.light()),
              _themedButton(NemoThemeData.dark(), focusNode: focusNode),
              _themedButton(NemoThemeData.highContrast(), enabled: false),
            ],
          ),
        ),
      );
      focusNode.requestFocus();
      await tester.pump(const Duration(milliseconds: 200));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/nemo_button.png'),
      );
    });
  });
}

Widget _themedButton(
  NemoThemeData theme, {
  FocusNode? focusNode,
  bool enabled = true,
}) {
  final NemoButtonTokens buttonTokens = theme.components.button;
  final NemoThemeData goldenTheme = theme.copyWith(
    components: theme.components.copyWith(
      // Blurred mask filters are rasterized differently across Skia hosts.
      // The golden keeps the real theme colors, state tones, outlines, and
      // focus ring while functional tests cover the tokenized shadow states.
      button: buttonTokens.copyWith(
        resting: buttonTokens.resting.copyWith(shadowOpacity: 0),
        hovered: buttonTokens.hovered.copyWith(shadowOpacity: 0),
        focused: buttonTokens.focused.copyWith(shadowOpacity: 0),
        pressed: buttonTokens.pressed.copyWith(shadowOpacity: 0),
      ),
    ),
  );
  final Widget button = NemoButton(
    focusNode: focusNode,
    onPressed: enabled ? () {} : null,
    child: const SizedBox(width: 160, height: 16),
  );
  return Theme(
    data: goldenThemeData(goldenTheme),
    child: ColoredBox(
      color: goldenTheme.semantic.surface,
      child: Padding(padding: const EdgeInsets.all(8), child: button),
    ),
  );
}

Widget _host(
  Widget child, {
  Locale locale = const Locale('en'),
  bool disableAnimations = false,
  TextScaler textScaler = TextScaler.noScaling,
  TextDirection textDirection = TextDirection.ltr,
}) {
  final NemoThemeData theme = NemoThemeData.light();
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: locale,
    supportedLocales: NemoLocalizations.supportedLocales,
    localizationsDelegates: NemoLocalizations.localizationsDelegates,
    theme: ThemeData(
      platform: TargetPlatform.android,
      extensions: <ThemeExtension<dynamic>>[theme],
    ),
    home: MediaQuery(
      data: MediaQueryData(
        disableAnimations: disableAnimations,
        textScaler: textScaler,
      ),
      child: Directionality(
        textDirection: textDirection,
        child: Scaffold(backgroundColor: theme.semantic.surface, body: child),
      ),
    ),
  );
}
