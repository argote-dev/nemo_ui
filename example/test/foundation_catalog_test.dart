import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nemo_ui/nemo_ui.dart';

import 'package:nemo_ui_example/main.dart';

void main() {
  testWidgets('home exposes global configuration and component menu only', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NemoFoundationCatalog());

    expect(find.text('Global configuration'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('High contrast'), findsOneWidget);
    expect(find.text('Español'), findsOneWidget);
    expect(find.text('Reduced motion'), findsOneWidget);
    expect(find.text('Text scale: 1.0×'), findsOneWidget);
    expect(find.text('NemoSurface'), findsOneWidget);
    expect(find.text('NemoButton'), findsOneWidget);
    expect(find.text('NemoSwitch'), findsOneWidget);
    expect(find.text('Raised by default'), findsNothing);
    expect(find.text('Submit'), findsNothing);
    expect(find.text('Notifications'), findsNothing);
  });

  testWidgets('menu navigates to every component screen and back', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NemoFoundationCatalog());

    for (final String component in <String>[
      'NemoSurface',
      'NemoButton',
      'NemoSwitch',
    ]) {
      await tester.tap(find.text(component));
      await tester.pumpAndSettle();

      expect(
        find.byKey(ValueKey<String>('${component}Screen')),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Global configuration'), findsOneWidget);
    }
  });

  testWidgets('global configuration persists across component routes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NemoFoundationCatalog());

    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('NemoSurface'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Cargando'), findsOneWidget);

    await tester.tap(find.byTooltip('Atrás'));
    await tester.pumpAndSettle();

    final SwitchListTile languageControl = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'Español'),
    );
    expect(languageControl.value, isTrue);
  });

  testWidgets('surface screen uses large responsive cards', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const NemoFoundationCatalog());

    await tester.tap(find.text('NemoSurface'));
    await tester.pumpAndSettle();

    final Finder raisedCard = find.byKey(
      const ValueKey<String>('surface-card-raised-surface-roundedMedium'),
    );
    final Finder adjacentCard = find.byKey(
      const ValueKey<String>('surface-card-deeplySunken-surface-roundedMedium'),
    );
    expect(raisedCard, findsOneWidget);
    expect(find.byType(NemoSurface), findsNWidgets(30));
    expect(tester.getSize(raisedCard).width, greaterThanOrEqualTo(220));
    expect(tester.getSize(raisedCard).height, greaterThanOrEqualTo(160));

    final Finder firstCard = find.byKey(
      const ValueKey<String>('surface-card-deeplySunken-surface-roundedSmall'),
    );
    expect(tester.getTopLeft(firstCard).dy, tester.getTopLeft(adjacentCard).dy);
    expect(
      tester.getTopLeft(adjacentCard).dx,
      greaterThan(tester.getTopLeft(firstCard).dx),
    );

    await tester.binding.setSurfaceSize(const Size(400, 800));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(firstCard).dx, tester.getTopLeft(adjacentCard).dx);
    expect(
      tester.getTopLeft(adjacentCard).dy,
      greaterThan(tester.getTopLeft(firstCard).dy),
    );
  });

  testWidgets('narrow component screens support the maximum text scale', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const NemoFoundationCatalog());

    final Slider textScaleControl = tester.widget<Slider>(find.byType(Slider));
    textScaleControl.onChanged!(2);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('NemoSurface'), 300);
    await tester.ensureVisible(find.text('NemoSurface'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('NemoSurface'));
    await tester.pumpAndSettle();

    final BuildContext screenContext = tester.element(
      find.byKey(const ValueKey<String>('NemoSurfaceScreen')),
    );
    expect(MediaQuery.textScalerOf(screenContext).scale(10), 20);
    expect(tester.takeException(), isNull);
  });
}
