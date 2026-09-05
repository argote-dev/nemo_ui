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
    expect(find.text('Canonical scenes'), findsOneWidget);
    expect(find.text('Work dashboard'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Catalog inspector'), findsOneWidget);
    expect(find.text('Composed workspace'), findsNothing);
    expect(find.byType(NemoPage), findsOneWidget);
    expect(find.byType(NemoSection), findsNWidgets(3));
    expect(find.byType(NemoButton), findsWidgets);
    expect(find.byType(NemoSwitch), findsNWidgets(4));
    expect(find.byType(NemoField), findsNothing);
    expect(find.byType(SegmentedButton<Brightness>), findsNothing);
    expect(find.byType(SwitchListTile), findsNothing);
    expect(find.byType(Slider), findsNothing);
    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.byType(ListTile), findsNothing);
    expect(find.byType(Card), findsNothing);
  });

  testWidgets('landing navigates to all component and canonical screens', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NemoFoundationCatalog());

    for (final (String title, Key screenKey) in <(String, Key)>[
      ('NemoSurface', const ValueKey<String>('NemoSurfaceScreen')),
      ('NemoButton', const ValueKey<String>('NemoButtonScreen')),
      ('NemoSwitch', const ValueKey<String>('NemoSwitchScreen')),
      ('NemoField', const ValueKey<String>('NemoFieldScreen')),
      ('Work dashboard', const ValueKey<String>('WorkDashboardScreen')),
      ('Settings', const ValueKey<String>('SettingsFlowScreen')),
      ('Catalog inspector', const ValueKey<String>('CatalogInspectorScreen')),
    ]) {
      await tester.ensureVisible(find.text(title).first);
      await tester.pumpAndSettle();
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
    expect(find.byType(NemoSwitch), findsNWidgets(4));

    await tester.drag(find.byType(ListView).first, const Offset(0, 1000));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('NemoSurface').first);
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

    await tester.ensureVisible(find.text('Work dashboard').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Work dashboard').first);
    await tester.pumpAndSettle();
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(NemoPage), findsOneWidget);
    expect(find.byType(NemoSection), findsOneWidget);
    for (final String key in <String>[
      'dashboard-base-canvas',
      'dashboard-receiving-area',
      'dashboard-action-island',
    ]) {
      expect(find.byKey(ValueKey<String>(key)), findsOneWidget);
    }
    expect(
      find.byKey(const ValueKey<String>('dashboard-floating-plane')),
      findsNothing,
    );
    await tester.tap(find.text('Capture task'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('dashboard-floating-plane')),
      findsOneWidget,
    );
    await tester.binding.setSurfaceSize(const Size(400, 800));
    await tester.pumpAndSettle();
    final BuildContext dashboardContext = tester.element(
      find.byKey(const ValueKey<String>('WorkDashboardScreen')),
    );
    expect(MediaQuery.textScalerOf(dashboardContext).scale(10), 20);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'work dashboard adapts on mobile and wide layouts without overflow',
    (WidgetTester tester) async {
      await tester.pumpWidget(const NemoFoundationCatalog());
      await tester.tap(find.text('Work dashboard').first);
      await tester.pumpAndSettle();
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpAndSettle();

      final Finder inbox = find.text('Incoming queue');
      final Finder actions = find.text('Actions');
      expect(
        tester.getTopLeft(actions).dy,
        greaterThan(tester.getTopLeft(inbox).dy),
      );
      expect(tester.takeException(), isNull);

      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(actions).dx,
        greaterThan(tester.getTopLeft(inbox).dx),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('dashboard keyboard captures a task and shows a floating plane', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NemoFoundationCatalog());
    await tester.tap(find.text('Work dashboard').first);
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(
      Focus.of(tester.element(find.text('Capture task'))).hasFocus,
      isTrue,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('dashboard-floating-plane')),
      findsOneWidget,
    );
  });

  testWidgets('settings keyboard traversal saves and reports explicit status', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NemoFoundationCatalog());
    await tester.tap(find.text('Settings').first);
    await tester.pumpAndSettle();

    expect(find.text('Unsaved changes'), findsOneWidget);
    expect(find.byType(NemoField), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('settings-action-island')),
      findsOneWidget,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
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

  testWidgets(
    'catalog inspector overlay is modal, traversable, dismissible, and restores focus',
    (WidgetTester tester) async {
      await tester.pumpWidget(const NemoFoundationCatalog());
      await tester.ensureVisible(find.text('Catalog inspector').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Catalog inspector').first);
      await tester.pumpAndSettle();

      final Finder trigger = find.text('Inspect specimen');
      await tester.tap(trigger);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey<String>('catalog-inspector-overlay')),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Specimen inspector'), findsWidgets);
      expect(find.text('Mark as default candidate'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        Focus.of(tester.element(find.text('Mark as default candidate')))
            .hasFocus,
        isTrue,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(Focus.of(tester.element(find.text('Dismiss'))).hasFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        Focus.of(tester.element(find.text('Mark as default candidate')))
            .hasFocus,
        isTrue,
      );
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(Focus.of(tester.element(find.text('Dismiss'))).hasFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey<String>('catalog-inspector-overlay')),
        findsNothing,
      );
      expect(Focus.of(tester.element(trigger)).hasFocus, isTrue);

      await tester.tap(trigger);
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey<String>('catalog-inspector-overlay')),
        findsNothing,
      );
      expect(Focus.of(tester.element(trigger)).hasFocus, isTrue);
    },
  );

  testWidgets('canonical scenes reflow in RTL without mirroring light', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const NemoFoundationCatalog());
    await tester.tap(find.text('Right to left'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Work dashboard').first);
    await tester.pumpAndSettle();
    expect(
      Directionality.of(tester.element(find.text('Incoming queue'))),
      TextDirection.rtl,
    );
    expect(
      tester.getTopLeft(find.text('Actions')).dx,
      lessThan(tester.getTopLeft(find.text('Incoming queue')).dx),
    );
    expect(tester.takeException(), isNull);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings').first);
    await tester.pumpAndSettle();
    expect(find.byType(NemoField), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('Daily brief'))),
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Catalog inspector').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Catalog inspector').first);
    await tester.pumpAndSettle();
    expect(
      Directionality.of(tester.element(find.text('Inspect specimen'))),
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('canonical scenes keep hierarchy under reduced motion', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NemoFoundationCatalog());
    await tester.tap(find.text('Reduced motion'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Work dashboard').first);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('dashboard-base-canvas')),
      findsOneWidget,
    );
    await tester.tap(find.text('Capture task'));
    await tester.pump();
    expect(
      find.byKey(const ValueKey<String>('dashboard-floating-plane')),
      findsOneWidget,
    );
    expect(find.text('Task captured'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save preferences'));
    await tester.pump();
    expect(find.text('Preferences saved'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('canonical scenes reflow at enlarged text without clipping', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const NemoFoundationCatalog());
    await tester.ensureVisible(find.text('2.0×'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2.0×'));
    await tester.pumpAndSettle();

    for (final String title in <String>[
      'Work dashboard',
      'Settings',
      'Catalog inspector',
    ]) {
      await tester.ensureVisible(find.text(title).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(title).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('canonical scenes expose landmarks and headings', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(const NemoFoundationCatalog());

    await tester.tap(find.text('Work dashboard').first);
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.text('Today’s work')),
      matchesSemantics(isHeader: true, label: 'Today’s work'),
    );
    expect(
      tester.getSemantics(find.text('Incoming queue')),
      matchesSemantics(isHeader: true, label: 'Incoming queue'),
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings').first);
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.text('Workspace identity')),
      matchesSemantics(isHeader: true, label: 'Workspace identity'),
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Catalog inspector').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Catalog inspector').first);
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.text('Component states')),
      matchesSemantics(isHeader: true, label: 'Component states'),
    );
    handle.dispose();
  });

  testWidgets('canonical scenes meet supported accessibility guidelines', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.binding.setSurfaceSize(const Size(1200, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const NemoFoundationCatalog());

    for (final String title in <String>[
      'Work dashboard',
      'Settings',
      'Catalog inspector',
    ]) {
      await tester.ensureVisible(find.text(title).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(title).first);
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
    handle.dispose();
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
