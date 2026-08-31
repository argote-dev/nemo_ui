import 'dart:ui' show PointerDeviceKind, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nemo_ui/nemo_ui.dart';

import '../support/golden_test_harness.dart';

void main() {
  group('NemoSwitch', () {
    testWidgets(
      'exposes controlled switch semantics and toggles through touch, Enter, and Space',
      (tester) async {
        final calls = <bool>[];
        final FocusNode focusNode = FocusNode();
        await tester.pumpWidget(
          _host(
            NemoSwitch(
              value: false,
              focusNode: focusNode,
              onChanged: calls.add,
              child: const Text('Notifications'),
            ),
          ),
        );

        expect(
          tester.getSemantics(find.byType(NemoSwitch)),
          matchesSemantics(
            hasToggledState: true,
            isToggled: false,
            hasEnabledState: true,
            isEnabled: true,
            hasTapAction: true,
            hasFocusAction: true,
            isFocusable: true,
            label: 'Notifications',
            value: 'Off',
          ),
        );
        expect(
          tester.getSemantics(find.text('Notifications')).label,
          'Notifications',
        );
        await tester.tap(find.byType(NemoSwitch));
        focusNode.requestFocus();
        await tester.pump();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.space);
        expect(calls, <bool>[true, true, true]);
      },
    );

    testWidgets('localizes system-owned state and blocks disabled activation', (
      tester,
    ) async {
      var calls = 0;
      await tester.pumpWidget(
        _host(
          Column(
            children: <Widget>[
              const NemoSwitch(
                value: true,
                semanticLabel: 'Network availability',
                child: Text('Enabled'),
              ),
              NemoSwitch(
                value: false,
                onChanged: (_) => calls++,
                child: const Text('Editable'),
              ),
            ],
          ),
          locale: const Locale('es'),
        ),
      );

      final semantics = tester.getSemantics(find.byType(NemoSwitch).first);
      expect(semantics.label, 'Network availability');
      expect(semantics.value, 'Activado');
      expect(semantics.flagsCollection.isToggled != Tristate.none, isTrue);
      expect(semantics.flagsCollection.isToggled == Tristate.isTrue, isTrue);
      expect(semantics.flagsCollection.isEnabled == Tristate.isTrue, isFalse);
      await tester.tap(find.text('Enabled'));
      expect(calls, 0);
    });

    testWidgets('builds in light, dark, and high-contrast themes', (
      tester,
    ) async {
      for (final theme in <NemoThemeData>[
        NemoThemeData.light(),
        NemoThemeData.dark(),
        NemoThemeData.highContrast(),
      ]) {
        await tester.pumpWidget(
          _host(
            NemoSwitch(
              value: true,
              onChanged: (_) {},
              child: const Text('Theme'),
            ),
            theme: theme,
          ),
        );
        expect(
          find.byKey(const ValueKey<String>('nemo-switch-indicator-on')),
          findsOneWidget,
        );
      }
    });

    testWidgets(
      'preserves a 48px touch target, text scaling, reduced motion, and mouse cursor',
      (tester) async {
        await tester.pumpWidget(
          _host(
            NemoSwitch(
              value: true,
              onChanged: (_) {},
              child: const Text('A deliberately long switch label'),
            ),
            textScaler: TextScaler.linear(2),
            disableAnimations: true,
          ),
        );
        final Finder control = find.byType(NemoSwitch);
        expect(tester.getSize(control).height, greaterThanOrEqualTo(48));
        expect(find.text('A deliberately long switch label'), findsOneWidget);
        final MouseRegion mouse = tester.widget<MouseRegion>(
          find.descendant(of: control, matching: find.byType(MouseRegion)),
        );
        expect(mouse.cursor, SystemMouseCursors.click);
        final TestGesture pointer = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        final AnimatedContainer before = tester.widget<AnimatedContainer>(
          find.byKey(const ValueKey<String>('nemo-switch-track')),
        );
        final Color resting = (before.decoration! as BoxDecoration).color!;
        await pointer.addPointer(location: tester.getCenter(control));
        await tester.pump();
        final AnimatedContainer hovered = tester.widget<AnimatedContainer>(
          find.byKey(const ValueKey<String>('nemo-switch-track')),
        );
        expect((hovered.decoration! as BoxDecoration).color, isNot(resting));
        expect(tester.binding.transientCallbackCount, 0);
        await pointer.removePointer();
        await tester.pumpWidget(
          _host(
            NemoSwitch(
              value: false,
              onChanged: (_) {},
              child: const Text('Transition'),
            ),
            disableAnimations: true,
          ),
        );
        await tester.pumpWidget(
          _host(
            NemoSwitch(
              value: true,
              onChanged: (_) {},
              child: const Text('Transition'),
            ),
            disableAnimations: true,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.binding.transientCallbackCount, 0);
      },
    );
    testWidgets('renders focus, pressed, and disabled visual states', (
      tester,
    ) async {
      final focusNode = FocusNode();
      final theme = NemoThemeData.light();
      await tester.pumpWidget(
        _host(
          NemoSwitch(
            value: false,
            focusNode: focusNode,
            onChanged: (_) {},
            child: const Text('State'),
          ),
          theme: theme,
        ),
      );
      final restingDecoration =
          tester
                  .widget<AnimatedContainer>(
                    find.byKey(const ValueKey<String>('nemo-switch-track')),
                  )
                  .decoration!
              as BoxDecoration;
      final restingBorder = restingDecoration.border! as Border;
      focusNode.requestFocus();
      await tester.pumpAndSettle();
      BoxDecoration decoration =
          tester
                  .widget<AnimatedContainer>(
                    find.byKey(const ValueKey<String>('nemo-switch-track')),
                  )
                  .decoration!
              as BoxDecoration;
      final focusedBorder = decoration.border! as Border;
      expect(focusedBorder.top.color, theme.semantic.focusRing);
      expect(focusedBorder.top.width, theme.components.focusRingWidth);
      expect(focusedBorder.top, isNot(restingBorder.top));
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byType(NemoSwitch)),
      );
      await tester.pump();
      decoration =
          tester
                  .widget<AnimatedContainer>(
                    find.byKey(const ValueKey<String>('nemo-switch-track')),
                  )
                  .decoration!
              as BoxDecoration;
      expect(decoration.boxShadow, isNull);
      await gesture.up();
      await tester.pumpWidget(
        _host(const NemoSwitch(value: false, child: Text('Disabled'))),
      );
      decoration =
          tester
                  .widget<AnimatedContainer>(
                    find.byKey(const ValueKey<String>('nemo-switch-track')),
                  )
                  .decoration!
              as BoxDecoration;
      expect(decoration.boxShadow, isNull);
    });

    testWidgets('renders deterministic representative states', (tester) async {
      configureGoldenTest(tester, physicalSize: const Size(400, 256));
      final focusNode = FocusNode();
      await tester.pumpWidget(
        goldenTestApp(
          scaffold: false,
          disableAnimations: false,
          child: ColoredBox(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                _goldenSwitch(
                  NemoThemeData.light(),
                  value: false,
                  label: 'Light',
                ),
                _goldenSwitch(NemoThemeData.dark(), value: true, label: 'Dark'),
                _goldenSwitch(
                  NemoThemeData.highContrast(),
                  value: true,
                  label: 'High contrast',
                  focusNode: focusNode,
                ),
                _goldenSwitch(
                  NemoThemeData.light(),
                  value: false,
                  label: 'Disabled',
                  enabled: false,
                ),
              ],
            ),
          ),
        ),
      );
      focusNode.requestFocus();
      await tester.pump(const Duration(milliseconds: 200));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/nemo_switch.png'),
      );
    });
  });
}

