import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nemo_ui/nemo_ui.dart';

/// Configures the view inputs shared by canonical golden captures.
///
/// Canonical baselines are rasterized by the Ubuntu 24.04 x64 GitHub Actions
/// job using Flutter 3.47.0. Local captures are useful diagnostics, but Skia does not
/// promise byte-identical blurred-shadow output across hosts. Pair this with
/// [goldenTestApp] to pin the remaining scene inputs.
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

/// Hosts [child] with the pinned locale, platform, font, text scale, and
/// animation inputs used by canonical golden captures.
///
/// Each scene must provide its own opaque background, rather than inheriting
/// compositor state from a test host.
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
