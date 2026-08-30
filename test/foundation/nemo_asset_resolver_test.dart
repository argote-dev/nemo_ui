import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nemo_ui/nemo_ui.dart';

void main() {
  testWidgets('NemoAssetScope supplies a resolver only to its subtree', (
    WidgetTester tester,
  ) async {
    const _Resolver resolver = _Resolver();
    NemoAssetResolver? resolved;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: NemoAssetScope(
          resolver: resolver,
          child: Builder(
            builder: (BuildContext context) {
              resolved = NemoAssetScope.of(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(resolved, same(resolver));
  });

  testWidgets('NemoAssetScope has no implicit global fallback', (
    WidgetTester tester,
  ) async {
    NemoAssetResolver? resolved;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (BuildContext context) {
            resolved = NemoAssetScope.maybeOf(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(resolved, isNull);
  });
}

class _Resolver implements NemoAssetResolver {
  const _Resolver();

  @override
  ImageProvider<Object>? imageFor(NemoAsset asset, BuildContext context) =>
      null;

  @override
  Widget? widgetFor(NemoAsset asset, BuildContext context) => null;
}
