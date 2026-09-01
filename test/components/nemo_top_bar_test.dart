import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nemo_ui/nemo_ui.dart';

void main() {
  test('has a stable preferred size excluding system insets', () {
    const NemoTopBar topBar = NemoTopBar(title: Text('Title'));
    expect(
      topBar.preferredSize,
      const Size.fromHeight(NemoTopBar.toolbarHeight),
    );
  });

  testWidgets('is publicly usable and reports a missing Nemo theme', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(appBar: NemoTopBar(title: Text('Title'))),
      ),
    );
    expect(tester.takeException(), isA<FlutterError>());
  });

  testWidgets('paints behind the top inset while the toolbar avoids it', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const NemoTopBar(title: Text('Title'))));
    final RenderBox background = tester.renderObject(find.byType(DecoratedBox));
    final RenderBox toolbar = tester.renderObject(
      find.byType(NavigationToolbar),
    );
    expect(background.localToGlobal(Offset.zero).dy, 0);
    expect(toolbar.localToGlobal(Offset.zero).dy, 24);
    expect(toolbar.size.height, NemoTopBar.toolbarHeight);
  });

  testWidgets('protects lateral safe insets in normal flow', (tester) async {
    await tester.pumpWidget(
      _host(
        const NemoTopBar(title: Text('Title')),
        padding: const EdgeInsets.only(left: 20, right: 30, top: 24),
      ),
    );
    final RenderBox toolbar = tester.renderObject(
      find.byType(NavigationToolbar),
    );
    expect(toolbar.localToGlobal(Offset.zero).dx, 36);
    expect(
      toolbar.size.width,
      lessThan(tester.getSize(find.byType(Scaffold)).width),
    );
  });

  testWidgets('consumes the scaffold top inset exactly once', (tester) async {
    await tester.pumpWidget(
      _host(
        const Scaffold(appBar: NemoTopBar(title: Text('Title'))),
        scaffold: false,
      ),
    );
    final RenderBox toolbar = tester.renderObject(
      find.byType(NavigationToolbar),
    );
    expect(toolbar.localToGlobal(Offset.zero).dy, 24);
    expect(toolbar.size.height, NemoTopBar.toolbarHeight);
  });

  testWidgets('derives and accepts a local system overlay style', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const NemoTopBar(title: Text('Title'))));
    final Finder overlayRegion = find.descendant(
      of: find.byType(NemoTopBar),
      matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
    );
    AnnotatedRegion<SystemUiOverlayStyle> region = tester.widget(overlayRegion);
    expect(region.value.statusBarColor, Colors.transparent);
    expect(region.value.statusBarIconBrightness, Brightness.dark);
    expect(region.value.statusBarBrightness, Brightness.light);

    await tester.pumpWidget(
      _host(
        const NemoTopBar(title: Text('Title')),
        theme: NemoThemeData.dark(),
      ),
    );
    region = tester.widget(overlayRegion);
    expect(region.value.statusBarColor, Colors.transparent);
    expect(region.value.statusBarIconBrightness, Brightness.light);
    expect(region.value.statusBarBrightness, Brightness.dark);

    final NemoThemeData mediumSurfaceTheme = NemoThemeData.light().copyWith(
      semantic: NemoThemeData.light().semantic.copyWith(
        surface: const Color(0xFFB0B0B0),
      ),
    );
    await tester.pumpWidget(
      _host(const NemoTopBar(title: Text('Title')), theme: mediumSurfaceTheme),
    );
    region = tester.widget(overlayRegion);
    expect(region.value.statusBarIconBrightness, Brightness.dark);
    expect(region.value.statusBarBrightness, Brightness.light);

    const SystemUiOverlayStyle override = SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
    );
    await tester.pumpWidget(
      _host(
        const NemoTopBar(title: Text('Title'), systemOverlayStyle: override),
      ),
    );
    region = tester.widget(overlayRegion);
    expect(region.value, override);
  });

  testWidgets('preserves title heading semantics and 48px slot targets', (
    tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        NemoTopBar(
          title: const Text('Page title'),
          leading: const SizedBox(key: ValueKey<String>('leading'), width: 12),
          actions: const <Widget>[
            SizedBox(key: ValueKey<String>('action'), width: 12),
          ],
        ),
      ),
    );
    expect(
      tester.getSemantics(find.text('Page title')),
      matchesSemantics(isHeader: true, label: 'Page title'),
    );
    final Finder leadingTarget = find
        .ancestor(
          of: find.byKey(const ValueKey<String>('leading')),
          matching: find.byType(ConstrainedBox),
        )
        .last;
    final Finder actionTarget = find
        .ancestor(
          of: find.byKey(const ValueKey<String>('action')),
          matching: find.byType(ConstrainedBox),
        )
        .last;
    expect(tester.getSize(leadingTarget).width, greaterThanOrEqualTo(48));
    expect(tester.getSize(leadingTarget).height, greaterThanOrEqualTo(48));
    expect(tester.getSize(actionTarget).width, greaterThanOrEqualTo(48));
    expect(tester.getSize(actionTarget).height, greaterThanOrEqualTo(48));
    handle.dispose();
  });

  testWidgets('keeps wider leading and action slots at their natural width', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        NemoTopBar(
          title: const Text('Page title'),
          leading: const SizedBox(
            key: ValueKey<String>('wide-leading'),
            width: 72,
          ),
          actions: const <Widget>[
            SizedBox(key: ValueKey<String>('wide-action'), width: 72),
          ],
        ),
      ),
    );
    final Finder leadingTarget = find
        .ancestor(
          of: find.byKey(const ValueKey<String>('wide-leading')),
          matching: find.byType(ConstrainedBox),
        )
        .last;
    final Finder actionTarget = find
        .ancestor(
          of: find.byKey(const ValueKey<String>('wide-action')),
          matching: find.byType(ConstrainedBox),
        )
        .last;
    expect(tester.getSize(leadingTarget).width, greaterThanOrEqualTo(72));
    expect(tester.getSize(actionTarget).width, greaterThanOrEqualTo(72));
    expect(tester.getSize(leadingTarget).height, greaterThanOrEqualTo(48));
    expect(tester.getSize(actionTarget).height, greaterThanOrEqualTo(48));
  });

  testWidgets('keeps directional layout and long titles within bounds', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const NemoTopBar(
          leading: SizedBox(width: 12),
          title: Text('A very long title that must not overflow the top bar'),
          actions: <Widget>[SizedBox(width: 12)],
        ),
        direction: TextDirection.rtl,
        textScaler: const TextScaler.linear(2),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not imply a back control on a root route', (tester) async {
    await tester.pumpWidget(_navigationHost());
    expect(find.byType(BackButton), findsNothing);
  });

  testWidgets('implies a back control on a secondary route and maybe-pops it', (
    tester,
  ) async {
    await tester.pumpWidget(_navigationHost());
    await tester.tap(find.text('Open secondary'));
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Root'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
  });

  testWidgets('places implied leading at directional start', (tester) async {
    for (final TextDirection direction in TextDirection.values) {
      await tester.pumpWidget(_navigationHost(direction: direction));
      await tester.tap(find.text('Open secondary'));
      await tester.pumpAndSettle();

      final RenderBox toolbar = tester.renderObject(
        find.ancestor(
          of: find.byType(BackButton),
          matching: find.byType(NavigationToolbar),
        ),
      );
      final RenderBox back = tester.renderObject(find.byType(BackButton));
      final double backCenter = back
          .localToGlobal(back.size.center(Offset.zero))
          .dx;
      final double toolbarCenter = toolbar
          .localToGlobal(toolbar.size.center(Offset.zero))
          .dx;
      expect(
        backCenter < toolbarCenter,
        direction == TextDirection.ltr,
        reason: 'The implied leading slot must stay at directional start.',
      );
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('gives an explicit leading slot precedence over implication', (
    tester,
  ) async {
    await tester.pumpWidget(
      _navigationHost(
        leading: const SizedBox(key: ValueKey<String>('explicit-leading')),
      ),
    );
    await tester.tap(find.text('Open secondary'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('explicit-leading')),
      findsOneWidget,
    );
    expect(find.byType(BackButton), findsNothing);
  });

  testWidgets('can disable implied leading', (tester) async {
    await tester.pumpWidget(_navigationHost(automaticallyImplyLeading: false));
    await tester.tap(find.text('Open secondary'));
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsNothing);
  });

  test('high-contrast tokens provide a fully opaque boundary', () {
    final NemoThemeData theme = NemoThemeData.highContrast();
    expect(theme.components.topBar.boundaryOpacity, 1);
    expect(theme.components.outlineWidth, 2);
  });

  test('top-bar tokens support copy, equality, and interpolation', () {
    const NemoTopBarTokens tokens = NemoTopBarTokens.standard;
    final NemoTopBarTokens updated = tokens.copyWith(boundaryOpacity: .75);
    expect(updated, isNot(tokens));
    expect(updated.boundaryOpacity, .75);
    expect(updated.copyWith(), updated);

    final NemoTopBarTokens midpoint = NemoTopBarTokens.lerp(
      NemoTopBarTokens.standard,
      NemoTopBarTokens.highContrast,
      .5,
    );
    expect(midpoint.horizontalPadding, 16);
    expect(midpoint.titleSpacing, 12);
    expect(midpoint.boundaryOpacity, .75);
  });
}

Widget _navigationHost({
  TextDirection direction = TextDirection.ltr,
  bool automaticallyImplyLeading = true,
  Widget? leading,
}) => MaterialApp(
  theme: ThemeData(
    extensions: <ThemeExtension<dynamic>>[NemoThemeData.light()],
  ),
  home: Directionality(
    textDirection: direction,
    child: Scaffold(
      appBar: const NemoTopBar(title: Text('Root')),
      body: Builder(
        builder: (BuildContext context) => Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => Directionality(
                  textDirection: direction,
                  child: Scaffold(
                    appBar: NemoTopBar(
                      title: const Text('Secondary'),
                      leading: leading,
                      automaticallyImplyLeading: automaticallyImplyLeading,
                    ),
                    body: const SizedBox(),
                  ),
                ),
              ),
            ),
            child: const Text('Open secondary'),
          ),
        ),
      ),
    ),
  ),
);

Widget _host(
  Widget child, {
  EdgeInsets padding = const EdgeInsets.only(top: 24),
  bool scaffold = true,
  TextDirection direction = TextDirection.ltr,
  TextScaler textScaler = TextScaler.noScaling,
  NemoThemeData? theme,
}) {
  final MediaQueryData mediaQuery = MediaQueryData(
    size: const Size(320, 640),
    padding: padding,
    viewPadding: padding,
    textScaler: textScaler,
  );
  final NemoThemeData resolvedTheme = theme ?? NemoThemeData.light();
  return MaterialApp(
    key: ValueKey<int>(resolvedTheme.semantic.surface.toARGB32()),
    theme: ThemeData(extensions: <ThemeExtension<dynamic>>[resolvedTheme]),
    home: MediaQuery(
      data: mediaQuery,
      child: Directionality(
        textDirection: direction,
        child: scaffold ? Scaffold(body: child) : child,
      ),
    ),
  );
}
