import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nemo_ui/nemo_ui.dart';

void main() {
  test('reduced motion preserves final state without durations', () {
    final NemoMotionTokens resolved = NemoMotionTokens.standardTokens.resolve(
      disableAnimations: true,
    );

    expect(resolved.instant, Duration.zero);
    expect(resolved.quick, Duration.zero);
    expect(resolved.standard, Duration.zero);
    expect(resolved.emphasized, Duration.zero);
  });

  testWidgets('motion adapts to MediaQuery.disableAnimations', (
    WidgetTester tester,
  ) async {
    NemoMotionTokens? resolved;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Builder(
          builder: (BuildContext context) {
            resolved = NemoMotionTokens.standardTokens.resolveFor(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(resolved!.standard, Duration.zero);
  });
}