Widget _goldenSwitch(
  NemoThemeData theme, {
  required bool value,
  required String label,
  FocusNode? focusNode,
  bool enabled = true,
}) {
  final tokens = theme.components.switchControl;
  final stableTheme = theme.copyWith(
    // Blurred shadows rasterize differently across Skia hosts. Keep the real
    // state colors, outlines, focus ring, position, and icon in the baseline.
    semantic: theme.semantic.copyWith(lowlightShadow: Colors.transparent),
    components: theme.components.copyWith(switchControl: tokens.copyWith()),
  );
  return Theme(
    data: goldenThemeData(stableTheme),
    child: ColoredBox(
      color: stableTheme.semantic.surface,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: NemoSwitch(
          value: value,
          onChanged: enabled ? (_) {} : null,
          focusNode: focusNode,
          semanticLabel: label,
          child: const SizedBox(width: 160, height: 16),
        ),
      ),
    ),
  );
}

Widget _host(
  Widget child, {
  Locale locale = const Locale('en'),
  TextScaler textScaler = TextScaler.noScaling,
  bool disableAnimations = false,
  NemoThemeData? theme,
}) => MaterialApp(
  theme: ThemeData(
    extensions: <ThemeExtension<dynamic>>[theme ?? NemoThemeData.light()],
  ),
  locale: locale,
  supportedLocales: NemoLocalizations.supportedLocales,
  localizationsDelegates: NemoLocalizations.localizationsDelegates,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: textScaler, disableAnimations: disableAnimations),
    child: child!,
  ),
  home: Scaffold(body: Center(child: child)),
);
