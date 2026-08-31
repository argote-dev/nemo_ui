import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nemo_ui/nemo_ui.dart';

/// Configures a widget test view for a deterministic golden capture.
///
/// Golden scenes use a fixed physical size and device-pixel ratio. Pair this
/// with [goldenTestApp] to pin the remaining environment inputs.
void configureGoldenTest(WidgetTester tester, {required Size physicalSize}) {
  tester.view.physicalSize = physicalSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Returns the deterministic Material theme used by golden scenes.
ThemeData goldenThemeData(NemoThemeData theme) => ThemeData(
  platform: TargetPlatform.android,
  fontFamily: 'Ahem',
  extensions: <ThemeExtension<dynamic>>[theme],
);

/// Hosts [child] in the fixed locale, text scale, animation, and font setup
/// used for golden captures.
Widget goldenTestApp({
  required Widget child,
  NemoThemeData? theme,
  bool scaffold = true,
  bool disableAnimations = true,
}) {
  final NemoThemeData resolvedTheme = theme ?? NemoThemeData.light();
  final Widget configuredChild = MediaQuery(
    data: MediaQueryData(
      disableAnimations: disableAnimations,
      textScaler: TextScaler.noScaling,
    ),
    child: child,
  );
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: const Locale('en'),
    supportedLocales: NemoLocalizations.supportedLocales,
    localizationsDelegates: NemoLocalizations.localizationsDelegates,
    theme: goldenThemeData(resolvedTheme),
    home: scaffold
        ? Scaffold(
            backgroundColor: resolvedTheme.semantic.surface,
            body: configuredChild,
          )
        : configuredChild,
  );
}
