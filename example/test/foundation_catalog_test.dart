import 'package:flutter_test/flutter_test.dart';

import 'package:nemo_ui_example/main.dart';

void main() {
  testWidgets('catalog exposes foundation configuration controls', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NemoFoundationCatalog());

    expect(find.text('Nemo foundation catalog'), findsWidgets);
    expect(find.text('High contrast'), findsOneWidget);
    expect(find.text('Reduced motion'), findsOneWidget);
    expect(find.text('Raised by default'), findsOneWidget);
    expect(find.text('elevated'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('NemoSwitch'), 300);
    expect(find.text('NemoSwitch'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Español'), -300);
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Raised by default'), -300);
    expect(find.textContaining('Cargando'), findsOneWidget);
  });
}
