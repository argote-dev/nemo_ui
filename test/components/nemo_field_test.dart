import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nemo_ui/nemo_ui.dart';

void main() {
  group('NemoField', () {
    testWidgets('keeps its label visible and preserves text editing seams', (
      tester,
    ) async {
      final controller = TextEditingController();
      final changes = <String>[];
      String? submitted;
      await tester.pumpWidget(
        _host(
          NemoField(
            label: 'Email address',
            hintText: 'you@example.com',
            supportingText: 'We will only use this for receipts.',
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onChanged: changes.add,
            onSubmitted: (value) => submitted = value,
          ),
        ),
      );

      expect(find.text('Email address'), findsOneWidget);
      expect(find.text('you@example.com'), findsOneWidget);
      expect(find.text('We will only use this for receipts.'), findsOneWidget);
      final emptySemantics = tester.getSemantics(find.byType(TextField));
      expect(emptySemantics.label, contains('Email address'));
      expect(emptySemantics.hint, contains('you@example.com'));
      await tester.enterText(find.byType(TextField), 'a@nemo.dev');
      await tester.pump();
      expect(controller.text, 'a@nemo.dev');
      expect(changes, <String>['a@nemo.dev']);
      expect(
        tester.getSemantics(find.byType(TextField)).value,
        contains('a@nemo.dev'),
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(submitted, 'a@nemo.dev');
      expect(find.text('Email address'), findsOneWidget);
    });

    testWidgets('supports focus and controller ownership across host updates', (
      tester,
    ) async {
      final externalFocus = FocusNode();
      final externalController = TextEditingController(text: 'external');
      await tester.pumpWidget(
        _host(
          NemoField(
            label: 'Name',
            focusNode: externalFocus,
            controller: externalController,
          ),
        ),
      );
      externalFocus.requestFocus();
      await tester.pump();
      expect(externalFocus.hasFocus, isTrue);
      await tester.pumpWidget(_host(const NemoField(label: 'Name')));
      await tester.enterText(find.byType(TextField), 'internal');
      expect(find.text('internal'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      expect(externalController.text, 'external');
      externalFocus.dispose();
      externalController.dispose();
    });

    testWidgets(
      'announces semantic label, error and state without duplicate wrapping',
      (tester) async {
        await tester.pumpWidget(
          _host(
            const NemoField(
              label: 'Password',
              semanticLabel: 'Account password',
              errorText: 'Password is required',
              obscureText: true,
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(TextField));
        expect(semantics.label, contains('Account password'));
        expect(semantics.hint, contains('Password is required'));
        expect(semantics.flagsCollection.isTextField, isTrue);
        expect(semantics.flagsCollection.isObscured, isTrue);
        final errorSemantics = tester.getSemantics(
          find.bySemanticsLabel('Password is required'),
        );
        expect(errorSemantics.flagsCollection.isLiveRegion, isTrue);
      },
    );

    testWidgets('keeps disabled and read-only states distinct', (tester) async {
      final readOnly = TextEditingController(text: 'fixed');
      await tester.pumpWidget(
        _host(
          Column(
            children: <Widget>[
              const NemoField(label: 'Disabled', enabled: false),
              NemoField(
                label: 'Read only',
                controller: readOnly,
                readOnly: true,
              ),
            ],
          ),
        ),
      );
      final fields = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      expect(fields[0].enabled, isFalse);
      expect(fields[1].readOnly, isTrue);
      expect(
        tester
            .getSemantics(find.byType(TextField).at(0))
            .flagsCollection
            .isEnabled,
        Tristate.isFalse,
      );
      expect(
        tester
            .getSemantics(find.byType(TextField).at(1))
            .flagsCollection
            .isReadOnly,
        isTrue,
      );
      readOnly.dispose();
    });

    testWidgets('keeps supporting and error content independently visible', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const NemoField(
            label: 'Email',
            supportingText: 'Use a work address.',
            errorText: 'Enter a valid address.',
          ),
        ),
      );

      expect(find.text('Use a work address.'), findsOneWidget);
      expect(find.text('Enter a valid address.'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(TextField)).hint,
        contains('Enter a valid address.'),
      );
    });

    testWidgets('participates in conventional keyboard traversal', (
      tester,
    ) async {
      final first = FocusNode();
      final second = FocusNode();
      await tester.pumpWidget(
        _host(
          Column(
            children: <Widget>[
              NemoField(label: 'First', focusNode: first, autofocus: true),
              NemoField(label: 'Second', focusNode: second),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(first.hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(second.hasFocus, isTrue);
      first.dispose();
      second.dispose();
    });

    testWidgets('updates enabled and read-only focus behavior', (tester) async {
      final focusNode = FocusNode();
      await tester.pumpWidget(
        _host(NemoField(label: 'Status', focusNode: focusNode)),
      );
      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      await tester.pumpWidget(
        _host(NemoField(label: 'Status', focusNode: focusNode, enabled: false)),
      );
      await tester.pump();
      expect(focusNode.hasFocus, isFalse);

      await tester.pumpWidget(
        _host(NemoField(label: 'Status', focusNode: focusNode, readOnly: true)),
      );
      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);
      expect(
        tester.getSemantics(find.byType(TextField)).flagsCollection.isReadOnly,
        isTrue,
      );
      focusNode.dispose();
    });

    testWidgets(
      'adapts to RTL, enlarged text, all themes, and reduced motion',
      (tester) async {
        for (final theme in <NemoThemeData>[
          NemoThemeData.light(),
          NemoThemeData.dark(),
          NemoThemeData.highContrast(),
        ]) {
          await tester.pumpWidget(
            _host(
              const NemoField(label: 'البريد الإلكتروني', errorText: 'مطلوب'),
              theme: theme,
              textDirection: TextDirection.rtl,
              textScaler: const TextScaler.linear(2),
              disableAnimations: true,
            ),
          );
          expect(find.text('البريد الإلكتروني'), findsOneWidget);
          expect(find.text('مطلوب'), findsOneWidget);
          expect(
            tester
                .getSize(
                  find.byKey(const ValueKey<String>('nemo-field-surface')),
                )
                .height,
            greaterThanOrEqualTo(48),
          );
          expect(tester.takeException(), isNull);
        }
      },
    );
  });
}

Widget _host(
  Widget child, {
  NemoThemeData? theme,
  TextDirection textDirection = TextDirection.ltr,
  TextScaler textScaler = TextScaler.noScaling,
  bool disableAnimations = false,
}) => MaterialApp(
  theme: ThemeData(
    extensions: <ThemeExtension<dynamic>>[theme ?? NemoThemeData.light()],
  ),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: textScaler, disableAnimations: disableAnimations),
    child: Directionality(textDirection: textDirection, child: child!),
  ),
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(16), child: child),
  ),
);
