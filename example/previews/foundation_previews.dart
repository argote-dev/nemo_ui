import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:nemo_ui/nemo_ui.dart';

/// Native Flutter Widget Previewer definitions for Nemo's foundation.
@Preview(name: 'Light foundation', group: 'Foundation')
Widget lightFoundationPreview() {
  return _FoundationPreview(theme: NemoThemeData.light());
}

/// Native Flutter Widget Previewer definition for Nemo high contrast.
@Preview(name: 'High contrast foundation', group: 'Foundation')
Widget highContrastFoundationPreview() {
  return _FoundationPreview(theme: NemoThemeData.highContrast());
}

class _FoundationPreview extends StatelessWidget {
  const _FoundationPreview({required this.theme});

  final NemoThemeData theme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(extensions: <ThemeExtension<dynamic>>[theme]),
      home: Builder(
        builder: (BuildContext context) => Scaffold(
          backgroundColor: NemoTheme.of(context).semantic.surface,
          body: Center(
            child: Text(
              'Nemo foundation',
              style: TextStyle(
                color: NemoTheme.of(context).semantic.foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
