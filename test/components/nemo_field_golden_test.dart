import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nemo_ui/nemo_ui.dart';

import '../support/golden_test_harness.dart';

void main() {
  const String invisibleText = '\u200B';
  for (final ({String name, NemoThemeData theme}) scene
      in <({String name, NemoThemeData theme})>[
        (name: 'light', theme: NemoThemeData.light()),
        (name: 'dark', theme: NemoThemeData.dark()),
        (name: 'high_contrast', theme: NemoThemeData.highContrast()),
      ]) {
    testWidgets('${scene.name} editing states', (WidgetTester tester) async {
      configureGoldenTest(tester, physicalSize: const Size(900, 620));
      final FocusNode focusedNode = FocusNode();
      final TextEditingController filledController = TextEditingController(
        text: invisibleText,
      );
      final TextEditingController readOnlyController = TextEditingController(
        text: invisibleText,
      );
      addTearDown(focusedNode.dispose);
      addTearDown(filledController.dispose);
      addTearDown(readOnlyController.dispose);

      await tester.pumpWidget(
        goldenTestApp(
          theme: scene.theme,
          child: _FieldStateScene(
            focusedNode: focusedNode,
            filledController: filledController,
            readOnlyController: readOnlyController,
            invisibleText: invisibleText,
          ),
        ),
      );
      focusedNode.requestFocus();
      await tester.pump();

      await expectLater(
        find.byType(_FieldStateScene),
        matchesGoldenFile('goldens/nemo_field_${scene.name}.png'),
      );
    });
  }
}

class _FieldStateScene extends StatelessWidget {
  const _FieldStateScene({
    required this.focusedNode,
    required this.filledController,
    required this.readOnlyController,
    required this.invisibleText,
  });

  final FocusNode focusedNode;
  final TextEditingController filledController;
  final TextEditingController readOnlyController;
  final String invisibleText;

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    return ColoredBox(
      color: theme.semantic.surface,
      child: Padding(
        padding: EdgeInsets.all(theme.foundation.space24),
        child: Wrap(
          spacing: theme.foundation.space24,
          runSpacing: theme.foundation.space24,
          children: <Widget>[
            SizedBox(
              width: 260,
              child: NemoField(label: invisibleText, hintText: invisibleText),
            ),
            SizedBox(
              width: 260,
              child: NemoField(label: invisibleText, focusNode: focusedNode),
            ),
            SizedBox(
              width: 260,
              child: Stack(
                children: <Widget>[
                  NemoField(label: invisibleText, controller: filledController),
                  // Glyph-free surrogate for the caller-owned entered value.
                  PositionedDirectional(
                    start: 16,
                    bottom: 14,
                    child: ExcludeSemantics(
                      child: ColoredBox(
                        color: theme.semantic.foreground,
                        child: const SizedBox(width: 96, height: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 260,
              child: NemoField(label: invisibleText, errorText: invisibleText),
            ),
            SizedBox(
              width: 260,
              child: NemoField(label: invisibleText, enabled: false),
            ),
            SizedBox(
              width: 260,
              child: NemoField(
                label: invisibleText,
                controller: readOnlyController,
                readOnly: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
