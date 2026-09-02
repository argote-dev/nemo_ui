import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nemo_ui/nemo_ui.dart';

import 'package:nemo_ui_example/main.dart';

void main() {
  testWidgets('landing uses Nemo controls instead of stock Material controls', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NemoFoundationCatalog());

    expect(find.text('Global configuration'), findsOneWidget);
    expect(find.text('Explore Nemo'), findsOneWidget);
    expect(find.text('Composed workspace'), findsOneWidget);
    expect(find.byType(NemoPage), findsOneWidget);
    expect(find.byType(NemoSection), findsNWidgets(2));
    expect(find.byType(NemoButton), findsWidgets);
    expect(find.byType(NemoSwitch), findsNWidgets(3));
    expect(find.byType(NemoField), findsNothing);
    expect(find.byType(SegmentedButton<Brightness>), findsNothing);
    expect(find.byType(SwitchListTile), findsNothing);
    expect(find.byType(Slider), findsNothing);
    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.byType(ListTile), findsNothing);
    expect(find.byType(Card), findsNothing);
  });

  testWidgets('landing navigates to all component and composed screens', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NemoFoundationCatalog());

    for (final (String title, Key screenKey) in <(String, Key)>[
      ('NemoSurface', const ValueKey<String>('NemoSurfaceScreen')),
      ('NemoButton', const ValueKey<String>('NemoButtonScreen')),
      ('NemoSwitch', const ValueKey<String>('NemoSwitchScreen')),
      ('NemoField', const ValueKey<String>('NemoFieldScreen')),
      ('Composed workspace', const ValueKey<String>('ComposedWorkspaceScreen')),
    ]) {
      await tester.tap(find.text(title).first);
      await tester.pumpAndSettle();
      expect(find.byKey(screenKey), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Global configuration'), findsOneWidget);
    }
  });

  testWidgets('settings remain operable and persist across routes', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const NemoFoundationCatalog());

    await tester.tap(find.text('Dark'));
    await tester.pump();
    await tester.tap(find.text('High contrast'));
    await tester.pump();
    await tester.tap(find.text('Español'));
    await tester.pump();
    await tester.tap(find.text('Reduced motion'));
    await tester.pump();
    await tester.drag(find.byType(ListView).first, const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2.0×'));
    await tester.pump();
    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Teal seed'));
    await tester.pump();
    await tester.pumpAndSettle();

    final BuildContext homeContext = tester.element(
      find.text('Global configuration'),
    );
    expect(Theme.of(homeContext).brightness, Brightness.dark);
    expect(MediaQuery.of(homeContext).disableAnimations, isTrue);
    expect(MediaQuery.textScalerOf(homeContext).scale(10), 20);
    expect(NemoTheme.of(homeContext).components.outlineWidth, 2);
    expect(find.bySemanticsLabel('Teal seed selected'), findsOneWidget);
    expect(find.byType(NemoSwitch), findsNWidgets(3));

    await tester.drag(find.byType(ListView).first, const Offset(0, 1000));
    await tester.pumpAndSettle();
    await tester.tap(find.text('NemoSurface').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Cargando'), findsOneWidget);
    expect(tester.takeException(), isNull);

    Navigator.of(
      tester.element(find.byKey(const ValueKey<String>('NemoSurfaceScreen'))),
    ).pop();
    await tester.pumpAndSettle();
    expect(find.text('Text scale: 2.0×'), findsOneWidget);
    expect(find.bySemanticsLabel('Teal seed selected'), findsOneWidget);

    await tester.ensureVisible(find.text('Composed workspace').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Composed workspace').first);
    await tester.pumpAndSettle();
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(NemoPage), findsOneWidget);
    expect(find.byType(NemoSection), findsOneWidget);
    for (final String key in <String>[
      'composed-workspace-canvas',
      'composed-material-recessed',
      'composed-material-raised',
    ]) {
      expect(find.byKey(ValueKey<String>(key)), findsOneWidget);
    }
    expect(
      find.byKey(const ValueKey<String>('composed-material-floating')),
      findsNothing,
    );
    await tester.tap(find.text('Save preferences'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('composed-material-floating')),
      findsOneWidget,
    );
    await tester.binding.setSurfaceSize(const Size(400, 800));
    await tester.pumpAndSettle();
    final BuildContext composedContext = tester.element(
      find.byKey(const ValueKey<String>('ComposedWorkspaceScreen')),
    );
    expect(MediaQuery.textScalerOf(composedContext).scale(10), 20);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'composed workspace adapts on mobile and wide layouts without overflow',
    (WidgetTester tester) async {
      await tester.pumpWidget(const NemoFoundationCatalog());
      await tester.tap(find.text('Composed workspace').first);
      await tester.pumpAndSettle();
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpAndSettle();

      final Finder summary = find.text('Today’s workspace');
      final Finder preferences = find.text('Delivery preference');
      expect(
        tester.getTopLeft(preferences).dy,
        greaterThan(tester.getTopLeft(summary).dy),
      );
      expect(tester.takeException(), isNull);

      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(preferences).dx,
        greaterThan(tester.getTopLeft(summary).dx),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Nemo keyboard traversal activates composed preferences', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NemoFoundationCatalog());
    await tester.tap(find.text('Composed workspace').first);
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(Focus.of(tester.element(find.text('Daily brief'))).hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(
      Focus.of(tester.element(find.text('Save preferences'))).hasFocus,
      isTrue,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Preferences saved'), findsOneWidget);
  });

  testWidgets('surface screen keeps responsive component cards', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const NemoFoundationCatalog());
    await tester.tap(find.text('NemoSurface').first);
    await tester.pumpAndSettle();

    final Finder raisedCard = find.byKey(
      const ValueKey<String>('surface-card-raised-surface-panel'),
    );
    final Finder adjacentCard = find.byKey(
      const ValueKey<String>('surface-card-recessed-surface-panel'),
    );
    final Finder firstCard = find.byKey(
      const ValueKey<String>('surface-card-recessed-surface-control'),
    );
    expect(tester.getSize(raisedCard).width, greaterThanOrEqualTo(220));
    expect(tester.getTopLeft(firstCard).dy, tester.getTopLeft(adjacentCard).dy);

    await tester.binding.setSurfaceSize(const Size(400, 800));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(firstCard).dx, tester.getTopLeft(adjacentCard).dx);
    expect(
      tester.getTopLeft(adjacentCard).dy,
      greaterThan(tester.getTopLeft(firstCard).dy),
    );
  });
}
