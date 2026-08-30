import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nemo_ui/nemo_ui.dart';

void main() {
  test('NemoLocales falls back to English for an unsupported locale', () {
    expect(
      NemoLocales.resolve(
        const Locale('ar'),
        NemoLocalizations.supportedLocales,
      ),
      const Locale('en'),
    );
  });

  testWidgets('NemoLocalizations loads Spanish system copy', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      WidgetsApp(
        color: const Color(0xFF000000),
        locale: const Locale('es'),
        localizationsDelegates: NemoLocalizations.localizationsDelegates,
        supportedLocales: NemoLocalizations.supportedLocales,
        builder: (BuildContext context, Widget? child) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Text(NemoLocalizations.of(context).loading),
          );
        },
      ),
    );

    expect(find.text('Cargando'), findsOneWidget);
  });
}
